#!/usr/bin/env bash
#
# cleanse.sh - Haunt Environment Management Script
#
# Manages Ghost County (Haunt) framework installation with three modes:
#   - repair:    Fix stale files, re-sync from source
#   - uninstall: Remove gco-* artifacts
#   - purge:     Complete removal including .haunt/
#
# Usage: bash Haunt/scripts/cleanse.sh [mode] [options]
#
# Modes:
#   --repair      Detect stale files, remove them, re-sync from Haunt/ source
#   --uninstall   Remove gco-* artifacts (default)
#   --purge       Full removal: uninstall + remove .haunt/ directory
#
# Options:
#   --scope=<scope>  Where to operate (project, user/global, both) [default: both]
#   --backup         Create backup before deletion
#   --dry-run        Preview what would be done without making changes
#   --force          Skip confirmation prompts (dangerous!)
#   --help           Show this help message
#
# Examples:
#   bash cleanse.sh --repair --scope=user     # Fix stale files in ~/.claude/
#   bash cleanse.sh --repair --dry-run        # Preview repair without changes
#   bash cleanse.sh --uninstall --scope=both  # Remove from everywhere
#   bash cleanse.sh --purge --scope=project   # Full removal from project only

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# ============================================================================
# COLOR OUTPUT FUNCTIONS
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly MAGENTA='\033[1;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

success() { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BLUE}ℹ${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; }
stale() { echo -e "${CYAN}⟳${NC} $1"; }

section() {
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════${NC}"
    echo -e "${BOLD}${PURPLE}  👻 $1${NC}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════${NC}"
    echo ""
}

# ============================================================================
# EXIT CODES
# ============================================================================

readonly EXIT_SUCCESS=0
readonly EXIT_CANCELLED=1
readonly EXIT_PERMISSION_DENIED=2
readonly EXIT_BACKUP_FAILED=3
readonly EXIT_NOTHING_TO_CLEAN=4

# ============================================================================
# CONFIGURATION
# ============================================================================

# Directories
GLOBAL_DIR="${HOME}/.claude"
GLOBAL_AGENTS_DIR="${GLOBAL_DIR}/agents"
GLOBAL_RULES_DIR="${GLOBAL_DIR}/rules"
GLOBAL_SKILLS_DIR="${GLOBAL_DIR}/skills"
GLOBAL_COMMANDS_DIR="${GLOBAL_DIR}/commands"

PROJECT_CLAUDE_DIR=".claude"
PROJECT_AGENTS_DIR="${PROJECT_CLAUDE_DIR}/agents"
PROJECT_RULES_DIR="${PROJECT_CLAUDE_DIR}/rules"
PROJECT_SKILLS_DIR="${PROJECT_CLAUDE_DIR}/skills"
PROJECT_COMMANDS_DIR="${PROJECT_CLAUDE_DIR}/commands"

PROJECT_HAUNT_DIR=".haunt"

# Source directories (for repair mode comparison)
HAUNT_SOURCE_DIR="Haunt"
SOURCE_AGENTS_DIR="${HAUNT_SOURCE_DIR}/agents"
SOURCE_RULES_DIR="${HAUNT_SOURCE_DIR}/rules"
SOURCE_SKILLS_DIR="${HAUNT_SOURCE_DIR}/skills"
SOURCE_COMMANDS_DIR="${HAUNT_SOURCE_DIR}/commands"

# Backup configuration (REQ-289)
BACKUP_DIR="${HOME}/haunt-backups"
BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/haunt-backup-${BACKUP_TIMESTAMP}.tar.gz"

# Default options
MODE="uninstall"  # repair, uninstall, purge
SCOPE="both"      # project, user, both
CREATE_BACKUP=false
DRY_RUN=false
FORCE=false

# Tracking arrays (using files for bash 3.2 compatibility)
STALE_FILES_LIST=$(mktemp)
REMOVED_COUNT=0
SYNCED_COUNT=0

trap "rm -f $STALE_FILES_LIST" EXIT

# ============================================================================
# HELP MESSAGE
# ============================================================================

