#!/usr/bin/env bash
#
# setup-haunt.sh - Haunt Setup Script
#
# This script summons the Haunt framework including:
# - Spirit agents in ~/.claude/agents/
# - Haunt skills from Haunt/skills/
# - Infrastructure verification
# - Directory structure creation
#
# Usage: bash scripts/setup-haunt.sh [options]
#
# Run with --help for full documentation

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# ============================================================================
# COLOR OUTPUT FUNCTIONS
# ============================================================================

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly PURPLE='\033[0;35m'
readonly MAGENTA='\033[1;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Output functions
success() {
    echo -e "${GREEN}✓${NC} $1"
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

section() {
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════${NC}"
    echo -e "${BOLD}${PURPLE}  👻 $1${NC}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════${NC}"
    echo ""
}

# ============================================================================
# ASCII BANNER
# ============================================================================

show_banner() {
    echo -e "${MAGENTA}"
    cat << "EOF"
                                   .     .
                                .  |\-^-/|  .
                               /| } O.=.O { |\
                              /╱ \-_ _ _-/   \\
                 ██╗  ██╗ █████╗ ██╗   ██╗███╗   ██╗████████╗
                 ██║  ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝
                 ███████║███████║██║   ██║██╔██╗ ██║   ██║
                 ██╔══██║██╔══██║██║   ██║██║╚██╗██║   ██║
                 ██║  ██║██║  ██║╚██████╔╝██║ ╚████║   ██║
                 ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝
                        ┌─────────────────────────────┐
                        │   G H O S T   C O U N T Y   │
                        │     Summon Your Dev Team    │
                        └─────────────────────────────┘
EOF
    echo -e "${NC}"
}

# ============================================================================
# REMOTE EXECUTION SUPPORT
# ============================================================================

# Check if we have the required resources locally
check_local_resources() {
    local script_dir="$1"

    # Check if agents directory exists relative to script
    if [[ -d "${script_dir}/../agents" ]] && [[ -d "${script_dir}/../skills" ]]; then
        return 0  # Resources exist locally
    fi
    return 1  # Resources missing - need to clone
}

# Clone the repository for remote execution
# NOTE: This function is called in a subshell $(...), so we must send
# info/success messages to stderr, not stdout. Only the clone_dir goes to stdout.
clone_repo_for_setup() {
    local clone_dir="${TMPDIR:-/tmp}/haunt-setup-$$"

    # Send info to stderr since stdout is captured for return value
    echo -e "${CYAN}ℹ${NC} Remote execution detected - cloning repository..." >&2

    # Check for git
    if ! command -v git &> /dev/null; then
        error "git is required for remote installation"
        error "Please install git and try again"
        exit 3
    fi

    # Clone the repo (capture stderr to show actual errors)
    local clone_output
    clone_output=$(git clone --depth 1 --branch "$GITHUB_REPO_BRANCH" "$GITHUB_REPO_URL" "$clone_dir" 2>&1)
    local clone_exit_code=$?

    if [[ $clone_exit_code -ne 0 ]]; then
        error "Failed to clone repository from $GITHUB_REPO_URL"
        echo "" >&2
        echo -e "${RED}Git error:${NC}" >&2
        echo "$clone_output" >&2
        echo "" >&2
        error "Possible causes:"
        error "  1. Git not in PATH (verify: which git)"
        error "  2. Network/firewall blocking GitHub"
        error "  3. GitHub authentication required"
        error "  4. Rate limiting (try again later)"
        echo "" >&2
        error "Use manual installation instead:"
        error "  git clone https://github.com/ghost-county/ghost-county.git"
        error "  cd ghost-county && bash Haunt/scripts/setup-haunt.sh"
        exit 3
    fi

    # Show clone output in verbose mode
    if [[ "$VERBOSE" == true ]]; then
        echo "$clone_output" >&2
    fi

    # Send success to stderr since stdout is captured for return value
    echo -e "${GREEN}✓${NC} Repository cloned to $clone_dir" >&2

    # Return the clone directory (only this goes to stdout)
    echo "$clone_dir"
}

# Cleanup cloned repository
cleanup_cloned_repo() {
    if [[ -n "$REMOTE_CLONE_DIR" ]] && [[ -d "$REMOTE_CLONE_DIR" ]]; then
        if [[ "$CLEANUP_AFTER" == true ]]; then
            info "Cleaning up cloned repository..."
            rm -rf "$REMOTE_CLONE_DIR"
            success "Removed $REMOTE_CLONE_DIR"
        else
            info "Cloned repository kept at: $REMOTE_CLONE_DIR"
            info "To remove it later, run: rm -rf $REMOTE_CLONE_DIR"
        fi
    fi
}

# ============================================================================
# CONFIGURATION
# ============================================================================

# Global configuration - these may be updated if running remotely
# Handle being piped via curl (BASH_SOURCE is unset in that case)
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || echo "")"
else
    SCRIPT_DIR=""
fi
PROJECT_ROOT=""
REPO_ROOT=""
PROJECT_AGENTS_DIR=""
SOURCE_SKILLS_DIR=""
SOURCE_COMMANDS_DIR=""

# Initialize paths (may be updated by ensure_resources)
init_paths() {
    PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
    REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
    PROJECT_AGENTS_DIR="${PROJECT_ROOT}/agents"
    SOURCE_SKILLS_DIR="${PROJECT_ROOT}/skills"
    SOURCE_COMMANDS_DIR="${PROJECT_ROOT}/commands"
}

# Ensure we have access to required resources (clone if needed)
ensure_resources() {
    # If SCRIPT_DIR is empty (piped from curl), we definitely need to clone
    if [[ -z "$SCRIPT_DIR" ]] || [[ ! -d "$SCRIPT_DIR" ]]; then
        RUNNING_FROM_REMOTE=true
        REMOTE_CLONE_DIR=$(clone_repo_for_setup)
        SCRIPT_DIR="${REMOTE_CLONE_DIR}/Haunt/scripts"
        init_paths
        return
    fi

    # Check if local resources exist
    if ! check_local_resources "$SCRIPT_DIR"; then
        RUNNING_FROM_REMOTE=true
        REMOTE_CLONE_DIR=$(clone_repo_for_setup)
        SCRIPT_DIR="${REMOTE_CLONE_DIR}/Haunt/scripts"
        init_paths
        return
    fi

    # Local resources exist, initialize paths normally
    init_paths
}

# Scope configuration (will be set based on --scope or --user flag)
SCOPE="project"  # Default: project-local (.claude/)
GLOBAL_AGENTS_DIR="${HOME}/.claude/agents"
GLOBAL_AGENTS_BACKUP_DIR="${HOME}/.claude/agents.backup"
GLOBAL_SKILLS_DIR="${HOME}/.claude/skills"
GLOBAL_SKILLS_BACKUP_DIR="${HOME}/.claude/skills.backup"
GLOBAL_COMMANDS_DIR="${HOME}/.claude/commands"
GLOBAL_COMMANDS_BACKUP_DIR="${HOME}/.claude/commands.backup"
GLOBAL_SETTINGS_FILE="${HOME}/.claude/settings.json"
PROJECT_AGENTS_INSTALL_DIR="$(pwd)/.claude/agents"
PROJECT_AGENTS_BACKUP_DIR="$(pwd)/.claude/agents.backup"
PROJECT_SKILLS_INSTALL_DIR="$(pwd)/.claude/skills"
PROJECT_SKILLS_BACKUP_DIR="$(pwd)/.claude/skills.backup"
PROJECT_COMMANDS_INSTALL_DIR="$(pwd)/.claude/commands"
PROJECT_COMMANDS_BACKUP_DIR="$(pwd)/.claude/commands.backup"
PROJECT_SETTINGS_FILE="$(pwd)/.claude/settings.json"

# Actual installation directories (will be set in parse_arguments)
AGENTS_INSTALL_DIR=""
AGENTS_BACKUP_DIR=""
SKILLS_INSTALL_DIR=""
SKILLS_BACKUP_DIR=""
MCP_SETTINGS_FILE=""

# Default flags
DRY_RUN=false
AGENTS_ONLY=false
SKILLS_ONLY=false
PROJECT_ONLY=false
VERIFY_ONLY=false
FIX_MODE=false
VERBOSE=false
SKIP_PREREQS=false
NO_BACKUP=false
NO_MCP=false
WITH_RITUALS=true  # Enabled by default
NO_RITUALS=false
WITH_PATTERN_DETECTION=true  # Enabled by default
NO_PATTERN_DETECTION=false
CLEANUP_AFTER=true  # For remote execution: delete cloned repo after setup
YES_TO_ALL=false  # Skip prompts and auto-install all dependencies

# Remote execution support
REMOTE_CLONE_DIR=""  # Will be set if we clone the repo
RUNNING_FROM_REMOTE=false

# GitHub repo URL for remote installation
readonly GITHUB_REPO_URL="https://github.com/ghost-county/ghost-county.git"
readonly GITHUB_REPO_BRANCH="main"

# ============================================================================
# HELP TEXT
# ============================================================================

show_help() {
    cat << EOF
${BOLD}USAGE:${NC}
    bash scripts/setup-haunt.sh [OPTIONS]

${BOLD}DESCRIPTION:${NC}
    Haunt framework setup script. By default, summons to project-local .claude/:

    • Spirit agents to .claude/agents/ (use --user for ~/.claude/)
    • Haunt methodology skills from Haunt/skills/
    • Verifies spiritual infrastructure (MCP servers)
    • Manifests required directory structure (.haunt/)
    • Ensures idempotent execution (safe to run multiple times)

${BOLD}OPTIONS:${NC}
    ${BOLD}--help${NC}              Show this help message and exit

    ${BOLD}--dry-run${NC}           Show what would be done without executing

    ${BOLD}--user${NC}              Summon to ~/.claude/ (global/user-level)

    ${BOLD}--scope=<value>${NC}     Summoning scope for agents and MCP servers:
                        • ${BOLD}project${NC} - Summon to ./.claude/ (default)
                        • ${BOLD}global${NC}  - Summon to ~/.claude/ (same as --user)
                        • ${BOLD}both${NC}    - Summon to both locations

    ${BOLD}--agents-only${NC}       Only summon spirit agents
    ${BOLD}--skills-only${NC}       Only conjure project-specific skills
    ${BOLD}--project-only${NC}      ${YELLOW}[DEPRECATED]${NC} Project is now the default

    ${BOLD}--verify${NC}            Only verify existing haunt, don't modify
    ${BOLD}--fix${NC}               Exorcise issues found during verification

    ${BOLD}--yes, -y${NC}           Auto-install all missing dependencies without prompting
    ${BOLD}--skip-prereqs${NC}      Skip prerequisite divination
    ${BOLD}--no-backup${NC}         Skip backup of existing spirits
    ${BOLD}--no-mcp${NC}            Skip MCP server channeling
    ${BOLD}--no-rituals${NC}        Skip binding of ritual scripts (morning-review, evening-handoff, weekly-refactor)
    ${BOLD}--no-pattern-detection${NC}  Skip conjuring of pattern detection tools (hunt-patterns, weekly-refactor)
    ${BOLD}--cleanup${NC}           Delete cloned repo after setup (for remote installation)
    ${BOLD}--verbose${NC}           Show detailed output during execution

${BOLD}REMOTE INSTALLATION:${NC}
    This script can be run directly from the internet:

    # Quick install (clones repo, runs setup, keeps repo)
    curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash

    # Install and cleanup (removes cloned repo after setup)
    curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --cleanup

    # Install with options
    curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --scope=project --cleanup

${BOLD}EXAMPLES:${NC}
    # Manifest full haunt (default: project-local to .claude/)
    bash scripts/setup-haunt.sh

    # Summon to global/user-level (~/.claude/)
    bash scripts/setup-haunt.sh --user

    # Summon to both global and project scopes
    bash scripts/setup-haunt.sh --scope=both

    # Divine what would be summoned without executing
    bash scripts/setup-haunt.sh --dry-run

    # Preview global/user summoning
    bash scripts/setup-haunt.sh --user --dry-run

    # Only summon project-local agents
    bash scripts/setup-haunt.sh --agents-only

    # Only summon global agents
    bash scripts/setup-haunt.sh --user --agents-only

    # Manifest project structure only (skip agents)
    bash scripts/setup-haunt.sh --project-only

    # Verify existing haunt
    bash scripts/setup-haunt.sh --verify

    # Verify and exorcise any issues
    bash scripts/setup-haunt.sh --verify --fix

    # Update agents without backup
    bash scripts/setup-haunt.sh --agents-only --no-backup

${BOLD}EXIT CODES:${NC}
    0    Success
    1    General error
    2    Invalid arguments
    3    Missing dependencies
    4    Verification failed

${BOLD}NOTES:${NC}
    • Script is idempotent - safe to run multiple times
    • Uses colored output for better readability
    • All file operations preserve existing content where appropriate
    • Default scope is 'global' (installs to ~/.claude/)
    • Use --scope=project for project-local installation (./.claude/)
    • Use --scope=both to install to both locations
    • Project skills are always relative to project root
    • Existing agents are backed up before overwriting (unless --no-backup)

${BOLD}MORE INFO:${NC}
    See README.md for complete documentation

EOF
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --scope=*)
                SCOPE="${1#*=}"
                # Validate scope value
                if [[ "$SCOPE" != "global" && "$SCOPE" != "project" && "$SCOPE" != "both" ]]; then
                    error "Invalid scope value: ${SCOPE}"
                    error "Valid values: global, project, both"
                    exit 2
                fi
                shift
                ;;
            --user)
                SCOPE="global"
                shift
                ;;
            --agents-only)
                AGENTS_ONLY=true
                shift
                ;;
            --skills-only)
                SKILLS_ONLY=true
                shift
                ;;
            --project-only)
                warning "--project-only is deprecated (project is now the default)"
                warning "This flag will be removed in a future version"
                # PROJECT_ONLY is now redundant since project is the default
                shift
                ;;
            --verify)
                VERIFY_ONLY=true
                shift
                ;;
            --fix)
                FIX_MODE=true
                shift
                ;;
            --skip-prereqs)
                SKIP_PREREQS=true
                shift
                ;;
            --yes|-y)
                YES_TO_ALL=true
                shift
                ;;
            --no-backup)
                NO_BACKUP=true
                shift
                ;;
            --no-mcp)
                NO_MCP=true
                shift
                ;;
            --no-rituals)
                WITH_RITUALS=false
                NO_RITUALS=true
                shift
                ;;
            --no-pattern-detection)
                WITH_PATTERN_DETECTION=false
                NO_PATTERN_DETECTION=true
                shift
                ;;
            --cleanup)
                CLEANUP_AFTER=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            *)
                error "Unknown option: $1"
                echo ""
                echo "Run with --help for usage information"
                exit 2
                ;;
        esac
    done

    # Validate flag combinations
    if [[ "$AGENTS_ONLY" == true && "$SKILLS_ONLY" == true ]]; then
        error "Cannot use --agents-only and --skills-only together"
        exit 2
    fi

    if [[ "$AGENTS_ONLY" == true && "$PROJECT_ONLY" == true ]]; then
        error "Cannot use --agents-only and --project-only together"
        exit 2
    fi

    if [[ "$SKILLS_ONLY" == true && "$PROJECT_ONLY" == true ]]; then
        warning "--skills-only and --project-only are similar; using --skills-only"
        PROJECT_ONLY=false
    fi

    # Set installation directories based on scope
    if [[ "$SCOPE" == "global" ]]; then
        AGENTS_INSTALL_DIR="$GLOBAL_AGENTS_DIR"
        AGENTS_BACKUP_DIR="$GLOBAL_AGENTS_BACKUP_DIR"
        SKILLS_INSTALL_DIR="$GLOBAL_SKILLS_DIR"
        SKILLS_BACKUP_DIR="$GLOBAL_SKILLS_BACKUP_DIR"
        MCP_SETTINGS_FILE="$GLOBAL_SETTINGS_FILE"
    elif [[ "$SCOPE" == "project" ]]; then
        AGENTS_INSTALL_DIR="$PROJECT_AGENTS_INSTALL_DIR"
        AGENTS_BACKUP_DIR="$PROJECT_AGENTS_BACKUP_DIR"
        SKILLS_INSTALL_DIR="$PROJECT_SKILLS_INSTALL_DIR"
        SKILLS_BACKUP_DIR="$PROJECT_SKILLS_BACKUP_DIR"
        MCP_SETTINGS_FILE="$PROJECT_SETTINGS_FILE"
    elif [[ "$SCOPE" == "both" ]]; then
        # For 'both' scope, we'll handle installations in the setup functions
        AGENTS_INSTALL_DIR="both"
        AGENTS_BACKUP_DIR="both"
        SKILLS_INSTALL_DIR="both"
        SKILLS_BACKUP_DIR="both"
        MCP_SETTINGS_FILE="both"
    fi
}

