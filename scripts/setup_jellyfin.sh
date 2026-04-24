#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"

source "$PROJECT_ROOT/config.env"

retry() {
    local retries=${1:-3}
    local delay=${2:-5}
    shift 2
    local count=0
    until "$@"; do
        local status=$?
        count=$((count + 1))
        if [ "$count" -ge "$retries" ]; then
            return $status
        fi
        echo "Retry $count/$retries after failure (waiting ${delay}s): $*"
        sleep "$delay"
    done
}

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log_output "ERROR: $1"
    exit 1
}

log_output "Setting up Jellyfin..."

# Verify docker-compose.yml exists
[ -f "$DOCKER_DIR/docker-compose.yml" ] || error_exit "docker-compose.yml not found at $DOCKER_DIR/docker-compose.yml"

# Deploy Jellyfin with increased retries and longer delays for network timeouts
log_output "Deploying Jellyfin service..."
if ! retry 5 30 bash -c "cd '$DOCKER_DIR' && sudo docker compose up -d jellyfin"; then
    error_exit "Failed to deploy Jellyfin after 5 retries. Check network connectivity and Docker registry availability."
fi

log_output "Jellyfin deployed successfully."
