#!/bin/bash
# Notification Hook: Work Completion Alerts
# Purpose: Send visual/audible notifications when work completes
# Usage: Called from Stop and SubagentStop hooks

set -euo pipefail

# Source haunt environment configuration if exists
# This file is created by setup-haunt.sh with default settings
[[ -f ~/.haunt.env ]] && source ~/.haunt.env

# Configuration via environment variables (defaults if not set in ~/.haunt.env)
HAUNT_NOTIFY="${HAUNT_NOTIFY:-false}"           # Master switch (true/false)
HAUNT_NOTIFY_SOUND="${HAUNT_NOTIFY_SOUND:-false}"  # Sound switch (true/false)

# Check master disable switch
if [[ "$HAUNT_NOTIFY" == "false" ]]; then
    exit 0  # Skip all notifications
fi

# Parse arguments
NOTIFICATION_TYPE="${1:-complete}"  # complete | input_needed | subagent
AGENT_TYPE="${2:-}"                 # Agent type for subagent notifications
TRANSCRIPT="${3:-}"                 # Transcript for analysis

# Notification messages and sounds
TITLE="Claude Code"
MESSAGE=""
SOUND=""

case "$NOTIFICATION_TYPE" in
    complete)
        MESSAGE="All work finished!"
        SOUND="/System/Library/Sounds/Glass.aiff"
        ;;
    input_needed)
        MESSAGE="Input needed"
        SOUND="/System/Library/Sounds/Submarine.aiff"
        ;;
    subagent)
        if [[ -n "$AGENT_TYPE" ]]; then
            MESSAGE="Agent ${AGENT_TYPE} finished"
        else
            MESSAGE="Subagent finished"
        fi
        SOUND="/System/Library/Sounds/Ping.aiff"
        ;;
    *)
        MESSAGE="Work complete"
        SOUND="/System/Library/Sounds/Glass.aiff"
        ;;
esac

# Send macOS notification (visual)
osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null || true

# Send audible alert (if enabled)
if [[ "$HAUNT_NOTIFY_SOUND" != "false" && -f "$SOUND" ]]; then
    afplay "$SOUND" &
fi

exit 0