show_help() {
    cat << EOF
${BOLD}${MAGENTA}Cleanse - Haunt Environment Management${NC}

Manage Ghost County (Haunt) framework installation with repair, uninstall, or purge modes.

${BOLD}Usage:${NC}
  bash cleanse.sh                      # Interactive mode (recommended)
  bash cleanse.sh [mode] [options]     # Advanced flag-based mode

${BOLD}Interactive Mode:${NC}
  Run with no arguments for a guided menu:
  - Choose scope (Global, Project, or All)
  - Preview what will be removed
  - Confirm with "yes" before deletion
  - View removal summary

${BOLD}Advanced Modes:${NC}
  --repair       Detect stale files, remove them, re-sync from Haunt/ source
  --uninstall    Remove gco-* artifacts (default mode)
  --purge        Full removal: uninstall + remove .haunt/ directory

${BOLD}Quick Cleanse Flags (REQ-288):${NC}
  --global       Remove only global ~/.claude/gco-* artifacts
  --project      Remove only .claude/ and .haunt/ from current directory
  --full         Remove both global and project artifacts

${BOLD}Scope Options:${NC}
  --scope=project   Only .claude/ in current project directory
  --scope=user      Only ~/.claude/ (user's home)
  --scope=global    Alias for --scope=user
  --scope=both      Both project and global locations (default)

${BOLD}Other Options:${NC}
  --backup       Create backup before any deletion
  --dry-run      Preview what would be done without making changes
  --force        Skip confirmation prompts (dangerous!)
  --help         Show this help message

${BOLD}Examples:${NC}
  # Fix stale files in global installation
  bash cleanse.sh --repair --scope=user

  # Preview repair without making changes
  bash cleanse.sh --repair --scope=both --dry-run

  # Quick removal - global only (new in REQ-288)
  bash cleanse.sh --global

  # Quick removal - project only (new in REQ-288)
  bash cleanse.sh --project

  # Quick removal - everything (new in REQ-288)
  bash cleanse.sh --full --backup

  # Uninstall from project only (detailed control)
  bash cleanse.sh --uninstall --scope=project

  # Full removal with backup
  bash cleanse.sh --purge --backup

${BOLD}Repair Mode Details:${NC}
  Repair mode compares deployed files against Haunt/ source to find:
  - Stale files: Exist in ~/.claude/ or .claude/ but NOT in Haunt/ source
  - These are usually leftovers from renamed/removed files

  After identifying stale files, repair mode:
  1. Removes stale files
  2. Re-runs setup-haunt.sh to sync current source

${BOLD}Restore from Backup:${NC}
  cd ~
  tar -xzf ~/haunt-backups/haunt-backup-YYYYMMDD-HHMMSS.tar.gz

${BOLD}Exit Codes:${NC}
  0 - Success (operation completed successfully)
  1 - Cancelled (user aborted operation)
  2 - Permission denied (cannot write to target directories)
  3 - Backup failed (backup creation error)
  4 - Nothing to clean (no artifacts found)

${BOLD}Dry-Run Mode:${NC}
  Use --dry-run to preview what would be deleted without making changes:
  - Shows all files/directories that would be removed
  - Checks permissions without deleting
  - Displays summary counts
  - Exits with code 0 (no actual changes made)

EOF
}

# ============================================================================
# INTERACTIVE MODE
# ============================================================================

show_interactive_menu() {
    section "Interactive Cleanse Mode"

    cat << "EOF"
What would you like to remove?

  [G] Global artifacts only      (~/.claude/gco-* files)
  [P] Project artifacts only     (.claude/ and .haunt/ in current directory)
  [A] All (Global + Project)     Remove from both locations
  [Q] Quit                       Exit without changes

EOF

    echo -ne "${YELLOW}Choose an option [G/P/A/Q]: ${NC}"
    read -r choice

    # Convert to uppercase (bash 3.2 compatible)
    choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')

    case "$choice" in
        G)
            MODE="uninstall"
            SCOPE="user"
            info "Selected: Remove global artifacts only"
            return 0
            ;;
        P)
            MODE="purge"
            SCOPE="project"
            info "Selected: Remove project artifacts only"
            return 0
            ;;
        A)
            MODE="purge"
            SCOPE="both"
            info "Selected: Remove all artifacts (global + project)"
            return 0
            ;;
        Q)
            info "Cleanse cancelled by user"
            exit "$EXIT_CANCELLED"
            ;;
        *)
            error "Invalid choice: $choice"
            return 1
            ;;
    esac
}

interactive_mode() {
    # Keep showing menu until valid choice
    while ! show_interactive_menu; do
        echo ""
    done

    # Preview what will be removed
    echo ""
    preview_uninstall

    # Ask for explicit confirmation
    echo ""
    echo -e "${YELLOW}${BOLD}Proceed with removal?${NC}"
    echo -ne "${YELLOW}Type 'yes' to confirm: ${NC}"
    read -r confirm

    if [[ "$confirm" != "yes" ]]; then
        info "Cleanse cancelled - no changes made"
        exit "$EXIT_CANCELLED"
    fi

    # Execute based on selected mode
    case "$MODE" in
        uninstall)
            section "Performing Removal"
            local failed=false

            if [[ "$SCOPE" == "user" || "$SCOPE" == "both" ]]; then
                info "Removing global artifacts (~/.claude/)..."
                remove_gco_files "$GLOBAL_AGENTS_DIR" "gco-*.md" "global agents" || failed=true
                remove_gco_files "$GLOBAL_RULES_DIR" "gco-*.md" "global rules" || failed=true
                remove_gco_dirs "$GLOBAL_SKILLS_DIR" "gco-*" "global skills" || failed=true
                remove_gco_files "$GLOBAL_COMMANDS_DIR" "gco-*.md" "global commands" || failed=true
                echo ""
            fi

            if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
                info "Removing project artifacts (.claude/)..."
                remove_gco_files "$PROJECT_AGENTS_DIR" "gco-*.md" "project agents" || failed=true
                remove_gco_files "$PROJECT_RULES_DIR" "gco-*.md" "project rules" || failed=true
                remove_gco_dirs "$PROJECT_SKILLS_DIR" "gco-*" "project skills" || failed=true
                remove_gco_files "$PROJECT_COMMANDS_DIR" "gco-*.md" "project commands" || failed=true
                echo ""
            fi

            [[ "$failed" == "true" ]] && warning "Some items could not be removed"
            ;;
        purge)
            perform_purge_silent
            ;;
    esac

    # Show summary
    echo ""
    section "Removal Complete"
    echo ""
    success "Removed ${REMOVED_COUNT} artifact(s)"
    echo ""
    echo "To reinstall Haunt, run: bash Haunt/scripts/setup-haunt.sh"
    echo ""
}

