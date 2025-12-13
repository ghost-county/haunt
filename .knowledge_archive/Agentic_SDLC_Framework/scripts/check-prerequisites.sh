#!/bin/bash
# scripts/check-prerequisites.sh
# Verify all Agentic SDLC prerequisites are installed

echo "=== Checking Agentic SDLC Prerequisites ==="

check() {
    if $1 > /dev/null 2>&1; then
        echo "✓ $2"
        return 0
    else
        echo "✗ $2 - $3"
        return 1
    fi
}

FAILED=0

echo ""
echo "## Core Tools"

check "python3 --version | grep -E '3\.(11|12|13)'" \
    "Python 3.11+" \
    "Install with: brew install python@3.11" || FAILED=1

check "node --version | grep -E 'v(18|19|20|21|22)'" \
    "Node.js 18+" \
    "Install with: brew install node@18" || FAILED=1

check "git config user.email" \
    "Git configured" \
    "Run: git config --global user.email 'you@example.com'" || FAILED=1

echo ""
echo "## NATS Infrastructure"

check "which nats-server" \
    "NATS Server installed" \
    "Install with: brew install nats-server" || FAILED=1

check "which nats" \
    "NATS CLI installed" \
    "Install with: brew install nats-io/nats-tools/nats" || FAILED=1

echo ""
echo "## Claude Access"

check "which claude" \
    "Claude Code CLI" \
    "Install with: npm install -g @anthropic-ai/claude-code" || FAILED=1

echo ""
echo "## Python Packages"

check "python3 -c 'import nats'" \
    "nats-py package" \
    "Install with: pip install nats-py" || FAILED=1

check "python3 -c 'import mcp'" \
    "mcp package" \
    "Install with: pip install mcp" || FAILED=1

check "python3 -c 'import pydantic'" \
    "pydantic package" \
    "Install with: pip install pydantic" || FAILED=1

echo ""
echo "## Directory Structure"

check "test -d .claude/agents" \
    "Agent directory exists" \
    "Create with: mkdir -p .claude/agents" || FAILED=1

check "test -d plans" \
    "Plans directory exists" \
    "Create with: mkdir -p plans" || FAILED=1

check "test -d tests/patterns" \
    "Pattern tests directory exists" \
    "Create with: mkdir -p tests/patterns" || FAILED=1

echo ""
if [ $FAILED -eq 0 ]; then
    echo "=== All prerequisites met! ==="
    echo "Proceed to: 02-Infrastructure.md"
else
    echo "=== Some prerequisites missing ==="
    echo "Fix the items marked with ✗ and run again."
    exit 1
fi
