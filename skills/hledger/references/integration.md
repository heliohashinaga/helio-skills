# Integration: Data Flow & Quality Gates

Read this when handing data to an advisor skill.

## Data flow

```text
Transactions → hledger (validate) → [DATA LAYER] → analysis
```

This skill guarantees the data layer only. Analysis (reconciliation, net worth,
tax, portfolio) belongs to the caller — do not duplicate analysis workflows here.

## Quality gates (all must pass before analysis)

1. **Basic validation**: `hledger --no-conf --file [JOURNAL_FILE] check`
2. **Strict mode** (declared accounts): `check -s`
3. **Categorized expenses**: `expenses:housing`, `expenses:food`, `expenses:transport`, …
4. **Regular reconciliations**: bank matches, monthly.
5. **Budgets defined** (for budget-comparison): `~ monthly` periodic transactions.

⚠️ **If data is invalid**, downstream skills give incorrect results. Always start
with `hledger check`.
