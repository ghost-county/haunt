#!/bin/bash
#
# test-haunt-metrics.sh - Unit tests for haunt-metrics.sh parsing functions
#
# Usage: bash tests/test-haunt-metrics.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
test_pass() {
    local test_name="$1"
    ((TESTS_RUN++))
    ((TESTS_PASSED++))
    echo -e "${GREEN}✓${NC} $test_name"
}

test_fail() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    ((TESTS_RUN++))
    ((TESTS_FAILED++))
    echo -e "${RED}✗${NC} $test_name"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
}

# Test helper functions (duplicated from haunt-metrics.sh for testing)
get_effort_estimate() {
    local metadata="$1"
    # Match **Effort:** field and capture ONLY the first size value
    # Use sed to extract the value after **Effort:** and before any other text
    local result=$(echo "$metadata" | grep "\*\*Effort:\*\*" | sed -n 's/.*\*\*Effort:\*\* *\([A-Z]*\).*/\1/p' | head -1)
    if [ -z "$result" ]; then
        echo "UNKNOWN"
    else
        echo "$result"
    fi
}

get_status() {
    local metadata="$1"

    # Try to extract from header line (### {🟢} REQ-XXX)
    local header=$(echo "$metadata" | head -1)

    if echo "$header" | grep -q "🟢"; then
        echo "🟢"
        return 0
    elif echo "$header" | grep -q "🟡"; then
        echo "🟡"
        return 0
    elif echo "$header" | grep -q "🔴"; then
        echo "🔴"
        return 0
    elif echo "$header" | grep -q "⚪"; then
        echo "⚪"
        return 0
    fi

    # Fallback: check for status in metadata
    if echo "$metadata" | grep -q "Status.*Complete"; then
        echo "🟢"
    elif echo "$metadata" | grep -q "Status.*In Progress"; then
        echo "🟡"
    elif echo "$metadata" | grep -q "Status.*Blocked"; then
        echo "🔴"
    else
        echo "⚪"
    fi
}

get_expected_hours() {
    local effort="$1"

    case "$effort" in
        XS) echo "1" ;;
        S)  echo "2" ;;
        M)  echo "4" ;;
        *)  echo "N/A" ;;
    esac
}

echo "═══════════════════════════════════════════"
echo "  Haunt Metrics - Unit Tests"
echo "═══════════════════════════════════════════"
echo ""

# Test 1: get_effort_estimate - Standard format
echo "Testing get_effort_estimate()..."
metadata="**Effort:** S (1-2 hours)"
result=$(get_effort_estimate "$metadata")
if [ "$result" = "S" ]; then
    test_pass "get_effort_estimate - Standard S"
else
    test_fail "get_effort_estimate - Standard S" "S" "$result"
fi

# Test 2: get_effort_estimate - M format
metadata="**Effort:** M (2-4 hours)"
result=$(get_effort_estimate "$metadata")
if [ "$result" = "M" ]; then
    test_pass "get_effort_estimate - Standard M"
else
    test_fail "get_effort_estimate - Standard M" "M" "$result"
fi

# Test 3: get_effort_estimate - XS format
metadata="**Effort:** XS (30min-1hr)"
result=$(get_effort_estimate "$metadata")
if [ "$result" = "XS" ]; then
    test_pass "get_effort_estimate - Standard XS"
else
    test_fail "get_effort_estimate - Standard XS" "XS" "$result"
fi

# Test 4: get_effort_estimate - SPLIT format
metadata="**Effort:** SPLIT (>4 hours)"
result=$(get_effort_estimate "$metadata")
if [ "$result" = "SPLIT" ]; then
    test_pass "get_effort_estimate - Standard SPLIT"
else
    test_fail "get_effort_estimate - Standard SPLIT" "SPLIT" "$result"
fi

# Test 5: get_effort_estimate - Should NOT capture S from Agent field
metadata="**Agent:** Dev-Infrastructure
**Effort:** M (2-4 hours)"
result=$(get_effort_estimate "$metadata")
if [ "$result" = "M" ]; then
    test_pass "get_effort_estimate - Ignores Agent field S"
