#!/usr/bin/env bash
# Test suite for haunt-secrets.sh tag parser

set -euo pipefail

# Source the script under test (will be created)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/scripts/haunt-secrets.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test utilities
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    # Case-insensitive check using tr
    local haystack_lower=$(echo "$haystack" | tr '[:upper:]' '[:lower:]')
    local needle_lower=$(echo "$needle" | tr '[:upper:]' '[:lower:]')

    if [[ "$haystack_lower" == *"$needle_lower"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $message"
        echo "  Haystack: $haystack"
        echo "  Needle:   $needle"
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local message="${2:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ -n "$value" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $message"
        echo "  Expected non-empty value"
        return 1
    fi
}

# Test: Valid tag format parsing
test_valid_tag_format() {
    echo "TEST: Valid tag format parsing"

    # Create temp .env file with valid tag
    local temp_env=$(mktemp)
    cat > "$temp_env" <<EOF
# @secret:op:ghost-county/api-keys/github-token
GITHUB_TOKEN=placeholder
EOF

    # Parse the file
    parse_secret_tags "$temp_env"

    # Verify output contains parsed components
    # Expected format: GITHUB_TOKEN ghost-county api-keys github-token
    local output=$(parse_secret_tags "$temp_env")

    assert_contains "$output" "GITHUB_TOKEN" "Should extract variable name"
    assert_contains "$output" "ghost-county" "Should extract vault name"
    assert_contains "$output" "api-keys" "Should extract item name"
    assert_contains "$output" "github-token" "Should extract field name"

    rm -f "$temp_env"
}

# Test: Multiple tags in one file
test_multiple_tags() {
    echo "TEST: Multiple tags parsing"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<EOF
# @secret:op:ghost-county/api-keys/github-token
GITHUB_TOKEN=placeholder

# @secret:op:ghost-county/database/postgres-password
DATABASE_PASSWORD=placeholder

# Regular comment
REGULAR_VAR=value
EOF

    local output=$(parse_secret_tags "$temp_env")

    assert_contains "$output" "GITHUB_TOKEN" "Should parse first secret tag"
    assert_contains "$output" "DATABASE_PASSWORD" "Should parse second secret tag"
    assert_not_empty "$output" "Should return non-empty output"

    rm -f "$temp_env"
}

# Test: Invalid tag format - missing vault
test_invalid_tag_missing_vault() {
    echo "TEST: Invalid tag format - missing vault"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<EOF
# @secret:op:/api-keys/github-token
GITHUB_TOKEN=placeholder
EOF

    # Should fail with clear error message
    local output=$(parse_secret_tags "$temp_env" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"
    assert_contains "$output" "malformed" "Should indicate malformed tag"

    rm -f "$temp_env"
}

# Test: Invalid tag format - missing item
test_invalid_tag_missing_item() {
    echo "TEST: Invalid tag format - missing item"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<EOF
# @secret:op:ghost-county//github-token
GITHUB_TOKEN=placeholder
EOF

    local output=$(parse_secret_tags "$temp_env" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"
    assert_contains "$output" "malformed" "Should indicate malformed tag"

    rm -f "$temp_env"
}

# Test: Invalid tag format - missing field
test_invalid_tag_missing_field() {
    echo "TEST: Invalid tag format - missing field"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<EOF
# @secret:op:ghost-county/api-keys/
GITHUB_TOKEN=placeholder
EOF

    local output=$(parse_secret_tags "$temp_env" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"
    assert_contains "$output" "malformed" "Should indicate malformed tag"

    rm -f "$temp_env"
}

# Test: Tag not followed by variable
test_tag_without_variable() {
    echo "TEST: Tag not followed by variable"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<EOF
# @secret:op:ghost-county/api-keys/github-token
# Just another comment, no variable
EOF

    local output=$(parse_secret_tags "$temp_env" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"
    assert_contains "$output" "variable" "Should mention missing variable"

    rm -f "$temp_env"
}

# Test: Empty file
test_empty_file() {
    echo "TEST: Empty file"

    local temp_env=$(mktemp)
    # Empty file

    local output=$(parse_secret_tags "$temp_env" 2>&1 || true)

    # Should not error on empty file, just return empty result
    # (This is NOT an error condition)
    echo "Empty file output: $output"

    rm -f "$temp_env"
}

# Test: File with no secret tags
test_no_secret_tags() {
    echo "TEST: File with no secret tags"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<EOF
# Regular comment
REGULAR_VAR=value
ANOTHER_VAR=another_value
EOF

    local output=$(parse_secret_tags "$temp_env" 2>&1 || true)

    # Should not error, just return empty result for secrets
    echo "No tags output: $output"

    rm -f "$temp_env"
}

# Test: Malformed tag - wrong prefix
test_malformed_tag_wrong_prefix() {
    echo "TEST: Malformed tag - wrong prefix"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<EOF
# @secret:aws:ghost-county/api-keys/github-token
GITHUB_TOKEN=placeholder
EOF

    local output=$(parse_secret_tags "$temp_env" 2>&1 || true)

    # Should skip non-op tags or error
    echo "Wrong prefix output: $output"

    rm -f "$temp_env"
}

# Test: Special characters in vault/item/field names
test_special_characters() {
    echo "TEST: Special characters in names"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<EOF
# @secret:op:ghost-county/api-keys-prod/github-token-v2
GITHUB_TOKEN=placeholder
EOF

    local output=$(parse_secret_tags "$temp_env")

    assert_contains "$output" "api-keys-prod" "Should handle hyphens in item name"
    assert_contains "$output" "github-token-v2" "Should handle hyphens and numbers in field name"

    rm -f "$temp_env"
}

# Test: fetch_secret with missing OP_SERVICE_ACCOUNT_TOKEN
test_fetch_secret_missing_token() {
    echo "TEST: fetch_secret without OP_SERVICE_ACCOUNT_TOKEN"

    # Unset token if it exists
    unset OP_SERVICE_ACCOUNT_TOKEN || true

    # Attempt to fetch secret
    local output=$(fetch_secret "ghost-county" "api-keys" "github-token" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"
    assert_contains "$output" "OP_SERVICE_ACCOUNT_TOKEN" "Should mention missing token"
}

# Test: fetch_secret when op CLI not installed
test_fetch_secret_op_not_installed() {
    echo "TEST: fetch_secret when op CLI not installed"

    # Mock 'op' command to simulate not found
    # We'll override PATH to prevent finding real 'op'
    local temp_bin=$(mktemp -d)
    export PATH="$temp_bin:$PATH"

    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Attempt to fetch secret
    local output=$(fetch_secret "ghost-county" "api-keys" "github-token" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"
    assert_contains "$output" "op" "Should mention op CLI"

    # Cleanup
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN
}

# Test: fetch_secret success
test_fetch_secret_success() {
    echo "TEST: fetch_secret success"

    # Mock successful 'op' command
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
# Mock op CLI that returns test secret
if [[ "$1" == "read" && "$2" =~ ^op://(.+)/(.+)/(.+)$ ]]; then
    echo "test-secret-value-12345"
    exit 0
fi
exit 1
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Fetch secret
    local output=$(fetch_secret "ghost-county" "api-keys" "github-token" 2>&1)

    assert_equals "test-secret-value-12345" "$output" "Should return secret value"

    # Cleanup
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN
}

# Test: fetch_secret authentication failure
test_fetch_secret_auth_failure() {
    echo "TEST: fetch_secret authentication failure"

    # Mock 'op' command that fails with auth error
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
echo "ERROR: Authentication failed" >&2
exit 1
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="invalid-token"

    # Attempt to fetch secret
    local output=$(fetch_secret "ghost-county" "api-keys" "github-token" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"
    assert_contains "$output" "auth" "Should mention authentication failure"

    # Cleanup
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN
}

# Test: fetch_secret network timeout
test_fetch_secret_network_timeout() {
    echo "TEST: fetch_secret network timeout"

    # Mock 'op' command that simulates timeout
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
echo "ERROR: Network timeout" >&2
exit 1
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Attempt to fetch secret
    local output=$(fetch_secret "ghost-county" "api-keys" "github-token" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"

    # Cleanup
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN
}

# Test: fetch_secret item not found
test_fetch_secret_item_not_found() {
    echo "TEST: fetch_secret item not found"

    # Mock 'op' command that returns item not found
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
echo "ERROR: Item not found" >&2
exit 1
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Attempt to fetch secret
    local output=$(fetch_secret "ghost-county" "api-keys" "github-token" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"

    # Cleanup
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN
}

# ==============================================================================
# E2E Tests for load_secrets()
# ==============================================================================

# Test: load_secrets - successful load with mixed secrets and plaintext
test_load_secrets_mixed_env() {
    echo "TEST: load_secrets with mixed secrets and plaintext variables"

    # Create test .env file with tagged secrets and plaintext
    local temp_env=$(mktemp)
    cat > "$temp_env" <<'EOF'
# @secret:op:ghost-county/api-keys/github-token
GITHUB_TOKEN=placeholder

# @secret:op:ghost-county/database/postgres-password
DATABASE_PASSWORD=placeholder

# Regular plaintext variable (no tag)
DATABASE_URL=postgres://localhost/dev
API_BASE_URL=https://api.example.com
EOF

    # Mock successful 'op' command
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
# Mock op CLI - return different secrets based on field name
if [[ "$2" =~ op://ghost-county/api-keys/github-token ]]; then
    echo "ghp_test_token_12345"
    exit 0
elif [[ "$2" =~ op://ghost-county/database/postgres-password ]]; then
    echo "secure_pg_password_67890"
    exit 0
fi
exit 1
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Load secrets (capture stderr for logging verification, run directly for exports)
    local temp_log=$(mktemp)
    load_secrets "$temp_env" 2> "$temp_log"
    local output=$(cat "$temp_log")
    rm -f "$temp_log"

    # Verify logging shows variable names (NOT values)
    assert_contains "$output" "GITHUB_TOKEN" "Should log loaded secret name"
    assert_contains "$output" "DATABASE_PASSWORD" "Should log loaded secret name"

    # Verify logging does NOT contain secret values
    if [[ "$output" =~ ghp_test_token_12345|secure_pg_password_67890 ]]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: Should NOT log secret values"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: Does not log secret values"
    fi

    # Verify secrets are exported to environment
    assert_equals "ghp_test_token_12345" "${GITHUB_TOKEN:-}" "GITHUB_TOKEN should be exported"
    assert_equals "secure_pg_password_67890" "${DATABASE_PASSWORD:-}" "DATABASE_PASSWORD should be exported"

    # Verify plaintext variables are exported as-is
    assert_equals "postgres://localhost/dev" "${DATABASE_URL:-}" "DATABASE_URL should be exported"
    assert_equals "https://api.example.com" "${API_BASE_URL:-}" "API_BASE_URL should be exported"

    # Cleanup
    rm -f "$temp_env"
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN GITHUB_TOKEN DATABASE_PASSWORD DATABASE_URL API_BASE_URL
}

# Test: load_secrets - .env file not found
test_load_secrets_file_not_found() {
    echo "TEST: load_secrets with non-existent .env file"

    # Attempt to load non-existent file
    local output=$(load_secrets "/path/that/does/not/exist/.env" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"
    assert_contains "$output" "not found" "Should indicate file not found"
}

# Test: load_secrets - empty .env file
test_load_secrets_empty_file() {
    echo "TEST: load_secrets with empty .env file"

    local temp_env=$(mktemp)
    # Empty file

    # Should not error, just do nothing
    local output=$(load_secrets "$temp_env" 2>&1 || true)

    echo "Empty file output: $output"

    rm -f "$temp_env"
}

# Test: load_secrets - no secrets, only plaintext
test_load_secrets_plaintext_only() {
    echo "TEST: load_secrets with only plaintext variables"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<'EOF'
DATABASE_URL=postgres://localhost/dev
API_KEY=hardcoded-key-for-dev
EOF

    # Run directly to preserve exports
    load_secrets "$temp_env" > /dev/null 2>&1 || true

    # Verify plaintext variables are exported
    assert_equals "postgres://localhost/dev" "${DATABASE_URL:-}" "DATABASE_URL should be exported"
    assert_equals "hardcoded-key-for-dev" "${API_KEY:-}" "API_KEY should be exported"

    rm -f "$temp_env"
    unset DATABASE_URL API_KEY
}

# Test: load_secrets - secret fetch failure
test_load_secrets_fetch_failure() {
    echo "TEST: load_secrets when secret fetch fails"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<'EOF'
# @secret:op:ghost-county/api-keys/github-token
GITHUB_TOKEN=placeholder
EOF

    # Mock 'op' command that fails
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
echo "ERROR: Authentication failed" >&2
exit 1
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Should fail with clear error
    local output=$(load_secrets "$temp_env" 2>&1 || true)

    assert_contains "$output" "error" "Should contain error message"
    assert_contains "$output" "failed" "Should indicate fetch failed"

    # Variable should NOT be set
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: GITHUB_TOKEN not set on fetch failure"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: GITHUB_TOKEN should not be set on fetch failure"
    fi

    rm -f "$temp_env"
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN GITHUB_TOKEN
}

# Test: load_secrets - can be sourced
test_load_secrets_sourceable() {
    echo "TEST: load_secrets can be sourced and used"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<'EOF'
# @secret:op:ghost-county/api-keys/test-key
TEST_KEY=placeholder
EOF

    # Mock successful 'op' command
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
echo "secret-value-abc123"
exit 0
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Source the script and call load_secrets
    # (Already sourced at top of test file)
    load_secrets "$temp_env" > /dev/null 2>&1

    # Verify variable is accessible in current shell
    assert_equals "secret-value-abc123" "${TEST_KEY:-}" "TEST_KEY should be accessible after sourcing"

    rm -f "$temp_env"
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN TEST_KEY
}

# Test: load_secrets - logging format verification
test_load_secrets_logging_format() {
    echo "TEST: load_secrets logging format"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<'EOF'
# @secret:op:ghost-county/api-keys/key1
KEY1=placeholder

# @secret:op:ghost-county/api-keys/key2
KEY2=placeholder
EOF

    # Mock successful 'op' command
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
echo "secret-value"
exit 0
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Capture stderr output
    local temp_log=$(mktemp)
    load_secrets "$temp_env" 2> "$temp_log"
    local output=$(cat "$temp_log")
    rm -f "$temp_log"

    # Verify logging shows summary
    assert_contains "$output" "loaded" "Should show loaded message"

    # Verify variable names are listed (comma or space separated)
    assert_contains "$output" "KEY1" "Should list KEY1"
    assert_contains "$output" "KEY2" "Should list KEY2"

    rm -f "$temp_env"
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN KEY1 KEY2
}

# Run all tests
main() {
    echo "========================================"
    echo "haunt-secrets.sh Test Suite"
    echo "========================================"
    echo ""

    test_valid_tag_format
    echo ""
    test_multiple_tags
    echo ""
    test_invalid_tag_missing_vault
    echo ""
    test_invalid_tag_missing_item
    echo ""
    test_invalid_tag_missing_field
    echo ""
    test_tag_without_variable
    echo ""
    test_empty_file
    echo ""
    test_no_secret_tags
    echo ""
    test_malformed_tag_wrong_prefix
    echo ""
    test_special_characters
    echo ""
    test_fetch_secret_missing_token
    echo ""
    test_fetch_secret_op_not_installed
    echo ""
    test_fetch_secret_success
    echo ""
    test_fetch_secret_auth_failure
    echo ""
    test_fetch_secret_network_timeout
    echo ""
    test_fetch_secret_item_not_found
    echo ""
    test_load_secrets_mixed_env
    echo ""
    test_load_secrets_file_not_found
    echo ""
    test_load_secrets_empty_file
    echo ""
    test_load_secrets_plaintext_only
    echo ""
    test_load_secrets_fetch_failure
    echo ""
    test_load_secrets_sourceable
    echo ""
    test_load_secrets_logging_format
    echo ""

    echo "========================================"
    echo "Test Results"
    echo "========================================"
    echo "Tests run:    $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "✓ All tests passed!"
        exit 0
    else
        echo "✗ Some tests failed"
        exit 1
    fi
}

main "$@"
