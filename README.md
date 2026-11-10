# Rudra Sarkar — Personal Hub & Live VPS Telemetry (`rudrasarkar.omicron.host`)

Production repository for **https://rudrasarkar.omicron.host**, hosted on Ubuntu (`Nginx`) at `/var/www/rudra` with automated **GitHub Actions CI/CD** and **AI-optimized incremental context** (`AI_CONTEXT.md` & `PROJECT_INDEX.md`).

---

## 1. How the Automatic Deployment Works

Whenever code is pushed to the `main` branch on GitHub, `.github/workflows/deploy.yml` runs automatically:

1. **Syntax & Integrity Gate:** Runs Node.js in GitHub Actions to parse and verify every `<script>` block in `index.html` and ensures `Rudra_Sarkar.html` is in sync. If there is any syntax error, deployment stops before touching your VPS.
2. **Pre-Deploy Backup:** Connects to your Ubuntu VPS over SSH and creates a compressed backup of `/var/www/rudra` in `/var/backups/rudra-site/backup_<timestamp>_<sha>.tar.gz` (retaining the 5 most recent backups automatically).
3. **Atomic File Replacement:** Uploads the release to a temporary staging folder (`/tmp/rudra-stage-<sha>`) with safe permissions (`644` for files, `755` for scripts) and atomically moves files into `/var/www/rudra`. Live runtime data (`vps-status.json`) and Nginx/SSL configs are **never** overwritten or deleted.
4. **Telemetry Daemon & Nginx Check:** Ensures `/usr/local/bin/vps-agent.sh` (`vps-agent.service`) is running and gracefully reloads Nginx only if `nginx -t` succeeds.
5. **Live Verification:** Requests `https://rudrasarkar.omicron.host` and `/.release-sha` to confirm HTTP `200 OK` and verify that the live server matches the exact GitHub commit SHA.

---

## 2. How to Update Your Website (Daily Workflow)

After Antigravity edits your code and saves changes in `C:\Users\rudra\.gemini\antigravity\scratch\rudra-links`:

### Option A: Standard Git Commands
```bash
git add .
git commit -m "Website update"
git push origin main
```

### Option B: One-Command Deploy Script
```bash
./deploy.sh "Website update"
```
*(Automatically syncs `index.html` -> `Rudra_Sarkar.html`, validates JS syntax, commits, and pushes to `origin main`.)*

---

## 3. How to Configure GitHub Secrets (One-Time Setup)

### Step 1: Run the Setup Script on Your Ubuntu VPS
SSH into your Ubuntu VPS (`demonix-vps`) and run the included setup script (or copy-paste it from `scripts/vps-setup.sh`):

```bash
bash /var/www/rudra/scripts/vps-setup.sh
```
This script will:
- Back up `/var/www/rudra` and `/etc/nginx` into `/var/backups/rudra-site/`.
- Install the persistent `vps-agent.service` systemd daemon so your real 30.6 GB RAM / CPU / Disk stats update 24/7 even after a VPS reboot.
- Generate a dedicated Ed25519 SSH deploy key (`~/.ssh/github_actions_rudra_deploy`), authorize it in `~/.ssh/authorized_keys`, and print the exact values to add to GitHub Secrets.

### Step 2: Add Secrets in GitHub
Open your GitHub repository -> **Settings** -> **Secrets and variables** -> **Actions** -> **New repository secret**, and add:

| Secret Name | Value |
| :--- | :--- |
| `VPS_HOST` | `rudrasarkar.omicron.host` *(or your VPS IPv4 address)* |
| `VPS_USER` | Your SSH username on the Ubuntu VPS (e.g., `root` or `ubuntu`) |
| `VPS_PORT` | `22` *(optional — defaults to `22` if omitted)* |
| `VPS_TARGET_DIR` | `/var/www/rudra` *(optional — defaults to `/var/www/rudra`)* |
| `VPS_SSH_KEY` | Entire private key printed by `vps-setup.sh` (including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`) |

---

## 4. How to Check Deployment Logs

- **Via GitHub Web UI:** Go to your GitHub repository -> click the **Actions** tab -> click the latest **Deploy to Ubuntu VPS** workflow run to inspect each step's real-time logs.
- **Via GitHub CLI (`gh`):**
  ```bash
  gh run list --limit 5
  gh run view --log
  ```
- **Verify Live Commit on VPS:**
  ```bash
  curl -s https://rudrasarkar.omicron.host/.release-sha
  ```

---

## 5. How to Roll Back if a Deployment Fails

Every deployment automatically saves a timestamped `.tar.gz` snapshot in `/var/backups/rudra-site` before modifying `/var/www/rudra`.

### Option A: One-Command Rollback on Ubuntu VPS
Run this command on your Ubuntu VPS to immediately restore the most recent backup:
```bash
bash /var/www/rudra/scripts/rollback.sh
```
Or restore a specific backup archive:
```bash
ls -lt /var/backups/rudra-site/
bash /var/www/rudra/scripts/rollback.sh /var/backups/rudra-site/backup_YYYYMMDD_HHMMSS.tar.gz
```

### Option B: Roll Back via Git (from Local Machine)
```bash
git revert HEAD --no-edit
git push origin main
```
GitHub Actions will automatically deploy the reverted commit to `/var/www/rudra`.

---

## 6. AI-Assisted Development Optimization
- **[AI_CONTEXT.md](./AI_CONTEXT.md):** Persistent architecture, technical rules, and 60fps performance constraints.
- **[PROJECT_INDEX.md](./PROJECT_INDEX.md):** Categorized file & line-range index so AI coding agents read only the exact 40–100 lines needed instead of re-analyzing the entire project.
