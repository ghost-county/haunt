#!/bin/bash
# Commit Convention Enforcement Hook
# Blocks: git commits without [REQ-XXX] prefix
#
# This hook ensures all commits follow the Haunt commit convention:
# [REQ-XXX] Action: Brief description

set -euo pipefail

# Global disable check
if [[ "${HAUNT_HOOKS_DISABLED:-0}" == "1" ]]; then
    exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract command from tool input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only validate git commit commands
if [[ ! "$COMMAND" =~ git[[:space:]]+commit ]]; then
    exit 0  # Not a commit command, allow
fi

# Skip if it's just git commit without -m (using editor)
if [[ ! "$COMMAND" =~ -m ]]; then
    exit 0  # Editor-based commit, can't validate here
fi

# Try to extract commit message
# Handle: -m "message", -m 'message', -m "$(cat <<'EOF'..."
MESSAGE=""

# Pattern 1: HEREDOC pattern -m "$(cat <<'EOF' ... EOF )" — check FIRST since
# the simple -m "..." regex greedily matches the outer quotes around heredocs
if [[ "$COMMAND" =~ -m[[:space:]]+\"\$\(cat ]]; then
    # The command has literal newlines — extract first non-empty line between EOF markers
    MESSAGE=$(echo "$COMMAND" | sed -n '/<<.*EOF/,/^[[:space:]]*EOF/{//d;p;}' | sed '/^[[:space:]]*$/d' | head -1 | sed 's/^[[:space:]]*//' || true)
# Pattern 2: -m "message" or -m 'message'
elif [[ "$COMMAND" =~ -m[[:space:]]+\"([^\"]+)\" ]]; then
    MESSAGE="${BASH_REMATCH[1]}"
elif [[ "$COMMAND" =~ -m[[:space:]]+\'([^\']+)\' ]]; then
    MESSAGE="${BASH_REMATCH[1]}"
fi

# If we couldn't extract the message, allow (don't block on parse failure)
if [[ -z "$MESSAGE" ]]; then
    exit 0
fi

# Allow merge commits
if [[ "$MESSAGE" =~ ^Merge ]]; then
    exit 0
fi

# Allow revert commits
if [[ "$MESSAGE" =~ ^Revert ]]; then
    exit 0
fi

# Allow WIP commits (but warn)
if [[ "$MESSAGE" =~ ^WIP ]]; then
    exit 0  # Allow but ideally should be squashed later
fi

# Allow generated/automated commits
if [[ "$MESSAGE" =~ Generated|Automated|Auto-generated ]]; then
    exit 0
fi

# Require [REQ-XXX] prefix for standard commits
if [[ ! "$MESSAGE" =~ ^\[REQ-[0-9]+\] ]] && [[ ! "$MESSAGE" =~ ^\[REQ-[0-9]+,[[:space:]]*REQ-[0-9]+ ]]; then
    echo "Commit convention violation: Message must start with [REQ-XXX]" >&2
    echo "" >&2
    echo "Got: '$MESSAGE'" >&2
    echo "" >&2
    echo "Expected formats:" >&2
    echo "  [REQ-123] Add: New feature description" >&2
    echo "  [REQ-123] Fix: Bug fix description" >&2
    echo "  [REQ-123, REQ-456] Update: Multi-requirement change" >&2
    echo "" >&2
    echo "Allowed exceptions:" >&2
    echo "  - Merge commits (start with 'Merge')" >&2
    echo "  - Revert commits (start with 'Revert')" >&2
    echo "  - WIP commits (start with 'WIP')" >&2
    echo "" >&2
    echo "See: gco-commit-conventions skill for full format guide" >&2
    exit 2  # Blocking error
fi

exit 0
