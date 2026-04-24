#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"

source "$PROJECT_ROOT/config.env"

retry() {
    local retries=${1:-3}
    local delay=${2:-10}
    shift 2
    local count=0
    until "$@"; do
        local status=$?
        count=$((count + 1))
        if [ "$count" -ge "$retries" ]; then
            return $status
        fi
        echo "Retry $count/$retries after failure: $*"
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

log_output "Setting up Docker..."

if ! command -v docker &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || true
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
    log_output "Docker installed."
else
    log_output "Docker is already installed."
fi

sudo usermod -aG docker "$USER" || true
sudo systemctl enable docker || true
sudo systemctl start docker || true

# Create .env file for docker-compose with proper paths
log_output "Configuring Docker Compose environment..."
cat > "$DOCKER_DIR/.env" << EOF
NAS_PATH=$NAS_PATH
MEDIA_PATH=$MEDIA_PATH
MONITORING_PATH=$PROJECT_ROOT/monitoring
TIMEZONE=$TIMEZONE
NEXTCLOUD_PORT=${NEXTCLOUD_PORT:-8080}
JELLYFIN_PORT=${JELLYFIN_PORT:-8096}
PROMETHEUS_PORT=${PROMETHEUS_PORT:-9090}
GRAFANA_PORT=${GRAFANA_PORT:-3000}
EOF

# Verify docker-compose.yml exists
[ -f "$DOCKER_DIR/docker-compose.yml" ] || error_exit "docker-compose.yml not found at $DOCKER_DIR/docker-compose.yml"

# Deploy base Docker services
log_output "Deploying base Docker services..."
if ! retry 3 10 bash -c "cd '$DOCKER_DIR' && sudo docker compose up -d portainer"; then
    error_exit "Failed to deploy Portainer service. Check Docker Compose configuration and disk space."
fi

log_output "Base Docker services deployed successfully."
