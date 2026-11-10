#!/usr/bin/env bash
# ==============================================================================
# deploy.sh — Unified Deployment Script for Rudra Sarkar (rudrasarkar.omicron.host)
#
# Usage (Local Workstation):
#   ./deploy.sh "Your commit message"
#   -> Validates JS syntax, syncs Rudra_Sarkar.html, commits, and pushes to
#      GitHub `main`, triggering automatic GitHub Actions VPS deployment.
#
# Usage (Directly on Ubuntu VPS):
#   ./deploy.sh --server
#   -> Backs up /var/www/rudra, pulls latest main branch, and atomically updates
#      production files without interrupting Nginx or deleting vps-status.json.
# ==============================================================================

set -euo pipefail

TARGET_DIR="${VPS_TARGET_DIR:-/var/www/rudra}"
BACKUP_ROOT="/var/backups/rudra-site"

if [ "${1:-}" = "--server" ]; then
  echo "==> Running Server-Side Atomic Deployment in ${TARGET_DIR}..."
  TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
  mkdir -p "${BACKUP_ROOT}" 2>/dev/null || true

  if [ -d "${TARGET_DIR}" ] && [ -f "${TARGET_DIR}/index.html" ]; then
    tar -czf "${BACKUP_ROOT}/backup_${TIMESTAMP}.tar.gz" \
      --exclude="vps-status.json*" \
      -C "${TARGET_DIR}" . 2>/dev/null || true
    ls -1dt "${BACKUP_ROOT}"/backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -f
    echo "==> Backup saved to ${BACKUP_ROOT}/backup_${TIMESTAMP}.tar.gz"
  fi

  cd "${TARGET_DIR}"
  if [ -d ".git" ]; then
    git fetch origin main
    git reset --hard origin/main
  fi

  cp -f index.html Rudra_Sarkar.html
  chmod 644 index.html Rudra_Sarkar.html vps-status.php
  chmod 755 scripts/*.sh 2>/dev/null || true

  if sudo -n nginx -t >/dev/null 2>&1; then
    sudo -n systemctl reload nginx
  fi
  echo "==> Server deployment complete!"
  exit 0
fi

# --- Local Workstation Workflow ---
COMMIT_MSG="${1:-Website update ($(date +'%Y-%m-%d %H:%M'))}"

echo "==> 1. Syncing index.html -> Rudra_Sarkar.html..."
cp -f index.html Rudra_Sarkar.html

echo "==> 2. Validating embedded JavaScript syntax..."
if command -v node >/dev/null 2>&1; then
  node -e '
    const fs = require("fs");
    const html = fs.readFileSync("index.html", "utf8");
    const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
    scripts.forEach((m, i) => new Function(m[1]));
    console.log("   JS syntax OK across " + scripts.length + " script blocks.");
  '
fi

echo "==> 3. Staging & committing changes..."
git add -A
if git diff --cached --quiet; then
  echo "==> No file changes to commit. Pushing any unpushed commits..."
else
  git commit -m "${COMMIT_MSG}"
fi

echo "==> 4. Pushing to origin/main (triggers GitHub Actions VPS deployment)..."
git push origin main
echo "==> Done! GitHub Actions is now deploying to https://rudrasarkar.omicron.host"
