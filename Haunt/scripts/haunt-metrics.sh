#!/bin/bash
#
# haunt-metrics.sh - Extract metrics from existing artifacts (git, roadmap, archives)
#
# This script derives measurements WITHOUT requiring agents to log anything extra.
# Metrics are extracted post-hoc from:
# - Git commit history (REQ-XXX patterns)
# - Roadmap status changes (⚪→🟡→🟢)
# - Archived completions
#
# Usage:
#   haunt-metrics [--format=json|text] [--req=REQ-XXX] [--since=YYYY-MM-DD]
#
# Examples:
#   haunt-metrics                    # All metrics, text format
#   haunt-metrics --format=json      # JSON output for tooling
#   haunt-metrics --req=REQ-123      # Specific requirement only
#   haunt-metrics --since=2025-12-01 # Metrics since date

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROADMAP="$PROJECT_ROOT/.haunt/plans/roadmap.md"
ARCHIVE="$PROJECT_ROOT/.haunt/completed/roadmap-archive.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default options
FORMAT="text"
SPECIFIC_REQ=""
SINCE_DATE=""
SHOW_CONTEXT=false

# Helper functions
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✅${NC} $1"
}

error() {
    echo -e "${RED}❌${NC} $1"
}

warning() {
    # Suppress warnings in JSON format
    if [ "$FORMAT" != "json" ]; then
        echo -e "${YELLOW}⚠${NC} $1"
    fi
}

section() {
    echo -e "\n${CYAN}═══${NC} $1 ${CYAN}═══${NC}"
}

# Parse command-line arguments
parse_args() {
    for arg in "$@"; do
        case $arg in
            --format=*)
                FORMAT="${arg#*=}"
                ;;
            --req=*)
                SPECIFIC_REQ="${arg#*=}"
                ;;
            --since=*)
                SINCE_DATE="${arg#*=}"
                ;;
            --context)
                SHOW_CONTEXT=true
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown argument: $arg"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << 'EOF'
haunt-metrics - Extract metrics from existing artifacts

Usage:
  haunt-metrics [OPTIONS]

Options:
  --format=json|text    Output format (default: text)
  --req=REQ-XXX         Filter to specific requirement
  --since=YYYY-MM-DD    Only include data since date
  --context             Include context overhead metrics
  --help, -h            Show this help message

Metrics Extracted:
  1. Cycle Time         - Time from first commit to 🟢 completion
  2. Effort Accuracy    - Estimated vs actual time (XS<1hr, S<2hr, M<4hr)
  3. First-Pass Success - Commits without "fix", "revert", "oops"
  4. Completion Rate    - Requirements completed vs abandoned
  5. Context Overhead   - Token/context consumption (with --context flag)

Examples:
  haunt-metrics                    # All metrics, text format
  haunt-metrics --format=json      # JSON output
  haunt-metrics --req=REQ-123      # Specific requirement only
  haunt-metrics --since=2025-12-01 # Since specific date
  haunt-metrics --context          # Include context overhead metrics

Data Sources:
  - Git commit history (REQ-XXX patterns)
  - Roadmap status changes (⚪→🟡→🟢)
  - Archived completions
  - Agent character sheets, rules, CLAUDE.md (for context overhead)
EOF
}

# Validate environment
validate_environment() {
    if [ ! -d "$PROJECT_ROOT/.git" ]; then
        error "Not a git repository: $PROJECT_ROOT"
        exit 1
    fi

    if [ ! -f "$ROADMAP" ]; then
        warning "Roadmap not found: $ROADMAP"
    fi
}

# Extract all REQ-XXX patterns from git history
extract_git_requirements() {
    local since_flag=""
    if [ -n "$SINCE_DATE" ]; then
        since_flag="--since=$SINCE_DATE"
    fi

    # Extract REQ-XXX from commit messages
    git -C "$PROJECT_ROOT" log --all --oneline $since_flag --grep="REQ-" | \
        grep -oE 'REQ-[0-9]{3}' | sort -u
}

# Get first and last commit timestamp for a requirement
get_req_commit_timestamps() {
    local req="$1"
    local since_flag=""
    if [ -n "$SINCE_DATE" ]; then
        since_flag="--since=$SINCE_DATE"
    fi

    # First commit timestamp
    local first_commit=$(git -C "$PROJECT_ROOT" log --all --reverse $since_flag --grep="$req" --format="%at" | head -1)

    # Last commit timestamp
    local last_commit=$(git -C "$PROJECT_ROOT" log --all $since_flag --grep="$req" --format="%at" | head -1)

    echo "$first_commit|$last_commit"
}

