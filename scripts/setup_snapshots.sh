#!/bin/bash
set -e
source "$(dirname "$0")/../config.env"

log_output() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output "Setting up snapshot system..."

SNAPSHOT_SCRIPT="/usr/local/bin/nas-snapshot.sh"

sudo bash -c "cat > $SNAPSHOT_SCRIPT" << 'EOL'
#!/bin/bash
SOURCE="/srv/nas/users"
DEST="/srv/nas/snapshots"
DATE=$(date +%Y-%m-%d)
LATEST_LINK="$DEST/latest"

rsync -av --delete --link-dest="$LATEST_LINK" "$SOURCE/" "$DEST/snap-$DATE/"
rm -f "$LATEST_LINK"
ln -s "$DEST/snap-$DATE" "$LATEST_LINK"

# Keep last 7 days
find "$DEST" -maxdepth 1 -type d -name "snap-*" -mtime +7 -exec rm -rf {} +
EOL

sudo chmod +x $SNAPSHOT_SCRIPT

CRON_FILE="/etc/cron.d/nas_snapshots"
if [ ! -f "$CRON_FILE" ]; then
    echo "0 1 * * * root $SNAPSHOT_SCRIPT" | sudo tee "$CRON_FILE" > /dev/null
    sudo chmod 644 "$CRON_FILE"
    log_output "Snapshot cron job created."
else
    log_output "Snapshot cron job already exists."
fi
