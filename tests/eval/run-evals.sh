#!/bin/bash
# Haunt Evaluation Runner
# Runs golden task scenarios and reports pass/fail
# Usage: bash Haunt/tests/eval/run-evals.sh [scenario-name]

set -euo pipefail

EVAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}PASS${NC} $1"; }
fail() { echo -e "${RED}FAIL${NC} $1"; }
header() { echo -e "\n${YELLOW}===${NC} $1 ${YELLOW}===${NC}"; }

FILTER="${1:-}"
PASS_COUNT=0
FAIL_COUNT=0

header "Haunt Eval Runner"
echo "Eval directory: $EVAL_DIR"
[[ -n "$FILTER" ]] && echo "Filter: $FILTER"
echo ""

# Find all scenario scripts (sort for deterministic order)
# Use while+read for bash 3 compatibility (macOS default)
SCENARIO_LIST=$(find "$EVAL_DIR" -name "scenario-*.sh" | sort)

if [[ -z "$SCENARIO_LIST" ]]; then
    echo "No scenario scripts found in $EVAL_DIR"
    exit 1
fi

while IFS= read -r SCENARIO; do
    SCENARIO_NAME="$(basename "$SCENARIO" .sh)"

    # Apply filter if provided
    if [[ -n "$FILTER" && "$SCENARIO_NAME" != *"$FILTER"* ]]; then
        continue
    fi

    # Run scenario, capture exit code separately from output
    set +e
    bash "$SCENARIO" 2>&1 | sed "s/^/  /"
    SCENARIO_EXIT=${PIPESTATUS[0]}
    set -e

    if [[ $SCENARIO_EXIT -eq 0 ]]; then
        pass "$SCENARIO_NAME"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        fail "$SCENARIO_NAME"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
done <<< "$SCENARIO_LIST"

TOTAL=$((PASS_COUNT + FAIL_COUNT))

echo ""
header "Results"
echo "Total:  $TOTAL"
echo -e "Passed: ${GREEN}${PASS_COUNT}${NC}"
echo -e "Failed: ${RED}${FAIL_COUNT}${NC}"
echo ""

if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "${RED}FAILED${NC} ($FAIL_COUNT scenario(s) failed)"
    exit 1
else
    echo -e "${GREEN}ALL PASSED${NC}"
    exit 0
fi
