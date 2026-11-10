# PROJECT_INDEX.md — File & Symbol Map

> **Quick Lookup Index for AI Agents:** Use the line ranges below with `read_file` (`StartLine` / `EndLine`) to jump directly to the relevant component without scanning the entire repository.

---

## 1. Repository Files

| File Path | Purpose | When to Inspect / Modify |
| :--- | :--- | :--- |
| [index.html](file:///C:/Users/rudra/.gemini/antigravity/scratch/rudra-links/index.html) | Primary production web application (HTML + CSS + SVG + JS). | Any UI, bio, link, weather, or VPS dashboard change. |
| [Rudra_Sarkar.html](file:///C:/Users/rudra/.gemini/antigravity/scratch/rudra-links/Rudra_Sarkar.html) | Exact mirror of `index.html` kept for backward compatibility. | Never edit directly — always copy from `index.html`. |
| [vps-status.php](file:///C:/Users/rudra/.gemini/antigravity/scratch/rudra-links/vps-status.php) | PHP fallback endpoint reading `/proc/meminfo`, `/proc/cpuinfo`, `df`, `/proc/uptime`. | Only when changing PHP-based VPS metric fields. |
| [deploy.sh](file:///C:/Users/rudra/.gemini/antigravity/scratch/rudra-links/deploy.sh) | Local (`./deploy.sh "msg"`) and server (`./deploy.sh --server`) deployment script. | When changing git push or server-side deploy steps. |
| [scripts/vps-agent.sh](file:///C:/Users/rudra/.gemini/antigravity/scratch/rudra-links/scripts/vps-agent.sh) | Linux background daemon writing real metrics to `/var/www/rudra/vps-status.json`. | When adding new Linux hardware/network telemetry fields. |
| [scripts/vps-setup.sh](file:///C:/Users/rudra/.gemini/antigravity/scratch/rudra-links/scripts/vps-setup.sh) | One-time Ubuntu VPS setup (`systemd` service, backups, permissions, SSH key). | When modifying initial VPS provisioning or `systemd` unit. |
| [scripts/rollback.sh](file:///C:/Users/rudra/.gemini/antigravity/scratch/rudra-links/scripts/rollback.sh) | Restores `/var/www/rudra` from `/var/backups/rudra-site/backup_*.tar.gz`. | When modifying backup/restore behavior. |
| [.github/workflows/deploy.yml](file:///C:/Users/rudra/.gemini/antigravity/scratch/rudra-links/.github/workflows/deploy.yml) | GitHub Actions CI/CD workflow (JS validation -> SSH atomic deploy -> HTTP check). | When modifying CI/CD pipeline triggers or steps. |
| [README.md](file:///C:/Users/rudra/.gemini/antigravity/scratch/rudra-links/README.md) | Operations & CI/CD guide (GitHub Secrets, deployment, logs, rollback). | When updating user-facing deployment docs. |

---

## 2. Internal Component & Line-Range Map inside `index.html`

| Component / Section | Line Range | Key Selectors / IDs / Functions |
| :--- | :--- | :--- |
| **Head, Fonts & Offline Mini-Game CSS** | `L1–L40` | `.offline-game`, `#offlineCanvas` |
| **Liquid Glass & Theme Surface CSS** | `L41–L148` | `#liquid-glass-theme`, `.card`, `.row`, `body.modal-open` |
| **Core Layout, CSS Variables & Profile CSS** | `L149–L365` | `:root`, `.banner`, `.avatar`, `.who`, `.sections`, `.row`, `.ic` |
| **UPI Modal & Hanging Lanterns / Clouds CSS** | `L366–L500` | `.upi-overlay`, `.upi-dialog`, `.hangs`, `.bgclouds`, `.night` |
| **Weather App (`#wx`) CSS & Animations** | `L501–L704` | `.wx`, `.wx-phone`, `.wx-hero`, `.wx-sheet`, `.wx-strip`, `.wx-layer` |
| **3D Frosted Glass Icons, VPS (`#vps`) & Bento Widget CSS** | `L705–L1060` | `.vps-row`, `.row .ic`, `.vps-phone`, `.bento-wrap`, `.bento-left`, `.bento-week`, `.bento-wx`, `.bento-vis` |
| **SVG Brand Icon Sprite Sheet** | `L1062–L1085` | `#i-ig`, `#i-sc`, `#i-x`, `#i-wa`, `#i-ml`, `#i-dc`, `#i-sp`, `#i-gh`, `#i-up` |
| **Profile Header, Bio & Offline Runner DOM** | `L1087–L1115` | `#bgclouds`, `#themeToggle`, `#banner`, `#avatar`, `.who p`, `#offlineGame` |
| **Link Sections & Pastel Bento Widget DOM** | `L1116–L1298` | `#upiTrigger`, `#wxTrigger`, `#vpsTrigger`, `#bentoWidget`, `#night` |
| **Script 1: Pixel Banner, Lanterns, HD Mountain Night Canvas & Copy/UPI** | `L1301–L1750` | `frame()`, `loop()`, `nframe()`, `nloop()`, `[data-copy]`, `#upiDialog` |
| **Weather App (`#wx`) & VPS Monitor (`#vps`) DOM** | `L1751–L2035` | `#wx`, `#wxPhone`, `#wxLayer`, `#vps`, `#vpsPhone`, `#vpsLayer`, `#vpsConfigPanel` |
| **Script 2A–2D: Scrollbar, Live Weather (`#wx`), VPS Monitor (`#vps`) & Bento Logic** | `L2036–L3140` | `CITIES`, `NODES`, `openWx()`, `openVps()`, `FESTIVALS`, `#bentoVisCount` |
