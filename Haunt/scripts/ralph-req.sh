#!/usr/bin/env bash
#
# ralph-req.sh - Ralph Requirement Loop Setup
#
# Extracts requirement from roadmap, validates size (XS/S/M), and sets up
# Ralph Wiggum iteration loop with derived completion promise.
#
# Usage:
#   ralph-req REQ-XXX              # Start Ralph loop for requirement
#   ralph-req REQ-XXX --dry-run    # Preview prompt without starting loop
#
# Exit Codes:
#   0 - Success (loop started or dry-run complete)
#   1 - Error (invalid usage, requirement not found)
#   2 - Roadmap file not found
#   3 - Requirement size too large (SPLIT not supported)
#   4 - Requirement blocked or complete

set -u
set -o pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="ralph-req"
readonly VERSION="1.0.0"

# Roadmap file location (relative to project root)
readonly DEFAULT_ROADMAP=".haunt/plans/roadmap.md"

# Max iterations by effort size
readonly MAX_ITERATIONS_XS=30
readonly MAX_ITERATIONS_S=50
readonly MAX_ITERATIONS_M=75

# Status icons
readonly STATUS_NOT_STARTED="⚪"
readonly STATUS_IN_PROGRESS="🟡"
readonly STATUS_COMPLETE="🟢"
readonly STATUS_BLOCKED="🔴"

# ============================================================================
# COLORS
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit "${2:-1}"
}

info() {
    echo -e "${BLUE}$1${NC}"
}

success() {
    echo -e "${GREEN}$1${NC}"
}

warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Find roadmap file (search up directory tree)
find_roadmap() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/$DEFAULT_ROADMAP" ]]; then
            echo "$dir/$DEFAULT_ROADMAP"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# ============================================================================
# REQUIREMENT EXTRACTION
# ============================================================================

extract_requirement() {
    local req_id="$1"
    local roadmap="$2"

    # Extract requirement section (from heading to next heading or EOF)
    # Use awk to capture from REQ heading until next ### or --- separator
    awk "/^### .*${req_id}:/{flag=1} flag; /^(###|---)/&&flag&&!/^### .*${req_id}:/{exit}" "$roadmap"
}

extract_field() {
    local content="$1"
    local field="$2"

    echo "$content" | grep "^\*\*${field}:\*\*" | sed "s/^\*\*${field}:\*\* //"
}

extract_completion_criteria() {
    local content="$1"

    # Extract completion criteria (text after **Completion:** on same or following lines)
    echo "$content" | grep "^\*\*Completion:\*\*" | sed 's/^\*\*Completion:\*\* //'
}

extract_tasks() {
    local content="$1"

    # Extract task list (lines starting with - [ ] or - [x])
    echo "$content" | grep "^- \[" | sed 's/^- \[.\] //'
}

# ============================================================================
# VALIDATION
# ============================================================================

validate_requirement() {
    local req_id="$1"
    local content="$2"

    # Check if requirement exists
    if [[ -z "$content" ]]; then
        return 1
    fi

    # Extract status and effort
    local status_line
    status_line=$(echo "$content" | grep "^###" | head -1)

    # Check if complete
    if [[ "$status_line" == *"$STATUS_COMPLETE"* ]]; then
        return 4
    fi

    # Check if blocked
    if [[ "$status_line" == *"$STATUS_BLOCKED"* ]]; then
        return 5
    fi

    # Extract and validate effort size
    local effort
    effort=$(extract_field "$content" "Effort")

    if [[ -z "$effort" ]]; then
        return 1
    fi

    if [[ "$effort" != "XS" && "$effort" != "S" && "$effort" != "M" ]]; then
        return 3
    fi

    return 0
}

# ============================================================================
# PROMPT GENERATION
# ============================================================================

