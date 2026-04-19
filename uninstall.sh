#!/bin/bash
set -e
cd "$(dirname "$0")"
source config.env

echo "Starting homelab-nas-pro uninstallation..."

if [ -x "$(command -v docker)" ]; then
    cd docker
    sudo docker compose down || true
    cd ..
fi

sudo systemctl stop smbd || true
sudo sed -i '/\[NAS\]/,+6d' /etc/samba/smb.conf || true
sudo systemctl restart smbd || true

sudo ufw reset -f || true

if [ -d "$NAS_PATH" ]; then
    sudo rm -rf "$NAS_PATH"
fi

rm -rf logs/*

echo "Uninstallation completed!"
