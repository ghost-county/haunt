#!/usr/bin/env bash
#
# setup-precommit-hooks-addon.sh - Pre-commit Hooks Configuration
#
# This script adds pre-commit hooks functionality to the Haunt setup.
# It can be called from setup-agentic-sdlc.sh or run standalone.
#
# Usage: bash setup-precommit-hooks-addon.sh [--dry-run] [--verbose]

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Import color functions if available
if [ -f "${SCRIPT_DIR}/setup-agentic-sdlc.sh" ]; then
    source "${SCRIPT_DIR}/setup-agentic-sdlc.sh" 2>/dev/null || true
fi

# Fallback color functions if not imported
if ! type success &>/dev/null; then
    success() { echo "✓ $1"; }
    info() { echo "ℹ $1"; }
    warning() { echo "⚠ $1"; }
    error() { echo "✗ $1" >&2; }
    section() { echo ""; echo "========== $1 =========="; echo ""; }
fi

DRY_RUN=false
VERBOSE=false

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --verbose)
            VERBOSE=true
            ;;
    esac
done

# ============================================================================
# PRE-COMMIT HOOKS SETUP
# ============================================================================

setup_precommit_hooks() {
    section "Setting Up Pre-commit Hooks (Optional)"

    # -------------------------------------------------------------------------
    # Check if pre-commit is installed
    # -------------------------------------------------------------------------
    if ! command -v pre-commit &> /dev/null; then
        warning "pre-commit is NOT installed (optional)"
        info "  Install: pip install pre-commit"
        info "           brew install pre-commit  (macOS)"
        info "  Skipping pre-commit hooks setup"
        echo ""
        info "Note: The setup script works fine without pre-commit."
        info "Pre-commit hooks are optional for automatic pattern detection."
        return 0
    fi

    local precommit_version=$(pre-commit --version 2>/dev/null || echo "installed")
    success "pre-commit: ${precommit_version}"

    # -------------------------------------------------------------------------
    # Check if we're in a git repository
    # -------------------------------------------------------------------------
    if [[ ! -d "${PROJECT_ROOT}/.git" ]]; then
        warning "Not in a git repository - skipping pre-commit hooks"
        return 0
    fi

    # -------------------------------------------------------------------------
    # Create .pre-commit-config.yaml if not exists
    # -------------------------------------------------------------------------
    local precommit_config="${PROJECT_ROOT}/.pre-commit-config.yaml"

    if [[ ! -f "$precommit_config" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            info "[DRY RUN] Would create .pre-commit-config.yaml"
        else
            cat > "$precommit_config" << 'PRECOMMIT_EOF'
# Pre-commit hooks for Haunt
# See https://pre-commit.com for more information

repos:
  # Standard pre-commit hooks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: detect-private-key

  # Python code quality
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.9
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]

  # Pattern detection tests
  - repo: local
    hooks:
      - id: pattern-detection
        name: Anti-Pattern Detection
        entry: python -m pytest .haunt/tests/patterns/ -v
        language: system
        pass_filenames: false
        always_run: false
        files: \.(py|js|ts|go)$
PRECOMMIT_EOF
            success "Created .pre-commit-config.yaml"
        fi
    else
        info "Skipped: .pre-commit-config.yaml already exists"

        # Check if pattern detection hook exists
        if ! grep -q "pattern-detection" "$precommit_config"; then
            warning "  pattern-detection hook not found in existing config"
            info "  Consider adding pattern detection tests to your pre-commit config"
        fi
    fi

    # -------------------------------------------------------------------------
    # Create sample pattern test if .haunt/tests/patterns/ is empty
    # -------------------------------------------------------------------------
    local patterns_dir="${PROJECT_ROOT}/.haunt/tests/patterns"

    if [[ -d "$patterns_dir" ]]; then
        local test_count=$(find "$patterns_dir" -name "test_*.py" -type f 2>/dev/null | wc -l | tr -d ' ')

        if [[ $test_count -eq 0 ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                info "[DRY RUN] Would create sample pattern test in .haunt/tests/patterns/"
            else
                # Check if sample test was already created by main script
                if [[ ! -f "${patterns_dir}/test_sample_pattern.py" ]]; then
                    info "Sample pattern test should be in .haunt/tests/patterns/"
                    warning "  No pattern tests found - create tests in .haunt/tests/patterns/"
                else
                    success "Sample pattern test exists"
                fi
            fi
        else
            success "Found ${test_count} pattern test(s)"
        fi
    else
        warning ".haunt/tests/patterns/ directory not found"
        info "  Run full setup script to create project structure"
    fi

    # -------------------------------------------------------------------------
    # Install hooks in .git/hooks/
    # -------------------------------------------------------------------------
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would run: pre-commit install"
    else
        if pre-commit install; then
            success "Installed pre-commit hooks in .git/hooks/"
        else
            error "Failed to install pre-commit hooks"
            return 1
        fi
    fi

    # -------------------------------------------------------------------------
    # Optionally run hooks on all files
    # -------------------------------------------------------------------------
    echo ""
    if [[ "$DRY_RUN" == false ]]; then
        info "To run hooks on all files: pre-commit run --all-files"
        info "Hooks will automatically run on git commit"
    fi

    echo ""
    success "Pre-commit hooks setup complete!"
    info "Summary:"
    echo "  • Configuration: .pre-commit-config.yaml"
    echo "  • Hooks installed: .git/hooks/pre-commit"
    echo "  • Pattern tests: .haunt/tests/patterns/test_*.py"
    echo ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    setup_precommit_hooks
}

# Only run main if script is executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
