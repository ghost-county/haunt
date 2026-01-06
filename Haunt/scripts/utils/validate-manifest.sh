#!/usr/bin/env bash
# validate-manifest.sh - Validate manifest integrity
#
# USAGE:
#   bash Haunt/scripts/utils/validate-manifest.sh
#
# CHECKS:
#   - All active objects in manifest exist in filesystem
#   - All filesystem objects are listed in manifest
#   - No duplicate entries
#   - Valid YAML structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST_PATH="$PROJECT_ROOT/manifest.yaml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

errors=0
warnings=0

error() {
    echo -e "${RED}✗${NC} $1"
    ((errors++))
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((warnings++))
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

echo "Validating Haunt manifest..."
echo ""

# Check manifest exists
if [[ ! -f "$MANIFEST_PATH" ]]; then
    error "Manifest not found: $MANIFEST_PATH"
    exit 1
fi

success "Manifest found"

# Extract manifest entries using awk
manifest_agents=$(awk '/^agents:/{in_section=1; next} /^[a-z]+:/{in_section=0} in_section && /  - name:/{sub(/.*name: */, ""); print}' "$MANIFEST_PATH")
manifest_rules=$(awk '/^rules:/{in_section=1; next} /^[a-z]+:/{in_section=0} in_section && /  - name:/{sub(/.*name: */, ""); print}' "$MANIFEST_PATH")
manifest_skills=$(awk '/^skills:/{in_section=1; next} /^[a-z]+:/{in_section=0} in_section && /  - name:/{sub(/.*name: */, ""); print}' "$MANIFEST_PATH")
manifest_commands=$(awk '/^commands:/{in_section=1; next} /^[a-z]+:/{in_section=0} in_section && /  - name:/{sub(/.*name: */, ""); print}' "$MANIFEST_PATH")

# Validate agents
echo ""
echo "Validating agents..."
while IFS= read -r agent; do
    [[ -z "$agent" ]] && continue
    if [[ -f "$PROJECT_ROOT/agents/${agent}.md" ]]; then
        success "Agent $agent exists"
    else
        error "Agent $agent listed in manifest but not found in filesystem"
    fi
done <<< "$manifest_agents"

# Check for unlisted agents
if [[ -d "$PROJECT_ROOT/agents" ]]; then
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        agent_name=$(basename "$file" .md)
        if ! grep -q "name: $agent_name" "$MANIFEST_PATH"; then
            warning "Agent $agent_name exists in filesystem but not in manifest"
        fi
    done < <(find "$PROJECT_ROOT/agents" -maxdepth 1 -name "gco-*.md" -type f)
fi

# Validate rules
echo ""
echo "Validating rules..."
while IFS= read -r rule; do
    [[ -z "$rule" ]] && continue
    if [[ -f "$PROJECT_ROOT/rules/${rule}.md" ]]; then
        success "Rule $rule exists"
    else
        error "Rule $rule listed in manifest but not found in filesystem"
    fi
done <<< "$manifest_rules"

# Check for unlisted rules
if [[ -d "$PROJECT_ROOT/rules" ]]; then
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        rule_name=$(basename "$file" .md)
        if ! grep -q "name: $rule_name" "$MANIFEST_PATH"; then
            warning "Rule $rule_name exists in filesystem but not in manifest"
        fi
    done < <(find "$PROJECT_ROOT/rules" -maxdepth 1 -name "gco-*.md" -type f)
fi

# Validate skills
echo ""
echo "Validating skills..."
while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    if [[ -d "$PROJECT_ROOT/skills/$skill" ]]; then
        success "Skill $skill exists"
    else
        error "Skill $skill listed in manifest but not found in filesystem"
    fi
done <<< "$manifest_skills"

# Check for unlisted skills
if [[ -d "$PROJECT_ROOT/skills" ]]; then
    while IFS= read -r dir; do
        [[ -z "$dir" ]] && continue
        skill_name=$(basename "$dir")
        if ! grep -q "name: $skill_name" "$MANIFEST_PATH"; then
            warning "Skill $skill_name exists in filesystem but not in manifest"
        fi
    done < <(find "$PROJECT_ROOT/skills" -maxdepth 1 -name "gco-*" -type d)
fi

# Validate commands
echo ""
echo "Validating commands..."
while IFS= read -r command; do
    [[ -z "$command" ]] && continue
    if [[ -f "$PROJECT_ROOT/commands/${command}.md" ]]; then
        success "Command $command exists"
    else
        error "Command $command listed in manifest but not found in filesystem"
    fi
done <<< "$manifest_commands"

# Check for unlisted commands
if [[ -d "$PROJECT_ROOT/commands" ]]; then
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        command_name=$(basename "$file" .md)
        if ! grep -q "name: $command_name" "$MANIFEST_PATH"; then
            warning "Command $command_name exists in filesystem but not in manifest"
        fi
    done < <(find "$PROJECT_ROOT/commands" -maxdepth 1 -name "*.md" -type f)
fi

# Summary
echo ""
echo "========================================="
if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
    echo -e "${GREEN}✓ Manifest validation passed${NC}"
    exit 0
elif [[ $errors -eq 0 ]]; then
    echo -e "${YELLOW}⚠ Manifest validation passed with $warnings warning(s)${NC}"
    exit 0
else
    echo -e "${RED}✗ Manifest validation failed with $errors error(s) and $warnings warning(s)${NC}"
    exit 1
fi
