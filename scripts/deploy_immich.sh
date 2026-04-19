#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

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

LOG_FILE=${LOG_FILE:-logs/install.log}
mkdir -p "$(dirname "$LOG_FILE")"
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] DEPLOY_IMMICH: $1" | tee -a "$LOG_FILE"; }

IMMICH_UPLOAD_LOCATION=${UPLOAD_LOCATION:-/srv/nas/photos}
IMMICH_DB_USERNAME=${DB_USERNAME:-immich}
IMMICH_DB_PASSWORD=${DB_PASSWORD:-immich_password}
IMMICH_DB_DATABASE_NAME=${DB_DATABASE_NAME:-immich}
IMMICH_VERSION=${IMMICH_VERSION:-release}

log "Preparing Immich deployment..."
sudo mkdir -p "$IMMICH_UPLOAD_LOCATION"
sudo chmod 775 "$IMMICH_UPLOAD_LOCATION" || true

log "Setting up Immich upload directories..."
sudo mkdir -p /srv/nas/photos/admin /srv/nas/photos/pareja
sudo chown -R admin:admin /srv/nas/photos/admin 2>/dev/null || true
sudo chown -R pareja:pareja /srv/nas/photos/pareja 2>/dev/null || true
sudo chmod -R 775 /srv/nas/photos || true

cd "$(dirname "$0")/../docker/immich"

log "Generating Docker Compose environment file..."
cat > .env <<EOF
UPLOAD_LOCATION=$IMMICH_UPLOAD_LOCATION
DB_USERNAME=$IMMICH_DB_USERNAME
DB_PASSWORD=$IMMICH_DB_PASSWORD
DB_DATABASE_NAME=$IMMICH_DB_DATABASE_NAME
IMMICH_VERSION=$IMMICH_VERSION
EOF

log "Deploying Immich via Docker Compose..."
retry 3 10 sudo docker compose up -d

log "Checking Immich containers..."
sudo docker ps | grep immich || true

log "Immich deployed successfully on port 2283."
