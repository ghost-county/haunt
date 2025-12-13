#!/bin/bash
# scripts/evening-handoff.sh
# Enhanced evening handoff script for Haunt

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

# Parse command line flags
SAVE_REPORT=false
SHOW_HELP=false
SKIP_MEMORY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --save)
            SAVE_REPORT=true
            shift
            ;;
        --skip-memory)
            SKIP_MEMORY=true
            shift
            ;;
        --help)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${RESET}"
            SHOW_HELP=true
            shift
            ;;
    esac
done

# Show help if requested
if [ "$SHOW_HELP" = true ]; then
    cat << 'EOF'
Evening Handoff Script - Haunt

Usage: ./evening-handoff.sh [OPTIONS]

Options:
  --save          Save handoff report to .haunt/progress/handoff-{date}.md
  --skip-memory   Skip memory consolidation (REM sleep)
  --help          Show this help message

Description:
  Generates an evening handoff report showing:
  - Session summary (commits, files changed, completed work)
  - Infrastructure status
  - Tomorrow's priorities from roadmap
  - Agent memory consolidation (optional)

Examples:
  ./evening-handoff.sh                  # Display report with memory consolidation
  ./evening-handoff.sh --save           # Display and save to file
  ./evening-handoff.sh --skip-memory    # Skip memory consolidation

EOF
    exit 0
fi

# Initialize report content
REPORT=""

# Helper function to add to report
add_to_report() {
    echo -e "$1"
    REPORT+="$1\n"
}

# Header
add_to_report "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
add_to_report "${BOLD}${CYAN}║           Evening Banishment - $(date +%Y-%m-%d)                    ║${RESET}"
add_to_report "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
add_to_report ""

# Session Summary Section
add_to_report "${BOLD}${BLUE}═══ Session Summary ═══${RESET}"
add_to_report ""

# Today's commits
COMMIT_COUNT=$(git log --since="8 hours ago" --oneline 2>/dev/null | wc -l | tr -d ' ')
if [ "$COMMIT_COUNT" -gt 0 ]; then
    add_to_report "${GREEN}✓ Commits today: ${COMMIT_COUNT}${RESET}"
    add_to_report ""
    git log --since="8 hours ago" --pretty=format:"  %h - %s (%an, %ar)" 2>/dev/null | while read line; do
        add_to_report "  ${line}"
    done
    add_to_report ""
else
    add_to_report "${YELLOW}○ No commits today${RESET}"
fi
add_to_report ""

# Files changed today
FILES_CHANGED=$(git diff --name-only HEAD@{8.hours.ago} 2>/dev/null | wc -l | tr -d ' ')
if [ "$FILES_CHANGED" -gt 0 ]; then
    add_to_report "${GREEN}✓ Files changed: ${FILES_CHANGED}${RESET}"
    git diff --name-only HEAD@{8.hours.ago} 2>/dev/null | head -10 | while read file; do
        add_to_report "  • ${file}"
    done
    if [ "$FILES_CHANGED" -gt 10 ]; then
        add_to_report "  ... and $((FILES_CHANGED - 10)) more"
    fi
else
    add_to_report "${YELLOW}○ No files changed${RESET}"
fi
add_to_report ""

# Completed work today
add_to_report "${BOLD}${BLUE}═══ Exorcised Today ═══${RESET}"
TODAY_DATE=$(date +%Y-%m-%d)
COMPLETED=$(grep -E "🟢.*${TODAY_DATE}" .haunt/plans/roadmap.md 2>/dev/null)
if [ -n "$COMPLETED" ]; then
    add_to_report "${GREEN}✓ Work completed:${RESET}"
    echo "$COMPLETED" | while read line; do
        add_to_report "  ${line}"
    done
else
    add_to_report "${YELLOW}○ No work items completed today${RESET}"
fi
add_to_report ""

# Current work in progress
add_to_report "${BOLD}${BLUE}═══ Active Hauntings ═══${RESET}"
IN_PROGRESS=$(grep -A3 "🟡" .haunt/plans/roadmap.md 2>/dev/null)
if [ -n "$IN_PROGRESS" ]; then
    add_to_report "${YELLOW}⚠ In progress:${RESET}"
    echo "$IN_PROGRESS" | while read line; do
        add_to_report "  ${line}"
    done
else
    add_to_report "${GREEN}✓ Nothing in progress${RESET}"
fi
add_to_report ""

# Infrastructure Status Section
add_to_report "${BOLD}${BLUE}═══ Infrastructure Status ═══${RESET}"
add_to_report ""

# NATS status
if pgrep -f nats-server > /dev/null; then
    add_to_report "${GREEN}✓ NATS server running${RESET}"

    # Check pending work queue
    if nats stream ls > /dev/null 2>&1; then
        PENDING=$(nats stream info WORK --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['state']['messages'])" 2>/dev/null)
        if [ -n "$PENDING" ]; then
            add_to_report "${CYAN}  └─ Work queue: ${PENDING} messages pending${RESET}"
        fi
    fi
