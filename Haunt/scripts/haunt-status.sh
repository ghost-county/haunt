#!/usr/bin/env bash
#
# haunt-status.sh - Display batch-organized status of roadmap
#
# Usage:
#   bash Haunt/scripts/haunt-status.sh [--batch]
#   bash Haunt/scripts/haunt-status.sh --help
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default paths
ROADMAP_FILE="${ROADMAP_FILE:-.haunt/plans/roadmap.md}"

# Status icons
ICON_PENDING="⚪"
ICON_IN_PROGRESS="🟡"
ICON_COMPLETE="🟢"
ICON_BLOCKED="🔴"

# Function to display help
show_help() {
    cat <<EOF
haunt-status - Display batch-organized status of roadmap

USAGE:
    bash Haunt/scripts/haunt-status.sh [OPTIONS]

OPTIONS:
    --batch         Show batch-organized view (default)
    --json          Output as JSON
    --help          Show this help message

EXAMPLES:
    # Show batch status
    bash Haunt/scripts/haunt-status.sh

    # Get JSON output
    bash Haunt/scripts/haunt-status.sh --json

EOF
}

# Function to extract requirement ID from line
extract_req_id() {
    local line="$1"
    echo "$line" | grep -oE 'REQ-[0-9]+' | head -1 || echo ""
}

# Function to extract status icon from line
extract_status() {
    local line="$1"
    if [[ "$line" =~ $ICON_PENDING ]]; then
        echo "pending"
    elif [[ "$line" =~ $ICON_IN_PROGRESS ]]; then
        echo "in_progress"
    elif [[ "$line" =~ $ICON_COMPLETE ]]; then
        echo "complete"
    elif [[ "$line" =~ $ICON_BLOCKED ]]; then
        echo "blocked"
    else
        echo "unknown"
    fi
}

# Function to extract requirement title
extract_title() {
    local line="$1"
    # Extract text after "REQ-XXX: " up to " (Agent:"
    echo "$line" | sed -E 's/.*REQ-[0-9]+: ([^(]+).*/\1/' | sed 's/^ *//;s/ *$//'
}

# Function to check if line is blocked
is_blocked() {
    local content="$1"
    if echo "$content" | grep -q "Blocked by:.*REQ-"; then
        return 0
    else
        return 1
    fi
}

# Function to extract blocking requirement IDs
extract_blockers() {
    local content="$1"
    echo "$content" | grep "Blocked by:" | grep -oE 'REQ-[0-9]+' | tr '\n' ', ' | sed 's/,$//'
}

# Function to parse batch section
parse_batch() {
    local batch_name="$1"
    local start_line=$2
    local end_line=$3

    local pending_count=0
    local in_progress_count=0
    local complete_count=0
    local blocked_count=0
    local total_count=0

    declare -a requirements

    # Read entire batch section once
    local batch_content=$(sed -n "${start_line},${end_line}p" "$ROADMAP_FILE")

    # Process requirements
    local current_req_id=""
    local current_status=""
    local current_title=""
    local current_content=""

    while IFS= read -r line; do
        # Check if this is a requirement header
        if [[ "$line" =~ ^###[[:space:]]+[$ICON_PENDING$ICON_IN_PROGRESS$ICON_COMPLETE$ICON_BLOCKED] ]]; then
            # Save previous requirement if exists
            if [[ -n "$current_req_id" ]]; then
                local blockers=""
                if is_blocked "$current_content"; then
                    blockers=$(extract_blockers "$current_content")
                    ((blocked_count++))
                fi
                requirements+=("$current_req_id|$current_status|$current_title|$blockers")
            fi

            # Start new requirement
            current_req_id=$(extract_req_id "$line")
            current_status=$(extract_status "$line")
            current_title=$(extract_title "$line")
            current_content=""

            if [[ -n "$current_req_id" ]]; then
                ((total_count++))
                case "$current_status" in
                    pending) ((pending_count++)) ;;
                    in_progress) ((in_progress_count++)) ;;
                    complete) ((complete_count++)) ;;
                esac
            fi
        else
            # Accumulate content for current requirement
            current_content+="$line"$'\n'
        fi
    done <<< "$batch_content"

    # Save last requirement
    if [[ -n "$current_req_id" ]]; then
        local blockers=""
        if is_blocked "$current_content"; then
            blockers=$(extract_blockers "$current_content")
            ((blocked_count++))
        fi
        requirements+=("$current_req_id|$current_status|$current_title|$blockers")
    fi

    # Output batch summary
    echo -e "${CYAN}## Batch: ${batch_name}${NC}"

    # Display requirements
    for req_entry in "${requirements[@]}"; do
        IFS='|' read -r req_id status title blockers <<< "$req_entry"

        # Choose color and icon based on status
        local color=""
        local icon=""
        case "$status" in
            pending) color="$NC"; icon="$ICON_PENDING" ;;
            in_progress) color="$YELLOW"; icon="$ICON_IN_PROGRESS" ;;
            complete) color="$GREEN"; icon="$ICON_COMPLETE" ;;
            blocked) color="$RED"; icon="$ICON_BLOCKED" ;;
        esac

        if [[ -n "$blockers" ]]; then
            echo -e "  ${color}${icon} ${req_id}: ${title} (blocked by ${blockers})${NC}"
        else
            echo -e "  ${color}${icon} ${req_id}: ${title}${NC}"
        fi
    done

    # Display status summary
    echo -e "  ${BLUE}Status: ${complete_count}/${total_count} complete"
    if [[ $blocked_count -gt 0 ]]; then
        echo -e "  ${RED}⚠️  ${blocked_count} blocked${NC}"
    fi
    echo ""
}

