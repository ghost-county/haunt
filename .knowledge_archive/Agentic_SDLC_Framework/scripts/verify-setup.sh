#!/bin/bash
# scripts/verify-setup.sh
# Verify complete Agentic SDLC setup

echo "=== Verifying Agentic SDLC Setup ==="

check() {
    if $1 > /dev/null 2>&1; then
        echo "✓ $2"
        return 0
    else
        echo "✗ $2"
        return 1
    fi
}

warning() {
    echo "○ $1 (optional)"
}

FAILED=0

echo ""
echo "Global Components:"
check "test -d $HOME/.claude/agents" "Global agents directory exists" || FAILED=1
check "test -f $HOME/.claude/agents/Project-Manager.md" "Project-Manager agent" || FAILED=1
check "test -f $HOME/.claude/agents/Dev-Backend.md" "Dev-Backend agent" || FAILED=1
check "test -f $HOME/.claude/agents/Dev-Frontend.md" "Dev-Frontend agent" || FAILED=1
check "test -f $HOME/.claude/agents/Dev-Infrastructure.md" "Dev-Infrastructure agent" || FAILED=1
check "test -f $HOME/.claude/agents/Research-Analyst.md" "Research-Analyst agent" || FAILED=1
check "test -f $HOME/.claude/agents/Research-Critic.md" "Research-Critic agent" || FAILED=1
check "test -f $HOME/.claude/agents/Code-Reviewer.md" "Code-Reviewer agent" || FAILED=1
check "test -f $HOME/.claude/agents/Release-Manager.md" "Release-Manager agent" || FAILED=1
check "test -f $HOME/.claude/agents/Agentic-SDLC-Initializer.md" "Agentic-SDLC-Initializer agent" || FAILED=1

echo ""
echo "Infrastructure:"
check "which nats-server" "NATS Server installed" || warning "Optional: NATS Server"
check "which nats" "NATS CLI installed" || warning "Optional: NATS CLI"
# Use 'nats stream ls' to check connectivity (not 'nats server ping' which requires system account)
if which nats > /dev/null 2>&1; then
    check "nats stream ls" "NATS JetStream running" || warning "Optional: NATS JetStream"
    # Check required streams exist
    check "nats stream info REQUIREMENTS" "REQUIREMENTS stream" || warning "Run: nats stream add REQUIREMENTS ..."
    check "nats stream info WORK" "WORK stream" || warning "Run: nats stream add WORK ..."
    check "nats stream info INTEGRATION" "INTEGRATION stream" || warning "Run: nats stream add INTEGRATION ..."
    check "nats stream info RELEASES" "RELEASES stream" || warning "Run: nats stream add RELEASES ..."
fi
check "python3 -c 'import playwright'" "Playwright installed" || warning "Optional: Playwright"

echo ""
echo "MCP Servers:"
check "claude mcp list 2>/dev/null | grep -q context7" "Context7 MCP configured" || warning "Optional: Context7 MCP"

echo ""
echo "Project Components:"
check "test -d .claude/agents" "Project agents directory" || FAILED=1
check "test -f plans/roadmap.md" "Roadmap exists" || FAILED=1
check "test -f plans/feature-contract.json" "Feature contract exists" || FAILED=1
check "test -f .pre-commit-config.yaml" "Pre-commit configured" || warning "Optional: Pre-commit"
check "test -d tests/patterns" "Pattern tests directory" || FAILED=1

echo ""
if [ $FAILED -eq 0 ]; then
    echo "=== Setup verified successfully! ==="
else
    echo "=== Some components missing - run setup-all.sh ==="
    exit 1
fi
