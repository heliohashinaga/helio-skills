---
name: hledger
description: hledger CLI (hledger 1.40+) for personal/SMB finance journals. Use for journal setup, CSV imports, transaction entry, reports, and validation checks. Data-integrity gate: always validate before analysis.
---

# hledger Skill

**Data layer** for hledger accounting projects (hledger 1.40+): validate here
first, analyze after. If advisor skills are present (accounting, financial, tax,
investment), hand validated data to them.

## Quick start

One rule: **never put `--file` in `hledger.conf`** (it double-reads the journal —
see `references/config.md`). Always call:

```bash
hledger --no-conf --file [JOURNAL_FILE] <command>
```

Five core commands:

```bash
hledger --no-conf --file [JOURNAL_FILE] check              # validate (gate for everything)
hledger --no-conf --file [JOURNAL_FILE] balance expenses  # where money went
hledger --no-conf --file [JOURNAL_FILE] balancesheet      # net worth
hledger --no-conf --file [JOURNAL_FILE] incomestatement -p "this month"
hledger --no-conf --file [JOURNAL_FILE] print --tail 10    # recent transactions
```

## Workflows

### 1. Validate (gate for every task)

```bash
hledger --no-conf --file [JOURNAL_FILE] check
```

Gate: exit 0 with no errors before any analysis, import, or handoff. If it fails,
fix the journal first — downstream skills give wrong results on invalid data.
Strict mode (`check -s`) when accounts/commodities must be declared.

### 2. Import CSV

```bash
hledger --no-conf --file [JOURNAL_FILE] import [BANK].csv --dry-run   # preview first, always
hledger --no-conf --file [JOURNAL_FILE] import [BANK].csv             # after verifying
hledger --no-conf --file [JOURNAL_FILE] check                         # validate after
```

Gate: `check` passes and new transactions appear in `print --tail`.
Details (rules files, catchup, multi-CSV): `references/import.md`.
Scripted path: `./scripts/import-csv.sh <csv> [<rules>]`.

### 3. Add a transaction

Append to `journal/[YEAR].journal`, then `check`. Format and tags:

```journal
2026-05-14 * Supermarket X
    expenses:food:groceries          [AMOUNT] [CURRENCY]
    assets:bank:[BANK_NAME]
```

Gate: `check` passes after the edit. Full format, tags, and balance assertions:
`references/journal.md`.

## Scripts

```bash
./scripts/validate.sh                 # all validation checks
./scripts/import-csv.sh [--yes] <csv> [<rules>]  # dry-run preview, then manual confirm
./scripts/monthly-report.sh [YYYY-MM]    # income statement, balance sheet, cash flow, top expenses
```

## References

- `references/setup.md` — read when creating a project or onboarding an advisor (checklist, budgets, layout).
- `references/config.md` — read when balances look doubled or setting up `hledger.conf`.
- `references/commands.md` — read when you need reports, validation variants, discovery, valuation, or prices beyond the core 5.
- `references/import.md` — read for CSV import details.
- `references/journal.md` — read for journal format, tags, assertions.
- `references/queries.md` — read for filtering, periods, and machine output (csv/json/html).
- `references/troubleshooting.md` — read when any command misbehaves (retry with `--no-conf` first).
- `references/integration.md` — read when handing data to analysis (data flow + quality gates).
