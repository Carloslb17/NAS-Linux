#!/bin/bash
LOG_FILE="logs/tests.log"
mkdir -p logs
touch "$LOG_FILE"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] INSTALL_TEST: $1" | tee -a "$LOG_FILE"; }

errors=0
log "Starting Installation Tests"

if [ -f "config.env" ]; then
  log "[OK] config.env exists"
else
  log "[FAIL] config.env is missing"
  errors=$((errors+1))
fi

if [ -x "install.sh" ]; then
  log "[OK] install.sh is executable"
else
  log "[WARNING] install.sh is not executable"
fi

if [ -x "scripts/deploy_immich.sh" ]; then
  log "[OK] deploy_immich.sh is executable"
else
  log "[WARNING] deploy_immich.sh is not executable"
fi

if grep -q "deploy_immich" install.sh 2>/dev/null; then
  log "[OK] install.sh includes Immich deployment"
else
  log "[FAIL] install.sh does not reference deploy_immich"
  errors=$((errors+1))
fi

if command -v docker >/dev/null 2>&1; then
  log "[OK] Docker command is available"
else
  log "[FAIL] Docker command is not installed"
  errors=$((errors+1))
fi

if command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1; then
  log "[OK] Docker Compose is available"
else
  log "[FAIL] Docker Compose is not available"
  errors=$((errors+1))
fi

for path in "/srv/nas" "/srv/nas/backups" "/srv/nas/photos"; do
  if [ -d "$path" ]; then
    log "[OK] Directory exists: $path"
  else
    log "[WARNING] Directory missing: $path"
  fi
done

if [ $errors -ne 0 ]; then
  log "Installation tests FAILED"
  exit 1
fi
log "Installation tests PASSED"
exit 0
