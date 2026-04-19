#!/bin/bash
set -e

mkdir -p logs
LOG_FILE="logs/deployment.log"
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] FINAL_VALIDATION: $1" | tee -a "$LOG_FILE"; }

log "Running final system validation..."
errors=0

if systemctl is-active --quiet docker; then
    log "[OK] Docker is running."
else
    log "[FAIL] Docker is NOT running."
    errors=$((errors+1))
fi

if docker ps | grep -q "immich_server"; then
    log "[OK] Immich container is running."
else
    log "[FAIL] Immich container is NOT running."
    errors=$((errors+1))
fi

if ip link show tailscale0 &> /dev/null; then
    log "[OK] Tailscale interface is connected."
else
    log "[FAIL] Tailscale interface is missing."
    errors=$((errors+1))
fi

if sudo ufw status | grep -qw "active"; then
    log "[OK] Firewall is active."
else
    log "[FAIL] Firewall is NOT active."
    errors=$((errors+1))
fi

if [ -d "/srv/nas/photos/admin" ] && [ -d "/srv/nas/photos/pareja" ]; then
    log "[OK] Photo directories exist."
else
    log "[FAIL] Photo directories do NOT exist."
    errors=$((errors+1))
fi

AVAIL=$(df -h / | awk 'NR==2 {print $4}')
log "[OK] Disk space available: $AVAIL"

status_code=$(curl -s -o /dev/null -w "%{http_code}" --retry 3 --retry-delay 2 --retry-connrefused "http://localhost:2283/api/server-info" || echo "failed")
if [ "$status_code" == "200" ]; then
    log "[OK] Connectivity test to Immich: SUCCESS"
else
    log "[FAIL] Connectivity test to Immich failed with status $status_code"
    errors=$((errors+1))
fi

if [ $errors -eq 0 ]; then
    echo "SYSTEM READY"
    log "SYSTEM READY"
    exit 0
else
    echo "SYSTEM NOT READY"
    log "SYSTEM NOT READY ($errors errors found)"
    exit 1
fi
