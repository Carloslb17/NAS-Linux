# Manual Operativo Completo — HomeLab NAS Pro

## Objetivo

Este manual describe paso a paso cómo probar, validar, mantener y depurar el sistema HomeLab NAS Pro después de crear el repositorio. Está diseñado para usuarios técnicos que quieren entender cómo se conectan los servicios y qué hacer si algo falla.

Incluye:

* Verificación inicial
* Acceso a servicios
* Configuración de APIs
* Tests manuales
* Tests automáticos con LLM
* Troubleshooting realista
* Checklist operativo

---

# 1. Verificación inicial del sistema

Después de ejecutar:

```bash
git clone homelab-nas-pro
cd homelab-nas-pro
./install.sh
```

Ejecutar:

```bash
./scripts/health_check.sh
```

Debe mostrar:

* Docker running
* Samba running
* Tailscale running
* Disk OK
* Services healthy

---

# 2. Comandos básicos de diagnóstico

## Ver contenedores activos

```bash
docker ps
```

## Ver logs de un servicio

```bash
docker logs nombre_servicio
```

Ejemplo:

```bash
docker logs nextcloud
```

## Ver uso de disco

```bash
df -h
```

## Ver memoria

```bash
free -h
```

## Ver procesos

```bash
top
```

---

# 3. Acceso a servicios

Desde navegador local o vía VPN.

## Nextcloud

```text
http://IP_SERVIDOR:8080
```

Credenciales iniciales:

```text
usuario: admin
password: definida durante instalación
```

---

## Jellyfin

```text
http://IP_SERVIDOR:8096
```

Carpeta media:

```text
/srv/nas/media
```

---

## Grafana

```text
http://IP_SERVIDOR:3000
```

Credenciales por defecto:

```text
admin / admin
```

---

## Prometheus

```text
http://IP_SERVIDOR:9090
```

---

## Portainer

```text
http://IP_SERVIDOR:9000
```

---

# 4. Acceso remoto (VPN)

Instalar cliente Tailscale en:

* portátil
* móvil
* tablet

Login:

```bash
tailscale login
```

Ver dispositivos:

```bash
tailscale status
```

---

# 5. APIs de servicios (si necesitas integraciones)

## Nextcloud API

Endpoint base:

```text
http://IP_SERVIDOR:8080/ocs/v2.php/
```

Ejemplo test:

```bash
curl -u admin:password \
http://IP_SERVIDOR:8080/ocs/v2.php/cloud/users
```

---

## Grafana API

Crear API key:

Settings → API Keys → New Key

Ejemplo:

```bash
curl \
-H "Authorization: Bearer API_KEY" \
http://IP_SERVIDOR:3000/api/health
```

---

## Prometheus API

```bash
curl http://IP_SERVIDOR:9090/api/v1/status/runtimeinfo
```

---

# 6. Snapshots

Ubicación:

```text
/srv/nas/snapshots
```

Crear snapshot manual:

```bash
./scripts/create_snapshot.sh
```

Restaurar snapshot:

```bash
rsync -a \
/srv/nas/snapshots/latest/ \
/srv/nas/
```

---

# 7. Backups

Destino:

```text
/srv/nas/backups
```

Ejecutar backup manual:

```bash
./scripts/backup.sh
```

Ver cron:

```bash
crontab -l
```

---

# 8. Monitorización

Métricas disponibles:

* CPU
* RAM
* Disk
* Network
* Containers

---

# 9. Alertas

Se disparan cuando:

* disco lleno
* servicio caído
* backup fallido
* CPU alta

Logs:

```text
logs/alerts.log
```

---

# 10. Tests manuales (Checklist)

Ejecutar en orden.

## Test 1 — Docker

```bash
docker ps
```

Debe mostrar:

* nextcloud
* jellyfin
* grafana
* prometheus

---

## Test 2 — Red

```bash
ping google.com
```

---

## Test 3 — Disco

```bash
df -h
```

---

## Test 4 — Samba

Desde otro equipo:

```text
\\IP_SERVIDOR\NAS
```

---

# 11. Tests automáticos (LLM-driven)

Crear archivo:

```text
tests/system_tests.sh
```

Contenido:

```bash
#!/bin/bash

errors=0

check_service() {

    if systemctl is-active --quiet "$1"; then

        echo "$1 OK"

    else

        echo "$1 FAILED"

        errors=$((errors+1))

    fi

}

check_service docker
check_service smbd
check_service tailscaled

if [ $errors -eq 0 ]; then

    echo "SYSTEM HEALTHY"

else

    echo "SYSTEM HAS ERRORS"

fi
```

---

# 12. Test automático de contenedores

```bash
#!/bin/bash

containers=(
nextcloud
jellyfin
grafana
prometheus
)

for c in "${containers[@]}"
do

    if docker ps | grep -q "$c"; then

        echo "$c RUNNING"

    else

        echo "$c NOT RUNNING"

    fi

done
```

---

# 13. Test de red

```bash
#!/bin/bash

ping -c 1 8.8.8.8
```

---

# 14. Test completo del sistema

Crear:

```bash
run_all_tests.sh
```

```bash
#!/bin/bash

./tests/system_tests.sh
./tests/container_tests.sh
./tests/network_tests.sh
```

---

# 15. Automatizar tests diarios

Cron:

```bash
0 6 * * * /home/user/run_all_tests.sh
```

---

# 16. Logs importantes

```text
logs/install.log
logs/backup.log
logs/alerts.log
```

Ver logs:

```bash
tail -f logs/install.log
```

---

# 17. Troubleshooting real

## Problema: Docker no arranca

```bash
sudo systemctl restart docker
```

---

## Problema: servicio caído

```bash
docker restart nombre_servicio
```

---

## Problema: disco lleno

```bash
df -h
```

Limpiar:

```bash
docker system prune -a
```

---

## Problema: no acceso remoto

```bash
tailscale status
```

---

# 18. Recuperación de emergencia

Restaurar backup:

```bash
rsync -a \
/srv/nas/backups/latest/ \
/home/
```

---

# 19. Escalado futuro

Cuando añadas discos:

Ejecutar:

```bash
./scripts/add_disk.sh
```

---

# 20. Buenas prácticas

Nunca:

* borrar snapshots manualmente
* apagar sin shutdown
* ignorar logs

Siempre:

* revisar espacio disco
* revisar backups
* revisar alertas

---

# 21. Comando de diagnóstico completo

```bash
./scripts/health_check.sh
```

---
