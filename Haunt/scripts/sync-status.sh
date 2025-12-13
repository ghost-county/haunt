#!/usr/bin/env bash

# ============================================================================
# sync-status.sh - Haunt Deployment Sync Status Checker
# ============================================================================
#
# Compares current Haunt/ source files against deployed manifest checksums
# to detect drift between source and deployed assets.
#
# Exit Codes:
#   0 - In sync (no drift detected)
#   1 - Drift detected (modified, added, or removed files)
#   2 - Error (no manifest found or other failure)
#
# Usage:
#   bash Haunt/scripts/sync-status.sh
#
# ============================================================================

set -eo pipefail

# Require bash 4+ for associative arrays, or fallback to temp files
BASH_VERSION_MAJOR="${BASH_VERSION%%.*}"
if [[ "$BASH_VERSION_MAJOR" -lt 4 ]]; then
    # Use temp files for older bash versions
    USE_TEMP_FILES=true
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT
else
    USE_TEMP_FILES=false
fi

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MANIFEST_FILE="${REPO_ROOT}/.haunt/.deployment-manifest.json"

# Source directories (from Haunt/)
PROJECT_AGENTS_DIR="${PROJECT_ROOT}/agents"
SOURCE_SKILLS_DIR="${PROJECT_ROOT}/skills"
SOURCE_COMMANDS_DIR="${PROJECT_ROOT}/commands"
SOURCE_RULES_DIR="${PROJECT_ROOT}/rules"

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

info() {
    echo -e "${CYAN}${1}${NC}"
}

success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

error() {
    echo -e "${RED}✗ ${1}${NC}"
}

section() {
    echo -e "\n${BOLD}${BLUE}=== ${1} ===${NC}\n"
}

# ============================================================================
# CHECKSUM COMPUTATION
# ============================================================================

compute_checksum() {
    local file="$1"
    shasum -a 256 "$file" 2>/dev/null | awk '{print $1}'
}

# ============================================================================
# MANIFEST PARSING
# ============================================================================

# Extract value from JSON (simple sed-based parsing, no jq dependency)
extract_json_value() {
    local key="$1"
    local json_file="$2"

    # Extract string values (POSIX-compatible sed)
    grep "\"${key}\":" "$json_file" | head -1 | sed 's/.*"'"${key}"'": "\([^"]*\)".*/\1/'
}

# Get checksum for a file from manifest
get_manifest_checksum() {
    local rel_path="$1"
    local manifest="$2"

    # Extract checksum for this file (POSIX-compatible sed)
    grep "\"${rel_path}\":" "$manifest" 2>/dev/null | sed 's/.*"sha256:\([^"]*\)".*/\1/'
}

# List all files in manifest
list_manifest_files() {
    local manifest="$1"

    # Extract all file paths (keys in the "files" object) - POSIX-compatible sed
    grep '^\s*"[^"]*": "sha256:' "$manifest" | sed 's/^[[:space:]]*"\([^"]*\)".*/\1/'
}

# ============================================================================
# SOURCE FILE SCANNING
# ============================================================================

