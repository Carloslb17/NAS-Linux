#!/bin/bash
LOG_FILE="logs/tests.log"
mkdir -p logs
touch "$LOG_FILE"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] API_TEST: $1" | tee -a "$LOG_FILE"; }

errors=0
log "Starting API Tests"

check_api() {
    name=$1
    url=$2
    log "Testing API endpoint for $name: $url"
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --retry 3 --retry-delay 2 --retry-connrefused "$url" || echo "failed")
    if [ "$status_code" == "200" ] || [ "$status_code" == "401" ] || [ "$status_code" == "403" ] || [ "$status_code" == "404" ]; then
        log "[OK] $name API responded (status $status_code)"
    else
        log "[FAIL] $name API failure, status: $status_code"
        errors=$((errors+1))
    fi
}

check_api "Nextcloud" "http://localhost:8080/status.php"
check_api "Grafana" "http://localhost:3000/api/health"
check_api "Prometheus" "http://localhost:9090/-/healthy"

if [ $errors -ne 0 ]; then
    log "API tests FAILED"
    exit 1
fi
log "API tests PASSED"
exit 0