perform_purge_silent() {
    section "Performing Removal"

    local failed=false

    if [[ "$SCOPE" == "user" || "$SCOPE" == "both" ]]; then
        info "Removing global artifacts (~/.claude/)..."
        remove_gco_files "$GLOBAL_AGENTS_DIR" "gco-*.md" "global agents" || failed=true
        remove_gco_files "$GLOBAL_RULES_DIR" "gco-*.md" "global rules" || failed=true
        remove_gco_dirs "$GLOBAL_SKILLS_DIR" "gco-*" "global skills" || failed=true
        remove_gco_files "$GLOBAL_COMMANDS_DIR" "gco-*.md" "global commands" || failed=true
        echo ""
    fi

    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        info "Removing project artifacts (.claude/)..."
        remove_gco_files "$PROJECT_AGENTS_DIR" "gco-*.md" "project agents" || failed=true
        remove_gco_files "$PROJECT_RULES_DIR" "gco-*.md" "project rules" || failed=true
        remove_gco_dirs "$PROJECT_SKILLS_DIR" "gco-*" "project skills" || failed=true
        remove_gco_files "$PROJECT_COMMANDS_DIR" "gco-*.md" "project commands" || failed=true
        echo ""

        # Remove .haunt/ directory
        info "Removing project planning artifacts (.haunt/)..."
        remove_haunt_dir || failed=true
        echo ""
    fi

    [[ "$failed" == "true" ]] && warning "Some items could not be removed"
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --repair)
                MODE="repair"
                shift
                ;;
            --uninstall)
                MODE="uninstall"
                shift
                ;;
            --purge)
                MODE="purge"
                shift
                ;;
            --scope=*)
                SCOPE="${1#*=}"
                # Normalize 'global' to 'user'
                if [[ "$SCOPE" == "global" ]]; then
                    SCOPE="user"
                fi
                # Validate scope
                if [[ "$SCOPE" != "project" && "$SCOPE" != "user" && "$SCOPE" != "both" ]]; then
                    error "Invalid scope: $SCOPE (must be: project, user/global, both)"
                    exit 1
                fi
                shift
                ;;
            --backup)
                CREATE_BACKUP=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            # REQ-288: Flag-based cleanse modes (non-interactive)
            --global)
                MODE="uninstall"
                SCOPE="user"
                shift
                ;;
            --project)
                MODE="purge"
                SCOPE="project"
                shift
                ;;
            --full)
                MODE="purge"
                SCOPE="both"
                shift
                ;;
            # Legacy support for old flags
            --partial)
                MODE="uninstall"
                SCOPE="user"
                warning "Deprecated: --partial is now --uninstall --scope=user or --global"
                shift
                ;;
            *)
                error "Unknown option: $1"
                echo ""
                show_help
                exit 1
                ;;
        esac
    done
}

# ============================================================================
# PERMISSION CHECK FUNCTIONS
# ============================================================================

# Check if directory is writable
check_directory_writable() {
    local dir="$1"
    local description="$2"

    [[ ! -d "$dir" ]] && return 0  # Doesn't exist, no permission needed

    if [[ ! -w "$dir" ]]; then
        error "Permission denied: Cannot write to $description"
        error "Directory: $dir"
        warning "Try running with appropriate permissions or check directory ownership"
        return 1
    fi
    return 0
}

