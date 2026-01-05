#!/usr/bin/env bash

# Pre-commit E2E Test Verification
# Blocks commits with UI changes that lack E2E tests
# Usage: Installed as .git/hooks/pre-commit by setup-haunt.sh

# Configuration
RUN_TESTS=${RUN_E2E_TESTS:-false}  # Set to 'true' to run tests on every commit
STRICT_MODE=${STRICT_E2E_MODE:-true}  # Block commits without E2E tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# UI file patterns to detect
UI_PATTERNS=(
    "components/"
    "pages/"
    "src/components/"
    "src/pages/"
    "app/"
    "*.tsx"
    "*.jsx"
    "*.vue"
)

# E2E test locations to check
E2E_TEST_PATHS=(
    "tests/e2e/"
    "e2e/"
    ".haunt/tests/e2e/"
    "test/e2e/"
    "__tests__/e2e/"
)

echo "🔍 Checking for UI changes requiring E2E tests..."

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
    echo "✅ No staged files to check"
    exit 0
fi

# Function to check if file matches UI patterns
is_ui_file() {
    local file=$1
    for pattern in "${UI_PATTERNS[@]}"; do
        if [[ "$file" == *"$pattern"* ]]; then
            return 0  # true
        fi
    done
    return 1  # false
}

# Function to find E2E test file for given UI file
find_e2e_test() {
    local ui_file=$1
    local base_name

    # Extract base filename without extension
    base_name=$(basename "$ui_file")
    base_name="${base_name%.*}"

    # Search for corresponding E2E test
    for test_dir in "${E2E_TEST_PATHS[@]}"; do
        if [ -d "$test_dir" ]; then
            # Look for test files with various naming conventions
            local test_candidates=(
                "${test_dir}${base_name}.spec.ts"
                "${test_dir}${base_name}.spec.js"
                "${test_dir}${base_name}.e2e.ts"
                "${test_dir}${base_name}.e2e.js"
                "${test_dir}${base_name}-flow.spec.ts"
                "${test_dir}test_${base_name}.py"
            )

            for candidate in "${test_candidates[@]}"; do
                if [ -f "$candidate" ]; then
                    echo "$candidate"
                    return 0
                fi
            done
        fi
    done

    return 1  # Not found
}

# Function to extract requirement number from file path or content
extract_req_number() {
    local ui_file=$1

    # Check file path for REQ-XXX pattern
    if [[ "$ui_file" =~ req-([0-9]+) ]]; then
        echo "REQ-${BASH_REMATCH[1]}"
        return 0
    fi

    # Check file content for REQ-XXX references
    if [ -f "$ui_file" ]; then
        local req_match=$(grep -oE 'REQ-[0-9]+' "$ui_file" | head -1)
        if [ -n "$req_match" ]; then
            echo "$req_match"
            return 0
        fi
    fi

    return 1
}

# Function to suggest E2E test location
suggest_test_location() {
    local ui_file=$1
    local base_name
    local req_num

    base_name=$(basename "$ui_file")
    base_name="${base_name%.*}"

    # Try to extract REQ number (don't fail on error)
    req_num=$(extract_req_number "$ui_file" 2>/dev/null || true)
    if [ -z "$req_num" ]; then
        req_num=""
    fi

    # Prefer tests/e2e/ for most projects
    if [ -d "tests/e2e/" ]; then
        if [ -n "$req_num" ]; then
            echo "tests/e2e/${req_num,,}.spec.ts"
        else
            echo "tests/e2e/${base_name}.spec.ts"
        fi
    elif [ -d "e2e/" ]; then
        echo "e2e/${base_name}.spec.ts"
    elif [ -d ".haunt/tests/e2e/" ]; then
        echo ".haunt/tests/e2e/${base_name}.spec.ts"
    else
        # Create directory suggestion
        if [ -n "$req_num" ]; then
            echo "tests/e2e/${req_num,,}.spec.ts (directory needs creation)"
        else
            echo "tests/e2e/${base_name}.spec.ts (directory needs creation)"
        fi
    fi
}

# Check each staged file
UI_FILES=()
MISSING_TESTS=()
FOUND_TESTS=()

for file in $STAGED_FILES; do
    if is_ui_file "$file"; then
        UI_FILES+=("$file")

        # Check for corresponding E2E test (don't fail on not found)
        test_file=$(find_e2e_test "$file" || echo "")
        if [ -n "$test_file" ]; then
            FOUND_TESTS+=("$file -> $test_file")
        else
            MISSING_TESTS+=("$file")
        fi
    fi
done

# Report results
if [ ${#UI_FILES[@]} -eq 0 ]; then
    echo "✅ No UI files changed"
    exit 0
fi

echo ""
echo "📊 E2E Test Coverage Report:"
echo "  UI files changed: ${#UI_FILES[@]}"
echo "  E2E tests found: ${#FOUND_TESTS[@]}"
echo "  Missing E2E tests: ${#MISSING_TESTS[@]}"
echo ""

# Show files with tests
if [ ${#FOUND_TESTS[@]} -gt 0 ]; then
    echo -e "${GREEN}✅ UI files with E2E tests:${NC}"
    for mapping in "${FOUND_TESTS[@]}"; do
        echo "  $mapping"
    done
    echo ""
fi

# Show files missing tests
if [ ${#MISSING_TESTS[@]} -gt 0 ]; then
    echo -e "${RED}❌ UI files WITHOUT E2E tests:${NC}"
    for file in "${MISSING_TESTS[@]}"; do
        suggested_location=$(suggest_test_location "$file")
        echo "  $file"
        echo "    Suggested test: $suggested_location"
    done
    echo ""

    if [ "$STRICT_MODE" = "true" ]; then
        echo -e "${RED}🚫 COMMIT BLOCKED${NC}"
        echo ""
        echo "E2E tests are REQUIRED for all UI changes."
        echo ""
        echo "Fix options:"
        echo "  1. Create E2E tests for the UI changes (RECOMMENDED)"
        echo "  2. Use 'git commit --no-verify' to bypass (EMERGENCY ONLY)"
        echo ""
        echo "See: .claude/rules/gco-ui-testing.md for guidance"
        echo ""
        exit 1
    else
        echo -e "${YELLOW}⚠️  WARNING: E2E tests missing${NC}"
        echo "Strict mode is disabled. Commit allowed but tests STRONGLY recommended."
        echo ""
    fi
fi

# Optionally run E2E tests
if [ "$RUN_TESTS" = "true" ] && [ ${#FOUND_TESTS[@]} -gt 0 ]; then
    echo "🧪 Running E2E tests..."

    # Check if Playwright is available
    if command -v npx &> /dev/null && [ -f "playwright.config.ts" ] || [ -f "playwright.config.js" ]; then
        echo "Running Playwright tests..."
        if npx playwright test; then
            echo -e "${GREEN}✅ E2E tests passed${NC}"
        else
            echo -e "${RED}❌ E2E tests FAILED${NC}"
            echo ""
            echo "🚫 COMMIT BLOCKED - Fix failing tests before committing"
            echo ""
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  Playwright not found. Skipping test execution.${NC}"
        echo "Install: npm install --save-dev @playwright/test"
    fi
fi

echo -e "${GREEN}✅ Pre-commit E2E check passed${NC}"
exit 0
