#!/bin/bash
# Session Start Hook: Initialize Session
# Fires on: SessionStart event (startup|clear|compact)
# Purpose:
#   1. ALWAYS: inject the gco-using-haunt dispatcher skill so build requests
#      route into the seance without the user typing /seance (passive harness)
#   2. DURING A SEANCE (.haunt/active-session exists): create .haunt/ structure,
#      surface handoff notes, incomplete tasks, and roadmap staleness warnings
#
# Output contract: emits a single JSON object on stdout
# (hookSpecificOutput.additionalContext). Nothing else may be printed.

set -euo pipefail

# Global disable check
if [[ "${HAUNT_HOOKS_DISABLED:-0}" == "1" ]]; then
    exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract working directory
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // ""')

# Derive plugin root from this script's location (hooks/session-start/ -> repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

CONTEXT=""

# --- Part 1: Always inject the dispatcher skill ---
DISPATCHER="${PLUGIN_ROOT}/skills/gco-using-haunt/SKILL.md"
if [[ -f "$DISPATCHER" ]]; then
    DISPATCHER_CONTENT=$(cat "$DISPATCHER")
    CONTEXT+="<HAUNT-DISPATCHER>
You have Haunt. Below is the full content of the 'haunt:gco-using-haunt' skill — it governs when build requests enter the seance workflow. For all other Haunt skills, use the Skill tool.

${DISPATCHER_CONTENT}
</HAUNT-DISPATCHER>"
fi

# --- Part 2: Seance-mode session state (only when sentinel exists) ---
SEANCE_ACTIVE=false
if [[ -n "$PROJECT_DIR" && "$PROJECT_DIR" != "null" && -f "$PROJECT_DIR/.haunt/active-session" ]]; then
    SEANCE_ACTIVE=true
fi

if [[ "$SEANCE_ACTIVE" == true ]]; then
    HAUNT_DIR="$PROJECT_DIR/.haunt"
    HANDOFF_MAX_AGE_SECONDS=86400

    # Capture epoch once — reuse for all time comparisons
    NOW=$(date +%s)
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Create all required directories idempotently (mkdir -p is a no-op if they exist)
    FIRST_INIT=false
    if [[ ! -d "$HAUNT_DIR/plans" ]]; then
        FIRST_INIT=true
    fi
    mkdir -p "$HAUNT_DIR"/{plans,progress,completed,tests/{patterns,behavior,e2e},docs,logs,history/{sessions,learnings,research,decisions,events,metadata},state,standards,specs}

    # Log session start
    SESSION_LOG="$HAUNT_DIR/session-history.log"
    if [[ "$FIRST_INIT" == true ]]; then
        echo "[$TIMESTAMP] Initialized .haunt/ directory structure" >> "$SESSION_LOG"
    fi
    echo "[$TIMESTAMP] Session started in: $PROJECT_DIR" >> "$SESSION_LOG"

    CONTEXT+=$'\n\n'"⚡ SEANCE ACTIVE: .haunt/active-session exists. A seance is in progress — read .haunt/plans/roadmap.md and the active spec folder before starting new work."

    # Check for session handoff file
    HANDOFF_FILE="$HAUNT_DIR/state/continue-here.md"
    if [[ -f "$HANDOFF_FILE" ]]; then
        FILE_MOD=$(stat -f %m "$HANDOFF_FILE" 2>/dev/null || echo 0)
        FILE_AGE=$((NOW - FILE_MOD))

        if [[ $FILE_AGE -lt $HANDOFF_MAX_AGE_SECONDS ]]; then
            HANDOFF_TITLE=$(grep -m1 "^# " "$HANDOFF_FILE" 2>/dev/null | sed 's/^# //' || echo "Incomplete work")
            HANDOFF_STATUS=$(grep -m1 "^\*\*Status:\*\*" "$HANDOFF_FILE" 2>/dev/null | sed 's/\*\*Status:\*\* //' || echo "Unknown")
            AGE_MINUTES=$((FILE_AGE / 60))

            CONTEXT+=$'\n\n'"📋 SESSION HANDOFF DETECTED
Found: .haunt/state/continue-here.md
Title: ${HANDOFF_TITLE}
Status: ${HANDOFF_STATUS}
Age: ${AGE_MINUTES} minutes ago
⚠️ ACTION REQUIRED: Read .haunt/state/continue-here.md before starting new work."
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
            CONTEXT+=$'\n\n'"⚠️ INCOMPLETE TASKS DETECTED — started but never verified:"
            for REQ in "${INCOMPLETE_REQS[@]}"; do
                CONTEXT+=$'\n'"  - $REQ"
            done
            CONTEXT+=$'\n'"Review these before re-executing to avoid duplicate side effects."
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
                    COMMITS_HEAD=$(echo "$COMMITS_SINCE" | head -10 | sed 's/^/  /')
                    CONTEXT+=$'\n\n'"⚠️ ROADMAP STALENESS WARNING
${COMMIT_COUNT} commit(s) landed since roadmap was written (${ROADMAP_DATE}):
${COMMITS_HEAD}
Review git log and confirm the plan is still valid before resuming."
                fi
                # Debounce: don't repeat this check today
                touch "$STALENESS_FLAG"
            fi
        fi
    fi
fi

# --- Emit JSON ---
if [[ -z "$CONTEXT" ]]; then
    exit 0
fi

# Escape string for JSON embedding using bash parameter substitution
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

CONTEXT_ESCAPED=$(escape_for_json "$CONTEXT")
printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$CONTEXT_ESCAPED"

exit 0
