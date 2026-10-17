---
name: windows-app-triage
description: "Use when a Windows app is missing from the apps list."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [windows]
metadata:
  hermes:
    tags: [windows, installed-apps, msi, triage, powershell, git-bash]
    related_skills: [windows-host-triage, systematic-debugging]
---

# Windows App Triage

## Overview

Ground truth before reinstall. When a user says an app "is not in the list" or "disappeared", determine whether it is installed, hidden, or really gone — then launch or repair it. Reinstalling without checking wastes time and can orphan per-user data.

## When to Use

Use when a Windows desktop app is reported missing from Settings > Installed apps, Start search, or the expected folder — any "app not found / not listed" triage from the terminal.

## Procedure

### 1. Establish ground truth with PowerShell (not the Settings UI)

```powershell
powershell -NoProfile -Command "Get-Package *<name>*"
```

```powershell
powershell -NoProfile -Command "Get-StartApps | Select-String <name>"
```

A package result means the MSI/provider still considers it installed even if the Settings list hides it. A StartApps hit means Start search should find it.

### 2. Locate the executable

Check per-user install locations BEFORE Program Files — per-user MSIs land outside Program Files:

- `C:/Users/<user>/AppData/Local/Programs/<Vendor>/` (most common for per-user installs)
- `C:/Users/<user>/AppData/Local/<Vendor>/` (often data/logs only, no exe)
- `C:/Program Files/` and `C:/Program Files (x86)/` (per-machine installs)
- Start Menu lnk: `C:/Users/<user>/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/`

### 3. Check for intentional hiding (SystemComponent)

An MSI installed with `ARPSYSTEMCOMPONENT=1` sets `SystemComponent=0x1` on its `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{<ProductCode>}` entry and is hidden from Settings > Installed apps BY DESIGN. Confirm with:

```
reg query "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" | grep -i <name>
reg query "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\{<ProductCode>}"
```

Unhide (requires admin) only if the user wants it listed:

```
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{<ProductCode>}" /v SystemComponent /t REG_DWORD /d 0 /f
```

### 4. Prove recent execution from app logs

Per-user apps log under `C:/Users/<user>/AppData/Local/<Vendor>/.../Logs/App-<date>.log`. A same-day log with version banner plus sync/session lines proves the app is installed AND was running — report that instead of reinstalling. Also check `tasklist` for the exe and for stale `<App> Setup` updater processes.

### 5. Report and offer the minimal fix

Report: installed version, exe path, Start entry present/absent, hidden-vs-gone verdict. Offer the smallest next step: launch via Start/exe path, kill a stuck updater, unhide the registry flag, or reinstall from the vendor URL only if the exe is truly absent.

## Pitfalls

- Absence from Settings > Installed apps does NOT mean uninstalled — check `Get-Package` and the `SystemComponent` flag before recommending a reinstall, or you will orphan the user's data and duplicate the install.
- Never scope an exe search to Program Files alone — per-user installs live under `%LocalAppData%/Programs` and the `%LocalAppData%/<Vendor>` tree is usually data/logs with no exe; searching only one of them gives a false "gone" verdict.
- Quote `reg query` key paths in double quotes because product-code braces break the parser; query the Uninstall folder and grep first when the exact GUID is unknown rather than guessing the full key.
- Avoid PowerShell `foreach($x ...)` one-liners through git-bash/MSYS — `$`-variables get eaten by bash and produce parser errors; prefer `reg query` plus grep, or write the loop to a `.ps1` file and invoke it.
