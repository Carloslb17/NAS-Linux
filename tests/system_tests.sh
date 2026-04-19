#!/bin/bash
LOG_FILE="logs/tests.log"
mkdir -p logs
touch "$LOG_FILE"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] SYSTEM_TEST: $1" | tee -a "$LOG_FILE"; }

errors=0
log "Starting System Tests"

for svc in docker smbd; do
    if systemctl is-active --quiet "$svc"; then
        log "[OK] Service $svc running"
    else
        log "[FAIL] Service $svc not running"
        errors=$((errors+1))
    fi
done

if command -v tailscaled &>/dev/null && systemctl is-active --quiet tailscaled; then
    log "[OK] Service tailscaled running"
else
    log "[WARNING] Service tailscaled not locally detected or running"
fi

if sudo ufw status | grep -i "active" > /dev/null; then
    log "[OK] Firewall active"
else
    log "[WARNING] Firewall is not active (Ignored for CI)"
fi

for req_script in "scripts/health_check.sh" "scripts/backup.sh" "scripts/create_snapshot.sh"; do
    if find . -maxdepth 3 -path "*/$req_script" | grep -q .; then
        log "[OK] Required script exists: $req_script"
    else
        log "[FAIL] Missing script: $req_script"
        errors=$((errors+1))
    fi
done

for req_log in "logs/install.log" "logs/backup.log" "logs/alerts.log"; do
    if find . -maxdepth 3 -path "*/$req_log" | grep -q .; then
        log "[OK] Log file exists: $req_log"
    else
        log "[FAIL] Log file missing: $req_log"
        errors=$((errors+1))
    fi
done

if [ $errors -ne 0 ]; then
    log "System tests FAILED"
    exit 1
fi
log "System tests PASSED"
exit 0
