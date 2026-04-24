#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/test_suite.log"

mkdir -p "$PROJECT_ROOT/logs"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ❌ ERROR: $1" | tee -a "$LOG_FILE"
}

success() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1" | tee -a "$LOG_FILE"
}

warning() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️  WARNING: $1" | tee -a "$LOG_FILE"
}

log "=========================================="
log "📊 HomeLab NAS Pro - Complete Test Suite"
log "=========================================="
log ""

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNING=0

# Test 1: System Requirements
log "TEST 1: System Requirements"
log "---"

# Check Ubuntu version
if grep -q "22.04\|24.04" /etc/os-release; then
    success "Ubuntu version: OK"
    ((TESTS_PASSED++))
else
    warning "Ubuntu version: May not be fully tested"
    ((TESTS_WARNING++))
fi

# Check available disk space
DISK_AVAIL=$(df /srv/nas 2>/dev/null | awk 'NR==2 {print $4}')
if [ "$DISK_AVAIL" -gt 10485760 ]; then  # 10GB
    success "Disk space: OK ($(($DISK_AVAIL/1048576))GB available)"
    ((TESTS_PASSED++))
else
    error "Disk space: CRITICAL (only $(($DISK_AVAIL/1048576))GB available)"
    ((TESTS_FAILED++))
fi

# Check memory
MEMORY_MB=$(free -m | awk 'NR==2 {print $2}')
if [ "$MEMORY_MB" -ge 4096 ]; then
    success "Memory: OK (${MEMORY_MB}MB)"
    ((TESTS_PASSED++))
else
    warning "Memory: Only ${MEMORY_MB}MB (4GB recommended)"
    ((TESTS_WARNING++))
fi

log ""
log "TEST 2: Docker & Services"
log "---"

# Check Docker daemon
if sudo systemctl is-active --quiet docker; then
    success "Docker daemon: Running"
    ((TESTS_PASSED++))
else
    error "Docker daemon: NOT running"
    ((TESTS_FAILED++))
    exit 1
fi

# Check container count
CONTAINER_COUNT=$(sudo docker ps --format "{{.Names}}" | wc -l)
if [ "$CONTAINER_COUNT" -ge 10 ]; then
    success "Docker containers: $CONTAINER_COUNT running"
    ((TESTS_PASSED++))
else
    error "Docker containers: Only $CONTAINER_COUNT (expected 11)"
    ((TESTS_FAILED++))
fi

# Check each service
SERVICES=("immich_server" "immich_postgres" "immich_redis" "nextcloud" "jellyfin" "portainer" "prometheus" "grafana")

for service in "${SERVICES[@]}"; do
    if sudo docker ps --filter "name=$service" --format "{{.Names}}" | grep -q "$service"; then
        success "Service: $service ✓"
        ((TESTS_PASSED++))
    else
        error "Service: $service NOT running"
        ((TESTS_FAILED++))
    fi
done

log ""
log "TEST 3: Port Accessibility"
log "---"

PORTS=(
    "2283:Immich"
    "8080:Nextcloud"
    "8096:Jellyfin"
    "9000:Portainer"
    "9090:Prometheus"
    "3000:Grafana"
    "9100:Node-Exporter"
)

