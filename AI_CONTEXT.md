# AI_CONTEXT.md — Persistent Architecture & Context Guide

> **MANDATORY FOR ALL AI AGENTS:** Read this file and `PROJECT_INDEX.md` **before** running any file searches or reading full source files. Do **not** read all of `index.html` at once — use the exact line ranges documented in `PROJECT_INDEX.md` to inspect only the 30–60 lines relevant to the user's request.

---

## 1. Project Overview & Architecture
- **Project Name:** Rudra Sarkar Personal Hub & Live Telemetry Portal
- **Live Domain:** `https://rudrasarkar.omicron.host`
- **Production VPS:** Ubuntu Linux (`nginx/1.24.0`), 4 vCPU AMD Ryzen 9, 30.6 GB RAM, 103 GB NVMe SSD
- **Production Web Root:** `/var/www/rudra`
- **Local Workspace:** `C:\Users\rudra\.gemini\antigravity\scratch\rudra-links`
- **Architecture Type:** Zero-build, single-bundle progressive web app (`index.html` + synced mirror `Rudra_Sarkar.html`) paired with a real-time Linux telemetry agent (`scripts/vps-agent.sh` -> `/var/www/rudra/vps-status.json`) and optional PHP fallback (`vps-status.php`).

---

## 2. Technology Stack & External Integrations
- **Frontend:** Semantic HTML5, CSS3 Custom Properties (`--page`, `--card`, `--ink`, `--muted`, `--line`, `--hover`, `--avatar`), Liquid Glass / 3D Frosted Glassmorphism UI, 2D Pixel-Art `<canvas>` scenes, inline SVG sprite sheet.
- **Typography:** Google Fonts (`Poppins`, `Outfit`, `Press Start 2P`).
- **Live Weather API:** Open-Meteo Forecast API (`https://api.open-meteo.com/v1/forecast`) + BigDataCloud Reverse Geocoding (`https://api.bigdatacloud.net/data/reverse-geocode-client`) + Browser Geolocation API, with 10-minute `localStorage` caching (`rudra-wx-v2`, `rudra-wx-cache-v1`).
- **Live VPS Telemetry:**
  - Primary: Background Linux daemon (`scripts/vps-agent.sh` managed by `systemd` unit `vps-agent.service`) writes real-time metrics from `/proc/stat`, `/proc/meminfo` (`MemTotal - MemAvailable`), `/proc/loadavg`, `/proc/uptime`, and `df -BG /` to `/var/www/rudra/vps-status.json` every 2 seconds.
  - Secondary Fallback: `vps-status.php` reads `/proc/*` on request if PHP-FPM is enabled.
  - Client Polling: `#vps` modal polls `./vps-status.json` every 2 seconds while open (`state.open && !document.hidden`).
- **CI/CD Pipeline:** GitHub Actions (`.github/workflows/deploy.yml`) validates embedded JS syntax via Node.js, creates a rolling backup in `/var/backups/rudra-site` (retaining last 5 archives), atomically deploys `index.html`, `Rudra_Sarkar.html`, `vps-status.php`, and `scripts/*.sh` to `/var/www/rudra`, reloads Nginx safely, and verifies HTTP 200 + `.release-sha`.

---

## 3. Important Technical Decisions & Conventions
1. **Always Keep `index.html` and `Rudra_Sarkar.html` Identical:**
   - All edits must be made to `index.html` first, then copied to `Rudra_Sarkar.html` (`Copy-Item index.html Rudra_Sarkar.html -Force` or via `deploy.sh`).
2. **Default Theme is Light (`<html data-theme="light">`):**
   - Light mode is the default unless the visitor explicitly toggles Dark Mode (stored in `localStorage` key `rudra-theme-choice`).
3. **60fps GPU Performance Rules (Do Not Regress):**
   - Only `.card`, `.wx`, `.wx-panel`, and `.upi-dialog` use `backdrop-filter: blur(...)`.
   - Do **not** add nested `backdrop-filter` to `.row`, `.row .ic`, `.vps-card`, `.vps-banner`, or `.wx-bubble` (their translucent linear/radial gradients already sit inside blurred or gradient containers).
   - `body.modal-open` pauses background CSS animations (`.bgc`, `.hang .sw`, `#wxRowIcon`) and canvas loops (`#banner`, `#night`) while `#wx` or `#vps` is open.
4. **Smooth Modal Open/Close Transitions:**
   - `#wx` and `#vps` use `.wx-closing` (`260ms`) and `.wx-layer.wx-closing` (`220ms`) before setting `hidden = true`.
   - `#upiDialog` uses `.pop-out` (`180ms`) before calling `dialog.close()`.

---

## 4. Mandatory Incremental AI Workflow
For every new user instruction, follow this exact sequence:
1. Read `AI_CONTEXT.md` and `PROJECT_INDEX.md`.
2. Identify the exact section and line range in `PROJECT_INDEX.md`.
3. Use `read_file` with `StartLine` and `EndLine` (only 40–100 lines around the target). **Never** read all 2,670 lines of `index.html`.
4. Use `edit_file` for targeted replacements.
5. Sync `Rudra_Sarkar.html` from `index.html` and run the 1-line Node.js syntax check:
   ```powershell
   Copy-Item index.html Rudra_Sarkar.html -Force
   node -e "const fs=require('fs');const h=fs.readFileSync('index.html','utf8');[...h.matchAll(/<script>([\s\S]*?)<\/script>/g)].forEach(m=>new Function(m[1]));console.log('JS OK');"
   ```
6. Update `PROJECT_INDEX.md` line numbers if a section shifted significantly (>30 lines).
