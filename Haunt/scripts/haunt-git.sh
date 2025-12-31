#!/usr/bin/env bash
#
# haunt-git.sh - Structured Git Operations Wrapper
#
# Returns structured JSON output for common git operations, eliminating
# parsing variance from text-based git output.
#
# Usage:
#   haunt-git status                  # Get repository status as JSON
#   haunt-git diff-stat [<ref>..<ref>]  # Get diff statistics as JSON
#   haunt-git log [--count=N]         # Get commit history as JSON
#   haunt-git <command> --raw         # Pass through to regular git
#
# Exit Codes:
#   0 - Success
#   1 - Error (git command failed or invalid usage)
#   2 - Not in a git repository

set -e
set -u
set -o pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="haunt-git"
readonly VERSION="1.0.0"

# ============================================================================
# ERROR HANDLING
# ============================================================================

error() {
    echo "{\"error\": \"$1\"}" >&2
    exit "${2:-1}"
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        error "Not in a git repository" 2
    fi
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
# GIT STATUS COMMAND
# ============================================================================

cmd_status() {
    check_git_repo

    # Get current branch (handles detached HEAD)
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "HEAD")
    if [[ "$branch" == "HEAD" ]]; then
        # Detached HEAD - get commit hash
        branch="detached:$(git rev-parse --short HEAD)"
    fi

    # Get tracking branch info
    local ahead=0
    local behind=0
    local tracking_branch
    tracking_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")

    if [[ -n "$tracking_branch" ]]; then
        # Get ahead/behind counts
        local ahead_behind
        ahead_behind=$(git rev-list --left-right --count "$tracking_branch"...HEAD 2>/dev/null || echo "0	0")
        behind=$(echo "$ahead_behind" | cut -f1)
        ahead=$(echo "$ahead_behind" | cut -f2)
    fi

    # Get file status using porcelain format (stable across git versions)
    local staged=()
    local modified=()
    local untracked=()
    local conflicted=()

    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            continue
        fi

        local status_code="${line:0:2}"
        local filepath="${line:3}"
        filepath=$(escape_json "$filepath")

        case "$status_code" in
            # Staged files (index has changes)
            A\ |M\ |D\ |R\ |C\ )
                staged+=("\"$filepath\"")
                ;;
            # Modified files (working tree has changes)
            \ M|\ D)
                modified+=("\"$filepath\"")
                ;;
            # Both staged and modified
            MM|AM|MD)
                staged+=("\"$filepath\"")
                modified+=("\"$filepath\"")
                ;;
            # Untracked files
            \?\?)
                untracked+=("\"$filepath\"")
                ;;
            # Merge conflicts
            UU|AA|DD|AU|UA|DU|UD)
                conflicted+=("\"$filepath\"")
                ;;
        esac
    done < <(git status --porcelain 2>/dev/null)

    # Check for merge in progress
    local merge_in_progress="false"
    if [[ -f .git/MERGE_HEAD ]]; then
        merge_in_progress="true"
    fi

    # Build JSON output
    # Handle empty arrays safely
    local staged_json=""
    local modified_json=""
    local untracked_json=""
    local conflicted_json=""

    if [[ ${#staged[@]} -gt 0 ]]; then
        staged_json=$(IFS=,; echo "${staged[*]}")
    fi
    if [[ ${#modified[@]} -gt 0 ]]; then
        modified_json=$(IFS=,; echo "${modified[*]}")
    fi
    if [[ ${#untracked[@]} -gt 0 ]]; then
        untracked_json=$(IFS=,; echo "${untracked[*]}")
    fi
    if [[ ${#conflicted[@]} -gt 0 ]]; then
        conflicted_json=$(IFS=,; echo "${conflicted[*]}")
    fi

    cat <<EOF
{
  "branch": "$(escape_json "$branch")",
  "tracking_branch": "$(escape_json "$tracking_branch")",
  "ahead": $ahead,
  "behind": $behind,
  "staged": [$staged_json],
  "modified": [$modified_json],
  "untracked": [$untracked_json],
  "conflicted": [$conflicted_json],
  "merge_in_progress": $merge_in_progress
}
EOF
}

# ============================================================================
# GIT DIFF-STAT COMMAND
# ============================================================================

cmd_diff_stat() {
    check_git_repo

    local ref_range="${1:-}"

    # Get diff statistics
    local diff_output
    if [[ -n "$ref_range" ]]; then
        diff_output=$(git diff --numstat "$ref_range" 2>/dev/null || error "Invalid ref range: $ref_range")
    else
        # Default: diff between working tree and HEAD
        diff_output=$(git diff --numstat HEAD 2>/dev/null || echo "")
    fi

    local files_changed=0
    local total_insertions=0
    local total_deletions=0
    local file_stats=()

    while IFS=$'\t' read -r insertions deletions filepath; do
        if [[ -z "$filepath" ]]; then
            continue
        fi

        # Handle binary files (git shows "-" for insertions/deletions)
        if [[ "$insertions" == "-" ]]; then
            insertions=0
        fi
        if [[ "$deletions" == "-" ]]; then
            deletions=0
        fi

        total_insertions=$((total_insertions + insertions))
        total_deletions=$((total_deletions + deletions))
        files_changed=$((files_changed + 1))

        filepath=$(escape_json "$filepath")
        file_stats+=("{\"file\": \"$filepath\", \"insertions\": $insertions, \"deletions\": $deletions}")
    done <<< "$diff_output"

    # Build JSON output
    local files_json=""
    if [[ ${#file_stats[@]} -gt 0 ]]; then
        files_json=$(IFS=,; echo "${file_stats[*]}")
    fi

    cat <<EOF
{
  "files_changed": $files_changed,
  "insertions": $total_insertions,
  "deletions": $total_deletions,
  "files": [$files_json]
}
EOF
}

# ============================================================================
# GIT LOG COMMAND
# ============================================================================

cmd_log() {
    check_git_repo

    local count=10  # Default to last 10 commits
    local ref_range=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --count=*)
                count="${1#*=}"
                shift
                ;;
            --count)
                count="$2"
                shift 2
                ;;
            *)
                # Assume it's a ref range
                ref_range="$1"
                shift
                ;;
        esac
    done

    # Build git log command
    local git_cmd="git log --format=%H%n%an%n%ae%n%at%n%s -n $count"
    if [[ -n "$ref_range" ]]; then
        git_cmd="$git_cmd $ref_range"
    fi

    local commits=()
    local commit_data=()
    local line_num=0

    while IFS= read -r line; do
        commit_data+=("$line")
        line_num=$((line_num + 1))

        # Every 5 lines is one complete commit
        if [[ $line_num -eq 5 ]]; then
            local hash="${commit_data[0]}"
            local author="${commit_data[1]}"
            local email="${commit_data[2]}"
            local timestamp="${commit_data[3]}"
            local message="${commit_data[4]}"

            # Escape JSON strings
            author=$(escape_json "$author")
            email=$(escape_json "$email")
            message=$(escape_json "$message")

            commits+=("{\"hash\": \"$hash\", \"author\": \"$author\", \"email\": \"$email\", \"timestamp\": $timestamp, \"message\": \"$message\"}")

            # Reset for next commit
            commit_data=()
            line_num=0
        fi
    done < <($git_cmd 2>/dev/null || error "Failed to retrieve git log")

    # Build JSON output
    local commits_json=""
    if [[ ${#commits[@]} -gt 0 ]]; then
        commits_json=$(IFS=,; echo "${commits[*]}")
    fi

    cat <<EOF
{
  "count": ${#commits[@]},
  "commits": [$commits_json]
}
EOF
}

# ============================================================================
# HELP TEXT
# ============================================================================

show_help() {
    cat <<EOF
$SCRIPT_NAME - Structured Git Operations Wrapper

USAGE:
    $SCRIPT_NAME <command> [options]

COMMANDS:
    status                 Get repository status as JSON
    diff-stat [<ref>..<ref>]  Get diff statistics as JSON
    log [--count=N] [<ref>]   Get commit history as JSON

OPTIONS:
    --raw                  Pass through to regular git (for any command)
    --help                 Show this help message
    --version              Show version information

EXAMPLES:
    # Get current repository status
    $SCRIPT_NAME status

    # Get diff statistics between HEAD and working tree
    $SCRIPT_NAME diff-stat

    # Get diff statistics between two refs
    $SCRIPT_NAME diff-stat main..feature-branch

    # Get last 5 commits
    $SCRIPT_NAME log --count=5

    # Get commits in a ref range
    $SCRIPT_NAME log main..HEAD

    # Pass through to regular git
    $SCRIPT_NAME status --raw

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

    # Check for --raw flag (pass through to git)
    local has_raw=false
    local clean_args=()
    for arg in "$@"; do
        if [[ "$arg" == "--raw" ]]; then
            has_raw=true
        else
            clean_args+=("$arg")
        fi
    done

    if [[ "$has_raw" == true ]]; then
        if [[ ${#clean_args[@]} -gt 0 ]]; then
            exec git "$command" "${clean_args[@]}"
        else
            exec git "$command"
        fi
    fi

    # Dispatch to command handlers
    case "$command" in
        status)
            cmd_status "$@"
            ;;
        diff-stat)
            cmd_diff_stat "$@"
            ;;
        log)
            cmd_log "$@"
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
