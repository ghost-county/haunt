#!/usr/bin/env bash

#==============================================================================
# migrate-to-haunt.sh
#
# Purpose: Migrate existing Haunt files from root-level directories
#          to the new .haunt/ consolidated structure.
#
# Usage:
#   bash migrate-to-haunt.sh              # Perform migration
#   bash migrate-to-haunt.sh --dry-run    # Preview changes
#   bash migrate-to-haunt.sh --rollback   # Reverse migration
#   bash migrate-to-haunt.sh --no-backup  # Skip backup creation
#
# Migration Mapping:
#   plans/roadmap.md                → .haunt/plans/roadmap.md
#   plans/feature-contract.json     → .haunt/plans/feature-contract.json
#   plans/*                         → .haunt/plans/*
#   progress/*                      → .haunt/progress/*
#   completed/*                     → .haunt/completed/*
#   tests/patterns/*                → .haunt/tests/patterns/*
#   tests/behavior/*                → .haunt/tests/behavior/*
#   tests/e2e/*                     → .haunt/tests/e2e/*
#   INITIALIZATION.md               → .haunt/docs/INITIALIZATION.md
#
# Safety Features:
#   - Creates timestamped backup before migration
#   - Validates source files exist before moving
#   - Checks for existing .haunt/ directory
#   - Provides dry-run mode to preview changes
#   - Supports rollback from backup
#   - Handles missing directories gracefully
#
# Version: 1.0
# Created: 2025-12-10
# Related: REQ-086 (Migration Script Implementation)
#==============================================================================

set -euo pipefail

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
BACKUP_DIR="${PROJECT_ROOT}/.haunt-backup-$(date +%Y%m%d-%H%M%S)"
ROLLBACK_MANIFEST="${BACKUP_DIR}/rollback-manifest.txt"

# Mode flags
DRY_RUN=false
ROLLBACK=false
NO_BACKUP=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Statistics
declare -i FILES_MOVED=0
declare -i FILES_SKIPPED=0
declare -i DIRS_CREATED=0
declare -i ERRORS=0

#------------------------------------------------------------------------------
# Helper Functions
#------------------------------------------------------------------------------

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
    ERRORS=$((ERRORS + 1))
}

log_dry_run() {
    echo -e "${YELLOW}[DRY-RUN]${NC} $*"
}

print_header() {
    echo ""
    echo "=========================================================================="
    echo "$*"
    echo "=========================================================================="
    echo ""
}

ensure_directory() {
    local dir="$1"

    if [[ "$DRY_RUN" == true ]]; then
        if [[ ! -d "$dir" ]]; then
            log_dry_run "Would create directory: $dir"
            DIRS_CREATED=$((DIRS_CREATED + 1))
        fi
    else
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
            DIRS_CREATED=$((DIRS_CREATED + 1))
        fi
    fi
}

move_file() {
    local src="$1"
    local dest="$2"
    local desc="${3:-}"

    if [[ ! -e "$src" ]]; then
        log_warning "Source not found (skipping): $src"
        FILES_SKIPPED=$((FILES_SKIPPED + 1))
        return 0
    fi

    # Ensure destination directory exists
    local dest_dir
    dest_dir="$(dirname "$dest")"
    ensure_directory "$dest_dir"

    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would move: $src → $dest ${desc:+($desc)}"
        FILES_MOVED=$((FILES_MOVED + 1))
    else
        # Record move in rollback manifest
        if [[ "$NO_BACKUP" == false ]]; then
            echo "$dest|$src" >> "$ROLLBACK_MANIFEST"
        fi

        mv "$src" "$dest"
        log_success "Moved: $src → $dest ${desc:+($desc)}"
        FILES_MOVED=$((FILES_MOVED + 1))
    fi
}

