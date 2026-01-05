#!/bin/bash
# Damage Control Hook Test Suite
# Tests bash-tool-damage-control.py and edit-write-tool-damage-control.py

set -e

HOOKS_DIR="$HOME/.claude/hooks/damage-control"
BASH_HOOK="$HOOKS_DIR/bash-tool-damage-control.py"
EDIT_HOOK="$HOOKS_DIR/edit-write-tool-damage-control.py"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

# Test bash hook
test_bash_hook() {
    local cmd="$1"
    local expected_exit="$2"
    local test_name="$3"

    # Create JSON input for hook
    local json_input=$(cat <<EOF
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "$cmd"
  }
}
EOF
)

    # Run hook and capture exit code
    set +e
    echo "$json_input" | uv run "$BASH_HOOK" > /dev/null 2>&1
    local actual_exit=$?
    set -e

    if [ "$actual_exit" -eq "$expected_exit" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name (exit $actual_exit)"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name (expected exit $expected_exit, got $actual_exit)"
        ((FAIL_COUNT++))
    fi
}

# Test edit/write hook
test_edit_write_hook() {
    local tool_name="$1"
    local file_path="$2"
    local expected_exit="$3"
    local test_name="$4"

    # Create JSON input for hook
    local json_input=$(cat <<EOF
{
  "tool_name": "$tool_name",
  "tool_input": {
    "file_path": "$file_path"
  }
}
EOF
)

    # Run hook and capture exit code
    set +e
    echo "$json_input" | uv run "$EDIT_HOOK" > /dev/null 2>&1
    local actual_exit=$?
    set -e

    if [ "$actual_exit" -eq "$expected_exit" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name (exit $actual_exit)"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name (expected exit $expected_exit, got $actual_exit)"
        ((FAIL_COUNT++))
    fi
}

echo "========================================"
echo "Damage Control Hooks Test Suite"
echo "========================================"
echo ""

# Verify hooks exist
if [ ! -f "$BASH_HOOK" ]; then
    echo -e "${RED}ERROR: Bash hook not found at $BASH_HOOK${NC}"
    exit 1
fi

if [ ! -f "$EDIT_HOOK" ]; then
    echo -e "${RED}ERROR: Edit/Write hook not found at $EDIT_HOOK${NC}"
    exit 1
fi

echo -e "${BLUE}Hooks verified:${NC}"
echo "  - Bash Tool: $BASH_HOOK"
echo "  - Edit/Write Tool: $EDIT_HOOK"
echo ""

# BLOCK Tests - Bash Tool
echo -e "${YELLOW}=== BLOCK Tests (Bash Tool) ===${NC}"
test_bash_hook "rm -rf /" 2 "rm -rf / (root filesystem)"
test_bash_hook "rm -rf ~" 2 "rm -rf ~ (home directory)"
test_bash_hook "rm -rf \$HOME" 2 "rm -rf \$HOME (home variable)"
test_bash_hook "rm -rf *" 2 "rm -rf * (wildcard)"
test_bash_hook "rm -rf .." 2 "rm -rf .. (parent directory)"
test_bash_hook "rm -rf .git" 2 "rm -rf .git (git directory)"
test_bash_hook "chmod 777 file.txt" 2 "chmod 777 (insecure permissions)"
test_bash_hook "chmod -R 777 ." 2 "chmod -R 777 (recursive insecure)"
test_bash_hook "DELETE FROM users;" 2 "DELETE FROM (unguarded SQL)"
test_bash_hook "DROP TABLE users;" 2 "DROP TABLE (unguarded SQL)"
echo ""

# BLOCK Tests - Edit/Write Tool
echo -e "${YELLOW}=== BLOCK Tests (Edit/Write Tool) ===${NC}"
test_edit_write_hook "Edit" "~/.ssh/id_rsa" 2 "Edit ~/.ssh/id_rsa (SSH key)"
test_edit_write_hook "Write" "~/.ssh/config" 2 "Write ~/.ssh/config (SSH config)"
test_edit_write_hook "Edit" "~/.aws/credentials" 2 "Edit ~/.aws/credentials (AWS creds)"
test_edit_write_hook "Write" "~/.gnupg/private-key.asc" 2 "Write ~/.gnupg/key (GPG key)"
test_edit_write_hook "Edit" "/etc/passwd" 2 "Edit /etc/passwd (system file)"
test_edit_write_hook "Write" "/etc/shadow" 2 "Write /etc/shadow (system file)"
echo ""

# ALLOW Tests - Bash Tool
echo -e "${YELLOW}=== ALLOW Tests (Bash Tool) ===${NC}"
test_bash_hook "ls -la" 0 "ls -la (safe read)"
test_bash_hook "git status" 0 "git status (safe read)"
test_bash_hook "npm install" 0 "npm install (safe operation)"
test_bash_hook "cat /etc/passwd" 0 "cat /etc/passwd (read-only file)"
test_bash_hook "pytest tests/" 0 "pytest tests/ (test runner)"
test_bash_hook "docker ps" 0 "docker ps (docker command)"
echo ""

# ALLOW Tests - Edit/Write Tool
echo -e "${YELLOW}=== ALLOW Tests (Edit/Write Tool) ===${NC}"
test_edit_write_hook "Edit" "src/app.ts" 0 "Edit src/app.ts (normal file)"
test_edit_write_hook "Write" "README.md" 0 "Write README.md (normal file)"
test_edit_write_hook "Edit" "tests/test_feature.py" 0 "Edit tests/test_feature.py (test file)"
test_edit_write_hook "Write" "/tmp/test.txt" 0 "Write /tmp/test.txt (temp file)"
test_edit_write_hook "Edit" "package.json" 0 "Edit package.json (config file)"
test_edit_write_hook "Write" ".haunt/plans/roadmap.md" 0 "Write .haunt/plans/roadmap.md (roadmap)"
echo ""

# ASK Tests - Manual Verification Note
echo -e "${YELLOW}=== ASK Tests - Manual Verification Required ===${NC}"
echo "NOTE: ASK tests require interactive user input and cannot be fully automated."
echo "To manually verify ASK behavior:"
echo "  1. Run: rm -rf ./node_modules (should prompt for confirmation)"
echo "  2. Edit .env file (should prompt for confirmation)"
echo "  3. Verify user can approve or deny the operation"
echo ""

# Summary
echo "========================================"
echo -e "Test Summary: ${GREEN}${PASS_COUNT} passed${NC}, ${RED}${FAIL_COUNT} failed${NC}"
echo "========================================"

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo -e "${RED}FAILURE: Some tests did not pass${NC}"
    exit 1
else
    echo -e "${GREEN}SUCCESS: All automated tests passed${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review test-prompts.md for manual ASK test verification"
    echo "  2. Test hooks in real Claude Code session"
    echo "  3. Monitor for false positives/negatives"
    exit 0
fi
