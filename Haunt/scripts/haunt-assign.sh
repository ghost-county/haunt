#!/usr/bin/env bash
#
# haunt-assign.sh - Assign Agent to Requirement
#
# Assigns the current agent to a specific requirement by:
# 1. Validating requirement exists and is assignable
# 2. Updating status to 🟡 In Progress in roadmap
# 3. Loading requirement details for working context
#
# Usage:
#   haunt-assign REQ-XXX              # Assign to requirement
#   haunt-assign REQ-XXX --dry-run    # Preview without changes
#   haunt-assign REQ-XXX --force      # Skip validation checks
#
# Exit Codes:
#   0 - Success (assigned)
#   1 - Error (validation failed, requirement not found, etc.)
#   2 - Roadmap file not found
#   3 - Requirement blocked or complete

set -u
set -o pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="haunt-assign"
readonly VERSION="1.0.0"

# Roadmap file location (relative to project root)
readonly DEFAULT_ROADMAP=".haunt/plans/roadmap.md"
readonly BATCHES_DIR=".haunt/plans/batches"
readonly STORIES_DIR=".haunt/plans/stories"

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
# ERROR HANDLING
# ============================================================================

error() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit "${2:-1}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

info() {
    echo -e "${BLUE}$1${NC}"
}

# ============================================================================
# USAGE
# ============================================================================

usage() {
    cat << EOF
Usage: $SCRIPT_NAME REQ-XXX [OPTIONS]

Assign yourself (the current agent) to a specific requirement.

Arguments:
  REQ-XXX           Requirement ID to assign (e.g., REQ-312)

Options:
  --dry-run         Preview assignment without making changes
  --force           Skip validation checks (not recommended)
  -h, --help        Show this help message

Examples:
  $SCRIPT_NAME REQ-312              # Assign to REQ-312
  $SCRIPT_NAME REQ-312 --dry-run    # Preview assignment
  $SCRIPT_NAME REQ-312 --force      # Force assignment

EOF
    exit 0
}

# ============================================================================
# FILE DISCOVERY
# ============================================================================

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
    error "Roadmap not found: $DEFAULT_ROADMAP (searched up from $PWD)" 2
}

# Find requirement in roadmap or batch files
find_requirement() {
    local req_id="$1"
    local roadmap_file="$2"
    local project_root
    project_root="$(dirname "$(dirname "$roadmap_file")")"

    # Try main roadmap first
    if grep -q "^### [⚪🟡🟢🔴] $req_id:" "$roadmap_file"; then
        echo "$roadmap_file"
        return 0
    fi

    # Try batch files if they exist
    local batches_dir="$project_root/$BATCHES_DIR"
    if [[ -d "$batches_dir" ]]; then
        for batch_file in "$batches_dir"/batch-*.md; do
            if [[ -f "$batch_file" ]] && grep -q "^### [⚪🟡🟢🔴] $req_id:" "$batch_file"; then
                echo "$batch_file"
                return 0
            fi
        done
    fi

    return 1
}

# ============================================================================
# REQUIREMENT PARSING
# ============================================================================

# Extract requirement details
parse_requirement() {
    local req_file="$1"
    local req_id="$2"

    # Find requirement start line
    local start_line
    start_line=$(grep -n "^### [⚪🟡🟢🔴] $req_id:" "$req_file" | cut -d: -f1 | head -1)

    if [[ -z "$start_line" ]]; then
        return 1
    fi

    # Find end of requirement block (next ### or --- or EOF)
    local end_line
    end_line=$(tail -n +$((start_line + 1)) "$req_file" | grep -n "^###\|^---" | head -1 | cut -d: -f1)

    if [[ -n "$end_line" ]]; then
        end_line=$((start_line + end_line - 1))
    else
        end_line=$(wc -l < "$req_file" | tr -d ' ')
    fi

    # Extract requirement block
    sed -n "${start_line},${end_line}p" "$req_file"
}

# Extract current status icon from requirement
get_status() {
    local req_block="$1"
    echo "$req_block" | head -1 | grep -oE '[⚪🟡🟢🔴]' | head -1
}

