#!/usr/bin/env bash
# =============================================================================
# music-watch.sh – Überwacht einen Musik-Download-Ordner und importiert
#                  neu heruntergeladene Musik automatisch mit beets.
#
# Abhängigkeiten: inotifywait (inotify-tools), beet
# Installation:   sudo apt install inotify-tools beets
#                 sudo dnf install inotify-tools beets
#
# Verwendung:     ./music-watch.sh [OPTIONEN]
#   -d DIR        Zu überwachender Verzeichnis (Standard: ~/Downloads/Music)
#   -w SEKUNDEN   Wartezeit nach letzter Änderung vor dem Import (Standard: 30)
#   -l DATEI      Logdatei (Standard: ~/music-watch.log)
#   -q            Ruhiger Modus (beet ohne interaktive Eingabeaufforderungen)
#   -n            Dry-run (beet --pretend, kein echter Import)
#   -h            Diese Hilfe anzeigen
# =============================================================================

set -euo pipefail

# ── Standardwerte ─────────────────────────────────────────────────────────────
WATCH_DIR="/mnt/data/slskd/downloads"
SETTLE_TIME=30          # Sekunden Ruhe abwarten, bevor der Import startet
LOG_FILE="${HOME}/music-watch.log"
QUIET=true
DRY_RUN=false
BEET_BIN="$(command -v beet 2>/dev/null || echo "")"

# ── Optionen parsen ───────────────────────────────────────────────────────────
while getopts ":d:w:l:qnh" opt; do
  case $opt in
    d) WATCH_DIR="$OPTARG" ;;
    w) SETTLE_TIME="$OPTARG" ;;
    l) LOG_FILE="$OPTARG" ;;
    q) QUIET=true ;;
    n) DRY_RUN=true ;;
    h)
      sed -n '/^# Verwendung/,/^# ====/p' "$0" | head -n -1 | sed 's/^# \?//'
      exit 0
      ;;
    :) echo "Fehler: Option -$OPTARG erfordert ein Argument." >&2; exit 1 ;;
    \?) echo "Fehler: Unbekannte Option -$OPTARG." >&2; exit 1 ;;
  esac
done

# ── Vorbedingungen prüfen ─────────────────────────────────────────────────────
check_deps() {
  local missing=()
  command -v inotifywait &>/dev/null || missing+=("inotifywait (Paket: inotify-tools)")
  [[ -n "$BEET_BIN" ]] || missing+=("beet (Paket: beets)")

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "FEHLER: Folgende Programme fehlen:" >&2
    printf '  • %s\n' "${missing[@]}" >&2
    exit 1
  fi
}

[[ -d "$WATCH_DIR" ]] || { echo "FEHLER: Verzeichnis nicht gefunden: $WATCH_DIR" >&2; exit 1; }
check_deps

# ── Hilfsfunktionen ───────────────────────────────────────────────────────────
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  echo "$msg"
  echo "$msg" >> "$LOG_FILE"
}

run_import() {
  local dir="$1"
  local beet_args=("import")

  $QUIET    && beet_args+=("--quiet")
  $DRY_RUN  && beet_args+=("--pretend")

  log "Starte beet-Import für: $dir"

  if "$BEET_BIN" "${beet_args[@]}" "$dir" >> "$LOG_FILE" 2>&1; then
    log "Import erfolgreich abgeschlossen: $dir"
  else
    log "WARNUNG: beet import beendete sich mit Fehlercode $? für: $dir"
  fi
}

# ── Pendende Verzeichnisse verwalten ──────────────────────────────────────────
# Wir sammeln geänderte Top-Level-Unterverzeichnisse (= ein Album / ein Künstler)
# und warten, bis SETTLE_TIME Sekunden lang keine weiteren Änderungen kamen.

declare -A PENDING_DIRS   # dir -> Unix-Timestamp der letzten Aktivität

mark_pending() {
  local path="$1"
  # Nimm das erste Unterverzeichnis unterhalb von WATCH_DIR als "Import-Einheit"
  local rel="${path#"$WATCH_DIR"/}"
  local top_level="${rel%%/*}"

  if [[ -z "$top_level" ]]; then
    # Datei direkt im WATCH_DIR – ganzen Ordner markieren
    PENDING_DIRS["$WATCH_DIR"]=$(date +%s)
  else
    PENDING_DIRS["$WATCH_DIR/$top_level"]=$(date +%s)
  fi
}

check_and_import() {
  local now
  now=$(date +%s)
  local to_import=()

  for dir in "${!PENDING_DIRS[@]}"; do
    local last_ts="${PENDING_DIRS[$dir]}"
    local elapsed=$(( now - last_ts ))
    if (( elapsed >= SETTLE_TIME )); then
      to_import+=("$dir")
    fi
  done

  for dir in "${to_import[@]}"; do
    unset "PENDING_DIRS[$dir]"
    [[ -d "$dir" ]] && run_import "$dir"
  done
}

# ── Haupt-Schleife ────────────────────────────────────────────────────────────
log "music-watch gestartet"
log "  Überwachtes Verzeichnis : $WATCH_DIR"
log "  Wartezeit               : ${SETTLE_TIME}s"
log "  Logdatei                : $LOG_FILE"
log "  Ruhiger Modus           : $QUIET"
log "  Dry-run                 : $DRY_RUN"

# Signalbehandlung für sauberes Beenden
trap 'log "music-watch beendet."; exit 0' SIGINT SIGTERM

# inotifywait im Monitor-Modus, gibt jedes Ereignis als Zeile aus
inotifywait \
  --monitor \
  --recursive \
  --format '%w%f' \
  --event close_write \
  --event moved_to \
  --event create \
  --event delete \
  "$WATCH_DIR" 2>/dev/null |
while IFS= read -r changed_path; do
  log "Änderung erkannt: $changed_path"
  mark_pending "$changed_path"
  check_and_import
done &

INOTIFY_PID=$!

# Polling-Loop: prüft regelmäßig, ob Settle-Zeit abgelaufen ist,
# auch wenn inotifywait zwischendurch keine neuen Ereignisse liefert.
while kill -0 "$INOTIFY_PID" 2>/dev/null; do
  check_and_import
  sleep 5
done
