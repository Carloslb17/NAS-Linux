#!/bin/bash
set -e

mkdir -p logs
LOG_FILE="logs/deployment.log"
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] DEPLOY_IMMICH: $1" | tee -a "$LOG_FILE"; }

log "Setting up Immich directories..."
sudo mkdir -p /srv/nas/photos/admin
sudo mkdir -p /srv/nas/photos/pareja

log "Setting ownership and permissions..."
sudo chown -R admin:admin /srv/nas/photos/admin 2>/dev/null || true
sudo chown -R pareja:pareja /srv/nas/photos/pareja 2>/dev/null || true
sudo chmod -R 775 /srv/nas/photos

cd "$(dirname "$0")/../docker/immich"

log "Deploying Immich via Docker Compose..."
sudo docker-compose up -d

log "Checking Immich containers..."
sudo docker ps | grep immich || true

log "Immich deployed successfully on port 2283."
