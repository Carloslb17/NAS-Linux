#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up storage directories..."

for dir in "$NAS_PATH" "$NAS_PATH/users" "$BACKUP_PATH" "$MEDIA_PATH" "$NAS_PATH/snapshots"; do
    if [ ! -d "$dir" ]; then
        sudo mkdir -p "$dir"
        log_output "Created directory: $dir"
    else
        log_output "Directory already exists: $dir"
    fi
done

sudo chmod -R 775 "$NAS_PATH"
sudo chown -R "$USER:$USER" "$NAS_PATH"
log_output "Permissions and ownership set."
