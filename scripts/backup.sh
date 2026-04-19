#!/bin/bash
# Wrapper script for manual backups
# The actual backup job is installed via setup_backups.sh at /usr/local/bin/nas-backup.sh

LOG_FILE="logs/backup.log"
mkdir -p logs

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Manual backup initiated..."

if [ -x /usr/local/bin/nas-backup.sh ]; then
    log "Running system backup..."
    sudo /usr/local/bin/nas-backup.sh
    log "Backup completed."
else
    log "Backup script not yet installed. Run ./install.sh first."
    exit 1
fi
