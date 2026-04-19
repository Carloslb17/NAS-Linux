# HomeLab NAS Pro - Current Status

## Overview
This repository provides an automated setup for a complete HomeLab NAS server on Ubuntu Linux. The system transforms your machine into a full-featured personal cloud and media server with file sharing, backups, monitoring, and remote access.

## What We Have Now ✅

### Core Infrastructure (Fully Operational)
- **Storage Setup**: All NAS directories created and properly configured
  - `/srv/nas` - Main NAS root
  - `/srv/nas/users` - User home directories
  - `/srv/nas/backups` - Backup storage
  - `/srv/nas/media` - Media files
  - `/srv/nas/snapshots` - Rolling snapshots
- **User Management**: System users created with proper permissions
  - `admin` - Administrative user
  - `pareja` - Additional user
- **File Sharing (Samba)**: Network file sharing active
  - Share: `\\<server_ip>\NAS`
  - Accessible from Windows/Linux/Mac
- **Docker Engine**: Container runtime installed and running
- **Remote Access (Tailscale)**: VPN service configured for secure external access

### Docker Services (Partially Deployed)
- **Portainer**: Container management UI running
  - Access: `http://<server_ip>:9000`
  - Status: ✅ Operational
- **Watchtower**: Automatic container updates
  - Status: ⚠️ Restarting (non-critical issue)

### System Health
- **Disk Space**: 122GB available
- **Services Status**:
  - Samba: ✅ Running
  - Docker: ✅ Running
  - Tailscale: ✅ Running
- **Network**: Server IP `10.225.214.205`

## What's Not Yet Complete ❌

### Application Services (Failed Due to Network Issues)
- **Nextcloud**: Personal cloud storage
  - Planned: `http://<server_ip>:8080`
  - Status: ❌ Image pull failed (TLS timeout)
- **Jellyfin**: Media streaming server
  - Planned: `http://<server_ip>:8096`
  - Status: ❌ Image pull failed (TLS timeout)
- **Monitoring Stack**:
  - Prometheus: Metrics collection
  - Grafana: Dashboards (`http://<server_ip>:3000`)
  - Alertmanager: Notifications
  - Status: ❌ Images not pulled
- **Backups & Snapshots**: Automated backup system
  - Status: ❌ Scripts not executed
- **Firewall**: UFW configuration
  - Status: ❌ Not applied

## How to Check Status

### Quick Health Check
```bash
./scripts/health_check.sh
```

### Docker Containers
```bash
sudo docker ps -a
```

### System Services
```bash
sudo systemctl status samba
sudo systemctl status docker
sudo systemctl status tailscaled
```

### Logs
- Installation: `logs/install.log`
- Docker logs: `sudo docker logs <container_name>`

## Current Access Points

| Service | URL/Address | Status |
|---------|-------------|--------|
| Samba Share | `\\10.225.214.205\NAS` | ✅ Working |
| Portainer | `http://10.225.214.205:9000` | ✅ Working |
| Nextcloud | `http://10.225.214.205:8080` | ❌ Not deployed |
| Jellyfin | `http://10.225.214.205:8096` | ❌ Not deployed |
| Grafana | `http://10.225.214.205:3000` | ❌ Not deployed |

## Issues Encountered & Resolved

### Fixed During Setup
1. **Docker GPG Key Error**: Removed invalid `-y` flag from gpg command
2. **Docker Compose Compatibility**: Updated scripts to use `docker compose` instead of `docker-compose` for Ubuntu 24.04/Python 3.12
3. **Log File Issues**: Ensured proper log file creation

### Remaining Issues
1. **Network Timeouts**: Docker image pulls failing due to TLS handshake timeouts
   - Cause: Unstable/slow internet connection
   - Impact: Application containers not deployed
   - Solution: Retry when network is stable

## Next Steps

### Immediate (When Network Improves)
```bash
./scripts/setup_nextcloud.sh
./scripts/setup_jellyfin.sh
./scripts/setup_monitoring.sh
./scripts/setup_backups.sh
./scripts/setup_snapshots.sh
./scripts/setup_firewall.sh
./scripts/health_check.sh
```

### Manual Docker Deployment
If scripts continue failing, deploy manually:
```bash
cd docker
sudo docker compose pull <service_name>
sudo docker compose up -d <service_name>
```

## Architecture Overview

```
[Remote Users] ---- (Tailscale VPN) ----> [HomeLab NAS]
                                            |
                                            +-- Samba (File Sharing)
                                            +-- Portainer (Management)
                                            +-- Nextcloud (Cloud Storage)
                                            +-- Jellyfin (Media)
                                            +-- Monitoring Stack
                                            +-- Backups & Snapshots
```

## Security Notes
- Services are containerized for isolation
- Tailscale provides VPN-based remote access
- UFW firewall configured (when deployed)
- User permissions properly set

## Educational Value
This setup demonstrates:
- Linux system administration
- Docker container orchestration
- Network configuration
- Backup strategies
- Monitoring and alerting
- Self-hosted service deployment

## Contact/Support
For issues or questions, check the logs and retry failed components. The core NAS functionality is working for file sharing and Docker management.