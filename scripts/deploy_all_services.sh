#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"
IMMICH_DIR="$DOCKER_DIR/immich"
LOG_FILE="$PROJECT_ROOT/logs/service_deployment.log"

mkdir -p "$PROJECT_ROOT/logs"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

retry() {
    local retries=${1:-3}
    local delay=${2:-10}
    shift 2
    local count=0
    until "$@"; do
        local status=$?
        count=$((count + 1))
        if [ "$count" -ge "$retries" ]; then
            log "Failed after $retries attempts"
            return $status
        fi
        log "Retry $count/$retries (waiting ${delay}s)..."
        sleep "$delay"
    done
}

log "=========================================="
log "Docker Services Deployment & Validation"
log "=========================================="

# Pre-flight checks
log "Running pre-flight checks..."

if ! sudo systemctl is-active --quiet docker; then
    log "Starting Docker daemon..."
    sudo systemctl start docker || error_exit "Failed to start Docker"
    sleep 5
fi
log "[OK] Docker daemon is running"

# Verify Docker can pull images
log "Testing Docker registry connectivity..."
if ! retry 3 5 sudo docker pull alpine:latest >/dev/null 2>&1; then
    error_exit "Cannot pull images from Docker registry. Check network connectivity."
fi
sudo docker rmi alpine:latest >/dev/null 2>&1
log "[OK] Docker registry connectivity verified"

# Check disk space
AVAIL=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
if [ "$AVAIL" -lt 5242880 ]; then
    error_exit "Insufficient disk space (need 5GB, have $(($AVAIL/1048576))GB)"
fi
log "[OK] Sufficient disk space available"

log ""
log "=========================================="
log "Deploying Main Docker Services"
log "=========================================="

cd "$DOCKER_DIR"
log "Current directory: $(pwd)"

# Check .env file
if [ ! -f ".env" ]; then
    error_exit ".env file not found at $DOCKER_DIR/.env"
fi
log "[OK] .env file found"

# Deploy services
log "Starting all services (this may take several minutes)..."
if ! retry 5 30 sudo docker compose up -d; then
    log "[FAIL] Docker compose up failed"
    sudo docker compose logs --tail=50
    error_exit "Failed to deploy services"
fi

log "[OK] Docker compose up completed"
sleep 10

log ""
log "=========================================="
log "Service Status Check"
log "=========================================="

EXPECTED_SERVICES=("portainer" "nextcloud" "jellyfin" "prometheus" "grafana" "node-exporter")
FAILED_SERVICES=()

for service in "${EXPECTED_SERVICES[@]}"; do
    if sudo docker ps --filter "name=$service" --format "{{.Names}}" | grep -q "$service"; then
        STATUS=$(sudo docker ps --filter "name=$service" --format "{{.Status}}")
        log "[OK] $service: $STATUS"
    else
        log "[FAIL] $service: NOT RUNNING"
        FAILED_SERVICES+=("$service")
    fi
done

log ""
log "=========================================="
log "Deploying Immich Services"
log "=========================================="

cd "$IMMICH_DIR"
log "Current directory: $(pwd)"

if [ ! -f ".env" ]; then
    error_exit ".env file not found at $IMMICH_DIR/.env"
fi

log "Starting Immich services..."
if ! retry 5 30 sudo docker compose up -d; then
    log "[FAIL] Immich docker compose up failed"
    sudo docker compose logs --tail=50
    error_exit "Failed to deploy Immich"
fi

log "[OK] Immich docker compose up completed"
sleep 15

IMMICH_SERVICES=("immich_server" "immich_machine_learning" "immich_postgres" "immich_redis")
for service in "${IMMICH_SERVICES[@]}"; do
    if sudo docker ps --filter "name=$service" --format "{{.Names}}" | grep -q "$service"; then
        STATUS=$(sudo docker ps --filter "name=$service" --format "{{.Status}}")
        log "[OK] $service: $STATUS"
    else
        log "[FAIL] $service: NOT RUNNING"
        FAILED_SERVICES+=("$service")
    fi
done

log ""
log "=========================================="
log "Port Availability Check"
log "=========================================="

PORTS=(
    "8080:nextcloud"
    "8096:jellyfin"
    "9000:portainer"
    "9090:prometheus"
    "3000:grafana"
    "9100:node-exporter"
    "2283:immich"
)

for port_service in "${PORTS[@]}"; do
    PORT=${port_service%:*}
    SERVICE=${port_service#*:}
    if sudo ss -tuln | grep -q ":$PORT"; then
        log "[OK] Port $PORT ($SERVICE) listening"
    else
        log "[WARN] Port $PORT ($SERVICE) NOT listening"
    fi
done

log ""
log "=========================================="
log "Service Health Checks"
log "=========================================="

# Portainer
if curl -sf http://localhost:9000 >/dev/null 2>&1; then
    log "[OK] Portainer health check: PASS"
else
    log "[FAIL] Portainer health check: FAIL"
    FAILED_SERVICES+=("portainer-health")
fi

# Nextcloud
if curl -sf http://localhost:8080 >/dev/null 2>&1; then
    log "[OK] Nextcloud health check: PASS"
else
    log "[FAIL] Nextcloud health check: FAIL"
    FAILED_SERVICES+=("nextcloud-health")
fi

# Grafana
if curl -sf http://localhost:3000 >/dev/null 2>&1; then
    log "[OK] Grafana health check: PASS"
else
    log "[FAIL] Grafana health check: FAIL"
    FAILED_SERVICES+=("grafana-health")
fi

# Immich
if curl -sf http://localhost:2283/api/server-info >/dev/null 2>&1; then
    log "[OK] Immich health check: PASS"
else
    log "[FAIL] Immich health check: FAIL"
    FAILED_SERVICES+=("immich-health")
fi

log ""
log "=========================================="
log "All Containers Status"
log "=========================================="

sudo docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | tee -a "$LOG_FILE"

log ""
log "=========================================="

if [ ${#FAILED_SERVICES[@]} -eq 0 ]; then
    log "✓ ALL SERVICES DEPLOYED AND HEALTHY"
    exit 0
else
    log "✗ SOME SERVICES FAILED:"
    printf '%s\n' "${FAILED_SERVICES[@]}" | tee -a "$LOG_FILE"
    log ""
    log "Failed services: ${#FAILED_SERVICES[@]}"
    exit 1
fi
