#!/bin/bash

# Test suite for haunt-secrets.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HAUNT_SECRETS_SCRIPT="$SECRETS_DIR/../scripts/haunt-secrets.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test result reporting
pass_test() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

fail_test() {
    echo -e "${RED}✗${NC} $1"
    echo -e "  ${RED}Reason: $2${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Mock op command for testing
setup_mock_op() {
    local mock_dir="$1"
    cat > "$mock_dir/op" <<'EOF'
#!/bin/bash
# Mock 1Password CLI

case "$1" in
    "read")
        # Parse op://vault/item/field format
        ref="$2"
        if [[ "$ref" == "op://test/api-key/token" ]]; then
            echo "secret_token_12345"
        elif [[ "$ref" == "op://test/database/password" ]]; then
            echo "db_pass_67890"
        else
            echo "Error: secret not found for $ref" >&2
            exit 1
        fi
        ;;
    *)
        echo "Unknown command: $1" >&2
        exit 1
        ;;
esac
EOF
    chmod +x "$mock_dir/op"
    export PATH="$mock_dir:$PATH"
}

# Create temporary test environment
setup_test_env() {
    TEST_DIR=$(mktemp -d)
    MOCK_BIN_DIR="$TEST_DIR/bin"
    mkdir -p "$MOCK_BIN_DIR"
    setup_mock_op "$MOCK_BIN_DIR"
    export OP_SERVICE_ACCOUNT_TOKEN="test_token"
}

# Cleanup test environment
cleanup_test_env() {
    rm -rf "$TEST_DIR"
    unset OP_SERVICE_ACCOUNT_TOKEN
}

# Test 1: Success case - loads secrets and exports variables
test_success_case() {
    echo -e "\n${YELLOW}Test 1: Success case - loads secrets and exports variables${NC}"

    setup_test_env

    # Create test .env file
    cat > "$TEST_DIR/.env" <<EOF
# Plain variable
PLAIN_VAR=plaintext_value

# Secret from 1Password
# @secret:op:test/api-key/token
SECRET_API_KEY=placeholder

# Another plain variable
ANOTHER_VAR=another_value

# Another secret
# @secret:op:test/database/password
DB_PASSWORD=placeholder
EOF

    # Source the script (should export variables)
    # Note: Must run in same shell context to preserve exports
    (
        set +e  # Disable exit-on-error for sourcing
        source "$HAUNT_SECRETS_SCRIPT" "$TEST_DIR/.env" 2>/dev/null
        result=$?

        if [[ $result -ne 0 ]]; then
            echo "FAIL:Script execution failed with exit code $result"
            exit 1
        fi

        # Verify exports in same shell context
        if [[ "$PLAIN_VAR" != "plaintext_value" ]]; then
            echo "FAIL:PLAIN_VAR:Expected 'plaintext_value', got '$PLAIN_VAR'"
            exit 1
        fi

        if [[ "$SECRET_API_KEY" != "secret_token_12345" ]]; then
            echo "FAIL:SECRET_API_KEY:Expected 'secret_token_12345', got '$SECRET_API_KEY'"
            exit 1
        fi

        if [[ "$DB_PASSWORD" != "db_pass_67890" ]]; then
            echo "FAIL:DB_PASSWORD:Expected 'db_pass_67890', got '$DB_PASSWORD'"
            exit 1
        fi

        echo "PASS:All variables"
        exit 0
    )

    test_result=$?
    if [[ $test_result -eq 0 ]]; then
        pass_test "Plain variable PLAIN_VAR exported correctly"
        pass_test "Secret SECRET_API_KEY loaded from 1Password"
        pass_test "Secret DB_PASSWORD loaded from 1Password"
    else
        fail_test "Variable verification failed" "See output above"
    fi

    cleanup_test_env
}

