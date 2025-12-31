#!/usr/bin/env bash
#
# haunt-lessons.sh - Lessons Learned Query Wrapper
#
# Returns structured JSON output for lessons-learned queries, eliminating
# the need to read entire 752-line file when looking up specific sections.
#
# Usage:
#   haunt-lessons list                    # List all section titles as JSON
#   haunt-lessons get "Section Name"      # Get specific section content
#   haunt-lessons search "keyword"        # Search across all lessons
#   haunt-lessons --help                  # Show usage
#
# Exit Codes:
#   0 - Success
#   1 - Error (invalid usage or section not found)
#   2 - Lessons file not found

set -u
set -o pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="haunt-lessons"
readonly VERSION="1.0.0"

# Lessons file location (relative to project root)
readonly DEFAULT_LESSONS=".haunt/docs/lessons-learned.md"

# ============================================================================
# ERROR HANDLING
# ============================================================================

error() {
    echo "{\"error\": \"$1\"}" >&2
    exit "${2:-1}"
}

# Find lessons file (search up directory tree)
find_lessons() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/$DEFAULT_LESSONS" ]]; then
            echo "$dir/$DEFAULT_LESSONS"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    error "Lessons file not found: $DEFAULT_LESSONS (searched up from $PWD)" 2
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
# SECTION PARSING
# ============================================================================

# Get file total line count
get_file_line_count() {
    local file="$1"
    wc -l < "$file" | tr -d ' '
}

# Parse all section titles (## headings)
parse_section_titles() {
    local lessons_file="$1"

    local sections=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^##[[:space:]](.+)$ ]]; then
            local section_name="${BASH_REMATCH[1]}"
            section_name=$(escape_json "$section_name")
            sections+=("\"$section_name\"")
        fi
    done < "$lessons_file"

    # Return array elements for proper handling
    printf '%s\n' "${sections[@]}"
}