# Check write permissions for all target directories
check_permissions() {
    local failed=false

    section "Checking Permissions"

    if [[ "$SCOPE" == "user" || "$SCOPE" == "both" ]]; then
        info "Checking global directories (~/.claude/)..."
        check_directory_writable "$GLOBAL_AGENTS_DIR" "global agents directory" || failed=true
        check_directory_writable "$GLOBAL_RULES_DIR" "global rules directory" || failed=true
        check_directory_writable "$GLOBAL_SKILLS_DIR" "global skills directory" || failed=true
        check_directory_writable "$GLOBAL_COMMANDS_DIR" "global commands directory" || failed=true
    fi

    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        info "Checking project directories (.claude/ and .haunt/)..."
        check_directory_writable "$PROJECT_AGENTS_DIR" "project agents directory" || failed=true
        check_directory_writable "$PROJECT_RULES_DIR" "project rules directory" || failed=true
        check_directory_writable "$PROJECT_SKILLS_DIR" "project skills directory" || failed=true
        check_directory_writable "$PROJECT_COMMANDS_DIR" "project commands directory" || failed=true

        if [[ "$MODE" == "purge" ]]; then
            check_directory_writable "$PROJECT_HAUNT_DIR" "project .haunt directory" || failed=true
        fi
    fi

    echo ""

    if [[ "$failed" == "true" ]]; then
        error "Permission checks failed - cannot proceed with deletion"
        return 1
    fi

    success "All permission checks passed"
    return 0
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Count files matching pattern in directory
count_files() {
    local pattern="$1"
    local dir="$2"
    [[ ! -d "$dir" ]] && echo "0" && return
    find "$dir" -maxdepth 1 -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' '
}

# Count directories matching pattern
count_dirs() {
    local pattern="$1"
    local dir="$2"
    [[ ! -d "$dir" ]] && echo "0" && return
    find "$dir" -maxdepth 1 -name "$pattern" -type d 2>/dev/null | wc -l | tr -d ' '
}

# Check if Haunt source directory exists
check_haunt_source() {
    if [[ ! -d "$HAUNT_SOURCE_DIR" ]]; then
        error "Haunt source directory not found: $HAUNT_SOURCE_DIR"
        error "Repair mode requires the Haunt/ source directory to compare against."
        error "Make sure you're running from the ghost-county repository root."
        exit 1
    fi
}

# ============================================================================
# STALE FILE DETECTION (for repair mode)
# ============================================================================

# Get list of source files (what SHOULD exist)
get_source_agents() {
    [[ -d "$SOURCE_AGENTS_DIR" ]] && find "$SOURCE_AGENTS_DIR" -maxdepth 1 -name "gco-*.md" -type f -exec basename {} \; 2>/dev/null | sort
}

get_source_rules() {
    [[ -d "$SOURCE_RULES_DIR" ]] && find "$SOURCE_RULES_DIR" -maxdepth 1 -name "gco-*.md" -type f -exec basename {} \; 2>/dev/null | sort
}

get_source_skills() {
    [[ -d "$SOURCE_SKILLS_DIR" ]] && find "$SOURCE_SKILLS_DIR" -maxdepth 1 -name "gco-*" -type d -exec basename {} \; 2>/dev/null | sort
}

get_source_commands() {
    [[ -d "$SOURCE_COMMANDS_DIR" ]] && find "$SOURCE_COMMANDS_DIR" -maxdepth 1 -name "gco-*.md" -type f -exec basename {} \; 2>/dev/null | sort
}

# Find stale files in a deployed directory
find_stale_files() {
    local deployed_dir="$1"
    local asset_type="$2"  # agents, rules, commands
    local pattern="$3"

    [[ ! -d "$deployed_dir" ]] && return

    # Get list of source files for comparison
    local source_list=$(mktemp)
    case "$asset_type" in
        agents)   get_source_agents > "$source_list" ;;
        rules)    get_source_rules > "$source_list" ;;
        commands) get_source_commands > "$source_list" ;;
    esac

    # Find deployed files that don't exist in source
    find "$deployed_dir" -maxdepth 1 -name "$pattern" -type f 2>/dev/null | while read -r file; do
        local basename=$(basename "$file")
        if ! grep -qx "$basename" "$source_list" 2>/dev/null; then
            echo "$file" >> "$STALE_FILES_LIST"
            stale "Stale: $file"
        fi
    done

    rm -f "$source_list"
}

# Find stale skill directories
find_stale_skills() {
    local deployed_dir="$1"

    [[ ! -d "$deployed_dir" ]] && return

    local source_list=$(mktemp)
    get_source_skills > "$source_list"

    find "$deployed_dir" -maxdepth 1 -name "gco-*" -type d 2>/dev/null | while read -r dir; do
        local basename=$(basename "$dir")
        if ! grep -qx "$basename" "$source_list" 2>/dev/null; then
            echo "$dir" >> "$STALE_FILES_LIST"
            stale "Stale: $dir/"
        fi
    done

    rm -f "$source_list"
}

# Scan for all stale files based on scope
scan_for_stale() {
    section "Scanning for Stale Spirits"

    # Clear previous scan
    > "$STALE_FILES_LIST"

    if [[ "$SCOPE" == "user" || "$SCOPE" == "both" ]]; then
        echo -e "${BOLD}Global (~/.claude/):${NC}"
        find_stale_files "$GLOBAL_AGENTS_DIR" "agents" "gco-*.md"
        find_stale_files "$GLOBAL_RULES_DIR" "rules" "gco-*.md"
        find_stale_skills "$GLOBAL_SKILLS_DIR"
        find_stale_files "$GLOBAL_COMMANDS_DIR" "commands" "gco-*.md"
        echo ""
    fi

    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        echo -e "${BOLD}Project (.claude/):${NC}"
        find_stale_files "$PROJECT_AGENTS_DIR" "agents" "gco-*.md"
        find_stale_files "$PROJECT_RULES_DIR" "rules" "gco-*.md"
        find_stale_skills "$PROJECT_SKILLS_DIR"
        find_stale_files "$PROJECT_COMMANDS_DIR" "commands" "gco-*.md"
        echo ""
    fi

    local stale_count=$(wc -l < "$STALE_FILES_LIST" | tr -d ' ')
    if [[ "$stale_count" -eq 0 ]]; then
        success "No stale files detected - your installation is clean!"
        return 1
    else
        warning "Found ${stale_count} stale file(s)/directory(ies)"
        return 0
    fi
}

