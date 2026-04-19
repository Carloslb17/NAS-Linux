#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up Samba..."

if ! command -v smbd &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y samba
    log_output "Samba installed."
else
    log_output "Samba is already installed."
fi

SMB_CONF="/etc/samba/smb.conf"

if ! grep -q "\[NAS\]" "$SMB_CONF"; then
    log_output "Configuring Samba share [NAS]..."
    sudo bash -c "cat >> $SMB_CONF" << EOL

[NAS]
path = $NAS_PATH
browseable = yes
writable = yes
create mask = 0775
directory mask = 0775
EOL
    sudo systemctl restart smbd
    log_output "Samba restarted."
else
    log_output "Samba share [NAS] is already configured."
fi
