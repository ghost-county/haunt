#!/bin/bash
# scripts/evening-handoff.sh
# Evening handoff script for Agentic SDLC

echo "=== Evening Handoff ==="
echo ""

echo "## Today's Commits"
git log --since="8 hours ago" --oneline 2>/dev/null || echo "No commits today"

echo ""
echo "## Current Work (In Progress)"
grep -A5 "🟡" plans/roadmap.md 2>/dev/null || echo "Nothing in progress"

echo ""
echo "## Completed Today"
grep -E "🟢.*$(date +%Y-%m-%d)" plans/roadmap.md 2>/dev/null || echo "Nothing completed today"

echo ""
echo "## Services Status"
pgrep -f nats-server > /dev/null && echo "✓ NATS running" || echo "✗ NATS stopped"
pgrep -f agent-memory > /dev/null && echo "✓ Memory running" || echo "○ Memory stopped"

echo ""
echo "## Pending Work Queue"
if nats stream ls > /dev/null 2>&1; then
    nats stream info WORK --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'{d[\"state\"][\"messages\"]} messages pending')" 2>/dev/null || echo "Unable to check queue"
else
    echo "NATS not running - no queue info"
fi

echo ""
echo "## Tests Status"
pytest tests/ -q --tb=no 2>/dev/null && echo "✓ All tests passing" || echo "⚠ Some tests failing"

echo ""
echo "=== Evening handoff complete ==="
echo ""
echo "Notes for tomorrow:"
echo "  - Review any overnight agent activity"
echo "  - Check CI/CD status"
echo "  - Update roadmap priorities if needed"
