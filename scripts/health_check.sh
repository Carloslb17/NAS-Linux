#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

echo "==================================="
echo "System Status Summary"
echo "==================================="

for dir in "$NAS_PATH" "$BACKUP_PATH" "$MEDIA_PATH"; do
    if [ -d "$dir" ]; then
        echo "[OK] Directory exists: $dir"
    else
        echo "[FAIL] Missing directory: $dir"
    fi
done

if systemctl is-active --quiet smbd; then
    echo "[OK] Samba running"
else
    echo "[FAIL] Samba not running"
fi

if systemctl is-active --quiet docker; then
    echo "[OK] Docker running"
else
    echo "[FAIL] Docker not running"
fi

if command -v tailscale &>/dev/null && systemctl is-active --quiet tailscaled; then
    echo "[OK] Tailscale service running"
else
    echo "[FAIL] Tailscale service missing/stopped"
fi

echo ""
echo "Disk space available:"
df -h "$NAS_PATH" | awk 'NR==2 {print $4}'
echo "==================================="
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "Access Links:"
echo "Nextcloud: http://$IP_ADDR:$NEXTCLOUD_PORT"
echo "Jellyfin:  http://$IP_ADDR:$JELLYFIN_PORT"
echo "Grafana:   http://$IP_ADDR:$GRAFANA_PORT"
echo "Portainer: http://$IP_ADDR:9000"
echo "Samba:     \\\\$IP_ADDR\\NAS"
echo "==================================="
