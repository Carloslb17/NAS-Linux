#!/bin/bash
# Wrapper script for manual snapshots
# The actual snapshot job is installed via setup_snapshots.sh at /usr/local/bin/nas-snapshot.sh

LOG_FILE="logs/snapshot.log"
mkdir -p logs

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Manual snapshot initiated..."

if [ -x /usr/local/bin/nas-snapshot.sh ]; then
    log "Running system snapshot..."
    sudo /usr/local/bin/nas-snapshot.sh
    log "Snapshot completed."
else
    log "Snapshot script not yet installed. Run ./install.sh first."
    exit 1
fi