move_directory_contents() {
    local src_dir="$1"
    local dest_dir="$2"
    local pattern="${3:-*}"

    if [[ ! -d "$src_dir" ]]; then
        log_warning "Source directory not found (skipping): $src_dir"
        return 0
    fi

    ensure_directory "$dest_dir"

    # Use find to get all files matching pattern
    local file_count=0
    while IFS= read -r -d '' file; do
        local relative_path="${file#$src_dir/}"
        local dest_file="$dest_dir/$relative_path"

        # Create subdirectory structure if needed
        local sub_dir
        sub_dir="$(dirname "$dest_file")"
        ensure_directory "$sub_dir"

        if [[ "$DRY_RUN" == true ]]; then
            log_dry_run "Would move: $file → $dest_file"
            file_count=$((file_count + 1))
        else
            # Record move in rollback manifest
            if [[ "$NO_BACKUP" == false ]]; then
                echo "$dest_file|$file" >> "$ROLLBACK_MANIFEST"
            fi

            mv "$file" "$dest_file"
            file_count=$((file_count + 1))
        fi
    done < <(find "$src_dir" -type f -name "$pattern" -print0)

    if [[ $file_count -gt 0 ]]; then
        log_success "Moved $file_count file(s) from $src_dir to $dest_dir"
        FILES_MOVED=$((FILES_MOVED + file_count))
    else
        log_warning "No files found in: $src_dir"
    fi
}

cleanup_empty_directories() {
    local dirs=("$@")

    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]] && [[ -z "$(ls -A "$dir")" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                log_dry_run "Would remove empty directory: $dir"
            else
                rmdir "$dir"
                log_info "Removed empty directory: $dir"
            fi
        fi
    done
}

#------------------------------------------------------------------------------
# Migration Functions
#------------------------------------------------------------------------------

check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check if we're in a valid project directory
    if [[ ! -f "CLAUDE.md" ]] && [[ ! -d ".claude" ]]; then
        log_error "Not in a valid Haunt project directory."
        log_error "Expected CLAUDE.md or .claude/ directory in: $PROJECT_ROOT"
        return 1
    fi

    # Check for existing .haunt/ directory
    if [[ -d "${PROJECT_ROOT}/.haunt" ]] && [[ "$ROLLBACK" == false ]]; then
        log_warning "Directory .haunt/ already exists."

        # Check if it has content
        if [[ -n "$(ls -A "${PROJECT_ROOT}/.haunt" 2>/dev/null)" ]]; then
            log_error "Directory .haunt/ is not empty. Please remove or rename it before migration."
            log_error "Or run with --rollback to restore from backup."
            return 1
        else
            log_info "Directory .haunt/ is empty and will be used."
        fi
    fi

    # Check for source directories/files
    local has_sources=false
    if [[ -d "${PROJECT_ROOT}/plans" ]] || \
       [[ -d "${PROJECT_ROOT}/progress" ]] || \
       [[ -d "${PROJECT_ROOT}/completed" ]] || \
       [[ -d "${PROJECT_ROOT}/tests" ]] || \
       [[ -f "${PROJECT_ROOT}/INITIALIZATION.md" ]]; then
        has_sources=true
    fi

    if [[ "$has_sources" == false ]] && [[ "$ROLLBACK" == false ]]; then
        log_warning "No source directories/files found to migrate."
        log_warning "Nothing to do."
        return 1
    fi

    log_success "Prerequisites check passed."
    return 0
}