# ============================================================================
# PREVIEW FUNCTIONS
# ============================================================================

preview_scope_targets() {
    echo -e "${BOLD}Scope:${NC} ${SCOPE}"
    echo ""
    case "$SCOPE" in
        user)
            echo "  Target: ~/.claude/ (global installation)"
            ;;
        project)
            echo "  Target: .claude/ (current project)"
            ;;
        both)
            echo "  Targets:"
            echo "    - ~/.claude/ (global installation)"
            echo "    - .claude/ (current project)"
            ;;
    esac
    echo ""
}

preview_uninstall() {
    section "Preview: What Will Be Removed"

    preview_scope_targets

    local total_files=0
    local total_dirs=0

    # Global scope
    if [[ "$SCOPE" == "user" || "$SCOPE" == "both" ]]; then
        echo -e "${BOLD}Global Artifacts (~/.claude/):${NC}"
        echo ""

        local agent_count=$(count_files "gco-*.md" "$GLOBAL_AGENTS_DIR")
        echo -e "  ${PURPLE}Agents${NC}: ${agent_count} files"
        total_files=$((total_files + agent_count))

        local rules_count=$(count_files "gco-*.md" "$GLOBAL_RULES_DIR")
        echo -e "  ${PURPLE}Rules${NC}: ${rules_count} files"
        total_files=$((total_files + rules_count))

        local skills_count=$(count_dirs "gco-*" "$GLOBAL_SKILLS_DIR")
        echo -e "  ${PURPLE}Skills${NC}: ${skills_count} directories"
        total_dirs=$((total_dirs + skills_count))

        local commands_count=$(count_files "gco-*.md" "$GLOBAL_COMMANDS_DIR")
        echo -e "  ${PURPLE}Commands${NC}: ${commands_count} files"
        total_files=$((total_files + commands_count))
        echo ""
    fi

    # Project scope
    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        echo -e "${BOLD}Project Artifacts (.claude/):${NC}"
        echo ""

        local agent_count=$(count_files "gco-*.md" "$PROJECT_AGENTS_DIR")
        echo -e "  ${PURPLE}Agents${NC}: ${agent_count} files"
        total_files=$((total_files + agent_count))

        local rules_count=$(count_files "gco-*.md" "$PROJECT_RULES_DIR")
        echo -e "  ${PURPLE}Rules${NC}: ${rules_count} files"
        total_files=$((total_files + rules_count))

        local skills_count=$(count_dirs "gco-*" "$PROJECT_SKILLS_DIR")
        echo -e "  ${PURPLE}Skills${NC}: ${skills_count} directories"
        total_dirs=$((total_dirs + skills_count))

        local commands_count=$(count_files "gco-*.md" "$PROJECT_COMMANDS_DIR")
        echo -e "  ${PURPLE}Commands${NC}: ${commands_count} files"
        total_files=$((total_files + commands_count))
        echo ""
    fi

    # Purge mode adds .haunt/
    if [[ "$MODE" == "purge" ]]; then
        if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
            echo -e "${BOLD}${RED}PURGE: Project Planning Artifacts (.haunt/):${NC}"
            if [[ -d "$PROJECT_HAUNT_DIR" ]]; then
                echo "  - .haunt/plans/"
                echo "  - .haunt/completed/"
                echo "  - .haunt/progress/"
                echo "  - .haunt/tests/"
                echo "  - .haunt/docs/"
                total_dirs=$((total_dirs + 1))
            else
                echo "  (not found)"
            fi
            echo ""
        fi
    fi

    echo -e "${BOLD}Total:${NC} ${total_files} files, ${total_dirs} directories"
    echo ""
}

preview_repair() {
    section "Preview: Repair Plan"

    preview_scope_targets

    local stale_count=$(wc -l < "$STALE_FILES_LIST" | tr -d ' ')

    echo -e "${BOLD}Step 1: Remove Stale Files${NC}"
    echo ""
    if [[ "$stale_count" -gt 0 ]]; then
        echo "  The following ${stale_count} stale item(s) will be removed:"
        cat "$STALE_FILES_LIST" | while read -r item; do
            if [[ -d "$item" ]]; then
                echo "    - ${item}/ (directory)"
            else
                echo "    - ${item}"
            fi
        done
    else
        echo "  No stale files to remove"
    fi
    echo ""

    echo -e "${BOLD}Step 2: Re-sync from Source${NC}"
    echo ""
    echo "  Will run: bash Haunt/scripts/setup-haunt.sh"
    case "$SCOPE" in
        user)   echo "  With scope: --agents-only (global)" ;;
        project) echo "  With scope: --project-only" ;;
        both)   echo "  With scope: (full setup)" ;;
    esac
    echo ""
}

# ============================================================================
# BACKUP FUNCTIONS
# ============================================================================