# Build list of current source files with checksums
# Output format: rel_path|checksum (one per line)
scan_source_files() {
    local output_file="$1"

    # Scan agents
    if [[ -d "$PROJECT_AGENTS_DIR" ]]; then
        for file in "$PROJECT_AGENTS_DIR"/*.md; do
            if [[ -f "$file" ]]; then
                local rel_path="agents/$(basename "$file")"
                local checksum=$(compute_checksum "$file")
                echo "${rel_path}|${checksum}" >> "$output_file"
            fi
        done
    fi

    # Scan rules
    if [[ -d "$SOURCE_RULES_DIR" ]]; then
        for file in "$SOURCE_RULES_DIR"/*.md; do
            if [[ -f "$file" ]]; then
                local rel_path="rules/$(basename "$file")"
                local checksum=$(compute_checksum "$file")
                echo "${rel_path}|${checksum}" >> "$output_file"
            fi
        done
    fi

    # Scan skills (only SKILL.md files)
    if [[ -d "$SOURCE_SKILLS_DIR" ]]; then
        for skill_dir in "$SOURCE_SKILLS_DIR"/*/; do
            if [[ -d "$skill_dir" ]] && [[ -f "${skill_dir}SKILL.md" ]]; then
                local skill_name=$(basename "$skill_dir")
                local rel_path="skills/${skill_name}/SKILL.md"
                local checksum=$(compute_checksum "${skill_dir}SKILL.md")
                echo "${rel_path}|${checksum}" >> "$output_file"
            fi
        done
    fi

    # Scan commands
    if [[ -d "$SOURCE_COMMANDS_DIR" ]]; then
        for file in "$SOURCE_COMMANDS_DIR"/*.md; do
            if [[ -f "$file" ]]; then
                local rel_path="commands/$(basename "$file")"
                local checksum=$(compute_checksum "$file")
                echo "${rel_path}|${checksum}" >> "$output_file"
            fi
        done
    fi
}

# ============================================================================
# DRIFT DETECTION
# ============================================================================

detect_drift() {
    local manifest="$1"

    # Temporary files for tracking
    local source_files="${TEMP_DIR}/source_files.txt"
    local manifest_files="${TEMP_DIR}/manifest_files.txt"
    local modified_files="${TEMP_DIR}/modified.txt"
    local added_files="${TEMP_DIR}/added.txt"
    local removed_files="${TEMP_DIR}/removed.txt"

    # Initialize temp files
    touch "$source_files" "$manifest_files" "$modified_files" "$added_files" "$removed_files"

    # Build source files index
    scan_source_files "$source_files"

    # Build manifest files list
    list_manifest_files "$manifest" > "$manifest_files"

    # Compare source files against manifest
    while IFS='|' read -r rel_path source_checksum; do
        local manifest_checksum=$(get_manifest_checksum "$rel_path" "$manifest")

        if [[ -z "$manifest_checksum" ]]; then
            # File exists in source but not in manifest
            echo "$rel_path" >> "$added_files"
        elif [[ "$source_checksum" != "$manifest_checksum" ]]; then
            # File exists in both but checksums differ
            echo "$rel_path" >> "$modified_files"
        fi
    done < "$source_files"

    # Find removed files (in manifest but not in source)
    while IFS= read -r manifest_file; do
        # Check if this file exists in source
        if ! grep -q "^${manifest_file}|" "$source_files"; then
            echo "$manifest_file" >> "$removed_files"
        fi
    done < "$manifest_files"

    # Count differences
    local modified_count=$(wc -l < "$modified_files" | tr -d ' ')
    local added_count=$(wc -l < "$added_files" | tr -d ' ')
    local removed_count=$(wc -l < "$removed_files" | tr -d ' ')
    local total_drift=$((modified_count + added_count + removed_count))

    if [[ $total_drift -eq 0 ]]; then
        return 0  # In sync
    else
        # Print drift details
        echo ""

        if [[ $modified_count -gt 0 ]]; then
            warning "Modified (${modified_count}):"
            while IFS= read -r file; do
                echo "  - $file"
            done < "$modified_files"
            echo ""
        fi

        if [[ $added_count -gt 0 ]]; then
            warning "Added (${added_count}):"
            while IFS= read -r file; do
                echo "  - $file"
            done < "$added_files"
            echo ""
        fi

        if [[ $removed_count -gt 0 ]]; then
            warning "Removed (${removed_count}):"
            while IFS= read -r file; do
                echo "  - $file"
            done < "$removed_files"
            echo ""
        fi

        return 1  # Drift detected
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    section "Haunt Sync Status"

    # Check if manifest exists
    if [[ ! -f "$MANIFEST_FILE" ]]; then
        error "No deployment manifest found"
        echo ""
        info "Expected location: ${MANIFEST_FILE}"
        echo ""
        info "Run 'bash Haunt/scripts/setup-haunt.sh' to deploy and generate manifest."
        echo ""
        return 2
    fi

    # Extract manifest metadata
    local deployed_at=$(extract_json_value "deployed_at" "$MANIFEST_FILE")
    local source_path=$(extract_json_value "source_path" "$MANIFEST_FILE")
    local version=$(extract_json_value "version" "$MANIFEST_FILE")
    local scope=$(extract_json_value "scope" "$MANIFEST_FILE")

    # Count files in manifest
    local file_count=$(list_manifest_files "$MANIFEST_FILE" | wc -l | tr -d ' ')

    # Detect drift
    if detect_drift "$MANIFEST_FILE"; then
        # In sync
        success "Status: IN SYNC"
        echo ""
        info "Deployed: ${deployed_at}"
        info "Files tracked: ${file_count}"
        info "Source: ${source_path}"
        info "Scope: ${scope}"
        echo ""
        return 0
    else
        # Drift detected
        error "Status: DRIFT DETECTED"
        echo ""
        info "Deployed: ${deployed_at}"
        info "Files tracked: ${file_count}"
        info "Source: ${source_path}"
        info "Scope: ${scope}"
        echo ""
        echo -e "${YELLOW}Run 'bash Haunt/scripts/setup-haunt.sh' to sync.${NC}"
        echo ""
        return 1
    fi
}

# Execute main function
main "$@"
