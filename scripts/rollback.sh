#!/usr/bin/env bash
# ==============================================================================
# scripts/rollback.sh — Instant Production Rollback for /var/www/rudra
#
# Usage on Ubuntu VPS:
#   bash /var/www/rudra/scripts/rollback.sh           # Restores latest backup
#   bash /var/www/rudra/scripts/rollback.sh <file>    # Restores specific backup
# ==============================================================================

set -euo pipefail

WEB_DIR="${VPS_TARGET_DIR:-/var/www/rudra}"
BACKUP_ROOT="/var/backups/rudra-site"

if [ ! -d "${BACKUP_ROOT}" ]; then
  echo "Error: Backup directory ${BACKUP_ROOT} not found."
  exit 1
fi

if [ -n "${1:-}" ]; then
  ARCHIVE="${1}"
else
  ARCHIVE="$(ls -1dt "${BACKUP_ROOT}"/backup_*.tar.gz 2>/dev/null | head -n 1 || true)"
fi

if [ -z "${ARCHIVE}" ] || [ ! -f "${ARCHIVE}" ]; then
  echo "Error: No backup archive found in ${BACKUP_ROOT}."
  ls -lh "${BACKUP_ROOT}" || true
  exit 1
fi

echo "==> Rolling back ${WEB_DIR} from ${ARCHIVE}..."
tar -xzf "${ARCHIVE}" -C "${WEB_DIR}"
chmod 644 "${WEB_DIR}/index.html" "${WEB_DIR}/Rudra_Sarkar.html" 2>/dev/null || true

if sudo -n nginx -t >/dev/null 2>&1; then
  sudo -n systemctl reload nginx
fi

echo "==> Rollback completed successfully!"