else
    add_to_report "${RED}✗ NATS server stopped${RESET}"
fi

# Memory server status
if pgrep -f agent-memory > /dev/null; then
    add_to_report "${GREEN}✓ Agent memory server running${RESET}"
else
    add_to_report "${YELLOW}○ Agent memory server stopped${RESET}"
fi
add_to_report ""

# Tests Status
add_to_report "${BOLD}${BLUE}═══ Tests Status ═══${RESET}"
if [ -d "tests" ]; then
    if pytest tests/ -q --tb=no 2>/dev/null; then
        add_to_report "${GREEN}✓ All tests passing${RESET}"
    else
        add_to_report "${RED}✗ Some tests failing - review before tomorrow${RESET}"
    fi
else
    add_to_report "${YELLOW}○ No tests directory found${RESET}"
fi
add_to_report ""

# Tomorrow's Priorities Section
add_to_report "${BOLD}${BLUE}═══ Tomorrow's Summonings ═══${RESET}"
add_to_report ""

# Extract not-started items from roadmap
NOT_STARTED=$(grep -A3 "⚪" .haunt/plans/roadmap.md 2>/dev/null | head -15)
if [ -n "$NOT_STARTED" ]; then
    add_to_report "${CYAN}Top priorities to start:${RESET}"
    echo "$NOT_STARTED" | while read line; do
        add_to_report "  ${line}"
    done
else
    add_to_report "${GREEN}✓ No pending work items${RESET}"
fi
add_to_report ""

# Extract blocked items
BLOCKED=$(grep -A3 "🔴" .haunt/plans/roadmap.md 2>/dev/null)
if [ -n "$BLOCKED" ]; then
    add_to_report "${RED}⚠ Blocked items requiring attention:${RESET}"
    echo "$BLOCKED" | while read line; do
        add_to_report "  ${line}"
    done
    add_to_report ""
fi

# Agent Memory Consolidation (REM Sleep)
add_to_report "${BOLD}${BLUE}═══ Memory Consolidation (REM Sleep) ═══${RESET}"
if [ "$SKIP_MEMORY" = true ]; then
    add_to_report "${YELLOW}○ Skipped (--skip-memory flag)${RESET}"
else
    # Check if memory file exists and has content
    MEMORY_FILE="$HOME/.agent-memory/memories.json"
    CONSOLIDATION_SCRIPT="$(dirname "$0")/../utils/consolidate-memory.py"

    if [ ! -f "$MEMORY_FILE" ]; then
        add_to_report "${YELLOW}○ No agent memories to consolidate${RESET}"
    elif [ ! -f "$CONSOLIDATION_SCRIPT" ]; then
        add_to_report "${RED}✗ Consolidation script not found: ${CONSOLIDATION_SCRIPT}${RESET}"
    elif ! command -v python3 &> /dev/null; then
        add_to_report "${RED}✗ python3 not available${RESET}"
    else
        # Run consolidation
        CONSOLIDATION_OUTPUT=$(python3 "$CONSOLIDATION_SCRIPT" 2>&1)
        CONSOLIDATION_EXIT=$?

        if [ $CONSOLIDATION_EXIT -eq 0 ]; then
            # Success - display output
            echo "$CONSOLIDATION_OUTPUT" | while read line; do
                add_to_report "${GREEN}${line}${RESET}"
            done
        else
            add_to_report "${RED}✗ Memory consolidation failed${RESET}"
            add_to_report "${YELLOW}  Error: ${CONSOLIDATION_OUTPUT}${RESET}"
        fi
    fi
fi
add_to_report ""

# Footer
add_to_report "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
add_to_report "${BOLD}${CYAN}║        Spirits Banished - Rest in the Crypt! 🌙               ║${RESET}"
add_to_report "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
add_to_report ""
add_to_report "${BOLD}Action items for tomorrow:${RESET}"
add_to_report "  ${GREEN}•${RESET} Run morning-review.sh to resume work"
add_to_report "  ${GREEN}•${RESET} Review any overnight agent activity"
add_to_report "  ${GREEN}•${RESET} Address blocked items if any"
add_to_report "  ${GREEN}•${RESET} Start next priority from roadmap"
add_to_report ""

# Save report if requested
if [ "$SAVE_REPORT" = true ]; then
    PROGRESS_DIR=".haunt/progress"
    mkdir -p "$PROGRESS_DIR"

    REPORT_FILE="${PROGRESS_DIR}/handoff-$(date +%Y-%m-%d).md"

    # Strip color codes for markdown file
    echo -e "$REPORT" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" > "$REPORT_FILE"

    echo -e "${GREEN}✓ Report saved to: ${REPORT_FILE}${RESET}"
    echo ""
fi
