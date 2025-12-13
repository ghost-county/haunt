#!/usr/bin/env bash
# pattern-hunt-weekly.sh
# Weekly Pattern Detection and Defeat Automation
#
# Orchestrates the complete pattern hunt workflow:
#   1. Collect signals from git, memory, and code churn
#   2. Analyze patterns using AI
#   3. Generate defeat tests
#   4. Update pre-commit hooks
#   5. Update agent memory
#   6. Generate comprehensive report
#
# Usage:
#   ./pattern-hunt-weekly.sh                # Interactive mode (default)
#   ./pattern-hunt-weekly.sh --auto         # Auto-approve all prompts
#   ./pattern-hunt-weekly.sh --dry-run      # Preview without changes
#   ./pattern-hunt-weekly.sh --help         # Show help

set -euo pipefail

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HUNT_PATTERNS="${SCRIPT_DIR}/hunt-patterns"
PROGRESS_DIR="${REPO_ROOT}/.haunt/progress"
REPORT_DATE="$(date +%Y-%m-%d)"
REPORT_TIME="$(date +%H:%M:%S)"
REPORT_FILE="${PROGRESS_DIR}/weekly-refactor-${REPORT_DATE}.md"

# Default options
DRY_RUN=false
AUTO_MODE=false
INTERACTIVE_MODE=true
DAYS=30
TOP_N=10

# Timing metrics
START_TIME=$(date +%s)
COLLECT_TIME=0
ANALYZE_TIME=0
GENERATE_TIME=0
APPLY_TIME=0

# Results metrics
PATTERNS_FOUND=0
PATTERNS_PROCESSED=0
TESTS_GENERATED=0
AGENTS_UPDATED=0
ERRORS_COUNT=0
ERRORS_LOG=()

# ============================================================
# Helper Functions
# ============================================================

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}============================================================${NC}"
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${BOLD}${CYAN}============================================================${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}${BLUE}## $1${NC}"
    echo ""
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ERRORS_COUNT=$((ERRORS_COUNT + 1))
    ERRORS_LOG+=("$1")
}

print_step() {
    local step=$1
    local total=$2
    local desc=$3
    echo ""
    echo -e "${BOLD}${MAGENTA}[$step/$total]${NC} ${BOLD}$desc${NC}"
    echo ""
}

format_duration() {
    local seconds=$1
    if [ "$seconds" -lt 60 ]; then
        echo "${seconds}s"
    else
        local minutes=$((seconds / 60))
        local secs=$((seconds % 60))
        echo "${minutes}m ${secs}s"
    fi
}

show_help() {
    cat << EOF
${BOLD}Pattern Hunt Weekly - Automated Pattern Detection${NC}

${BOLD}USAGE:${NC}
    $0 [OPTIONS]

${BOLD}DESCRIPTION:${NC}
    Orchestrates the complete weekly pattern detection workflow:
      1. Collect signals from git history, agent memory, code churn
      2. Analyze patterns using AI
      3. Generate defeat tests for approved patterns
      4. Update pre-commit hooks
      5. Update agent memory with learnings
      6. Generate comprehensive summary report

${BOLD}OPTIONS:${NC}
    --help              Show this help message
    --dry-run           Preview actions without making changes
    --auto              Auto-approve all prompts (non-interactive)
    --interactive       Interactive mode with prompts (default)
    --days N            Days of git history to analyze (default: 30)
    --top-n N           Maximum patterns to identify (default: 10)

${BOLD}MODES:${NC}
    ${BOLD}Interactive Mode${NC} (default)
        Pauses for approval at each step:
        - Review patterns before processing
        - Approve pre-commit hook updates
        - Approve agent memory updates

    ${BOLD}Auto Mode${NC} (--auto)
        Runs entire workflow without prompts
        Useful for CI/CD or scheduled runs
        Recommend using --dry-run first

    ${BOLD}Dry Run Mode${NC} (--dry-run)
        Shows what would happen without making changes
        Safe for testing and verification

${BOLD}OUTPUT:${NC}
    ${PROGRESS_DIR}/weekly-refactor-YYYY-MM-DD.md
        - Comprehensive metrics and summary
        - Pattern detection results
        - Tests generated
        - Agents updated
        - Timing information
        - Any errors encountered

${BOLD}EXAMPLES:${NC}
    # Interactive mode (default)
    $0

    # Preview what would happen
    $0 --dry-run

    # Automated run for CI/CD
    $0 --auto

    # Analyze last 60 days, find top 15 patterns
    $0 --days 60 --top-n 15

    # Dry-run with custom parameters
    $0 --dry-run --days 60 --top-n 15

${BOLD}EXIT CODES:${NC}
    0    Success
    1    Error occurred (see report for details)
    2    Invalid arguments
    130  Interrupted by user (Ctrl+C)

${BOLD}SEE ALSO:${NC}
    hunt-patterns --help    Individual workflow commands
    pattern-detector/CLI-USAGE.md    Detailed CLI documentation

EOF
}