# Test 2: Missing token - should fail with exit code 1
test_missing_token() {
    echo -e "\n${YELLOW}Test 2: Missing token - should fail with exit code 1${NC}"

    setup_test_env
    unset OP_SERVICE_ACCOUNT_TOKEN

    cat > "$TEST_DIR/.env" <<EOF
# @secret:op:test/api-key/token
SECRET_API_KEY=placeholder
EOF

    # Capture output and exit code
    if output=$(bash "$HAUNT_SECRETS_SCRIPT" "$TEST_DIR/.env" 2>&1); then
        fail_test "Script should fail without OP_SERVICE_ACCOUNT_TOKEN" "Expected exit code 1, got 0"
    else
        exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            pass_test "Script fails with exit code 1 when token missing"
        else
            fail_test "Wrong exit code" "Expected 1, got $exit_code"
        fi

        if echo "$output" | grep -q "OP_SERVICE_ACCOUNT_TOKEN"; then
            pass_test "Error message mentions missing token"
        else
            fail_test "Error message should mention OP_SERVICE_ACCOUNT_TOKEN" "Output: $output"
        fi
    fi

    cleanup_test_env
}

# Test 3: op command failure - should fail with exit code 2
test_op_failure() {
    echo -e "\n${YELLOW}Test 3: op command failure - should fail with exit code 2${NC}"

    setup_test_env

    cat > "$TEST_DIR/.env" <<EOF
# @secret:op:invalid/path/field
INVALID_SECRET=placeholder
EOF

    if output=$(bash "$HAUNT_SECRETS_SCRIPT" "$TEST_DIR/.env" 2>&1); then
        fail_test "Script should fail when op read fails" "Expected exit code 2, got 0"
    else
        exit_code=$?
        if [[ $exit_code -eq 2 ]]; then
            pass_test "Script fails with exit code 2 when op read fails"
        else
            fail_test "Wrong exit code" "Expected 2, got $exit_code"
        fi
    fi

    cleanup_test_env
}

# Test 4: Missing .env file - should fail with exit code 3
test_missing_file() {
    echo -e "\n${YELLOW}Test 4: Missing .env file - should fail with exit code 3${NC}"

    setup_test_env

    if output=$(bash "$HAUNT_SECRETS_SCRIPT" "$TEST_DIR/nonexistent.env" 2>&1); then
        fail_test "Script should fail when .env file missing" "Expected exit code 3, got 0"
    else
        exit_code=$?
        if [[ $exit_code -eq 3 ]]; then
            pass_test "Script fails with exit code 3 when .env file missing"
        else
            fail_test "Wrong exit code" "Expected 3, got $exit_code"
        fi

        if echo "$output" | grep -q "not found"; then
            pass_test "Error message mentions file not found"
        else
            fail_test "Error message should mention missing file" "Output: $output"
        fi
    fi

    cleanup_test_env
}

# Test 5: No secrets in output - verify security
test_no_secrets_in_output() {
    echo -e "\n${YELLOW}Test 5: No secrets in output - verify security${NC}"

    setup_test_env

    cat > "$TEST_DIR/.env" <<EOF
# @secret:op:test/api-key/token
SECRET_API_KEY=placeholder
EOF

    output=$(bash "$HAUNT_SECRETS_SCRIPT" "$TEST_DIR/.env" 2>&1 || true)

    if echo "$output" | grep -q "secret_token_12345"; then
        fail_test "Secret value appears in output" "Found 'secret_token_12345' in output"
    else
        pass_test "Secret values not printed to output"
    fi

    cleanup_test_env
}

# Run all tests
main() {
    echo "================================="
    echo "Bash Secrets Wrapper Test Suite"
    echo "================================="

    # Check if script exists (it shouldn't yet - TDD!)
    if [[ ! -f "$HAUNT_SECRETS_SCRIPT" ]]; then
        echo -e "${YELLOW}Note: $HAUNT_SECRETS_SCRIPT not found (expected in TDD RED phase)${NC}"
    fi

    test_success_case
    test_missing_token
    test_op_failure
    test_missing_file
    test_no_secrets_in_output

    echo ""
    echo "================================="
    echo "Test Results"
    echo "================================="
    echo -e "Total: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
