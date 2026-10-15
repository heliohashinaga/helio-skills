# Journal Format: Transactions, Tags, Assertions

Read this when adding transactions by hand or setting up balance assertions.

## Adding transactions

Append to `journal/[YEAR].journal` (or the appropriate year file).

Format:

```journal
YYYY-MM-DD [STATUS] [(CODE)] DESCRIPTION
    ACCOUNT       AMOUNT COMMODITY
    ACCOUNT
```

- **STATUS**: `*` cleared (confirmed), `!` pending. Optional.
- **CODE**: optional transaction ID in parentheses, e.g. `(12345)`.
- **DESCRIPTION**: can include `PAYEE | NOTE` separated by pipe.
- At least two spaces between account name and amount.
- One posting can omit the amount (inferred to balance the transaction).

Example:

```journal
2026-05-14 * Supermarket X
    expenses:food:groceries          [AMOUNT] [CURRENCY]
    assets:bank:[BANK_NAME]

2026-05-14 ! Monthly rent
    expenses:home:rent             [AMOUNT] [CURRENCY]
    assets:bank:[BANK_NAME]

2026-05-15 (INV-001) Freelance payment
    assets:bank:[BANK_NAME]               [AMOUNT] [CURRENCY]
    income:freelance
```

After adding transactions, always validate:

```bash
hledger --no-conf --file [JOURNAL_FILE] check
```

## Tags

Tags annotate transactions/postings: `; tag:value` after a semicolon.

```journal
2026-06-01 * Purchase
    expenses:food               [AMOUNT] [CURRENCY]    ; tag:groceries
    assets:bank:[BANK_NAME]                     ; tag:budget:monthly
```

Filter reports with `tag:key:value` or `tag:key`. Useful for projects and budgets.

Journal rules: the pipe `|` in descriptions separates payee from note
(`PAYEE | NOTE`); two or more spaces are required between account and amount.

## Balance assertions

```journal
2026-05-15 * Reconcile checking
    assets:bank:[BANK_NAME]           = [AMOUNT] [CURRENCY]
    equity:reconciliation
```

Types:

- `= BALANCE` — single commodity, excludes subaccounts
- `=* BALANCE` — single commodity, includes subaccounts
- `== BALANCE` — multi-commodity, excludes subaccounts
- `==* BALANCE` — multi-commodity, includes subaccounts