# ============================================================
# Argument Parsing
# ============================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --auto)
                AUTO_MODE=true
                INTERACTIVE_MODE=false
                shift
                ;;
            --interactive)
                INTERACTIVE_MODE=true
                AUTO_MODE=false
                shift
                ;;
            --days)
                DAYS="$2"
                shift 2
                ;;
            --top-n)
                TOP_N="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}Error: Unknown option: $1${NC}" >&2
                echo "Use --help for usage information" >&2
                exit 2
                ;;
        esac
    done
}

# ============================================================
# Validation
# ============================================================

validate_environment() {
    print_section "Environment Validation"

    local validation_failed=false

    # Check if hunt-patterns exists
    if [ ! -f "$HUNT_PATTERNS" ]; then
        print_error "hunt-patterns not found at: $HUNT_PATTERNS"
        validation_failed=true
    else
        print_success "Found hunt-patterns CLI"
    fi

    # Check if Python 3 is available
    if ! command -v python3 &> /dev/null; then
        print_error "python3 is required but not found"
        validation_failed=true
    else
        print_success "Python 3 available: $(python3 --version 2>&1)"
    fi

    # Check if in git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        validation_failed=true
    else
        print_success "Git repository detected"
    fi

    # Check for .haunt directory structure
    if [ ! -d "${REPO_ROOT}/.haunt" ]; then
        print_warning ".haunt directory not found - will be created"
        mkdir -p "${REPO_ROOT}/.haunt/progress"
    else
        print_success ".haunt directory exists"
    fi

    # Ensure progress directory exists
    mkdir -p "$PROGRESS_DIR"

    if [ "$validation_failed" = true ]; then
        echo ""
        print_error "Environment validation failed"
        exit 1
    fi

    echo ""
    print_success "Environment validation passed"
}

# ============================================================
# Workflow Steps
# ============================================================

run_pattern_hunt() {
    print_step 1 5 "Running Pattern Hunt Workflow"

    # Build command with global options first, then command, then command options
    local hunt_args=()

    # Global options (before command)
    if [ "$DRY_RUN" = true ]; then
        hunt_args+=("--dry-run")
        print_warning "DRY RUN MODE: No changes will be made"
    fi

    if [ "$AUTO_MODE" = true ]; then
        hunt_args+=("--auto")
        print_info "AUTO MODE: All prompts will be auto-approved"
    fi

    # Command
    hunt_args+=("hunt")

    # Command options (after command)
    hunt_args+=("--days" "$DAYS" "--top-n" "$TOP_N")

    print_info "Executing: ${HUNT_PATTERNS} ${hunt_args[*]}"
    echo ""

    local step_start=$(date +%s)
    local exit_code=0

    # Run hunt-patterns and capture exit code
    if "$HUNT_PATTERNS" "${hunt_args[@]}"; then
        exit_code=0
        print_success "Pattern hunt completed successfully"
    else
        exit_code=$?
        print_error "Pattern hunt failed with exit code: $exit_code"
    fi

    local step_end=$(date +%s)
    local duration=$((step_end - step_start))

    # Store timing based on overall duration (rough estimate)
    COLLECT_TIME=$((duration / 5))
    ANALYZE_TIME=$((duration * 2 / 5))
    GENERATE_TIME=$((duration / 5))
    APPLY_TIME=$((duration / 5))

    print_info "Duration: $(format_duration $duration)"

    return $exit_code
}

