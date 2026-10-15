# Command Reference: Reports, Validation, Discovery, Valuation

Read this when you need a command beyond the 5 core ones in SKILL.md.
All commands use `hledger --no-conf --file [JOURNAL_FILE]`.

## Reports

```bash
# Balance sheet (assets, liabilities, net worth)
hledger --no-conf --file [JOURNAL_FILE] balancesheet

# Balance sheet with equity
hledger --no-conf --file [JOURNAL_FILE] balancesheetequity

# Income statement (revenues and expenses)
hledger --no-conf --file [JOURNAL_FILE] incomestatement

# Cash flow (liquid assets)
hledger --no-conf --file [JOURNAL_FILE] cashflow

# General balance report (most flexible)
hledger --no-conf --file [JOURNAL_FILE] balance

# Account register for a specific account
hledger --no-conf --file [JOURNAL_FILE] register assets:bank

# Transaction-oriented register (one line per transaction)
hledger --no-conf --file [JOURNAL_FILE] aregister checking

# Monthly expense breakdown
hledger --no-conf --file [JOURNAL_FILE] balance --monthly expenses

# Weekly balance changes
hledger --no-conf --file [JOURNAL_FILE] balance --weekly assets

# Quarterly income statement
hledger --no-conf --file [JOURNAL_FILE] incomestatement --quarterly
```

## Data integrity & validation

```bash
# Run all default checks (parseable, autobalanced, assertions)
hledger --no-conf --file [JOURNAL_FILE] check

# Strict mode (also checks accounts, commodities, balanced)
hledger --no-conf --file [JOURNAL_FILE] check -s

# Check ordered dates within each file
hledger --no-conf --file [JOURNAL_FILE] check ordereddates

# Check recent assertions (asserted accounts must have assertion within 7 days of latest posting)
hledger --no-conf --file [JOURNAL_FILE] check recentassertions

# Check unique leaf names (no two accounts share the same last part)
hledger --no-conf --file [JOURNAL_FILE] check uniqueleafnames

# Check payees (all payees must be declared)
hledger --no-conf --file [JOURNAL_FILE] check payees

# Check tags (all tags must be declared)
hledger --no-conf --file [JOURNAL_FILE] check tags

# Check specific types
hledger --no-conf --file [JOURNAL_FILE] check accounts commodities
```

## Query & discovery

```bash
# List all accounts
hledger --no-conf --file [JOURNAL_FILE] accounts

# List accounts as tree
hledger --no-conf --file [JOURNAL_FILE] accounts --tree

# List with types
hledger --no-conf --file [JOURNAL_FILE] accounts --types

# List payees
hledger --no-conf --file [JOURNAL_FILE] payees

# List commodities
hledger --no-conf --file [JOURNAL_FILE] commodities

# List tags
hledger --no-conf --file [JOURNAL_FILE] tags

# List descriptions
hledger --no-conf --file [JOURNAL_FILE] descriptions

# Show transactions matching a query
hledger --no-conf --file [JOURNAL_FILE] print desc:"Supermarket"

# Show recent transactions
hledger --no-conf --file [JOURNAL_FILE] print --tail 10

# Show cleared transactions only
hledger --no-conf --file [JOURNAL_FILE] print --cleared

# Show stats
hledger --no-conf --file [JOURNAL_FILE] stats
```

## Valuation & cost reporting

```bash
# Show amounts at cost (using costs recorded in transactions)
hledger --no-conf --file [JOURNAL_FILE] balance -B

# Show market value at period end (-V is shorthand for --value=end)
hledger --no-conf --file [JOURNAL_FILE] balancesheet -V

# Convert to a specific commodity
hledger --no-conf --file [JOURNAL_FILE] balance -X BRL

# Show value on transaction dates
hledger --no-conf --file [JOURNAL_FILE] balance --value=then

# Show current market value
hledger --no-conf --file [JOURNAL_FILE] balance --value=now

# Show value on a specific date
hledger --no-conf --file [JOURNAL_FILE] balance --value=2026-05-01

# Infer market prices from transaction costs
hledger --no-conf --file [JOURNAL_FILE] balancesheet -V --infer-market-prices
```

## Prices

```bash
# Show declared market prices
hledger --no-conf --file [JOURNAL_FILE] prices

# Show with inferred prices from costs
hledger --no-conf --file [JOURNAL_FILE] prices --infer-market-prices

# Show reverse-inferred prices
hledger --no-conf --file [JOURNAL_FILE] prices --show-reverse
```
