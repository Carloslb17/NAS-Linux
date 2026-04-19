#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"
cd "$(dirname "$0")/../docker"
sudo docker compose up -d jellyfin
