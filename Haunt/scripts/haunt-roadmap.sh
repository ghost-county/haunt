#!/usr/bin/env bash
#
# haunt-roadmap.sh - Structured Roadmap Lookup Wrapper
#
# Returns structured JSON output for roadmap queries, eliminating the need
# to read entire roadmap file when looking up specific requirements.
#
# Usage:
#   haunt-roadmap get REQ-XXX              # Get specific requirement as JSON
#   haunt-roadmap list --status=🟡         # List requirements by status
#   haunt-roadmap list --agent=Dev-Backend # List requirements by agent type
#   haunt-roadmap my-work                  # Show requirements for caller (future)
#
# Exit Codes:
#   0 - Success
#   1 - Error (invalid usage or requirement not found)
#   2 - Roadmap file not found

set -u
set -o pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="haunt-roadmap"
readonly VERSION="1.0.0"

# Roadmap file location (relative to project root)
readonly DEFAULT_ROADMAP=".haunt/plans/roadmap.md"

# ============================================================================
# ERROR HANDLING
# ============================================================================

error() {
    echo "{\"error\": \"$1\"}" >&2
    exit "${2:-1}"
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
    error "Roadmap not found: $DEFAULT_ROADMAP (searched up from $PWD)" 2
}

# ============================================================================
# JSON ESCAPING
# ============================================================================

# Escape JSON special characters
escape_json() {
    local input="$1"
    # Escape backslashes first
    input="${input//\\/\\\\}"
    # Escape double quotes
    input="${input//\"/\\\"}"
    # Escape newlines
    input="${input//$'\n'/\\n}"
    # Escape tabs
    input="${input//$'\t'/\\t}"
    # Escape carriage returns
    input="${input//$'\r'/\\r}"
    echo "$input"
}

# ============================================================================
# REQUIREMENT PARSING
# ============================================================================

