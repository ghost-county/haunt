#!/bin/bash
# Session Start Hook: Initialize Session
# Fires on: SessionStart event
# Purpose: Create .haunt/ directory structure if needed, log session start

set -euo pipefail

# Global disable check
if [[ "${HAUNT_HOOKS_DISABLED:-0}" == "1" ]]; then
    exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract working directory
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // ""')

# Exit if no project directory
if [[ -z "$PROJECT_DIR" || "$PROJECT_DIR" == "null" ]]; then
    exit 0
fi

# Create .haunt/ directory structure if it doesn't exist
HAUNT_DIR="$PROJECT_DIR/.haunt"
if [[ ! -d "$HAUNT_DIR" ]]; then
    mkdir -p "$HAUNT_DIR"/{plans,progress,completed,tests,docs}

    # Create subdirectories for tests
    mkdir -p "$HAUNT_DIR/tests"/{patterns,behavior,e2e}

    # Create UOCS history structure
    mkdir -p "$HAUNT_DIR/history"/{sessions,learnings,research,decisions,events,metadata}

    # Log initialization
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Initialized .haunt/ directory structure with UOCS history" >> "$HAUNT_DIR/session-history.log"
fi

# Ensure history directories exist even if .haunt/ already present
HISTORY_DIR="$HAUNT_DIR/history"
if [[ ! -d "$HISTORY_DIR" ]]; then
    mkdir -p "$HISTORY_DIR"/{sessions,learnings,research,decisions,events,metadata}
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Created UOCS history directories" >> "$HAUNT_DIR/session-history.log"
fi

# Log session start
SESSION_LOG="$HAUNT_DIR/session-history.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "[$TIMESTAMP] Session started in: $PROJECT_DIR" >> "$SESSION_LOG"

# Check for session handoff file
HANDOFF_FILE="$HAUNT_DIR/state/continue-here.md"
if [[ -f "$HANDOFF_FILE" ]]; then
    # Check if file is recent (modified within last 24 hours = 86400 seconds)
    FILE_MOD=$(stat -f %m "$HANDOFF_FILE" 2>/dev/null || echo 0)
    NOW=$(date +%s)
    FILE_AGE=$((NOW - FILE_MOD))

    if [[ $FILE_AGE -lt 86400 ]]; then
        # Extract first meaningful line (skip template header if present)
        HANDOFF_TITLE=$(grep -m1 "^# " "$HANDOFF_FILE" 2>/dev/null | sed 's/^# //' || echo "Incomplete work")
        HANDOFF_STATUS=$(grep -m1 "^\*\*Status:\*\*" "$HANDOFF_FILE" 2>/dev/null | sed 's/\*\*Status:\*\* //' || echo "Unknown")
        AGE_MINUTES=$((FILE_AGE / 60))

        # Output reminder to Claude (this appears in conversation)
        cat <<EOF

📋 SESSION HANDOFF DETECTED

Found: .haunt/state/continue-here.md
Title: ${HANDOFF_TITLE}
Status: ${HANDOFF_STATUS}
Age: ${AGE_MINUTES} minutes ago

⚠️ ACTION REQUIRED: Read .haunt/state/continue-here.md before starting new work.

EOF
    fi
fi

# Exit successfully (non-blocking hook)
exit 0
