#!/usr/bin/env bash
#
# haunt-story.sh - Structured Story File Lookup Wrapper
#
# Returns structured JSON output for story file queries, eliminating the need
# to read entire story file when checking existence or extracting sections.
#
# Usage:
#   haunt-story check REQ-XXX              # Check if story exists, return metadata
#   haunt-story get REQ-XXX                # Get full story as JSON
#   haunt-story section REQ-XXX "Heading"  # Get specific section
#   haunt-story list                       # List all story files
#   haunt-story --help                     # Show usage
#
# Exit Codes:
#   0 - Success
#   1 - Error (invalid usage or story not found)
#   2 - Stories directory not found

set -u
set -o pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="haunt-story"
readonly VERSION="1.0.0"

# Story files location (relative to project root)
readonly DEFAULT_STORIES_DIR=".haunt/plans/stories"

# ============================================================================
# ERROR HANDLING
# ============================================================================

error() {
    echo "{\"error\": \"$1\"}" >&2
    exit "${2:-1}"
}

# Find stories directory (search up directory tree)
find_stories_dir() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/$DEFAULT_STORIES_DIR" ]]; then
            echo "$dir/$DEFAULT_STORIES_DIR"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    # Directory doesn't exist yet - that's OK for check/list commands
    return 1
}

# Get story file path for REQ-XXX
get_story_path() {
    local req_id="$1"
    local stories_dir="$2"
    echo "$stories_dir/${req_id}-story.md"
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

# Extract markdown sections (## Heading format)
extract_sections() {
    local file="$1"
    local sections=()

    # Find all ## headings (second level)
    while IFS= read -r line; do
        if [[ "$line" =~ ^##[[:space:]](.+)$ ]]; then
            local heading="${BASH_REMATCH[1]}"
            heading=$(escape_json "$heading")
            sections+=("\"$heading\"")
        fi
    done < "$file"

    local sections_json=""
    if [[ ${#sections[@]} -gt 0 ]]; then
        sections_json=$(IFS=,; echo "${sections[*]}")
    fi

    echo "$sections_json"
}

# Extract specific section content
# Returns line numbers and content via stdout (metadata first, then content)
extract_section_content() {
    local file="$1"
    local target_heading="$2"

    # Find section start line (## Heading format)
    local start_line
    start_line=$(grep -n "^## ${target_heading}\$" "$file" | cut -d: -f1 | head -1)

    if [[ -z "$start_line" ]]; then
        return 1
    fi

    # Find next section or end of file
    local end_line
    end_line=$(tail -n +$((start_line + 1)) "$file" | grep -n "^##" | head -1 | cut -d: -f1)

    if [[ -n "$end_line" ]]; then
        end_line=$((start_line + end_line - 1))
    else
        # End of file
        end_line=$(wc -l < "$file" | tr -d ' ')
    fi

    # Extract section content (skip heading line)
    local content
    content=$(sed -n "$((start_line + 1)),${end_line}p" "$file")

    local line_count=$((end_line - start_line))

    # Output metadata on first line, content on subsequent lines
    echo "$start_line $end_line $line_count"
    echo "$content"
}

# ============================================================================
# CHECK COMMAND
# ============================================================================

cmd_check() {
    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME check REQ-XXX"
    fi

    local req_id="$1"

    # Validate REQ-XXX format
    if [[ ! "$req_id" =~ ^REQ-[0-9]+$ ]]; then
        error "Invalid requirement ID format: $req_id (expected REQ-XXX)"
    fi

    # Find stories directory
    local stories_dir
    if stories_dir=$(find_stories_dir); then
        local story_path
        story_path=$(get_story_path "$req_id" "$stories_dir")

        if [[ -f "$story_path" ]]; then
            # Story exists - get metadata
            local total_lines
            total_lines=$(wc -l < "$story_path" | tr -d ' ')

            local sections_json
            sections_json=$(extract_sections "$story_path")

            # Output JSON
            cat <<EOF
{
  "requirement": "$req_id",
  "exists": true,
  "path": "$story_path",
  "sections": [$sections_json],
  "total_lines": $total_lines
}
EOF
        else
            # Story doesn't exist
            cat <<EOF
{
  "requirement": "$req_id",
  "exists": false,
  "path": "$story_path",
  "sections": [],
  "total_lines": 0
}
EOF
        fi
    else
        # Stories directory doesn't exist
        cat <<EOF
{
  "requirement": "$req_id",
  "exists": false,
  "path": null,
  "sections": [],
  "total_lines": 0
}
EOF
    fi
}

# ============================================================================
# GET COMMAND
# ============================================================================

cmd_get() {
    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME get REQ-XXX"
    fi

    local req_id="$1"

    # Validate REQ-XXX format
    if [[ ! "$req_id" =~ ^REQ-[0-9]+$ ]]; then
        error "Invalid requirement ID format: $req_id (expected REQ-XXX)"
    fi

    # Find stories directory
    local stories_dir
    if ! stories_dir=$(find_stories_dir); then
        error "Stories directory not found: $DEFAULT_STORIES_DIR" 2
    fi

    local story_path
    story_path=$(get_story_path "$req_id" "$stories_dir")

    if [[ ! -f "$story_path" ]]; then
        error "Story file not found: $story_path"
    fi

    # Read full content
    local content
    content=$(cat "$story_path")
    content=$(escape_json "$content")

    local total_lines
    total_lines=$(wc -l < "$story_path" | tr -d ' ')

    local sections_json
    sections_json=$(extract_sections "$story_path")

    # Output JSON
    cat <<EOF
{
  "requirement": "$req_id",
  "path": "$story_path",
  "content": "$content",
  "sections": [$sections_json],
  "total_lines": $total_lines
}
EOF
}

# ============================================================================
# SECTION COMMAND
# ============================================================================

cmd_section() {
    if [[ $# -lt 2 ]]; then
        error "Usage: $SCRIPT_NAME section REQ-XXX \"Heading\""
    fi

    local req_id="$1"
    local heading="$2"

    # Validate REQ-XXX format
    if [[ ! "$req_id" =~ ^REQ-[0-9]+$ ]]; then
        error "Invalid requirement ID format: $req_id (expected REQ-XXX)"
    fi

    # Find stories directory
    local stories_dir
    if ! stories_dir=$(find_stories_dir); then
        error "Stories directory not found: $DEFAULT_STORIES_DIR" 2
    fi

    local story_path
    story_path=$(get_story_path "$req_id" "$stories_dir")

    if [[ ! -f "$story_path" ]]; then
        error "Story file not found: $story_path"
    fi

    # Extract section (returns metadata + content)
    local section_output
    if ! section_output=$(extract_section_content "$story_path" "$heading"); then
        error "Section not found: $heading (in $story_path)"
    fi

    # Parse metadata (first line) and content (rest)
    local metadata
    metadata=$(echo "$section_output" | head -1)
    local line_start line_end line_count
    read -r line_start line_end line_count <<< "$metadata"

    # Get content (all lines after first)
    local content
    content=$(echo "$section_output" | tail -n +2)
    content=$(escape_json "$content")

    # Output JSON
    cat <<EOF
{
  "requirement": "$req_id",
  "section": "$heading",
  "content": "$content",
  "line_start": $line_start,
  "line_end": $line_end,
  "line_count": $line_count
}
EOF
}

# ============================================================================
# LIST COMMAND
# ============================================================================

cmd_list() {
    # Find stories directory
    local stories_dir
    if ! stories_dir=$(find_stories_dir); then
        # No stories directory - return empty list
        cat <<EOF
{
  "stories": [],
  "total_stories": 0
}
EOF
        return 0
    fi

    # Find all story files
    local story_files=()
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            story_files+=("$file")
        fi
    done < <(find "$stories_dir" -maxdepth 1 -name "REQ-*-story.md" 2>/dev/null | sort)

    # Parse each story file
    local results=()
    for story_path in "${story_files[@]}"; do
        local filename
        filename=$(basename "$story_path")

        # Extract REQ-XXX from filename
        local req_id
        req_id=$(echo "$filename" | grep -o "REQ-[0-9]\+" | head -1)

        local total_lines
        total_lines=$(wc -l < "$story_path" | tr -d ' ')

        local story_json
        story_json=$(cat <<STORY_EOF
{"requirement": "$req_id", "path": "$story_path", "lines": $total_lines}
STORY_EOF
)
        results+=("$story_json")
    done

    # Output JSON array
    local results_json=""
    if [[ ${#results[@]} -gt 0 ]]; then
        results_json=$(IFS=,; echo "${results[*]}")
    fi

    cat <<EOF
{
  "stories": [$results_json],
  "total_stories": ${#results[@]}
}
EOF
}

# ============================================================================
# HELP TEXT
# ============================================================================

show_help() {
    cat <<EOF
$SCRIPT_NAME - Structured Story File Lookup Wrapper

USAGE:
    $SCRIPT_NAME <command> [options]

COMMANDS:
    check REQ-XXX              Check if story exists, return metadata
    get REQ-XXX                Get full story content as JSON
    section REQ-XXX "Heading"  Get specific section content
    list                       List all story files

OPTIONS:
    --help                     Show this help message
    --version                  Show version information

EXAMPLES:
    # Check if story exists
    $SCRIPT_NAME check REQ-223

    # Get full story content
    $SCRIPT_NAME get REQ-223

    # Get specific section
    $SCRIPT_NAME section REQ-223 "Implementation Approach"

    # List all story files
    $SCRIPT_NAME list

OUTPUT FORMAT:
    Check command:
    {
      "requirement": "REQ-223",
      "exists": true,
      "path": ".haunt/plans/stories/REQ-223-story.md",
      "sections": ["Context & Background", "Implementation Approach", ...],
      "total_lines": 312
    }

    Get command:
    {
      "requirement": "REQ-223",
      "path": ".haunt/plans/stories/REQ-223-story.md",
      "content": "...",
      "sections": ["Context & Background", "Implementation Approach", ...],
      "total_lines": 312
    }

    Section command:
    {
      "requirement": "REQ-223",
      "section": "Implementation Approach",
      "content": "...",
      "line_start": 45,
      "line_end": 120,
      "line_count": 75
    }

    List command:
    {
      "stories": [
        {"requirement": "REQ-223", "path": "...", "lines": 312},
        {"requirement": "REQ-224", "path": "...", "lines": 156}
      ],
      "total_stories": 2
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
        check)
            cmd_check "$@"
            ;;
        get)
            cmd_get "$@"
            ;;
        section)
            cmd_section "$@"
            ;;
        list)
            cmd_list "$@"
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
