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

# Extract working directory (needed before seance gate check)
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // ""')

# Seance gate: only activate during active seance
if [[ -n "$PROJECT_DIR" && "$PROJECT_DIR" != "null" ]]; then
    SENTINEL="$PROJECT_DIR/.haunt/active-session"
    [[ -f "$SENTINEL" ]] || exit 0
else
    exit 0
fi

# PROJECT_DIR already extracted above for seance gate

HAUNT_DIR="$PROJECT_DIR/.haunt"
HANDOFF_MAX_AGE_SECONDS=86400

# Capture epoch once — reuse for all time comparisons
NOW=$(date +%s)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create all required directories idempotently (mkdir -p is a no-op if they exist)
FIRST_INIT=false
if [[ ! -d "$HAUNT_DIR" ]]; then
    FIRST_INIT=true
fi
mkdir -p "$HAUNT_DIR"/{plans,progress,completed,tests/{patterns,behavior,e2e},docs,logs,history/{sessions,learnings,research,decisions,events,metadata},state}

# Log session start
SESSION_LOG="$HAUNT_DIR/session-history.log"
if [[ "$FIRST_INIT" == true ]]; then
    echo "[$TIMESTAMP] Initialized .haunt/ directory structure" >> "$SESSION_LOG"
fi
echo "[$TIMESTAMP] Session started in: $PROJECT_DIR" >> "$SESSION_LOG"

# Check for session handoff file
HANDOFF_FILE="$HAUNT_DIR/state/continue-here.md"
if [[ -f "$HANDOFF_FILE" ]]; then
    FILE_MOD=$(stat -f %m "$HANDOFF_FILE" 2>/dev/null || echo 0)
    FILE_AGE=$((NOW - FILE_MOD))

    if [[ $FILE_AGE -lt $HANDOFF_MAX_AGE_SECONDS ]]; then
        HANDOFF_TITLE=$(grep -m1 "^# " "$HANDOFF_FILE" 2>/dev/null | sed 's/^# //' || echo "Incomplete work")
        HANDOFF_STATUS=$(grep -m1 "^\*\*Status:\*\*" "$HANDOFF_FILE" 2>/dev/null | sed 's/\*\*Status:\*\* //' || echo "Unknown")
        AGE_MINUTES=$((FILE_AGE / 60))

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

# REQ-401: Idempotency Checkpoint — detect incomplete tasks
PROGRESS_DIR="$HAUNT_DIR/progress"
if [[ -d "$PROGRESS_DIR" ]]; then
    INCOMPLETE_REQS=()
    for STARTED_FILE in "$PROGRESS_DIR"/*-started.txt; do
        [[ -e "$STARTED_FILE" ]] || break
        BASENAME="${STARTED_FILE##*/}"
        BASENAME="${BASENAME%-started.txt}"
        if [[ ! -f "$PROGRESS_DIR/${BASENAME}-verified.txt" ]]; then
            read -r STARTED_TS < "$STARTED_FILE" 2>/dev/null || STARTED_TS="unknown"
            INCOMPLETE_REQS+=("${BASENAME} (started: ${STARTED_TS})")
        fi
    done

    if [[ ${#INCOMPLETE_REQS[@]} -gt 0 ]]; then
        echo ""
        echo "⚠️ INCOMPLETE TASKS DETECTED"
        echo ""
        echo "The following tasks were started but never verified:"
        for REQ in "${INCOMPLETE_REQS[@]}"; do
            echo "  - $REQ"
        done
        echo ""
        echo "Review these before re-executing to avoid duplicate side effects."
        echo ""
    fi
fi

# REQ-402: Staleness check — warn if commits landed since roadmap was written
ROADMAP_FILE="$HAUNT_DIR/plans/roadmap.md"
STALENESS_FLAG="$HAUNT_DIR/state/staleness-checked-${TIMESTAMP:0:4}${TIMESTAMP:5:2}${TIMESTAMP:8:2}.flag"
if [[ -f "$ROADMAP_FILE" && ! -f "$STALENESS_FLAG" ]]; then
    if ! grep -q "All requirements complete" "$ROADMAP_FILE" 2>/dev/null; then
        ROADMAP_MOD=$(stat -f %m "$ROADMAP_FILE" 2>/dev/null || echo 0)
        ROADMAP_DATE=$(date -u -r "$ROADMAP_MOD" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "")

        if [[ -n "$ROADMAP_DATE" && -d "$PROJECT_DIR/.git" ]]; then
            COMMITS_SINCE=$(git -C "$PROJECT_DIR" log --oneline --since="$ROADMAP_DATE" 2>/dev/null || echo "")
            if [[ -n "$COMMITS_SINCE" ]]; then
                COMMIT_COUNT=0
                while IFS= read -r _; do COMMIT_COUNT=$((COMMIT_COUNT + 1)); done <<< "$COMMITS_SINCE"
                echo ""
                echo "⚠️ ROADMAP STALENESS WARNING"
                echo ""
                echo "${COMMIT_COUNT} commit(s) landed since roadmap was written (${ROADMAP_DATE}):"
                echo ""
                echo "$COMMITS_SINCE" | head -10 | sed 's/^/  /'
                echo ""
                echo "Review git log and confirm the plan is still valid before resuming."
                echo ""
            fi
            # Debounce: don't repeat this check today
            touch "$STALENESS_FLAG"
        fi
    fi
fi

# Exit successfully (non-blocking hook)
exit 0