for port_service in "${PORTS[@]}"; do
    PORT=${port_service%:*}
    SERVICE=${port_service#*:}
    
    if sudo ss -tuln | grep -q ":$PORT"; then
        success "Port $PORT ($SERVICE): Listening"
        ((TESTS_PASSED++))
    else
        error "Port $PORT ($SERVICE): NOT listening"
        ((TESTS_FAILED++))
    fi
done

log ""
log "TEST 4: API Connectivity"
log "---"

# Immich API
if curl -sf http://localhost:2283/api/server-info >/dev/null 2>&1; then
    success "Immich API: Responding"
    ((TESTS_PASSED++))
else
    warning "Immich API: Not responding (may still be starting)"
    ((TESTS_WARNING++))
fi

# Nextcloud
if curl -sf http://localhost:8080 >/dev/null 2>&1; then
    success "Nextcloud: Responding"
    ((TESTS_PASSED++))
else
    warning "Nextcloud: Not responding (may still be starting)"
    ((TESTS_WARNING++))
fi

# Jellyfin
if curl -sf http://localhost:8096 >/dev/null 2>&1; then
    success "Jellyfin: Responding"
    ((TESTS_PASSED++))
else
    warning "Jellyfin: Not responding (may still be starting)"
    ((TESTS_WARNING++))
fi

# Portainer
if curl -sf http://localhost:9000 >/dev/null 2>&1; then
    success "Portainer: Responding"
    ((TESTS_PASSED++))
else
    warning "Portainer: Not responding"
    ((TESTS_WARNING++))
fi

# Prometheus
if curl -sf http://localhost:9090 >/dev/null 2>&1; then
    success "Prometheus: Responding"
    ((TESTS_PASSED++))
else
    warning "Prometheus: Not responding"
    ((TESTS_WARNING++))
fi

# Grafana
if curl -sf http://localhost:3000 >/dev/null 2>&1; then
    success "Grafana: Responding"
    ((TESTS_PASSED++))
else
    warning "Grafana: Not responding"
    ((TESTS_WARNING++))
fi

log ""
log "TEST 5: Storage & Filesystem"
log "---"

# Check storage directories
for dir in "/srv/nas" "/srv/nas/photos" "/srv/nas/media" "/srv/nas/backups"; do
    if [ -d "$dir" ]; then
        success "Directory: $dir exists"
        ((TESTS_PASSED++))
    else
        error "Directory: $dir MISSING"
        ((TESTS_FAILED++))
    fi
done

# Check docker volumes
if sudo docker volume ls | grep -q "immich_pgdata"; then
    success "Docker volumes: Immich database volume exists"
    ((TESTS_PASSED++))
else
    error "Docker volumes: Immich database volume MISSING"
    ((TESTS_FAILED++))
fi

log ""
log "TEST 6: Network & Connectivity"
log "---"

# Internet connectivity
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    success "Internet connectivity: OK"
    ((TESTS_PASSED++))
else
    error "Internet connectivity: FAILED"
    ((TESTS_FAILED++))
fi

# Docker network
if sudo docker network ls | grep -q "immich_default"; then
    success "Docker networks: Immich network exists"
    ((TESTS_PASSED++))
else
    error "Docker networks: Immich network MISSING"
    ((TESTS_FAILED++))
fi

log ""
log "TEST 7: Health Checks (Container Health Status)"
log "---"

HEALTHY_COUNT=$(sudo docker ps --filter "health=healthy" --format "{{.Names}}" | wc -l)
UNHEALTHY_COUNT=$(sudo docker ps --filter "health=unhealthy" --format "{{.Names}}" | wc -l)

if [ "$UNHEALTHY_COUNT" -eq 0 ]; then
    success "Container health: $HEALTHY_COUNT healthy, 0 unhealthy"
    ((TESTS_PASSED++))
else
    error "Container health: $UNHEALTHY_COUNT containers unhealthy"
    sudo docker ps --filter "health=unhealthy" --format "table {{.Names}}\t{{.Status}}"
    ((TESTS_FAILED++))
fi

log ""
log "TEST 8: Samba Share"
log "---"

if sudo systemctl is-active --quiet smbd; then
    success "Samba: Service running"
    ((TESTS_PASSED++))
else
    error "Samba: Service NOT running"
    ((TESTS_FAILED++))
fi

if sudo smbclient -L localhost -N 2>&1 | grep -q "NAS"; then
    success "Samba: NAS share configured"
    ((TESTS_PASSED++))
else
    warning "Samba: NAS share not accessible"
    ((TESTS_WARNING++))
fi

log ""
log "TEST 9: Firewall"
log "---"

if sudo ufw status | grep -q "active"; then
    success "Firewall: UFW active"
    ((TESTS_PASSED++))
else
    warning "Firewall: UFW not active"
    ((TESTS_WARNING++))
fi

log ""
log "TEST 10: Immich Specific"
log "---"

# Check Immich database
if sudo docker exec immich_postgres pg_isready -U immich 2>&1 | grep -q "accepting"; then
    success "Immich database: Ready"
    ((TESTS_PASSED++))
else
    error "Immich database: NOT ready"
    ((TESTS_FAILED++))
fi

# Check Immich Redis
if sudo docker exec immich_redis redis-cli ping 2>&1 | grep -q "PONG"; then
    success "Immich Redis: Responsive"
    ((TESTS_PASSED++))
else
    error "Immich Redis: NOT responsive"
    ((TESTS_FAILED++))
fi

# Check server API
if sudo docker exec immich_server curl -sf http://localhost:3001/api/server/about >/dev/null 2>&1; then
    success "Immich server API: Responsive"
    ((TESTS_PASSED++))
else
    warning "Immich server API: Not responding (may still be starting)"
    ((TESTS_WARNING++))
fi

# Check ML service
if sudo docker ps --filter "name=immich_machine_learning" --format "{{.Names}}" | grep -q "immich_machine_learning"; then
    success "Immich ML service: Running"
    ((TESTS_PASSED++))
else
    error "Immich ML service: NOT running"
    ((TESTS_FAILED++))
fi

log ""
log "=========================================="
log "📊 Test Summary"
log "=========================================="
log "✅ Passed:  $TESTS_PASSED"
log "❌ Failed:  $TESTS_FAILED"
log "⚠️  Warnings: $TESTS_WARNING"
log ""

if [ $TESTS_FAILED -eq 0 ]; then
    log "🎉 ALL CRITICAL TESTS PASSED"
    exit 0
else
    error "Some tests failed. Please review logs and troubleshoot."
    exit 1
fi