create_backup() {
    if [[ "$NO_BACKUP" == true ]] || [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    print_header "Creating Backup"

    mkdir -p "$BACKUP_DIR"

    # Create manifest file
    echo "# Rollback Manifest - $(date)" > "$ROLLBACK_MANIFEST"
    echo "# Format: destination|source" >> "$ROLLBACK_MANIFEST"

    log_success "Backup directory created: $BACKUP_DIR"
}

create_sdlc_structure() {
    print_header "Creating .haunt/ Directory Structure"

    local sdlc_root="${PROJECT_ROOT}/.haunt"

    ensure_directory "$sdlc_root"
    ensure_directory "$sdlc_root/plans"
    ensure_directory "$sdlc_root/progress"
    ensure_directory "$sdlc_root/completed"
    ensure_directory "$sdlc_root/tests/patterns"
    ensure_directory "$sdlc_root/tests/behavior"
    ensure_directory "$sdlc_root/tests/e2e"
    ensure_directory "$sdlc_root/docs"
    ensure_directory "$sdlc_root/scripts"

    # Create .gitignore in .haunt/
    local gitignore_path="$sdlc_root/.gitignore"

    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would create: $gitignore_path"
    elif [[ ! -f "$gitignore_path" ]]; then
        # Ensure parent directory exists before creating file
        if [[ -d "$sdlc_root" ]]; then
            cat > "$gitignore_path" << 'EOF'
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
EOF
            log_success "Created: $gitignore_path"
        fi
    fi

    log_success "Directory structure created."
}

migrate_plans() {
    print_header "Migrating plans/ Directory"

    local src_dir="${PROJECT_ROOT}/plans"
    local dest_dir="${PROJECT_ROOT}/.haunt/plans"

    if [[ ! -d "$src_dir" ]]; then
        log_warning "Directory not found: $src_dir (skipping)"
        return 0
    fi

    move_directory_contents "$src_dir" "$dest_dir" "*"

    # Clean up empty source directory
    cleanup_empty_directories "$src_dir"
}

migrate_progress() {
    print_header "Migrating progress/ Directory"

    local src_dir="${PROJECT_ROOT}/progress"
    local dest_dir="${PROJECT_ROOT}/.haunt/progress"

    if [[ ! -d "$src_dir" ]]; then
        log_warning "Directory not found: $src_dir (skipping)"
        return 0
    fi

    move_directory_contents "$src_dir" "$dest_dir" "*"

    # Clean up empty source directory
    cleanup_empty_directories "$src_dir"
}

migrate_completed() {
    print_header "Migrating completed/ Directory"

    local src_dir="${PROJECT_ROOT}/completed"
    local dest_dir="${PROJECT_ROOT}/.haunt/completed"

    if [[ ! -d "$src_dir" ]]; then
        log_warning "Directory not found: $src_dir (skipping)"
        return 0
    fi

    move_directory_contents "$src_dir" "$dest_dir" "*"

    # Clean up empty source directory
    cleanup_empty_directories "$src_dir"
}

migrate_tests() {
    print_header "Migrating tests/ Directory"

    local src_base="${PROJECT_ROOT}/tests"
    local dest_base="${PROJECT_ROOT}/.haunt/tests"

    if [[ ! -d "$src_base" ]]; then
        log_warning "Directory not found: $src_base (skipping)"
        return 0
    fi

    # Migrate patterns
    if [[ -d "$src_base/patterns" ]]; then
        move_directory_contents "$src_base/patterns" "$dest_base/patterns" "*"
        cleanup_empty_directories "$src_base/patterns"
    fi

    # Migrate behavior
    if [[ -d "$src_base/behavior" ]]; then
        move_directory_contents "$src_base/behavior" "$dest_base/behavior" "*"
        cleanup_empty_directories "$src_base/behavior"
    fi

    # Migrate e2e
    if [[ -d "$src_base/e2e" ]]; then
        move_directory_contents "$src_base/e2e" "$dest_base/e2e" "*"
        cleanup_empty_directories "$src_base/e2e"
    fi

    # Clean up empty tests directory
    cleanup_empty_directories "$src_base"
}

migrate_initialization() {
    print_header "Migrating INITIALIZATION.md"

    local src_file="${PROJECT_ROOT}/INITIALIZATION.md"
    local dest_file="${PROJECT_ROOT}/.haunt/docs/INITIALIZATION.md"

    move_file "$src_file" "$dest_file" "Project initialization record"
}

update_gitignore() {
    print_header "Updating Root .gitignore"

    local gitignore_path="${PROJECT_ROOT}/.gitignore"

    # Check if .haunt/ is already in .gitignore
    if [[ -f "$gitignore_path" ]] && grep -q "^\.haunt/" "$gitignore_path" 2>/dev/null; then
        log_info ".gitignore already contains .haunt/ entry."
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would add .haunt/ entries to .gitignore"
        return 0
    fi

    # Create .gitignore if it doesn't exist
    if [[ ! -f "$gitignore_path" ]]; then
        touch "$gitignore_path"
        log_info "Created .gitignore"
    fi

    # Add .haunt/ entries
    cat >> "$gitignore_path" << 'EOF'

# Haunt working files (ephemeral)
.haunt/plans/
.haunt/progress/
.haunt/completed/
.haunt/docs/

# Preserve tests and scripts (optionally shareable)
!.haunt/tests/
!.haunt/scripts/
!.haunt/README.md
EOF

    log_success "Updated .gitignore with .haunt/ entries."
}

perform_rollback() {
    print_header "Rolling Back Migration"

    # Find most recent backup
    local latest_backup
    latest_backup=$(find "$PROJECT_ROOT" -maxdepth 1 -type d -name ".haunt-backup-*" | sort -r | head -n 1)

    if [[ -z "$latest_backup" ]]; then
        log_error "No backup found for rollback."
        log_error "Backups are named: .haunt-backup-YYYYMMDD-HHMMSS"
        return 1
    fi

    log_info "Found backup: $latest_backup"

    local manifest="$latest_backup/rollback-manifest.txt"

    if [[ ! -f "$manifest" ]]; then
        log_error "Rollback manifest not found: $manifest"
        return 1
    fi

    # Read manifest and reverse moves
    local line_count=0
    while IFS='|' read -r dest src; do
        # Skip comments
        [[ "$dest" =~ ^# ]] && continue

        if [[ -f "$dest" ]]; then
            local src_dir
            src_dir="$(dirname "$src")"
            mkdir -p "$src_dir"

            mv "$dest" "$src"
            log_success "Restored: $dest → $src"
            line_count=$((line_count + 1))
        else
            log_warning "Destination file not found (skipping): $dest"
        fi
    done < "$manifest"

    log_success "Restored $line_count file(s) from backup."

    # Remove .haunt directory if empty
    if [[ -d "${PROJECT_ROOT}/.haunt" ]]; then
        if [[ -z "$(ls -A "${PROJECT_ROOT}/.haunt")" ]]; then
            rmdir "${PROJECT_ROOT}/.haunt"
            log_info "Removed empty .haunt/ directory."
        else
            log_warning ".haunt/ directory still contains files. Not removing."
        fi
    fi

    log_info "Rollback complete. Backup preserved at: $latest_backup"
}

print_summary() {
    print_header "Migration Summary"

    echo "Files moved:    $FILES_MOVED"
    echo "Files skipped:  $FILES_SKIPPED"
    echo "Directories:    $DIRS_CREATED"
    echo "Errors:         $ERRORS"
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        log_info "This was a dry-run. No files were actually moved."
        log_info "Run without --dry-run to perform the migration."
    elif [[ "$ROLLBACK" == true ]]; then
        log_success "Rollback completed successfully."
    elif [[ $ERRORS -eq 0 ]]; then
        log_success "Migration completed successfully!"

        if [[ "$NO_BACKUP" == false ]]; then
            log_info "Backup saved to: $BACKUP_DIR"
            log_info "To rollback: bash $0 --rollback"
        fi

        log_info ""
        log_info "Next steps:"
        log_info "  1. Verify migration: ls -la .haunt/"
        log_info "  2. Test your workflows with new paths"
        log_info "  3. Commit changes: git add .haunt/ .gitignore"
        log_info "  4. Remove backup once verified: rm -rf $BACKUP_DIR"
    else
        log_error "Migration completed with $ERRORS error(s)."
        log_error "Review errors above and retry."
    fi
}

#------------------------------------------------------------------------------
# Main Execution
#------------------------------------------------------------------------------

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                log_info "Dry-run mode enabled."
                shift
                ;;
            --rollback)
                ROLLBACK=true
                log_info "Rollback mode enabled."
                shift
                ;;
            --no-backup)
                NO_BACKUP=true
                log_info "Backup creation disabled."
                shift
                ;;
            -h|--help)
                cat << EOF
