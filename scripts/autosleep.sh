#!/bin/bash
# ─── CONFIG ───────────────────────────────────────────────────────────────────
IDLE_THRESHOLD=3600
CHECK_INTERVAL=60
LOG_FILE="/var/log/autosleep.log"
MAX_LOG_LINES=500

NET_IFACES="enp35s0"
DISKS="sda"

NET_THRESHOLD=600000
DISK_THRESHOLD=20000

# How many consecutive active checks before resetting the idle timer.
# Filters out short background spikes (cron jobs, RSS pulls, DB flushes).
# 3 = activity must persist for 3 * CHECK_INTERVAL seconds (3 min) to count.
ACTIVE_STREAK_REQUIRED=3

ACTIVE_PORTS="8096 8000 8082"
# ─────────────────────────────────────────────────────────────────────────────

idle_seconds=0
active_streak=0

log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
  echo "$msg"
  echo "$msg" >> "$LOG_FILE"
  local lines
  lines=$(wc -l < "$LOG_FILE")
  if [ "$lines" -gt "$MAX_LOG_LINES" ]; then
    tail -n $((MAX_LOG_LINES / 2)) "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    log "Log rotated."
  fi
}

get_disk_io() {
  local total=0
  for disk in $DISKS; do
    local stats
    stats=$(grep -w "$disk" /proc/diskstats 2>/dev/null | awk '{print $6+$10}')
    total=$((total + ${stats:-0}))
  done
  echo "$total"
}

get_net_io() {
  local total=0
  for iface in $NET_IFACES; do
    local rx tx
    rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
    tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
    total=$((total + rx + tx))
  done
  echo "$total"
}

get_active_port_connections() {
  local matched_ports=()
  for port in $ACTIVE_PORTS; do
    local count
    count=$(ss -tn state established 2>/dev/null | awk '{print $4}' | grep -c ":${port}$" 2>/dev/null || true)
    count=${count//[^0-9]/}
    count=${count:-0}
    if [ "$count" -gt 0 ]; then
      matched_ports+=("${port}(${count})")
    fi
  done
  echo "${matched_ports[*]}"
}

is_vm_running() {
  virsh list --state-running 2>/dev/null | grep -qc "running"
}

log "========================================"
log "Autosleep script started."
log "Idle threshold  : ${IDLE_THRESHOLD}s"
log "Check interval  : ${CHECK_INTERVAL}s"
log "Disks           : $DISKS"
log "Interfaces      : $NET_IFACES"
log "Net threshold   : ${NET_THRESHOLD} bytes/interval"
log "Disk threshold  : ${DISK_THRESHOLD} sectors/interval"
log "Active streak   : ${ACTIVE_STREAK_REQUIRED} consecutive checks to reset timer"
log "Watched ports   : $ACTIVE_PORTS"
log "========================================"

prev_disk_io=$(get_disk_io)
prev_net_io=$(get_net_io)

while true; do
  sleep "$CHECK_INTERVAL"

  curr_disk_io=$(get_disk_io)
  curr_net_io=$(get_net_io)

  disk_delta=$((curr_disk_io - prev_disk_io))
  net_delta=$((curr_net_io - prev_net_io))

  prev_disk_io=$curr_disk_io
  prev_net_io=$curr_net_io

  active_reason=""

  # ── VM check ────────────────────────────────────────────────────────────────
  if is_vm_running 2>/dev/null; then
    active_reason="VM running"
  fi

  # ── Active port connections ──────────────────────────────────────────────────
  if [ -z "$active_reason" ]; then
    port_hits=$(get_active_port_connections)
    if [ -n "$port_hits" ]; then
      active_reason="Active connections on port(s): $port_hits"
    fi
  fi

  # ── Network I/O above threshold ─────────────────────────────────────────────
  if [ -z "$active_reason" ] && [ "$net_delta" -gt "$NET_THRESHOLD" ]; then
    active_reason="High net I/O: +${net_delta} bytes"
  fi

  # ── Disk I/O above threshold ─────────────────────────────────────────────────
  if [ -z "$active_reason" ] && [ "$disk_delta" -gt "$DISK_THRESHOLD" ]; then
    active_reason="High disk I/O: +${disk_delta} sectors"
  fi

  # ── Streak logic — only reset timer if active for N checks in a row ──────────
  if [ -n "$active_reason" ]; then
    active_streak=$((active_streak + 1))
    if [ "$active_streak" -ge "$ACTIVE_STREAK_REQUIRED" ]; then
      # Genuine sustained activity — reset idle timer
      log "ACTIVE  | ${active_reason} (streak: ${active_streak}) — timer reset (was at ${idle_seconds}s)."
      idle_seconds=0
    else
      # Spike — warn but don't reset yet
      log "SPIKE   | ${active_reason} (streak: ${active_streak}/${ACTIVE_STREAK_REQUIRED}) — waiting to confirm."
    fi
  else
    if [ "$active_streak" -gt 0 ]; then
      log "IDLE    | Spike cleared after ${active_streak} check(s). Resuming idle count."
    fi
    active_streak=0
    idle_seconds=$((idle_seconds + CHECK_INTERVAL))
    remaining=$((IDLE_THRESHOLD - idle_seconds))
    log "IDLE    | Disk: +${disk_delta} | Net: +${net_delta} bytes | Idle: ${idle_seconds}s / ${IDLE_THRESHOLD}s | Sleep in: ${remaining}s"
  fi

  # ── Sleep trigger ─────────────────────────────────────────────────────────────
  if [ "$idle_seconds" -ge "$IDLE_THRESHOLD" ]; then
    log "SLEEP   | Threshold reached. Syncing and sleeping..."
    sync
    sleep 2
    echo mem > /sys/power/state
    idle_seconds=0
    active_streak=0
    log "WAKE    | System woke up. Resuming monitoring."
  fi

done
