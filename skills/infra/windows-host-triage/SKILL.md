---
name: windows-host-triage
description: "Use when triaging Windows RAM, disk, or app leftovers."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [windows]
metadata:
  hermes:
    tags: [windows, performance, ram, disk, triage, powershell, git-bash]
    related_skills: [systematic-debugging]
---

# Windows Host Triage

## Overview

Evidence before advice. For "is X enough / what is consuming / how to speed up" on a Windows host driven via git-bash/MSYS: collect RAM top-consumers, disk free space, and largest folders first, then recommend. Guessing without numbers is the failure mode.

## When to Use

Use when the user asks whether RAM/SSD is enough, what is consuming RAM or disk, or how to speed up a Windows notebook — any host-performance triage from the terminal. Also use when asked to evaluate removing files, config dirs, or packages left behind by a tool that is "no longer installed".

## Procedure

### 1. Identify the host

```powershell
powershell.exe -Command "Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,TotalPhysicalMemory; Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors"
```

### 2. RAM: top consumers

```powershell
powershell.exe -Command "Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 15 Name, @{N='RAM_MB';E={[math]::Round($_.WorkingSet64/1MB)}}, Id | Format-Table -AutoSize"
```

Aggregate multi-process apps before reporting (Edge, Electron apps, Python backends each spawn several processes — sum them, do not read out raw PIDs).

### 3. Disk: free space then largest folders

```powershell
powershell.exe -Command "Get-PSDrive C | Select-Object Used,Free, @{N='UsedGB';E={[math]::Round($_.Used/1GB,1)}}, @{N='FreeGB';E={[math]::Round($_.Free/1GB,1)}}"
```

Then size suspect folders ONE at a time with `du -s "<dir>"` (repos, scoop, .cache, Program Files, Program Files (x86), ProgramData). Report in GB with one line on what lives inside the biggest ones (list the top level via the terminal).

### 4. Leftovers from uninstalled tools

Package managers and uninstallers leave three kinds of weight behind. When the
user says a tool "is no longer installed", sweep all three — the config path
they named is usually the smallest part:

- **Broken launcher shims.** `shutil.which('<tool>')` / `where <tool>` proves
  only that a launcher FILE exists. Run each suspect launcher (`<tool>
  --version`); a shim that dies with `Cannot find module '<pkg>'` means the
  package is gone and only the launcher survives. Check EVERY shim in the bin
  dir, not just the named one — tools get uninstalled in generations, so
  several are usually dead at once.
- **Orphaned platform packages.** Bun/npm keep per-platform builds in the
  global store (`~/.bun/install/global/node_modules`,
  `<node>/lib/node_modules`). Grep that one directory for the dead tool's name
  and size each hit; a single tool's `-windows-x64` builds routinely weigh
  hundreds of MB, and they are invisible from the config dir the user pointed
  at. Before deleting an orphan, confirm nothing live declares it: read the
  `package.json` of every tool that still works and check its `dependencies` —
  one global store serves all of them, so a dead shim proves only that the
  shim's own target is gone, never that the package is unreferenced.
- **Surviving config dirs.** `~/.config/<tool>`, `~/.<tool>`, `$APPDATA/<tool>`
  outlive the uninstall — and so do the XDG trio `~/.local/share/<tool>` (auth
  tokens, session DBs, repo snapshots), `~/.local/state/<tool>`, and
  `~/.cache/<tool>` (downloaded binaries); sweep all of them by name, since the
  config dir the user named is routinely a few MB while the trio holds the real
  hundreds. INVENTORY before proposing removal: these often hold
  user-authored content (custom agents, rules, skills, session DBs) worth
  migrating first, and a file named `tokens.json` may hold only a schema
  version. Archive to a sibling path (e.g. `~/.config-REMOVED-<date>/`) and let
  the user review, rather than hard-deleting.

### 5. Recommend in priority order

1. Disk free space if C: is above ~90% (blocks paging, updates, caches) — safe targets first: Disk Cleanup (Windows Update + error reports), unused Steam games, `scoop cache rm *`, rebuildable `node_modules`/`bin`/`obj`/`.venv`.
2. RAM relief: sleeping tabs, close heavy desktop apps, set rarely-used services (SQL Server, IIS Express) to manual.
3. Hardware: RAM upgrade / larger SSD only after 1–2.

End by offering to run the safe cleanup step and measure the result.

## Pitfalls

- Never run one recursive `du` over the whole home, AppData, or ProgramData — the file count makes it time out and floods permission-denied noise; scope to a single suspect folder per command with a bounded timeout.
- Prefer PowerShell CIM cmdlets (`Get-CimInstance`, `Get-Process`, `Get-PSDrive`) over `wmic`/`free`, which are absent on current hosts — check the working equivalent first instead of retrying the missing binary.
- Pass native tools `C:/...` forward-slash paths under git-bash/MSYS, never bare `/c/...` or `/tmp`, since path conversion is disabled for native programs.
- Verify before destructive action: list plus `du -s` the exact folder, then `rm -rf` only that path, then re-list the parent to confirm it is gone.
- A launcher's presence is not installation evidence — run it before reporting a tool as installed, or its config dir as live. The shim's `Cannot find module` error both proves the tool is gone and names the package, which is what makes the leftovers safe to sweep.
- Config dirs and orphan packages are separate finds: discovering one does not mean you have found the weight. Size the tool's store directory by name too, or the recommendation quotes a few MB when the real cost was hundreds.
- Distinguish app-cache from user content inside a config dir before calling it safe to delete (agents, rules, custom skills, and session DBs are authored artifacts). Ask before deleting anything with authorial content; deleting a config dir nobody approved is unrecoverable and the user reviews removals in batches.
- Deleting a leftover can trip on read-only files: a cached or snapshot dir
  often contains its own git repository, git object files carry the read-only
  attribute, and `rmtree` then aborts partway with
  `PermissionError [WinError 5]`. Pass a `rmtree` error handler that
  `os.chmod(path, stat.S_IWRITE)` and retries the call, or fall back to
  `attrib -r -s -h /s /d "<path>"` then `rmdir /s /q "<path>"`. Re-check the
  path afterwards — a partial `rmtree` leaves it present while freeing most of
  the bytes, so quote the size measured before the attempt, not a stale number.
- Before reporting a tool's artifacts gone, grep the live app config for the
  name: an uninstalled CLI and an active service frequently share one. A model
  provider or API gateway keeps its credential in the app's own env file, not
  in the app-data dirs you removed, so the removal never touched it — verify
  that and say so plainly, rather than leaving the user to fear their running
  setup was collateral.