Usage: bash migrate-to-haunt.sh [OPTIONS]

Migrate existing Haunt files to .haunt/ structure.

Options:
  --dry-run       Preview changes without moving files
  --rollback      Reverse migration from most recent backup
  --no-backup     Skip backup creation (faster but riskier)
  -h, --help      Show this help message

Examples:
  bash migrate-to-haunt.sh --dry-run    # Preview changes
  bash migrate-to-haunt.sh              # Perform migration
  bash migrate-to-haunt.sh --rollback   # Undo migration

For more information, see:
  Haunt/docs/HAUNT-DIRECTORY-SPEC.md

EOF
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                log_error "Use --help for usage information."
                exit 1
                ;;
        esac
    done
}

main() {
    parse_arguments "$@"

    print_header "Haunt Migration to .haunt/ Structure"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "DRY-RUN MODE: No files will be moved."
    fi

    # Rollback mode
    if [[ "$ROLLBACK" == true ]]; then
        perform_rollback
        exit $?
    fi

    # Normal migration
    check_prerequisites || exit 1

    create_backup
    create_sdlc_structure

    migrate_plans
    migrate_progress
    migrate_completed
    migrate_tests
    migrate_initialization

    update_gitignore

    print_summary

    # Exit with error code if there were errors
    [[ $ERRORS -eq 0 ]] && exit 0 || exit 1
}

# Execute main function
main "$@"
