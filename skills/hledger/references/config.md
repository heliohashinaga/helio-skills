# Config File Usage

Read this when balances look wrong or when setting up `hledger.conf`.

## ⚠️ CRITICAL: avoid double-read errors

Do NOT place `--file` inside `hledger.conf`. If both are present and conflicting,
hledger reads your journal file **TWICE**, causing all account balances to duplicate.

```bash
# ❌ BAD - Causes duplicate reads
# hledger.conf contains: --file [JOURNAL_FILE]
hledger --no-conf --file [JOURNAL_FILE] balance
# Result: [JOURNAL_FILE] read TWICE → all values doubled!

# ✅ GOOD - hledger.conf with display options only
# hledger.conf contains: --pretty-tables, --width 100, etc. (NO --file)
hledger --no-conf --file [JOURNAL_FILE] balance
# Result: [JOURNAL_FILE] read ONCE → correct values

# ✅ GOOD - No config, explicit file
hledger --no-conf --file [JOURNAL_FILE] balance
# Result: [JOURNAL_FILE] read ONCE → correct values
```

**Recommended hledger.conf structure**:

```conf
# hledger.conf - Display and behavior options ONLY
# NOTE: Do NOT include --file here!

--pretty-tables           # Better table formatting
--decimal-mark .          # Decimal separator
--commodity-style "$1,000.00"  # Currency display
--width 100              # Output width in characters
```

Then use:

```bash
hledger --no-conf --file [JOURNAL_FILE] <command>
```

**For automation scripts**, always use `--no-conf --file` — it avoids config
file side effects completely. If a command behaves unexpectedly, retry with
`-n` (`--no-conf`) to rule out config effects.