# Parse a single requirement block starting at line number
parse_requirement() {
    local roadmap_file="$1"
    local req_id="$2"

    # Find requirement start line (format: ### STATUS REQ-XXX:)
    local start_line
    start_line=$(grep -n "^### [⚪🟡🟢🔴] $req_id:" "$roadmap_file" | cut -d: -f1 | head -1)

    if [[ -z "$start_line" ]]; then
        echo "{\"error\": \"Requirement $req_id not found in roadmap\"}"
        return 1
    fi

    # Extract requirement block (until next ### or --- or empty line followed by ##)
    local end_line
    end_line=$(tail -n +$((start_line + 1)) "$roadmap_file" | grep -n "^###\|^---" | head -1 | cut -d: -f1)

    if [[ -n "$end_line" ]]; then
        end_line=$((start_line + end_line - 1))
    else
        # End of file
        end_line=$(wc -l < "$roadmap_file" | tr -d ' ')
    fi

    # Ensure we don't go past actual content - trim at first "---" separator
    local actual_end
    actual_end=$(sed -n "${start_line},${end_line}p" "$roadmap_file" | grep -n "^---$" | head -1 | cut -d: -f1)
    if [[ -n "$actual_end" ]]; then
        end_line=$((start_line + actual_end - 2))
    fi

    # Extract block content
    local block_content
    block_content=$(sed -n "${start_line},${end_line}p" "$roadmap_file")

    # Parse fields
    local title
    title=$(echo "$block_content" | grep "^### " | sed 's/^### {[⚪🟡🟢🔴]} //; s/^### [⚪🟡🟢🔴] //' | cut -d: -f2- | sed 's/^ *//')

    local status
    status=$(echo "$block_content" | grep "^### " | grep -o "{[⚪🟡🟢🔴]}" | tr -d '{}' || true)
    if [[ -z "$status" ]]; then
        status=$(echo "$block_content" | grep "^### " | grep -o "[⚪🟡🟢🔴]" | head -1 || echo "⚪")
    fi

    local type
    type=$(echo "$block_content" | grep "^\\*\\*Type:\\*\\*" | sed 's/\*\*Type:\*\* //' || echo "")

    local effort
    effort=$(echo "$block_content" | grep "^\\*\\*Effort:\\*\\*" | sed 's/\*\*Effort:\*\* //' || echo "")

    local agent
    agent=$(echo "$block_content" | grep "^\\*\\*Agent:\\*\\*" | sed 's/\*\*Agent:\*\* //' || echo "")

    local blocked_by
    blocked_by=$(echo "$block_content" | grep "^\\*\\*Blocked by:\\*\\*" | sed 's/\*\*Blocked by:\*\* //' || echo "None")
    if [[ "$blocked_by" == "None" ]] || [[ -z "$blocked_by" ]]; then
        blocked_by="null"
    else
        blocked_by="\"$(escape_json "$blocked_by")\""
    fi

    local completion
    completion=$(echo "$block_content" | grep "^\\*\\*Completion:\\*\\*" | sed 's/\*\*Completion:\*\* //' || echo "")

    # Parse tasks (array of strings)
    local tasks=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            # Remove checkbox markers
            local task_text="${line#*] }"
            task_text=$(escape_json "$task_text")
            tasks+=("\"$task_text\"")
        fi
    done < <(echo "$block_content" | grep "^- \[" | sed 's/^- \[[x ]\] //')

    local tasks_json=""
    if [[ ${#tasks[@]} -gt 0 ]]; then
        tasks_json=$(IFS=,; echo "${tasks[*]}")
    fi

    # Escape string fields
    title=$(escape_json "$title")
    type=$(escape_json "$type")
    effort=$(escape_json "$effort")
    agent=$(escape_json "$agent")
    completion=$(escape_json "$completion")

    # Output JSON
    cat <<EOF
{
  "id": "$req_id",
  "title": "$title",
  "status": "$status",
  "type": "$type",
  "effort": "$effort",
  "agent": "$agent",
  "blocked_by": $blocked_by,
  "tasks": [$tasks_json],
  "completion": "$completion"
}
EOF
}

# ============================================================================
# GET COMMAND
# ============================================================================

cmd_get() {
    local roadmap_file
    roadmap_file=$(find_roadmap)

    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME get REQ-XXX"
    fi

    local req_id="$1"

    # Validate REQ-XXX format
    if [[ ! "$req_id" =~ ^REQ-[0-9]+$ ]]; then
        error "Invalid requirement ID format: $req_id (expected REQ-XXX)"
    fi

    parse_requirement "$roadmap_file" "$req_id"
}

# ============================================================================
# LIST COMMAND
# ============================================================================

cmd_list() {
    local roadmap_file
    roadmap_file=$(find_roadmap)

    local filter_status=""
    local filter_agent=""
    local filter_project=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --status=*)
                filter_status="${1#*=}"
                shift
                ;;
            --agent=*)
                filter_agent="${1#*=}"
                shift
                ;;
            --project=*)
                filter_project="${1#*=}"
                shift
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    # Extract all requirement IDs with their line numbers
    local req_ids=()
    local req_lines=()
    while IFS=: read -r line_num line_content; do
        if [[ -n "$line_content" ]]; then
            local req_id
            req_id=$(echo "$line_content" | grep -o "REQ-[0-9]\+" | head -1)
            if [[ -n "$req_id" ]]; then
                req_ids+=("$req_id")
                req_lines+=("$line_num")
            fi
        fi
    done < <(grep -n "^### {[⚪🟡🟢🔴]} REQ-\|^### [⚪🟡🟢🔴] REQ-" "$roadmap_file")

    # Build section map: line number -> section name
    # Sections are ## headers (not ### requirement headers)
    declare -A section_map
    local current_section=""
    local section_start=0
    while IFS=: read -r line_num line_content; do
        # Extract section name from ## Header
        local section_name
        section_name=$(echo "$line_content" | sed 's/^## //')
        section_map["$line_num"]="$section_name"
    done < <(grep -n "^## " "$roadmap_file" | grep -v "^## Summary\|^## Recent Archives\|^## Current Focus")

    # Get sorted section line numbers for determining which section a req belongs to
    local section_lines=()
    for line in "${!section_map[@]}"; do
        section_lines+=("$line")
    done
    IFS=$'\n' section_lines=($(sort -n <<<"${section_lines[*]}")); unset IFS

    # Helper: find section for a given line number
    get_section_for_line() {
        local target_line="$1"
        local found_section=""
        for section_line in "${section_lines[@]}"; do
            if [[ "$section_line" -le "$target_line" ]]; then
                found_section="${section_map[$section_line]}"
            else
                break
            fi
        done
        echo "$found_section"
    }

    # Parse each requirement and filter
    local results=()
    local idx=0
    for req_id in "${req_ids[@]}"; do
        local req_line="${req_lines[$idx]}"
        local req_json
        req_json=$(parse_requirement "$roadmap_file" "$req_id")

        # Apply filters
        local include=true

        # Project filter: check which section the requirement is under
        if [[ -n "$filter_project" ]]; then
            local req_section
            req_section=$(get_section_for_line "$req_line")
            # Case-insensitive partial match (e.g., "Haunt" matches "Haunt Framework")
            if [[ ! "${req_section,,}" =~ ${filter_project,,} ]]; then
                include=false
            fi
        fi

        if [[ -n "$filter_status" ]]; then
            local req_status
            req_status=$(echo "$req_json" | grep -o '"status": "[^"]*"' | cut -d'"' -f4)
            if [[ "$req_status" != "$filter_status" ]]; then
                include=false
            fi
        fi

        if [[ -n "$filter_agent" ]]; then
            local req_agent
            req_agent=$(echo "$req_json" | grep -o '"agent": "[^"]*"' | cut -d'"' -f4)
            if [[ "$req_agent" != "$filter_agent" ]]; then
                include=false
            fi
        fi

        if [[ "$include" == true ]]; then
            results+=("$req_json")
        fi

        ((idx++))
    done

    # Output JSON array
    local results_json=""
    if [[ ${#results[@]} -gt 0 ]]; then
        results_json=$(IFS=,; echo "${results[*]}")
    fi

    cat <<EOF
{
  "count": ${#results[@]},
  "requirements": [$results_json]
}
EOF
}

# ============================================================================
# MY-WORK COMMAND
# ============================================================================

cmd_my_work() {
    # Future: Detect agent type from environment or context
    # For now, placeholder that shows usage
    cat <<EOF
{
  "error": "my-work command not yet implemented",
  "workaround": "Use: haunt-roadmap list --agent=Dev-Backend (replace with your agent type)"
}
EOF
    return 1
}

# ============================================================================
# HELP TEXT
# ============================================================================

show_help() {
    cat <<EOF
$SCRIPT_NAME - Structured Roadmap Lookup Wrapper

USAGE:
    $SCRIPT_NAME <command> [options]

COMMANDS:
    get REQ-XXX                Get specific requirement as JSON
    list [filters]             List requirements with optional filters
    my-work                    Show requirements for caller (placeholder)

LIST FILTERS:
    --status={⚪|🟡|🟢|🔴}     Filter by status icon
    --agent=<agent-type>       Filter by assigned agent type
    --project=<project>        Filter by project section (case-insensitive partial match)

OPTIONS:
    --help                     Show this help message
    --version                  Show version information

EXAMPLES:
    # Get specific requirement
    $SCRIPT_NAME get REQ-274

    # List in-progress requirements
    $SCRIPT_NAME list --status=🟡

    # List requirements for Dev-Backend agent
    $SCRIPT_NAME list --agent=Dev-Backend

    # List requirements in TrueSight project section
    $SCRIPT_NAME list --project=TrueSight

    # Combine filters: TrueSight project, Dev-Frontend agent
    $SCRIPT_NAME list --project=TrueSight --agent=Dev-Frontend

    # List all requirements
    $SCRIPT_NAME list

OUTPUT FORMAT:
    Single requirement (get):
    {
      "id": "REQ-274",
      "title": "Structured Roadmap Lookup Wrapper",
      "status": "⚪",
      "type": "Enhancement",
      "effort": "S",
      "agent": "Dev-Infrastructure",
      "blocked_by": null,
      "tasks": ["task1", "task2"],
      "completion": "Completion criteria here"
    }

    Multiple requirements (list):
    {
      "count": 2,
      "requirements": [...]
    }

VERSION:
    $VERSION
EOF
}

# ============================================================================
# MAIN DISPATCH
# ============================================================================

main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 1
    fi

    local command="$1"
    shift

    # Dispatch to command handlers
    case "$command" in
        get)
            cmd_get "$@"
            ;;
        list)
            cmd_list "$@"
            ;;
        my-work)
            cmd_my_work "$@"
            ;;
        --help|-h|help)
            show_help
            ;;
        --version|-v)
            echo "$SCRIPT_NAME version $VERSION"
            ;;
        *)
            error "Unknown command: $command (use --help for usage)"
            ;;
    esac
}

main "$@"
