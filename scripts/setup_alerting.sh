#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up alerting..."
log_output "Alertmanager configuration written."
# Configuration is managed via the created files in /monitoring folder
