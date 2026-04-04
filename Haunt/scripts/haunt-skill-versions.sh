#!/bin/bash
set -euo pipefail

# haunt-skill-versions.sh
# Compare source vs deployed skill versions, flag mismatches.
#
# Usage:
#   bash Haunt/scripts/haunt-skill-versions.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HAUNT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "=== Skill Version Report ==="
echo ""

MISMATCH=0
NO_VERSION=0
TOTAL=0

printf "%-35s %-10s %-10s %s\n" "SKILL" "SOURCE" "DEPLOYED" "STATUS"
printf "%-35s %-10s %-10s %s\n" "-----" "------" "--------" "------"

for source_skill in "$HAUNT_DIR/skills"/gco-*/SKILL.md; do
    [[ -e "$source_skill" ]] || continue
    TOTAL=$((TOTAL + 1))

    skill_name=$(basename "$(dirname "$source_skill")")
    deployed_skill="$CLAUDE_DIR/skills/$skill_name/SKILL.md"

    # Extract version from source (between --- markers)
    source_version=$(sed -n '/^---$/,/^---$/p' "$source_skill" | grep -m1 '^version:' | sed 's/version:[[:space:]]*//' | tr -d '"' || echo "none")

    # Extract version from deployed
    if [[ -f "$deployed_skill" ]]; then
        deployed_version=$(sed -n '/^---$/,/^---$/p' "$deployed_skill" | grep -m1 '^version:' | sed 's/version:[[:space:]]*//' | tr -d '"' || echo "none")
    else
        deployed_version="not deployed"
    fi

    # Determine status
    if [[ "$source_version" == "none" ]] || [[ -z "$source_version" ]]; then
        status="⚠️ no version"
        NO_VERSION=$((NO_VERSION + 1))
    elif [[ "$deployed_version" == "not deployed" ]]; then
        status="⚠️ not deployed"
        MISMATCH=$((MISMATCH + 1))
    elif [[ "$source_version" != "$deployed_version" ]]; then
        status="⚠️ MISMATCH"
        MISMATCH=$((MISMATCH + 1))
    else
        status="✓"
    fi

    printf "%-35s %-10s %-10s %s\n" "$skill_name" "$source_version" "$deployed_version" "$status"
done

echo ""
echo "Total: $TOTAL skills"
echo "Mismatches: $MISMATCH"
echo "No version: $NO_VERSION"

if [[ $MISMATCH -gt 0 ]]; then
    echo ""
    echo "Run 'bash Haunt/scripts/setup-haunt.sh' to sync deployed versions."
fi
