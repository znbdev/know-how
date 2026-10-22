# macOS & Windows Disk & System Maintenance Toolkit

Read-only or confirm-before-delete shell scripts for disk usage analysis, system
health checks and safe cleanup. No sudo/admin is required for the default flows,
and personal files are never touched.

## Scripts

| Script | Platforms | Purpose | Safety level |
|--------|-----------|---------|--------------|
| `disk-overview.sh` / `.ps1` | macOS / Windows | Quick disk usage overview | Read-only |
| `disk-full-report.sh` / `.ps1` | macOS / Windows | Full disk scan → Markdown report | Read-only |
| `disk-timeline.sh` / `.ps1` | macOS / Windows | Find what grew the disk recently, by time | Read-only |
| `smart-clean.sh` / `.ps1` | macOS / Windows | Interactive cleanup (safe / review groups) | Confirm before delete |
| `sys-health-check.sh` / `.ps1` | macOS / Linux / Windows | Health checks + L1 safe cleanup | Dry run by default |

Directory layout:

```
toolkit-en/
├── mac/        # Bash scripts for macOS (Linux support in sys-health-check)
├── windows/    # PowerShell scripts for Windows
└── README.md
```

---

## disk-overview — quick disk usage

**macOS**

```bash
bash mac/disk-overview.sh           # volume usage + top home directories
bash mac/disk-overview.sh --top     # also scan top-level system directories
bash mac/disk-overview.sh --deep    # also show large dev/cache directories
```

**Windows** (if execution policy blocks scripts, first run
`Set-ExecutionPolicy -Scope Process Bypass`)

```powershell
.\windows\disk-overview.ps1         # volume usage + top home directories
.\windows\disk-overview.ps1 -Top    # also scan top-level system directories
.\windows\disk-overview.ps1 -Deep   # also show large dev/cache directories
```

- Colored usage percentages / progress bars (green / yellow / red)
- Read-only, deletes nothing

---

## disk-full-report — full scan report

Generates a Markdown report containing:

- Volume overview
- Largest home directory subdirectories
- Dev & cache directories (macOS Library / Windows AppData)
- Large files (>200MB)
- Browser caches (Windows)
- Cleanup suggestions with reclaimable estimates

```bash
bash mac/disk-full-report.sh                    # writes disk-report-YYYY-MM-DD.md
bash mac/disk-full-report.sh /path/to/out.md    # custom output path
```

```powershell
.\windows\disk-full-report.ps1                              # same default output
.\windows\disk-full-report.ps1 -OutputPath C:\reports\d.md  # custom output path
```

- Read-only, only writes the report file

---

## disk-timeline — what grew my disk recently?

Finds large files modified inside a time window, grouped into
"last 24 hours" and "2 ~ N days ago", so you can see what filled the disk.

```bash
bash mac/disk-timeline.sh              # default: last 3 days, files >= 50M
bash mac/disk-timeline.sh --days 7     # widen the window
bash mac/disk-timeline.sh --min 10M    # lower the size threshold
bash mac/disk-timeline.sh --dirs       # aggregate by directory
bash mac/disk-timeline.sh --all        # files + directories
```

```powershell
.\windows\disk-timeline.ps1                 # default: last 3 days, files >= 50MB
.\windows\disk-timeline.ps1 -Days 7         # widen the window
.\windows\disk-timeline.ps1 -MinSize 10MB   # lower the size threshold
.\windows\disk-timeline.ps1 -Dirs           # aggregate by directory
.\windows\disk-timeline.ps1 -All            # files + directories
```

- macOS uses the Spotlight index (`mdfind`) for second-level queries, with a
  `find` fallback when Spotlight is unavailable
- Windows walks curated roots (AppData, Downloads, dev folders, Program Files)
- Starts with a quick check of common growth sources, then lists concrete files
- Read-only, deletes nothing

---

## smart-clean — interactive cleanup

Scan results are grouped into:

- **[SAFE]** regenerable caches / temp files / dumps — no risk
- **[REVIEW]** may contain user data or be in use — needs confirmation

```bash
bash mac/smart-clean.sh --list    # list only, delete nothing
bash mac/smart-clean.sh           # interactive confirmation (default)
bash mac/smart-clean.sh --yes     # auto-delete [SAFE], still ask for [REVIEW]
```

```powershell
.\windows\smart-clean.ps1 -List  # list only, delete nothing
.\windows\smart-clean.ps1        # interactive confirmation (default)
.\windows\smart-clean.ps1 -Yes   # auto-delete [SAFE], still ask for [REVIEW]
```

Covered items:

| macOS | Windows |
|-------|---------|
| `~/Library/Caches`, `~/Library/Logs` | `Temp`, `Windows\Temp`, crash dumps |
| npm / pip / Homebrew caches | npm / pip / Yarn / pnpm / NuGet caches |
| Xcode DerivedData, simulator caches | Chrome / Edge caches |
| Trash (confirmed via prompt) | Recycle Bin (confirmed via prompt) |
| Oversized global npm packages, node_modules > 500MB | node_modules > 500MB |
| Downloads files > 200MB, home files > 1GB | Downloads/Desktop files > 200MB |

[REVIEW] also covers Ollama / HuggingFace model caches.

---

## sys-health-check — health check + safe cleanup

**Checks (L0, read-only):** CPU / memory / disk / network / startup items

```bash
bash mac/sys-health-check.sh                  # check + cleanup dry run (default)
bash mac/sys-health-check.sh --check          # checks only
bash mac/sys-health-check.sh --optimize       # cleanup preview only
bash mac/sys-health-check.sh --optimize --execute  # actually delete
```

```powershell
.\windows\sys-health-check.ps1                     # check + cleanup dry run (default)
.\windows\sys-health-check.ps1 -Check              # checks only
.\windows\sys-health-check.ps1 -Optimize           # cleanup preview only
.\windows\sys-health-check.ps1 -Optimize -Execute  # actually delete
```

Startup items covered:

- **macOS**: LaunchAgents, LaunchDaemons, login items
- **Linux**: systemd enabled units, `~/.config/autostart`, shell rc files
- **Windows**: Startup folders, registry Run keys, non-Microsoft scheduled tasks

Safety promises:

- Never uses sudo/admin for the cleanup paths it runs
- Never touches system directories
- Never touches personal files (Desktop / Documents / Downloads / Pictures / Videos)
- Never empties the Trash / Recycle Bin (irreversible — left to the user)
- Only deletes regenerable caches, logs and temporary files
- Dry run by default; `-Execute` / `--execute` is required to actually delete

---

## Which script should I use?

| Situation | Recommended script |
|-----------|--------------------|
| Quick look at free space | `disk-overview` |
| Monthly full health report | `disk-full-report` |
| Disk suddenly full, find the cause | `disk-timeline` |
| Routine cache cleanup | `smart-clean` |
| System feels slow, full check-up | `sys-health-check` |
