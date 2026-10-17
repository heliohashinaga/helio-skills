---
name: parallel-execution-sizing
description: "Use when sizing parallel workers to host capacity."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [sizing, capacity, parallelism, workers, bots, windows, performance]
---

# Parallel Execution Sizing

## When to Use

Sizing parallel bots, workers, agents, or batch jobs to what the host can actually run.

Measure real free capacity first, then set concurrency.

## Procedure

1. **Measure CPU:** logical threads, physical cores, current load. Reserve 2 threads for OS/agent/antivirus; usable workers ≈ threads − 2.
2. **Measure RAM:** total vs free right now. Reserve 2GB for OS; per-worker budget = free-after-reserve / workers. Flag `Memory Compression` in top processes as RAM-pressure signal.
3. **Measure disk:** free GB and % full on the working drive. Below ~15-20GB free (or >90% full) is a blocker for parallel runs — logs, pagefile, and temp need headroom. Report it before tuning anything else.
4. **List top consumers** (`tasklist`, `Get-Process` sorted by WorkingSet) to find reclaimable headroom (browsers, chat apps).
5. **Classify workload:** I/O-bound (API/websocket/requests) tolerates workers > cores; CPU-bound (backtest, indicators, ML) caps at usable cores.
6. **Set concurrency conservatively:** `workers = min(cpu_usable, ram_budget)`; default to 3 on 4C/8T + 8GB machines. Apply via the tool's own config command (e.g. `hermes config set delegation.max_concurrent_children N`), then read back to verify.

## Windows git-bash pitfalls

- Run PowerShell via a script file, not inline `-Command` in double quotes — bash expands `$_, $env:` inside double quotes and corrupts the script. Write a `.ps1` with `write_file`, then `powershell.exe -File C:/path/to/script.ps1` (forward-slash native path).
- `wmic`, `free`, `vmstat` are usually absent in git-bash. Use `systeminfo`, `tasklist`, `nproc`, `cat /proc/meminfo`, `df -h`, `Get-CimInstance Win32_Processor/Win32_PhysicalMemory/Win32_LogicalDisk`, and node `os.cpus()/totalmem()/freemem()` as fallbacks.
- Never hand-edit `config.yaml` (a stray indent breaks the live gateway); use `hermes config set KEY VAL` and verify with `hermes config get KEY`.
