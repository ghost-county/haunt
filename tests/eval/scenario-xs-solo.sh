#!/bin/bash
# Scenario: XS Solo Task Infrastructure
# Checks that the harness infrastructure for solo-mode seance is intact.
# Validates artifact structure, not Claude execution quality.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
HAUNT_DIR="$REPO_ROOT/Haunt"
source "$(dirname "${BASH_SOURCE[0]}")/eval-lib.sh"

echo "Scenario: XS Solo Task Infrastructure"
echo "Checking harness structure for solo-mode seance..."

check_file ".haunt spec doc exists" "$HAUNT_DIR/docs/HAUNT-DIRECTORY-SPEC.md"
check_file "seance command exists" "$HAUNT_DIR/commands/seance.md"
check_file "gco-dev agent exists" "$HAUNT_DIR/agents/gco-dev.md"
check_file "completion-gate.sh exists" "$HAUNT_DIR/hooks/completion-gate.sh"
check_exec "completion-gate.sh is executable" "$HAUNT_DIR/hooks/completion-gate.sh"
check_file "observability-logger.sh exists" "$HAUNT_DIR/hooks/observability-logger.sh"
check_file "setup-haunt.sh exists" "$HAUNT_DIR/scripts/setup-haunt.sh"
check_exec "setup-haunt.sh is executable" "$HAUNT_DIR/scripts/setup-haunt.sh"
check_file "CLAUDE.md exists" "$REPO_ROOT/CLAUDE.md"

report_results
