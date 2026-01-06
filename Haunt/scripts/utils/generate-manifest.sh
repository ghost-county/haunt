#!/usr/bin/env bash
# generate-manifest.sh - Generate Haunt manifest active sections from filesystem
#
# PURPOSE:
#   Auto-generate the active sections (agents, rules, skills, commands) of
#   Haunt/manifest.yaml by scanning filesystem. PRESERVES the deprecated section.
#
# USAGE:
#   bash Haunt/scripts/utils/generate-manifest.sh          # Output to stdout
#   bash Haunt/scripts/utils/generate-manifest.sh --update # Update manifest.yaml
#
# WORKFLOW:
#   1. Scan Haunt/{agents,rules,skills,commands}/ for active objects
#   2. Generate YAML for active sections (with schema documentation)
#   3. PRESERVE existing deprecated section (never auto-generate)
#   4. Update manifest.yaml (if --update) or output to stdout (default)
#
# NON-NEGOTIABLE:
#   - NEVER modify or regenerate the deprecated section
#   - ALWAYS preserve deprecated entries exactly as written
#   - ONLY regenerate active sections (agents, rules, skills, commands)

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST_PATH="$PROJECT_ROOT/manifest.yaml"
UPDATE_MODE=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --update)
            UPDATE_MODE=true
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            echo "Usage: $0 [--update]" >&2
            exit 1
            ;;
    esac
done

# ============================================================================
# HEADER TEMPLATE
# ============================================================================

generate_header() {
    cat <<'EOF'
# Haunt Object Manifest
# Single source of truth for all Haunt framework assets (agents, rules, skills, commands)
#
# PURPOSE:
#   - Define all active Haunt objects with their source paths and deployment scope
#   - Track deprecated objects for automatic cleanup
#   - Enable verification that deployed objects match source of truth
#
# SCHEMA:
#   Active Sections (agents, rules, skills, commands):
#     - name: Base filename without extension (e.g., "gco-dev" not "gco-dev.md")
#     - scope: Where to deploy (global | project | both)
#       - global: Deploy to ~/.claude/ only
#       - project: Deploy to .claude/ only (project-specific customization)
#       - both: Deploy to both locations
#     - source: Relative path from Haunt/ directory to source file/directory
#
#   Deprecated Section:
#     - type: Type of object (agent | rule | skill | command)
#     - name: Object name (as it appears in ~/.claude/ or .claude/)
#     - removed: ISO date when deprecated (YYYY-MM-DD)
#     - reason: Brief explanation of why deprecated
#
# MAINTENANCE:
#   - Active sections: Auto-generated via `bash Haunt/scripts/utils/generate-manifest.sh`
#   - Deprecated section: MANUALLY maintained (never auto-generated)
#   - Update workflow:
#     1. Add/remove files in Haunt/agents/, rules/, skills/, commands/
#     2. Run generator to update active sections
#     3. Manually add deprecated entries when removing objects
#     4. Run setup-haunt.sh --clean to remove deprecated objects

version: "2.0"
updated: "$(date +%Y-%m-%d)"
generated_by: "Haunt/scripts/utils/generate-manifest.sh"
EOF
}

# ============================================================================
# SECTION GENERATORS
# ============================================================================

generate_agents_section() {
    echo ""
    echo "# =============================================================================="
    echo "# AGENTS - Character sheets for agent personas"
    echo "# =============================================================================="
    echo ""
    echo "agents:"

    if [[ -d "$PROJECT_ROOT/agents" ]]; then
        find "$PROJECT_ROOT/agents" -maxdepth 1 -name "gco-*.md" -type f | sort | while read -r file; do
            local basename=$(basename "$file" .md)
            echo "  - name: $basename"
            echo "    scope: global"
            echo "    source: agents/$(basename "$file")"
            echo ""
        done
    else
        echo "  []"
        echo ""
    fi
}

generate_rules_section() {
    echo "# =============================================================================="
    echo "# RULES - Invariant enforcement protocols"
    echo "# =============================================================================="
    echo ""
    echo "rules:"

    if [[ -d "$PROJECT_ROOT/rules" ]]; then
        find "$PROJECT_ROOT/rules" -maxdepth 1 -name "gco-*.md" -type f | sort | while read -r file; do
            local basename=$(basename "$file" .md)
            echo "  - name: $basename"
            echo "    scope: global"
            echo "    source: rules/$(basename "$file")"
            echo ""
        done
    else
        echo "  []"
        echo ""
    fi
}

generate_skills_section() {
    echo "# =============================================================================="
    echo "# SKILLS - On-demand SDLC methodology guidance"
    echo "# =============================================================================="
    echo ""
    echo "skills:"

    if [[ -d "$PROJECT_ROOT/skills" ]]; then
        find "$PROJECT_ROOT/skills" -maxdepth 1 -name "gco-*" -type d | sort | while read -r dir; do
            local basename=$(basename "$dir")
            echo "  - name: $basename"
            echo "    scope: global"
            echo "    source: skills/$basename/"
            echo ""
        done
    else
        echo "  []"
        echo ""
    fi
}

generate_commands_section() {
    echo "# =============================================================================="
    echo "# COMMANDS - Workflow automation commands"
    echo "# =============================================================================="
    echo ""
    echo "commands:"

    if [[ -d "$PROJECT_ROOT/commands" ]]; then
        find "$PROJECT_ROOT/commands" -maxdepth 1 -name "*.md" -type f | sort | while read -r file; do
            local basename=$(basename "$file" .md)
            echo "  - name: $basename"
            echo "    scope: global"
            echo "    source: commands/$(basename "$file")"
            echo ""
        done
    else
        echo "  []"
        echo ""
    fi
}

# ============================================================================
# DEPRECATED SECTION PRESERVATION
# ============================================================================

extract_deprecated_section() {
    if [[ ! -f "$MANIFEST_PATH" ]]; then
        # No existing manifest, generate default empty deprecated section
        cat <<'EOF'

# ==============================================================================
# DEPRECATED - Objects removed from framework, marked for cleanup
# ==============================================================================
#
# When removing Haunt objects:
# 1. Delete source file/directory from Haunt/
# 2. Regenerate manifest to remove from active sections
# 3. Add entry here with type, name, removed date, reason
# 4. Run `bash Haunt/scripts/setup-haunt.sh --clean` to remove from deployments
#
# Deprecated entries are NEVER auto-generated - manual maintenance only.

deprecated: []

# Example deprecated entry format:
#   - type: skill
#     name: git-push
#     removed: "2026-01-05"
#     reason: "Redundant - command exists at commands/git-push.md"
EOF
        return
    fi

    # Extract everything from "deprecated:" to end of file
    awk '/^deprecated:/ {found=1} found {print}' "$MANIFEST_PATH"
}

# ============================================================================
# MAIN GENERATOR
# ============================================================================

generate_manifest() {
    generate_header
    generate_agents_section
    generate_rules_section
    generate_skills_section
    generate_commands_section
    extract_deprecated_section
}

# ============================================================================
# EXECUTION
# ============================================================================

if [[ "$UPDATE_MODE" == true ]]; then
    echo "Generating manifest from filesystem..." >&2
    TEMP_FILE=$(mktemp)
    trap "rm -f $TEMP_FILE" EXIT

    generate_manifest > "$TEMP_FILE"

    # Atomic update (write to temp, then move)
    mv "$TEMP_FILE" "$MANIFEST_PATH"
    echo "Updated: $MANIFEST_PATH" >&2
    echo "Updated: $(date +%Y-%m-%d)" >&2
else
    generate_manifest
fi
