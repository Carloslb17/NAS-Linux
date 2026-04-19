#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up backup system..."

if ! command -v rsync &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y rsync
fi

BACKUP_SCRIPT="/usr/local/bin/nas-backup.sh"

sudo bash -c "cat > $BACKUP_SCRIPT" << EOL
#!/bin/bash
rsync -av --delete /home/ $BACKUP_PATH/
EOL

sudo chmod +x $BACKUP_SCRIPT

CRON_FILE="/etc/cron.d/nas_backup"
if [ ! -f "$CRON_FILE" ]; then
    echo "0 2 * * * root $BACKUP_SCRIPT" | sudo tee "$CRON_FILE" > /dev/null
    sudo chmod 644 "$CRON_FILE"
    log_output "Backup cron job created."
else
    log_output "Backup cron job already exists."
fi
