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

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up Monitoring..."

cd "$(dirname "$0")/../docker"
retry 3 15 sudo docker compose up -d prometheus grafana node-exporter

log_output "Monitoring Stack Deployed."