# Get requirement metadata from roadmap or archive
get_req_metadata() {
    local req="$1"

    # Search in active roadmap first (increased to 40 lines to capture all metadata)
    if [ -f "$ROADMAP" ]; then
        local metadata=$(grep -A 40 "### {.*} $req:" "$ROADMAP" 2>/dev/null)
        if [ -n "$metadata" ]; then
            echo "$metadata"
            return 0
        fi
    fi

    # Search in main archive if not in active roadmap (increased to 40 lines)
    # Archive format: ### 🟢 REQ-XXX: Title
    if [ -f "$ARCHIVE" ]; then
        local metadata=$(grep -A 40 "### .* $req:" "$ARCHIVE" 2>/dev/null)
        if [ -n "$metadata" ]; then
            echo "$metadata"
            return 0
        fi
    fi

    # Search in bulk archive files (different format: list items, not headers)
    # Bulk archive format: - 🟢 REQ-XXX: Title (date)
    if [ -d "$PROJECT_ROOT/.haunt/completed" ]; then
        for archive_file in "$PROJECT_ROOT/.haunt/completed"/*.md; do
            if [ -f "$archive_file" ]; then
                # Check if requirement is mentioned in bulk archive (list format)
                # Use -- to prevent emoji being interpreted as option
                if grep -q -- "$req:" "$archive_file" 2>/dev/null; then
                    # Found in bulk archive - create minimal metadata for completed status
                    echo "### 🟢 $req: (Archived in bulk)"
                    echo "**Effort:** UNKNOWN"
                    return 0
                fi
            fi
        done
    fi

    return 1
}

# Extract effort estimate from metadata
get_effort_estimate() {
    local metadata="$1"
    # Match **Effort:** field and capture ONLY the first size value
    # Use sed to extract the value after **Effort:** and before any other text
    local result=$(echo "$metadata" | grep "\*\*Effort:\*\*" | sed -n 's/.*\*\*Effort:\*\* *\([A-Z]*\).*/\1/p' | head -1)
    if [ -z "$result" ]; then
        echo "UNKNOWN"
    else
        echo "$result"
    fi
}

# Extract status from metadata (⚪, 🟡, 🟢, 🔴)
get_status() {
    local metadata="$1"

    # Try to extract from header line (### {🟢} REQ-XXX)
    # Use a more portable approach - look for the emoji directly
    local header=$(echo "$metadata" | head -1)

    if echo "$header" | grep -q "🟢"; then
        echo "🟢"
        return 0
    elif echo "$header" | grep -q "🟡"; then
        echo "🟡"
        return 0
    elif echo "$header" | grep -q "🔴"; then
        echo "🔴"
        return 0
    elif echo "$header" | grep -q "⚪"; then
        echo "⚪"
        return 0
    fi

    # Fallback: check for status in metadata
    if echo "$metadata" | grep -q "Status.*Complete"; then
        echo "🟢"
    elif echo "$metadata" | grep -q "Status.*In Progress"; then
        echo "🟡"
    elif echo "$metadata" | grep -q "Status.*Blocked"; then
        echo "🔴"
    else
        echo "⚪"
    fi
}

# Calculate cycle time (first commit to 🟢 status)
calculate_cycle_time() {
    local first_commit="$1"
    local last_commit="$2"

    if [ -z "$first_commit" ] || [ -z "$last_commit" ]; then
        echo "N/A"
        return
    fi

    local diff=$((last_commit - first_commit))

    # Convert to hours
    local hours=$((diff / 3600))

    echo "${hours}h"
}

# Check for first-pass success (no "fix", "revert", "oops" commits)
check_first_pass_success() {
    local req="$1"
    local since_flag=""
    if [ -n "$SINCE_DATE" ]; then
        since_flag="--since=$SINCE_DATE"
    fi

    # Get all commits for this requirement
    local commits=$(git -C "$PROJECT_ROOT" log --all $since_flag --grep="$req" --oneline)

    # Check for problem keywords
    if echo "$commits" | grep -iE 'fix|revert|oops|undo|wrong|mistake' > /dev/null; then
        echo "No"
    else
        echo "Yes"
    fi
}

# Map effort estimate to expected hours
get_expected_hours() {
    local effort="$1"

    case "$effort" in
        XS) echo "1" ;;
        S)  echo "2" ;;
        M)  echo "4" ;;
        *)  echo "N/A" ;;
    esac
}