build_ralph_prompt() {
    local req_id="$1"
    local content="$2"
    local effort="$3"

    # Extract fields
    local description
    local completion
    local tasks

    description=$(extract_field "$content" "Description")
    completion=$(extract_completion_criteria "$content")
    tasks=$(extract_tasks "$content")

    # Build structured prompt
    cat <<EOF
Implement $req_id using TDD workflow.

DESCRIPTION:
$description

COMPLETION CRITERIA:
$completion

TASKS:
$tasks

RULES:
- Follow gco-tdd-workflow for implementation (RED → GREEN → REFACTOR)
- Run tests after each change
- Update roadmap status to 🟡 In Progress when starting
- Check off tasks as completed (- [ ] → - [x])
- Output <promise>ALL_CRITERIA_VERIFIED</promise> ONLY when:
  * ALL completion criteria verified
  * ALL tasks checked off
  * ALL tests pass
  * Code quality meets standards (no magic numbers, proper error handling, clear naming)

BLOCKED PROTOCOL:
- If genuinely blocked (missing environment variable, external service down, permission denied):
  * Output <blocked>REASON</blocked> to exit loop
  * Include clear explanation of what's needed to unblock

ITERATION AWARENESS:
- Check git log to see previous work
- Review file changes to understand what was attempted
- Learn from previous iterations (don't repeat failed approaches)

NON-NEGOTIABLE:
- NEVER output false promise to escape loop
- Only declare completion when YOU would confidently demo this to your CTO
- If in doubt, continue iterating
EOF
}

# ============================================================================
# MAIN LOGIC
# ============================================================================

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME REQ-XXX [--dry-run]

Start Ralph Wiggum iteration loop for a requirement.

Options:
  --dry-run     Preview prompt without starting loop

Examples:
  $SCRIPT_NAME REQ-042              # Start loop for REQ-042
  $SCRIPT_NAME REQ-042 --dry-run    # Preview prompt only

EOF
    exit 0
}

main() {
    # Parse arguments
    local req_id=""
    local dry_run=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                usage
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            REQ-*)
                req_id="$1"
                shift
                ;;
            *)
                error "Unknown argument: $1\n\nUse --help for usage information." 1
                ;;
        esac
    done

    # Validate requirement ID provided
    if [[ -z "$req_id" ]]; then
        error "Requirement ID required\n\nUsage: $SCRIPT_NAME REQ-XXX" 1
    fi

    # Find roadmap file
    info "Finding roadmap..."
    local roadmap
    if ! roadmap=$(find_roadmap); then
        error "Roadmap file not found. Are you in a Haunt project?" 2
    fi
    success "Found roadmap: $roadmap"

    # Extract requirement
    info "Extracting requirement $req_id..."
    local req_content
    req_content=$(extract_requirement "$req_id" "$roadmap")

    # Validate requirement
    info "Validating requirement..."
    validate_requirement "$req_id" "$req_content"
    local validation_result=$?

    case $validation_result in
        0)
            # Valid - continue
            ;;
        1)
            error "Requirement $req_id not found in roadmap" 1
            ;;
        3)
            local effort
            effort=$(extract_field "$req_content" "Effort")
            error "Requirement $req_id is size $effort. Ralph loops only support XS/S/M.\nDecompose this requirement first or work interactively." 3
            ;;
        4)
            error "Requirement $req_id is already complete" 4
            ;;
        5)
            local blocked_by
            blocked_by=$(extract_field "$req_content" "Blocked by")
            error "Requirement $req_id is blocked by: $blocked_by" 4
            ;;
        *)
            error "Unknown validation error for $req_id" 1
            ;;
    esac

    # Extract effort size
    local effort
    effort=$(extract_field "$req_content" "Effort")
    success "Requirement valid (Effort: $effort)"

    # Set max iterations based on effort
    local max_iterations
    case "$effort" in
        XS) max_iterations=$MAX_ITERATIONS_XS ;;
        S)  max_iterations=$MAX_ITERATIONS_S ;;
        M)  max_iterations=$MAX_ITERATIONS_M ;;
        *)  max_iterations=$MAX_ITERATIONS_S ;;  # Fallback
    esac

    # Build prompt
    info "Building Ralph prompt..."
    local prompt
    prompt=$(build_ralph_prompt "$req_id" "$req_content" "$effort")

    # Dry run or execute
    if [[ "$dry_run" == true ]]; then
        echo ""
        echo "=== RALPH PROMPT (DRY RUN) ==="
        echo "$prompt"
        echo ""
        echo "=== RALPH CONFIGURATION ==="
        echo "Completion Promise: ALL_CRITERIA_VERIFIED"
        echo "Max Iterations: $max_iterations"
        echo ""
        success "Dry run complete. Use without --dry-run to start loop."
    else
        info "Starting Ralph loop..."
        info "  Completion Promise: ALL_CRITERIA_VERIFIED"
        info "  Max Iterations: $max_iterations"
        echo ""

        # Check if /ralph-loop command exists
        if ! command -v ralph-loop &> /dev/null; then
            warning "Ralph loop command not found. Outputting prompt for manual use:"
            echo ""
            echo "$prompt"
            echo ""
            error "Install Ralph Wiggum or invoke /ralph-loop manually" 1
        fi

        # Invoke Ralph loop
        /ralph-loop "$prompt" --completion-promise "ALL_CRITERIA_VERIFIED" --max-iterations "$max_iterations"
    fi
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main "$@"
