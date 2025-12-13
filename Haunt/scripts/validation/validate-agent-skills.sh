#!/bin/bash

# Script: validate-agent-skills.sh
# Purpose: Validate that all skills referenced in agent definitions exist in Haunt/skills/ directory
# Exit: 0 if all references valid, 1 if any broken

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

AGENTS_DIR="${PROJECT_ROOT}/agents"
SKILLS_DIR="${PROJECT_ROOT}/skills"

# Validation counters
total_skills=0
valid_skills=0
invalid_skills=0

# Track unique skills to avoid duplicate checks (space-separated list)
checked_skills=""

echo "=== Haunted Skill Binding Validator ==="
echo "Agents Directory: ${AGENTS_DIR}"
echo "Skills Directory: ${SKILLS_DIR}"
echo ""

# Verify directories exist
if [ ! -d "${AGENTS_DIR}" ]; then
    echo -e "${RED}ERROR: Agents directory not found: ${AGENTS_DIR}${NC}"
    exit 1
fi

if [ ! -d "${SKILLS_DIR}" ]; then
    echo -e "${RED}ERROR: Skills directory not found: ${SKILLS_DIR}${NC}"
    exit 1
fi

# Find all agent markdown files
agent_files=$(find "${AGENTS_DIR}" -name "*.md" -type f)

if [ -z "${agent_files}" ]; then
    echo -e "${YELLOW}WARNING: No agent files found in ${AGENTS_DIR}${NC}"
    exit 0
fi

# Process each agent file
for agent_file in ${agent_files}; do
    agent_name=$(basename "${agent_file}" .md)
    echo -e "${YELLOW}Checking agent: ${agent_name}${NC}"

    # Extract skill references from "Skills Used" section
    # Pattern: Match lines with "- **skill-name**" format
    skills=$(grep -E '^\s*-\s+\*\*[a-z0-9-]+\*\*' "${agent_file}" | sed 's/^[^*]*\*\*\([a-z0-9-]*\)\*\*.*/\1/' || true)

    if [ -z "${skills}" ]; then
        echo "  No skills referenced"
        echo ""
        continue
    fi

    # Check each skill
    while IFS= read -r skill; do
        # Skip if already checked
        if echo " ${checked_skills} " | grep -q " ${skill} "; then
            continue
        fi

        checked_skills="${checked_skills} ${skill}"
        total_skills=$((total_skills + 1))

        # Check skills in Haunt/skills/
        skill_path="${SKILLS_DIR}/${skill}/SKILL.md"

        if [ -f "${skill_path}" ]; then
            echo -e "  ${skill}: ${GREEN}[EXISTS]${NC}"
            valid_skills=$((valid_skills + 1))
        else
            echo -e "  ${skill}: ${RED}[MISSING]${NC}"
            echo -e "    Expected: ${skill_path}"
            invalid_skills=$((invalid_skills + 1))
        fi
    done <<< "${skills}"

    echo ""
done

# Summary
echo "=== Séance Summary ==="
echo "Total unique skills summoned: ${total_skills}"
echo -e "Bound: ${GREEN}${valid_skills}${NC}"
echo -e "Lost to the void: ${RED}${invalid_skills}${NC}"

# Exit with appropriate code
if [ ${invalid_skills} -gt 0 ]; then
    echo ""
    echo -e "${RED}BINDING RITUAL FAILED: ${invalid_skills} skill(s) remain unbound${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}BINDING RITUAL COMPLETE: All skills successfully bound${NC}"
    exit 0
fi
