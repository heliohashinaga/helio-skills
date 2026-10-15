#!/usr/bin/env bash
# Journal resolution: $JOURNAL_FILE env wins, else ./finance.journal (repo root)

# Generate a monthly financial report
# Usage: ./monthly-report.sh [YYYY-MM]

MONTH="${1:-$(date +%Y-%m)}"
CONF_OPTS="--no-conf --file ${JOURNAL_FILE:-finance.journal}"

# Determine next month for end date (GNU date; git-bash/MSYS included)
NEXT_MONTH=$(date -d "$MONTH-01 +1 month" +%F)

echo "═══════════════════════════════════════════"
echo "  Monthly Report: $MONTH"
echo "═══════════════════════════════════════════"

echo ""
echo "--- Income Statement ---"
hledger $CONF_OPTS incomestatement -b "$MONTH-01" -e "$NEXT_MONTH"

echo ""
echo "--- Balance Sheet ---"
hledger $CONF_OPTS balancesheet -e "$NEXT_MONTH"

echo ""
echo "--- Cash Flow ---"
hledger $CONF_OPTS cashflow -b "$MONTH-01" -e "$NEXT_MONTH"

echo ""
echo "--- Top Expenses ---"
hledger $CONF_OPTS balance expenses -b "$MONTH-01" -e "$NEXT_MONTH" --row-total --average --sort-amount

echo ""
echo "--- Expense Breakdown by Category ---"
hledger $CONF_OPTS balance expenses -b "$MONTH-01" -e "$NEXT_MONTH" --tree --depth 2

echo ""
echo "--- Revenue Sources ---"
hledger $CONF_OPTS balance revenues income -b "$MONTH-01" -e "$NEXT_MONTH" --tree --depth 2

echo ""
echo "--- Asset Changes ---"
hledger $CONF_OPTS balance assets -b "$MONTH-01" -e "$NEXT_MONTH" --change --tree --depth 2

echo ""
echo "--- Recent Transactions ---"
hledger $CONF_OPTS register -b "$MONTH-01" -e "$NEXT_MONTH"
