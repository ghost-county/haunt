#!/bin/bash
# scripts/04-implement-phases.sh
# Guide through Agentic SDLC implementation phases
set -e

echo "=== Agentic SDLC Phase Implementation ==="
echo ""
echo "This script guides you through the implementation phases."
echo "Each phase has its own verification before proceeding."
echo ""

# Phase 1
echo "=== PHASE 1: First Agent (Days 1-3) ==="
echo ""
echo "Goals:"
echo "  - Get one agent reliably committing code"
echo "  - Document any issues for prompt iteration"
echo ""
echo "Steps:"
echo "  1. Create simple REQ-001 in plans/roadmap.md"
echo "  2. Invoke Dev-Backend agent on the requirement"
echo "  3. Observe and document results"
echo "  4. Iterate on prompt until 3 requirements complete unassisted"
echo ""
read -p "Press Enter when Phase 1 is complete..."

# Phase 2
echo ""
echo "=== PHASE 2: Process Gates (Days 4-7) ==="
echo ""
echo "Goals:"
echo "  - Add automated enforcement (pre-commit hooks)"
echo "  - Create first pattern defeat tests"
echo "  - Add second agent"
echo ""

# Install pre-commit if not already
if ! pre-commit --version > /dev/null 2>&1; then
    echo "Installing pre-commit..."
    pip install pre-commit
fi

# Create pattern test directory
mkdir -p tests/patterns

# Create sample pattern test
if [ ! -f tests/patterns/test_no_silent_fallbacks.py ]; then
    cat > tests/patterns/test_no_silent_fallbacks.py << 'PYTEST_EOF'
"""
Defeat: Silent fallback pattern
Found: Initial setup
Agent(s): Dev-Backend
Impact: Validation errors were hidden
"""

import re
from pathlib import Path

SILENT_FALLBACK_PATTERN = r'\.get\([^,]+,\s*(0|None|\'\'|\"\"|\[\]|\{\})\)'

def get_python_files(directory: str = "src") -> list:
    """Get all Python files in directory."""
    src_path = Path(directory)
    if not src_path.exists():
        return []
    return list(src_path.rglob("*.py"))

def test_no_silent_fallbacks_in_codebase():
    """Silent fallbacks (.get(x, default)) hide errors. Use explicit validation."""
    violations = []

    for filepath in get_python_files("src"):
        content = filepath.read_text()
        for line_num, line in enumerate(content.split("\n"), 1):
            if re.search(SILENT_FALLBACK_PATTERN, line):
                violations.append(f"{filepath}:{line_num}: {line.strip()}")

    # This test passes if no violations found, or if src/ doesn't exist yet
    assert not violations, (
        f"Silent fallbacks found:\n"
        + "\n".join(violations)
        + "\n\nUse explicit validation: raise error if required key missing"
    )
PYTEST_EOF
    echo "✓ Created sample pattern test"
fi

# Create pre-commit config if not exists
if [ ! -f .pre-commit-config.yaml ]; then
    cat > .pre-commit-config.yaml << 'PRECOMMIT_EOF'
repos:
  - repo: local
    hooks:
      - id: pytest
        name: Run Tests
        entry: pytest tests/ -x -q
        language: system
        types: [python]
        pass_filenames: false
        stages: [commit]

      - id: patterns
        name: Pattern Detection
        entry: pytest tests/patterns/ -x -q
        language: system
        types: [python]
        pass_filenames: false
        stages: [commit]
PRECOMMIT_EOF
    echo "✓ Created .pre-commit-config.yaml"
fi

# Install hooks
pre-commit install 2>/dev/null || echo "Note: Run 'pre-commit install' after setting up git"

echo ""
echo "Pre-commit hooks installed."
echo ""
echo "Steps:"
echo "  1. Create defeat test in tests/patterns/"
echo "  2. Verify pre-commit rejects bad patterns"
echo "  3. Define second agent (Dev-Frontend or Dev-Infrastructure)"
echo "  4. Test second agent on independent requirement"
echo ""
read -p "Press Enter when Phase 2 is complete..."

# Continue for remaining phases...
echo ""
echo "=== Phases 3-6 require ongoing iteration ==="
echo ""
echo "Continue with manual implementation following:"
echo "  - 04-Implementation-Phases.md"
echo "  - 05-Operations.md"
echo "  - 06-Patterns-and-Defeats.md"
echo ""
echo "Phase Overview:"
echo "  Phase 3 (Week 2): Scale Team - Multiple agents in parallel"
echo "  Phase 4 (Week 3): Quality Gates - Multi-layer validation"
echo "  Phase 5 (Week 4): Evolution & Memory - Persistent memory, agent versioning"
echo "  Phase 6 (Week 5+): Mastery - Self-improving system"
echo ""
echo "Remember: Agent teams reach mastery in ~5 weeks."
echo "Trust the process!"
