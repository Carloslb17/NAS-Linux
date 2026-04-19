#!/bin/bash
LOG_FILE="logs/tests.log"
mkdir -p logs
touch "$LOG_FILE"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] SNAPSHOT_TEST: $1" | tee -a "$LOG_FILE"; }

errors=0
log "Starting Snapshot Tests"

SNAP_DIR="/srv/nas/snapshots"

if [ -d "$SNAP_DIR" ]; then
    log "[OK] Snapshot directory exists at $SNAP_DIR"
    snap_count=$(find "$SNAP_DIR" -maxdepth 1 -name "snap-*" -o -name "latest" | wc -l)
    if [ "$snap_count" -gt 0 ]; then
        log "[OK] At least one snapshot is present"
    else
        log "[FAIL] No snapshots found"
        errors=$((errors+1))
    fi
else
    log "[FAIL] Snapshot directory does not exist at $SNAP_DIR"
    errors=$((errors+1))
fi

if [ $errors -ne 0 ]; then
    log "Snapshot tests FAILED"
    exit 1
fi
log "Snapshot tests PASSED"
exit 0