# Calculate metrics for a single requirement
calculate_req_metrics() {
    local req="$1"

    # Get git timestamps
    local timestamps=$(get_req_commit_timestamps "$req")
    local first_commit=$(echo "$timestamps" | cut -d'|' -f1)
    local last_commit=$(echo "$timestamps" | cut -d'|' -f2)

    # Get metadata from roadmap/archive
    local metadata=$(get_req_metadata "$req")

    if [ -z "$metadata" ]; then
        warning "No metadata found for $req (orphaned commits?)"
        return
    fi

    # Extract fields
    local effort=$(get_effort_estimate "$metadata")
    local status=$(get_status "$metadata")
    local cycle_time=$(calculate_cycle_time "$first_commit" "$last_commit")
    local first_pass=$(check_first_pass_success "$req")
    local expected_hours=$(get_expected_hours "$effort")

    # Output based on format
    if [ "$FORMAT" = "json" ]; then
        cat << JSON
{
  "requirement": "$req",
  "status": "$status",
  "effort_estimate": "$effort",
  "expected_hours": "$expected_hours",
  "cycle_time": "$cycle_time",
  "first_pass_success": "$first_pass",
  "first_commit_ts": ${first_commit:-null},
  "last_commit_ts": ${last_commit:-null}
}
JSON
    else
        # Text format
        echo ""
        echo "  Requirement:      $req"
        echo "  Status:           $status"
        echo "  Effort Estimate:  $effort (${expected_hours}h expected)"
        echo "  Cycle Time:       $cycle_time"
        echo "  First-Pass:       $first_pass"
    fi
}

# Count lines in file (excluding blank and comment lines)
count_effective_lines() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi
    # Count lines, excluding blank lines and lines starting with # (after trimming whitespace)
    grep -v '^\s*$' "$file" | grep -v '^\s*#' | wc -l | tr -d ' '
}

# Measure context overhead (agent + rules + CLAUDE.md + skills)
measure_context_overhead() {
    local agent_lines=0
    local rules_lines=0
    local claude_md_lines=0
    local skill_lines=0

    # Count agent character sheet lines (use largest as representative)
    local max_agent=0
    if [ -d "$PROJECT_ROOT/Haunt/agents" ]; then
        for agent_file in "$PROJECT_ROOT/Haunt/agents"/*.md; do
            if [ -f "$agent_file" ]; then
                local lines=$(count_effective_lines "$agent_file")
                if [ "$lines" -gt "$max_agent" ]; then
                    max_agent=$lines
                fi
            fi
        done
    fi
    agent_lines=$max_agent

    # Count rules lines (sum of all rules)
    if [ -d "$PROJECT_ROOT/Haunt/rules" ]; then
        for rule_file in "$PROJECT_ROOT/Haunt/rules"/*.md; do
            if [ -f "$rule_file" ]; then
                local lines=$(count_effective_lines "$rule_file")
                rules_lines=$((rules_lines + lines))
            fi
        done
    fi

    # Count CLAUDE.md lines
    if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
        claude_md_lines=$(count_effective_lines "$PROJECT_ROOT/CLAUDE.md")
    fi

    # Estimate skill overhead (top 5 most-used skills)
    # For initial implementation, use average of all skills
    local total_skill_lines=0
    local skill_count=0
    if [ -d "$PROJECT_ROOT/Haunt/skills" ]; then
        for skill_dir in "$PROJECT_ROOT/Haunt/skills"/*/; do
            if [ -d "$skill_dir" ]; then
                local skill_file="$skill_dir/SKILL.md"
                if [ -f "$skill_file" ]; then
                    local lines=$(count_effective_lines "$skill_file")
                    total_skill_lines=$((total_skill_lines + lines))
                    ((skill_count++))
                fi
            fi
        done
    fi

    # Estimate: assume 3 skills loaded on average per session
    local avg_skills_loaded=3
    local avg_skill_size=0
    if [ $skill_count -gt 0 ]; then
        avg_skill_size=$((total_skill_lines / skill_count))
    fi
    skill_lines=$((avg_skills_loaded * avg_skill_size))

    # Calculate totals
    local base_overhead=$((agent_lines + rules_lines + claude_md_lines))
    local total_overhead=$((base_overhead + skill_lines))

    if [ "$FORMAT" = "json" ]; then
        cat << JSON
"context_overhead": {
  "agent_lines": $agent_lines,
  "rules_lines": $rules_lines,
  "claude_md_lines": $claude_md_lines,
  "estimated_skill_lines": $skill_lines,
  "base_overhead_lines": $base_overhead,
  "total_overhead_lines": $total_overhead,
  "avg_skills_loaded_estimate": $avg_skills_loaded,
  "avg_skill_size_lines": $avg_skill_size,
  "total_skills_available": $skill_count
}
JSON
    else
        section "Context Overhead"
        echo ""
        echo "  Base Context:"
        echo "    Agent Character Sheet:  ${agent_lines} lines"
        echo "    Rules (all):            ${rules_lines} lines"
        echo "    CLAUDE.md:              ${claude_md_lines} lines"
        echo "    Subtotal:               ${base_overhead} lines"
        echo ""
        echo "  Estimated Skill Overhead:"
        echo "    Avg Skills Loaded:      ${avg_skills_loaded} skills/session"
        echo "    Avg Skill Size:         ${avg_skill_size} lines"
        echo "    Subtotal:               ${skill_lines} lines"
        echo ""
        echo "  Total Context Overhead:   ${total_overhead} lines"
        echo ""
        echo "  Skills Available:         ${skill_count} skills"
    fi
}

