#!/bin/bash
# scripts/morning-review.sh
# Daily morning review script for Agentic SDLC

echo "=== Morning Review ==="
echo ""

echo "## Git Activity (last 24h)"
git log --since="24 hours ago" --oneline 2>/dev/null || echo "No commits"

echo ""
echo "## Current Roadmap Status"
head -40 plans/roadmap.md 2>/dev/null || echo "No roadmap"

echo ""
echo "## In-Progress Items"
grep -E "🟡|In Progress|IN_PROGRESS" plans/roadmap.md 2>/dev/null || echo "None"

echo ""
echo "## Blocked Items"
grep -E "🔴|BLOCKED" plans/roadmap.md 2>/dev/null || echo "None"

echo ""
echo "## Tests Status"
pytest tests/ -q --tb=no 2>/dev/null && echo "All tests passing" || echo "Some tests failing"

echo ""
echo "## NATS Queue Status"
# Use 'nats stream ls' instead of 'nats server ping' (ping requires system account permissions)
if nats stream ls > /dev/null 2>&1; then
    echo "NATS Server: Running"
    nats stream info WORK --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'  WORK queue: {d[\"state\"][\"messages\"]} messages')" 2>/dev/null || echo "  WORK queue: Unable to check"
else
    echo "NATS Server: Not running"
fi

echo ""
echo "## Services Status"
pgrep -f nats-server > /dev/null && echo "✓ NATS running" || echo "✗ NATS stopped"
pgrep -f agent-memory > /dev/null && echo "✓ Memory server running" || echo "○ Memory server not running (starts on demand)"

echo ""
echo "=== Morning review complete ==="