# Extract requirement title (after "REQ-XXX: ")
get_title() {
    local req_block="$1"
    echo "$req_block" | head -1 | sed -E 's/^### [⚪🟡🟢🔴] REQ-[0-9]+: (.*)/\1/'
}

# Extract field value from requirement block
get_field() {
    local req_block="$1"
    local field="$2"
    echo "$req_block" | grep "^\*\*$field:\*\*" | sed "s/^\*\*$field:\*\* //"
}

# Extract blocked_by value
get_blocked_by() {
    local req_block="$1"
    echo "$req_block" | grep '^\*\*Blocked by:\*\*' | sed 's/^\*\*Blocked by:\*\* //'
}

# ============================================================================
# VALIDATION
# ============================================================================

# Validate requirement can be assigned
validate_assignment() {
    local req_id="$1"
    local req_block="$2"
    local force="$3"

    local status
    status=$(get_status "$req_block")

    # Check if already complete
    if [[ "$status" == "$STATUS_COMPLETE" ]]; then
        error "Cannot assign $req_id: Requirement is already $STATUS_COMPLETE Complete

Archived or ready to archive. Check .haunt/completed/ for details." 3
    fi

    # Check if blocked
    if [[ "$status" == "$STATUS_BLOCKED" ]]; then
        local blocked_by
        blocked_by=$(get_blocked_by "$req_block")
        error "Cannot assign $req_id: Requirement is $STATUS_BLOCKED Blocked

Blocked by: $blocked_by

Recommendation: Resolve blocker first or choose unblocked requirement." 3
    fi

    # Warn if already in progress
    if [[ "$status" == "$STATUS_IN_PROGRESS" && "$force" != "true" ]]; then
        warn "$req_id is already $STATUS_IN_PROGRESS In Progress"
        echo ""
        echo "Do you want to:"
        echo "  1. Continue with this requirement (load context)"
        echo "  2. Cancel and choose different requirement"
        echo ""
        read -rp "Choose [1/2]: " choice

        case "$choice" in
            1)
                return 0
                ;;
            2)
                exit 0
                ;;
            *)
                error "Invalid choice" 1
                ;;
        esac
    fi

    return 0
}

# ============================================================================
# ROADMAP UPDATE
# ============================================================================

# Update requirement status in roadmap
update_status() {
    local req_file="$1"
    local req_id="$2"
    local old_status="$3"
    local new_status="$4"

    # Use sed to replace status (macOS and Linux compatible)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS requires backup extension
        sed -i '' "s/^### $old_status $req_id:/### $new_status $req_id:/" "$req_file"
    else
        # Linux
        sed -i "s/^### $old_status $req_id:/### $new_status $req_id:/" "$req_file"
    fi
}

# ============================================================================
# OUTPUT FORMATTING
# ============================================================================

# Display requirement details for context
display_requirement() {
    local req_id="$1"
    local req_block="$2"

    local title
    title=$(get_title "$req_block")

    local type agent effort complexity
    type=$(get_field "$req_block" "Type")
    agent=$(get_field "$req_block" "Agent")
    effort=$(get_field "$req_block" "Effort")
    complexity=$(get_field "$req_block" "Complexity")

    echo ""
    info "  Type: ${type:-Not specified}"
    info "  Agent: ${agent:-Not specified}"
    info "  Effort: ${effort:-Not specified}"
    info "  Complexity: ${complexity:-Not specified}"
    echo ""

    # Extract description
    local description
    description=$(echo "$req_block" | sed -n '/^\*\*Description:\*\*$/,/^$/p' | tail -n +2 | sed '$d')
    if [[ -n "$description" ]]; then
        info "  Description:"
        echo "$description" | sed 's/^/  /'
        echo ""
    fi

    # Extract tasks
    local tasks
    tasks=$(echo "$req_block" | sed -n '/^\*\*Tasks:\*\*$/,/^$/p' | tail -n +2 | grep "^- \[")
    if [[ -n "$tasks" ]]; then
        info "  Tasks:"
        echo "$tasks" | sed 's/^/  /'
        echo ""
    fi

    # Extract files
    local files
    files=$(echo "$req_block" | sed -n '/^\*\*Files:\*\*$/,/^$/p' | tail -n +2 | grep "^- ")
    if [[ -n "$files" ]]; then
        info "  Files:"
        echo "$files" | sed 's/^/  /'
        echo ""
    fi

    # Extract completion criteria
    local completion
    completion=$(echo "$req_block" | sed -n '/^\*\*Completion:\*\*$/,/^$/p' | tail -n +2 | sed '$d')
    if [[ -n "$completion" ]]; then
        info "  Completion Criteria:"
        echo "$completion" | sed 's/^/  /'
        echo ""
    fi

    # Check blocked by
    local blocked_by
    blocked_by=$(get_blocked_by "$req_block")
    if [[ -n "$blocked_by" && "$blocked_by" != "None" ]]; then
        warn "  Blocked by: $blocked_by"
        echo ""
    fi
}

