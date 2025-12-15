#!/usr/bin/env bash
#
# garden-roadmap.sh - Verify and archive completed requirements
#
# Usage:
#   bash garden-roadmap.sh              # Verify and archive all completed items
#   bash garden-roadmap.sh --dry-run    # Show what would be archived without doing it
#   bash garden-roadmap.sh --verify-only # Only check for issues, don't archive
#
# Part of the Ghost County Haunt framework

set -euo pipefail

# Colors
PURPLE='\033[0;35m'
MAGENTA='\033[1;35m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Ghost County themed output
section() {
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${PURPLE}👻  $1${RESET}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

success() { echo -e "${GREEN}✅ $1${RESET}"; }
warning() { echo -e "${YELLOW}⚠️  $1${RESET}"; }
error() { echo -e "${RED}❌ $1${RESET}"; }
info() { echo -e "${PURPLE}ℹ️  $1${RESET}"; }

# Parse arguments
DRY_RUN=false
VERIFY_ONLY=false

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --verify-only)
            VERIFY_ONLY=true
            ;;
        -h|--help)
            echo "Usage: garden-roadmap.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run        Show what would be archived without doing it"
            echo "  --verify-only    Only check for issues, don't archive"
            echo "  -h, --help       Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $arg"
            exit 1
            ;;
    esac
done

# Verify .haunt directory exists
if [[ ! -d ".haunt/plans" ]]; then
    error "No .haunt/plans directory found. Run this from project root."
    exit 1
fi

ROADMAP=".haunt/plans/roadmap.md"
ARCHIVE=".haunt/completed/roadmap-archive.md"

if [[ ! -f "$ROADMAP" ]]; then
    error "No roadmap found at $ROADMAP"
    exit 1
fi

section "🌙 Roadmap Gardening Ritual"

# Create archive directory if it doesn't exist
mkdir -p .haunt/completed

# Extract all completed requirements
COMPLETED_REQS=()
VERIFICATION_ISSUES=()
ARCHIVE_CANDIDATES=()

info "Reading roadmap at $ROADMAP..."

# Parse roadmap for completed items
# This is a simplified parser - production version would use Python/Ruby for robust parsing
while IFS= read -r line; do
    # Look for requirement headers with 🟢
    if [[ "$line" =~ ^###[[:space:]]🟢[[:space:]]REQ-([0-9]+): ]]; then
        REQ_NUM="${BASH_REMATCH[1]}"
        COMPLETED_REQS+=("REQ-$REQ_NUM")
    fi
done < "$ROADMAP"

if [[ ${#COMPLETED_REQS[@]} -eq 0 ]]; then
    success "No completed requirements found. Roadmap is clean."
    exit 0
fi

info "Found ${#COMPLETED_REQS[@]} completed requirement(s): ${COMPLETED_REQS[*]}"

# Verify each completed requirement
section "🔍 Verifying Task Checkboxes"

for req in "${COMPLETED_REQS[@]}"; do
    info "Checking $req..."

    # Extract requirement block (from ### REQ-XXX to next ### or end)
    REQ_BLOCK=$(awk "/^### 🟢 $req:/,/^###/" "$ROADMAP" | sed '$d')

    # Count unchecked tasks in this requirement
    UNCHECKED_COUNT=$(echo "$REQ_BLOCK" | grep -c "^- \[ \]" || true)
    CHECKED_COUNT=$(echo "$REQ_BLOCK" | grep -c "^- \[x\]" || true)

    if [[ $UNCHECKED_COUNT -gt 0 ]]; then
        warning "$req: $UNCHECKED_COUNT unchecked task(s), $CHECKED_COUNT checked"
        VERIFICATION_ISSUES+=("$req: $UNCHECKED_COUNT unchecked tasks")
    else
        if [[ $CHECKED_COUNT -gt 0 ]]; then
            success "$req: All $CHECKED_COUNT tasks checked ✓"
            ARCHIVE_CANDIDATES+=("$req")
        else
            info "$req: No tasks to verify"
            ARCHIVE_CANDIDATES+=("$req")
        fi
    fi
done

# Report verification issues
if [[ ${#VERIFICATION_ISSUES[@]} -gt 0 ]]; then
    section "⚠️  Verification Issues Found"
    for issue in "${VERIFICATION_ISSUES[@]}"; do
        warning "$issue"
    done
    echo ""
    error "Cannot archive requirements with unchecked tasks."
    error "Please update roadmap and try again."
    exit 1
fi

if [[ $VERIFY_ONLY == true ]]; then
    section "✅ Verification Complete"
    success "All ${#ARCHIVE_CANDIDATES[@]} completed requirement(s) have tasks checked off."
    info "Run without --verify-only to archive them."
    exit 0
fi

# Archive completed requirements
section "📦 Archiving Completed Work"

if [[ $DRY_RUN == true ]]; then
    info "DRY RUN - Would archive ${#ARCHIVE_CANDIDATES[@]} requirement(s):"
    for req in "${ARCHIVE_CANDIDATES[@]}"; do
        echo "  - $req"
    done
    exit 0
fi

# Create archive header if file doesn't exist
if [[ ! -f "$ARCHIVE" ]]; then
    cat > "$ARCHIVE" <<EOF
# Roadmap Archive

Completed requirements from \`.haunt/plans/roadmap.md\`.

---

EOF
fi

# Archive each requirement
ARCHIVED_COUNT=0
TODAY=$(date +%Y-%m-%d)

for req in "${ARCHIVE_CANDIDATES[@]}"; do
    info "Archiving $req..."

    # Extract full requirement block
    REQ_BLOCK=$(awk "/^### 🟢 $req:/,/^###/" "$ROADMAP" | sed '$d')

    # Append to archive with date header
    {
        echo ""
        echo "## Archived $TODAY"
        echo ""
        echo "$REQ_BLOCK"
        echo ""
        echo "---"
        echo ""
    } >> "$ARCHIVE"

    # Remove from roadmap (delete from ### REQ-XXX to next ### or end)
    # Using perl for cross-platform compatibility
    perl -i -ne 'BEGIN{$delete=0} if(/^### 🟢 '"$req"':/) {$delete=1} elsif(/^###/ && $delete) {$delete=0} print unless $delete' "$ROADMAP"

    ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
    success "Archived $req"
done

# Final report
section "✨ Gardening Complete"

success "Archived $ARCHIVED_COUNT requirement(s) to $ARCHIVE"
success "Removed archived items from $ROADMAP"
info "Active roadmap cleaned. Ready for the next summoning."
