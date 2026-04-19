#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up Tailscale..."

if ! command -v tailscale &> /dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo systemctl enable tailscaled
    sudo systemctl start tailscaled
    log_output "Tailscale installed. Please run 'sudo tailscale up' manually to authenticate."
else
    log_output "Tailscale already installed."
fi
