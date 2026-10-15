# Troubleshooting

Read this when a command misbehaves. First step for anything odd: retry with
`--no-conf` to rule out config effects.

## Balances doubled or duplicated

**Symptom**: `balance` shows 2x values or duplicate account entries.

**Root cause**: `--file` is defined in both `hledger.conf` AND the command line —
hledger reads the journal **TWICE**.

**Fix**:

```bash
grep "--file" hledger.conf
# If this returns anything, edit hledger.conf and remove the --file line
```

Good `hledger.conf` (display options only — NO `--file`):

```conf
--pretty-tables
--decimal-mark .
--commodity-style "$1,000.00"
--width 100
```

Then always specify the file on the command line:

```bash
hledger --conf hledger.conf --file [JOURNAL_FILE] balance
# OR
hledger --no-conf --file [JOURNAL_FILE] balance
```

Verify: `hledger --no-conf --file [JOURNAL_FILE] balance <an-account>` shows a
single value, not doubled.

**Prevention**: use `--no-conf --file` in all scripts.

## Import doesn't find my CSV

1. Check file exists: `ls -la bank.csv`
2. Check working directory: `pwd`
3. Use full path: `hledger --no-conf --file [JOURNAL_FILE] import /path/to/bank.csv --dry-run`
4. Check hledger.conf is using the right directory

## Commands slow or hanging

- Large journal (1000+ transactions), recursive lookups, or market-value math.
- Try `--depth 2`, `-E` (exclude empty accounts), `--no-conf`.
- Check for circular account references.
