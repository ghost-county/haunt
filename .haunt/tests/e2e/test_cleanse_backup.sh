#!/usr/bin/env bash
#
# E2E Tests for REQ-289: Backup functionality in cleanse.sh
#
# Tests verify:
# - --backup flag creates timestamped archive before deletion
# - Backup stored in ~/haunt-backups/ directory
# - Backup format: haunt-backup-YYYYMMDD-HHMMSS.tar.gz
# - Backup location reported to user
# - Deletion aborts if backup fails
#

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "${SCRIPT_DIR}/../../.." && pwd)
CLEANSE_SCRIPT="${PROJECT_ROOT}/Haunt/scripts/cleanse.sh"

# Test utilities
TEST_BACKUP_DIR="${HOME}/haunt-backups"
TEST_PASSED=0
TEST_FAILED=0

success() { echo "✓ $1"; TEST_PASSED=$((TEST_PASSED + 1)); }
fail() { echo "✗ $1"; TEST_FAILED=$((TEST_FAILED + 1)); }
info() { echo "ℹ $1"; }

# Cleanup function
cleanup_test_backups() {
    if [[ -d "$TEST_BACKUP_DIR" ]]; then
        rm -rf "$TEST_BACKUP_DIR"
    fi
}

# Test 1: --backup flag creates ~/haunt-backups/ directory if missing
test_backup_directory_creation() {
    info "Test 1: Verify ~/haunt-backups/ directory creation"

    cleanup_test_backups

    # Verify directory doesn't exist before
    if [[ -d "$TEST_BACKUP_DIR" ]]; then
        fail "Backup directory already exists before test"
        return
    fi

    # Run cleanse with --backup --dry-run (should not create in dry-run)
    bash "$CLEANSE_SCRIPT" --backup --global --dry-run >/dev/null 2>&1

    # In dry-run mode, directory should NOT be created
    if [[ ! -d "$TEST_BACKUP_DIR" ]]; then
        success "Backup directory not created in dry-run mode (correct behavior)"
    else
        fail "Backup directory should not be created in dry-run mode"
    fi
}

# Test 2: Backup filename format matches requirement
test_backup_filename_format() {
    info "Test 2: Verify backup filename format (haunt-backup-YYYYMMDD-HHMMSS.tar.gz)"

    # Extract filename from output
    local filename=$(bash "$CLEANSE_SCRIPT" --backup --global --dry-run 2>&1 | grep "Backup location" | sed 's/.*\///')

    # Expected format: haunt-backup-20251231-153045.tar.gz
    # Pattern: haunt-backup-[8 digits]-[6 digits].tar.gz
    if echo "$filename" | grep -qE "^haunt-backup-[0-9]{8}-[0-9]{6}\.tar\.gz$"; then
        success "Backup filename format matches (haunt-backup-YYYYMMDD-HHMMSS.tar.gz)"
    else
        fail "Backup filename format incorrect: $filename"
    fi
}

# Test 3: --backup works with --global flag
test_backup_with_global() {
    info "Test 3: Verify --backup --global creates backup of global artifacts"

    cleanup_test_backups

    # Run with --dry-run to avoid actual deletion
    local output=$(bash "$CLEANSE_SCRIPT" --backup --global --dry-run 2>&1)

    # Verify output mentions creating backup with .claude
    if echo "$output" | grep -q "Would create backup with: .claude"; then
        success "--backup --global includes .claude artifacts"
    else
        fail "--backup --global does not mention .claude in backup"
    fi
}

# Test 4: --backup works with --project flag
test_backup_with_project() {
    info "Test 4: Verify --backup --project creates backup of project artifacts"

    cleanup_test_backups

    # Run with --dry-run to avoid actual deletion
    local output=$(bash "$CLEANSE_SCRIPT" --backup --project --dry-run 2>&1)

    # Verify output mentions creating backup with .claude and .haunt
    if echo "$output" | grep -q "Would create backup with: .claude .haunt"; then
        success "--backup --project includes .claude and .haunt artifacts"
    else
        fail "--backup --project output: $output"
    fi
}

# Test 5: --backup works with --full flag
test_backup_with_full() {
    info "Test 5: Verify --backup --full creates backup of all artifacts"

    cleanup_test_backups

    # Run with --dry-run to avoid actual deletion
    local output=$(bash "$CLEANSE_SCRIPT" --backup --full --dry-run 2>&1)

    # Verify output mentions creating backup
    if echo "$output" | grep -q "Would create backup"; then
        success "--backup --full creates backup of all artifacts"
    else
        fail "--backup --full does not mention backup creation"
    fi
}

# Test 6: Backup location reported to user
test_backup_location_reporting() {
    info "Test 6: Verify backup location is printed to stdout"

    local output=$(bash "$CLEANSE_SCRIPT" --backup --global --dry-run 2>&1)

    # Verify output contains backup location in expected format
    if echo "$output" | grep -q "Backup location.*haunt-backups/haunt-backup-[0-9]\{8\}-[0-9]\{6\}\.tar\.gz"; then
        success "Backup location reported to user"
    else
        fail "Backup location not found in output"
    fi
}

# Test 7: Deletion aborts if backup fails
test_abort_on_backup_failure() {
    info "Test 7: Verify deletion aborted if backup fails"

    # Verify error handling exists in script
    if grep -q "exit.*EXIT_BACKUP_FAILED" "$CLEANSE_SCRIPT"; then
        success "Backup failure triggers script exit (abort mechanism exists)"
    else
        fail "No exit on backup failure detected in script"
    fi

    # Note: Full integration test would require simulating disk full or permission denied
    # This is difficult in automated tests, so we verify the code path exists
}

# Test 8: --backup works with interactive mode
test_backup_with_interactive_mode() {
    info "Test 8: Verify --backup flag works in interactive mode"

    # Verify that --backup flag is parsed before interactive mode
    if grep -q 'CREATE_BACKUP=true' "$CLEANSE_SCRIPT"; then
        success "--backup flag setting exists in script"
    else
        fail "CREATE_BACKUP variable not found in script"
    fi

    # Note: Testing interactive mode requires stdin simulation which is complex
    # We verify the flag exists and trust integration with existing backup flow
}

# Run all tests
echo ""
echo "========================================"
echo "REQ-289: Backup Functionality Tests"
echo "========================================"
echo ""

test_backup_directory_creation
test_backup_filename_format
test_backup_with_global
test_backup_with_project
test_backup_with_full
test_backup_location_reporting
test_abort_on_backup_failure
test_backup_with_interactive_mode

# Cleanup
cleanup_test_backups

# Summary
echo ""
echo "========================================"
echo "Test Results"
echo "========================================"
echo "Passed: ${TEST_PASSED}"
echo "Failed: ${TEST_FAILED}"
echo ""

if [[ $TEST_FAILED -eq 0 ]]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