# Find section by name and extract content
parse_section_content() {
    local lessons_file="$1"
    local section_name="$2"

    # Find section start line (format: ## Section Name)
    local start_line
    start_line=$(grep -n "^## $section_name\$" "$lessons_file" | cut -d: -f1 | head -1)

    if [[ -z "$start_line" ]]; then
        echo "{\"error\": \"Section '$section_name' not found in lessons file\"}"
        return 1
    fi

    # Find next section (next ## heading) or end of file
    local end_line
    end_line=$(tail -n +$((start_line + 1)) "$lessons_file" | grep -n "^## " | head -1 | cut -d: -f1)

    if [[ -n "$end_line" ]]; then
        # End at line before next section
        end_line=$((start_line + end_line - 1))
    else
        # End of file
        end_line=$(get_file_line_count "$lessons_file")
    fi

    # Extract section content (excluding the heading line itself)
    local content
    content=$(sed -n "$((start_line + 1)),${end_line}p" "$lessons_file")

    # Trim trailing empty lines
    content=$(echo "$content" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

    # Calculate line count
    local line_count=$((end_line - start_line))

    # Get total file lines
    local file_total_lines
    file_total_lines=$(get_file_line_count "$lessons_file")

    # Escape content for JSON
    content=$(escape_json "$content")

    # Output JSON
    cat <<EOF
{
  "section": "$section_name",
  "content": "$content",
  "line_start": $start_line,
  "line_end": $end_line,
  "line_count": $line_count,
  "file_total_lines": $file_total_lines
}
EOF
}

# Search for keyword across all sections
search_lessons() {
    local lessons_file="$1"
    local query="$2"

    # Get all section names
    local section_titles=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^##[[:space:]](.+)$ ]]; then
            section_titles+=("${BASH_REMATCH[1]}")
        fi
    done < "$lessons_file"

    # Search each section for matches
    local matches=()
    local total_matches=0

    for section in "${section_titles[@]}"; do
        # Get section content
        local section_json
        section_json=$(parse_section_content "$lessons_file" "$section" 2>/dev/null)

        if [[ $? -eq 0 ]]; then
            # Extract content from JSON (unescape newlines for searching)
            local content
            content=$(echo "$section_json" | grep -o '"content": "[^"]*"' | cut -d'"' -f4 | sed 's/\\n/\n/g')

            # Search for matches in content
            local match_lines
            match_lines=$(echo "$content" | grep -in "$query")

            if [[ -n "$match_lines" ]]; then
                # Found matches - extract context
                while IFS= read -r match_line; do
                    local line_num
                    line_num=$(echo "$match_line" | cut -d: -f1)

                    local context
                    context=$(echo "$match_line" | cut -d: -f2-)
                    context=$(escape_json "$context")

                    local section_escaped
                    section_escaped=$(escape_json "$section")

                    matches+=("{\"section\": \"$section_escaped\", \"line\": $line_num, \"context\": \"$context\"}")
                    ((total_matches++))
                done <<< "$match_lines"
            fi
        fi
    done

    # Build JSON output
    local matches_json=""
    if [[ ${#matches[@]} -gt 0 ]]; then
        matches_json=$(IFS=,; echo "${matches[*]}")
    fi

    local query_escaped
    query_escaped=$(escape_json "$query")

    cat <<EOF
{
  "query": "$query_escaped",
  "matches": [$matches_json],
  "total_matches": $total_matches
}
EOF
}

# ============================================================================
# LIST COMMAND
# ============================================================================

cmd_list() {
    local lessons_file
    lessons_file=$(find_lessons)

    # Get all section titles (one per line)
    local sections_array=()
    while IFS= read -r section; do
        if [[ -n "$section" ]]; then
            sections_array+=("$section")
        fi
    done < <(parse_section_titles "$lessons_file")

    # Count sections
    local section_count=${#sections_array[@]}

    # Get total file lines
    local file_lines
    file_lines=$(get_file_line_count "$lessons_file")

    # Build JSON array (join with commas)
    local sections_json=""
    if [[ ${#sections_array[@]} -gt 0 ]]; then
        sections_json=$(IFS=,; echo "${sections_array[*]}")
    fi

    cat <<EOF
{
  "sections": [$sections_json],
  "total_sections": $section_count,
  "file_lines": $file_lines
}
EOF
}

# ============================================================================
# GET COMMAND
# ============================================================================

cmd_get() {
    local lessons_file
    lessons_file=$(find_lessons)

    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME get \"Section Name\""
    fi

    local section_name="$1"

    parse_section_content "$lessons_file" "$section_name"
}

# ============================================================================
# SEARCH COMMAND
# ============================================================================

cmd_search() {
    local lessons_file
    lessons_file=$(find_lessons)

    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME search \"keyword\""
    fi

    local query="$1"

    search_lessons "$lessons_file" "$query"
}

# ============================================================================
# HELP TEXT
# ============================================================================

show_help() {
    cat <<EOF
$SCRIPT_NAME - Lessons Learned Query Wrapper

USAGE:
    $SCRIPT_NAME <command> [options]

COMMANDS:
    list                       List all section titles as JSON
    get "Section Name"         Get specific section content as JSON
    search "keyword"           Search across all lessons for keyword
    --help                     Show this help message
    --version                  Show version information

EXAMPLES:
    # List all section titles
    $SCRIPT_NAME list

    # Get specific section
    $SCRIPT_NAME get "Common Mistakes"

    # Search for keyword
    $SCRIPT_NAME search "roadmap"

OUTPUT FORMAT:
    list:
    {
      "sections": ["Common Mistakes", "Anti-Patterns", ...],
      "total_sections": 8,
      "file_lines": 752
    }

    get:
    {
      "section": "Common Mistakes",
      "content": "...",
      "line_start": 19,
      "line_end": 90,
      "line_count": 71,
      "file_total_lines": 752
    }

    search:
    {
      "query": "roadmap",
      "matches": [
        {"section": "Common Mistakes", "line": 45, "context": "...roadmap updates..."},
        {"section": "Architecture Decisions", "line": 120, "context": "..."}
      ],
      "total_matches": 2
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
        list)
            cmd_list "$@"
            ;;
        get)
            cmd_get "$@"
            ;;
        search)
            cmd_search "$@"
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
