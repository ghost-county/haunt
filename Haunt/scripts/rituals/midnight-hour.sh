#!/bin/bash
# scripts/rituals/midnight-hour.sh
# The Midnight Hour - Deep weekly reflection and strategic planning ritual
# When the veil between code and consciousness grows thin...

set -o pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Default flags
DRY_RUN=false
SAVE_REPORT=true
INTERACTIVE=true
DAYS_BACK=7

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            cat << 'EOF'
The Midnight Hour - Deep Weekly Reflection Ritual

Usage: ./midnight-hour.sh [OPTIONS]

When the clock strikes twelve, the spirits gather for deep reflection.
This ritual provides strategic insights through pattern analysis, memory
consolidation, and planning for the journey ahead.

Options:
  --help, -h          Show this help message
  --dry-run           Preview analysis without saving report
  --no-save           Skip saving the reflection report
  --non-interactive   Run without pausing for contemplation
  --days <N>          Analyze last N days (default: 7)

The Midnight Hour Ritual:
  1. Opening the Veil - Review week's commit patterns
  2. Reading the Bones - Analyze roadmap progress
  3. Summoning Memories - Consolidate agent learnings
  4. Divining the Path - Strategic planning for next phase
  5. Sealing the Circle - Save insights to memory

Examples:
  ./midnight-hour.sh                    # Full midnight ritual
  ./midnight-hour.sh --days 14          # Two-week deep dive
  ./midnight-hour.sh --dry-run          # Preview without saving
  ./midnight-hour.sh --non-interactive  # Quick automated run

EOF
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            SAVE_REPORT=false
            shift
            ;;
        --no-save)
            SAVE_REPORT=false
            shift
            ;;
        --non-interactive)
            INTERACTIVE=false
            shift
            ;;
        --days)
            DAYS_BACK="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Helper functions
print_header() {
    echo ""
    echo -e "${BOLD}${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${MAGENTA}║  $1${NC}"
    echo -e "${BOLD}${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}${CYAN}═══ $1 ═══${NC}"
    echo ""
}

print_info() {
    echo -e "${BLUE}•${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_diviner() {
    echo -e "${MAGENTA}${BOLD}🔮${NC} ${DIM}$1${NC}"
}

pause_for_contemplation() {
    if [ "$INTERACTIVE" = true ]; then
        echo ""
        echo -e "${DIM}Press Enter to continue the ritual...${NC}"
        read -r
    fi
}

# Initialize report
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
WEEK_NUM=$(date +%U)
REPORT_FILE=".haunt/progress/midnight-hour-week-${WEEK_NUM}-$(date +%Y-%m-%d).md"
REPORT=""

add_to_report() {
    echo -e "$1"
    REPORT+="$1\n"
}

# Ensure progress directory exists
mkdir -p .haunt/progress

# ============================================
# OPENING: The Witching Hour Begins
# ============================================

print_header "  THE MIDNIGHT HOUR  "
add_to_report "# The Midnight Hour Reflection"
add_to_report ""
add_to_report "_The clock strikes twelve. The veil grows thin._"
add_to_report ""
add_to_report "**Date:** ${TIMESTAMP}"
add_to_report "**Week:** ${WEEK_NUM} of $(date +%Y)"
add_to_report "**Analysis Period:** Last ${DAYS_BACK} days"
add_to_report ""
add_to_report "---"
add_to_report ""

echo -e "${DIM}The spirits gather at midnight for deep reflection..."
echo -e "Analyzing the last ${DAYS_BACK} days of your journey...${NC}"
echo ""

pause_for_contemplation

# ============================================
# PHASE 1: Opening the Veil - Commit Patterns
# ============================================

print_section "Phase 1: Opening the Veil - Commit Patterns"
add_to_report "## Opening the Veil - Commit Patterns"
add_to_report ""

print_info "Examining the traces left by spirits past..."

# Count commits
COMMIT_COUNT=$(git log --since="${DAYS_BACK} days ago" --oneline 2>/dev/null | wc -l | tr -d ' ')

