#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up users..."

echo "Ensuring admin and pareja users exist..."
for u in "admin" "pareja"; do
    if ! id "$u" &>/dev/null; then
        sudo useradd -m -s /bin/bash "$u"
        log_output "User $u created."
    else
        log_output "User $u already exists."
    fi
    
    USER_DIR="$NAS_PATH/users/$u"
    if [ ! -d "$USER_DIR" ]; then
        sudo mkdir -p "$USER_DIR"
        sudo chown -R "$u:$u" "$USER_DIR"
        sudo chmod -R 700 "$USER_DIR"
        log_output "Created data folder for $u at $USER_DIR."
    fi
done
