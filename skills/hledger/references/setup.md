# Setup & Project Structure

Read this when creating a new hledger project or onboarding a new advisor skill.

## Prerequisites checklist

- [ ] Journal file created (`journal/[YEAR].journal`)
- [ ] hledger.conf with display options (NO `--file` — see `config.md`)
- [ ] `hledger check` passes successfully
- [ ] Accounts declared and organized by type (assets, liabilities, income, expenses)

Extended (as needed):

- Expense accounts categorized (`expenses:housing`, `expenses:food`, …); bank reconciliation set up and updated.
- Assets/liabilities tracked consistently; monthly budget as periodic transactions (`~ monthly`).
- Capital gains/losses in separate accounts; cost basis per investment position.

## Budget setup (periodic transactions)

```journal
~ monthly
  expenses:housing     1500
  expenses:food        1000
  expenses:transport    300
  expenses:utilities    150
  expenses:health       200
```

Keep categories consistent with `expenses:*` account names; review monthly; adjust as expenses change.

## Project structure

```text
your-project/
├── [MAIN_JOURNAL].journal       # Main journal (entry point, includes sub-journals)
├── hledger.conf                 # hledger configuration file
├── journal/
│   ├── [YEAR].journal           # Transactions for the current year
│   └── opening-balances.journal # Opening balances
├── prices/
│   └── prices.journal           # Commodity prices (optional)
└── rules/
    ├── [BANK_NAME].rules        # Bank CSV import rules (optional)
    └── [BROKER_NAME].rules      # Broker CSV import rules (optional)
```

> **Note**: Your project structure may differ. Customize paths and names as needed.
