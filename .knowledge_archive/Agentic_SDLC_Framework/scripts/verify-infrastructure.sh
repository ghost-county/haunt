#!/bin/bash
# scripts/verify-infrastructure.sh
# Verify Agentic SDLC infrastructure is properly set up

echo "=== Verifying Agentic SDLC Infrastructure ==="

FAILED=0

# NATS Server
echo ""
echo "## NATS Server"
echo -n "NATS Server running: "
if nats server ping > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗ - Start with: nats-server --jetstream"
    FAILED=1
fi

# NATS Streams
echo -n "NATS Streams created: "
STREAMS=$(nats stream ls 2>/dev/null | wc -l)
if [ "$STREAMS" -ge 4 ]; then
    echo "✓ ($STREAMS streams)"
else
    echo "✗ - Run: ./scripts/create-nats-streams.sh"
    FAILED=1
fi

# Memory directory
echo ""
echo "## Memory System"
echo -n "Memory directory exists: "
if [ -d "$HOME/.agent-memory" ]; then
    echo "✓"
else
    echo "✗ - Will be created on first use"
fi

# MCP configuration
echo -n "MCP configuration exists: "
if [ -f ".claude/mcp.json" ]; then
    echo "✓"
else
    echo "✗ - Create .claude/mcp.json"
    FAILED=1
fi

# Plans directory
echo ""
echo "## Planning Files"
echo -n "Roadmap exists: "
if [ -f "plans/roadmap.md" ]; then
    echo "✓"
else
    echo "✗ - Initialize plans/roadmap.md"
    FAILED=1
fi

# Archive directory
echo -n "Archive exists: "
if [ -f "completed/roadmap-archive.md" ]; then
    echo "✓"
else
    echo "✗ - Initialize completed/roadmap-archive.md"
    FAILED=1
fi

# Feature contract
echo -n "Feature contract exists: "
if [ -f "plans/feature-contract.json" ]; then
    echo "✓"
else
    echo "✗ - Initialize plans/feature-contract.json"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo "=== Infrastructure ready! ==="
    echo "Proceed to: 03-Agent-Definitions.md"
else
    echo "=== Some components missing ==="
    echo "Fix the items marked with ✗ and run again."
    exit 1
fi
