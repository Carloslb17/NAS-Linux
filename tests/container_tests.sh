#!/bin/bash
LOG_FILE="logs/tests.log"
mkdir -p logs
touch "$LOG_FILE"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] CONTAINER_TEST: $1" | tee -a "$LOG_FILE"; }

errors=0
log "Starting Container Tests"

containers=("nextcloud" "jellyfin" "grafana" "prometheus" "portainer" "immich_server")

for c in "${containers[@]}"; do
    if docker ps --format '{{.Names}}' | grep -Eq "^${c}$"; then
        log "[OK] Container $c is running"
        
        RESTART_POLICY=$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' "$c" 2>/dev/null || echo "none")
        if [ "$RESTART_POLICY" != "none" ] && [ "$RESTART_POLICY" != "" ]; then
            log "[OK] Container $c restart policy is $RESTART_POLICY"
        else
            log "[FAIL] Container $c has no restart policy"
            errors=$((errors+1))
        fi

        HEALTH=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$c" 2>/dev/null || echo "none")
        if [ "$HEALTH" == "unhealthy" ]; then
            log "[FAIL] Container $c is unhealthy"
            errors=$((errors+1))
        fi
    else
        log "[FAIL] Container $c is NOT running"
        errors=$((errors+1))
    fi
done

if [ $errors -ne 0 ]; then
    log "Container tests FAILED"
    exit 1
fi
log "Container tests PASSED"
exit 0
