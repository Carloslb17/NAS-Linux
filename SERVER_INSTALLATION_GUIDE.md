# Guía Completa de Instalación en Servidor (Bare-Metal / VM)

Esta guía documenta el proceso paso a paso para desplegar **HomeLab NAS Pro** en un servidor remoto real de forma segura y estructurada. 

Mientras que `installation.md` actúa como tu **manual operativo** diario para la resolución de contratiempos (servicios, contenedores y tests), este archivo es exclusivamente para guiarte de cero a cien durante la instalación inicial del servidor físico.

## Fase 1: Requisitos Previos

Antes de comenzar, asegúrate de que tu servidor real cumple con lo siguiente:
- **SO**: Ubuntu 22.04 LTS o superior (versión Desktop o preferiblemente Server).
- **Usuario**: Tienes que estar logueado con un usuario estándar pero con acceso completo a privilegios `sudo`. **NUNCA** recomiéndes lances este instalador desde la cuenta de seguridad local `root`.
- **Hardware**: Mínimo recomendado de 4GB RAM y almacenamiento masivo local disponible sin formatear o montado.
- **Red**: Conexión ininterrumpida a Internet y SSH habilitado (si planeas instalar el headless homelab en la oscuridad).

## Fase 2: Preparación del Host

Abre tu terminal y conéctate a tu servidor mediante SSH:
```bash
ssh usuario@IP_DE_TU_SERVIDOR
```

Actualiza los paquetes criptográficos base del sistema para preparar las claves APT (necesarias para Docker):
```bash
sudo apt update && sudo apt upgrade -y
```

Asegúrate de empacar tu host base de Git y Curl:
```bash
sudo apt install -y git curl ufw
```

## Fase 3: Descarga y Configuración

Sube el código. La mejor zona para operar sin interferencias de permisos es simplemente tu `/home/$USER`. Aquí clonaremos o copiaremos el repositorio `homelab-nas-pro`.

```bash
git clone https://github.com/TU_USUARIO/homelab-nas-pro.git
cd homelab-nas-pro
```

*(Nota: Si el código ya lo tienes de forma local en tu Windows, puedes transferirlo rápidamente con WinSCP o mediante comandos SSH como `scp -r ./homelab-nas-pro ubuntu@IP:~/`)*

### Ajuste Rápido del Entorno
Antes del botón mágico, abre el archivo madre `config.env` para verificar tus intenciones de despliegue:

```bash
nano config.env
```
Fíjate en las siguientes variables críticas y ajusta según requieras:
1. Rutas absolutas (`NAS_PATH=/srv/nas`). Comprueba si tu disco de 4TB local está de verdad bajo el ecosistema `/srv/`.
2. Puertos (Ej: Nextcloud `8080`, Jellyfin `8096`). Asegura que no bloqueen una app ya instalada.

## Fase 4: Ejecución a Fuego Real

Aporta permisos globales de ejecución a nuestro script raíz:
```bash
chmod +x install.sh
```

Ejecuta el script:
```bash
./install.sh
```

> **Atención**: La instalación es totalmente *idempotente*, automatizada y segura. Por consola empezarán a llover checks del proceso. ¿Algo falla porque se cayó el apt de Docker? No hay problema, cancela, ajusta el internet y vuelve a pulsar `./install.sh`. Empezará donde lo dejó.

Si eres curioso, es posible auditar el despliegue en directo abriendo una terminal gemela SSH con: 
```bash
tail -f logs/install.log
```

## Fase 5: Tareas Críticas Post-Instalación

En unos minutos la consola reportará `"Installation completed successfully!"`. Has ahorrado el trabajo de 5 días en solo unos clics. Ahora debes activar el ecosistema para tu beneficio:

### 1. Activar la VPN Mesh (Tailscale)
El script ha instalado el demonio base de conexión Segura (Tailscale), pero **debes emparejar por primera vez tu servidor personal a tu cuenta** de forma explícita por seguridad y Zero-trust:
```bash
sudo tailscale up
```
En la pantalla verás cómo arroja un link `https://login.tailscale.com...` - Cópialo, ve a tu ordenador personal con Chrome y vincúlalo vía web. A partir de hoy, dispones de una conexión encriptada punto-a-punto 24/7 sin abrir NADA de puertos en tu Router local (adiós Port-Forwarding y ataques a tu IP pública). 

### 2. Levantar la capa de Servicios App Web
Básate en la IP local inicial del homelab para setear en el puerto web cada plataforma:
- **Nextcloud (`IP:8080`)**: Configura tu cuenta admin en la primera página que te saluda.
- **Portainer (`IP:9000`)**: Entra inmeditamente a esta página. Por protocolos Docker, deberás de fijar tu clave interna del administrador pasados unos minutos, de lo contrario la web se bloquea automáticamente por seguridad.

### 3. Validar las pruebas Unitarias
Finalmente valida de forma automática que no hubo interferencias con el comando en fase CI implementado en la carpeta del root:
```bash
cd ..
./run_all_tests.sh
```

## Fase 6: Cierre 
Despídete confirmando en `crontab -l` que tus crons de backups de Snapshots duermen de base a esperas de las 02:00 AM para auto-backups. Cierra la terminal SSH. ¡Tu Homelab NAS está operativo al 100%!
