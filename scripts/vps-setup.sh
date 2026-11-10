#!/usr/bin/env bash
# ==============================================================================
# scripts/vps-setup.sh — One-Time Safe Ubuntu VPS Setup for GitHub Actions CI/CD
#
# Run this script once on your Ubuntu VPS:
#   bash scripts/vps-setup.sh
#
# What it safely performs:
# 1. Inspects existing /var/www/rudra and Nginx config (NEVER overwrites Nginx/SSL).
# 2. Creates a full backup in /var/backups/rudra-site before making any changes.
# 3. Sets safe permissions (755 dirs, 644 files — never 777).
# 4. Installs & starts systemd service `vps-agent.service` for 24/7 real VPS telemetry.
# 5. Generates an Ed25519 SSH deploy keypair (if not present) and prints the values
#    to paste into GitHub Repository Secrets.
# ==============================================================================

set -euo pipefail

WEB_DIR="/var/www/rudra"
BACKUP_ROOT="/var/backups/rudra-site"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

echo "============================================================"
echo "1. Inspecting Existing VPS Environment & Nginx Configuration"
echo "============================================================"
echo "Hostname : $(hostname)"
echo "OS       : $(lsb_release -ds 2>/dev/null || uname -a)"
echo "Web Root : ${WEB_DIR}"

if command -v nginx >/dev/null 2>&1; then
  echo "Nginx    : $(nginx -v 2>&1)"
  echo "Matching Nginx server blocks for rudrasarkar.omicron.host / ${WEB_DIR}:"
  grep -rnE "rudrasarkar|/var/www/rudra" /etc/nginx/sites-enabled/ /etc/nginx/conf.d/ 2>/dev/null || true
  nginx -t
fi

echo ""
echo "============================================================"
echo "2. Backing Up Existing Production Files & Nginx Config"
echo "============================================================"
sudo mkdir -p "${BACKUP_ROOT}" "${WEB_DIR}/scripts"
if [ -d "${WEB_DIR}" ]; then
  sudo tar -czf "${BACKUP_ROOT}/pre_cicd_backup_${TIMESTAMP}.tar.gz" -C "${WEB_DIR}" . 2>/dev/null || true
  echo "Saved website backup: ${BACKUP_ROOT}/pre_cicd_backup_${TIMESTAMP}.tar.gz"
fi
sudo tar -czf "${BACKUP_ROOT}/nginx_config_backup_${TIMESTAMP}.tar.gz" /etc/nginx 2>/dev/null || true
echo "Saved Nginx backup  : ${BACKUP_ROOT}/nginx_config_backup_${TIMESTAMP}.tar.gz"

echo ""
echo "============================================================"
echo "3. Applying Safe File Permissions (755 Dirs / 644 Files)"
echo "============================================================"
DEPLOY_USER="$(whoami)"
sudo chown -R "${DEPLOY_USER}:www-data" "${WEB_DIR}" 2>/dev/null || sudo chown -R "${DEPLOY_USER}:${DEPLOY_USER}" "${WEB_DIR}"
sudo find "${WEB_DIR}" -type d -exec chmod 755 {} \;
sudo find "${WEB_DIR}" -type f -exec chmod 644 {} \;
sudo chmod 755 "${WEB_DIR}/scripts/"*.sh 2>/dev/null || true
sudo chown -R "${DEPLOY_USER}" "${BACKUP_ROOT}"

echo ""
echo "============================================================"
echo "4. Installing Persistent systemd Service for Live VPS Stats"
echo "============================================================"
if [ -f "${WEB_DIR}/scripts/vps-agent.sh" ]; then
  sudo cp -f "${WEB_DIR}/scripts/vps-agent.sh" /usr/local/bin/vps-agent.sh
  sudo chmod 755 /usr/local/bin/vps-agent.sh
  pkill -f "vps-agent.sh" 2>/dev/null || true

  sudo tee /etc/systemd/system/vps-agent.service >/dev/null <<EOF
[Unit]
Description=Rudra VPS Live Telemetry Agent
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/vps-agent.sh ${WEB_DIR}
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable --now vps-agent.service
  echo "vps-agent.service is active and writing live stats to ${WEB_DIR}/vps-status.json"
fi

echo ""
echo "============================================================"
echo "5. Preparing Dedicated GitHub Actions SSH Deploy Key"
echo "============================================================"
SSH_DIR="${HOME}/.ssh"
KEY_FILE="${SSH_DIR}/github_actions_rudra_deploy"
mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

if [ ! -f "${KEY_FILE}" ]; then
  ssh-keygen -t ed25519 -C "github-actions-deploy@rudrasarkar.omicron.host" -f "${KEY_FILE}" -N ""
fi

touch "${SSH_DIR}/authorized_keys"
chmod 600 "${SSH_DIR}/authorized_keys"
PUB_KEY="$(cat "${KEY_FILE}.pub")"
if ! grep -qF "${PUB_KEY}" "${SSH_DIR}/authorized_keys"; then
  echo "${PUB_KEY}" >> "${SSH_DIR}/authorized_keys"
fi

echo ""
echo "============================================================"
echo "ADD THESE 3 SECRETS IN GITHUB -> SETTINGS -> SECRETS -> ACTIONS:"
echo "============================================================"
echo "1. VPS_HOST       : rudrasarkar.omicron.host  (or your VPS IPv4 address)"
echo "2. VPS_USER       : ${DEPLOY_USER}"
echo "3. VPS_TARGET_DIR : ${WEB_DIR}"
echo "4. VPS_SSH_KEY    : (Copy the entire block below including BEGIN and END lines)"
echo "------------------------------------------------------------"
cat "${KEY_FILE}"
echo "------------------------------------------------------------"
