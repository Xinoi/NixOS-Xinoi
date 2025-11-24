#!/bin/bash

# --- Configuration ---
BACKUP_DIR="/home/xinoi/backup"
SEAFILE_DATA_SOURCE="/media/xinoi/raspiStorage/seafile-data/seafile"
DB_CONTAINER="seafile-mysql"
DB_USER="seafile"
DB_PASSWORD="<YOUR_DB_PASSWORD>" # !! REPLACE ME !!
REMOTE_USER="xinoi"
REMOTE_HOST="<YOUR_PC_IP_OR_HOSTNAME>" # !! REPLACE ME !!
REMOTE_PATH="/path/to/backup/on/pc/" # !! REPLACE ME !!

# Create date variables for naming the backup file
DATE=$(date +%d.%m.%Y)
ARCHIVE_NAME="backup_$DATE.tar.gz"
DATA_DIR="$BACKUP_DIR/data"
DB_DIR="$BACKUP_DIR/databases"

# --- Functions for Robustness ---

function log_message {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - $1"
}

function exit_on_error {
    log_message "ERROR: $1" >&2
    log_message "Backup script failed."
    exit 1
}

# --- 1. Preparation and Cleanup ---
log_message "Starting Seafile hot backup process..."

# Create or clear the necessary directories
mkdir -p "$DATA_DIR" || exit_on_error "Failed to create data directory."
mkdir -p "$DB_DIR" || exit_on_error "Failed to create databases directory."

# --- 2. Database Backup (First for Consistency) ---
log_message "Dumping databases into $DB_DIR (Hot Dump)..."

# Clean up old SQL files in the dump location
rm -f "$DB_DIR"/*.sql

# Use --single-transaction for InnoDB tables to ensure a consistent snapshot without locks
sudo docker exec "$DB_CONTAINER" mariadb-dump -u "$DB_USER" -p"$DB_PASSWORD" --single-transaction ccnet_db > "$DB_DIR"/ccnet_db.sql || exit_on_error "CCNet DB dump failed."
sudo docker exec "$DB_CONTAINER" mariadb-dump -u "$DB_USER" -p"$DB_PASSWORD" --single-transaction seafile_db > "$DB_DIR"/seafile_db.sql || exit_on_error "Seafile DB dump failed."
sudo docker exec "$DB_CONTAINER" mariadb-dump -u "$DB_USER" -p"$DB_PASSWORD" --single-transaction seahub_db > "$DB_DIR"/seahub_db.sql || exit_on_error "Seahub DB dump failed."

# --- 3. Backup Data (rsync) ---
log_message "Rsyncing Seafile data directory from $SEAFILE_DATA_SOURCE to $DATA_DIR..."
# The initial rsync is performed here, creating the 'data' folder structure.
# Using rsync means only changed blocks are copied, which is fast locally.
rsync -Paz "$SEAFILE_DATA_SOURCE"/ "$DATA_DIR"/ || exit_on_error "Rsync of Seafile data failed."

# --- 4. Create Tarball ---
log_message "Creating compressed archive: $ARCHIVE_NAME"
# Navigate to the main backup directory, then tar the subdirectories 'data' and 'databases'
cd "$BACKUP_DIR" || exit_on_error "Failed to navigate to backup directory."
tar -czf "$ARCHIVE_NAME" data databases || exit_on_error "Failed to create tar archive."

# --- 5. Rsync over Network (Push to PC) ---
log_message "Transferring $ARCHIVE_NAME to remote PC ($REMOTE_HOST)..."
# -P flag provides progress and allows partial resume for slow, unstable links.
rsync -Paz "$ARCHIVE_NAME" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"

if [ $? -ne 0 ]; then
    log_message "WARNING: Rsync transfer failed or was interrupted. The file is still on the server."
else
    log_message "Rsync transfer successful."
    
    # --- 6. Final Cleanup ---
    log_message "Cleaning up local archive and temporary directories."
    rm -f "$ARCHIVE_NAME"
    rm -rf data databases
fi

log_message "Backup process complete."