create_backup() {
    section "Creating Backup"

    local backup_paths=()

    if [[ "$SCOPE" == "user" || "$SCOPE" == "both" ]]; then
        [[ -d "$GLOBAL_DIR" ]] && backup_paths+=(".claude")
    fi

    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        [[ -d "$PROJECT_CLAUDE_DIR" ]] && backup_paths+=("$PROJECT_CLAUDE_DIR")
        [[ -d "$PROJECT_HAUNT_DIR" && "$MODE" == "purge" ]] && backup_paths+=("$PROJECT_HAUNT_DIR")
    fi

    if [[ ${#backup_paths[@]} -eq 0 ]]; then
        warning "No files to backup"
        return 1
    fi

    info "Backup location: ${BACKUP_FILE}"

    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would create backup with: ${backup_paths[*]}"
        return 0
    fi

    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR" 2>/dev/null || {
        error "Cannot create backup directory: $BACKUP_DIR"
        exit "$EXIT_BACKUP_FAILED"
    }

    # Create backup
    (cd "$HOME" && tar -czf "$BACKUP_FILE" "${backup_paths[@]}" 2>/dev/null) || {
        error "Backup creation failed"
        exit "$EXIT_BACKUP_FAILED"
    }

    if [[ -f "$BACKUP_FILE" ]]; then
        local backup_size=$(du -h "$BACKUP_FILE" | cut -f1)
        success "Backup created: ${BACKUP_FILE} (${backup_size})"
        return 0
    else
        error "Backup file not created"
        exit "$EXIT_BACKUP_FAILED"
    fi
}

# ============================================================================
# REMOVAL FUNCTIONS
# ============================================================================

remove_gco_files() {
    local dir="$1"
    local pattern="$2"
    local description="$3"

    [[ ! -d "$dir" ]] && return 0

    local count=$(count_files "$pattern" "$dir")
    [[ "$count" -eq 0 ]] && return 0

    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would remove ${count} ${description}"
        return 0
    fi

    find "$dir" -maxdepth 1 -name "$pattern" -type f -delete 2>/dev/null || {
        error "Failed to remove some ${description}"
        return 1
    }
    success "Removed ${count} ${description}"
    REMOVED_COUNT=$((REMOVED_COUNT + count))
}

remove_gco_dirs() {
    local dir="$1"
    local pattern="$2"
    local description="$3"

    [[ ! -d "$dir" ]] && return 0

    local count=$(count_dirs "$pattern" "$dir")
    [[ "$count" -eq 0 ]] && return 0

    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would remove ${count} ${description}"
        return 0
    fi

    find "$dir" -maxdepth 1 -name "$pattern" -type d -exec rm -rf {} + 2>/dev/null || {
        error "Failed to remove some ${description}"
        return 1
    }
    success "Removed ${count} ${description}"
    REMOVED_COUNT=$((REMOVED_COUNT + count))
}

remove_stale_items() {
    local stale_count=$(wc -l < "$STALE_FILES_LIST" | tr -d ' ')

    if [[ "$stale_count" -eq 0 ]]; then
        info "No stale items to remove"
        return 0
    fi

    info "Removing ${stale_count} stale item(s)..."

    cat "$STALE_FILES_LIST" | while read -r item; do
        if [[ "$DRY_RUN" == "true" ]]; then
            info "[DRY-RUN] Would remove: $item"
        else
            if [[ -d "$item" ]]; then
                rm -rf "$item" && success "Removed: $item/" || warning "Failed: $item/"
            else
                rm -f "$item" && success "Removed: $item" || warning "Failed: $item"
            fi
            REMOVED_COUNT=$((REMOVED_COUNT + 1))
        fi
    done
}

remove_haunt_dir() {
    [[ ! -d "$PROJECT_HAUNT_DIR" ]] && return 0

    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would remove: ${PROJECT_HAUNT_DIR}/"
        return 0
    fi

    rm -rf "$PROJECT_HAUNT_DIR" 2>/dev/null || {
        error "Failed to remove ${PROJECT_HAUNT_DIR}/"
        return 1
    }
    success "Removed ${PROJECT_HAUNT_DIR}/"
}

# ============================================================================
# SYNC FUNCTION (for repair mode)
# ============================================================================

resync_from_source() {
    section "Re-syncing from Source"

    local setup_script="${HAUNT_SOURCE_DIR}/scripts/setup-haunt.sh"

    if [[ ! -f "$setup_script" ]]; then
        error "Setup script not found: $setup_script"
        return 1
    fi

    local setup_args=""
    case "$SCOPE" in
        user)    setup_args="--agents-only" ;;
        project) setup_args="--project-only" ;;
        both)    setup_args="" ;;
    esac

    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would run: bash $setup_script $setup_args"
        return 0
    fi

    info "Running: bash $setup_script $setup_args"
    echo ""

    bash "$setup_script" $setup_args || {
        error "Setup script failed"
        return 1
    }

    success "Re-sync complete"
}

# ============================================================================
# CONFIRMATION FUNCTIONS
# ============================================================================

confirm_action() {
    [[ "$FORCE" == "true" ]] && return 0
    [[ "$DRY_RUN" == "true" ]] && return 0

    echo -e "${YELLOW}$1${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        return 0
    else
        info "Operation cancelled by user"
        exit "$EXIT_CANCELLED"
    fi
}

