#!/bin/bash

# --- Configuration ---
FOLDERS_TO_BACKUP="books siyuan compose-files /home/xinoi/homepage /home/xinoi/linkding /home/xinoi/slskd"

# Destination details
DESTINATION_USER="xinoi"
DESTINATION_HOST="amdfull"
DESTINATION_PATH="/home/xinoi/Documents/raspi_backup/other"

# socket for ssh
SSH_SOCKET="/tmp/ssh-mux-${DESTINATION_USER}@${DESTINATION_HOST}:22"

# --- Script Logic ---

# Establish the Master SSH Connection and Request Password Prompt
echo "Establishing secure connection to remote server..."

ssh -M -S ${SSH_SOCKET} -Nf ${DESTINATION_USER}@${DESTINATION_HOST}

# Check if the master connection was successful (i.e., password/auth succeeded)
if [ $? -ne 0 ]; then
    echo "Error: Failed to establish SSH connection. Exiting."
    ssh -O exit -S ${SSH_SOCKET} ${DESTINATION_USER}@${DESTINATION_HOST} 2>/dev/null
    exit 1
fi

echo "Connection established. Starting archive creation..."

# 1. Define the filename with the current date/time
# Format: YYYY-MM-DD-HHMMSS.tar.gz
DATE_STRING=$(date +%d-%m-%Y-%H%M%S)
ARCHIVE_NAME="other_${DATE_STRING}.tar.gz"

echo "Starting backup process..."
echo "Folders to pack: ${FOLDERS_TO_BACKUP}"
echo "Archive name: ${ARCHIVE_NAME}"

# 2. Create the compressed tarball (tar.gz)
tar --ignore-failed-read -czf ${ARCHIVE_NAME} ${FOLDERS_TO_BACKUP}

# Check if the tar command was successful
if [ $? -ne 0 ]; then
    echo "Error: Tar creation failed."
    ssh -O exit -S ${SSH_SOCKET} ${DESTINATION_USER}@${DESTINATION_HOST} 2>/dev/null
    exit 1
fi

echo "Successfully created archive: ${ARCHIVE_NAME}"

# 3. Transfer the archive using rsync
DESTINATION="${DESTINATION_USER}@${DESTINATION_HOST}:${DESTINATION_PATH}"

echo "Starting transfer to ${DESTINATION}..."

# rsync -Paz local_file remote_user@remote_host:remote_path
rsync -Paz -e "ssh -S ${SSH_SOCKET}" ${ARCHIVE_NAME} ${DESTINATION}

# Check if the rsync command was successful
if [ $? -ne 0 ]; then
    echo "Error: Rsync transfer failed."
    rm -f ${ARCHIVE_NAME}
    ssh -O exit -S ${SSH_SOCKET} ${DESTINATION_USER}@${DESTINATION_HOST} 2>/dev/null
    exit 1
fi

echo "Transfer successful!"

# 4. Clean up the local archive and ssh socket
echo "Removing local archive file: ${ARCHIVE_NAME}"
rm -f ${ARCHIVE_NAME}

echo "Removing SSH Socket"
ssh -O exit -S ${SSH_SOCKET} ${DESTINATION_USER}@${DESTINATION_HOST} 2>/dev/null

echo "Backup and transfer complete."
