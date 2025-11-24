#!/bin/bash

# --- Configuration ---
# List the folders you want to backup, separated by spaces.
# Example: FOLDERS_TO_BACKUP="/home/user/documents /var/log/apache2"
FOLDERS_TO_BACKUP="<folder1> <folder2> <folder3>"

# Destination details
DESTINATION_USER="<username>"
DESTINATION_HOST="<remote_server_ip_or_hostname>"
DESTINATION_PATH="/path/to/remote/backup/location"

# --- Script Logic ---

# 1. Define the filename with the current date/time
# Format: YYYY-MM-DD-HHMMSS.tar.gz
DATE_STRING=$(date +%Y-%m-%d-%H%M%S)
ARCHIVE_NAME="backup_${DATE_STRING}.tar.gz"

echo "Starting backup process..."
echo "Folders to pack: ${FOLDERS_TO_BACKUP}"
echo "Archive name: ${ARCHIVE_NAME}"

# 2. Create the compressed tarball (tar.gz)
# 'c'reate, 'z'zip, 'v'erbose, 'f'ilename
tar -czf ${ARCHIVE_NAME} ${FOLDERS_TO_BACKUP}

# Check if the tar command was successful
if [ $? -ne 0 ]; then
    echo "Error: Tar creation failed."
    exit 1
fi

echo "Successfully created archive: ${ARCHIVE_NAME}"

# 3. Transfer the archive using rsync
# 'P'rogress, 'a'rchive mode, 'z'ip (compress during transfer)
DESTINATION="${DESTINATION_USER}@${DESTINATION_HOST}:${DESTINATION_PATH}"

echo "Starting transfer to ${DESTINATION}..."

# rsync -Paz local_file remote_user@remote_host:remote_path
rsync -Paz ${ARCHIVE_NAME} ${DESTINATION}

# Check if the rsync command was successful
if [ $? -ne 0 ]; then
    echo "Error: Rsync transfer failed."
    # You might want to remove the local tar file here if the transfer failed
    # rm -f ${ARCHIVE_NAME}
    exit 1
fi

echo "Transfer successful!"

# 4. Clean up the local archive (optional)
echo "Removing local archive file: ${ARCHIVE_NAME}"
rm -f ${ARCHIVE_NAME}

echo "Backup and transfer complete."