final_confirmation() {
    [[ "$FORCE" == "true" ]] && return 0
    [[ "$DRY_RUN" == "true" ]] && return 0

    echo ""
    echo -e "${RED}${BOLD}⚠️  FINAL WARNING ⚠️${NC}"
    echo ""

    case "$MODE" in
        repair)
            echo "This will remove stale files and re-sync from Haunt/ source."
            ;;
        uninstall)
            echo "This will remove all gco-* artifacts from the specified scope."
            ;;
        purge)
            echo "This will remove ALL Haunt artifacts including .haunt/ directory."
            echo -e "${RED}Your roadmap, progress, and archived work will be DELETED.${NC}"
            ;;
    esac

    if [[ "$CREATE_BACKUP" == "false" ]]; then
        echo -e "${YELLOW}NO BACKUP will be created.${NC}"
    fi
    echo ""
    echo -e "${YELLOW}Type 'CLEANSE' to proceed: ${NC}"
    read -r response

    [[ "$response" == "CLEANSE" ]] || {
        info "Cleanse aborted by user"
        exit "$EXIT_CANCELLED"
    }
}

# ============================================================================
# CHECK FUNCTIONS
# ============================================================================

# Check if there's anything to clean
check_has_artifacts() {
    local has_artifacts=false

    if [[ "$SCOPE" == "user" || "$SCOPE" == "both" ]]; then
        [[ $(count_files "gco-*.md" "$GLOBAL_AGENTS_DIR") -gt 0 ]] && has_artifacts=true
        [[ $(count_files "gco-*.md" "$GLOBAL_RULES_DIR") -gt 0 ]] && has_artifacts=true
        [[ $(count_dirs "gco-*" "$GLOBAL_SKILLS_DIR") -gt 0 ]] && has_artifacts=true
        [[ $(count_files "gco-*.md" "$GLOBAL_COMMANDS_DIR") -gt 0 ]] && has_artifacts=true
    fi

    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        [[ $(count_files "gco-*.md" "$PROJECT_AGENTS_DIR") -gt 0 ]] && has_artifacts=true
        [[ $(count_files "gco-*.md" "$PROJECT_RULES_DIR") -gt 0 ]] && has_artifacts=true
        [[ $(count_dirs "gco-*" "$PROJECT_SKILLS_DIR") -gt 0 ]] && has_artifacts=true
        [[ $(count_files "gco-*.md" "$PROJECT_COMMANDS_DIR") -gt 0 ]] && has_artifacts=true

        if [[ "$MODE" == "purge" && -d "$PROJECT_HAUNT_DIR" ]]; then
            has_artifacts=true
        fi
    fi

    [[ "$has_artifacts" == "true" ]]
}

check_uncommitted_work() {
    [[ ! -f "${PROJECT_HAUNT_DIR}/plans/roadmap.md" ]] && return 0

    local has_warnings=false

    if git status --porcelain "${PROJECT_HAUNT_DIR}" 2>/dev/null | grep -q .; then
        warning "Uncommitted changes in ${PROJECT_HAUNT_DIR}/"
        has_warnings=true
    fi

    local in_progress=$(grep -c "^### 🟡" "${PROJECT_HAUNT_DIR}/plans/roadmap.md" 2>/dev/null || echo "0")
    if [[ "$in_progress" -gt 0 ]]; then
        warning "${in_progress} requirement(s) marked 🟡 In Progress"
        has_warnings=true
    fi

    if [[ "$has_warnings" == "true" ]]; then
        echo ""
        echo -e "${YELLOW}🔮 Consider finishing or committing work before cleansing.${NC}"
        echo ""
        return 1
    fi
    return 0
}

# ============================================================================
# MAIN MODE FUNCTIONS
# ============================================================================

perform_repair() {
    check_haunt_source

    # Scan for stale files
    if ! scan_for_stale; then
        echo ""
        info "Nothing to repair. Your installation matches the source."
        echo ""
        if confirm_action "Run setup anyway to ensure sync? (yes/no): "; then
            resync_from_source
        fi
        return 0
    fi

    # Preview
    preview_repair

    # Confirm
    final_confirmation

    # Backup if requested
    if [[ "$CREATE_BACKUP" == "true" ]]; then
        create_backup || {
            confirm_action "Backup failed. Continue anyway? (yes/no): " || exit 1
        }
    fi

    section "Performing Repair"

    # Remove stale items
    remove_stale_items

    # Re-sync from source
    resync_from_source

    echo ""
    success "Repair complete!"
}

