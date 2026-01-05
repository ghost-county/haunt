#!/bin/bash
# Completion Gate Hook
# Blocks:
# 1. Marking requirements complete (🟢) without test verification
# 2. Marking requirements complete (🟢) with unchecked task boxes (- [ ])
#
# This hook ensures requirements can only be marked complete when:
# - Tests have been verified (via verify-tests.sh evidence file)
# - All task checkboxes are marked complete (- [x], not - [ ])

set -euo pipefail

# Global disable check
if [[ "${HAUNT_HOOKS_DISABLED:-0}" == "1" ]]; then
    exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract file path and new content from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
NEW_STRING=$(echo "$INPUT" | jq -r '.tool_input.new_string // ""')

# Only check edits to roadmap files
if [[ "$FILE_PATH" != *"roadmap.md"* ]]; then
    exit 0
fi

# Check if the edit is changing a requirement status to complete (🟢)
# Pattern: ### {🟢} REQ-XXX (requirement header with complete status)
# This prevents false positives from emoji in other contexts (e.g., "🟢 Unblocked", summary tables)
#
# Strategy: Use grep to find lines matching the complete requirement header pattern.
# If no such line exists, this is not a requirement completion (allow the edit).
# If such a line exists, extract the REQ number and verify tests.

COMPLETE_HEADER=$(echo "$NEW_STRING" | grep -E '###[[:space:]]*\{[[:space:]]*🟢[[:space:]]*\}[[:space:]]*REQ-[0-9]+' || true)

if [[ -z "$COMPLETE_HEADER" ]]; then
    exit 0  # Not marking requirement complete, allow
fi

# Extract REQ number being marked complete
REQ_MATCH=$(echo "$COMPLETE_HEADER" | grep -oE 'REQ-[0-9]+' | head -1 || true)

if [[ -z "$REQ_MATCH" ]]; then
    exit 0  # Can't determine REQ number, allow (defensive)
fi

# Find project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(echo "$INPUT" | jq -r '.cwd')}"

# Check for test verification evidence file
VERIFY_FILE="$PROJECT_DIR/.haunt/progress/${REQ_MATCH}-verified.txt"

if [[ ! -f "$VERIFY_FILE" ]]; then
    echo "Completion gate: Cannot mark $REQ_MATCH complete without test verification." >&2
    echo "" >&2
    echo "To fix:" >&2
    echo "1. Run: bash Haunt/scripts/verify-tests.sh $REQ_MATCH <frontend|backend|infrastructure>" >&2
    echo "2. This creates: $VERIFY_FILE" >&2
    echo "3. Then retry marking the requirement complete" >&2
    echo "" >&2
    echo "This ensures all requirements have passing tests before completion." >&2
    echo "See: gco-completion-checklist rule for full requirements." >&2
    exit 2  # Blocking error
fi

# Check verification is recent (within last hour = 3600 seconds)
# This prevents using stale verification from previous sessions
CURRENT_TIME=$(date +%s)

# Get file modification time (macOS vs Linux compatible)
if [[ "$(uname)" == "Darwin" ]]; then
    FILE_TIME=$(stat -f %m "$VERIFY_FILE" 2>/dev/null || echo "0")
else
    FILE_TIME=$(stat -c %Y "$VERIFY_FILE" 2>/dev/null || echo "0")
fi

VERIFY_AGE=$((CURRENT_TIME - FILE_TIME))

if [[ $VERIFY_AGE -gt 3600 ]]; then
    MINUTES_AGO=$((VERIFY_AGE / 60))
    echo "Completion gate: Test verification for $REQ_MATCH is stale." >&2
    echo "" >&2
    echo "Verification was $MINUTES_AGO minutes ago (max: 60 minutes)." >&2
    echo "" >&2
    echo "Re-run: bash Haunt/scripts/verify-tests.sh $REQ_MATCH <agent-type>" >&2
    echo "" >&2
    echo "This ensures tests still pass before marking complete." >&2
    exit 2  # Blocking error
fi

# Check for unchecked task boxes in the requirement being marked complete
# Pattern: - [ ] (task checkbox that is NOT checked)
UNCHECKED_TASKS=$(echo "$NEW_STRING" | grep -E '^[[:space:]]*-[[:space:]]*\[[[:space:]]\]' || true)

if [[ -n "$UNCHECKED_TASKS" ]]; then
    UNCHECKED_COUNT=$(echo "$UNCHECKED_TASKS" | wc -l | tr -d ' ')
    echo "Completion gate: Cannot mark $REQ_MATCH complete with unchecked tasks." >&2
    echo "" >&2
    echo "Found $UNCHECKED_COUNT unchecked task(s):" >&2
    echo "$UNCHECKED_TASKS" | head -5 >&2
    if [[ $UNCHECKED_COUNT -gt 5 ]]; then
        echo "  ... and $((UNCHECKED_COUNT - 5)) more" >&2
    fi
    echo "" >&2
    echo "To fix:" >&2
    echo "1. Complete all tasks and mark them as [x]" >&2
    echo "2. Then retry marking the requirement complete" >&2
    echo "" >&2
    echo "Rule: All tasks must be - [x] (not - [ ]) before marking 🟢" >&2
    echo "See: gco-completion-checklist rule" >&2
    exit 2  # Blocking error
fi

# All checks passed - verification valid and all tasks complete
exit 0
