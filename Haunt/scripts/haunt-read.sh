#!/usr/bin/env bash
#
# haunt-read.sh - Smart File Reader Wrapper
#
# Provides structured JSON output for common file reading patterns, eliminating
# the need to read entire files when only specific portions are needed.
#
# Usage:
#   haunt-read check <file>                     # File existence + metadata
#   haunt-read head <file> [--lines=N]          # First N lines (default 50)
#   haunt-read tail <file> [--lines=N]          # Last N lines (default 50)
#   haunt-read section <file> "Heading"         # Extract markdown section
#   haunt-read grep <file> <pattern> [--context=N]  # Grep with context
#   haunt-read --help                           # Show usage
#
# Exit Codes:
#   0 - Success
#   1 - Error (invalid usage, file not found, pattern not found)
#

set -u
set -o pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="haunt-read"
readonly VERSION="1.0.0"

# Default values
readonly DEFAULT_LINES=50
readonly DEFAULT_CONTEXT=3

# ============================================================================
# ERROR HANDLING
# ============================================================================

error() {
    echo "{\"error\": \"$1\"}" >&2
    exit "${2:-1}"
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
# FILE VALIDATION
# ============================================================================

validate_file() {
    local file="$1"

    if [[ ! -e "$file" ]]; then
        error "File not found: $file" 1
    fi

    if [[ ! -f "$file" ]]; then
        error "Not a regular file: $file" 1
    fi

    if [[ ! -r "$file" ]]; then
        error "File not readable: $file" 1
    fi
}

# ============================================================================
# CHECK COMMAND
# ============================================================================

cmd_check() {
    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME check <file>"
    fi

    local file="$1"

    # Check if file exists
    local exists="false"
    local total_lines=0
    local size_bytes=0
    local modified=""

    if [[ -e "$file" ]]; then
        exists="true"

        if [[ -f "$file" ]]; then
            total_lines=$(wc -l < "$file" | tr -d ' ')
            size_bytes=$(wc -c < "$file" | tr -d ' ')

            # Get last modified time (macOS compatible)
            if command -v stat &>/dev/null; then
                if [[ "$(uname)" == "Darwin" ]]; then
                    # macOS
                    modified=$(stat -f "%Sm" -t "%Y-%m-%dT%H:%M:%S" "$file")
                else
                    # Linux
                    modified=$(stat -c "%y" "$file" | cut -d. -f1 | tr ' ' 'T')
                fi
            fi
        fi
    fi

    # Output JSON
    cat <<EOF
{
  "file": "$(escape_json "$file")",
  "exists": $exists,
  "total_lines": $total_lines,
  "size_bytes": $size_bytes,
  "modified": "$(escape_json "$modified")"
}
EOF
}

# ============================================================================
# HEAD COMMAND
# ============================================================================

cmd_head() {
    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME head <file> [--lines=N]"
    fi

    local file="$1"
    shift

    validate_file "$file"

    local lines=$DEFAULT_LINES

    # Parse --lines flag
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lines=*)
                lines="${1#*=}"
                shift
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    # Validate lines is a positive integer
    if ! [[ "$lines" =~ ^[0-9]+$ ]] || [[ "$lines" -eq 0 ]]; then
        error "Invalid lines value: $lines (must be positive integer)"
    fi

    # Get total lines
    local total_lines
    total_lines=$(wc -l < "$file" | tr -d ' ')

    # Extract head content
    local content
    content=$(head -n "$lines" "$file")

    # Calculate actual line range
    local line_end=$lines
    if [[ $line_end -gt $total_lines ]]; then
        line_end=$total_lines
    fi

    # Escape content
    content=$(escape_json "$content")

    # Output JSON
    cat <<EOF
{
  "file": "$(escape_json "$file")",
  "mode": "head",
  "lines_requested": $lines,
  "content": "$content",
  "line_start": 1,
  "line_end": $line_end,
  "total_lines": $total_lines
}
EOF
}

# ============================================================================
# TAIL COMMAND
# ============================================================================

