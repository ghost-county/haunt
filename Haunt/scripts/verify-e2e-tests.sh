#!/usr/bin/env bash

# verify-e2e-tests.sh
# Verifies that E2E tests exist for UI-related requirements before allowing completion

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_info() {
    echo "INFO: $1"
}

# Function to check if directory exists
check_directory_exists() {
    local dir=$1
    if [ -d "$dir" ]; then
        return 0
    else
        return 1
    fi
}

# Function to count E2E test files in a directory
count_e2e_tests() {
    local dir=$1
    local count=0

    if check_directory_exists "$dir"; then
        # Count .spec.ts, .spec.js, test_*.py files
        count=$(find "$dir" -type f \( -name "*.spec.ts" -o -name "*.spec.js" -o -name "test_*.py" \) 2>/dev/null | wc -l | tr -d ' ')
    fi

    echo "$count"
}

# Function to list E2E test files
list_e2e_tests() {
    local dir=$1

    if check_directory_exists "$dir"; then
        find "$dir" -type f \( -name "*.spec.ts" -o -name "*.spec.js" -o -name "test_*.py" \) 2>/dev/null
    fi
}

# Main verification function
verify_e2e_tests() {
    local req_number=$1
    local work_type=$2

    print_info "Verifying E2E tests for ${req_number} (${work_type})"

    # Determine expected test locations based on project structure
    local test_locations=()

    # Check for standard frontend project structure
    if check_directory_exists "tests/e2e"; then
        test_locations+=("tests/e2e")
    fi

    if check_directory_exists "e2e"; then
        test_locations+=("e2e")
    fi

    # Check for Haunt framework structure
    if check_directory_exists ".haunt/tests/e2e"; then
        test_locations+=(".haunt/tests/e2e")
    fi

    # If no E2E directories found, check if this is a UI requirement
    if [ ${#test_locations[@]} -eq 0 ]; then
        if [ "$work_type" = "frontend" ] || [ "$work_type" = "ui" ]; then
            print_error "No E2E test directory found (expected tests/e2e/, e2e/, or .haunt/tests/e2e/)"
            print_info "Create E2E test directory first, then add tests"
            return 1
        else
            print_warning "No E2E test directory found, but this is not frontend work"
            print_info "Skipping E2E test verification for non-UI work"
            return 0
        fi
    fi

    # Count total E2E tests across all locations
    local total_tests=0
    local req_specific_tests=0

    for dir in "${test_locations[@]}"; do
        local dir_count=$(count_e2e_tests "$dir")
        total_tests=$((total_tests + dir_count))

        # Check for requirement-specific tests
        local req_pattern=$(echo "$req_number" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
        req_pattern=$(echo "$req_pattern" | tr '-' '_') # Replace - with _

        if check_directory_exists "$dir"; then
            local req_count=$(find "$dir" -type f \( -name "*${req_pattern}*" \) 2>/dev/null | wc -l | tr -d ' ')
            req_specific_tests=$((req_specific_tests + req_count))
        fi
    done

    print_info "Found ${total_tests} total E2E test(s) in project"
    print_info "Found ${req_specific_tests} E2E test(s) related to ${req_number}"

    # Verify requirements
    if [ "$work_type" = "frontend" ] || [ "$work_type" = "ui" ]; then
        if [ $req_specific_tests -eq 0 ]; then
            print_error "No E2E tests found for UI requirement ${req_number}"
            print_error "Expected test file matching pattern: *${req_number}* in E2E test directory"
            print_error ""
            print_error "Requirement CANNOT be marked 🟢 Complete without E2E tests"
            print_error ""
            print_info "Available E2E test locations:"
            for dir in "${test_locations[@]}"; do
                print_info "  - ${dir}/"
            done
            print_info ""
            print_info "Example test filenames:"
            local example_num=$(echo "$req_number" | sed 's/REQ-//')
            local example_lower=$(echo "$req_number" | tr '[:upper:]' '[:lower:]')
            print_info "  - ${test_locations[0]}/req-${example_num}.spec.ts"
            print_info "  - ${test_locations[0]}/${example_lower}.spec.ts"
            return 1
        else
            print_success "Found ${req_specific_tests} E2E test(s) for ${req_number}"
            print_info ""
            print_info "Test files:"
            for dir in "${test_locations[@]}"; do
                if check_directory_exists "$dir"; then
                    local req_pattern=$(echo "$req_number" | tr '[:upper:]' '[:lower:]')
                    req_pattern=$(echo "$req_pattern" | tr '-' '_')
                    find "$dir" -type f -name "*${req_pattern}*" 2>/dev/null | while read -r file; do
                        print_info "  ✓ ${file}"
                    done
                fi
            done
            print_info ""
            print_success "E2E test verification PASSED"
            return 0
        fi
    else
        print_info "Non-UI work type: ${work_type}"
        print_info "E2E tests not required (but ${total_tests} test(s) exist in project)"
        return 0
    fi
}

# Usage information
usage() {
    cat << EOF
Usage: $0 <REQ-NUMBER> <WORK-TYPE>

Arguments:
  REQ-NUMBER    Requirement number (e.g., REQ-261, req-123)
  WORK-TYPE     Type of work: frontend|ui|backend|infrastructure

Examples:
  $0 REQ-261 frontend
  $0 req-123 ui
  $0 REQ-100 backend

Work Types:
  frontend, ui  - Requires E2E tests (strict verification)
  backend       - E2E tests optional (informational only)
  infrastructure - E2E tests optional (informational only)

Exit Codes:
  0 - Verification passed or not applicable
  1 - Verification failed (missing E2E tests for UI work)
EOF
}

# Main script
main() {
    if [ $# -ne 2 ]; then
        print_error "Invalid number of arguments"
        usage
        exit 1
    fi

    local req_number=$1
    local work_type=$2

    # Normalize requirement number to uppercase
    req_number=$(echo "$req_number" | tr '[:lower:]' '[:upper:]')

    # Normalize work type to lowercase
    work_type=$(echo "$work_type" | tr '[:upper:]' '[:lower:]')

    # Validate work type
    case "$work_type" in
        frontend|ui|backend|infrastructure)
            # Valid work type
            ;;
        *)
            print_error "Invalid work type: ${work_type}"
            usage
            exit 1
            ;;
    esac

    verify_e2e_tests "$req_number" "$work_type"
}

# Run main function
main "$@"
