#!/usr/bin/env bash
# Journal resolution: $JOURNAL_FILE env wins, else ./finance.journal (repo root)

# Run all hledger validation checks

# Use --no-conf --file to avoid duplicate reads and config conflicts
# This is the safest approach for automation scripts
CONF_OPTS="--no-conf --file ${JOURNAL_FILE:-finance.journal}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS="${GREEN}✓ PASS${NC}"
FAIL="${RED}✗ FAIL${NC}"
WARN="${YELLOW}⚠ WARN${NC}"

echo "═══════════════════════════════════════════"
echo "  hledger Validation Suite"
echo "═══════════════════════════════════════════"
echo ""

FAILS=0

run_check() {
    local name="$1"
    local cmd="$2"
    echo -n "Checking $name... "
    if eval "$cmd" > /dev/null 2>&1; then
        echo -e "$PASS"
        return 0
    else
        echo -e "$FAIL"
        FAILS=$((FAILS + 1))
        return 1
    fi
}

# Basic checks
echo "--- Basic Checks ---"
run_check "parsable" "hledger $CONF_OPTS check parseable"
run_check "balanced" "hledger $CONF_OPTS check autobalanced"
run_check "assertions" "hledger $CONF_OPTS check assertions"

# Strict checks
echo ""
echo "--- Strict Checks (-s) ---"
run_check "accounts declared" "hledger $CONF_OPTS check -s accounts"
run_check "commodities declared" "hledger $CONF_OPTS check -s commodities"
run_check "explicitly balanced" "hledger $CONF_OPTS check -s balanced"

# Additional checks
echo ""
echo "--- Additional Checks ---"
run_check "ordered dates" "hledger $CONF_OPTS check ordereddates"
run_check "unique leaf names" "hledger $CONF_OPTS check uniqueleafnames"

# Info
echo ""
echo "--- Ledger Statistics ---"
hledger $CONF_OPTS stats

echo ""
echo "═══════════════════════════════════════════"
if [ "$FAILS" -ne 0 ]; then
    echo "  Validation FAILED ($FAILS check(s))"
    echo "═══════════════════════════════════════════"
    exit 1
fi
echo "  Validation complete"
echo "═══════════════════════════════════════════"