# Function to parse batch section (JSON output)
parse_batch_json() {
    local batch_name="$1"
    local start_line=$2
    local end_line=$3

    local pending_count=0
    local in_progress_count=0
    local complete_count=0
    local blocked_count=0
    local total_count=0

    local requirements_json="["
    local first_req=true

    # Read entire batch section once
    local batch_content=$(sed -n "${start_line},${end_line}p" "$ROADMAP_FILE")

    # Process requirements
    local current_req_id=""
    local current_status=""
    local current_title=""
    local current_content=""

    while IFS= read -r line; do
        # Check if this is a requirement header
        if [[ "$line" =~ ^###[[:space:]]+[$ICON_PENDING$ICON_IN_PROGRESS$ICON_COMPLETE$ICON_BLOCKED] ]]; then
            # Save previous requirement if exists
            if [[ -n "$current_req_id" ]]; then
                local blockers=""
                if is_blocked "$current_content"; then
                    blockers=$(extract_blockers "$current_content")
                    ((blocked_count++))
                fi

                # Add to JSON
                if [[ "$first_req" == true ]]; then
                    first_req=false
                else
                    requirements_json+=","
                fi

                requirements_json+=$(cat <<EOF
{
  "id": "$current_req_id",
  "title": "$current_title",
  "status": "$current_status",
  "blockers": "$blockers"
}
EOF
)
            fi

            # Start new requirement
            current_req_id=$(extract_req_id "$line")
            current_status=$(extract_status "$line")
            current_title=$(extract_title "$line")
            current_content=""

            if [[ -n "$current_req_id" ]]; then
                ((total_count++))
                case "$current_status" in
                    pending) ((pending_count++)) ;;
                    in_progress) ((in_progress_count++)) ;;
                    complete) ((complete_count++)) ;;
                esac
            fi
        else
            # Accumulate content for current requirement
            current_content+="$line"$'\n'
        fi
    done <<< "$batch_content"

    # Save last requirement
    if [[ -n "$current_req_id" ]]; then
        local blockers=""
        if is_blocked "$current_content"; then
            blockers=$(extract_blockers "$current_content")
            ((blocked_count++))
        fi

        # Add to JSON
        if [[ "$first_req" == true ]]; then
            first_req=false
        else
            requirements_json+=","
        fi

        requirements_json+=$(cat <<EOF
{
  "id": "$current_req_id",
  "title": "$current_title",
  "status": "$current_status",
  "blockers": "$blockers"
}
EOF
)
    fi

    requirements_json+="]"

    # Output JSON
    cat <<EOF
{
  "batch": "$batch_name",
  "requirements": $requirements_json,
  "summary": {
    "total": $total_count,
    "pending": $pending_count,
    "in_progress": $in_progress_count,
    "complete": $complete_count,
    "blocked": $blocked_count
  }
}
EOF
}

# Main function
main() {
    local output_format="batch"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --batch)
                output_format="batch"
                shift
                ;;
            --json)
                output_format="json"
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
        esac
    done

    # Check if roadmap exists
    if [[ ! -f "$ROADMAP_FILE" ]]; then
        echo "Error: Roadmap file not found: $ROADMAP_FILE" >&2
        exit 1
    fi

    # Find all batch sections
    declare -a batches
    declare -a batch_starts
    declare -a batch_ends

    local line_num=0
    local current_batch=""
    local batch_start=0

    while IFS= read -r line; do
        ((line_num++))

        # Detect batch header
        if [[ "$line" =~ ^##[[:space:]]+(Batch:|Priority:)[[:space:]]+(.+)$ ]]; then
            # Save previous batch if exists
            if [[ -n "$current_batch" ]]; then
                batches+=("$current_batch")
                batch_starts+=("$batch_start")
                batch_ends+=("$((line_num - 1))")
            fi

            # Start new batch
            current_batch="${BASH_REMATCH[2]}"
            batch_start=$line_num
        fi
    done < "$ROADMAP_FILE"

    # Save last batch
    if [[ -n "$current_batch" ]]; then
        batches+=("$current_batch")
        batch_starts+=("$batch_start")
        batch_ends+=("$(wc -l < "$ROADMAP_FILE")")
    fi

    # Output based on format
    if [[ "$output_format" == "json" ]]; then
        echo "["
        local first_batch=true
        for i in "${!batches[@]}"; do
            if [[ "$first_batch" == true ]]; then
                first_batch=false
            else
                echo ","
            fi
            parse_batch_json "${batches[$i]}" "${batch_starts[$i]}" "${batch_ends[$i]}"
        done
        echo "]"
    else
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        echo -e "${BLUE}    Haunt Framework Batch Status${NC}"
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        echo ""

        for i in "${!batches[@]}"; do
            parse_batch "${batches[$i]}" "${batch_starts[$i]}" "${batch_ends[$i]}"
        done
    fi
}

main "$@"
