#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up Monitoring..."

cd "$(dirname "$0")/../docker"
sudo docker-compose up -d prometheus grafana node-exporter

log_output "Monitoring Stack Deployed."
