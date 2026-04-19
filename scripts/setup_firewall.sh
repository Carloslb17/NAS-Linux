#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up Firewall (UFW)..."

if ! command -v ufw &> /dev/null; then
    sudo apt-get install -y ufw
fi

sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow samba
sudo ufw allow "$NEXTCLOUD_PORT"
sudo ufw allow "$JELLYFIN_PORT"
sudo ufw allow "$PROMETHEUS_PORT"
sudo ufw allow "$GRAFANA_PORT"
sudo ufw allow 9000    # Portainer
sudo ufw allow 9100    # Node Exporter
sudo ufw allow in on tailscale0 || true

log_output "Firewall configured."
