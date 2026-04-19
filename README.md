# HomeLab NAS Pro

A complete, production-ready, educational repository that deploys a fully functional HomeLab NAS server on Ubuntu Linux.

## Project Description
This project provides an automated, idempotent setup to build a home NAS infrastructure. Features include Sambashares, cloud storage via Nextcloud, media streaming via Jellyfin, automated backups and snapshots, and monitoring using Prometheus and Grafana. Remote access is secured behind a Tailscale VPN.

## Architecture Diagram
```text
[ Remote Users ] ---- (Tailscale VPN) ----> [ HomeLab NAS ]
                                                 |
                                                 +-- Nextcloud (Port 8080)
                                                 +-- Jellyfin  (Port 8096)
                                                 +-- Portainer (Port 9000)
                                                 +-- Monitoring Stack
```

## Installation
1. Ensure you have an Ubuntu system (22.04+) ready with a non-root sudoer user.
2. Clone the repository:
   ```bash
   git clone <repo_url>
   cd homelab-nas-pro
   ```
3. Execute the installer:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## Usage Guide
- Samba `\\<nas_ip>\NAS` is pre-configured.
- Access apps safely using local IPs, or join Tailscale to access remotely.
- Ensure you configure your monitoring defaults via the web UIs provided.

## Security Explanation
Services are restricted by UFW firewall, Tailscale is heavily recommended for external access without port-forwarding on your physical router. Docker is isolated.

## Backup Explanation
A daily cron task mirrors `/home` safely into the backups folder, while an independent snapshot system manages hard-link rotations of user files to prevent accidental deletion over a rolling 7-day period.

## Troubleshooting
- Run `./scripts/health_check.sh` anytime. 
- View `/logs/install.log`.
- Restart services via Docker Compose inside the `docker/` directory.

## Future Upgrades
- ZFS configuration for redundant disks (RAID).
- HTTPS setup.
- Automating config syncing.
