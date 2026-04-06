#!/bin/bash
# Scenario: Completion Gate Enforcement
# Tests that the completion gate script exists, has valid syntax, and
# correctly enforces the verification timestamp window.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
GATE_SCRIPT="$REPO_ROOT/Haunt/hooks/completion-gate.sh"
source "$(dirname "${BASH_SOURCE[0]}")/eval-lib.sh"

echo "Scenario: Completion Gate Enforcement"

# 1. Script exists and is valid
check_file "completion-gate.sh exists" "$GATE_SCRIPT"
check_syntax "completion-gate.sh has valid bash syntax" "$GATE_SCRIPT"
check_exec "completion-gate.sh is executable" "$GATE_SCRIPT"

# 4. Test stale verification rejection
TMPDIR_HAUNT="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_HAUNT"' EXIT
PROGRESS_DIR="$TMPDIR_HAUNT/.haunt/progress"
mkdir -p "$PROGRESS_DIR"
VERIFY_FILE="$PROGRESS_DIR/REQ-999-verified.txt"

echo "verified" > "$VERIFY_FILE"
if [[ "$(uname)" == "Darwin" ]]; then
    touch -t "$(date -v-2H '+%Y%m%d%H%M.%S')" "$VERIFY_FILE"
else
    touch -d "2 hours ago" "$VERIFY_FILE"
fi

FAKE_INPUT=$(cat <<EOF
{
  "tool_input": {
    "file_path": "/tmp/roadmap.md",
    "new_string": "### { 🟢 } REQ-999 Complete"
  },
  "cwd": "$TMPDIR_HAUNT"
}
EOF
)

# Gate should reject stale verification (exit 2)
set +e
echo "$FAKE_INPUT" | CLAUDE_PROJECT_DIR="$TMPDIR_HAUNT" bash "$GATE_SCRIPT" >/dev/null 2>&1
STALE_EXIT=$?
set -e

check_nonzero_exit "stale verification correctly rejected (exit $STALE_EXIT)" "$STALE_EXIT"

# 5. Test fresh verification acceptance
touch "$VERIFY_FILE"

set +e
echo "$FAKE_INPUT" | CLAUDE_PROJECT_DIR="$TMPDIR_HAUNT" bash "$GATE_SCRIPT" >/dev/null 2>&1
FRESH_EXIT=$?
set -e

check_exit "fresh verification correctly accepted" 0 "$FRESH_EXIT"

report_results
