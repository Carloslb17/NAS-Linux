# HomeLab NAS Pro - Current Status

## Overview
This repository provides an automated setup for a complete HomeLab NAS server on Ubuntu Linux. It is designed to build a personal cloud, media server, backup system, and secure remote access environment.

## Current Status Summary
- **Services**: ✅ OK
- **Containers**: ❌ FAILED
- **Network**: ✅ OK
- **Disk**: ✅ OK
- **APIs**: ❌ FAILED
- **Backups**: ✅ OK
- **Snapshots**: ✅ OK
- **Install checks**: ✅ OK
- **Immich**: ❌ FAILED

## What Is Working
- **Core storage paths** are present:
  - `/srv/nas`
  - `/srv/nas/backups`
  - `/srv/nas/media`
  - `/srv/nas/snapshots`
- **System users** created successfully.
- **Docker daemon** is installed and running.
- **Samba file share** is available.
- **Tailscale** service is up.
- **Portainer** is running at `http://10.225.214.205:9000`.
- **Backup and snapshot directories** exist and are ready.

## What Failed
### Container deployment failed
- **Nextcloud**, **Jellyfin**, **Prometheus**, **Grafana**, and **Immich** containers are not running.
- The only active container confirmed is **Portainer**.
- Service startup failed because Docker image download/pull was interrupted by network errors.

### API health checks failed
- Nextcloud, Grafana, and Prometheus endpoints are unreachable.
- This is caused by the application containers not being fully deployed.

### Immich deployment failed
- `./scripts/deploy_immich.sh` generated the environment file but the service stack did not complete.
- Immich is not available on port `2283`.

## Root Cause Analysis
- The install scripts and system setup are mostly correct.
- The main blocker is **Docker image pull failures** due to remote network/registry interruptions:
  - `read tcp ... connection reset by peer`
- There was a **watchtower compatibility issue** in the previous compose setup, which has been removed from the deployment flow.

## Immediate Recovery Plan
1. Verify external network connectivity:
   ```bash
   ping -c 3 8.8.8.8
   ping -c 3 google.com
   ```
2. Retry Docker image pulls:
   ```bash
   cd docker
   sudo docker compose pull
   ```
3. Start the application stack:
   ```bash
   sudo docker compose up -d
   ```
4. Redeploy Immich:
   ```bash
   cd ..
   ./scripts/deploy_immich.sh
   ```
5. Validate with the test suite:
   ```bash
   ./run_all_tests.sh
   ```

## Manual Recovery Commands
If automated scripts still fail, run each service manually:
```bash
cd docker
sudo docker compose pull nextcloud jellyfin prometheus grafana
sudo docker compose up -d nextcloud jellyfin prometheus grafana node-exporter
```
Then redeploy Immich:
```bash
cd ..
./scripts/deploy_immich.sh
```

## Logs to Inspect
- `logs/install.log`
- `logs/tests.log`
- `sudo docker compose logs --tail 100`
- `sudo docker logs <container-name>`

## Notes for Later Troubleshooting
- If pull fails with `read: connection reset by peer`, retry after 5–10 minutes.
- If a container starts and then stops, inspect specific container logs.
- If Immich fails again, confirm `docker/immich/.env` exists and port `2283` is free.

## Architecture Snapshot
```
[Remote User] ---(Tailscale VPN)---> [HomeLab NAS]
                                      |
                                      +-- Samba
                                      +-- Portainer
                                      +-- Nextcloud
                                      +-- Jellyfin
                                      +-- Monitoring
                                      +-- Immich
                                      +-- Backups/Snapshots
```

## Security Notes
- Services are containerized for isolation.
- Tailscale provides VPN-based remote access.
- UFW firewall should be configured once the services are stable.
- User permissions are set for `admin` and `pareja`.

## Recommendation
Focus on resolving the Docker image pull problem first. Once the application containers are running, the API and Immich failures should resolve on their own.
