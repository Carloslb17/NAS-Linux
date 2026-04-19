#!/bin/bash
LOG_FILE="logs/tests.log"
mkdir -p logs
touch "$LOG_FILE"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] BACKUP_TEST: $1" | tee -a "$LOG_FILE"; }

errors=0
log "Starting Backup Tests"

BACKUP_DIR="/srv/nas/backups"

if [ -d "$BACKUP_DIR" ]; then
    log "[OK] Backup directory exists at $BACKUP_DIR"
    if [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
        log "[OK] Backup files found"
        recent=$(find "$BACKUP_DIR" -type f -mtime -1 | head -n 1)
        if [ -n "$recent" ]; then
            log "[OK] Recent backup timestamp verified"
        else
            log "[WARNING] No backups found in the last 24 hours (normal on fresh install)"
        fi
    else
        log "[WARNING] Backup directory is empty (normal on fresh install, first backup runs at 2 AM)"
    fi
else
    log "[FAIL] Backup directory does not exist at $BACKUP_DIR"
    errors=$((errors+1))
fi

if [ $errors -ne 0 ]; then
    log "Backup tests FAILED"
    exit 1
fi
log "Backup tests PASSED"
exit 0