if [[ "$COMMIT_COUNT" -gt 0 ]]; then
    print_success "${COMMIT_COUNT} commits in the last ${DAYS_BACK} days"
    add_to_report "**Total Commits:** ${COMMIT_COUNT}"
    add_to_report ""

    # Analyze commit types from [REQ-XXX] Action: pattern
    echo ""
    print_info "Commit patterns by action type:"
    add_to_report "### Commit Patterns by Action"
    add_to_report ""
    add_to_report "| Action | Count | Percentage |"
    add_to_report "|--------|-------|------------|"

    git log --since="${DAYS_BACK} days ago" --pretty=format:"%s" 2>/dev/null | \
    grep -o '\[REQ-[0-9]*\] *[A-Za-z]*' | sed 's/\[REQ-[0-9]*\] *//' | sort | uniq -c | sort -rn | while read count action; do
        if [[ -n "$action" && "$COMMIT_COUNT" -gt 0 ]]; then
            percentage=$(echo "scale=1; $count * 100 / $COMMIT_COUNT" | bc)
            echo -e "  ${CYAN}$action${NC}: $count (${percentage}%)"
            add_to_report "| $action | $count | ${percentage}% |"
        fi
    done
    add_to_report ""

    # Most active REQs
    echo ""
    print_info "Most actively worked requirements:"
    add_to_report "### Most Active Requirements"
    add_to_report ""

    git log --since="${DAYS_BACK} days ago" --pretty=format:"%s" 2>/dev/null | \
    grep -o '\[REQ-[0-9-]*\]' | sort | uniq -c | sort -rn | head -5 | while read count req; do
        echo -e "  ${YELLOW}$req${NC}: $count commits"
        add_to_report "- **$req**: $count commits"
    done
    add_to_report ""

    # Files most changed
    echo ""
    print_info "Files most touched by spirits:"
    add_to_report "### Most Modified Files"
    add_to_report ""

    git log --since="${DAYS_BACK} days ago" --name-only --pretty=format: 2>/dev/null | \
    grep -v '^$' | sort | uniq -c | sort -rn | head -10 | while read count file; do
        echo -e "  ${BLUE}$file${NC}: $count changes"
        add_to_report "- \`$file\`: $count changes"
    done
    add_to_report ""
else
    print_warning "No commits found in the last ${DAYS_BACK} days"
    add_to_report "_The spirits have been quiet. No commits found._"
    add_to_report ""
fi

pause_for_contemplation

# ============================================
# PHASE 2: Reading the Bones - Roadmap Analysis
# ============================================

print_section "Phase 2: Reading the Bones - Roadmap Analysis"
add_to_report "## Reading the Bones - Roadmap Progress"
add_to_report ""

ROADMAP=".haunt/plans/roadmap.md"

