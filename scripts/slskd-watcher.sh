WATCH_DIR="/mnt/data/slskd/downloads"
SETTLE_TIME=60
LOG_FILE="${HOME}/music-watch.log"
PENDING_DIR="$(mktemp -d)"

# Dateitypen die nach erfolgreichem Import gelöscht werden
JUNK_EXTENSIONS=("cue" "log" "m3u" "m3u8" "nfo" "txt" "jpg" "png" "pdf")

trap 'rm -rf "$PENDING_DIR"; exit' SIGINT SIGTERM

[[ -d "$WATCH_DIR" ]] || { echo "Verzeichnis nicht gefunden: $WATCH_DIR"; exit 1; }

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "Gestartet – überwache: $WATCH_DIR"

inotifywait --monitor --recursive --quiet \
  --event close_write --event moved_to \
  --format '%w%f' \
  "$WATCH_DIR" | while IFS= read -r path; do
    rel="${path#"$WATCH_DIR"/}"
    top="${rel%%/*}"
    [[ -z "$top" ]] && continue
    echo "$(date +%s)" > "$PENDING_DIR/${top//\//_}"
    log "Neu: $path"
done &

while true; do
  sleep 10
  now=$(date +%s)
  for f in "$PENDING_DIR"/*; do
    [[ -f "$f" ]] || continue
    last=$(cat "$f")
    elapsed=$(( now - last ))
    if (( elapsed >= SETTLE_TIME )); then
      top=$(basename "$f")
      import_dir="$WATCH_DIR/$top"
      rm "$f"
      [[ -d "$import_dir" ]] || continue

      log "Importiere: $import_dir"
      output=$(beet import --quiet "$import_dir" 2>&1)
      echo "$output" | tee -a "$LOG_FILE"

      # Nur aufräumen wenn beets was importiert hat (nicht bei "Skipping")
      if echo "$output" | grep -q "Skipping"; then
        log "Geskippt, Ordner bleibt: $import_dir"
      else
        log "Cleanup: lösche Überbleibsel in $import_dir"
        for ext in "${JUNK_EXTENSIONS[@]}"; do
          find "$import_dir" -iname "*.${ext}" -delete
        done
        # Leere Ordner entfernen
        find "$import_dir" -type d -empty -delete
      fi
    fi
  done
done
