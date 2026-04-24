#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/docker_diagnostic.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Docker Diagnostic Report ==="
log "Host: $(hostname)"
log "Kernel: $(uname -r)"
log "Docker version: $(sudo docker --version)"
log ""

log "=== Network Connectivity Check ==="
ping -c 2 8.8.8.8 >/dev/null 2>&1 && log "[OK] Internet connectivity: PASS" || log "[FAIL] Internet connectivity: FAIL"
curl -s -I https://hub.docker.com >/dev/null 2>&1 && log "[OK] Docker Hub reachable" || log "[FAIL] Docker Hub unreachable"
log ""

log "=== Docker Daemon Status ==="
sudo systemctl is-active --quiet docker && log "[OK] Docker daemon running" || log "[FAIL] Docker daemon NOT running"
log ""

log "=== Docker Network Check ==="
sudo docker network ls || log "[FAIL] Cannot list networks"
log ""

log "=== Running Containers ==="
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || log "[FAIL] Cannot list containers"
log ""

log "=== Stopped/Exited Containers ==="
sudo docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" || log "[FAIL] Cannot list exited containers"
log ""

log "=== Disk Space ==="
df -h | grep -E "Filesystem|/$" || true
log ""

log "=== Docker Disk Usage ==="
sudo docker system df || log "[FAIL] Cannot get Docker disk usage"
log ""

log "=== Recent Docker Logs ==="
sudo journalctl -u docker --since "1 hour ago" -n 20 || log "[FAIL] Cannot get Docker logs"
log ""

log "=== Image Pull Test ==="
if sudo docker pull alpine:latest 2>&1; then
    log "[OK] Successfully pulled test image (alpine:latest)"
    sudo docker rmi alpine:latest
else
    log "[FAIL] Failed to pull test image. Docker registry connectivity issue."
fi
log ""

log "Diagnostic complete. Check $LOG_FILE for details."
