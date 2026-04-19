# Mobile Synchronization Guide (Immich)

This document provides exact steps to connect your mobile devices to the private NAS Immich instance.
Since public port forwarding is strictly prohibited, the sync operates exclusively via the Tailscale VPN.

## Step 1: Install Required Apps
On both Android and iOS devices, install:
1. **Tailscale** (from Google Play Store / Apple App Store)
2. **Immich** (from Google Play Store / Apple App Store)

## Step 2: Establish Secure VPN Connection
1. Open the Tailscale app on your phone.
2. Log in with your network credentials.
3. Verify the status is "Connected".

> The current `./install.sh` flow includes Immich deployment by default. If you are using an older installation or need to redeploy Immich manually, run:
>
> ```bash
> ./scripts/deploy_immich.sh
> ```
>
> Then confirm the service is reachable on port `2283`.

## Step 3: Configure Immich App
1. Open Immich.
2. When prompted for the Server URL, enter your private Tailscale server IP and port:
   `http://<tailscale-ip>:2283`
3. Login using your designated credentials:
   - User: `admin` (or `pareja`)
   - Password: (Your configured password)

## Step 4: Verify the setup
1. On the NAS, run:
   ```bash
   ./run_all_tests.sh
   ```
2. Confirm the `Immich` section passes.
3. You can also run only the Immich check:
   ```bash
   ./tests/immich_tests.sh
   ```

## Step 4: Enable Automatic Backup
1. In the Immich app, navigate to **Backup** settings.
2. Select the Albums you want to synchronize.
3. Enable **Automatic photo upload**.
4. Enable **Automatic video upload**.
5. Enable **Background synchronization**.

### Recommended Backup Settings:
- **Upload only on WiFi**: Recommended to avoid mobile data charges.
- **Keep original quality**: Ensure zero compression.
- **Delete local files**: Delete ONLY after confirming successful backup on the NAS web interface.
