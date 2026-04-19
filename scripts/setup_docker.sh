#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up Docker..."

if ! command -v docker &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -y -o /etc/apt/keyrings/docker.gpg || true
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
    log_output "Docker installed."
else
    log_output "Docker is already installed."
fi

sudo usermod -aG docker "$USER" || true
sudo systemctl enable docker
sudo systemctl start docker

cd "$(dirname "$0")/../docker"
sudo docker-compose up -d portainer watchtower
log_output "Base Docker services deployed."
