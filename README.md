# 🏠 HomeLab NAS Pro - Complete Home Server Infrastructure

A production-ready, fully automated, and educational repository that deploys a complete home NAS server on Ubuntu Linux with Docker containerization, photo backup (Immich), file storage (Nextcloud), media streaming (Jellyfin), and comprehensive monitoring.

**Status**: ✅ All core services operational and tested.

---

## 📋 Table of Contents

1. [Features](#features)
2. [System Requirements](#system-requirements)
3. [Quick Start](#quick-start)
4. [Architecture](#architecture)
5. [Installation Guide](#installation-guide)
6. [Service Documentation](#service-documentation)
7. [Immich Mobile Setup](#immich-mobile-setup)
8. [Accessing Services](#accessing-services)
9. [Monitoring & Administration](#monitoring--administration)
10. [Backup & Recovery](#backup--recovery)
11. [Troubleshooting](#troubleshooting)
12. [Security](#security)
13. [Testing](#testing)
14. [Next Phases](#next-phases)

---

## ✨ Features

### Core Services
- **Immich** - Self-hosted photo backup & gallery (similar to Google Photos)
- **Nextcloud** - Self-hosted file storage & sync (Dropbox alternative)
- **Jellyfin** - Self-hosted media streaming (Plex alternative)
- **Samba/SMB** - Native network file shares for Windows/Mac/Linux
- **Portainer** - Docker container management UI
- **Prometheus + Grafana** - Complete system monitoring & alerting
- **Tailscale VPN** - Secure remote access without port-forwarding

### Infrastructure
- ✅ Automated installation (idempotent, re-run safely)
- ✅ Docker containerization (11 services)
- ✅ Automated daily backups
- ✅ Rolling 7-day snapshots (hard-link based)
- ✅ UFW firewall pre-configured
- ✅ Comprehensive health checks & diagnostics
- ✅ Full test suite included

---

## 🖥️ System Requirements

### Minimum Hardware
- **CPU**: Dual-core processor (quad-core recommended)
- **RAM**: 4GB (8GB recommended, especially with Immich ML)
- **Storage**: 
  - 50GB for system + services
  - Dedicated partition for photos/media (100GB+ recommended)
  - Dedicated partition for backups (50% of data size minimum)

### Software Requirements
- **OS**: Ubuntu 22.04 LTS or newer
- **User**: Non-root user with sudo privileges
- **Network**: Stable internet for initial setup

### Network
- Static IP recommended (or DHCP reservation)
- Router with UPnP (optional, for remote access)
- Tailscale account (free tier available)

---

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone <repo_url>
cd NAS-Linux

# 2. Configure environment
cp config.env config.env  
nano config.env  # Edit as needed

# 3. Run installer
chmod +x install.sh
./install.sh

# 4. Wait 10-20 minutes for completion
# 5. Access services at http://<your-nas-ip>:port
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      HomeLab NAS Server                     │
│                      (Ubuntu Linux)                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          Docker Compose Services (11 total)          │  │
│  │                                                      │  │
│  │  ┌────────────┐  ┌─────────────┐  ┌────────────┐   │  │
│  │  │ Immich     │  │ Nextcloud   │  │ Jellyfin   │   │  │
│  │  │ 2283       │  │ 8080        │  │ 8096       │   │  │
│  │  └────────────┘  └─────────────┘  └────────────┘   │  │
│  │                                                      │  │
│  │  ┌──────────────────────────────────────────────┐  │  │
│  │  │  Portainer: 9000 │ Grafana: 3000            │  │  │
│  │  │  Prometheus: 9090 │ Node-exporter: 9100    │  │  │
│  │  └──────────────────────────────────────────────┘  │  │
│  │                                                      │  │
│  │  ┌──────────────────────────────────────────────┐  │  │
│  │  │  Databases: PostgreSQL, Redis               │  │  │
│  │  │  Volumes: Persistent data storage            │  │  │
│  │  └──────────────────────────────────────────────┘  │  │
│  │                                                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          Storage Subsystem                           │  │
│  │                                                      │  │
│  │  /srv/nas/  ┌──────┬──────────┬─────────────┐      │  │
│  │             │photos│backups   │media        │      │  │
│  │             └──────┴──────────┴─────────────┘      │  │
│  │                                                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📥 Installation Guide

### Step 1: Prepare Ubuntu System

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Verify user has sudo privileges
sudo whoami
# Should output: root (means sudo works)

# Verify you're not running as root
whoami
# Should NOT output: root
```

### Step 2: Clone Repository

```bash
cd /opt  # or ~/projects
git clone https://github.com/username/NAS-Linux.git
cd NAS-Linux
```

### Step 3: Configure Environment

```bash
cp config.env config.env  
nano config.env
```

**Key variables:**
```env
# Storage paths (ensure partitions have sufficient space)
NAS_PATH=/srv/nas
MEDIA_PATH=/srv/nas/media
TIMEZONE=Europe/Madrid

# Service ports
NEXTCLOUD_PORT=8080
JELLYFIN_PORT=8096
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000

# Immich
IMMICH_VERSION=release
UPLOAD_LOCATION=/srv/nas/photos
DB_PASSWORD=<choose-secure-password>
```

### Step 4: Run Installation

```bash
chmod +x *.sh scripts/*.sh
./install.sh
# Enter sudo password when prompted
# Installation takes 10-20 minutes
```

**What happens:**
1. ✅ Creates storage directories
2. ✅ Sets up system users (admin, pareja)
3. ✅ Configures Samba shares
4. ✅ Installs Docker
5. ✅ Deploys 11 Docker services
6. ✅ Configures backups & snapshots
7. ✅ Sets up monitoring
8. ✅ Configures firewall
9. ✅ Sets up Tailscale
10. ✅ Runs health checks

### Step 5: Verify Installation

```bash
./scripts/health_check.sh
# Should show all services as [OK]

sudo docker ps
# Should show 11 running containers
```

---

## 📱 Service Documentation

### Immich (Photo Backup & Gallery)
**Port**: 2283 | **URL**: `http://<nas-ip>:2283`

- Auto-backup photos from phone
- Organize by date, location, face recognition
- Album sharing, web gallery
- **Storage**: `/srv/nas/photos`

### Nextcloud (File Storage)
**Port**: 8080 | **URL**: `http://<nas-ip>:8080`

- Personal file sync (Dropbox alternative)
- Calendar, contacts, task management
- Collaborative editing
- **Storage**: Docker volume

### Jellyfin (Media Streaming)
**Port**: 8096 | **URL**: `http://<nas-ip>:8096`

- Stream movies, TV shows, music
- Personal photo galleries
- Multiple library types (movies, anime, music)
- **Storage**: `/srv/nas/media`

### Portainer (Container Management)
**Port**: 9000 | **URL**: `http://<nas-ip>:9000`

- Visual container management
- View logs & resource usage
- Stop/restart services

### Monitoring Stack
- **Prometheus** (9090): Metrics database
- **Grafana** (3000): Visualization dashboards
- **Node Exporter** (9100): System metrics

---

## 📱 Immich Mobile Setup

### Android Setup

1. **Install App**: Google Play Store → Search "Immich" → Install

2. **Add Server**:
   - Open Immich
   - Tap "Add Server"
   - Enter: `http://<nas-ip>:2283`

3. **Create Account**:
   - Email: `your-email@example.com`
   - Password: Strong password
   - Tap "Create Account"

4. **Configure Auto-Backup**:
   - Settings ⚙️ → Backup Settings
   - ✅ Enable Backup
   - Select folders to backup
   - Quality: "Original" (keep full resolution)
   - Trigger: "Wifi Only" (recommended)

5. **Start Backup**:
   - Return to main screen
   - Photos upload automatically on WiFi
   - Check "Recent" tab to verify

### iOS Setup

1. **Install App**: App Store → Search "Immich" → Install

2. **Connect to Server**:
   - Open Immich
   - Tap "Add Server"
   - Enter: `http://<nas-ip>:2283`

3. **Create Account**:
   - Email & password
   - Tap "Register"

4. **Enable Auto-Backup**:
   - Settings tab (bottom)
   - Photo Auto Backup: Toggle ON
   - Select folders
   - Quality: "Original" or "Compressed"
   - WiFi Only option

5. **Grant Permissions**:
   - Allow Photos access
   - Allow Videos access
   - Allow Location access

### Web Access

1. Open browser: `http://<nas-ip>:2283`
2. Register or login
3. Browse/upload photos
4. Share galleries

### Remote Access (Tailscale)

1. Install Tailscale on phone & login
2. In Immich app, add server with Tailscale IP:
   - `http://100.xx.xx.xx:2283`
3. Full access from anywhere!

---

## 🌐 Accessing Services

### Local Network

Find NAS IP:
```bash
hostname -I
# Example: 192.168.1.100
```

Access services:
- **Immich**: http://192.168.1.100:2283
- **Nextcloud**: http://192.168.1.100:8080
- **Jellyfin**: http://192.168.1.100:8096
- **Portainer**: http://192.168.1.100:9000
- **Grafana**: http://192.168.1.100:3000

### Remote (Tailscale)

1. Install Tailscale on device
2. Connect to your Tailscale network
3. Use Tailscale IP: `http://100.xx.xx.xx:port`

### Samba Network Shares

- **Windows/Mac**: `\\<nas-ip>\NAS`
- **Linux**: `smb://<nas-ip>/NAS`

---

## 🔍 Monitoring & Administration

### Health Checks

```bash
./scripts/health_check.sh
# Shows all services status

sudo docker ps
# List all running containers
```

### View Logs

```bash
tail -f logs/install.log
tail -f logs/service_deployment.log

# Docker logs
sudo docker logs immich_server
sudo docker logs nextcloud
```

### Docker Management

```bash
cd docker/

# Stop/start services
sudo docker compose stop nextcloud
sudo docker compose start nextcloud

# Restart all
sudo docker compose restart

# View logs
sudo docker compose logs -f immich_server
```

### Grafana Dashboard

1. Access: `http://<nas-ip>:3000`
2. Login: `admin:admin`
3. Change password immediately!
4. Browse dashboards:
   - System Overview
   - Docker Stats
   - Network I/O

---

## 💾 Backup & Recovery

### Automated Backups
- **Frequency**: Daily at 2 AM
- **Retention**: 7 days rolling
- **Location**: `/srv/nas/backups`

### Manual Backup

```bash
./scripts/backup.sh
```

### Snapshots (7-day)

```bash
# View snapshots
ls -la /srv/nas/.snapshots/

# Restore file
cp /srv/nas/.snapshots/*/filename /srv/nas/
```

---

## 🔧 Troubleshooting

### Services Not Starting

```bash
sudo systemctl restart docker
sudo docker compose logs
sudo docker compose up -d
```

### Port Already in Use

```bash
sudo lsof -i :8080
# Change port in config.env & redeploy
```

### Storage Issues

```bash
df -h
du -sh /srv/nas/*
```

### Docker Registry Issues

```bash
sudo docker system prune -a
sudo docker pull immich-app/immich-server:release
```

---

## 🔐 Security

### Initial Setup
- Change Grafana password (admin:admin)
- Configure Nextcloud admin users
- Set up Immich users

### Firewall
```bash
sudo ufw status
# Configured to allow only needed ports
```

### Network Isolation
- All services in Docker containers
- Automatic restarts
- Data in persistent volumes

### HTTPS/SSL
- Current: HTTP (local network safe)
- Future: Let's Encrypt via Nginx (see Next Phases)

---

## 📊 Testing

Run all tests:
```bash
./run_all_tests.sh
```

Individual tests:
```bash
./tests/system_tests.sh
./tests/container_tests.sh
./tests/network_tests.sh
./tests/immich_tests.sh
./tests/api_tests.sh
```

---

## 🚀 Next Phases

### Phase 2: Production Hardening (Recommended)
- [ ] HTTPS/SSL certificates (Let's Encrypt)
- [ ] Nginx reverse proxy
- [ ] Rate limiting & DDoS protection
- [ ] Fail2ban for intrusion prevention
- [ ] Advanced firewall rules

### Phase 3: Advanced Features
- [ ] ZFS RAID configuration
- [ ] Automated disaster recovery
- [ ] Cloud backup integration
- [ ] Advanced Immich features (AI tagging)
- [ ] Media transcoding optimization

### Phase 4: Scalability
- [ ] Kubernetes deployment
- [ ] Multi-node setup
- [ ] Load balancing
- [ ] Database replication
- [ ] Distributed storage (Ceph)

### Phase 5: Intelligence & Automation
- [ ] ML-powered photo organization
- [ ] Smart home integration
- [ ] Predictive analytics
- [ ] Cost optimization

---

## 📚 Resources

- **Immich**: https://immich.app/docs/
- **Nextcloud**: https://docs.nextcloud.com/
- **Jellyfin**: https://jellyfin.org/docs/
- **Docker**: https://docs.docker.com/
- **Tailscale**: https://tailscale.com/kb/

---

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Make changes
4. Run tests: `./run_all_tests.sh`
5. Submit pull request

---

## 📄 License

MIT License - See LICENSE file

---

**Status**: ✅ All services operational  
**Last Updated**: April 23, 2026  
**Version**: 1.0.0
