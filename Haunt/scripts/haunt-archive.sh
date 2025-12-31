#!/usr/bin/env bash
#
# haunt-archive.sh - Structured Archive Lookup Wrapper
#
# Returns structured JSON output for archive queries, eliminating the need
# to read entire archive file when looking up completed requirements.
#
# Usage:
#   haunt-archive search REQ-XXX              # Find specific completed requirement
#   haunt-archive list [--since=YYYY-MM-DD]   # List completions, optionally filtered by date
#   haunt-archive get REQ-XXX                 # Get full completion details
#   haunt-archive stats                       # Summary statistics
#
# Exit Codes:
#   0 - Success
#   1 - Error (invalid usage or requirement not found)
#   2 - Archive file not found

set -u
set -o pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="haunt-archive"
readonly VERSION="1.0.0"

# Archive file location (relative to project root)
readonly DEFAULT_ARCHIVE=".haunt/completed/roadmap-archive.md"

# ============================================================================
# ERROR HANDLING
# ============================================================================

error() {
    echo "{\"error\": \"$1\"}" >&2
    exit "${2:-1}"
}

# Find archive file (search up directory tree)
find_archive() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/$DEFAULT_ARCHIVE" ]]; then
            echo "$dir/$DEFAULT_ARCHIVE"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    # Archive file may not exist yet - return empty success
    echo ""
    return 0
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

