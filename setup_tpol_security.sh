#!/bin/bash
# Project Fortress Bootstrap Script
# Restores the permanent Document Exchange Infrastructure

echo "Initiating Project Fortress Restoration..."

# 1. Create Outbox
mkdir -p /home/tpol/outbox
chmod 755 /home/tpol/outbox
echo "[OK] Outbox created."

# 2. Create Systemd Override
OVERRIDE_DIR="/home/tpol/.config/systemd/user/hermes-gateway.service.d"
mkdir -p "$OVERRIDE_DIR"
echo "[Service]\nEnvironment=\"HERMES_GATEWAY_MEDIA_ALLOWED_DIRS=['/home/tpol/outbox/']\"" > "$OVERRIDE_DIR/override.conf"
echo "[OK] Systemd override configured."

# 3. Update Hermes Config
hermes config set gateway.media_allowed_dirs "['/home/tpol/outbox/']"
echo "[OK] Hermes config updated."

# 4. Restart Gateway
systemctl --user daemon-reload
systemctl --user restart hermes-gateway
echo "[OK] Gateway restarted."

echo "Project Fortress is now active. All documents must be placed in /home/tpol/outbox/ for delivery."