if [[ -f "$ROADMAP" ]]; then
    print_info "Consulting the sacred roadmap..."

    # Count status by emoji
    NOT_STARTED=$(grep "^### ⚪" "$ROADMAP" 2>/dev/null | wc -l | tr -d ' ')
    IN_PROGRESS=$(grep "^### 🟡" "$ROADMAP" 2>/dev/null | wc -l | tr -d ' ')
    COMPLETE=$(grep "^### 🟢" "$ROADMAP" 2>/dev/null | wc -l | tr -d ' ')
    BLOCKED=$(grep "^### 🔴" "$ROADMAP" 2>/dev/null | wc -l | tr -d ' ')

    # Ensure numeric values (default to 0 if empty)
    NOT_STARTED=${NOT_STARTED:-0}
    IN_PROGRESS=${IN_PROGRESS:-0}
    COMPLETE=${COMPLETE:-0}
    BLOCKED=${BLOCKED:-0}

    TOTAL=$((NOT_STARTED + IN_PROGRESS + COMPLETE + BLOCKED))

    if [[ $TOTAL -gt 0 ]]; then
        echo ""
        print_success "Roadmap contains ${TOTAL} requirements"
        add_to_report "**Total Requirements:** ${TOTAL}"
        add_to_report ""
        add_to_report "| Status | Count | Percentage |"
        add_to_report "|--------|-------|------------|"

        if [[ $NOT_STARTED -gt 0 ]]; then
            pct=$(echo "scale=1; $NOT_STARTED * 100 / $TOTAL" | bc)
            echo -e "  ⚪ Not Started: ${NOT_STARTED} (${pct}%)"
            add_to_report "| ⚪ Not Started | $NOT_STARTED | ${pct}% |"
        fi

        if [[ $IN_PROGRESS -gt 0 ]]; then
            pct=$(echo "scale=1; $IN_PROGRESS * 100 / $TOTAL" | bc)
            echo -e "  🟡 In Progress: ${IN_PROGRESS} (${pct}%)"
            add_to_report "| 🟡 In Progress | $IN_PROGRESS | ${pct}% |"
        fi

        if [[ $COMPLETE -gt 0 ]]; then
            pct=$(echo "scale=1; $COMPLETE * 100 / $TOTAL" | bc)
            echo -e "  🟢 Complete: ${COMPLETE} (${pct}%)"
            add_to_report "| 🟢 Complete | $COMPLETE | ${pct}% |"
        fi

        if [[ $BLOCKED -gt 0 ]]; then
            pct=$(echo "scale=1; $BLOCKED * 100 / $TOTAL" | bc)
            echo -e "  🔴 Blocked: ${BLOCKED} (${pct}%)"
            add_to_report "| 🔴 Blocked | $BLOCKED | ${pct}% |"
        fi
        add_to_report ""

        # Calculate velocity (completed / days)
        if [[ $COMPLETE -gt 0 ]]; then
            velocity=$(echo "scale=2; $COMPLETE / $DAYS_BACK" | bc)
            print_diviner "Development velocity: ${velocity} requirements per day"
            add_to_report "**Development Velocity:** ${velocity} req/day"
            add_to_report ""
        fi

        # Check for completed items ready to archive
        if [[ $COMPLETE -gt 0 ]]; then
            echo ""
            print_warning "${COMPLETE} completed items ready for archival"
            add_to_report "### Items Ready for Archival"
            add_to_report ""
            grep "^### 🟢" "$ROADMAP" | sed 's/^### 🟢 /- /' >> /tmp/midnight_complete.txt
            cat /tmp/midnight_complete.txt
            add_to_report "$(cat /tmp/midnight_complete.txt)"
            add_to_report ""
            rm /tmp/midnight_complete.txt
        fi
    else
        print_warning "Roadmap exists but contains no requirements"
        add_to_report "_The roadmap lies empty, awaiting new quests._"
        add_to_report ""
    fi
else
    print_error "Roadmap not found at $ROADMAP"
    add_to_report "_The roadmap has vanished into the mist._"
    add_to_report ""
fi

pause_for_contemplation

# ============================================
# PHASE 3: Summoning Memories - Agent Learning
# ============================================

print_section "Phase 3: Summoning Memories - Agent Learnings"
add_to_report "## Summoning Memories - Agent Learnings"
add_to_report ""

print_info "Calling upon the collective memory of spirits..."

# Check for pattern test files created
if [[ -d ".haunt/tests/patterns" ]]; then
    PATTERN_COUNT=$(find .haunt/tests/patterns -name "test_*.py" 2>/dev/null | wc -l | tr -d ' ')

    if [[ $PATTERN_COUNT -gt 0 ]]; then
        print_success "Found ${PATTERN_COUNT} pattern defeat tests"
        add_to_report "**Pattern Defeat Tests:** ${PATTERN_COUNT}"
        add_to_report ""
        add_to_report "Patterns the agents have learned to defeat:"
        add_to_report ""

        find .haunt/tests/patterns -name "test_*.py" 2>/dev/null | while read -r file; do
            pattern_name=$(basename "$file" | sed 's/test_//' | sed 's/.py$//' | sed 's/_/ /g')
            echo -e "  ${GREEN}✓${NC} $pattern_name"
            add_to_report "- $pattern_name"
        done
        add_to_report ""
    else
        print_warning "No pattern tests found yet"
        add_to_report "_No patterns have been captured in tests yet._"
        add_to_report ""
    fi
else
    print_info "Pattern test directory not yet created"
    add_to_report "_The pattern detection chamber awaits construction._"
    add_to_report ""
fi

# Check for completed work archives
if [[ -f ".haunt/completed/roadmap-archive.md" ]]; then
    ARCHIVE_SIZE=$(wc -l < ".haunt/completed/roadmap-archive.md" 2>/dev/null || echo 0)
    print_success "Archive contains ${ARCHIVE_SIZE} lines of completed work"
    add_to_report "**Archived Work:** ${ARCHIVE_SIZE} lines in roadmap-archive.md"
    add_to_report ""
else
    print_info "No archive file yet - all work is still active"
    add_to_report "_No work has been archived to the eternal halls._"
    add_to_report ""
fi

pause_for_contemplation

# ============================================
# PHASE 4: Divining the Path - Strategic Insights
# ============================================

