# Filtering, Queries & Output Formats

Read this when a report needs slicing (period, account, tag) or machine output.

Most commands accept [QUERY] arguments:

```bash
# By account name (regex, case insensitive)
hledger --no-conf --file [JOURNAL_FILE] balance expenses:food

# By description
hledger --no-conf --file [JOURNAL_FILE] print desc:amazon

# By payee (left of | in description)
hledger --no-conf --file [JOURNAL_FILE] print payee:"Gas Station"

# By date range
hledger --no-conf --file [JOURNAL_FILE] register -b 2026-01-01 -e 2026-04-01
hledger --no-conf --file [JOURNAL_FILE] balance date:2026-01-01..2026-03-31

# By period expression
hledger --no-conf --file [JOURNAL_FILE] incomestatement -p "this month"
hledger --no-conf --file [JOURNAL_FILE] balance -p "monthly in 2026"

# By status
hledger --no-conf --file [JOURNAL_FILE] balance status:*       # cleared only
hledger --no-conf --file [JOURNAL_FILE] balance status:!       # pending only

# By commodity
hledger --no-conf --file [JOURNAL_FILE] balance cur:BRL
hledger --no-conf --file [JOURNAL_FILE] balance cur:\$          # for $

# By tag
hledger --no-conf --file [JOURNAL_FILE] balance tag:trip
hledger --no-conf --file [JOURNAL_FILE] balance tag:trip=paris

# Exclude with not:
hledger --no-conf --file [JOURNAL_FILE] balance not:equity

# Boolean queries
hledger --no-conf --file [JOURNAL_FILE] print expr:'expenses AND (food OR rent)'

# Depth limit
hledger --no-conf --file [JOURNAL_FILE] balance --depth 2
hledger --no-conf --file [JOURNAL_FILE] balance -2              # shorthand

# Real postings only (exclude virtual)
hledger --no-conf --file [JOURNAL_FILE] balance --real
```

## Output formats

```bash
# CSV output
hledger --no-conf --file [JOURNAL_FILE] print -O csv

# JSON output
hledger --no-conf --file [JOURNAL_FILE] balance -O json

# HTML output
hledger --no-conf --file [JOURNAL_FILE] balancesheet -o report.html

# Write to file (format inferred from extension)
hledger --no-conf --file [JOURNAL_FILE] balance -o balances.csv
```

Supported formats vary by command: txt, csv, tsv, json, html, fods, beancount, sql.

Display shortcuts: `--pretty` (tables), `--depth N` (summaries), `-S`/`--sort-amount`
(flat mode), `-E`/`--empty` (zero accounts), `-R`/`--real` (exclude virtual).
hledger accepts unambiguous flag prefixes: `--dry` for `--dry-run`, `-M` for `--monthly`.
