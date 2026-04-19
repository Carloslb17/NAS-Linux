#!/bin/bash
LOG_FILE="logs/tests.log"
mkdir -p logs
touch "$LOG_FILE"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] IMMICH_TEST: $1" | tee -a "$LOG_FILE"; }

errors=0
log "Starting Immich Tests"

containers=(
  immich_server
  immich_machine_learning
  immich_postgres
  immich_redis
)

for c in "${containers[@]}"; do
  if docker ps --format '{{.Names}}' | grep -Eq "^${c}$"; then
    log "[OK] Immich container $c is running"
    restart_policy=$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' "$c" 2>/dev/null || echo "none")
    if [ "$restart_policy" != "none" ] && [ "$restart_policy" != "" ]; then
      log "[OK] Container $c restart policy is $restart_policy"
    else
      log "[FAIL] Container $c has no restart policy"
      errors=$((errors+1))
    fi
  else
    log "[FAIL] Immich container $c is NOT running"
    errors=$((errors+1))
  fi
done

if [ -d "/srv/nas/photos/admin" ] && [ -d "/srv/nas/photos/pareja" ]; then
  log "[OK] Immich upload directories exist"
else
  log "[FAIL] Immich upload directories are missing"
  errors=$((errors+1))
fi

status_code=$(curl -s -o /dev/null -w "%{http_code}" --retry 3 --retry-delay 2 --retry-connrefused "http://localhost:2283/api/server-info" || echo "failed")
if [ "$status_code" == "200" ] || [ "$status_code" == "401" ] || [ "$status_code" == "403" ]; then
  log "[OK] Immich API responded (status $status_code)"
else
  log "[FAIL] Immich API did not respond correctly: $status_code"
  errors=$((errors+1))
fi

if [ $errors -ne 0 ]; then
  log "Immich tests FAILED"
  exit 1
fi
log "Immich tests PASSED"
exit 0
