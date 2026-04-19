#!/bin/bash
set -e

mkdir -p logs
LOG_FILE="logs/firewall.log"
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] FIREWALL: $1" | tee -a "$LOG_FILE"; }

log "Configuring Tailscale-only UFW isolation..."

if ! command -v ufw &> /dev/null; then
    sudo apt-get install -y ufw
fi

log "Setting default rules..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

log "Allowing traffic specifically on tailscale0 interface..."
sudo ufw allow in on tailscale0

log "Enabling firewall..."
sudo ufw --force enable

log "Reloading rules..."
sudo ufw reload

log "Firewall status:"
sudo ufw status verbose | tee -a "$LOG_FILE"

log "Firewall configuration completed successfully."