cmd_tail() {
    if [[ $# -eq 0 ]]; then
        error "Usage: $SCRIPT_NAME tail <file> [--lines=N]"
    fi

    local file="$1"
    shift

    validate_file "$file"

    local lines=$DEFAULT_LINES

    # Parse --lines flag
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lines=*)
                lines="${1#*=}"
                shift
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    # Validate lines is a positive integer
    if ! [[ "$lines" =~ ^[0-9]+$ ]] || [[ "$lines" -eq 0 ]]; then
        error "Invalid lines value: $lines (must be positive integer)"
    fi

    # Get total lines
    local total_lines
    total_lines=$(wc -l < "$file" | tr -d ' ')

    # Extract tail content
    local content
    content=$(tail -n "$lines" "$file")

    # Calculate line range
    local line_start=$((total_lines - lines + 1))
    if [[ $line_start -lt 1 ]]; then
        line_start=1
    fi

    # Escape content
    content=$(escape_json "$content")

    # Output JSON
    cat <<EOF
{
  "file": "$(escape_json "$file")",
  "mode": "tail",
  "lines_requested": $lines,
  "content": "$content",
  "line_start": $line_start,
  "line_end": $total_lines,
  "total_lines": $total_lines
}
EOF
}

# ============================================================================
# SECTION COMMAND
# ============================================================================

cmd_section() {
    if [[ $# -lt 2 ]]; then
        error "Usage: $SCRIPT_NAME section <file> \"Heading\""
    fi

    local file="$1"
    local heading="$2"

    validate_file "$file"

    # Get total lines
    local total_lines
    total_lines=$(wc -l < "$file" | tr -d ' ')

    # Find section start (matches ## Heading, ### Heading, etc.)
    # Use -E for extended regex where + is a quantifier
    local start_line
    start_line=$(grep -n -E "^##+ ${heading}\$" "$file" | head -1 | cut -d: -f1)

    if [[ -z "$start_line" ]]; then
        # Try case-insensitive partial match
        start_line=$(grep -n -i -E "^##+ .*${heading}.*\$" "$file" | head -1 | cut -d: -f1)
    fi

    if [[ -z "$start_line" ]]; then
        error "Section not found: $heading" 1
    fi

    # Get heading level (count #)
    local heading_line
    heading_line=$(sed -n "${start_line}p" "$file")
    local heading_level
    heading_level=$(echo "$heading_line" | grep -o -E "^#+" | wc -c | tr -d ' ')
    heading_level=$((heading_level - 1))  # Subtract 1 because wc -c counts the newline

    # Find next heading at same or higher level (fewer #)
    local end_line=$total_lines
    local next_heading_pattern="^#{1,${heading_level}} "
    local next_heading
    next_heading=$(tail -n +$((start_line + 1)) "$file" | grep -n -E "$next_heading_pattern" | head -1 | cut -d: -f1)

    if [[ -n "$next_heading" ]]; then
        end_line=$((start_line + next_heading - 1))
    fi

    # Extract section content
    local content
    content=$(sed -n "${start_line},${end_line}p" "$file")

    # Calculate line count
    local line_count=$((end_line - start_line + 1))

    # Escape content
    content=$(escape_json "$content")

    # Output JSON
    cat <<EOF
{
  "file": "$(escape_json "$file")",
  "section": "$(escape_json "$heading")",
  "content": "$content",
  "line_start": $start_line,
  "line_end": $end_line,
  "line_count": $line_count,
  "total_lines": $total_lines
}
EOF
}

# ============================================================================
# GREP COMMAND
# ============================================================================

cmd_grep() {
    if [[ $# -lt 2 ]]; then
        error "Usage: $SCRIPT_NAME grep <file> <pattern> [--context=N]"
    fi

    local file="$1"
    local pattern="$2"
    shift 2

    validate_file "$file"

    local context=$DEFAULT_CONTEXT

    # Parse --context flag
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --context=*)
                context="${1#*=}"
                shift
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    # Validate context is a non-negative integer
    if ! [[ "$context" =~ ^[0-9]+$ ]]; then
        error "Invalid context value: $context (must be non-negative integer)"
    fi

    # Get total lines
    local total_lines
    total_lines=$(wc -l < "$file" | tr -d ' ')

    # Run grep with context
    local grep_output
    if ! grep_output=$(grep -n -C "$context" "$pattern" "$file" 2>&1); then
        # No matches found
        cat <<EOF
{
  "file": "$(escape_json "$file")",
  "pattern": "$(escape_json "$pattern")",
  "matches": [],
  "total_matches": 0,
  "total_lines": $total_lines
}
EOF
        return 0
    fi

    # Parse grep output into JSON matches array
    local matches=()
    local current_match=""
    local match_line=""
    local match_content=""
    local context_before=()
    local context_after=()
    local in_after_context=false
    local after_count=0

    while IFS= read -r line; do
        if [[ "$line" == "--" ]]; then
            # Separator between match groups
            if [[ -n "$current_match" ]]; then
                # Build JSON for this match
                local context_before_json=""
                if [[ ${#context_before[@]} -gt 0 ]]; then
                    local escaped_lines=()
                    for ctx in "${context_before[@]}"; do
                        escaped_lines+=("\"$(escape_json "$ctx")\"")
                    done
                    context_before_json=$(IFS=,; echo "${escaped_lines[*]}")
                fi

                local context_after_json=""
                if [[ ${#context_after[@]} -gt 0 ]]; then
                    local escaped_lines=()
                    for ctx in "${context_after[@]}"; do
                        escaped_lines+=("\"$(escape_json "$ctx")\"")
                    done
                    context_after_json=$(IFS=,; echo "${escaped_lines[*]}")
                fi

                local match_json
                match_json=$(cat <<MATCH_EOF
{"line": $match_line, "content": "$(escape_json "$match_content")", "context_before": [$context_before_json], "context_after": [$context_after_json]}
MATCH_EOF
)
                matches+=("$match_json")
            fi

            # Reset for next match group
            current_match=""
            match_line=""
            match_content=""
            context_before=()
            context_after=()
            in_after_context=false
            after_count=0
            continue
        fi

        # Parse line number and content
        local line_num
        line_num=$(echo "$line" | cut -d: -f1 | cut -d- -f1)
        local line_content
        line_content=$(echo "$line" | cut -d: -f2-)

        if [[ "$line" =~ ^[0-9]+: ]]; then
            # This is a match line
            if [[ -n "$current_match" ]]; then
                # Save previous match first
                local context_before_json=""
                if [[ ${#context_before[@]} -gt 0 ]]; then
                    local escaped_lines=()
                    for ctx in "${context_before[@]}"; do
                        escaped_lines+=("\"$(escape_json "$ctx")\"")
                    done
                    context_before_json=$(IFS=,; echo "${escaped_lines[*]}")
                fi

                local context_after_json=""
                if [[ ${#context_after[@]} -gt 0 ]]; then
                    local escaped_lines=()
                    for ctx in "${context_after[@]}"; do
                        escaped_lines+=("\"$(escape_json "$ctx")\"")
                    done
                    context_after_json=$(IFS=,; echo "${escaped_lines[*]}")
                fi

                local match_json
                match_json=$(cat <<MATCH_EOF
{"line": $match_line, "content": "$(escape_json "$match_content")", "context_before": [$context_before_json], "context_after": [$context_after_json]}
MATCH_EOF
)
                matches+=("$match_json")
            fi

            # Start new match
            current_match="$line"
            match_line="$line_num"
            match_content="$line_content"
            context_before=()
            context_after=()
            in_after_context=true
            after_count=0
        elif [[ "$line" =~ ^[0-9]+- ]]; then
            # Context line
            if [[ -z "$current_match" ]] || [[ "$in_after_context" == false ]]; then
                # Before context
                context_before+=("$line_content")
            else
                # After context
                if [[ $after_count -lt $context ]]; then
                    context_after+=("$line_content")
                    after_count=$((after_count + 1))
                fi
            fi
        fi
    done <<< "$grep_output"

    # Add final match if exists
    if [[ -n "$current_match" ]]; then
        local context_before_json=""
        if [[ ${#context_before[@]} -gt 0 ]]; then
            local escaped_lines=()
            for ctx in "${context_before[@]}"; do
                escaped_lines+=("\"$(escape_json "$ctx")\"")
            done
            context_before_json=$(IFS=,; echo "${escaped_lines[*]}")
        fi

        local context_after_json=""
        if [[ ${#context_after[@]} -gt 0 ]]; then
            local escaped_lines=()
            for ctx in "${context_after[@]}"; do
                escaped_lines+=("\"$(escape_json "$ctx")\"")
            done
            context_after_json=$(IFS=,; echo "${escaped_lines[*]}")
        fi

        local match_json
        match_json=$(cat <<MATCH_EOF
{"line": $match_line, "content": "$(escape_json "$match_content")", "context_before": [$context_before_json], "context_after": [$context_after_json]}
MATCH_EOF
)
        matches+=("$match_json")
    fi

    # Build final JSON
    local matches_json=""
    if [[ ${#matches[@]} -gt 0 ]]; then
        matches_json=$(IFS=,; echo "${matches[*]}")
    fi

    # Output JSON
    cat <<EOF
{
  "file": "$(escape_json "$file")",
  "pattern": "$(escape_json "$pattern")",
  "matches": [$matches_json],
  "total_matches": ${#matches[@]},
  "total_lines": $total_lines
}
EOF
}

# ============================================================================
# HELP TEXT
# ============================================================================

show_help() {
    cat <<EOF
$SCRIPT_NAME - Smart File Reader Wrapper

USAGE:
    $SCRIPT_NAME <command> [options]

COMMANDS:
    check <file>                      File existence + metadata
    head <file> [--lines=N]           First N lines (default $DEFAULT_LINES)
    tail <file> [--lines=N]           Last N lines (default $DEFAULT_LINES)
    section <file> "Heading"          Extract markdown section by heading
    grep <file> <pattern> [--context=N]  Grep with context (default $DEFAULT_CONTEXT)

OPTIONS:
    --help                            Show this help message
    --version                         Show version information

EXAMPLES:
    # Check file metadata
    $SCRIPT_NAME check /path/to/file.md

    # Get first 100 lines
    $SCRIPT_NAME head /path/to/file.md --lines=100

    # Get last 20 lines
    $SCRIPT_NAME tail /path/to/file.log --lines=20

    # Extract markdown section
    $SCRIPT_NAME section README.md "Installation"

    # Search with 5 lines of context
    $SCRIPT_NAME grep config.json "database" --context=5

OUTPUT FORMAT:
    All commands return valid JSON with structure appropriate to the mode.

    check:
    {
      "file": "/path/to/file",
      "exists": true,
      "total_lines": 752,
      "size_bytes": 24680,
      "modified": "2025-12-30T10:15:00"
    }

    head/tail:
    {
      "file": "/path/to/file",
      "mode": "head",
      "lines_requested": 50,
      "content": "...",
      "line_start": 1,
      "line_end": 50,
      "total_lines": 752
    }

    section:
    {
      "file": "/path/to/file",
      "section": "Heading",
      "content": "...",
      "line_start": 19,
      "line_end": 90,
      "line_count": 71,
      "total_lines": 752
    }

    grep:
    {
      "file": "/path/to/file",
      "pattern": "search-term",
      "matches": [
        {
          "line": 45,
          "content": "...search-term...",
          "context_before": ["..."],
          "context_after": ["..."]
        }
      ],
      "total_matches": 3,
      "total_lines": 752
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
        head)
            cmd_head "$@"
            ;;
        tail)
            cmd_tail "$@"
            ;;
        section)
            cmd_section "$@"
            ;;
        grep)
            cmd_grep "$@"
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
