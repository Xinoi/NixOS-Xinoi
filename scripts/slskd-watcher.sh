#!/usr/bin/env bash
# Abhängigkeiten: inotify-tools, beets

WATCH_DIR="/mnt/data/slskd/downloads"
SETTLE_TIME=30
LOG_FILE="${HOME}/music-watch.log"

[[ -d "$WATCH_DIR" ]] || { echo "Verzeichnis nicht gefunden: $WATCH_DIR"; exit 1; }

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "Gestartet – überwache: $WATCH_DIR"

inotifywait --monitor --recursive --quiet \
  --event close_write --event moved_to \
  --format '%w%f' \
  "$WATCH_DIR" | while IFS= read -r path; do

  rel="${path#"$WATCH_DIR"/}"
  top="${rel%%/*}"
  import_dir="$WATCH_DIR/$top"

  log "Neu: $path → warte ${SETTLE_TIME}s..."
  sleep "$SETTLE_TIME"

  log "Importiere: $import_dir"
  beet import --quiet "$import_dir" 2>&1 | tee -a "$LOG_FILE"
done