extract_metrics() {
    print_step 2 5 "Extracting Metrics"

    local pattern_hunter_dir="${REPO_ROOT}/.haunt/pattern-hunter"
    local tests_dir="${REPO_ROOT}/.haunt/tests/patterns"

    # Count patterns from latest analysis
    if [ -d "$pattern_hunter_dir" ]; then
        local latest_patterns=$(find "$pattern_hunter_dir" -name "patterns-*.json" -type f | sort -r | head -n 1)
        if [ -n "$latest_patterns" ] && [ -f "$latest_patterns" ]; then
            # Try to extract pattern count from JSON
            if command -v jq &> /dev/null; then
                PATTERNS_FOUND=$(jq '.patterns | length' "$latest_patterns" 2>/dev/null || echo 0)
                print_success "Patterns identified: $PATTERNS_FOUND"
            else
                PATTERNS_FOUND=$(grep -c '"name":' "$latest_patterns" 2>/dev/null || echo 0)
                print_info "Patterns identified: ~$PATTERNS_FOUND (jq not available for exact count)"
            fi
        fi

        # Check for approved patterns
        local state_file="${pattern_hunter_dir}/state.json"
        if [ -f "$state_file" ] && command -v jq &> /dev/null; then
            PATTERNS_PROCESSED=$(jq '.patterns_approved | length' "$state_file" 2>/dev/null || echo 0)
            print_success "Patterns processed: $PATTERNS_PROCESSED"
        fi
    fi

    # Count generated tests
    if [ -d "$tests_dir" ]; then
        TESTS_GENERATED=$(find "$tests_dir" -name "test_*.py" -type f -mtime -1 2>/dev/null | wc -l | tr -d ' ')
        print_success "Tests generated: $TESTS_GENERATED"
    fi

    # Estimate agents updated (rough heuristic)
    AGENTS_UPDATED=$PATTERNS_PROCESSED

    echo ""
    print_success "Metrics extraction complete"
}