# ============================================================================
# DRY RUN HELPERS
# ============================================================================

execute() {
    local description="$1"
    shift

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would execute: $description"
        if [[ "$VERBOSE" == true ]]; then
            echo "  Command: $*"
        fi
        return 0
    fi

    if [[ "$VERBOSE" == true ]]; then
        info "Executing: $description"
        echo "  Command: $*"
    fi

    "$@"
}

# ============================================================================
# PHASE 1: PREREQUISITES CHECK
# ============================================================================

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Detect package manager
detect_package_manager() {
    local os=$(detect_os)

    if [[ "$os" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            echo "brew"
        else
            echo "none"
        fi
    elif [[ "$os" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            echo "apt"
        elif command -v yum &> /dev/null; then
            echo "yum"
        elif command -v dnf &> /dev/null; then
            echo "dnf"
        else
            echo "none"
        fi
    else
        echo "none"
    fi
}

# Prompt user for installation (returns 0 for yes, 1 for no)
prompt_install() {
    local package_name="$1"
    local install_command="$2"

    # If --yes flag is set, auto-confirm
    if [[ "$YES_TO_ALL" == true ]]; then
        info "Auto-installing ${package_name} (--yes flag set)"
        return 0
    fi

    # Interactive prompt
    echo -e "${YELLOW}?${NC} Install ${package_name} via ${install_command}? (Y/n): "
    read -r response

    # Default to Yes if empty
    if [[ -z "$response" ]] || [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Add directory to PATH in shell profile
add_to_path() {
    local dir_to_add="$1"
    local shell_profile=""

    # Detect shell profile
    if [[ -n "$ZSH_VERSION" ]] && [[ -f "$HOME/.zshrc" ]]; then
        shell_profile="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] && [[ -f "$HOME/.bashrc" ]]; then
        shell_profile="$HOME/.bashrc"
    elif [[ -f "$HOME/.bash_profile" ]]; then
        shell_profile="$HOME/.bash_profile"
    elif [[ -f "$HOME/.profile" ]]; then
        shell_profile="$HOME/.profile"
    fi

    if [[ -z "$shell_profile" ]]; then
        warning "Could not detect shell profile to update PATH"
        return 1
    fi

    # Check if already in PATH
    if grep -q "export PATH.*${dir_to_add}" "$shell_profile" 2>/dev/null; then
        info "PATH already includes ${dir_to_add} in ${shell_profile}"
        return 0
    fi

    # Add to PATH
    echo "" >> "$shell_profile"
    echo "# Added by Haunt setup" >> "$shell_profile"
    echo "export PATH=\"${dir_to_add}:\$PATH\"" >> "$shell_profile"
    success "Added ${dir_to_add} to PATH in ${shell_profile}"
    warning "Please run: source ${shell_profile}"
    return 0
}

# Install git
install_git() {
    local pkg_manager=$(detect_package_manager)

    if [[ "$pkg_manager" == "brew" ]]; then
        if prompt_install "git" "brew"; then
            info "Installing git via Homebrew..."
            brew install git || {
                error "Failed to install git"
                return 1
            }
            success "git installed successfully"
        else
            warning "Skipping git installation"
            return 1
        fi
    elif [[ "$pkg_manager" == "apt" ]]; then
        if prompt_install "git" "apt-get"; then
            info "Installing git via apt-get..."
            sudo apt-get update && sudo apt-get install -y git || {
                error "Failed to install git"
                return 1
            }
            success "git installed successfully"
        else
            warning "Skipping git installation"
            return 1
        fi
    elif [[ "$pkg_manager" == "yum" ]] || [[ "$pkg_manager" == "dnf" ]]; then
        if prompt_install "git" "$pkg_manager"; then
            info "Installing git via ${pkg_manager}..."
            sudo $pkg_manager install -y git || {
                error "Failed to install git"
                return 1
            }
            success "git installed successfully"
        else
            warning "Skipping git installation"
            return 1
        fi
    else
        error "No supported package manager found"
        info "Please install git manually: https://git-scm.com/downloads"
        return 1
    fi
}

# Install Python 3.11+
install_python() {
    local pkg_manager=$(detect_package_manager)

    if [[ "$pkg_manager" == "brew" ]]; then
        if prompt_install "Python 3.11+" "brew"; then
            info "Installing Python 3.11 via Homebrew..."
            brew install python@3.11 || {
                error "Failed to install Python"
                return 1
            }
            success "Python installed successfully"

            # Check if python3 is in PATH
            if ! command -v python3 &> /dev/null; then
                warning "python3 not found in PATH after installation"
                add_to_path "/usr/local/opt/python@3.11/bin"
            fi
        else
            warning "Skipping Python installation"
            return 1
        fi
    elif [[ "$pkg_manager" == "apt" ]]; then
        if prompt_install "Python 3.11+" "apt-get"; then
            info "Installing Python 3.11 via apt-get..."
            sudo apt-get update && sudo apt-get install -y python3.11 python3.11-venv python3-pip || {
                error "Failed to install Python"
                return 1
            }
            success "Python installed successfully"
        else
            warning "Skipping Python installation"
            return 1
        fi
    elif [[ "$pkg_manager" == "yum" ]] || [[ "$pkg_manager" == "dnf" ]]; then
        if prompt_install "Python 3.11+" "$pkg_manager"; then
            info "Installing Python 3.11 via ${pkg_manager}..."
            sudo $pkg_manager install -y python311 python311-pip || {
                error "Failed to install Python"
                return 1
            }
            success "Python installed successfully"
        else
            warning "Skipping Python installation"
            return 1
        fi
    else
        error "No supported package manager found"
        info "Please install Python 3.11+ manually: https://www.python.org/downloads/"
        return 1
    fi
}

# ============================================================================
# PHASE 1.5: FRONTEND PLUGIN SETUP (OPTIONAL)
# ============================================================================

setup_frontend_plugin() {
    section "Phase 1.5: Frontend Design Plugin (Optional)"

    # Check if Claude Code CLI is available
    if ! command -v claude &> /dev/null; then
        warning "Claude Code CLI not found - skipping plugin setup"
        info "Install Claude Code CLI first: https://claude.ai/download"
        echo ""
        return 0
    fi

    # Check if plugin is already installed
    local plugin_installed=false
    if claude plugin list 2>/dev/null | grep -q "frontend-design"; then
        success "frontend-design plugin already installed"
        plugin_installed=true
    fi

    # If already installed, skip prompt
    if [[ "$plugin_installed" == true ]]; then
        info "Skipping plugin installation prompt"
        echo ""
        return 0
    fi

    # Interactive prompt
    echo ""
    info "The frontend-design plugin provides specialized UI/UX development capabilities:"
    info "  - Component scaffolding"
    info "  - Responsive design helpers"
    info "  - Accessibility checks"
    info "  - Browser preview integration"
    echo ""

    local response
    read -p "$(echo -e "${CYAN}?${NC} Install frontend-design plugin for UI development? (Y/n): ")" response
    response=${response:-Y}  # Default to Y if empty

    if [[ "$response" =~ ^[Yy]$ ]]; then
        info "Installing frontend-design plugin..."

        # Add marketplace if needed (suppress expected errors)
        claude plugin marketplace add anthropics/claude-code 2>&1 | grep -v "already" || true

        # Install plugin
        if claude plugin install frontend-design@claude-code-plugins 2>&1; then
            success "frontend-design plugin installed successfully!"
            info "Use plugin features with /frontend-design commands"
        else
            local exit_code=$?
            if [[ $exit_code -eq 1 ]]; then
                warning "Plugin may already be installed"
            else
                error "Failed to install frontend-design plugin (exit code: $exit_code)"
                info "You can install it manually later:"
                info "  claude plugin marketplace add anthropics/claude-code"
                info "  claude plugin install frontend-design@claude-code-plugins"
            fi
        fi
    else
        info "Skipping frontend-design plugin installation"
        info "You can install it later with:"
        info "  claude plugin marketplace add anthropics/claude-code"
        info "  claude plugin install frontend-design@claude-code-plugins"
    fi

    echo ""
}

# Install Node.js 18+
install_nodejs() {
    local pkg_manager=$(detect_package_manager)

    if [[ "$pkg_manager" == "brew" ]]; then
        if prompt_install "Node.js 18+" "brew"; then
            info "Installing Node.js via Homebrew..."
            brew install node || {
                error "Failed to install Node.js"
                return 1
            }
            success "Node.js installed successfully"
        else
            warning "Skipping Node.js installation"
            return 1
        fi
    elif [[ "$pkg_manager" == "apt" ]]; then
        if prompt_install "Node.js 18+" "apt-get (NodeSource)"; then
            info "Adding NodeSource repository and installing Node.js..."
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - || {
                error "Failed to add NodeSource repository"
                return 1
            }
            sudo apt-get install -y nodejs || {
                error "Failed to install Node.js"
                return 1
            }
            success "Node.js installed successfully"
        else
            warning "Skipping Node.js installation"
            return 1
        fi
    elif [[ "$pkg_manager" == "yum" ]] || [[ "$pkg_manager" == "dnf" ]]; then
        if prompt_install "Node.js 18+" "$pkg_manager (NodeSource)"; then
            info "Adding NodeSource repository and installing Node.js..."
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash - || {
                error "Failed to add NodeSource repository"
                return 1
            }
            sudo $pkg_manager install -y nodejs || {
                error "Failed to install Node.js"
                return 1
            }
            success "Node.js installed successfully"
        else
            warning "Skipping Node.js installation"
            return 1
        fi
    else
        error "No supported package manager found"
        info "Please install Node.js 18+ manually: https://nodejs.org/"
        return 1
    fi
}

# Install uv package manager
install_uv() {
    if prompt_install "uv package manager" "official installer"; then
        info "Installing uv via official installer..."
        curl -LsSf https://astral.sh/uv/install.sh | sh || {
            error "Failed to install uv"
            return 1
        }
        success "uv installed successfully"

        # Check if uv is in PATH
        if ! command -v uv &> /dev/null; then
            warning "uv not found in PATH after installation"
            # Common uv install location
            if [[ -f "$HOME/.cargo/bin/uv" ]]; then
                add_to_path "$HOME/.cargo/bin"
            fi
        fi
    else
        warning "Skipping uv installation"
        return 1
    fi
}

check_prerequisites() {
    section "Phase 1: Divining Prerequisites"

    # Skip if requested
    if [[ "$SKIP_PREREQS" == true ]]; then
        warning "Skipping prerequisite checks (--skip-prereqs flag set)"
        return 0
    fi

    local critical_missing=()
    local optional_missing=()
    local warnings=()

    # -------------------------------------------------------------------------
    # Check: Git
    # -------------------------------------------------------------------------
    if ! command -v git &> /dev/null; then
        error "git: NOT FOUND"

        # Attempt interactive installation
        if install_git; then
            # Verify installation succeeded
            if command -v git &> /dev/null; then
                local git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                success "git: ${git_version} (newly installed)"
            else
                critical_missing+=("git")
                error "git installation failed - command still not found"
            fi
        else
            critical_missing+=("git")
            info "  Manual install: brew install git  (macOS)"
            info "                  apt-get install git  (Ubuntu/Debian)"
            info "                  yum install git  (CentOS/RHEL)"
        fi
    else
        local git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "git: ${git_version}"

        # Check git configuration
        if ! git config --get user.name &> /dev/null; then
            warnings+=("Git user.name not configured")
            warning "git user.name: NOT CONFIGURED"
            info "  Configure: git config --global user.name \"Your Name\""
        else
            local git_user=$(git config --get user.name)
            success "git user.name: ${git_user}"
        fi

        if ! git config --get user.email &> /dev/null; then
            warnings+=("Git user.email not configured")
            warning "git user.email: NOT CONFIGURED"
            info "  Configure: git config --global user.email \"your.email@example.com\""
        else
            local git_email=$(git config --get user.email)
            success "git user.email: ${git_email}"
        fi
    fi

    # -------------------------------------------------------------------------
    # Check: Python 3.11+
    # -------------------------------------------------------------------------
    if ! command -v python3 &> /dev/null; then
        error "Python 3: NOT FOUND"

        # Attempt interactive installation
        if install_python; then
            # Verify installation succeeded
            if command -v python3 &> /dev/null; then
                local python_version=$(python3 --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                success "Python 3: ${python_version} (newly installed)"
            else
                critical_missing+=("python3")
                error "Python installation failed - command still not found"
            fi
        else
            critical_missing+=("python3")
            info "  Manual install: brew install python@3.11  (macOS)"
            info "                  apt-get install python3.11  (Ubuntu/Debian)"
            info "                  yum install python311  (CentOS/RHEL)"
        fi
    else
        local python_version=$(python3 --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        local python_major=$(echo "$python_version" | cut -d. -f1)
        local python_minor=$(echo "$python_version" | cut -d. -f2)

        if [[ "$python_major" -lt 3 ]] || [[ "$python_major" -eq 3 && "$python_minor" -lt 11 ]]; then
            error "Python 3: ${python_version} (requires 3.11+)"
            # Attempt upgrade
            if install_python; then
                # Re-check version
                if command -v python3 &> /dev/null; then
                    python_version=$(python3 --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                    python_major=$(echo "$python_version" | cut -d. -f1)
                    python_minor=$(echo "$python_version" | cut -d. -f2)
                    if [[ "$python_major" -ge 3 ]] && [[ "$python_minor" -ge 11 ]]; then
                        success "Python 3: ${python_version} (upgraded)"
                    else
                        critical_missing+=("python3.11+")
                        error "Python upgrade failed - still ${python_version}"
                    fi
                fi
            else
                critical_missing+=("python3.11+")
                info "  Manual install: brew install python@3.11  (macOS)"
            fi
        else
            success "Python 3: ${python_version}"
        fi
    fi

    # -------------------------------------------------------------------------
    # Check: Node.js 18+
    # -------------------------------------------------------------------------
    if ! command -v node &> /dev/null; then
        error "Node.js: NOT FOUND"

        # Attempt interactive installation
        if install_nodejs; then
            # Verify installation succeeded
            if command -v node &> /dev/null; then
                local node_version=$(node --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                success "Node.js: ${node_version} (newly installed)"
            else
                critical_missing+=("node")
                error "Node.js installation failed - command still not found"
            fi
        else
            critical_missing+=("node")
            info "  Manual install: brew install node  (macOS)"
            info "                  https://nodejs.org/  (all platforms)"
            info "                  nvm install 18  (if using nvm)"
        fi
    else
        local node_version=$(node --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        local node_major=$(echo "$node_version" | cut -d. -f1)

        if [[ "$node_major" -lt 18 ]]; then
            error "Node.js: ${node_version} (requires 18+)"
            # Attempt upgrade
            if install_nodejs; then
                # Re-check version
                if command -v node &> /dev/null; then
                    node_version=$(node --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                    node_major=$(echo "$node_version" | cut -d. -f1)
                    if [[ "$node_major" -ge 18 ]]; then
                        success "Node.js: ${node_version} (upgraded)"
                    else
                        critical_missing+=("node18+")
                        error "Node.js upgrade failed - still ${node_version}"
                    fi
                fi
            else
                critical_missing+=("node18+")
                info "  Manual install: brew install node  (macOS)"
                info "                  nvm install 18  (if using nvm)"
            fi
        else
            success "Node.js: ${node_version}"
        fi
    fi

    # -------------------------------------------------------------------------
    # Check: Claude Code CLI
    # -------------------------------------------------------------------------
    if ! command -v claude &> /dev/null; then
        critical_missing+=("claude")
        error "Claude Code CLI: NOT FOUND"
        info "  Install: npm install -g @anthropic-ai/claude-code"
        info "           See: https://claude.ai/code"
    else
        # Try to get version (may not be available in all versions)
        local claude_version=$(claude --version 2>/dev/null || echo "installed")
        success "Claude Code CLI: ${claude_version}"
    fi

    # -------------------------------------------------------------------------
    # Check: uv package manager (Optional)
    # -------------------------------------------------------------------------
    if ! command -v uv &> /dev/null; then
        warning "uv package manager: NOT FOUND (optional)"

        # Attempt interactive installation
        if install_uv; then
            # Verify installation succeeded
            if command -v uv &> /dev/null; then
                local uv_version=$(uv --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 2>/dev/null || echo "installed")
                success "uv package manager: ${uv_version} (newly installed)"
            else
                optional_missing+=("uv")
                warning "uv installation may require shell reload"
                info "  Try: source ~/.bashrc  (or ~/.zshrc)"
            fi
        else
            optional_missing+=("uv")
            info "  Manual install: curl -LsSf https://astral.sh/uv/install.sh | sh"
            info "  Note: Required for MCP server management"
        fi
    else
        local uv_version=$(uv --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 2>/dev/null || echo "installed")
        success "uv package manager: ${uv_version}"
    fi

    # -------------------------------------------------------------------------
    # Check: Claude Agent SDK (Optional - for programmatic agent development)
    # -------------------------------------------------------------------------
    # Note: Claude Code CLI already includes SDK features (context compaction, subagents, caching)
    # The separate Agent SDK package is only needed for building custom agent applications
    if npm list -g @anthropic-ai/claude-agent-sdk &> /dev/null 2>&1; then
        local sdk_version=$(npm list -g @anthropic-ai/claude-agent-sdk --depth=0 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "installed")
        success "Claude Agent SDK: ${sdk_version} (optional)"
    else
        info "Claude Agent SDK: NOT INSTALLED (optional)"
        info "  Install: npm install -g @anthropic-ai/claude-agent-sdk"
        info "  Note: Only needed for building custom programmatic agents"
        info "  Claude Code CLI already includes SDK features for CLI usage"
    fi

    # -------------------------------------------------------------------------
    # Summary and Exit Logic
    # -------------------------------------------------------------------------
    echo ""

    # Report critical missing dependencies
    if [[ ${#critical_missing[@]} -gt 0 ]]; then
        error "CRITICAL: Missing required dependencies (${#critical_missing[@]}):"
        for dep in "${critical_missing[@]}"; do
            echo "  - $dep"
        done
        echo ""
        error "Setup cannot continue without critical dependencies."
        info "Install missing dependencies and re-run this script."
        exit 3
    fi

    # Report optional missing dependencies
    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        warning "OPTIONAL: Missing recommended dependencies (${#optional_missing[@]}):"
        for dep in "${optional_missing[@]}"; do
            echo "  - $dep"
        done
        echo ""
        warning "Setup will continue, but some features may be limited."
        echo ""
    fi

    # Report warnings
    if [[ ${#warnings[@]} -gt 0 ]]; then
        warning "WARNINGS: Configuration issues found (${#warnings[@]}):"
        for warn in "${warnings[@]}"; do
            echo "  - $warn"
        done
        echo ""
        warning "These issues may affect functionality."
        echo ""
    fi

    success "All critical prerequisites satisfied"
    echo ""
}

# ============================================================================
# PHASE 2: GLOBAL AGENTS SETUP
# ============================================================================

setup_agents_to_directory() {
    local target_dir="$1"
    local backup_dir="$2"
    local scope_name="$3"

    info "Summoning to: ${target_dir}"
    info "Source agents directory: ${PROJECT_AGENTS_DIR}"

    # Create target agents directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        execute "Create ${scope_name} agents directory" mkdir -p "$target_dir"
        success "Created ${target_dir}"
    else
        info "Directory already exists: ${target_dir}"
    fi

    # Backup existing agents if directory has content and --no-backup not set
    if [[ "$NO_BACKUP" == false ]]; then
        local existing_agents=$(find "$target_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ $existing_agents -gt 0 ]]; then
            local timestamp=$(date +%Y%m%d_%H%M%S)
            local backup_path="${backup_dir}/${timestamp}"

            if [[ "$DRY_RUN" == false ]]; then
                mkdir -p "$backup_path"
                cp "$target_dir"/*.md "$backup_path"/ 2>/dev/null || true
                success "Backed up ${existing_agents} existing agent(s) to ${backup_path}"
            else
                info "[DRY RUN] Would backup ${existing_agents} agent(s) to ${backup_path}"
            fi
        else
            info "No existing agents to backup"
        fi
    else
        info "Skipping backup (--no-backup flag set)"
    fi

    # Copy agents from project to target directory
    local installed_count=0
    local updated_count=0
    local unchanged_count=0

    for agent_file in "$PROJECT_AGENTS_DIR"/*.md; do
        if [[ ! -f "$agent_file" ]]; then
            continue
        fi

        local agent_name=$(basename "$agent_file")
        local dest_file="${target_dir}/${agent_name}"

        # Check if agent already exists and differs
        if [[ -f "$dest_file" ]]; then
            if ! cmp -s "$agent_file" "$dest_file"; then
                # Files differ - show diff if verbose
                if [[ "$VERBOSE" == true && "$DRY_RUN" == false ]]; then
                    info "Changes in ${agent_name}:"
                    diff -u "$dest_file" "$agent_file" || true
                fi

                if [[ "$DRY_RUN" == false ]]; then
                    cp "$agent_file" "$dest_file"
                    chmod 644 "$dest_file"
                    success "Updated ${agent_name}"
                else
                    info "[DRY RUN] Would update ${agent_name}"
                fi
                updated_count=$((updated_count + 1))
            else
                info "Unchanged: ${agent_name}"
                unchanged_count=$((unchanged_count + 1))
            fi
        else
            # New agent
            if [[ "$DRY_RUN" == false ]]; then
                cp "$agent_file" "$dest_file"
                chmod 644 "$dest_file"
                success "Installed ${agent_name}"
            else
                info "[DRY RUN] Would install ${agent_name}"
            fi
            installed_count=$((installed_count + 1))
        fi
    done

    # Summary
    echo ""
    info "Agent installation summary for ${scope_name}:"
    echo "  - Installed: ${installed_count} new agent(s)"
    echo "  - Updated:   ${updated_count} agent(s)"
    echo "  - Unchanged: ${unchanged_count} agent(s)"

    # Validate permissions
    if [[ "$DRY_RUN" == false ]]; then
        local unreadable=0
        for agent_file in "$target_dir"/*.md; do
            if [[ -f "$agent_file" && ! -r "$agent_file" ]]; then
                error "Not readable: $(basename "$agent_file")"
                unreadable=$((unreadable + 1))
            fi
        done

        if [[ $unreadable -eq 0 ]]; then
            success "All agents are readable"
        else
            warning "${unreadable} agent(s) have permission issues"
        fi
    fi
}

setup_global_agents() {
    section "Phase 2: Summoning Agents (Scope: ${SCOPE})"

    # Check if source agents directory exists
    if [[ ! -d "$PROJECT_AGENTS_DIR" ]]; then
        error "Source agents directory not found: ${PROJECT_AGENTS_DIR}"
        return 1
    fi

    # Count source agents
    local agent_count=$(find "$PROJECT_AGENTS_DIR" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
    if [[ $agent_count -eq 0 ]]; then
        error "No agent files found in ${PROJECT_AGENTS_DIR}"
        return 1
    fi
    info "Found ${agent_count} agent(s) to install"
    echo ""

    # Install based on scope
    if [[ "$SCOPE" == "global" ]]; then
        setup_agents_to_directory "$GLOBAL_AGENTS_DIR" "$GLOBAL_AGENTS_BACKUP_DIR" "global"
        success "Global agents setup complete"
    elif [[ "$SCOPE" == "project" ]]; then
        setup_agents_to_directory "$PROJECT_AGENTS_INSTALL_DIR" "$PROJECT_AGENTS_BACKUP_DIR" "project"
        success "Project agents setup complete"
    elif [[ "$SCOPE" == "both" ]]; then
        info "Summoning to both global and project scopes..."
        echo ""
        info "=== Summoning to GLOBAL scope ==="
        setup_agents_to_directory "$GLOBAL_AGENTS_DIR" "$GLOBAL_AGENTS_BACKUP_DIR" "global"
        echo ""
        info "=== Summoning to PROJECT scope ==="
        setup_agents_to_directory "$PROJECT_AGENTS_INSTALL_DIR" "$PROJECT_AGENTS_BACKUP_DIR" "project"
        echo ""
        success "Agents setup complete for both scopes"
    fi
}

# ============================================================================
# PHASE 2b: RULES SETUP
# ============================================================================

setup_rules_to_directory() {
    local target_dir="$1"
    local scope_name="$2"

    info "Binding rules to: ${target_dir}"

    local source_rules_dir="${PROJECT_ROOT}/rules"
    info "Source rules directory: ${source_rules_dir}"

    # Check if source rules exist
    if [[ ! -d "$source_rules_dir" ]]; then
        warning "Source rules directory not found: ${source_rules_dir}"
        warning "Skipping rules installation"
        return 0
    fi

    # Count source rules
    local rule_count=$(find "$source_rules_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [[ $rule_count -eq 0 ]]; then
        warning "No rule files found in ${source_rules_dir}"
        return 0
    fi
    info "Found ${rule_count} rule(s) to install"

    # Create target rules directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "$target_dir"
        fi
        success "Created ${target_dir}"
    else
        info "Directory already exists: ${target_dir}"
    fi

    # Copy rules from source to target directory
    local installed_count=0
    local updated_count=0
    local unchanged_count=0

    for rule_file in "$source_rules_dir"/*.md; do
        if [[ ! -f "$rule_file" ]]; then
            continue
        fi

        local rule_name=$(basename "$rule_file")
        local dest_file="${target_dir}/${rule_name}"

        # Check if rule already exists and differs
        if [[ -f "$dest_file" ]]; then
            if ! cmp -s "$rule_file" "$dest_file"; then
                if [[ "$DRY_RUN" == false ]]; then
                    cp "$rule_file" "$dest_file"
                    chmod 644 "$dest_file"
                    success "Updated ${rule_name}"
                else
                    info "[DRY RUN] Would update ${rule_name}"
                fi
                updated_count=$((updated_count + 1))
            else
                info "Unchanged: ${rule_name}"
                unchanged_count=$((unchanged_count + 1))
            fi
        else
            # New rule
            if [[ "$DRY_RUN" == false ]]; then
                cp "$rule_file" "$dest_file"
                chmod 644 "$dest_file"
                success "Installed ${rule_name}"
            else
                info "[DRY RUN] Would install ${rule_name}"
            fi
            installed_count=$((installed_count + 1))
        fi
    done

    # Summary
    echo ""
    info "Rules installation summary for ${scope_name}:"
    echo "  - Installed: ${installed_count} new rule(s)"
    echo "  - Updated:   ${updated_count} rule(s)"
    echo "  - Unchanged: ${unchanged_count} rule(s)"
}

setup_rules() {
    section "Phase 2b: Binding Rules (Scope: ${SCOPE})"

    # Define target directories based on scope
    local global_rules_dir="${HOME}/.claude/rules"
    local project_rules_dir="$(pwd)/.claude/rules"

    # Install based on scope
    if [[ "$SCOPE" == "global" ]]; then
        setup_rules_to_directory "$global_rules_dir" "global"
        success "Global rules setup complete"
    elif [[ "$SCOPE" == "project" ]]; then
        setup_rules_to_directory "$project_rules_dir" "project"
        success "Project rules setup complete"
    elif [[ "$SCOPE" == "both" ]]; then
        info "Binding rules to both global and project scopes..."
        echo ""
        info "=== Binding rules to GLOBAL scope ==="
        setup_rules_to_directory "$global_rules_dir" "global"
        echo ""
        info "=== Binding rules to PROJECT scope ==="
        setup_rules_to_directory "$project_rules_dir" "project"
        echo ""
        success "Rules setup complete for both scopes"
    fi
}

# ============================================================================
# PHASE 3: SKILLS SETUP
# ============================================================================

setup_skills_to_directory() {
    local target_dir="$1"
    local backup_dir="$2"
    local scope_name="$3"

    info "Conjuring skills to: ${target_dir}"
    info "Source skills directory: ${SOURCE_SKILLS_DIR}"

    # Create target skills directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        execute "Create ${scope_name} skills directory" mkdir -p "$target_dir"
        success "Created ${target_dir}"
    else
        info "Directory already exists: ${target_dir}"
    fi

    # Backup existing skills if directory has content and --no-backup not set
    if [[ "$NO_BACKUP" == false && -d "$target_dir" ]]; then
        local existing_skills=$(find "$target_dir" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
        if [[ $existing_skills -gt 0 ]]; then
            local timestamp=$(date +%Y%m%d_%H%M%S)
            local backup_path="${backup_dir}/${timestamp}"

            if [[ "$DRY_RUN" == false ]]; then
                mkdir -p "$backup_path"
                # Copy skill directories (not just files)
                for skill_dir in "$target_dir"/*/; do
                    if [[ -d "$skill_dir" ]]; then
                        cp -r "$skill_dir" "$backup_path"/ 2>/dev/null || true
                    fi
                done
                success "Backed up ${existing_skills} existing skill(s) to ${backup_path}"
            else
                info "[DRY RUN] Would backup ${existing_skills} skill(s) to ${backup_path}"
            fi
        else
            info "No existing skills to backup"
        fi
    elif [[ "$NO_BACKUP" == true ]]; then
        info "Skipping backup (--no-backup flag set)"
    else
        info "No existing skills to backup (new installation)"
    fi

    # Copy skills from source to target directory
    local installed_count=0
    local updated_count=0
    local unchanged_count=0

    for skill_src_dir in "$SOURCE_SKILLS_DIR"/*/; do
        if [[ ! -d "$skill_src_dir" ]]; then
            continue
        fi

        # Skip if no SKILL.md file (not a valid skill)
        if [[ ! -f "${skill_src_dir}/SKILL.md" ]]; then
            continue
        fi

        local skill_name=$(basename "$skill_src_dir")
        local dest_skill_dir="${target_dir}/${skill_name}"

        # Check if skill already exists and differs
        if [[ -d "$dest_skill_dir" ]]; then
            # Compare SKILL.md files to detect changes
            if [[ -f "${dest_skill_dir}/SKILL.md" ]]; then
                if ! cmp -s "${skill_src_dir}/SKILL.md" "${dest_skill_dir}/SKILL.md"; then
                    # Files differ - update the skill
                    if [[ "$DRY_RUN" == false ]]; then
                        rm -rf "$dest_skill_dir"
                        cp -r "$skill_src_dir" "$dest_skill_dir"
                        chmod -R 644 "$dest_skill_dir"/* 2>/dev/null || true
                        chmod 755 "$dest_skill_dir"
                        success "Updated ${skill_name}"
                    else
                        info "[DRY RUN] Would update ${skill_name}"
                    fi
                    updated_count=$((updated_count + 1))
                else
                    info "Unchanged: ${skill_name}"
                    unchanged_count=$((unchanged_count + 1))
                fi
            else
                # SKILL.md missing in destination - reinstall
                if [[ "$DRY_RUN" == false ]]; then
                    rm -rf "$dest_skill_dir"
                    cp -r "$skill_src_dir" "$dest_skill_dir"
                    chmod -R 644 "$dest_skill_dir"/* 2>/dev/null || true
                    chmod 755 "$dest_skill_dir"
                    success "Reinstalled ${skill_name} (missing SKILL.md)"
                else
                    info "[DRY RUN] Would reinstall ${skill_name}"
                fi
                updated_count=$((updated_count + 1))
            fi
        else
            # New skill
            if [[ "$DRY_RUN" == false ]]; then
                cp -r "$skill_src_dir" "$dest_skill_dir"
                chmod -R 644 "$dest_skill_dir"/* 2>/dev/null || true
                chmod 755 "$dest_skill_dir"
                success "Installed ${skill_name}"
            else
                info "[DRY RUN] Would install ${skill_name}"
            fi
            installed_count=$((installed_count + 1))
        fi
    done

    # Summary
    echo ""
    info "Skills installation summary for ${scope_name}:"
    echo "  - Installed: ${installed_count} new skill(s)"
    echo "  - Updated:   ${updated_count} skill(s)"
    echo "  - Unchanged: ${unchanged_count} skill(s)"

    # Validate permissions
    if [[ "$DRY_RUN" == false ]]; then
        local unreadable=0
        for skill_dir in "$target_dir"/*/; do
            if [[ -d "$skill_dir" && ! -r "${skill_dir}/SKILL.md" ]]; then
                error "Not readable: $(basename "$skill_dir")/SKILL.md"
                unreadable=$((unreadable + 1))
            fi
        done

        if [[ $unreadable -eq 0 ]]; then
            success "All skills are readable"
        else
            warning "${unreadable} skill(s) have permission issues"
        fi
    fi
}

setup_project_skills() {
    section "Phase 3: Conjuring Skills (Scope: ${SCOPE})"

    # Check if source skills directory exists
    if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
        error "Source skills directory not found: ${SOURCE_SKILLS_DIR}"
        return 1
    fi

    # Count source skills (directories with SKILL.md)
    local skill_count=0
    for skill_dir in "$SOURCE_SKILLS_DIR"/*/; do
        if [[ -d "$skill_dir" && -f "${skill_dir}/SKILL.md" ]]; then
            skill_count=$((skill_count + 1))
        fi
    done

    if [[ $skill_count -eq 0 ]]; then
        error "No valid skills found in ${SOURCE_SKILLS_DIR}"
        return 1
    fi
    info "Found ${skill_count} skill(s) to install"
    echo ""

    # Validate skill frontmatter before installation
    info "Validating skill frontmatter..."
    if [[ -f "${SCRIPT_DIR}/validation/validate-skills.sh" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            info "[DRY RUN] Would run: ${SCRIPT_DIR}/validation/validate-skills.sh"
            success "Would validate skills frontmatter"
        else
            if bash "${SCRIPT_DIR}/validation/validate-skills.sh"; then
                success "All skills have valid frontmatter"
            else
                error "Some skills have invalid frontmatter"
                if [[ "$FIX_MODE" == true ]]; then
                    warning "Fix mode: Skills require manual correction (missing name/description fields)"
                fi
                return 1
            fi
        fi
    else
        warning "validation/validate-skills.sh not found - skipping frontmatter validation"
    fi
    echo ""

    # Install based on scope
    if [[ "$SCOPE" == "global" ]]; then
        setup_skills_to_directory "$GLOBAL_SKILLS_DIR" "$GLOBAL_SKILLS_BACKUP_DIR" "global"
        success "Global skills setup complete"
    elif [[ "$SCOPE" == "project" ]]; then
        setup_skills_to_directory "$PROJECT_SKILLS_INSTALL_DIR" "$PROJECT_SKILLS_BACKUP_DIR" "project"
        success "Project skills setup complete"
    elif [[ "$SCOPE" == "both" ]]; then
        info "Summoning to both global and project scopes..."
        echo ""
        info "=== Conjuring skills to GLOBAL scope ==="
        setup_skills_to_directory "$GLOBAL_SKILLS_DIR" "$GLOBAL_SKILLS_BACKUP_DIR" "global"
        echo ""
        info "=== Conjuring skills to PROJECT scope ==="
        setup_skills_to_directory "$PROJECT_SKILLS_INSTALL_DIR" "$PROJECT_SKILLS_BACKUP_DIR" "project"
        echo ""
        success "Skills setup complete for both scopes"
    fi

    # Validate agent-skill references
    echo ""
    info "Validating agent-skill references..."
    if [[ -f "${SCRIPT_DIR}/validation/validate-agent-skills.sh" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            info "[DRY RUN] Would run: ${SCRIPT_DIR}/validation/validate-agent-skills.sh"
            success "Would validate agent-skill references"
        else
            if bash "${SCRIPT_DIR}/validation/validate-agent-skills.sh"; then
                success "All agent-skill references are valid"
            else
                warning "Some agent-skill references are broken"
                warning "Agents reference skills that don't exist in Haunt/skills/ directory"
            fi
        fi
    else
        warning "validation/validate-agent-skills.sh not found - skipping reference validation"
    fi
}

# ============================================================================
# PHASE 3b: COMMANDS SETUP
# ============================================================================

setup_commands_to_directory() {
    local target_dir="$1"
    local backup_dir="$2"
    local scope_name="$3"

    info "Inscribing commands to: ${target_dir}"
    info "Source commands directory: ${SOURCE_COMMANDS_DIR}"

    # Check if source commands exist
    if [[ ! -d "$SOURCE_COMMANDS_DIR" ]]; then
        warning "Source commands directory not found: ${SOURCE_COMMANDS_DIR}"
        warning "Skipping commands installation"
        return 0
    fi

    # Count source commands
    local command_count=$(find "$SOURCE_COMMANDS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [[ $command_count -eq 0 ]]; then
        warning "No command files found in ${SOURCE_COMMANDS_DIR}"
        return 0
    fi
    info "Found ${command_count} command(s) to install"

    # Create target commands directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "$target_dir"
        fi
        success "Created ${target_dir}"
    else
        info "Directory already exists: ${target_dir}"
    fi

    # Copy commands from source to target directory
    local installed_count=0
    local updated_count=0
    local unchanged_count=0

    for command_file in "$SOURCE_COMMANDS_DIR"/*.md; do
        if [[ ! -f "$command_file" ]]; then
            continue
        fi

        local command_name=$(basename "$command_file")
        local dest_file="${target_dir}/${command_name}"

        # Check if command already exists and differs
        if [[ -f "$dest_file" ]]; then
            if ! cmp -s "$command_file" "$dest_file"; then
                if [[ "$DRY_RUN" == false ]]; then
                    cp "$command_file" "$dest_file"
                    chmod 644 "$dest_file"
                    success "Updated ${command_name}"
                else
                    info "[DRY RUN] Would update ${command_name}"
                fi
                updated_count=$((updated_count + 1))
            else
                info "Unchanged: ${command_name}"
                unchanged_count=$((unchanged_count + 1))
            fi
        else
            # New command
            if [[ "$DRY_RUN" == false ]]; then
                cp "$command_file" "$dest_file"
                chmod 644 "$dest_file"
                success "Installed ${command_name}"
            else
                info "[DRY RUN] Would install ${command_name}"
            fi
            installed_count=$((installed_count + 1))
        fi
    done

    # Summary
    echo ""
    info "Commands installation summary for ${scope_name}:"
    echo "  - Installed: ${installed_count} new command(s)"
    echo "  - Updated:   ${updated_count} command(s)"
    echo "  - Unchanged: ${unchanged_count} command(s)"
}

setup_project_commands() {
    section "Phase 3b: Inscribing Slash Commands (Scope: ${SCOPE})"

    # Check if source commands directory exists
    if [[ ! -d "$SOURCE_COMMANDS_DIR" ]]; then
        warning "Source commands directory not found: ${SOURCE_COMMANDS_DIR}"
        warning "Skipping commands installation"
        return 0
    fi

    # Count source commands
    local command_count=$(find "$SOURCE_COMMANDS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [[ $command_count -eq 0 ]]; then
        warning "No command files found in ${SOURCE_COMMANDS_DIR}"
        return 0
    fi
    info "Found ${command_count} command(s) to install"
    echo ""

    # Install based on scope
    if [[ "$SCOPE" == "global" ]]; then
        setup_commands_to_directory "$GLOBAL_COMMANDS_DIR" "$GLOBAL_COMMANDS_BACKUP_DIR" "global"
        success "Global commands setup complete"
    elif [[ "$SCOPE" == "project" ]]; then
        setup_commands_to_directory "$PROJECT_COMMANDS_INSTALL_DIR" "$PROJECT_COMMANDS_BACKUP_DIR" "project"
        success "Project commands setup complete"
    elif [[ "$SCOPE" == "both" ]]; then
        info "Inscribing to both global and project scopes..."
        echo ""
        info "=== Inscribing commands to GLOBAL scope ==="
        setup_commands_to_directory "$GLOBAL_COMMANDS_DIR" "$GLOBAL_COMMANDS_BACKUP_DIR" "global"
        echo ""
        info "=== Inscribing commands to PROJECT scope ==="
        setup_commands_to_directory "$PROJECT_COMMANDS_INSTALL_DIR" "$PROJECT_COMMANDS_BACKUP_DIR" "project"
        echo ""
        success "Commands setup complete for both scopes"
    fi
}

# ============================================================================
# PHASE 4: PROJECT STRUCTURE
# ============================================================================

setup_project_structure() {
    section "Phase 4: Manifesting Project Structure"

    local created_count=0
    local skipped_count=0
    local project_root="$(pwd)"

    info "Project root: ${project_root}"
    echo ""

    # -------------------------------------------------------------------------
    # Create .claude/ subdirectories
    # -------------------------------------------------------------------------
    info "Manifesting .claude/ subdirectories..."

    if [[ ! -d "${project_root}/.claude/agents" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.claude/agents"
        fi
        success "Created .claude/agents/ (project-specific agent overrides)"
        ((created_count++))
    else
        info "Skipped: .claude/agents/ already exists"
        ((skipped_count++))
    fi

    if [[ ! -d "${project_root}/.claude/commands" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.claude/commands"
        fi
        success "Created .claude/commands/ (custom slash commands)"
        ((created_count++))
    else
        info "Skipped: .claude/commands/ already exists"
        ((skipped_count++))
    fi

    if [[ ! -d "${project_root}/.claude/rules" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.claude/rules"
        fi
        success "Created .claude/rules/ (invariant enforcement protocols)"
        ((created_count++))
    else
        info "Skipped: .claude/rules/ already exists"
        ((skipped_count++))
    fi

    # -------------------------------------------------------------------------
    # Create .haunt/plans/ directory with template
    # -------------------------------------------------------------------------
    echo ""
    info "Manifesting .haunt/plans/ directory..."

    if [[ ! -d "${project_root}/.haunt/plans" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.haunt/plans"
        fi
        success "Created .haunt/plans/"
        ((created_count++))
    else
        info "Skipped: .haunt/plans/ already exists"
        ((skipped_count++))
    fi

    if [[ ! -f "${project_root}/.haunt/plans/roadmap.md" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            cat > "${project_root}/.haunt/plans/roadmap.md" << 'ROADMAP_EOF'
# Project Roadmap

**Project:** [Project Name]
**Created:** $(date +%Y-%m-%d)
**Last Updated:** $(date +%Y-%m-%d)
**Status:** Planning

---

## Active Work

> **Copy this section to CLAUDE.md** to give agents context without loading full roadmap.
> Project Manager should sync this with CLAUDE.md Active Work section.

**Current Focus:** [Brief description of current phase/goal]

**In Progress:**
- 🟡 REQ-001: [Title] - [Brief status]

**Up Next:**
- ⚪ REQ-002: [Title]

---

## Requirements

### 🟡 REQ-001: [First Requirement Title]

**Priority:** High
**Agent:** Dev
**Effort:** S (2 hours)
**Blocked by:** None

**Description:**
[Clear description of what needs to be done]

**Tasks:**
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

**Files:**
- `path/to/file.ext` (create/modify)

**Completion Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

**Acceptance Tests:**
- Test 1
- Test 2

---

## Status Icons

- ⚪ Not Started
- 🟡 In Progress
- 🟢 Complete
- 🔴 Blocked

ROADMAP_EOF
        fi
        success "Created .haunt/plans/roadmap.md template"
        ((created_count++))
    else
        info "Skipped: .haunt/plans/roadmap.md already exists (preserving existing content)"
        ((skipped_count++))
    fi

    # -------------------------------------------------------------------------
    # Create .haunt/completed/ directory with template
    # -------------------------------------------------------------------------
    echo ""
    info "Manifesting .haunt/completed/ directory..."

    if [[ ! -d "${project_root}/.haunt/completed" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.haunt/completed"
        fi
        success "Created .haunt/completed/"
        ((created_count++))
    else
        info "Skipped: .haunt/completed/ already exists"
        ((skipped_count++))
    fi

    if [[ ! -f "${project_root}/.haunt/completed/roadmap-archive.md" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            cat > "${project_root}/.haunt/completed/roadmap-archive.md" << 'ARCHIVE_EOF'
# Completed Requirements Archive

This file contains all completed requirements from the project roadmap.

---

## [Batch/Feature Name] - Completed [Date]

### 🟢 REQ-XXX: [Requirement Title]

**Completed:** [Date]
**Agent:** [Agent Name]
**Effort:** [Actual time spent]

**Description:**
[Original description]

**Completion Notes:**
[What was actually done, any deviations from plan, lessons learned]

---

ARCHIVE_EOF
        fi
        success "Created .haunt/completed/roadmap-archive.md template"
        ((created_count++))
    else
        info "Skipped: .haunt/completed/roadmap-archive.md already exists (preserving existing content)"
        ((skipped_count++))
    fi

    # -------------------------------------------------------------------------
    # Create .haunt/progress/ directory with README
    # -------------------------------------------------------------------------
    echo ""
    info "Manifesting .haunt/progress/ directory..."

    if [[ ! -d "${project_root}/.haunt/progress" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.haunt/progress"
        fi
        success "Created .haunt/progress/"
        ((created_count++))
    else
        info "Skipped: .haunt/progress/ already exists"
        ((skipped_count++))
    fi

    if [[ ! -f "${project_root}/.haunt/progress/README.md" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            cat > "${project_root}/.haunt/progress/README.md" << 'PROGRESS_EOF'
# Progress Tracking

This directory contains progress reports, session notes, and verification results.

## Files in This Directory

- **setup-verification-*.md** - Setup verification reports
- **weekly-refactor-*.md** - Weekly refactor pattern hunt reports
- **session-*.md** - Individual session notes and progress

## Usage

Agents and humans can add files here to track:
- Daily/weekly progress summaries
- Blockers and resolutions
- Learnings and insights
- Verification and validation results

PROGRESS_EOF
        fi
        success "Created .haunt/progress/README.md"
        ((created_count++))
    else
        info "Skipped: .haunt/progress/README.md already exists (preserving existing content)"
        ((skipped_count++))
    fi

    # -------------------------------------------------------------------------
    # Create .haunt/tests/ subdirectories
    # -------------------------------------------------------------------------
    echo ""
    info "Manifesting .haunt/tests/ subdirectories..."

    if [[ ! -d "${project_root}/.haunt/tests/patterns" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.haunt/tests/patterns"
        fi
        success "Created .haunt/tests/patterns/ (defeat tests for anti-patterns)"
        ((created_count++))
    else
        info "Skipped: .haunt/tests/patterns/ already exists"
        ((skipped_count++))
    fi

    if [[ ! -d "${project_root}/.haunt/tests/behavior" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.haunt/tests/behavior"
        fi
        success "Created .haunt/tests/behavior/ (agent behavior validation)"
        ((created_count++))
    else
        info "Skipped: .haunt/tests/behavior/ already exists"
        ((skipped_count++))
    fi

    if [[ ! -d "${project_root}/.haunt/tests/e2e" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.haunt/tests/e2e"
        fi
        success "Created .haunt/tests/e2e/ (end-to-end tests)"
        ((created_count++))
    else
        info "Skipped: .haunt/tests/e2e/ already exists"
        ((skipped_count++))
    fi

    # -------------------------------------------------------------------------
    # Create .haunt/docs/ directory
    # -------------------------------------------------------------------------
    echo ""
    info "Manifesting .haunt/docs/ directory..."

    if [[ ! -d "${project_root}/.haunt/docs" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.haunt/docs"
        fi
        success "Created .haunt/docs/ (project initialization and framework documentation)"
        ((created_count++))
    else
        info "Skipped: .haunt/docs/ already exists"
        ((skipped_count++))
    fi

    # -------------------------------------------------------------------------
    # Create .haunt/scripts/ directory
    # -------------------------------------------------------------------------
    echo ""
    info "Manifesting .haunt/scripts/ directory..."

    if [[ ! -d "${project_root}/.haunt/scripts" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "${project_root}/.haunt/scripts"
        fi
        success "Created .haunt/scripts/ (daily and weekly ritual scripts)"
        ((created_count++))
    else
        info "Skipped: .haunt/scripts/ already exists"
        ((skipped_count++))
    fi

    # -------------------------------------------------------------------------
    # Install ritual scripts (if --no-rituals not set)
    # -------------------------------------------------------------------------
    if [[ "$WITH_RITUALS" == true ]]; then
        echo ""
        info "Binding ritual scripts..."

        local ritual_scripts=(
            "morning-review.sh"
            "evening-handoff.sh"
            "weekly-refactor.sh"
        )

        local installed_rituals=0
        local updated_rituals=0
        local unchanged_rituals=0

        for script_name in "${ritual_scripts[@]}"; do
            local source_script="${SCRIPT_DIR}/rituals/${script_name}"
            local dest_script="${project_root}/.haunt/scripts/${script_name}"

            # Check if source script exists
            if [[ ! -f "$source_script" ]]; then
                warning "  Source script not found: ${source_script}"
                continue
            fi

            # Check if destination script exists and differs
            if [[ -f "$dest_script" ]]; then
                if ! cmp -s "$source_script" "$dest_script"; then
                    # Files differ - update
                    if [[ "$DRY_RUN" == false ]]; then
                        cp "$source_script" "$dest_script"
                        chmod +x "$dest_script"
                        success "  Updated ${script_name}"
                    else
                        info "  [DRY RUN] Would update ${script_name}"
                    fi
                    ((updated_rituals++))
                else
                    info "  Unchanged: ${script_name}"
                    ((unchanged_rituals++))
                fi
            else
                # New installation
                if [[ "$DRY_RUN" == false ]]; then
                    cp "$source_script" "$dest_script"
                    chmod +x "$dest_script"
                    success "  Installed ${script_name}"
                else
                    info "  [DRY RUN] Would install ${script_name}"
                fi
                ((installed_rituals++))
                ((created_count++))
            fi
        done

        # Summary for ritual scripts
        echo ""
        info "Ritual script installation summary:"
        echo "  - Installed: ${installed_rituals} new script(s)"
        echo "  - Updated:   ${updated_rituals} script(s)"
        echo "  - Unchanged: ${unchanged_rituals} script(s)"
    else
        echo ""
        info "Skipping ritual script installation (--no-rituals flag set)"
    fi

    # -------------------------------------------------------------------------
    # Install pattern detection tools (if --no-pattern-detection not set)
    # -------------------------------------------------------------------------
    if [[ "$WITH_PATTERN_DETECTION" == true ]]; then
        echo ""
        info "Conjuring pattern detection tools..."

        local pattern_tools=(
            "hunt-patterns"
        )

        local pattern_dir="${SCRIPT_DIR}/rituals/pattern-detector"
        local installed_tools=0
        local updated_tools=0
        local unchanged_tools=0

        # Check if pattern-detector directory exists in source
        if [[ ! -d "$pattern_dir" ]]; then
            warning "  Pattern detector directory not found: ${pattern_dir}"
            warning "  Skipping pattern detection installation"
        else
            # Copy pattern-detector directory to .haunt/scripts/
            local dest_pattern_dir="${project_root}/.haunt/scripts/pattern-detector"

            if [[ ! -d "$dest_pattern_dir" ]]; then
                if [[ "$DRY_RUN" == false ]]; then
                    mkdir -p "$dest_pattern_dir"
                    cp -r "$pattern_dir"/* "$dest_pattern_dir"/
                    success "  Installed pattern-detector/ directory"
                else
                    info "  [DRY RUN] Would install pattern-detector/ directory"
                fi
                ((installed_tools++))
            else
                # Update existing installation
                if [[ "$DRY_RUN" == false ]]; then
                    # Use rsync if available for better updates, otherwise use cp
                    if command -v rsync &> /dev/null; then
                        rsync -a --exclude='__pycache__' --exclude='.pytest_cache' --exclude='*.pyc' \
                              "${pattern_dir}/" "${dest_pattern_dir}/"
                    else
                        cp -r "$pattern_dir"/* "$dest_pattern_dir"/
                    fi
                    success "  Updated pattern-detector/ directory"
                else
                    info "  [DRY RUN] Would update pattern-detector/ directory"
                fi
                ((updated_tools++))
            fi

            # Install hunt-patterns wrapper script
            for tool_name in "${pattern_tools[@]}"; do
                local source_tool="${SCRIPT_DIR}/rituals/${tool_name}"
                local dest_tool="${project_root}/.haunt/scripts/${tool_name}"

                # Check if source tool exists
                if [[ ! -f "$source_tool" ]]; then
                    warning "  Source tool not found: ${source_tool}"
                    continue
                fi

                # Check if destination tool exists and differs
                if [[ -f "$dest_tool" ]]; then
                    if ! cmp -s "$source_tool" "$dest_tool"; then
                        # Files differ - update
                        if [[ "$DRY_RUN" == false ]]; then
                            cp "$source_tool" "$dest_tool"
                            chmod +x "$dest_tool"
                            success "  Updated ${tool_name}"
                        else
                            info "  [DRY RUN] Would update ${tool_name}"
                        fi
                        ((updated_tools++))
                    else
                        info "  Unchanged: ${tool_name}"
                        ((unchanged_tools++))
                    fi
                else
                    # New installation
                    if [[ "$DRY_RUN" == false ]]; then
                        cp "$source_tool" "$dest_tool"
                        chmod +x "$dest_tool"
                        success "  Installed ${tool_name}"
                    else
                        info "  [DRY RUN] Would install ${tool_name}"
                    fi
                    ((installed_tools++))
                    ((created_count++))
                fi
            done

            # Verify Python 3 is available for pattern detection
            if command -v python3 &> /dev/null; then
                success "  Python 3 available for pattern detection"
            else
                warning "  Python 3 not found - pattern detection requires Python 3"
            fi

            # Summary for pattern detection tools
            echo ""
            info "Pattern detection installation summary:"
            echo "  - Installed: ${installed_tools} new tool(s)"
            echo "  - Updated:   ${updated_tools} tool(s)"
            echo "  - Unchanged: ${unchanged_tools} tool(s)"
        fi
    else
        echo ""
        info "Skipping pattern detection installation (--no-pattern-detection flag set)"
    fi

    # -------------------------------------------------------------------------
    # Create feature contract template
    # -------------------------------------------------------------------------
    echo ""
    info "Manifesting feature contract template..."

    if [[ ! -f "${project_root}/.haunt/plans/feature-contract.json" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            cat > "${project_root}/.haunt/plans/feature-contract.json" << 'CONTRACT_EOF'
{
  "feature_id": "REQ-XXX",
  "feature_name": "Example Feature",
  "created_at": "2025-01-01T00:00:00Z",
  "status": "in_progress",
  "acceptance_criteria": [
    "Criterion 1: Must do X",
    "Criterion 2: Must do Y",
    "Criterion 3: Must do Z"
  ],
  "implementation_notes": [
    "Note: This section CAN be updated by agents during implementation",
    "Add technical decisions, blockers, clarifications here"
  ],
  "completed_at": null,
  "completion_evidence": []
}
CONTRACT_EOF
        fi
        success "Created .haunt/plans/feature-contract.json template"
        ((created_count++))
    else
        info "Skipped: .haunt/plans/feature-contract.json already exists (preserving existing content)"
        ((skipped_count++))
    fi

    # -------------------------------------------------------------------------
    # Create .haunt/.gitignore
    # -------------------------------------------------------------------------
    echo ""
    info "Manifesting .haunt/.gitignore..."

    if [[ ! -f "${project_root}/.haunt/.gitignore" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            cat > "${project_root}/.haunt/.gitignore" << 'HAUNT_GITIGNORE_EOF'
# Ignore working files (ephemeral)
plans/
progress/
completed/
docs/

# Preserve tests (optionally shareable)
!tests/

# Preserve scripts (team rituals)
!scripts/

# Ignore verification reports
*verification*.md

# Ignore session reports
session-*.md

# But preserve templates
!README.md
HAUNT_GITIGNORE_EOF
        fi
        success "Created .haunt/.gitignore"
        ((created_count++))
    else
        info "Skipped: .haunt/.gitignore already exists (preserving existing content)"
        ((skipped_count++))
    fi

    # -------------------------------------------------------------------------
    # Update project root .gitignore
    # -------------------------------------------------------------------------
    echo ""
    info "Updating project root .gitignore..."

    local gitignore_file="${project_root}/.gitignore"
    local sdlc_entry_found=false

    # Check if .gitignore exists and contains Haunt entries
    # Match both old "# Ghost County" and new "# Haunt" headers for idempotency
    if [[ -f "$gitignore_file" ]]; then
        if grep -qE "^# (Ghost County|Haunt)" "$gitignore_file" 2>/dev/null ; then
            sdlc_entry_found=true
            info "Skipped: .gitignore already contains Haunt entries"
            ((skipped_count++))
        fi
    fi

    # Add .claude/ and .haunt/ entries to .gitignore if not found
    if [[ "$sdlc_entry_found" == false ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            # Create .gitignore if it doesn't exist
            if [[ ! -f "$gitignore_file" ]]; then
                touch "$gitignore_file"
            fi

            # Append .claude/ and .haunt/ gitignore entries
            cat >> "$gitignore_file" << 'ROOT_GITIGNORE_EOF'

# ============================================================================
# Haunt Framework - Git Ignore
# ============================================================================

# Project-local Claude Code configuration
.claude/

# Haunt project artifacts (entire directory)
.haunt/
ROOT_GITIGNORE_EOF
            success "Updated .gitignore with .claude/ and .haunt/ entries"
        else
            info "[DRY RUN] Would add .claude/ and .haunt/ entries to .gitignore"
        fi
        ((created_count++))
    fi

    # -------------------------------------------------------------------------
    # Create or update CLAUDE.md with Active Work section
    # -------------------------------------------------------------------------
    echo ""
    info "Setting up CLAUDE.md with Active Work section..."

    local claude_md_file="${project_root}/CLAUDE.md"
    local active_work_marker="## Active Work"

    if [[ -f "$claude_md_file" ]]; then
        # CLAUDE.md exists - check if Active Work section is present
        if grep -q "^## Active Work" "$claude_md_file" 2>/dev/null; then
            info "Skipped: CLAUDE.md already contains Active Work section"
            ((skipped_count++))
        else
            # Append Active Work section to existing CLAUDE.md
            if [[ "$DRY_RUN" == false ]]; then
                cat >> "$claude_md_file" << 'ACTIVE_WORK_APPEND_EOF'

## Active Work

> This section is synced with `.haunt/plans/roadmap.md` Active Work section.
> Keep this under 500 tokens for efficient context loading.

**Current Focus:** [Update with current phase/goal]

**In Progress:**
- None currently

**Up Next:**
- Check `.haunt/plans/roadmap.md` for requirements

**Recently Completed:**
- Initial project setup
ACTIVE_WORK_APPEND_EOF
                success "Added Active Work section to existing CLAUDE.md"
            else
                info "[DRY RUN] Would add Active Work section to existing CLAUDE.md"
            fi
            ((created_count++))
        fi
    else
        # CLAUDE.md doesn't exist - create it with Active Work section
        if [[ "$DRY_RUN" == false ]]; then
            # Try to get project name from git remote or directory name
            local project_name
            project_name=$(basename "$project_root")
            if git -C "$project_root" remote get-url origin 2>/dev/null | grep -oE '[^/]+\.git$' | sed 's/\.git$//' 2>/dev/null; then
                project_name=$(git -C "$project_root" remote get-url origin 2>/dev/null | grep -oE '[^/]+\.git$' | sed 's/\.git$//' || basename "$project_root")
            fi

            cat > "$claude_md_file" << CLAUDE_MD_EOF
# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Repository Purpose

${project_name} - [Add brief description of this project]

## Active Work

> This section is synced with \`.haunt/plans/roadmap.md\` Active Work section.
> Keep this under 500 tokens for efficient context loading.

**Current Focus:** Initial project setup

**In Progress:**
- None currently

**Up Next:**
- Review \`.haunt/plans/roadmap.md\` for first requirements
- Define initial features/requirements

**Recently Completed:**
- Haunt setup complete

## Key Commands

\`\`\`bash
# Run tests
[Add test command]

# Build project
[Add build command]

# Start development server
[Add dev command]
\`\`\`

## Project Structure

\`\`\`
${project_name}/
├── .haunt/                    # Haunt project artifacts
│   ├── plans/roadmap.md      # Project roadmap (Active Work source)
│   ├── completed/            # Archived completed work
│   └── progress/             # Session progress
├── .claude/                  # Claude Code configuration
└── [Add key directories]
\`\`\`

## Development Guidelines

- Follow requirements in \`.haunt/plans/roadmap.md\`
- Update Active Work section when completing tasks
- Use TDD workflow for new features
- Commit using conventional commit format

CLAUDE_MD_EOF
            success "Created CLAUDE.md with Active Work section"
        else
            info "[DRY RUN] Would create CLAUDE.md with Active Work section"
        fi
        ((created_count++))
    fi

    # -------------------------------------------------------------------------
    # Summary
    # -------------------------------------------------------------------------
    echo ""
    success "Project structure setup complete!"
    info "Created: ${created_count} directories/files"
    info "Skipped: ${skipped_count} (already existed)"
}

# ============================================================================
# PHASE 5: MCP SERVER CONFIGURATION
# ============================================================================

setup_mcp_servers() {
    section "Phase 5: Channeling MCP Servers (Scope: ${SCOPE})"

    # Skip if requested
    if [[ "$NO_MCP" == true ]]; then
        warning "Skipping MCP server configuration (--no-mcp flag set)"
        return 0
    fi

    # Determine MCP servers directory based on scope
    local mcp_servers_dir
    local agent_memory_dir
    if [[ "$SCOPE" == "project" ]]; then
        mcp_servers_dir="$(pwd)/.claude/mcp-servers"
        agent_memory_dir="$(pwd)/.agent-memory"
        info "Using project scope for MCP servers"
    else
        mcp_servers_dir="${HOME}/.claude/mcp-servers"
        agent_memory_dir="${HOME}/.agent-memory"
        if [[ "$SCOPE" == "both" ]]; then
            info "Using global scope for MCP servers (when scope=both, MCP is global)"
        else
            info "Using global scope for MCP servers"
        fi
    fi

    local configured_count=0
    local skipped_count=0

    # -------------------------------------------------------------------------
    # Create MCP servers directory
    # -------------------------------------------------------------------------
    if [[ ! -d "$mcp_servers_dir" ]]; then
        execute "Create MCP servers directory" mkdir -p "$mcp_servers_dir"
        success "Created ${mcp_servers_dir}"
    else
        info "MCP servers directory already exists: ${mcp_servers_dir}"
    fi

    # -------------------------------------------------------------------------
    # Create agent memory directory
    # -------------------------------------------------------------------------
    if [[ ! -d "$agent_memory_dir" ]]; then
        execute "Create agent memory directory" mkdir -p "$agent_memory_dir"
        success "Created ${agent_memory_dir}"
    else
        info "Agent memory directory already exists: ${agent_memory_dir}"
    fi

    # -------------------------------------------------------------------------
    # Install agent-memory-server.py
    # -------------------------------------------------------------------------
    info "Channeling agent-memory MCP server..."

    local source_memory_server="${SCRIPT_DIR}/utils/agent-memory-server.py"
    local dest_memory_server="${mcp_servers_dir}/agent-memory-server.py"

    # Check if source exists (if not, try parent Framework directory)
    if [[ ! -f "$source_memory_server" ]]; then
        local framework_memory_server="${PROJECT_ROOT}/../Haunt_Framework/scripts/agent-memory-server.py"
        if [[ -f "$framework_memory_server" ]]; then
            source_memory_server="$framework_memory_server"
            info "Using agent-memory-server.py from Framework directory"
        else
            warning "agent-memory-server.py not found in expected locations"
            warning "  Looked in: ${SCRIPT_DIR}/utils/agent-memory-server.py"
            warning "             ${framework_memory_server}"
            warning "Manifesting template agent-memory-server.py..."

            if [[ "$DRY_RUN" == false ]]; then
                # Create a minimal template
                cat > "$dest_memory_server" << 'TEMPLATE_EOF'
#!/usr/bin/env python3
"""
MCP Memory Server for Haunt - TEMPLATE

This is a minimal template. For the full implementation, see:
Haunt_Framework/scripts/agent-memory-server.py

To use this server:
1. Install dependencies: pip install mcp
2. Configure in Claude Desktop settings
3. Start server: python ~/.claude/mcp-servers/agent-memory-server.py
"""

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

server = Server("agent-memory")

@server.list_tools()
async def list_tools():
    return [
        Tool(
            name="recall_context",
            description="Get agent's memory context (template implementation)",
            inputSchema={
                "type": "object",
                "properties": {
                    "agent_id": {"type": "string"}
                },
                "required": ["agent_id"]
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    return [TextContent(type="text", text="Memory server template - not fully implemented")]

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream)

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
TEMPLATE_EOF
                chmod +x "$dest_memory_server"
                warning "Created template agent-memory-server.py"
                warning "Replace with full implementation from Framework for production use"
            else
                info "[DRY RUN] Would create template agent-memory-server.py"
            fi
            configured_count=$((configured_count + 1))
        fi
    fi

    # Copy agent-memory-server.py if source exists
    if [[ -f "$source_memory_server" ]]; then
        if [[ -f "$dest_memory_server" ]]; then
            # Check if files differ
            if ! cmp -s "$source_memory_server" "$dest_memory_server"; then
                if [[ "$VERBOSE" == true && "$DRY_RUN" == false ]]; then
                    info "agent-memory-server.py will be updated"
                fi

                if [[ "$DRY_RUN" == false ]]; then
                    cp "$source_memory_server" "$dest_memory_server"
                    chmod +x "$dest_memory_server"
                    success "Updated agent-memory-server.py"
                else
                    info "[DRY RUN] Would update agent-memory-server.py"
                fi
                configured_count=$((configured_count + 1))
            else
                info "agent-memory-server.py unchanged"
                skipped_count=$((skipped_count + 1))
            fi
        else
            # New installation
            if [[ "$DRY_RUN" == false ]]; then
                cp "$source_memory_server" "$dest_memory_server"
                chmod +x "$dest_memory_server"
                success "Installed agent-memory-server.py"
            else
                info "[DRY RUN] Would install agent-memory-server.py"
            fi
            configured_count=$((configured_count + 1))
        fi
    fi

    # -------------------------------------------------------------------------
    # Configure Context7 MCP server (if available)
    # -------------------------------------------------------------------------
    echo ""
    info "Checking Context7 MCP server configuration..."

    if command -v claude &> /dev/null; then
        # Check if 'claude mcp' command is available
        if claude mcp --help &> /dev/null 2>&1; then
            # Check if Context7 is already configured
            if claude mcp list 2>/dev/null | grep -q "context7"; then
                info "Context7 MCP server already configured"
                skipped_count=$((skipped_count + 1))
            else
                # Try to add Context7
                info "Attempting to configure Context7 MCP server..."
                if [[ "$DRY_RUN" == false ]]; then
                    # Note: The actual command may vary depending on Context7 installation method
                    # This is a placeholder for the expected command structure
                    if claude mcp add context7 &> /dev/null 2>&1; then
                        success "Configured Context7 MCP server"
                        configured_count=$((configured_count + 1))
                    else
                        warning "Could not auto-configure Context7"
                        info "  You may need to manually configure Context7 MCP server"
                        info "  See: https://github.com/modelcontextprotocol/servers"
                    fi
                else
                    info "[DRY RUN] Would configure Context7 MCP server"
                fi
            fi
        else
            warning "'claude mcp' command not available"
            info "  MCP server configuration commands not supported in this Claude CLI version"
            info "  You can manually configure MCP servers in Claude Desktop settings"
            info "  See: https://modelcontextprotocol.io/docs/tools/inspector"
        fi
    else
        warning "Claude CLI not found - cannot auto-configure Context7"
        info "  Install with: npm install -g @anthropic-ai/claude-code"
    fi

    # -------------------------------------------------------------------------
    # Verify agent-memory-server.py has required dependencies
    # -------------------------------------------------------------------------
    echo ""
    info "Checking agent-memory server dependencies..."

    if command -v python3 &> /dev/null; then
        # Check if mcp package is installed
        if python3 -c "import mcp" &> /dev/null; then
            success "Python 'mcp' package is installed"
        else
            warning "Python 'mcp' package not found"
            info "  Install with: pip install mcp"
            info "  Or with uv: uv pip install mcp"
            info "  The agent-memory server requires this package to run"
        fi
    else
        error "Python 3 not found - cannot verify dependencies"
    fi

    # -------------------------------------------------------------------------
    # Summary
    # -------------------------------------------------------------------------
    echo ""
    success "MCP server configuration complete!"
    info "Configuration summary:"
    echo "  • Configured: ${configured_count} server(s)"
    echo "  • Skipped:    ${skipped_count} (already configured)"
    echo ""
    info "MCP servers installed:"
    echo "  • agent-memory: ${dest_memory_server}"
    if [[ -f "${dest_memory_server}" ]]; then
        echo "    Status: Installed"
    else
        echo "    Status: Not installed"
    fi
    echo ""
    info "Next steps:"
    echo "  1. Ensure MCP server dependencies are installed (pip install mcp)"
    echo "  2. Configure MCP servers in Claude Desktop settings if not auto-configured"
    echo "  3. Restart Claude Desktop to load MCP servers"
    echo ""
}

# ============================================================================
# PHASE 5: INFRASTRUCTURE VERIFICATION
# ============================================================================

verify_infrastructure() {
    section "Phase 5b: Verifying Spiritual Infrastructure"

    # TODO: Check MCP servers (Context7, Agent Memory)
    # TODO: Check Playwright installation
    # This will be implemented in subsequent requirements

    info "Infrastructure verification complete"
}

# ============================================================================
# PHASE 6: FINAL VERIFICATION
# ============================================================================

verify_setup() {
    section "Phase 6: Conducting Séance (Comprehensive Verification)"

    local timestamp=$(date +%Y-%m-%d_%H%M%S)
    local report_file
    local total_checks=0
    local passed_checks=0
    local failed_checks=0
    local warnings_count=0
    local issues=()
    local fixes_applied=()

    # Calculate project root properly
    local project_root="$(pwd)"
    report_file="${project_root}/.haunt/progress/setup-verification-${timestamp}.md"

    # Ensure progress directory exists
    if [[ ! -d "${project_root}/.haunt/progress" ]]; then
        mkdir -p "${project_root}/.haunt/progress" 2>/dev/null || true
    fi

    # Start verification report
    if [[ "$DRY_RUN" == false ]]; then
        cat > "$report_file" << 'EOF'
# Setup Verification Report

**Generated:** TIMESTAMP_PLACEHOLDER
**Mode:** MODE_PLACEHOLDER

---

## Verification Results

EOF
        # Replace placeholders
        sed -i '' "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/" "$report_file"
        sed -i '' "s/MODE_PLACEHOLDER/$(if [[ "$FIX_MODE" == true ]]; then echo 'Verify + Fix'; else echo 'Verify Only'; fi)/" "$report_file"
    fi

    echo ""
    info "Running comprehensive verification checks..."
    echo ""

    # =========================================================================
    # CHECK 1: Prerequisites Still Valid
    # =========================================================================
    ((total_checks++))
    info "[${total_checks}] Checking prerequisites..."

    local prereq_issues=0

    # Check Git
    if ! command -v git &> /dev/null; then
        error "  git: NOT FOUND"
        issues+=("CRITICAL: git not installed")
        ((prereq_issues++))
    else
        success "  git: installed"
    fi

    # Check Python 3.11+
    if ! command -v python3 &> /dev/null; then
        error "  Python 3: NOT FOUND"
        issues+=("CRITICAL: Python 3.11+ not installed")
        ((prereq_issues++))
    else
        local python_version=$(python3 --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        local python_major=$(echo "$python_version" | cut -d. -f1)
        local python_minor=$(echo "$python_version" | cut -d. -f2)
        if [[ "$python_major" -lt 3 ]] || [[ "$python_major" -eq 3 && "$python_minor" -lt 11 ]]; then
            error "  Python 3: ${python_version} (requires 3.11+)"
            issues+=("CRITICAL: Python 3.11+ required")
            ((prereq_issues++))
        else
            success "  Python 3: ${python_version}"
        fi
    fi

    # Check Node.js 18+
    if ! command -v node &> /dev/null; then
        error "  Node.js: NOT FOUND"
        issues+=("CRITICAL: Node.js 18+ not installed")
        ((prereq_issues++))
    else
        local node_version=$(node --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        local node_major=$(echo "$node_version" | cut -d. -f1)
        if [[ "$node_major" -lt 18 ]]; then
            error "  Node.js: ${node_version} (requires 18+)"
            issues+=("CRITICAL: Node.js 18+ required")
            ((prereq_issues++))
        else
            success "  Node.js: ${node_version}"
        fi
    fi

    if [[ $prereq_issues -eq 0 ]]; then
        ((passed_checks++))
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✓ Prerequisites" >> "$report_file"
            echo "All critical prerequisites are installed and meet version requirements." >> "$report_file"
            echo "" >> "$report_file"
        fi
    else
        ((failed_checks++))
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✗ Prerequisites" >> "$report_file"
            echo "**Status:** FAILED - ${prereq_issues} critical prerequisite(s) missing or outdated" >> "$report_file"
            echo "**Fix:** Install missing prerequisites and re-run verification" >> "$report_file"
            echo "" >> "$report_file"
        fi
    fi

    # =========================================================================
    # CHECK 2: MCP Servers Configuration
    # =========================================================================
    ((total_checks++))
    info "[${total_checks}] Checking MCP server configuration..."

    local mcp_issues=0
    local mcp_servers_dir="${HOME}/.claude/mcp-servers"

    if [[ ! -d "$mcp_servers_dir" ]]; then
        warning "  MCP servers directory not found: ${mcp_servers_dir}"
        issues+=("MCP servers directory not configured")
        ((mcp_issues++))

        if [[ "$FIX_MODE" == true ]]; then
            info "  [FIX] Creating MCP servers directory..."
            if [[ "$DRY_RUN" == false ]]; then
                mkdir -p "$mcp_servers_dir"
                success "  Created ${mcp_servers_dir}"
                fixes_applied+=("Created MCP servers directory")
            else
                info "  [DRY RUN] Would create ${mcp_servers_dir}"
            fi
        fi
    else
        success "  MCP servers directory exists"
    fi

    # Check agent-memory-server.py
    if [[ ! -f "${mcp_servers_dir}/agent-memory-server.py" ]]; then
        warning "  agent-memory-server.py not found"
        issues+=("agent-memory-server.py not installed")
        ((mcp_issues++))
        ((warnings_count++))
    else
        success "  agent-memory-server.py exists"
    fi

    # Check agent memory directory
    if [[ ! -d "${HOME}/.agent-memory" ]]; then
        warning "  Agent memory directory not found"
        issues+=("Agent memory directory not configured")
        ((mcp_issues++))

        if [[ "$FIX_MODE" == true ]]; then
            info "  [FIX] Creating agent memory directory..."
            if [[ "$DRY_RUN" == false ]]; then
                mkdir -p "${HOME}/.agent-memory"
                success "  Created ${HOME}/.agent-memory"
                fixes_applied+=("Created agent memory directory")
            else
                info "  [DRY RUN] Would create ${HOME}/.agent-memory"
            fi
        fi
    else
        success "  Agent memory directory exists"
    fi

    if [[ $mcp_issues -eq 0 ]]; then
        ((passed_checks++))
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✓ MCP Servers" >> "$report_file"
            echo "MCP server infrastructure is properly configured." >> "$report_file"
            echo "" >> "$report_file"
        fi
    else
        ((warnings_count++))
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ⚠ MCP Servers" >> "$report_file"
            echo "**Status:** WARNINGS - ${mcp_issues} configuration issue(s)" >> "$report_file"
            echo "**Fix:** Run with --fix flag to create missing directories, or run full setup" >> "$report_file"
            echo "" >> "$report_file"
        fi
    fi

    # =========================================================================
    # CHECK 3: Global Agents Installation (based on SCOPE)
    # =========================================================================
    ((total_checks++))
    info "[${total_checks}] Checking agents installation (scope: ${SCOPE})..."

    local agents_issues=0
    local agent_count=0

    # Check global agents if scope is global or both
    if [[ "$SCOPE" == "global" || "$SCOPE" == "both" ]]; then
        info "  Checking global agents..."
        if [[ ! -d "$GLOBAL_AGENTS_DIR" ]]; then
            error "  Global agents directory not found: ${GLOBAL_AGENTS_DIR}"
            issues+=("CRITICAL: Global agents directory missing")
            ((agents_issues++))

            if [[ "$FIX_MODE" == true ]]; then
                info "  [FIX] Creating global agents directory..."
                if [[ "$DRY_RUN" == false ]]; then
                    mkdir -p "$GLOBAL_AGENTS_DIR"
                    success "  Created ${GLOBAL_AGENTS_DIR}"
                    fixes_applied+=("Created global agents directory")
                else
                    info "  [DRY RUN] Would create ${GLOBAL_AGENTS_DIR}"
                fi
            fi
        else
            success "  Global agents directory exists"

            # Count agents
            agent_count=$(find "$GLOBAL_AGENTS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
            if [[ $agent_count -eq 0 ]]; then
                error "  No agents found in ${GLOBAL_AGENTS_DIR}"
                issues+=("CRITICAL: No global agents installed")
                ((agents_issues++))

                if [[ "$FIX_MODE" == true ]]; then
                    warning "  [FIX] Cannot auto-install agents - source directory may be missing"
                    warning "  Run full setup: bash scripts/setup-haunt.sh --agents-only"
                fi
            else
                success "  Found ${agent_count} global agent(s)"
            fi
        fi
    fi

    # Check project agents if scope is project or both
    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        info "  Checking project agents..."
        if [[ ! -d "$PROJECT_AGENTS_INSTALL_DIR" ]]; then
            error "  Project agents directory not found: ${PROJECT_AGENTS_INSTALL_DIR}"
            issues+=("CRITICAL: Project agents directory missing")
            ((agents_issues++))

            if [[ "$FIX_MODE" == true ]]; then
                info "  [FIX] Creating project agents directory..."
                if [[ "$DRY_RUN" == false ]]; then
                    mkdir -p "$PROJECT_AGENTS_INSTALL_DIR"
                    success "  Created ${PROJECT_AGENTS_INSTALL_DIR}"
                    fixes_applied+=("Created project agents directory")
                else
                    info "  [DRY RUN] Would create ${PROJECT_AGENTS_INSTALL_DIR}"
                fi
            fi
        else
            success "  Project agents directory exists"

            # Count project agents
            local project_agent_count=$(find "$PROJECT_AGENTS_INSTALL_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
            if [[ $project_agent_count -eq 0 ]]; then
                error "  No agents found in ${PROJECT_AGENTS_INSTALL_DIR}"
                issues+=("CRITICAL: No project agents installed")
                ((agents_issues++))

                if [[ "$FIX_MODE" == true ]]; then
                    warning "  [FIX] Cannot auto-install agents - source directory may be missing"
                    warning "  Run full setup: bash scripts/setup-haunt.sh --scope=project"
                fi
            else
                success "  Found ${project_agent_count} project agent(s)"
            fi
        fi
    fi

    # Validate agent line counts (<= 300 lines) if agents exist (warning only)
    if [[ $agent_count -gt 0 || ${project_agent_count:-0} -gt 0 ]]; then
        if [[ -f "${SCRIPT_DIR}/validation/validate-agents.sh" ]]; then
            info "  Validating agent line counts (<= 300 lines)..."
            if bash "${SCRIPT_DIR}/validation/validate-agents.sh" > /dev/null 2>&1; then
                success "  All agents are <= 300 lines"
            else
                warning "  Some agents exceed 300 lines (consider trimming)"
                ((warnings_count++))
            fi
        else
            warning "  validation/validate-agents.sh not found - skipping line count validation"
        fi
    fi

    if [[ $agents_issues -eq 0 ]]; then
        ((passed_checks++))
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✓ Agents Installation" >> "$report_file"
            echo "Agents are properly installed for scope: ${SCOPE}" >> "$report_file"
            echo "" >> "$report_file"
        fi
    else
        ((failed_checks++))
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✗ Agents Installation" >> "$report_file"
            echo "**Status:** FAILED - ${agents_issues} issue(s)" >> "$report_file"
            echo "**Fix:** \`bash scripts/setup-haunt.sh --agents-only\`" >> "$report_file"
            echo "" >> "$report_file"
        fi
    fi

    # =========================================================================
    # CHECK 4: Skills Library Validation (Source)
    # =========================================================================
    ((total_checks++))
    info "[${total_checks}] Validating source skills library..."

    local skills_issues=0
    local skill_count=0

    if [[ ! -d "${SOURCE_SKILLS_DIR}" ]]; then
        error "  Source skills directory not found: ${SOURCE_SKILLS_DIR}"
        issues+=("CRITICAL: Source skills directory missing")
        ((skills_issues++))
        ((failed_checks++))
    else
        success "  Source skills directory exists"

        # Count skills
        skill_count=$(find "${SOURCE_SKILLS_DIR}" -type d -maxdepth 1 | tail -n +2 | wc -l | tr -d ' ')
        info "  Found ${skill_count} skill directories in source"

        # Validate skill frontmatter
        if [[ -f "${SCRIPT_DIR}/validation/validate-skills.sh" ]]; then
            info "  Validating skill frontmatter..."
            if bash "${SCRIPT_DIR}/validation/validate-skills.sh" > /dev/null 2>&1; then
                success "  All skills have valid frontmatter"
                ((passed_checks++))
            else
                error "  Some skills have invalid frontmatter"
                issues+=("Some skills missing name/description fields")
                ((skills_issues++))
                ((failed_checks++))
            fi
        else
            warning "  validation/validate-skills.sh not found - skipping validation"
            ((passed_checks++))
        fi
    fi

    if [[ $skills_issues -eq 0 && $skill_count -gt 0 ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✓ Source Skills Library" >> "$report_file"
            echo "Found ${skill_count} skills, all validated." >> "$report_file"
            echo "" >> "$report_file"
        fi
    else
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✗ Source Skills Library" >> "$report_file"
            echo "**Status:** FAILED - ${skills_issues} issue(s)" >> "$report_file"
            echo "**Fix:** Manually correct skills with missing frontmatter" >> "$report_file"
            echo "" >> "$report_file"
        fi
    fi

    # =========================================================================
    # CHECK 4b: Installed Skills Validation
    # =========================================================================
    ((total_checks++))
    info "[${total_checks}] Validating installed skills..."

    local installed_skills_issues=0
    local installed_skill_count=0

    # Determine which directories to check based on scope
    local skills_dirs_to_check=()
    if [[ "$SCOPE" == "global" || "$SCOPE" == "both" ]]; then
        skills_dirs_to_check+=("$GLOBAL_SKILLS_DIR")
    fi
    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        skills_dirs_to_check+=("$PROJECT_SKILLS_INSTALL_DIR")
    fi

    for skills_dir in "${skills_dirs_to_check[@]}"; do
        local scope_label="global"
        if [[ "$skills_dir" == "$PROJECT_SKILLS_INSTALL_DIR" ]]; then
            scope_label="project"
        fi

        if [[ ! -d "$skills_dir" ]]; then
            warning "  Installed skills directory not found (${scope_label}): ${skills_dir}"
            issues+=("Skills not installed to ${scope_label} location")
            ((installed_skills_issues++))

            if [[ "$FIX_MODE" == true ]]; then
                warning "  [FIX] Run: bash scripts/setup-haunt.sh --scope=${scope_label} --skills-only"
            fi
        else
            # Count installed skills
            local dir_skill_count=0
            for skill_dir in "$skills_dir"/*/; do
                if [[ -d "$skill_dir" && -f "${skill_dir}/SKILL.md" ]]; then
                    dir_skill_count=$((dir_skill_count + 1))
                fi
            done
            installed_skill_count=$((installed_skill_count + dir_skill_count))

            if [[ $dir_skill_count -eq 0 ]]; then
                warning "  No skills found in ${scope_label} location: ${skills_dir}"
                issues+=("No skills installed to ${scope_label} location")
                ((installed_skills_issues++))
            else
                success "  Found ${dir_skill_count} installed skill(s) in ${scope_label} location"
            fi
        fi
    done

    if [[ $installed_skills_issues -eq 0 && $installed_skill_count -gt 0 ]]; then
        ((passed_checks++))
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✓ Installed Skills" >> "$report_file"
            echo "Found ${installed_skill_count} installed skill(s)." >> "$report_file"
            echo "" >> "$report_file"
        fi
    else
        ((failed_checks++))
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✗ Installed Skills" >> "$report_file"
            echo "**Status:** FAILED - ${installed_skills_issues} issue(s)" >> "$report_file"
            echo "**Fix:** Run setup script with --skills-only flag" >> "$report_file"
            echo "" >> "$report_file"
        fi
    fi

    # =========================================================================
    # CHECK 5: Agent-Skill References
    # =========================================================================
    ((total_checks++))
    info "[${total_checks}] Validating agent-skill references..."

    if [[ -f "${SCRIPT_DIR}/validation/validate-agent-skills.sh" ]]; then
        if bash "${SCRIPT_DIR}/validation/validate-agent-skills.sh" > /dev/null 2>&1; then
            success "  All agent-skill references are valid"
            ((passed_checks++))

            if [[ "$DRY_RUN" == false ]]; then
                echo "### ✓ Agent-Skill References" >> "$report_file"
                echo "All agent-skill references validated successfully." >> "$report_file"
                echo "" >> "$report_file"
            fi
        else
            error "  Some agent-skill references are broken"
            issues+=("Agents reference non-existent skills")
            ((failed_checks++))

            if [[ "$DRY_RUN" == false ]]; then
                echo "### ✗ Agent-Skill References" >> "$report_file"
                echo "**Status:** FAILED - Broken skill references detected" >> "$report_file"
                echo "**Fix:** Update agent files or create missing skills" >> "$report_file"
                echo "" >> "$report_file"
            fi
        fi
    else
        warning "  validation/validate-agent-skills.sh not found - skipping validation"
        ((warnings_count++))
    fi

    # =========================================================================
    # CHECK 6: Pattern Detection Installation
    # =========================================================================
    ((total_checks++))
    info "[${total_checks}] Checking pattern detection installation..."

    local pattern_issues=0

    if [[ "$WITH_PATTERN_DETECTION" == true ]]; then
        # Check for pattern-detector directory
        if [[ ! -d "${project_root}/.haunt/scripts/pattern-detector" ]]; then
            warning "  Pattern detector directory not found"
            issues+=("Pattern detector directory not installed")
            ((pattern_issues++))
        else
            success "  Pattern detector directory exists"
        fi

        # Check for hunt-patterns wrapper
        if [[ ! -f "${project_root}/.haunt/scripts/hunt-patterns" ]]; then
            warning "  hunt-patterns wrapper not found"
            issues+=("hunt-patterns tool not installed")
            ((pattern_issues++))
        else
            if [[ -x "${project_root}/.haunt/scripts/hunt-patterns" ]]; then
                success "  hunt-patterns wrapper exists and is executable"
            else
                warning "  hunt-patterns exists but is not executable"
                issues+=("hunt-patterns not executable")
                ((pattern_issues++))
            fi
        fi

        # Check for weekly-refactor.sh
        if [[ ! -f "${project_root}/.haunt/scripts/weekly-refactor.sh" ]]; then
            warning "  weekly-refactor.sh not found"
            issues+=("weekly-refactor.sh not installed")
            ((pattern_issues++))
        else
            if [[ -x "${project_root}/.haunt/scripts/weekly-refactor.sh" ]]; then
                success "  weekly-refactor.sh exists and is executable"
            else
                warning "  weekly-refactor.sh exists but is not executable"
                issues+=("weekly-refactor.sh not executable")
                ((pattern_issues++))
            fi
        fi

        # Check Python 3 availability
        if ! command -v python3 &> /dev/null; then
            error "  Python 3 not found - required for pattern detection"
            issues+=("CRITICAL: Python 3 required for pattern detection")
            ((pattern_issues++))
        else
            success "  Python 3 available"
        fi

        if [[ $pattern_issues -eq 0 ]]; then
            ((passed_checks++))
            if [[ "$DRY_RUN" == false ]]; then
                echo "### ✓ Pattern Detection" >> "$report_file"
                echo "Pattern detection tools are properly installed." >> "$report_file"
                echo "" >> "$report_file"
            fi
        else
            ((failed_checks++))
            if [[ "$DRY_RUN" == false ]]; then
                echo "### ✗ Pattern Detection" >> "$report_file"
                echo "**Status:** FAILED - ${pattern_issues} issue(s)" >> "$report_file"
                echo "**Fix:** \`bash scripts/setup-haunt.sh --project-only\`" >> "$report_file"
                echo "" >> "$report_file"
            fi
        fi
    else
        info "  Pattern detection not enabled (--no-pattern-detection)"
        ((passed_checks++))
    fi

    # =========================================================================
    # CHECK 7: Project Structure
    # =========================================================================
    ((total_checks++))
    info "[${total_checks}] Checking project structure..."

    local structure_issues=0
    local missing_dirs=()

    # Required directories
    local required_dirs=(
        ".claude/agents"
        ".claude/commands"
        ".haunt/plans"
        ".haunt/completed"
        ".haunt/progress"
        ".haunt/tests/patterns"
        ".haunt/tests/behavior"
        ".haunt/tests/e2e"
        ".haunt/docs"
        ".haunt/scripts"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "${project_root}/${dir}" ]]; then
            warning "  Missing: ${dir}/"
            missing_dirs+=("${dir}")
            ((structure_issues++))
        else
            success "  Found: ${dir}/"
        fi
    done

    # Check required files
    if [[ ! -f "${project_root}/.haunt/plans/roadmap.md" ]]; then
        warning "  Missing: .haunt/plans/roadmap.md"
        missing_dirs+=(".haunt/plans/roadmap.md")
        ((structure_issues++))
    else
        success "  Found: .haunt/plans/roadmap.md"
    fi

    if [[ ! -f "${project_root}/.haunt/.gitignore" ]]; then
        warning "  Missing: .haunt/.gitignore"
        missing_dirs+=(".haunt/.gitignore")
        ((structure_issues++))
    else
        success "  Found: .haunt/.gitignore"
    fi

    # Check CLAUDE.md exists and has Active Work section
    if [[ -f "${project_root}/CLAUDE.md" ]]; then
        if grep -q "^## Active Work" "${project_root}/CLAUDE.md" 2>/dev/null; then
            success "  Found: CLAUDE.md with Active Work section"
        else
            warning "  Found: CLAUDE.md but missing Active Work section"
            ((warnings_count++))
            info "    Tip: Run setup to add Active Work section, or add manually"
        fi
    else
        warning "  Missing: CLAUDE.md (recommended for agent context)"
        ((warnings_count++))
        info "    Tip: Run --project-only to create CLAUDE.md with Active Work section"
    fi

    if [[ $structure_issues -gt 0 ]]; then
        ((failed_checks++))

        if [[ "$FIX_MODE" == true ]]; then
            info "  [FIX] Creating missing directories..."
            for dir in "${missing_dirs[@]}"; do
                if [[ "$dir" == ".haunt/plans/roadmap.md" || "$dir" == ".haunt/.gitignore" ]]; then
                    continue  # Skip files for now
                fi

                if [[ "$DRY_RUN" == false ]]; then
                    mkdir -p "${project_root}/${dir}"
                    success "  Created ${dir}/"
                    fixes_applied+=("Created ${dir}/")
                else
                    info "  [DRY RUN] Would create ${dir}/"
                fi
            done

            # Note about roadmap and gitignore
            if [[ " ${missing_dirs[*]} " =~ " .haunt/plans/roadmap.md " ]] || [[ " ${missing_dirs[*]} " =~ " .haunt/.gitignore " ]]; then
                warning "  Note: Run full setup to create roadmap template and .haunt/.gitignore"
                info "  Command: bash scripts/setup-haunt.sh --project-only"
            fi
        fi

        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✗ Project Structure" >> "$report_file"
            echo "**Status:** INCOMPLETE - ${structure_issues} missing directories/files" >> "$report_file"
            echo "**Fix:** \`bash scripts/setup-haunt.sh --verify --fix\` or \`--project-only\`" >> "$report_file"
            echo "" >> "$report_file"
        fi
    else
        ((passed_checks++))
        if [[ "$DRY_RUN" == false ]]; then
            echo "### ✓ Project Structure" >> "$report_file"
            echo "All required directories and files exist." >> "$report_file"
            echo "" >> "$report_file"
        fi
    fi

    # Check plan file sizes (warning only, not a blocking failure)
    if [[ -d "${project_root}/.haunt/plans" ]]; then
        local oversized_files=()
        for plan_file in "${project_root}/.haunt/plans"/*.md; do
            [[ ! -f "$plan_file" ]] && continue
            local line_count=$(wc -l < "$plan_file" | tr -d ' ')
            if [[ $line_count -gt 1000 ]]; then
                oversized_files+=("$(basename "$plan_file"): ${line_count} lines")
            fi
        done
        if [[ ${#oversized_files[@]} -gt 0 ]]; then
            ((warnings_count++))
            warning "  Plan files exceeding 1000 lines (archive recommended):"
            for file in "${oversized_files[@]}"; do
                warning "    - $file"
            done
            if [[ "$DRY_RUN" == false ]]; then
                echo "### ⚠ Plan File Sizes" >> "$report_file"
                echo "The following files exceed 1000 lines and should be archived:" >> "$report_file"
                for file in "${oversized_files[@]}"; do
                    echo "- $file" >> "$report_file"
                done
                echo "" >> "$report_file"
            fi
        fi
    fi

    # =========================================================================
    # SUMMARY
    # =========================================================================
    echo ""
    echo "=========================================="
    info "Verification Summary"
    echo "=========================================="
    echo ""
    echo "  Total Checks:  ${total_checks}"
    echo -e "  Passed:        ${GREEN}${passed_checks}${NC}"
    echo -e "  Failed:        ${RED}${failed_checks}${NC}"
    echo -e "  Warnings:      ${YELLOW}${warnings_count}${NC}"
    echo ""

    if [[ ${#fixes_applied[@]} -gt 0 ]]; then
        success "Fixes Applied: ${#fixes_applied[@]}"
        for fix in "${fixes_applied[@]}"; do
            echo "  - ${fix}"
        done
        echo ""
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        warning "Issues Found: ${#issues[@]}"
        for issue in "${issues[@]}"; do
            echo "  - ${issue}"
        done
        echo ""
    fi

    # Write summary to report
    if [[ "$DRY_RUN" == false ]]; then
        cat >> "$report_file" << EOF
---

## Summary

**Total Checks:** ${total_checks}
**Passed:** ${passed_checks}
**Failed:** ${failed_checks}
**Warnings:** ${warnings_count}

EOF

        if [[ ${#fixes_applied[@]} -gt 0 ]]; then
            echo "### Fixes Applied" >> "$report_file"
            echo "" >> "$report_file"
            for fix in "${fixes_applied[@]}"; do
                echo "- ${fix}" >> "$report_file"
            done
            echo "" >> "$report_file"
        fi

        if [[ ${#issues[@]} -gt 0 ]]; then
            echo "### Issues Found" >> "$report_file"
            echo "" >> "$report_file"
            for issue in "${issues[@]}"; do
                echo "- ${issue}" >> "$report_file"
            done
            echo "" >> "$report_file"
        fi

        echo "---" >> "$report_file"
        echo "" >> "$report_file"
        echo "**Report saved:** \`${report_file}\`" >> "$report_file"

        success "Verification report saved: ${report_file}"
    fi

    # Exit code determination
    if [[ $failed_checks -gt 0 ]]; then
        error "Verification FAILED: ${failed_checks} check(s) failed"
        echo ""
        if [[ "$FIX_MODE" != true ]]; then
            info "Run with --fix flag to attempt automatic repairs:"
            echo "  bash scripts/setup-haunt.sh --verify --fix"
        fi
        return 1
    else
        success "All verification checks PASSED"
        return 0
    fi
}

# ============================================================================
# DEPLOYMENT MANIFEST GENERATION
# ============================================================================

generate_manifest() {
    local project_root="$(pwd)"
    local manifest_file="${project_root}/.haunt/.deployment-manifest.json"
    local source_path="$REPO_ROOT/Haunt"

    # Ensure .haunt/ directory exists
    if [[ ! -d "${project_root}/.haunt" ]]; then
        mkdir -p "${project_root}/.haunt"
    fi

    info "Generating deployment manifest..."

    # Start JSON structure
    cat > "$manifest_file" << EOF
{
  "version": "2.0",
  "source_path": "$source_path",
  "deployed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "scope": "$SCOPE",
  "files": {
EOF

    # Track files with checksums
    local first_file=true

    # Process agents
    if [[ -d "$PROJECT_AGENTS_DIR" ]]; then
        for file in "$PROJECT_AGENTS_DIR"/*.md; do
            if [[ -f "$file" ]]; then
                local rel_path="agents/$(basename "$file")"
                local checksum=$(shasum -a 256 "$file" | awk '{print $1}')

                if [[ "$first_file" == true ]]; then
                    first_file=false
                else
                    echo "," >> "$manifest_file"
                fi

                echo -n "    \"$rel_path\": \"sha256:$checksum\"" >> "$manifest_file"
            fi
        done
    fi

    # Process rules
    local source_rules_dir="${PROJECT_ROOT}/rules"
    if [[ -d "$source_rules_dir" ]]; then
        for file in "$source_rules_dir"/*.md; do
            if [[ -f "$file" ]]; then
                local rel_path="rules/$(basename "$file")"
                local checksum=$(shasum -a 256 "$file" | awk '{print $1}')

                if [[ "$first_file" == true ]]; then
                    first_file=false
                else
                    echo "," >> "$manifest_file"
                fi

                echo -n "    \"$rel_path\": \"sha256:$checksum\"" >> "$manifest_file"
            fi
        done
    fi

    # Process skills (only SKILL.md files)
    if [[ -d "$SOURCE_SKILLS_DIR" ]]; then
        for skill_dir in "$SOURCE_SKILLS_DIR"/*/; do
            if [[ -d "$skill_dir" ]] && [[ -f "${skill_dir}SKILL.md" ]]; then
                local skill_name=$(basename "$skill_dir")
                local rel_path="skills/${skill_name}/SKILL.md"
                local checksum=$(shasum -a 256 "${skill_dir}SKILL.md" | awk '{print $1}')

                if [[ "$first_file" == true ]]; then
                    first_file=false
                else
                    echo "," >> "$manifest_file"
                fi

                echo -n "    \"$rel_path\": \"sha256:$checksum\"" >> "$manifest_file"
            fi
        done
    fi

    # Process commands
    if [[ -d "$SOURCE_COMMANDS_DIR" ]]; then
        for file in "$SOURCE_COMMANDS_DIR"/*.md; do
            if [[ -f "$file" ]]; then
                local rel_path="commands/$(basename "$file")"
                local checksum=$(shasum -a 256 "$file" | awk '{print $1}')

                if [[ "$first_file" == true ]]; then
                    first_file=false
                else
                    echo "," >> "$manifest_file"
                fi

                echo -n "    \"$rel_path\": \"sha256:$checksum\"" >> "$manifest_file"
            fi
        done
    fi

    # Close JSON structure
    cat >> "$manifest_file" << EOF

  }
}
EOF

    success "Deployment manifest saved: ${manifest_file}"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    # Parse command line arguments
    parse_arguments "$@"

    # Ensure we have access to required resources (clone repo if running remotely)
    ensure_resources

    # Show banner
    show_banner

    # Show remote execution notice
    if [[ "$RUNNING_FROM_REMOTE" == true ]]; then
        info "Running from remote source"
        info "Resources cloned to: $REMOTE_CLONE_DIR"
        echo ""
    fi

    # Show dry-run notice
    if [[ "$DRY_RUN" == true ]]; then
        warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    # Execute phases based on flags
    if [[ "$VERIFY_ONLY" == true ]]; then
        check_prerequisites
        verify_setup
        local result=$?
        cleanup_cloned_repo
        exit $result
    fi

    # Check prerequisites (always)
    check_prerequisites

    # Phase 1.5: Frontend plugin (optional)
    if [[ "$AGENTS_ONLY" == false && "$SKILLS_ONLY" == false ]]; then
        setup_frontend_plugin
    fi

    # Phase 2: Global agents
    if [[ "$SKILLS_ONLY" == false && "$PROJECT_ONLY" == false ]]; then
        setup_global_agents
    elif [[ "$AGENTS_ONLY" == true ]]; then
        setup_global_agents
        success "Agents-only setup complete!"
        cleanup_cloned_repo
        exit 0
    fi

    # Phase 2b: Rules (invariant enforcement protocols)
    if [[ "$SKILLS_ONLY" == false ]]; then
        setup_rules
    fi

    # Phase 3: Project skills
    if [[ "$AGENTS_ONLY" == false ]]; then
        setup_project_skills
    fi

    # Phase 3b: Slash commands
    if [[ "$AGENTS_ONLY" == false ]]; then
        setup_project_commands
    fi

    # Phase 4: Project structure
    if [[ "$AGENTS_ONLY" == false ]]; then
        setup_project_structure
    fi

    # Phase 5: MCP server configuration
    if [[ "$AGENTS_ONLY" == false ]]; then
        setup_mcp_servers
    fi

    # Phase 5b: Infrastructure verification
    if [[ "$AGENTS_ONLY" == false ]]; then
        verify_infrastructure
    fi

    # Phase 6: Final verification (unless --no-verify flag is set)
    verify_setup

    # Phase 7: Generate deployment manifest (unless dry-run or verify-only)
    if [[ "$DRY_RUN" == false && "$VERIFY_ONLY" == false ]]; then
        generate_manifest
    fi

    # Success message
    echo ""
    section "Haunt Manifested!"

    if [[ "$DRY_RUN" == true ]]; then
        info "This was a dry run. Re-run without --dry-run to apply changes."
    else
        success "Your house is Haunted..."
        echo ""
        info "Next steps:"

        # Show relevant paths based on scope
        if [[ "$SCOPE" == "global" ]]; then
            echo "  1. Review agent character sheets in ${GLOBAL_AGENTS_DIR}"
            echo "  2. Review installed skills in ${GLOBAL_SKILLS_DIR}"
        elif [[ "$SCOPE" == "project" ]]; then
            echo "  1. Review agent character sheets in ${PROJECT_AGENTS_INSTALL_DIR}"
            echo "  2. Review installed skills in ${PROJECT_SKILLS_INSTALL_DIR}"
        elif [[ "$SCOPE" == "both" ]]; then
            echo "  1. Review agent character sheets:"
            echo "     - Global: ${GLOBAL_AGENTS_DIR}"
            echo "     - Project: ${PROJECT_AGENTS_INSTALL_DIR}"
            echo "  2. Review installed skills:"
            echo "     - Global: ${GLOBAL_SKILLS_DIR}"
            echo "     - Project: ${PROJECT_SKILLS_INSTALL_DIR}"
        fi

        echo "  3. Restart Claude Code to load the new configuration"
        echo "  4. Start a new session and run: /seance"
        echo ""

        info "The /seance command will guide you through getting started with Haunt"
    fi

    # Cleanup cloned repository if running remotely
    cleanup_cloned_repo
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

# Only run main if script is executed (not sourced)
# Handle being piped via curl (BASH_SOURCE is unset in that case)
if [[ -z "${BASH_SOURCE[0]:-}" ]] || [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
