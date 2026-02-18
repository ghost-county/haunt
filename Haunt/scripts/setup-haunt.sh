#!/usr/bin/env bash
#
# setup-haunt.sh - Deploy Haunt dev guardrails to ~/.claude/
#
# Copies rules, skills, and commands from Haunt/ source to global Claude Code config.
#
# Usage: bash Haunt/scripts/setup-haunt.sh [--verify]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HAUNT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

ok() { echo -e "${GREEN}+${NC} $1"; }
fail() { echo -e "${RED}x${NC} $1"; }

# --- Verify mode ---
if [[ "${1:-}" == "--verify" ]]; then
    echo "Verifying Haunt deployment..."
    errors=0

    # Check rules
    rule_count=$(ls "$CLAUDE_DIR/rules"/gco-*.md 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$rule_count" -ge 5 ]]; then
        ok "Rules: $rule_count gco rules deployed"
    else
        fail "Rules: only $rule_count gco rules (expected 5)"
        errors=$((errors + 1))
    fi

    # Check skills
    skill_count=$(ls -d "$CLAUDE_DIR/skills"/gco-*/ 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$skill_count" -ge 14 ]]; then
        ok "Skills: $skill_count gco skills deployed"
    else
        fail "Skills: only $skill_count gco skills (expected 14)"
        errors=$((errors + 1))
    fi

    # Check commands
    cmd_count=$(ls "$CLAUDE_DIR/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$cmd_count" -ge 3 ]]; then
        ok "Commands: $cmd_count commands deployed"
    else
        fail "Commands: only $cmd_count commands (expected 3)"
        errors=$((errors + 1))
    fi

    # Validate each skill has SKILL.md
    for skill_dir in "$CLAUDE_DIR/skills"/gco-*/; do
        if [[ ! -f "$skill_dir/SKILL.md" ]]; then
            fail "Missing SKILL.md in $(basename "$skill_dir")"
            errors=$((errors + 1))
        fi
    done

    if [[ "$errors" -eq 0 ]]; then
        echo ""
        ok "All checks passed."
    else
        echo ""
        fail "$errors issues found. Re-run setup: bash Haunt/scripts/setup-haunt.sh"
        exit 1
    fi
    exit 0
fi

# --- Deploy ---
echo "Deploying Haunt dev guardrails..."

# Create directories
mkdir -p "$CLAUDE_DIR/rules" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/commands"

# Deploy rules
for rule in "$HAUNT_DIR/rules"/*.md; do
    cp "$rule" "$CLAUDE_DIR/rules/$(basename "$rule")"
done
ok "Rules deployed ($(ls "$HAUNT_DIR/rules"/*.md | wc -l | tr -d ' ') files)"

# Deploy skills (each is a directory with SKILL.md)
for skill_dir in "$HAUNT_DIR/skills"/gco-*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$CLAUDE_DIR/skills/$skill_name"
    cp -r "$skill_dir"/* "$CLAUDE_DIR/skills/$skill_name/"
done
ok "Skills deployed ($(ls -d "$HAUNT_DIR/skills"/gco-*/ | wc -l | tr -d ' ') skills)"

# Deploy upland-data-engineering skill if present
if [[ -d "$HAUNT_DIR/skills/upland-data-engineering" ]]; then
    mkdir -p "$CLAUDE_DIR/skills/upland-data-engineering"
    cp -r "$HAUNT_DIR/skills/upland-data-engineering"/* "$CLAUDE_DIR/skills/upland-data-engineering/"
    ok "Domain skill deployed (upland-data-engineering)"
fi

# Deploy commands
for cmd in "$HAUNT_DIR/commands"/*.md; do
    cp "$cmd" "$CLAUDE_DIR/commands/$(basename "$cmd")"
done
ok "Commands deployed ($(ls "$HAUNT_DIR/commands"/*.md | wc -l | tr -d ' ') files)"

echo ""
ok "Done. Verify with: bash Haunt/scripts/setup-haunt.sh --verify"
