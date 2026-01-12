#!/usr/bin/env bash
#
# validate-installed-skills.sh - Validate that skills are properly installed
#
# Validates that skills from Haunt/skills/ directory have been
# installed to the target location based on scope:
#   - global: ~/.claude/skills/
#   - project: ./.claude/skills/
#   - both: checks both locations
#
# Usage:
#   bash scripts/validate-installed-skills.sh [--scope=global|project|both]
#
# Exit codes:
#   0 - All skills are properly installed
#   1 - One or more skills are missing or invalid

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory (relative to script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_SKILLS_DIR="${PROJECT_ROOT}/skills"

# Target directories
GLOBAL_SKILLS_DIR="${HOME}/.claude/skills"
PROJECT_SKILLS_DIR="$(pwd)/.claude/skills"

# Default scope
SCOPE="global"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --scope=*)
            SCOPE="${1#*=}"
            if [[ "$SCOPE" != "global" && "$SCOPE" != "project" && "$SCOPE" != "both" ]]; then
                echo -e "${RED}ERROR: Invalid scope: ${SCOPE}${NC}"
                echo "Valid values: global, project, both"
                exit 1
            fi
            shift
            ;;
        --help|-h)
            echo "Usage: bash scripts/validate-installed-skills.sh [--scope=global|project|both]"
            echo ""
            echo "Options:"
            echo "  --scope=global   Check ~/.claude/skills/ (default)"
            echo "  --scope=project  Check ./.claude/skills/"
            echo "  --scope=both     Check both locations"
            exit 0
            ;;
        *)
            echo -e "${RED}ERROR: Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo "Divining Installed Haunted Skills"
echo "========================================"
echo ""
echo "Source Directory: ${SOURCE_SKILLS_DIR}"
echo "Scope: ${SCOPE}"
echo ""

# Check source directory exists
if [[ ! -d "${SOURCE_SKILLS_DIR}" ]]; then
    echo -e "${RED}ERROR: Source skills directory not found: ${SOURCE_SKILLS_DIR}${NC}"
    exit 1
fi

# Collect source skills
declare -a SOURCE_SKILLS=()
for skill_dir in "${SOURCE_SKILLS_DIR}"/*/; do
    if [[ -d "$skill_dir" && -f "${skill_dir}/SKILL.md" ]]; then
        SOURCE_SKILLS+=("$(basename "$skill_dir")")
    fi
done

if [[ ${#SOURCE_SKILLS[@]} -eq 0 ]]; then
    echo -e "${RED}ERROR: No valid skills found in source directory${NC}"
    exit 1
fi

echo "Source skills (${#SOURCE_SKILLS[@]}):"
for skill in "${SOURCE_SKILLS[@]}"; do
    echo "  - ${skill}"
done
echo ""

# Track validation results
TOTAL_CHECKED=0
PASSED=0
FAILED=0
MISSING=()
INVALID=()

# Function to validate skills in a directory
validate_skills_in_dir() {
    local target_dir="$1"
    local scope_name="$2"

    echo "Checking ${scope_name} installation: ${target_dir}"
    echo "----------------------------------------"

    if [[ ! -d "$target_dir" ]]; then
        echo -e "${RED}[FAIL] Directory does not exist: ${target_dir}${NC}"
        for skill in "${SOURCE_SKILLS[@]}"; do
            MISSING+=("${scope_name}:${skill}")
            ((TOTAL_CHECKED++))
        done
        ((FAILED += ${#SOURCE_SKILLS[@]}))
        return 1
    fi

    for skill in "${SOURCE_SKILLS[@]}"; do
        ((TOTAL_CHECKED++))
        local installed_skill_dir="${target_dir}/${skill}"
        local installed_skill_file="${installed_skill_dir}/SKILL.md"
        local source_skill_file="${SOURCE_SKILLS_DIR}/${skill}/SKILL.md"

        if [[ ! -d "$installed_skill_dir" ]]; then
            echo -e "${skill}: ${RED}[MISSING - directory not found]${NC}"
            MISSING+=("${scope_name}:${skill}")
            ((FAILED++))
            continue
        fi

        if [[ ! -f "$installed_skill_file" ]]; then
            echo -e "${skill}: ${RED}[INVALID - SKILL.md not found]${NC}"
            INVALID+=("${scope_name}:${skill}")
            ((FAILED++))
            continue
        fi

        # Compare with source to verify it's up to date
        if ! cmp -s "$source_skill_file" "$installed_skill_file"; then
            echo -e "${skill}: ${YELLOW}[OUTDATED - differs from source]${NC}"
            # Still count as passed but warn
            ((PASSED++))
        else
            echo -e "${skill}: ${GREEN}[PASS]${NC}"
            ((PASSED++))
        fi
    done

    echo ""
}

# Validate based on scope
if [[ "$SCOPE" == "global" || "$SCOPE" == "both" ]]; then
    validate_skills_in_dir "$GLOBAL_SKILLS_DIR" "global"
fi

if [[ "$SCOPE" == "project" || "$SCOPE" == "both" ]]; then
    validate_skills_in_dir "$PROJECT_SKILLS_DIR" "project"
fi

# Summary
echo "========================================"
echo "Validation Summary"
echo "========================================"
echo -e "Total checked: ${TOTAL_CHECKED}"
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}Missing Skills:${NC}"
    for item in "${MISSING[@]}"; do
        echo "  - ${item}"
    done
fi

if [[ ${#INVALID[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}Invalid Skills (missing SKILL.md):${NC}"
    for item in "${INVALID[@]}"; do
        echo "  - ${item}"
    done
fi

echo ""

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}BINDING RITUAL FAILED: ${FAILED} skill(s) not properly bound${NC}"
    echo ""
    echo "To fix, run:"
    if [[ "$SCOPE" == "global" ]]; then
        echo "  bash Haunt/scripts/setup-haunt.sh --scope=global --skills-only"
    elif [[ "$SCOPE" == "project" ]]; then
        echo "  bash Haunt/scripts/setup-haunt.sh --scope=project --skills-only"
    else
        echo "  bash Haunt/scripts/setup-haunt.sh --scope=both --skills-only"
    fi
    exit 1
fi

echo -e "${GREEN}All skills bound successfully!${NC}"
exit 0