# Check for story file
check_story_file() {
    local req_id="$1"
    local project_root="$2"

    local story_file="$project_root/$STORIES_DIR/${req_id}-story.md"

    if [[ -f "$story_file" ]]; then
        echo ""
        success "Story file found: $story_file"
        echo ""
        info "Recommendation: Read story file for implementation context before starting."
        echo ""
        info "The story file contains:"
        echo "  - Implementation approach and technical strategy"
        echo "  - Code examples and references from codebase"
        echo "  - Known edge cases and gotchas"
        echo "  - Session notes from previous work"
        echo ""
    fi
}

# ============================================================================
# MAIN LOGIC
# ============================================================================

main() {
    local req_id=""
    local dry_run=false
    local force=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --force)
                force=true
                shift
                ;;
            REQ-*)
                req_id="$1"
                shift
                ;;
            *)
                error "Unknown argument: $1\n\nUse --help for usage information" 1
                ;;
        esac
    done

    # Validate arguments
    if [[ -z "$req_id" ]]; then
        error "Missing requirement ID\n\nUsage: $SCRIPT_NAME REQ-XXX [OPTIONS]\n\nUse --help for more information" 1
    fi

    # Find roadmap
    local roadmap_file
    roadmap_file=$(find_roadmap)

    local project_root
    project_root="$(dirname "$(dirname "$roadmap_file")")"

    # Find requirement (in roadmap or batch file)
    local req_file
    req_file=$(find_requirement "$req_id" "$roadmap_file")
    if [[ -z "$req_file" ]]; then
        error "Requirement $req_id not found in roadmap or batch files" 1
    fi

    # Parse requirement
    local req_block
    req_block=$(parse_requirement "$req_file" "$req_id")
    if [[ -z "$req_block" ]]; then
        error "Failed to parse requirement $req_id" 1
    fi

    # Get current status
    local current_status
    current_status=$(get_status "$req_block")

    # Validate assignment
    validate_assignment "$req_id" "$req_block" "$force"

    # Display assignment info
    local title
    title=$(get_title "$req_block")

    if [[ "$dry_run" == "true" ]]; then
        info "DRY RUN: Would assign to $req_id: $title"
        info "  Current status: $current_status"
        info "  New status: $STATUS_IN_PROGRESS"
        echo ""
        display_requirement "$req_id" "$req_block"
        exit 0
    fi

    # Update status if not already in progress
    if [[ "$current_status" != "$STATUS_IN_PROGRESS" ]]; then
        update_status "$req_file" "$req_id" "$current_status" "$STATUS_IN_PROGRESS"
        success "Assigned to $req_id: $title"
        echo ""
        info "  Status: $current_status → $STATUS_IN_PROGRESS"
    else
        success "Continuing with $req_id: $title"
        echo ""
        info "  Status: $STATUS_IN_PROGRESS (already in progress)"
    fi

    # Display requirement details
    display_requirement "$req_id" "$req_block"

    # Check for story file
    check_story_file "$req_id" "$project_root"
}

# Run main
main "$@"