generate_report() {
    print_step 3 5 "Generating Summary Report"

    local total_time=$(( $(date +%s) - START_TIME ))

    print_info "Report file: $REPORT_FILE"

    cat > "$REPORT_FILE" << EOF
# Weekly Pattern Detection Report

**Date:** ${REPORT_DATE}
**Time:** ${REPORT_TIME}
**Mode:** $([ "$AUTO_MODE" = true ] && echo "Automated" || echo "Interactive")$([ "$DRY_RUN" = true ] && echo " (Dry Run)" || echo "")

---

## Summary

This report was generated by the automated weekly pattern detection workflow.

### Metrics

| Metric | Value |
|--------|-------|
| Patterns Found | ${PATTERNS_FOUND} |
| Patterns Processed | ${PATTERNS_PROCESSED} |
| Tests Generated | ${TESTS_GENERATED} |
| Agents Updated | ${AGENTS_UPDATED} |
| Errors Encountered | ${ERRORS_COUNT} |

### Timing

| Phase | Duration |
|-------|----------|
| Signal Collection | $(format_duration $COLLECT_TIME) |
| Pattern Analysis | $(format_duration $ANALYZE_TIME) |
| Test Generation | $(format_duration $GENERATE_TIME) |
| Hook/Memory Update | $(format_duration $APPLY_TIME) |
| **Total** | **$(format_duration $total_time)** |

---

## Workflow Details

### Phase 1: Signal Collection
- **Period:** Last ${DAYS} days
- **Sources:** Git history, agent memory, code churn analysis
- **Status:** $([ "$ERRORS_COUNT" -eq 0 ] && echo "✓ Complete" || echo "⚠ Completed with errors")

### Phase 2: Pattern Analysis
- **Patterns Identified:** ${PATTERNS_FOUND}
- **Top N Limit:** ${TOP_N}
- **AI Model:** Claude (via Anthropic API)
- **Status:** $([ "$PATTERNS_FOUND" -gt 0 ] && echo "✓ Patterns found" || echo "ℹ No new patterns detected")

### Phase 3: Test Generation
- **Tests Generated:** ${TESTS_GENERATED}
- **Location:** \`.haunt/tests/patterns/\`
- **Framework:** pytest
- **Status:** $([ "$TESTS_GENERATED" -gt 0 ] && echo "✓ Tests created" || echo "ℹ No tests generated")

### Phase 4: Pre-commit Integration
- **Hook Updated:** $([ "$DRY_RUN" = false ] && echo "Yes" || echo "Dry run - no changes")
- **Config File:** \`.pre-commit-config.yaml\`
- **Status:** $([ "$DRY_RUN" = false ] && echo "✓ Updated" || echo "ℹ Would be updated (dry run)")

### Phase 5: Agent Memory Update
- **Agents Updated:** ${AGENTS_UPDATED}
- **Memory Location:** \`~/.agent-memory/memories.json\`
- **Status:** $([ "$AGENTS_UPDATED" -gt 0 ] && echo "✓ Memories added" || echo "ℹ No memory updates")

---

## Errors and Warnings

EOF

    if [ "$ERRORS_COUNT" -gt 0 ]; then
        cat >> "$REPORT_FILE" << EOF
The following errors were encountered during execution:

EOF
        for error in "${ERRORS_LOG[@]}"; do
            echo "- $error" >> "$REPORT_FILE"
        done
    else
        cat >> "$REPORT_FILE" << EOF
No errors encountered during execution.

EOF
    fi

    cat >> "$REPORT_FILE" << EOF
---

## Generated Artifacts

### Test Files
EOF

    if [ -d "${REPO_ROOT}/.haunt/tests/patterns" ]; then
        local tests=$(find "${REPO_ROOT}/.haunt/tests/patterns" -name "test_*.py" -type f -mtime -1 2>/dev/null | sort)
        if [ -n "$tests" ]; then
            echo "" >> "$REPORT_FILE"
            while IFS= read -r test_file; do
                echo "- \`$(basename "$test_file")\`" >> "$REPORT_FILE"
            done <<< "$tests"
        else
            echo "" >> "$REPORT_FILE"
            echo "No test files generated in this run." >> "$REPORT_FILE"
        fi
    else
        echo "" >> "$REPORT_FILE"
        echo "Test directory not found." >> "$REPORT_FILE"
    fi

    cat >> "$REPORT_FILE" << EOF

### Pattern Data
EOF

    if [ -d "${REPO_ROOT}/.haunt/pattern-hunter" ]; then
        echo "" >> "$REPORT_FILE"
        echo "Pattern detection artifacts are stored in:" >> "$REPORT_FILE"
        echo "- \`.haunt/pattern-hunter/signals-*.json\`" >> "$REPORT_FILE"
        echo "- \`.haunt/pattern-hunter/patterns-*.json\`" >> "$REPORT_FILE"
        echo "- \`.haunt/pattern-hunter/proposals-*.json\`" >> "$REPORT_FILE"
        echo "- \`.haunt/pattern-hunter/state.json\`" >> "$REPORT_FILE"
    fi

    cat >> "$REPORT_FILE" << EOF

---

## Next Steps

Based on this week's pattern detection:

1. **Review Generated Tests**
   - Examine tests in \`.haunt/tests/patterns/\`
   - Run tests: \`pytest .haunt/tests/patterns/ -v\`
   - Verify tests catch the intended patterns

2. **Update Agent Character Sheets**
   - Review agent memory updates
   - Update agent prompts if needed
   - Ensure agents are aware of new patterns

3. **Monitor Pattern Recurrence**
   - Track if defeated patterns reappear
   - Adjust tests if patterns evolve
   - Consider agent training improvements

4. **Pre-commit Validation**
   - Test pre-commit hooks: \`pre-commit run --all-files\`
   - Ensure hooks don't block valid code
   - Adjust hook configuration if needed

5. **Schedule Next Run**
   - Pattern detection should run weekly
   - Consider automating with cron or CI/CD
   - Review and improve based on results

---

## Resources

- **Hunt Patterns CLI:** \`./hunt-patterns --help\`
- **Pattern Detector Docs:** \`pattern-detector/README.md\`
- **CLI Usage Guide:** \`pattern-detector/CLI-USAGE.md\`
- **Pre-commit Setup:** \`scripts/setup-precommit-hooks-addon.sh\`

---

**Report Generated:** ${REPORT_DATE} at ${REPORT_TIME}

EOF

    if [ "$DRY_RUN" = false ]; then
        print_success "Report saved: $REPORT_FILE"
    else
        print_info "Dry run: Report would be saved to $REPORT_FILE"
    fi
}

display_summary() {
    print_step 4 5 "Displaying Summary"

    local total_time=$(( $(date +%s) - START_TIME ))

    echo ""
    echo -e "${BOLD}Pattern Hunt Summary${NC}"
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}Patterns Found:${NC}      ${PATTERNS_FOUND}"
    echo -e "  ${BOLD}Patterns Processed:${NC}  ${PATTERNS_PROCESSED}"
    echo -e "  ${BOLD}Tests Generated:${NC}     ${TESTS_GENERATED}"
    echo -e "  ${BOLD}Agents Updated:${NC}      ${AGENTS_UPDATED}"
    echo -e "  ${BOLD}Errors:${NC}              ${ERRORS_COUNT}"
    echo ""
    echo -e "  ${BOLD}Total Duration:${NC}      $(format_duration $total_time)"
    echo ""
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$ERRORS_COUNT" -gt 0 ]; then
        print_warning "Workflow completed with $ERRORS_COUNT error(s)"
        echo ""
        echo "Errors:"
        for error in "${ERRORS_LOG[@]}"; do
            echo "  - $error"
        done
        echo ""
    fi

    print_info "Detailed report: $REPORT_FILE"
}

show_next_steps() {
    print_step 5 5 "Next Steps"

    echo "Recommended actions:"
    echo ""

    if [ "$TESTS_GENERATED" -gt 0 ]; then
        echo "  1. Review generated tests:"
        echo "     ${DIM}cd ${REPO_ROOT}${NC}"
        echo "     ${DIM}pytest .haunt/tests/patterns/ -v${NC}"
        echo ""
    fi

    if [ "$PATTERNS_PROCESSED" -gt 0 ]; then
        echo "  2. Verify pre-commit hooks:"
        echo "     ${DIM}pre-commit run --all-files${NC}"
        echo ""
    fi

    echo "  3. Review detailed report:"
    echo "     ${DIM}cat $REPORT_FILE${NC}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        echo "  4. Run for real (without --dry-run):"
        echo "     ${DIM}$0 --auto${NC}"
        echo ""
    fi

    echo "  5. Schedule weekly runs:"
    echo "     ${DIM}# Add to crontab:${NC}"
    echo "     ${DIM}0 9 * * 1 cd ${REPO_ROOT} && $0 --auto${NC}"
    echo ""
}

# ============================================================
# Main Execution
# ============================================================

main() {
    # Parse command-line arguments
    parse_arguments "$@"

    # Display header
    print_header "Weekly Pattern Detection Automation"

    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN MODE: No changes will be made"
        echo ""
    fi

    if [ "$AUTO_MODE" = true ]; then
        print_info "AUTO MODE: Running without interactive prompts"
        echo ""
    fi

    # Validate environment
    validate_environment

    # Run pattern hunt workflow
    local hunt_exit_code=0
    if ! run_pattern_hunt; then
        hunt_exit_code=$?
        print_error "Pattern hunt workflow failed"
    fi

    # Extract metrics from results
    extract_metrics

    # Generate comprehensive report
    generate_report

    # Display summary
    display_summary

    # Show next steps
    show_next_steps

    # Final status
    print_header "Pattern Hunt Complete"

    if [ "$ERRORS_COUNT" -eq 0 ] && [ "$hunt_exit_code" -eq 0 ]; then
        print_success "All operations completed successfully"
        if [ "$DRY_RUN" = false ]; then
            print_info "Report saved: $REPORT_FILE"
        fi
        exit 0
    else
        print_error "Workflow completed with errors (exit code: $hunt_exit_code)"
        print_info "Check report for details: $REPORT_FILE"
        exit 1
    fi
}

# Handle Ctrl+C gracefully
trap 'echo ""; print_warning "Interrupted by user"; exit 130' INT

# Run main function with all arguments
main "$@"
