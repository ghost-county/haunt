#!/bin/bash
# Séance Phase Enforcement Hook
# Blocks: gco-dev-* agents when summoning not approved
#
# Simple existence-based checking:
# - No .haunt/state/ dir = not in séance, allow all spawns
# - .haunt/state/ exists but no summoning-approved file = block dev agents
# - summoning-approved file exists = allow dev agents
# - PM/Research agents always allowed

set -euo pipefail

# Global disable check
if [[ "${HAUNT_HOOKS_DISABLED:-0}" == "1" ]]; then
    exit 0
fi

# Seance gate: only enforce during active seance
SENTINEL="${PWD}/.haunt/active-session"
[[ -f "$SENTINEL" ]] || exit 0

# Read hook input from stdin
INPUT=$(cat)

# Extract subagent type from tool input
SUBAGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // ""')

# Only check gco-dev-* agents (backend, frontend, infrastructure)
if [[ ! "$SUBAGENT_TYPE" =~ ^gco-dev ]]; then
    exit 0  # Allow non-dev agents (PM, research, code-reviewer, etc.)
fi

# Find project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(echo "$INPUT" | jq -r '.cwd')}"
STATE_DIR="$PROJECT_DIR/.haunt/state"
SUMMONING_FILE="$STATE_DIR/summoning-approved"

# If .haunt/state/ doesn't exist, we're not in a séance
# Allow dev agents for regular non-séance work
if [[ ! -d "$STATE_DIR" ]]; then
    exit 0
fi

# We're in séance context - check if summoning is approved
if [[ ! -f "$SUMMONING_FILE" ]]; then
    echo "Séance phase violation: Cannot spawn $SUBAGENT_TYPE before summoning approval." >&2
    echo "" >&2
    echo "You are in séance mode but summoning has not been approved yet." >&2
    echo "" >&2
    echo "To fix:" >&2
    echo "1. Complete planning (SCRYING) first" >&2
    echo "2. Present summoning prompt to user" >&2
    echo "3. Get user approval" >&2
    echo "4. Create summoning approval: touch $SUMMONING_FILE" >&2
    echo "5. Then spawn dev agents" >&2
    exit 2  # Blocking error
fi

# Summoning approved - allow dev agents
exit 0
