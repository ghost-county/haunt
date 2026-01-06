#!/bin/bash
#
# haunt-report.sh - Report issues to the Haunt GitHub repository
#
# This script collects diagnostic information and helps users create
# detailed issue reports on the main Haunt repository.

set -e

# Configuration
HAUNT_REPO="ghost-county/haunt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo -e "${YELLOW}⚠${NC} $1"
}

# Collect diagnostic information
collect_diagnostics() {
    info "Collecting diagnostic information..."
    echo ""
    
    # Haunt version
    HAUNT_VERSION=$(grep -m1 "version" "$SCRIPT_DIR/../QUICK-REFERENCE.md" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' || echo "unknown")
    
    # OS information
    OS_NAME=$(uname -s)
    OS_VERSION=$(uname -r)
    
    # Architecture
    ARCH=$(uname -m)
    
    # Claude Code version (if available)
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "not installed")
    
    # Git status (if in git repo)
    if git rev-parse --git-dir > /dev/null 2>&1; then
        GIT_STATUS="Git repo ($(git rev-parse --abbrev-ref HEAD))"
    else
        GIT_STATUS="Not a git repository"
    fi
    
    # Recent errors from Haunt logs (if they exist)
    RECENT_ERRORS=""
    if [ -f "$PROJECT_ROOT/.haunt/integration.log" ]; then
        RECENT_ERRORS=$(tail -100 "$PROJECT_ROOT/.haunt/integration.log" 2>/dev/null | grep -i "error\|exception\|fail" | tail -10 || echo "No recent errors found")
    else
        RECENT_ERRORS="No integration.log file found"
    fi
    
    # Build diagnostics section
    cat > /tmp/haunt-diagnostics.md << DIAG_EOF
## Environment

- **Haunt Version:** ${HAUNT_VERSION}
- **OS:** ${OS_NAME} ${OS_VERSION} (${ARCH})
- **Claude Code:** ${CLAUDE_VERSION}
- **Git Status:** ${GIT_STATUS}
- **Date:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Recent Errors (if any)

\`\`\`
${RECENT_ERRORS}
\`\`\`
DIAG_EOF
    
    success "Diagnostics collected"
}

# Check if GitHub CLI is available and authenticated
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        return 1
    fi
    
    if ! gh auth status &> /dev/null 2>&1; then
        return 2
    fi
    
    return 0
}

# Create issue using GitHub CLI
create_issue_gh() {
    local title="$1"
    local description="$2"
    local issue_type="$3"
    
    # Read diagnostics
    local diagnostics=$(cat /tmp/haunt-diagnostics.md)
    
    # Build full issue body
    local body="${description}

---

${diagnostics}

---

**Reported via:** \`/haunt-report\` command"
    
    info "Creating issue on ${HAUNT_REPO}..."
    
    # Create issue
    local issue_url=$(gh issue create \
        --repo "$HAUNT_REPO" \
        --title "${issue_type}: ${title}" \
        --body "$body" \
        --label "user-reported"
    )
    
    echo ""
    success "Issue created successfully!"
    echo ""
    echo "  ${issue_url}"
    echo ""
    info "Thank you for helping improve Haunt! 👻"
}

# Create issue using browser (fallback)
create_issue_browser() {
    local title="$1"
    local description="$2"
    local issue_type="$3"
    
    # Read diagnostics
    local diagnostics=$(cat /tmp/haunt-diagnostics.md)
    
    # Build full issue body
    local body="${description}

---

${diagnostics}

---

**Reported via:** \`/haunt-report\` command"
    
    # URL encode the body (using Python for cross-platform compatibility)
    local encoded_body=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''${body}'''))" 2>/dev/null || echo "")
    local encoded_title=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''${issue_type}: ${title}'''))" 2>/dev/null || echo "")
    
    if [ -z "$encoded_body" ]; then
        error "Failed to encode issue body. Please create issue manually at:"
        echo "  https://github.com/${HAUNT_REPO}/issues/new"
        echo ""
        echo "Title: ${issue_type}: ${title}"
        echo ""
        echo "Body:"
        echo "$body"
        return 1
    fi
    
    # Build GitHub issue URL with pre-filled data
    local url="https://github.com/${HAUNT_REPO}/issues/new?title=${encoded_title}&body=${encoded_body}&labels=user-reported"
    
    info "Opening browser with pre-filled issue template..."
    echo ""
    
    # Try to open browser (cross-platform)
    if command -v open &> /dev/null; then
        open "$url"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$url"
    elif command -v start &> /dev/null; then
        start "$url"
    else
        warning "Could not open browser automatically."
        echo ""
        echo "Please visit this URL to create the issue:"
        echo "  $url"
        return 0
    fi
    
    echo ""
    success "Browser opened. Please review and submit the issue."
    echo ""
    info "Thank you for helping improve Haunt! 👻"
}

# Interactive issue creation
interactive_issue_creation() {
    echo ""
    echo "═══════════════════════════════════════════"
    echo "  Haunt Issue Reporter"
    echo "═══════════════════════════════════════════"
    echo ""
    
    # Collect diagnostics first
    collect_diagnostics
    echo ""
    
    # Select issue type
    echo "What type of issue are you reporting?"
    echo ""
    echo "  1) 🐛 Bug Report - Something isn't working"
    echo "  2) ✨ Feature Request - New functionality or improvement"
    echo "  3) 📚 Documentation - Docs are unclear or incorrect"
    echo "  4) ❓ Question - General question about Haunt"
    echo ""
    read -p "Select (1-4): " issue_type_num
    
    case $issue_type_num in
        1) ISSUE_TYPE="🐛 Bug" ;;
        2) ISSUE_TYPE="✨ Feature" ;;
        3) ISSUE_TYPE="📚 Docs" ;;
        4) ISSUE_TYPE="❓ Question" ;;
        *) ISSUE_TYPE="🐛 Bug" ;;
    esac
    
    echo ""
    
    # Get issue title
    read -p "Issue title: " TITLE
    
    if [ -z "$TITLE" ]; then
        error "Title cannot be empty"
        exit 1
    fi
    
    echo ""
    echo "Issue description (press Ctrl+D or type 'END' on a new line to finish):"
    echo ""
    
    # Read multi-line description
    DESCRIPTION=""
    while IFS= read -r line; do
        [[ "$line" == "END" ]] && break
        DESCRIPTION="${DESCRIPTION}${line}\n"
    done
    
    if [ -z "$DESCRIPTION" ]; then
        error "Description cannot be empty"
        exit 1
    fi
    
    echo ""
    
    # Convert \n to actual newlines
    DESCRIPTION=$(echo -e "$DESCRIPTION")
    
    # Check GitHub CLI availability
    check_gh_cli
    gh_status=$?
    
    if [ $gh_status -eq 0 ]; then
        # GitHub CLI available and authenticated
        create_issue_gh "$TITLE" "$DESCRIPTION" "$ISSUE_TYPE"
    elif [ $gh_status -eq 1 ]; then
        # GitHub CLI not installed
        warning "GitHub CLI (gh) not found."
        echo ""
        echo "For automated issue creation, install GitHub CLI:"
        echo "  macOS:   brew install gh"
        echo "  Linux:   https://github.com/cli/cli#installation"
        echo "  Windows: https://github.com/cli/cli#installation"
        echo ""
        echo "Then authenticate: gh auth login"
        echo ""
        info "Falling back to browser-based issue creation..."
        sleep 2
        create_issue_browser "$TITLE" "$DESCRIPTION" "$ISSUE_TYPE"
    elif [ $gh_status -eq 2 ]; then
        # GitHub CLI not authenticated
        warning "GitHub CLI found but not authenticated."
        echo ""
        echo "Run this once: gh auth login"
        echo ""
        info "Falling back to browser-based issue creation..."
        sleep 2
        create_issue_browser "$TITLE" "$DESCRIPTION" "$ISSUE_TYPE"
    fi
    
    # Cleanup
    rm -f /tmp/haunt-diagnostics.md
}

# Main execution
main() {
    interactive_issue_creation
}

main "$@"