# Parse a single archived requirement block
parse_archived_requirement() {
    local archive_file="$1"
    local req_id="$2"

    # Find requirement start line (format: ### REQ-XXX:)
    local start_line
    start_line=$(grep -n "^### REQ-$req_id:" "$archive_file" | cut -d: -f1 | head -1)

    if [[ -z "$start_line" ]]; then
        # Try alternative format: ### 🟢 REQ-XXX:
        start_line=$(grep -n "^### [🟢] REQ-$req_id:" "$archive_file" | cut -d: -f1 | head -1)
    fi

    if [[ -z "$start_line" ]]; then
        echo "{\"error\": \"Requirement REQ-$req_id not found in archive\"}"
        return 1
    fi

    # Extract requirement block (until next ### or ---)
    local end_line
    end_line=$(tail -n +$((start_line + 1)) "$archive_file" | grep -n "^###\|^---" | head -1 | cut -d: -f1)

    if [[ -n "$end_line" ]]; then
        end_line=$((start_line + end_line - 1))
    else
        # End of file
        end_line=$(wc -l < "$archive_file" | tr -d ' ')
    fi

    # Extract block content
    local block_content
    block_content=$(sed -n "${start_line},${end_line}p" "$archive_file")

    # Parse fields
    local title
    title=$(echo "$block_content" | grep "^### " | sed 's/^### {[🟢]} //; s/^### [🟢] //; s/^### //' | sed "s/REQ-$req_id: //" | head -1)

    local completed_date
    completed_date=$(echo "$block_content" | grep "^\\*\\*Completed:\\*\\*\|^\\*\\*Date:\\*\\*" | sed 's/\*\*Completed:\*\* //; s/\*\*Date:\*\* //' | head -1 || echo "")

    local effort
    effort=$(echo "$block_content" | grep "^\\*\\*Effort:\\*\\*" | sed 's/\*\*Effort:\*\* //' || echo "")

    local agent
    agent=$(echo "$block_content" | grep "^\\*\\*Completed by:\\*\\*\|^\\*\\*Agent:\\*\\*" | sed 's/\*\*Completed by:\*\* //; s/\*\*Agent:\*\* //' | head -1 || echo "")

    local type
    type=$(echo "$block_content" | grep "^\\*\\*Type:\\*\\*" | sed 's/\*\*Type:\*\* //' || echo "")

    # Parse files changed
    local files_changed=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local file_path=$(escape_json "$line")
            files_changed+=("\"$file_path\"")
        fi
    done < <(echo "$block_content" | grep "^\\*\\*Files Changed:\\*\\*" | sed 's/\*\*Files Changed:\*\* //' | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v "^$")

    # If files not found in single line, try list format
    if [[ ${#files_changed[@]} -eq 0 ]]; then
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                local file_path=$(escape_json "$line")
                files_changed+=("\"$file_path\"")
            fi
        done < <(echo "$block_content" | sed -n '/^\*\*Files Changed:\*\*/,/^\*\*[A-Za-z]/{/^\*\*Files Changed:\*\*/d; /^\*\*[A-Za-z]/d; s/^- //p}')
    fi

    local files_json=""
    if [[ ${#files_changed[@]} -gt 0 ]]; then
        files_json=$(IFS=,; echo "${files_changed[*]}")
    fi

    # Parse tasks
    local tasks=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local task_text="${line#*] }"
            task_text=$(escape_json "$task_text")
            tasks+=("\"$task_text\"")
        fi
    done < <(echo "$block_content" | grep "^- \[x\]" | sed 's/^- \[x\] //')

    local tasks_json=""
    if [[ ${#tasks[@]} -gt 0 ]]; then
        tasks_json=$(IFS=,; echo "${tasks[*]}")
    fi

    # Parse completion criteria
    local completion=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local criterion=$(escape_json "$line")
            completion+=("\"$criterion\"")
        fi
    done < <(echo "$block_content" | sed -n '/^\*\*Completion Criteria Met:\*\*/,/^\*\*[A-Za-z]/{/^\*\*Completion Criteria Met:\*\*/d; /^\*\*[A-Za-z]/d; s/^- \[x\] //p}')

    local completion_json=""
    if [[ ${#completion[@]} -gt 0 ]]; then
        completion_json=$(IFS=,; echo "${completion[*]}")
    fi

    # Escape string fields
    title=$(escape_json "$title")
    completed_date=$(escape_json "$completed_date")
    effort=$(escape_json "$effort")
    agent=$(escape_json "$agent")
    type=$(escape_json "$type")

    # Output JSON
    cat <<EOF
{
  "requirement": "REQ-$req_id",
  "title": "$title",
  "completed_date": "$completed_date",
  "effort": "$effort",
  "agent": "$agent",
  "type": "$type",
  "files_changed": [$files_json],
  "tasks": [$tasks_json],
  "completion_criteria": [$completion_json],
  "line_start": $start_line
}
EOF
}

# ============================================================================
# SEARCH COMMAND
# ============================================================================

cmd_search() {
    local archive_file
    archive_file=$(find_archive)

    if [[ -z "$archive_file" ]]; then
        echo "{\"found\": false, \"error\": \"Archive file not found\"}"
        return 0
    fi

    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME search REQ-XXX"
    fi

    local req_id="$1"

    # Strip "REQ-" prefix if provided
    req_id="${req_id#REQ-}"

    # Validate requirement ID format
    if [[ ! "$req_id" =~ ^[0-9]+$ ]]; then
        error "Invalid requirement ID format: $req_id (expected REQ-XXX or XXX)"
    fi

    # Find requirement
    local start_line
    start_line=$(grep -n "^### REQ-$req_id:\|^### [🟢] REQ-$req_id:" "$archive_file" | cut -d: -f1 | head -1)

    if [[ -z "$start_line" ]]; then
        echo "{\"requirement\": \"REQ-$req_id\", \"found\": false}"
        return 0
    fi

    # Extract title and completed date
    local title
    title=$(sed -n "${start_line}p" "$archive_file" | sed 's/^### {[🟢]} //; s/^### [🟢] //; s/^### //' | sed "s/REQ-$req_id: //" | head -1)

    local completed_date
    completed_date=$(sed -n "$((start_line + 1)),\$p" "$archive_file" | grep -m 1 "^\\*\\*Completed:\\*\\*\|^\\*\\*Date:\\*\\*" | sed 's/\*\*Completed:\*\* //; s/\*\*Date:\*\* //' || echo "")

    title=$(escape_json "$title")
    completed_date=$(escape_json "$completed_date")

    cat <<EOF
{
  "requirement": "REQ-$req_id",
  "found": true,
  "title": "$title",
  "completed_date": "$completed_date",
  "line_start": $start_line
}
EOF
}

# ============================================================================
# LIST COMMAND
# ============================================================================

cmd_list() {
    local archive_file
    archive_file=$(find_archive)

    if [[ -z "$archive_file" ]]; then
        echo "{\"requirements\": [], \"total\": 0, \"filter\": \"none\"}"
        return 0
    fi

    local since_date=""
    local filter_text="none"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --since=*)
                since_date="${1#*=}"
                filter_text="since:$since_date"
                shift
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    # Extract all requirement IDs
    local req_ids=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local req_id
            req_id=$(echo "$line" | grep -o "REQ-[0-9]\+" | sed 's/REQ-//' | head -1)
            if [[ -n "$req_id" ]]; then
                req_ids+=("$req_id")
            fi
        fi
    done < <(grep "^### REQ-\|^### [🟢] REQ-" "$archive_file")

    # Parse each requirement and filter
    local results=()
    for req_id in "${req_ids[@]}"; do
        local req_json
        req_json=$(parse_archived_requirement "$archive_file" "$req_id" 2>/dev/null)

        # Skip if parsing failed
        if [[ $(echo "$req_json" | grep -c "\"error\"") -gt 0 ]]; then
            continue
        fi

        # Apply date filter
        if [[ -n "$since_date" ]]; then
            local completed_date
            completed_date=$(echo "$req_json" | grep -o '"completed_date": "[^"]*"' | cut -d'"' -f4)

            # Compare dates (simple string comparison works for YYYY-MM-DD)
            if [[ "$completed_date" < "$since_date" ]]; then
                continue
            fi
        fi

        # Extract summary fields for list
        local id title completed effort
        id=$(echo "$req_json" | grep -o '"requirement": "[^"]*"' | cut -d'"' -f4)
        title=$(echo "$req_json" | grep -o '"title": "[^"]*"' | cut -d'"' -f4)
        completed=$(echo "$req_json" | grep -o '"completed_date": "[^"]*"' | cut -d'"' -f4)
        effort=$(echo "$req_json" | grep -o '"effort": "[^"]*"' | cut -d'"' -f4)

        local summary="{\"id\": \"$id\", \"title\": \"$title\", \"completed\": \"$completed\", \"effort\": \"$effort\"}"
        results+=("$summary")
    done

    # Output JSON array
    local results_json=""
    if [[ ${#results[@]} -gt 0 ]]; then
        results_json=$(IFS=,; echo "${results[*]}")
    fi

    filter_text=$(escape_json "$filter_text")

    cat <<EOF
{
  "requirements": [$results_json],
  "total": ${#results[@]},
  "filter": "$filter_text"
}
EOF
}

# ============================================================================
# GET COMMAND
# ============================================================================

cmd_get() {
    local archive_file
    archive_file=$(find_archive)

    if [[ -z "$archive_file" ]]; then
        error "Archive file not found" 2
    fi

    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME get REQ-XXX"
    fi

    local req_id="$1"

    # Strip "REQ-" prefix if provided
    req_id="${req_id#REQ-}"

    # Validate requirement ID format
    if [[ ! "$req_id" =~ ^[0-9]+$ ]]; then
        error "Invalid requirement ID format: $req_id (expected REQ-XXX or XXX)"
    fi

    parse_archived_requirement "$archive_file" "$req_id"
}

# ============================================================================
# STATS COMMAND
# ============================================================================

cmd_stats() {
    local archive_file
    archive_file=$(find_archive)

    if [[ -z "$archive_file" ]]; then
        echo "{\"total_completed\": 0, \"by_effort\": {}, \"by_agent\": {}, \"date_range\": {}}"
        return 0
    fi

    # Extract all requirement IDs
    local req_ids=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local req_id
            req_id=$(echo "$line" | grep -o "REQ-[0-9]\+" | sed 's/REQ-//' | head -1)
            if [[ -n "$req_id" ]]; then
                req_ids+=("$req_id")
            fi
        fi
    done < <(grep "^### REQ-\|^### [🟢] REQ-" "$archive_file")

    local total_completed=${#req_ids[@]}

    # Count by effort
    declare -A effort_counts
    effort_counts["XS"]=0
    effort_counts["S"]=0
    effort_counts["M"]=0
    effort_counts["L"]=0

    # Count by agent
    declare -A agent_counts

    # Track date range
    local earliest_date=""
    local latest_date=""

    # Parse each requirement
    for req_id in "${req_ids[@]}"; do
        local req_json
        req_json=$(parse_archived_requirement "$archive_file" "$req_id" 2>/dev/null)

        # Skip if parsing failed
        if [[ $(echo "$req_json" | grep -c "\"error\"") -gt 0 ]]; then
            continue
        fi

        # Extract effort
        local effort
        effort=$(echo "$req_json" | grep -o '"effort": "[^"]*"' | cut -d'"' -f4)
        if [[ -n "$effort" ]] && [[ -n "${effort_counts[$effort]+_}" ]]; then
            ((effort_counts[$effort]++))
        fi

        # Extract agent
        local agent
        agent=$(echo "$req_json" | grep -o '"agent": "[^"]*"' | cut -d'"' -f4)
        if [[ -n "$agent" ]]; then
            if [[ -z "${agent_counts[$agent]+_}" ]]; then
                agent_counts[$agent]=0
            fi
            ((agent_counts[$agent]++))
        fi

        # Track dates
        local completed_date
        completed_date=$(echo "$req_json" | grep -o '"completed_date": "[^"]*"' | cut -d'"' -f4)
        if [[ -n "$completed_date" ]]; then
            if [[ -z "$earliest_date" ]] || [[ "$completed_date" < "$earliest_date" ]]; then
                earliest_date="$completed_date"
            fi
            if [[ -z "$latest_date" ]] || [[ "$completed_date" > "$latest_date" ]]; then
                latest_date="$completed_date"
            fi
        fi
    done

    # Build by_effort JSON
    local effort_json=""
    for effort in XS S M L; do
        if [[ -n "$effort_json" ]]; then
            effort_json="$effort_json, "
        fi
        effort_json="$effort_json\"$effort\": ${effort_counts[$effort]}"
    done

    # Build by_agent JSON
    local agent_json=""
    for agent in "${!agent_counts[@]}"; do
        if [[ -n "$agent_json" ]]; then
            agent_json="$agent_json, "
        fi
        local agent_escaped=$(escape_json "$agent")
        agent_json="$agent_json\"$agent_escaped\": ${agent_counts[$agent]}"
    done

    # Build date_range JSON
    local date_range_json=""
    if [[ -n "$earliest_date" ]]; then
        date_range_json="\"earliest\": \"$earliest_date\", \"latest\": \"$latest_date\""
    fi

    cat <<EOF
{
  "total_completed": $total_completed,
  "by_effort": {$effort_json},
  "by_agent": {$agent_json},
  "date_range": {$date_range_json}
}
EOF
}

# ============================================================================
# HELP TEXT
# ============================================================================

show_help() {
    cat <<EOF
$SCRIPT_NAME - Structured Archive Lookup Wrapper

USAGE:
    $SCRIPT_NAME <command> [options]

COMMANDS:
    search REQ-XXX             Find specific completed requirement (quick check)
    list [--since=DATE]        List completions, optionally filtered by date
    get REQ-XXX                Get full completion details
    stats                      Summary statistics

OPTIONS:
    --help                     Show this help message
    --version                  Show version information

EXAMPLES:
    # Quick check if requirement is completed
    $SCRIPT_NAME search REQ-274

    # List all completed requirements
    $SCRIPT_NAME list

    # List requirements completed since date
    $SCRIPT_NAME list --since=2025-12-01

    # Get full details for specific requirement
    $SCRIPT_NAME get REQ-274

    # View archive statistics
    $SCRIPT_NAME stats

OUTPUT FORMAT:
    search (quick check):
    {
      "requirement": "REQ-274",
      "found": true,
      "title": "Structured Roadmap Lookup Wrapper",
      "completed_date": "2025-12-30",
      "line_start": 156
    }

    list (summary):
    {
      "requirements": [
        {"id": "REQ-274", "title": "...", "completed": "2025-12-30", "effort": "S"}
      ],
      "total": 15,
      "filter": "since:2025-12-01"
    }

    get (full details):
    {
      "requirement": "REQ-274",
      "title": "...",
      "completed_date": "2025-12-30",
      "effort": "S",
      "agent": "Dev-Infrastructure",
      "files_changed": ["file1", "file2"],
      "tasks": ["task1", "task2"],
      "completion_criteria": ["criterion1"],
      "line_start": 156
    }

    stats (summary):
    {
      "total_completed": 45,
      "by_effort": {"XS": 10, "S": 20, "M": 12, "L": 3},
      "by_agent": {"Dev-Infrastructure": 15, "Dev-Backend": 20},
      "date_range": {"earliest": "2025-11-01", "latest": "2025-12-30"}
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
        search)
            cmd_search "$@"
            ;;
        list)
            cmd_list "$@"
            ;;
        get)
            cmd_get "$@"
            ;;
        stats)
            cmd_stats "$@"
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
