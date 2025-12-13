#!/usr/bin/env bash
#
# validate-skills.sh - Validate skill file completeness and structure
#
# Validates that all workflow skills have required frontmatter and structure:
# - YAML frontmatter with 'name:' field
# - YAML frontmatter with 'description:' field
# - Description contains trigger keywords (evidence of when to invoke)
#
# Exit codes:
#   0 - All skills pass validation
#   1 - One or more skills fail validation

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory (relative to script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SKILLS_DIR="${PROJECT_ROOT}/skills"

echo "Divining All Haunted Skills"
echo "========================================"
echo ""
echo "Skills Directory: ${SKILLS_DIR}"
echo ""

# Track validation results
FAILED_SKILLS=()
PASSED_SKILLS=()

# Find all skill directories (excluding non-directory entries)
# shellcheck disable=SC2207
SKILL_DIRS=($(find "${SKILLS_DIR}" -maxdepth 1 -type d ! -name skills | sort))

# Validate each skill
for skill_dir in "${SKILL_DIRS[@]}"; do
    # Skip the Skills directory itself
    if [[ "${skill_dir}" == "${SKILLS_DIR}" ]]; then
        continue
    fi

    skill=$(basename "${skill_dir}")
    SKILL_FILE="${skill_dir}/SKILL.md"

    # Check if file exists
    if [[ ! -f "${SKILL_FILE}" ]]; then
        echo -e "${skill}: ${RED}[FAIL - FILE NOT FOUND]${NC}"
        FAILED_SKILLS+=("${skill}")
        continue
    fi

    # Check for 'name:' in frontmatter
    if ! grep -q '^name:' "${SKILL_FILE}"; then
        echo -e "${skill}: ${RED}[FAIL - MISSING 'name:' FIELD]${NC}"
        FAILED_SKILLS+=("${skill}")
        continue
    fi

    # Check for 'description:' in frontmatter
    if ! grep -q '^description:' "${SKILL_FILE}"; then
        echo -e "${skill}: ${RED}[FAIL - MISSING 'description:' FIELD]${NC}"
        FAILED_SKILLS+=("${skill}")
        continue
    fi

    # Extract description and check for trigger keywords
    # Description should contain words like: "trigger", "use when", "invoke when", or specific action words
    DESCRIPTION=$(grep '^description:' "${SKILL_FILE}" | cut -d':' -f2-)

    # Check if description contains trigger indicators or is sufficiently descriptive (>30 chars)
    if [[ ${#DESCRIPTION} -lt 30 ]]; then
        echo -e "${skill}: ${RED}[FAIL - DESCRIPTION TOO SHORT]${NC}"
        FAILED_SKILLS+=("${skill}")
        continue
    fi

    # All checks passed
    echo -e "${skill}: ${GREEN}[PASS]${NC}"
    PASSED_SKILLS+=("${skill}")
done

echo ""
echo "========================================"
echo "Séance Summary"
echo "========================================"
TOTAL_SKILLS=$((${#PASSED_SKILLS[@]} + ${#FAILED_SKILLS[@]}))
echo -e "Bound: ${GREEN}${#PASSED_SKILLS[@]}${NC}/${TOTAL_SKILLS}"
echo -e "Banished: ${RED}${#FAILED_SKILLS[@]}${NC}/${TOTAL_SKILLS}"

if [[ ${#FAILED_SKILLS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}Banished Skills:${NC}"
    for skill in "${FAILED_SKILLS[@]}"; do
        echo "  - ${skill}"
    done
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}All haunted skills bound successfully!${NC}"
exit 0
