#!/bin/bash
# Scenario: Completion Gate Enforcement
# Tests that the completion gate script exists, has valid syntax, and
# correctly enforces the verification timestamp window.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
GATE_SCRIPT="$REPO_ROOT/Haunt/hooks/completion-gate.sh"

PASS=0
FAIL=0

check() {
    local desc="$1"
    local condition="$2"
    if eval "$condition"; then
        echo "  ok  $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL $desc"
        FAIL=$((FAIL + 1))
    fi
}

echo "Scenario: Completion Gate Enforcement"

# 1. Script exists
check "completion-gate.sh exists" "[[ -f '$GATE_SCRIPT' ]]"

# 2. Valid bash syntax
if bash -n "$GATE_SCRIPT" 2>/dev/null; then
    echo "  ok  completion-gate.sh has valid bash syntax"
    PASS=$((PASS + 1))
else
    echo "  FAIL completion-gate.sh has syntax errors"
    FAIL=$((FAIL + 1))
fi

# 3. Script is executable
check "completion-gate.sh is executable" "[[ -x '$GATE_SCRIPT' ]]"

# 4. Test stale verification rejection
# Create a temp directory simulating the project root (.haunt/progress/ lives inside)
TMPDIR_HAUNT="$(mktemp -d)"
PROGRESS_DIR="$TMPDIR_HAUNT/.haunt/progress"
mkdir -p "$PROGRESS_DIR"
VERIFY_FILE="$PROGRESS_DIR/REQ-999-verified.txt"

# Write the file with an old timestamp (2 hours ago)
echo "verified" > "$VERIFY_FILE"
if [[ "$(uname)" == "Darwin" ]]; then
    touch -t "$(date -v-2H '+%Y%m%d%H%M.%S')" "$VERIFY_FILE"
else
    touch -d "2 hours ago" "$VERIFY_FILE"
fi

# Build a fake hook input that targets a roadmap file and marks REQ-TEST complete
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

if [[ $STALE_EXIT -ne 0 ]]; then
    echo "  ok  stale verification correctly rejected (exit $STALE_EXIT)"
    PASS=$((PASS + 1))
else
    echo "  FAIL stale verification was not rejected (expected non-zero exit)"
    FAIL=$((FAIL + 1))
fi

# 5. Test fresh verification acceptance
# Touch the file with current time
touch "$VERIFY_FILE"

set +e
echo "$FAKE_INPUT" | CLAUDE_PROJECT_DIR="$TMPDIR_HAUNT" bash "$GATE_SCRIPT" >/dev/null 2>&1
FRESH_EXIT=$?
set -e

if [[ $FRESH_EXIT -eq 0 ]]; then
    echo "  ok  fresh verification correctly accepted (exit 0)"
    PASS=$((PASS + 1))
else
    echo "  FAIL fresh verification was rejected (expected exit 0, got $FRESH_EXIT)"
    FAIL=$((FAIL + 1))
fi

# Cleanup temp dir
rm -rf "$TMPDIR_HAUNT"

echo ""
echo "Results: $PASS passed, $FAIL failed"

[[ $FAIL -eq 0 ]]
