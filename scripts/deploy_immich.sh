#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IMMICH_DIR="$PROJECT_ROOT/docker/immich"

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
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] DEPLOY_IMMICH: $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log_output "ERROR: $1"
    exit 1
}

IMMICH_UPLOAD_LOCATION=${UPLOAD_LOCATION:-/srv/nas/photos}
IMMICH_DB_USERNAME=${DB_USERNAME:-immich}
IMMICH_DB_PASSWORD=${DB_PASSWORD:-immich_password}
IMMICH_DB_DATABASE_NAME=${DB_DATABASE_NAME:-immich}
IMMICH_VERSION=${IMMICH_VERSION:-release}

log_output "Preparing Immich deployment..."
sudo mkdir -p "$IMMICH_UPLOAD_LOCATION"
sudo chmod 775 "$IMMICH_UPLOAD_LOCATION" || true

log_output "Setting up Immich upload directories..."
sudo mkdir -p /srv/nas/photos/admin /srv/nas/photos/pareja
sudo chown -R admin:admin /srv/nas/photos/admin 2>/dev/null || true
sudo chown -R pareja:pareja /srv/nas/photos/pareja 2>/dev/null || true
sudo chmod -R 775 /srv/nas/photos || true

# Verify immich compose file exists
[ -f "$IMMICH_DIR/docker-compose.yml" ] || error_exit "docker-compose.yml not found at $IMMICH_DIR/docker-compose.yml"

log_output "Generating Docker Compose environment file..."
cat > "$IMMICH_DIR/.env" <<EOF
UPLOAD_LOCATION=$IMMICH_UPLOAD_LOCATION
DB_USERNAME=$IMMICH_DB_USERNAME
DB_PASSWORD=$IMMICH_DB_PASSWORD
DB_DATABASE_NAME=$IMMICH_DB_DATABASE_NAME
IMMICH_VERSION=$IMMICH_VERSION
EOF

log_output "Deploying Immich via Docker Compose..."
if ! retry 5 30 bash -c "cd '$IMMICH_DIR' && sudo docker compose up -d"; then
    error_exit "Failed to deploy Immich after 5 retries. Check network connectivity and Docker registry availability."
fi

log_output "Checking Immich containers..."
sudo docker ps | grep immich || true

log_output "Immich deployed successfully on port 2283."