perform_uninstall() {
    # Check if there's anything to clean
    if ! check_has_artifacts; then
        info "No Haunt artifacts found - nothing to clean"
        exit "$EXIT_NOTHING_TO_CLEAN"
    fi

    # Check permissions (skip in dry-run mode)
    if [[ "$DRY_RUN" == "false" ]]; then
        check_permissions || exit "$EXIT_PERMISSION_DENIED"
    fi

    # Preview
    preview_uninstall

    # Confirm
    final_confirmation

    # Backup if requested
    if [[ "$CREATE_BACKUP" == "true" ]]; then
        create_backup
    fi

    section "Performing Uninstall"

    local failed=false

    # Global scope
    if [[ "$SCOPE" == "user" || "$SCOPE" == "both" ]]; then
        info "Removing global artifacts (~/.claude/)..."
        remove_gco_files "$GLOBAL_AGENTS_DIR" "gco-*.md" "global agents" || failed=true
        remove_gco_files "$GLOBAL_RULES_DIR" "gco-*.md" "global rules" || failed=true
        remove_gco_dirs "$GLOBAL_SKILLS_DIR" "gco-*" "global skills" || failed=true
        remove_gco_files "$GLOBAL_COMMANDS_DIR" "gco-*.md" "global commands" || failed=true
        echo ""
    fi

    # Project scope
    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        info "Removing project artifacts (.claude/)..."
        remove_gco_files "$PROJECT_AGENTS_DIR" "gco-*.md" "project agents" || failed=true
        remove_gco_files "$PROJECT_RULES_DIR" "gco-*.md" "project rules" || failed=true
        remove_gco_dirs "$PROJECT_SKILLS_DIR" "gco-*" "project skills" || failed=true
        remove_gco_files "$PROJECT_COMMANDS_DIR" "gco-*.md" "project commands" || failed=true
        echo ""
    fi

    [[ "$failed" == "true" ]] && warning "Some items could not be removed"
    success "Uninstall complete!"
}

perform_purge() {
    # Check if there's anything to clean
    if ! check_has_artifacts; then
        info "No Haunt artifacts found - nothing to clean"
        exit "$EXIT_NOTHING_TO_CLEAN"
    fi

    # Check permissions (skip in dry-run mode)
    if [[ "$DRY_RUN" == "false" ]]; then
        check_permissions || exit "$EXIT_PERMISSION_DENIED"
    fi

    # Check for uncommitted work (purge is destructive)
    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        if ! check_uncommitted_work; then
            confirm_action "Continue anyway? (yes/no): "
        fi
    fi

    # Preview
    preview_uninstall

    # Confirm
    final_confirmation

    # Backup if requested
    if [[ "$CREATE_BACKUP" == "true" ]]; then
        create_backup
    fi

    section "Performing Purge"

    # First do normal uninstall
    local failed=false

    if [[ "$SCOPE" == "user" || "$SCOPE" == "both" ]]; then
        info "Removing global artifacts (~/.claude/)..."
        remove_gco_files "$GLOBAL_AGENTS_DIR" "gco-*.md" "global agents" || failed=true
        remove_gco_files "$GLOBAL_RULES_DIR" "gco-*.md" "global rules" || failed=true
        remove_gco_dirs "$GLOBAL_SKILLS_DIR" "gco-*" "global skills" || failed=true
        remove_gco_files "$GLOBAL_COMMANDS_DIR" "gco-*.md" "global commands" || failed=true
        echo ""
    fi

    if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
        info "Removing project artifacts (.claude/)..."
        remove_gco_files "$PROJECT_AGENTS_DIR" "gco-*.md" "project agents" || failed=true
        remove_gco_files "$PROJECT_RULES_DIR" "gco-*.md" "project rules" || failed=true
        remove_gco_dirs "$PROJECT_SKILLS_DIR" "gco-*" "project skills" || failed=true
        remove_gco_files "$PROJECT_COMMANDS_DIR" "gco-*.md" "project commands" || failed=true
        echo ""

        # Remove .haunt/ directory
        info "Removing project planning artifacts (.haunt/)..."
        remove_haunt_dir || failed=true
        echo ""
    fi

    [[ "$failed" == "true" ]] && warning "Some items could not be removed"
    success "Purge complete!"
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    # Check if no arguments provided - trigger interactive mode
    if [[ $# -eq 0 ]]; then
        interactive_mode
        exit 0
    fi

    parse_arguments "$@"

    # Show banner
    section "Cleanse - Haunt Environment Management"

    echo -e "${MAGENTA}"
    cat << "EOF"
                    .     .
                 .  |\-^-/|   .
                /| } O.=" O { |\
               /╱ \-_ _ _-/    \\
EOF
    echo -e "${NC}"

    # Show mode and options
    local mode_display=$(echo "$MODE" | tr '[:lower:]' '[:upper:]')
    echo -e "${BOLD}Mode:${NC} ${mode_display}"
    echo -e "${BOLD}Scope:${NC} ${SCOPE}"
    [[ "$DRY_RUN" == "true" ]] && echo -e "${CYAN}${BOLD}[DRY-RUN MODE]${NC}"
    echo ""

    # Execute based on mode
    case "$MODE" in
        repair)
            perform_repair
            ;;
        uninstall)
            perform_uninstall
            ;;
        purge)
            perform_purge
            ;;
    esac

    # Final message
    echo ""
    section "The Ritual is Complete"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "This was a dry-run. No changes were made."
        echo ""
        echo "To perform the actual cleanse, run without --dry-run"
    else
        echo "Your environment has been cleansed."
        echo ""
        if [[ "$CREATE_BACKUP" == "true" && -f "$BACKUP_FILE" ]]; then
            echo "Backup saved to: ${BACKUP_FILE}"
            echo ""
        fi
        if [[ "$MODE" != "purge" || "$SCOPE" == "user" ]]; then
            echo "To reinstall Haunt:"
            echo "  bash Haunt/scripts/setup-haunt.sh"
        fi
    fi
    echo ""
}

# Run main
main "$@"
