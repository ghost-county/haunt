#!/usr/bin/env bash
#
# test-seer-agent.sh - Seer Agent Behavior Tests
#
# Tests for REQ-320: Core Seer Agent Implementation
# Verifies Task tool spawning, memory operations, and skill integration.
#
# Usage: bash .haunt/tests/behavior/test-seer-agent.sh

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ============================================================================
# Test 1: Seer Agent File Exists and is Deployed
# ============================================================================

section "Test 1: Seer Agent Deployment"

if [[ -f ~/.claude/agents/gco-seer.md ]]; then
    pass "gco-seer.md deployed to ~/.claude/agents/"
else
    fail "gco-seer.md NOT found in ~/.claude/agents/"
fi

if [[ -f Haunt/agents/gco-seer.md ]]; then
    pass "gco-seer.md source exists in Haunt/agents/"
else
    fail "gco-seer.md source NOT found in Haunt/agents/"
fi

# ============================================================================
# Test 2: Seer Agent Metadata Validation
# ============================================================================

section "Test 2: Seer Agent Metadata"

SEER_FILE=~/.claude/agents/gco-seer.md

# Check for required YAML frontmatter fields
if grep -q "^name: gco-seer$" "$SEER_FILE"; then
    pass "Agent name is 'gco-seer'"
else
    fail "Agent name field missing or incorrect"
fi

if grep -q "^model: opus$" "$SEER_FILE"; then
    pass "Model is 'opus' (required for orchestration)"
else
    fail "Model field missing or incorrect (should be 'opus')"
fi

if grep -q "^permissionMode: bypassPermissions$" "$SEER_FILE"; then
    pass "PermissionMode is 'bypassPermissions'"
else
    fail "PermissionMode field missing or incorrect"
fi

if grep -q "^tools:.*Task" "$SEER_FILE"; then
    pass "Task tool listed in tools"
else
    fail "Task tool missing from tools declaration"
fi

if grep -q "^tools:.*mcp__agent_memory__" "$SEER_FILE"; then
    pass "Agent memory tools listed in tools"
else
    fail "Agent memory tools missing from tools declaration"
fi

if grep -q "^skills:.*gco-orchestrator" "$SEER_FILE"; then
    pass "gco-orchestrator skill listed in skills"
else
    fail "gco-orchestrator skill missing from skills declaration"
fi

# ============================================================================
# Test 3: Seer Agent Size Constraint (150-200 lines)
# ============================================================================

section "Test 3: Seer Agent Size"

LINE_COUNT=$(wc -l < "$SEER_FILE" | tr -d ' ')

if [[ $LINE_COUNT -ge 150 && $LINE_COUNT -le 200 ]]; then
    pass "Agent size within target (${LINE_COUNT} lines, target: 150-200)"
else
    if [[ $LINE_COUNT -lt 150 ]]; then
        fail "Agent too small (${LINE_COUNT} lines, target: 150-200)"
    else
        fail "Agent too large (${LINE_COUNT} lines, target: 150-200)"
    fi
fi

# ============================================================================
# Test 4: Required Sections Present
# ============================================================================

section "Test 4: Required Sections"

if grep -q "## Identity" "$SEER_FILE"; then
    pass "Identity section present"
else
    fail "Identity section missing"
fi

if grep -q "## Persistent Memory" "$SEER_FILE"; then
    pass "Persistent Memory section present"
else
    fail "Persistent Memory section missing"
fi

if grep -q "mcp__agent_memory__search" "$SEER_FILE"; then
    pass "Memory search operation documented"
else
    fail "Memory search operation not documented"
fi

if grep -q "mcp__agent_memory__store" "$SEER_FILE"; then
    pass "Memory store operation documented"
else
    fail "Memory store operation not documented"
fi

if grep -q "Explore-First Pattern" "$SEER_FILE"; then
    pass "Explore-First Pattern section present"
else
    fail "Explore-First Pattern section missing"
fi

# ============================================================================
# Test 5: Spawnable Agents Documented
# ============================================================================

section "Test 5: Spawnable Agents Documented"

# Seer should document ability to spawn key agents
if grep -q "gco-project-manager\|gco-pm" "$SEER_FILE"; then
    pass "Project Manager agent spawning documented"
else
    fail "Project Manager agent spawning not documented"
fi

if grep -q "gco-dev" "$SEER_FILE"; then
    pass "Dev agent spawning documented"
else
    fail "Dev agent spawning not documented"
fi

if grep -q "gco-research" "$SEER_FILE"; then
    pass "Research agent spawning documented"
else
    fail "Research agent spawning not documented"
fi

if grep -q "gco-code-reviewer\|Code Reviewer" "$SEER_FILE"; then
    pass "Code Reviewer agent spawning documented"
else
    fail "Code Reviewer agent spawning not documented"
fi

# ============================================================================
# Test 6: Orchestrator Skill Integration
# ============================================================================

section "Test 6: Orchestrator Skill Integration"

ORCHESTRATOR_SKILL=~/.claude/skills/gco-orchestrator/SKILL.md

if [[ -f "$ORCHESTRATOR_SKILL" ]]; then
    pass "gco-orchestrator skill exists"

    # Verify key orchestrator concepts referenced in Seer
    if grep -q "SCRYING.*SUMMONING.*BANISHING" "$SEER_FILE"; then
        pass "Séance phase workflow referenced"
    else
        fail "Séance phase workflow not referenced"
    fi

    if grep -q "delegation\|coordinate" "$SEER_FILE"; then
        pass "Delegation principle present"
    else
        fail "Delegation principle not documented"
    fi
else
    fail "gco-orchestrator skill not found (required dependency)"
fi

# ============================================================================
# Test Summary
# ============================================================================

section "Test Summary"

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))

echo ""
echo "Tests Passed: ${TESTS_PASSED}/${TOTAL_TESTS}"
echo "Tests Failed: ${TESTS_FAILED}/${TOTAL_TESTS}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Seer agent is ready for functional testing."
    echo "Next steps:"
    echo "  1. Test Task tool spawning with real agents"
    echo "  2. Test memory operations with mcp__agent_memory__* tools"
    echo "  3. Conduct full séance workflow test"
    exit 0
else
    echo -e "${RED}✗ ${TESTS_FAILED} test(s) failed${NC}"
    echo ""
    echo "Fix the failing tests before marking REQ-320 complete."
    exit 1
fi
