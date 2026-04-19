#!/bin/bash
LOG_FILE="logs/tests.log"
mkdir -p logs
touch "$LOG_FILE"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] NETWORK_TEST: $1" | tee -a "$LOG_FILE"; }

errors=0
log "Starting Network Tests"

if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    log "[OK] Internet connectivity (8.8.8.8) is working"
else
    log "[FAIL] Internet connectivity (8.8.8.8) is DOWN"
    errors=$((errors+1))
fi

if ping -c 1 google.com >/dev/null 2>&1; then
    log "[OK] DNS resolution (google.com) is working"
else
    log "[FAIL] DNS resolution (google.com) is DOWN"
    errors=$((errors+1))
fi

if ping -c 1 127.0.0.1 >/dev/null 2>&1; then
    log "[OK] Local network access is working"
else
    log "[FAIL] Local network access is DOWN"
    errors=$((errors+1))
fi

if [ $errors -ne 0 ]; then
    log "Network tests FAILED"
    exit 1
fi
log "Network tests PASSED"
exit 0
