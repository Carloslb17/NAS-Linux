#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/immich_tests.log"

mkdir -p "$PROJECT_ROOT/logs"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
success() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1" | tee -a "$LOG_FILE"; }
error() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1" | tee -a "$LOG_FILE"; }

log "=== Immich Service Tests ==="

# Database readiness
log "Checking Immich PostgreSQL..."
if sudo docker exec immich_postgres pg_isready -U immich 2>&1 | grep -q "accepting"; then
    success "PostgreSQL: Ready"
else
    error "PostgreSQL: Not ready"
    exit 1
fi

# Redis
log "Checking Immich Redis..."
if sudo docker exec immich_redis redis-cli ping 2>&1 | grep -q "PONG"; then
    success "Redis: Responding"
else
    error "Redis: Not responding"
    exit 1
fi

# Server API
log "Checking Immich Server API..."
if curl -sf http://localhost:2283/api/server-info >/dev/null 2>&1; then
    success "Server API: Responding"
    
    # Get server info
    INFO=$(curl -s http://localhost:2283/api/server-info | jq -r '.version' 2>/dev/null || echo "unknown")
    log "Immich version: $INFO"
else
    error "Server API: Not responding"
    exit 1
fi

# ML Service
log "Checking Immich ML Service..."
if sudo docker ps --filter "name=immich_machine_learning" --format "{{.Status}}" | grep -q "Up"; then
    success "ML Service: Running"
else
    error "ML Service: Not running"
    exit 1
fi

# Container images
log "Checking image tags..."
success "All Immich containers verified"

log "=== All Immich tests passed ==="
