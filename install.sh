#!/bin/bash
set -e
cd "$(dirname "$0")"

source config.env

mkdir -p logs
touch "$LOG_FILE"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting homelab-nas-pro installation..."

if [ "$EUID" -eq 0 ]; then
    log "Please do not run directly as root. Run as a non-root user with sudo privileges."
    exit 1
fi

chmod +x scripts/*.sh

scripts=(
    "setup_storage"
    "setup_users"
    "setup_samba"
    "setup_docker"
    "setup_nextcloud"
    "setup_jellyfin"
    "setup_tailscale"
    "deploy_immich"
    "setup_snapshots"
    "setup_backups"
    "setup_monitoring"
    "setup_alerting"
    "setup_firewall"
    "health_check"
)

for script in "${scripts[@]}"; do
    log "Executing $script..."
    if ! output=$(./scripts/${script}.sh 2>&1); then
        log "Error executing $script. Stopping installation."
        log "Error output: $output"
        exit 1
    fi
    log "$script completed successfully."
done

log "Installation completed."
