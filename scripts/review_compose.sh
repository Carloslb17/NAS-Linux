#!/bin/bash
set -e

mkdir -p logs
LOG_FILE="logs/compose_validation.log"
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] COMPOSE_REVIEW: $1" | tee -a "$LOG_FILE"; }

log "Starting Docker Compose validation..."

COMPOSE_FILES=$(find ./docker -name "docker-compose.yml")

for file in $COMPOSE_FILES; do
    log "Validating $file..."
    if docker-compose -f "$file" config >/dev/null 2>&1; then
        log "[OK] Syntax valid for $file"
    else
        log "[FAIL] Invalid syntax in $file."
    fi
    
    if grep -q "restart: always" "$file"; then
        log "[OK] Restart policy 'always' found."
    else
        log "[WARNING] Missing 'restart: always' in some services in $file."
    fi
done

log "Docker Compose validation completed."
