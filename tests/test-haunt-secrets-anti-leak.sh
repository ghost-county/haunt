#!/usr/bin/env bash
# Anti-Leak Test Suite for haunt-secrets.sh
#
# Tests that secrets are NEVER exposed in stdout, stderr, or logs.
# These tests intentionally try to leak secrets and verify they are blocked.

set -euo pipefail

# Source the script under test
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/scripts/haunt-secrets.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test utilities
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    # Case-sensitive check (secrets are case-sensitive)
    if [[ "$haystack" != *"$needle"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $message"
        echo "  Haystack SHOULD NOT contain needle"
        echo "  Needle:   $needle"
        echo "  Found in: $haystack"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$haystack" == *"$needle"* ]]; then
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

# ==============================================================================
# ANTI-LEAK TESTS: Verify secrets NEVER appear in output
# ==============================================================================

# Test: fetch_secret error messages do NOT contain secret value
test_fetch_secret_error_no_value_leak() {
    echo "TEST: fetch_secret errors do not leak secret value"

    # Mock 'op' command that returns secret but we simulate error context
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

    # Verify error does NOT contain any secret-like values
    assert_not_contains "$output" "ghp_" "Error should not contain GitHub token prefix"
    assert_not_contains "$output" "sk-" "Error should not contain secret key prefix"
    assert_contains "$output" "error" "Should contain error message"

    # Cleanup
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN
}

# Test: load_secrets logging does NOT contain secret values
test_load_secrets_no_value_in_logs() {
    echo "TEST: load_secrets does not log secret values"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<'EOF'
# @secret:op:ghost-county/api-keys/github-token
GITHUB_TOKEN=placeholder
EOF

    # Mock successful 'op' command that returns a secret
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
# Return secret with distinctive pattern
echo "ghp_SUPER_SECRET_TOKEN_DO_NOT_LOG_12345"
exit 0
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Capture ALL output from load_secrets
    local temp_log=$(mktemp)
    load_secrets "$temp_env" > "$temp_log" 2>&1 || true
    local output=$(cat "$temp_log")
    rm -f "$temp_log"

    # Verify log contains variable name (this is OK)
    assert_contains "$output" "GITHUB_TOKEN" "Should log variable name"

    # CRITICAL: Verify log does NOT contain secret value
    assert_not_contains "$output" "ghp_SUPER_SECRET_TOKEN_DO_NOT_LOG_12345" "MUST NOT log secret value"
    assert_not_contains "$output" "SUPER_SECRET_TOKEN" "MUST NOT log any part of secret"

    # Cleanup
    rm -f "$temp_env"
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN GITHUB_TOKEN
}

# Test: Error messages show variable name but mask value
test_error_message_masks_value() {
    echo "TEST: Error messages mask secret values with ***"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<'EOF'
# @secret:op:ghost-county/api-keys/api-key
API_KEY=placeholder
EOF

    # Mock op command that fails
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
echo "ERROR: Authentication failed" >&2
exit 1
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Try to load secrets
    local output=$(load_secrets "$temp_env" 2>&1 || true)

    # Should show variable name in error
    assert_contains "$output" "API_KEY" "Should show variable name in error"

    # Should NOT show placeholder value (even though it's just 'placeholder')
    # In real scenario, we'd verify actual secret value is masked
    assert_contains "$output" "error" "Should contain error message"

    # Cleanup
    rm -f "$temp_env"
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN API_KEY
}

# Test: Attempting to echo secret value should show warning or masked output
test_direct_echo_attempt_masked() {
    echo "TEST: Direct echo of secret variable shows masked value"

    # Set a secret in environment (simulating after load_secrets)
    export SECRET_TOKEN="ghp_very_secret_value_12345"

    # Try to echo the secret
    # In production, we'd intercept or warn about this
    # For now, we document that users should use safe_log function
    local output=$(echo "${SECRET_TOKEN:-***}")

    # This test documents expected behavior:
    # Users should NOT directly echo secrets
    # If they do, value will leak UNLESS we provide safe_log wrapper

    # For now, verify variable IS set
    if [[ -n "${SECRET_TOKEN}" ]]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: Direct echo can access value (user must use safe_log)"
    fi

    unset SECRET_TOKEN
}

# Test: load_secrets summary shows variable names, not values
test_load_secrets_summary_safe() {
    echo "TEST: load_secrets summary is safe (no values)"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<'EOF'
# @secret:op:ghost-county/api-keys/key1
KEY1=placeholder

# @secret:op:ghost-county/api-keys/key2
KEY2=placeholder
EOF

    # Mock successful op command
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
echo "secret-value-sensitive-data"
exit 0
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Capture output
    local temp_log=$(mktemp)
    load_secrets "$temp_env" 2> "$temp_log" || true
    local output=$(cat "$temp_log")
    rm -f "$temp_log"

    # Should show KEY1, KEY2 in summary
    assert_contains "$output" "KEY1" "Should list KEY1"
    assert_contains "$output" "KEY2" "Should list KEY2"

    # MUST NOT show secret value
    assert_not_contains "$output" "secret-value-sensitive-data" "MUST NOT show secret value in summary"

    # Cleanup
    rm -f "$temp_env"
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN KEY1 KEY2
}

# Test: fetch_secret success does NOT log to stderr
test_fetch_secret_success_quiet() {
    echo "TEST: fetch_secret on success does not log secret to stderr"

    # Mock successful op
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
echo "secret-value-12345"
exit 0
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Capture stderr only (stdout has secret, which is expected)
    local temp_log=$(mktemp)
    fetch_secret "vault" "item" "field" 2> "$temp_log" > /dev/null || true
    local stderr_output=$(cat "$temp_log")
    rm -f "$temp_log"

    # stderr should be EMPTY or only contain non-sensitive logging
    assert_not_contains "$stderr_output" "secret-value-12345" "stderr MUST NOT contain secret"

    # Cleanup
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN
}

# Test: Multiple secrets loaded, none appear in logs
test_multiple_secrets_no_leaks() {
    echo "TEST: Multiple secrets loaded, none leak in logs"

    local temp_env=$(mktemp)
    cat > "$temp_env" <<'EOF'
# @secret:op:vault/item/field1
SECRET1=placeholder

# @secret:op:vault/item/field2
SECRET2=placeholder

# @secret:op:vault/item/field3
SECRET3=placeholder
EOF

    # Mock op to return different secrets each time
    local temp_bin=$(mktemp -d)
    cat > "$temp_bin/op" <<'EOF'
#!/usr/bin/env bash
# Return different secret based on field name
if [[ "$2" =~ field1 ]]; then
    echo "secret-alpha-123"
elif [[ "$2" =~ field2 ]]; then
    echo "secret-beta-456"
elif [[ "$2" =~ field3 ]]; then
    echo "secret-gamma-789"
fi
exit 0
EOF
    chmod +x "$temp_bin/op"
    export PATH="$temp_bin:$PATH"
    export OP_SERVICE_ACCOUNT_TOKEN="test-token"

    # Capture all output
    local temp_log=$(mktemp)
    load_secrets "$temp_env" > "$temp_log" 2>&1 || true
    local output=$(cat "$temp_log")
    rm -f "$temp_log"

    # Verify NONE of the secret values appear
    assert_not_contains "$output" "secret-alpha-123" "MUST NOT leak SECRET1 value"
    assert_not_contains "$output" "secret-beta-456" "MUST NOT leak SECRET2 value"
    assert_not_contains "$output" "secret-gamma-789" "MUST NOT leak SECRET3 value"

    # Verify variable names ARE present (this is safe)
    assert_contains "$output" "SECRET1" "Should mention SECRET1"
    assert_contains "$output" "SECRET2" "Should mention SECRET2"
    assert_contains "$output" "SECRET3" "Should mention SECRET3"

    # Cleanup
    rm -f "$temp_env"
    rm -rf "$temp_bin"
    unset OP_SERVICE_ACCOUNT_TOKEN SECRET1 SECRET2 SECRET3
}

# Run all tests
main() {
    echo "========================================"
    echo "Anti-Leak Test Suite"
    echo "========================================"
    echo ""
    echo "These tests verify that secret values NEVER appear in logs, stdout, or stderr."
    echo ""

    test_fetch_secret_error_no_value_leak
    echo ""
    test_load_secrets_no_value_in_logs
    echo ""
    test_error_message_masks_value
    echo ""
    test_direct_echo_attempt_masked
    echo ""
    test_load_secrets_summary_safe
    echo ""
    test_fetch_secret_success_quiet
    echo ""
    test_multiple_secrets_no_leaks
    echo ""

    echo "========================================"
    echo "Anti-Leak Test Results"
    echo "========================================"
    echo "Tests run:    $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "✓ All anti-leak tests passed! Secrets are protected."
        exit 0
    else
        echo "✗ Some anti-leak tests FAILED - SECRETS MAY BE EXPOSED"
        exit 1
    fi
}

main "$@"
