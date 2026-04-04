#!/bin/bash
# Scenario: Planning Phase (Scrying) Infrastructure
# Tests that all planning-phase artifacts are in place.
# Validates agent definitions, skills, and command files — not Claude output.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
HAUNT_DIR="$REPO_ROOT/Haunt"
CLAUDE_DIR="$HOME/.claude"
source "$(dirname "${BASH_SOURCE[0]}")/eval-lib.sh"

echo "Scenario: Scrying (Planning) Infrastructure"

check_file "gco-project-manager agent source exists" \
    "$HAUNT_DIR/agents/gco-project-manager.md"
check_file "gco-project-manager deployed to ~/.claude/agents/" \
    "$CLAUDE_DIR/agents/gco-project-manager.md"
check_file "gco-requirements-development skill source exists" \
    "$HAUNT_DIR/skills/gco-requirements-development/SKILL.md"
check_file "gco-requirements-development skill deployed" \
    "$CLAUDE_DIR/skills/gco-requirements-development/SKILL.md"
check_file "gco-task-decomposition skill source exists" \
    "$HAUNT_DIR/skills/gco-task-decomposition/SKILL.md"
check_file "gco-task-decomposition skill deployed" \
    "$CLAUDE_DIR/skills/gco-task-decomposition/SKILL.md"
check_file "seance command source exists" \
    "$HAUNT_DIR/commands/seance.md"
check_file "seance command deployed to ~/.claude/commands/" \
    "$CLAUDE_DIR/commands/seance.md"
check_file "gco-seance-orchestration skill source exists" \
    "$HAUNT_DIR/skills/gco-seance-orchestration/SKILL.md"
check_file "phase-enforcement.sh exists" \
    "$HAUNT_DIR/hooks/phase-enforcement.sh"
check_syntax "phase-enforcement.sh has valid bash syntax" \
    "$HAUNT_DIR/hooks/phase-enforcement.sh"
check_file "CLAUDE.md present at repo root" \
    "$REPO_ROOT/CLAUDE.md"

report_results
