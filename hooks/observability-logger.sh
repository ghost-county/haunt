#!/bin/bash
set -euo pipefail

# Global disable check
if [[ "${HAUNT_HOOKS_DISABLED:-0}" == "1" ]]; then
    exit 0
fi

# Seance gate: only enforce during active seance
SENTINEL="${PWD}/.haunt/active-session"
[[ -f "$SENTINEL" ]] || exit 0

# Require jq
command -v jq >/dev/null 2>&1 || exit 0

# Read hook input from stdin
INPUT=$(cat)

# Extract all fields in a single jq invocation
read -r TOOL_NAME FILE_PATH CWD < <(echo "$INPUT" | jq -r '[(.tool_name // "unknown"), (.tool_input.file_path // .tool_input.command // .tool_input.pattern // ""), (.cwd // "")] | @tsv')

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Determine project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$CWD}"

# Only log if we're in a project with .haunt/
if [[ -z "$PROJECT_DIR" ]] || [[ "$PROJECT_DIR" == "null" ]] || [[ ! -d "$PROJECT_DIR/.haunt" ]]; then
    exit 0
fi

# Create logs directory if needed
LOG_DIR="$PROJECT_DIR/.haunt/logs"
mkdir -p "$LOG_DIR"

# Append structured JSON log entry (use jq to safely escape values)
LOG_FILE="$LOG_DIR/tool-usage.jsonl"
jq -nc --arg ts "$TIMESTAMP" --arg tool "$TOOL_NAME" --arg target "$FILE_PATH" --arg cwd "$CWD" \
    '{timestamp:$ts,tool:$tool,target:$target,cwd:$cwd}' >> "$LOG_FILE"

exit 0
