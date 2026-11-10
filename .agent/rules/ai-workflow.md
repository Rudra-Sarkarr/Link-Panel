---
description: Incremental AI workflow and persistent project context rules for Rudra Sarkar's web project
globs: "**/*"
alwaysApply: true
---

# Incremental AI Development Rules

1. **Read Context First:** Before searching the workspace or reading full files, check `AI_CONTEXT.md` and `PROJECT_INDEX.md`.
2. **Targeted Line-Range Reads:** Never read all of `index.html` at once. Use the line-range table in `PROJECT_INDEX.md` to read only the specific 40–100 lines needed for the task.
3. **Smart File Editing:** Modify `index.html` using targeted `edit_file` blocks, then sync `Rudra_Sarkar.html` (`Copy-Item index.html Rudra_Sarkar.html -Force`).
4. **Change Tracking:** Use `git status` and `git diff --stat` to inspect recent modifications instead of re-reading unchanged files.
5. **Fast Validation:** Validate JavaScript changes with the one-line Node.js script check rather than full-project scans.
