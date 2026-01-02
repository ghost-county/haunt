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