print_section "Phase 4: Divining the Path - Strategic Planning"
add_to_report "## Divining the Path - Strategic Insights"
add_to_report ""

print_diviner "Consulting the crystal ball for the path ahead..."
echo ""

# Analyze what's blocking progress
if [[ -f "$ROADMAP" ]] && grep -q "^### 🔴" "$ROADMAP" 2>/dev/null; then
    echo -e "${YELLOW}Blockages detected in the flow:${NC}"
    add_to_report "### Current Blockages"
    add_to_report ""
    grep -A 2 "^### 🔴" "$ROADMAP" | grep "^**Blocked by:**" | while read -r line; do
        blocker=$(echo "$line" | sed 's/^**Blocked by:** //')
        echo -e "  ${RED}•${NC} $blocker"
        add_to_report "- $blocker"
    done
    add_to_report ""
    echo ""
fi

# Suggest focus areas based on current state
if [[ -f "$ROADMAP" ]]; then
    echo -e "${MAGENTA}Strategic recommendations:${NC}"
    add_to_report "### Strategic Recommendations"
    add_to_report ""

    # If lots complete, suggest archiving
    if [[ $COMPLETE -ge 5 ]]; then
        print_diviner "Archive completed work to maintain roadmap clarity"
        add_to_report "- **Archive Ritual**: ${COMPLETE} items ready for archival - run \`/banish --all-complete\`"
    fi

    # If lots in progress, suggest focusing
    if [[ $IN_PROGRESS -ge 5 ]]; then
        print_diviner "Many spirits at work - consider focusing efforts"
        add_to_report "- **Focus Required**: ${IN_PROGRESS} items in progress - prioritize completion over new starts"
    fi

    # If lots not started, suggest planning
    if [[ $NOT_STARTED -ge 10 ]]; then
        print_diviner "Large backlog detected - prioritization ritual needed"
        add_to_report "- **Prioritization**: ${NOT_STARTED} items waiting - review and prioritize in next planning session"
    fi

    # If high velocity, celebrate
    if [[ $COMPLETE -gt 0 && $DAYS_BACK -gt 0 ]]; then
        velocity=$(echo "scale=2; $COMPLETE / $DAYS_BACK" | bc)
        if [[ -n "$velocity" ]] && (( $(echo "$velocity > 0.5" | bc -l) )); then
            print_diviner "Strong momentum detected - maintain the rhythm"
            add_to_report "- **Momentum**: Velocity of ${velocity} req/day is strong - maintain current pace"
        fi
    fi
    add_to_report ""
fi

# Suggest next week's focus
echo ""
print_diviner "Recommended focus for the week ahead:"
add_to_report "### Next Week's Focus"
add_to_report ""

if [[ -f "$ROADMAP" ]]; then
    # Find highest priority incomplete items
    grep "^### 🟡\|^### ⚪" "$ROADMAP" | head -3 | while read -r line; do
        req=$(echo "$line" | sed 's/^### [⚪🟡] //')
        echo -e "  ${CYAN}→${NC} $req"
        add_to_report "- $req"
    done
    add_to_report ""
else
    echo -e "  ${DIM}Define goals in roadmap${NC}"
    add_to_report "- Define goals in roadmap"
    add_to_report ""
fi

pause_for_contemplation

# ============================================
# CLOSING: Sealing the Circle
# ============================================

print_section "Phase 5: Sealing the Circle"
add_to_report "## Sealing the Circle"
add_to_report ""

if [ "$SAVE_REPORT" = true ]; then
    if [ "$DRY_RUN" = false ]; then
        # Write report to file (remove ANSI codes for clean markdown)
        echo -e "$REPORT" | sed 's/\x1b\[[0-9;]*m//g' > "$REPORT_FILE"
        print_success "Reflection sealed in ${REPORT_FILE}"
        add_to_report "_This reflection has been sealed in the archives._"
        add_to_report ""
        add_to_report "**May the spirits guide your code.**"
    else
        print_info "[DRY RUN] Would save report to ${REPORT_FILE}"
    fi
else
    print_info "Report not saved (--no-save or --dry-run mode)"
fi

echo ""
print_header "  The Midnight Hour Concludes  "
echo -e "${DIM}The veil closes. The spirits return to their rest."
echo -e "Until the next midnight hour...${NC}"
echo ""

exit 0
