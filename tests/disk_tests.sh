#!/bin/bash
LOG_FILE="logs/tests.log"
mkdir -p logs
touch "$LOG_FILE"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] DISK_TEST: $1" | tee -a "$LOG_FILE"; }

errors=0
log "Starting Disk Tests"

if df -h / >/dev/null 2>&1; then
    log "[OK] Filesystem is mounted"
else
    log "[FAIL] Main filesystem not accessible"
    errors=$((errors+1))
fi

USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ -n "$USAGE" ] && [ "$USAGE" -gt 85 ]; then
    log "[WARNING] Disk usage is above 85% (Current: ${USAGE}%)"
else
    log "[OK] Disk usage is healthy (Current: ${USAGE}%)"
fi

AVAIL=$(df -h / | awk 'NR==2 {print $4}')
log "[OK] Available space: $AVAIL"

if [ $errors -ne 0 ]; then
    log "Disk tests FAILED"
    exit 1
fi
log "Disk tests PASSED"
exit 0
