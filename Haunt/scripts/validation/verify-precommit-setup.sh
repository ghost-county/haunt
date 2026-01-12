#!/usr/bin/env bash
#
# verify-precommit-setup.sh - Verify Pre-commit Hooks Implementation (Ghost County/Haunt)
#
# This script verifies that all REQ-058 deliverables are in place and working.
#
# Usage: bash verify-precommit-setup.sh

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "========================================"
echo "  Divining Pre-commit Binding Ritual"
echo "========================================"
echo ""

pass_count=0
fail_count=0

# Test 1: Addon script exists and is executable
echo -n "Test 1: Addon script exists and is executable... "
if [[ -x "${SCRIPT_DIR}/setup-precommit-hooks-addon.sh" ]]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 2: Integration guide exists
echo -n "Test 2: Integration guide exists... "
if [[ -f "${SCRIPT_DIR}/PRECOMMIT-INTEGRATION.md" ]]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 3: Quick reference exists
echo -n "Test 3: Quick reference exists... "
if [[ -f "${SCRIPT_DIR}/README-PRECOMMIT.md" ]]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 4: Sample pattern test exists and is executable
echo -n "Test 4: Sample pattern test exists... "
if [[ -x "${PROJECT_ROOT}/.haunt/tests/patterns/test_sample_pattern.py" ]]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 5: Sample pattern test runs without errors
echo -n "Test 5: Sample pattern test executes... "
if python3 "${PROJECT_ROOT}/.haunt/tests/patterns/test_sample_pattern.py" > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 6: Addon script runs in dry-run mode
echo -n "Test 6: Addon script dry-run works... "
if bash "${SCRIPT_DIR}/setup-precommit-hooks-addon.sh" --dry-run > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 7: Completion documentation exists
echo -n "Test 7: Completion documentation exists... "
if [[ -f "${PROJECT_ROOT}/.haunt/completed/REQ-058-precommit-hooks-implementation.md" ]]; then
    echo -e "${GREEN}PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}FAIL${NC}"
    ((fail_count++))
fi

# Test 8: Check pre-commit availability (informational)
echo -n "Test 8: pre-commit availability (info)... "
if command -v pre-commit &> /dev/null; then
    echo -e "${GREEN}INSTALLED${NC} ($(pre-commit --version))"
else
    echo -e "${YELLOW}NOT INSTALLED${NC} (optional)"
fi

# Summary
echo ""
echo "========================================"
echo "  Séance Summary"
echo "========================================"
echo ""
echo "Tests passed: ${pass_count}/7"
echo "Tests failed: ${fail_count}/7"
echo ""

if [[ $fail_count -eq 0 ]]; then
    echo -e "${GREEN}✓ All binding rituals successful!${NC}"
    echo ""
    echo "REQ-058 implementation manifested and operational."
    echo ""
    echo "Next hauntings:"
    echo "  1. Review PRECOMMIT-INTEGRATION.md for binding instructions"
    echo "  2. Integrate addon into main summoning script"
    echo "  3. Test with: bash setup-haunt.sh --with-hooks --dry-run"
    exit 0
else
    echo -e "${RED}✗ Some binding rituals failed.${NC}"
    echo ""
    echo "Please divine the failed tests above and ensure all artifacts are manifested."
    exit 1
fi
