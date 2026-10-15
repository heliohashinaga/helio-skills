# CSV Import

Read this when importing bank/broker CSVs into the journal.

hledger's `import` detects new transactions in CSV files and appends them to the
main journal. It avoids duplicates by tracking the latest date seen in a hidden
`.latest.FILE.csv` file.

**Naming convention:** for `bank.csv`, hledger looks for `bank.csv.rules` in the
same directory. You can also specify a rules file with `--rules-file`.

```bash
# Preview what would be imported (always do this first!)
hledger --no-conf --file [JOURNAL_FILE] import [BANK_NAME].csv --dry-run

# Import with explicit rules file (when rules are in rules/ dir)
hledger --no-conf --file [JOURNAL_FILE] import --rules-file rules/[BANK_NAME].rules [BANK_NAME].csv --dry-run

# Import multiple CSVs
hledger --no-conf --file [JOURNAL_FILE] import *.csv --dry-run

# After verifying, run without --dry-run to actually import
hledger --no-conf --file [JOURNAL_FILE] import [BANK_NAME].csv

# Mark all current records as already imported (creates/updates .latest file)
hledger --no-conf --file [JOURNAL_FILE] import [BANK_NAME].csv --catchup
```

You can also read CSV directly:

```bash
# Preview CSV as journal entries
hledger --no-conf --file [JOURNAL_FILE] -f [BANK_NAME].csv print

# Balance from CSV
hledger --no-conf --file [JOURNAL_FILE] -f [BANK_NAME].csv balance
```

Or use the helper script (dry-run preview, then manual confirm; `--yes` skips the prompt):

```bash
./scripts/import-csv.sh [--yes] <csv-file> [<rules-file>]
```

Gate: import is done when `hledger check` passes after the import and the new
transactions appear in `print --tail`.