else
    test_fail "get_effort_estimate - Ignores Agent field S" "M" "$result"
fi

# Test 6: get_effort_estimate - Multi-line metadata with Agent before Effort
metadata="### 🟡 REQ-311: Test
**Type:** Bug Fix
**Agent:** Research-Analyst
**Effort:** S (1-2 hours)
**Complexity:** SIMPLE"
result=$(get_effort_estimate "$metadata")
if [ "$result" = "S" ]; then
    test_pass "get_effort_estimate - Multi-line with Agent before Effort"
else
    test_fail "get_effort_estimate - Multi-line with Agent before Effort" "S" "$result"
fi

# Test 7: get_effort_estimate - No effort field
metadata="**Type:** Bug Fix
**Agent:** Dev"
result=$(get_effort_estimate "$metadata")
if [ "$result" = "UNKNOWN" ]; then
    test_pass "get_effort_estimate - Missing Effort field returns UNKNOWN"
else
    test_fail "get_effort_estimate - Missing Effort field returns UNKNOWN" "UNKNOWN" "$result"
fi

# Test 8: get_status - 🟢 Complete
metadata="### 🟢 REQ-123: Test"
result=$(get_status "$metadata")
if [ "$result" = "🟢" ]; then
    test_pass "get_status - 🟢 Complete"
else
    test_fail "get_status - 🟢 Complete" "🟢" "$result"
fi

# Test 9: get_status - 🟡 In Progress
metadata="### 🟡 REQ-123: Test"
result=$(get_status "$metadata")
if [ "$result" = "🟡" ]; then
    test_pass "get_status - 🟡 In Progress"
else
    test_fail "get_status - 🟡 In Progress" "🟡" "$result"
fi

# Test 10: get_status - ⚪ Not Started
metadata="### ⚪ REQ-123: Test"
result=$(get_status "$metadata")
if [ "$result" = "⚪" ]; then
    test_pass "get_status - ⚪ Not Started"
else
    test_fail "get_status - ⚪ Not Started" "⚪" "$result"
fi

# Test 11: get_status - 🔴 Blocked
metadata="### 🔴 REQ-123: Test"
result=$(get_status "$metadata")
if [ "$result" = "🔴" ]; then
    test_pass "get_status - 🔴 Blocked"
else
    test_fail "get_status - 🔴 Blocked" "🔴" "$result"
fi

# Test 12: get_expected_hours - XS
result=$(get_expected_hours "XS")
if [ "$result" = "1" ]; then
    test_pass "get_expected_hours - XS = 1 hour"
else
    test_fail "get_expected_hours - XS = 1 hour" "1" "$result"
fi

# Test 13: get_expected_hours - S
result=$(get_expected_hours "S")
if [ "$result" = "2" ]; then
    test_pass "get_expected_hours - S = 2 hours"
else
    test_fail "get_expected_hours - S = 2 hours" "2" "$result"
fi

# Test 14: get_expected_hours - M
result=$(get_expected_hours "M")
if [ "$result" = "4" ]; then
    test_pass "get_expected_hours - M = 4 hours"
else
    test_fail "get_expected_hours - M = 4 hours" "4" "$result"
fi

# Test 15: get_expected_hours - UNKNOWN
result=$(get_expected_hours "UNKNOWN")
if [ "$result" = "N/A" ]; then
    test_pass "get_expected_hours - UNKNOWN = N/A"
else
    test_fail "get_expected_hours - UNKNOWN = N/A" "N/A" "$result"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════"
echo "  Test Summary"
echo "═══════════════════════════════════════════"
echo "  Total Tests:  $TESTS_RUN"
echo -e "  ${GREEN}Passed:${NC}       $TESTS_PASSED"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "  ${RED}Failed:${NC}       $TESTS_FAILED"
    exit 1
else
    echo "  Failed:       0"
    exit 0
fi
