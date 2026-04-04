#!/bin/bash
# Scenario: XS Solo Task Infrastructure
# Checks that the harness infrastructure for solo-mode seance is intact.
# Validates artifact structure, not Claude execution quality.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
HAUNT_DIR="$REPO_ROOT/Haunt"
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

echo "Scenario: XS Solo Task Infrastructure"
echo "Checking harness structure for solo-mode seance..."

# 1. Haunt directory structure
check ".haunt spec doc exists" "[[ -f '$HAUNT_DIR/docs/HAUNT-DIRECTORY-SPEC.md' ]]"

# 2. Seance command is present (solo mode is part of seance)
check "seance command exists" "[[ -f '$HAUNT_DIR/commands/seance.md' ]]"

# 3. Dev agent definition present
check "gco-dev agent exists" "[[ -f '$HAUNT_DIR/agents/gco-dev.md' ]]"

# 4. Completion gate hook deployed
check "completion-gate.sh exists" "[[ -f '$HAUNT_DIR/hooks/completion-gate.sh' ]]"
check "completion-gate.sh is executable" "[[ -x '$HAUNT_DIR/hooks/completion-gate.sh' ]]"

# 5. Observability logger hook deployed
check "observability-logger.sh exists" "[[ -f '$HAUNT_DIR/hooks/observability-logger.sh' ]]"

# 6. Setup script can be located (drives solo deployment)
check "setup-haunt.sh exists" "[[ -f '$HAUNT_DIR/scripts/setup-haunt.sh' ]]"
check "setup-haunt.sh is executable" "[[ -x '$HAUNT_DIR/scripts/setup-haunt.sh' ]]"

# 7. CLAUDE.md present (root context for solo agent)
check "CLAUDE.md exists" "[[ -f '$REPO_ROOT/CLAUDE.md' ]]"

echo ""
echo "Results: $PASS passed, $FAIL failed"

[[ $FAIL -eq 0 ]]