# Calculate aggregate metrics
calculate_aggregate_metrics() {
    local reqs=("$@")
    local total_reqs=${#reqs[@]}
    local completed=0
    local first_pass_successes=0
    local total_cycle_time=0
    local cycle_time_samples=0

    for req in "${reqs[@]}"; do
        local metadata=$(get_req_metadata "$req")
        if [ -z "$metadata" ]; then
            continue
        fi

        local status=$(get_status "$metadata")
        if [ "$status" = "🟢" ]; then
            ((completed++))
        fi

        local first_pass=$(check_first_pass_success "$req")
        if [ "$first_pass" = "Yes" ]; then
            ((first_pass_successes++))
        fi

        # Calculate cycle time
        local timestamps=$(get_req_commit_timestamps "$req")
        local first_commit=$(echo "$timestamps" | cut -d'|' -f1)
        local last_commit=$(echo "$timestamps" | cut -d'|' -f2)

        if [ -n "$first_commit" ] && [ -n "$last_commit" ]; then
            local diff=$((last_commit - first_commit))
            local hours=$((diff / 3600))
            total_cycle_time=$((total_cycle_time + hours))
            ((cycle_time_samples++))
        fi
    done

    # Calculate percentages
    local completion_rate=0
    local first_pass_rate=0
    local avg_cycle_time=0

    if [ $total_reqs -gt 0 ]; then
        completion_rate=$(awk "BEGIN {printf \"%.1f\", ($completed / $total_reqs) * 100}")
        first_pass_rate=$(awk "BEGIN {printf \"%.1f\", ($first_pass_successes / $total_reqs) * 100}")
    fi

    if [ $cycle_time_samples -gt 0 ]; then
        avg_cycle_time=$(awk "BEGIN {printf \"%.1f\", $total_cycle_time / $cycle_time_samples}")
    fi

    if [ "$FORMAT" = "json" ]; then
        cat << JSON
"aggregate_metrics": {
  "total_requirements": $total_reqs,
  "completed_requirements": $completed,
  "completion_rate": $completion_rate,
  "first_pass_successes": $first_pass_successes,
  "first_pass_rate": $first_pass_rate,
  "average_cycle_time_hours": $avg_cycle_time
}
JSON
    else
        section "Aggregate Metrics"
        echo ""
        echo "  Total Requirements:    $total_reqs"
        echo "  Completed:             $completed (${completion_rate}%)"
        echo "  First-Pass Success:    $first_pass_successes (${first_pass_rate}%)"
        echo "  Avg Cycle Time:        ${avg_cycle_time}h"
    fi
}

# Main execution
main() {
    parse_args "$@"
    validate_environment

    if [ "$FORMAT" = "text" ]; then
        echo ""
        echo "═══════════════════════════════════════════"
        echo "  Haunt Metrics - Post-Hoc Analysis"
        echo "═══════════════════════════════════════════"
    fi

    # Get requirements from git or filter to specific
    if [ -n "$SPECIFIC_REQ" ]; then
        REQUIREMENTS=("$SPECIFIC_REQ")
    else
        # Portable alternative to mapfile (works in older Bash versions)
        REQUIREMENTS=()
        while IFS= read -r line; do
            REQUIREMENTS+=("$line")
        done < <(extract_git_requirements)
    fi

    if [ ${#REQUIREMENTS[@]} -eq 0 ]; then
        warning "No requirements found in git history"
        exit 0
    fi

    if [ "$FORMAT" = "json" ]; then
        echo "{"
        echo "  \"metrics\": ["
    else
        section "Individual Requirements"
    fi

    # Calculate metrics for each requirement
    local first=true
    for req in "${REQUIREMENTS[@]}"; do
        if [ "$FORMAT" = "json" ]; then
            if [ "$first" = false ]; then
                echo ","
            fi
            first=false
            calculate_req_metrics "$req" | sed 's/^/    /'
        else
            calculate_req_metrics "$req"
        fi
    done

    if [ "$FORMAT" = "json" ]; then
        echo ""
        echo "  ],"
        calculate_aggregate_metrics "${REQUIREMENTS[@]}" | sed 's/^/  /'

        # Add context overhead if requested
        if [ "$SHOW_CONTEXT" = true ]; then
            echo ","
            measure_context_overhead | sed 's/^/  /'
        fi

        echo "}"
    else
        echo ""
        calculate_aggregate_metrics "${REQUIREMENTS[@]}"

        # Add context overhead if requested
        if [ "$SHOW_CONTEXT" = true ]; then
            echo ""
            measure_context_overhead
        fi

        echo ""
    fi
}

main "$@"
