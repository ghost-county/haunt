#!/bin/bash
# Scenario: Planning Phase (Scrying) Infrastructure
# Tests that all planning-phase artifacts are in place.
# Validates agent definitions, skills, and command files — not Claude output.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
HAUNT_DIR="$REPO_ROOT/Haunt"
CLAUDE_DIR="$HOME/.claude"
PASS=0
FAIL=0

check() {
    local desc="$1"
    local condition="$2"
    if eval "$condition"; then
        echo "  ok  $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL $desc"
        FAIL=$((FAIL + 1))
    fi
}

check_syntax() {
    local desc="$1"
    local file="$2"
    if bash -n "$file" 2>/dev/null; then
        echo "  ok  $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL $desc (syntax error)"
        FAIL=$((FAIL + 1))
    fi
}

echo "Scenario: Scrying (Planning) Infrastructure"

# 1. PM agent definition (source)
check "gco-project-manager agent source exists" \
    "[[ -f '$HAUNT_DIR/agents/gco-project-manager.md' ]]"

# 2. PM agent deployed to ~/.claude
check "gco-project-manager deployed to ~/.claude/agents/" \
    "[[ -f '$CLAUDE_DIR/agents/gco-project-manager.md' ]]"

# 3. Requirements development skill (source)
check "gco-requirements-development skill source exists" \
    "[[ -f '$HAUNT_DIR/skills/gco-requirements-development/SKILL.md' ]]"

# 4. Requirements development skill deployed
check "gco-requirements-development skill deployed" \
    "[[ -f '$CLAUDE_DIR/skills/gco-requirements-development/SKILL.md' ]]"

# 5. Task decomposition skill (source)
check "gco-task-decomposition skill source exists" \
    "[[ -f '$HAUNT_DIR/skills/gco-task-decomposition/SKILL.md' ]]"

# 6. Task decomposition skill deployed
check "gco-task-decomposition skill deployed" \
    "[[ -f '$CLAUDE_DIR/skills/gco-task-decomposition/SKILL.md' ]]"

# 7. Seance command (source)
check "seance command source exists" \
    "[[ -f '$HAUNT_DIR/commands/seance.md' ]]"

# 8. Seance command deployed
check "seance command deployed to ~/.claude/commands/" \
    "[[ -f '$CLAUDE_DIR/commands/seance.md' ]]"

# 9. Seance orchestration skill (source)
check "gco-seance-orchestration skill source exists" \
    "[[ -f '$HAUNT_DIR/skills/gco-seance-orchestration/SKILL.md' ]]"

# 10. Phase enforcement hook — blocks dev agents before planning approval
check "phase-enforcement.sh exists" \
    "[[ -f '$HAUNT_DIR/hooks/phase-enforcement.sh' ]]"

# 11. Phase enforcement hook has valid bash syntax
check_syntax "phase-enforcement.sh has valid bash syntax" \
    "$HAUNT_DIR/hooks/phase-enforcement.sh"

# 12. CLAUDE.md accessible (root context injected at session start)
check "CLAUDE.md present at repo root" \
    "[[ -f '$REPO_ROOT/CLAUDE.md' ]]"

echo ""
echo "Results: $PASS passed, $FAIL failed"

[[ $FAIL -eq 0 ]]
