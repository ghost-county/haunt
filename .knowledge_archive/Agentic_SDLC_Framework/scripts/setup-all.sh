#!/bin/bash
# scripts/setup-all.sh
# Comprehensive Agentic SDLC setup script
# This script sets up the complete Agentic SDLC framework including:
# - Global agents in ~/.claude/agents/
# - Infrastructure (NATS, MCP servers)
# - Project structure and configuration
# - Pre-commit hooks and pattern tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

success() { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BLUE}ℹ${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           Agentic SDLC Complete Setup                          ║"
echo "║                                                                 ║"
echo "║  This script will set up:                                      ║"
echo "║  • Global agents in ~/.claude/agents/                          ║"
echo "║  • NATS JetStream (optional)                                   ║"
echo "║  • MCP Memory Server                                           ║"
echo "║  • Context7 MCP Server                                         ║"
echo "║  • Project structure and configuration                         ║"
echo "║  • Pre-commit hooks and pattern tests                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# Phase 1: Prerequisites Check
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 1: Checking Prerequisites"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check Python
if python3 --version 2>/dev/null | grep -qE '3\.(11|12|13)'; then
    success "Python 3.11+ installed"
else
    warning "Python 3.11+ recommended (brew install python@3.11)"
fi

# Check Node
if node --version 2>/dev/null | grep -qE 'v(18|19|20|21|22)'; then
    success "Node.js 18+ installed"
else
    warning "Node.js 18+ recommended (brew install node@18)"
fi

# Check Git
if git config user.email > /dev/null 2>&1; then
    success "Git configured"
else
    warning "Git not configured - run: git config --global user.email 'you@example.com'"
fi

# Check Claude CLI
if which claude > /dev/null 2>&1; then
    success "Claude Code CLI installed"
else
    warning "Claude Code CLI not found (npm install -g @anthropic-ai/claude-code)"
fi

# Check NATS
if which nats-server > /dev/null 2>&1; then
    success "NATS Server installed"
else
    warning "NATS Server not installed (optional: brew install nats-server)"
fi

echo ""

# ============================================================================
# Phase 2: Create Global Agents
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 2: Creating Global Agents"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "$HOME/.claude/agents"
mkdir -p "$HOME/.claude/mcp-servers"

# Run the agent creation script
if [ -f "$SCRIPT_DIR/03-create-agents.sh" ]; then
    bash "$SCRIPT_DIR/03-create-agents.sh"
else
    info "Creating agents inline..."
    # Create agents inline if script doesn't exist
    bash -c 'source /dev/stdin' << 'AGENTS_SCRIPT'
# This is a fallback - normally 03-create-agents.sh handles this
mkdir -p "$HOME/.claude/agents"
echo "Agents would be created here..."
AGENTS_SCRIPT
fi

echo ""

# ============================================================================
# Phase 3: Infrastructure Setup
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3: Setting Up Infrastructure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create memory directory
mkdir -p "$HOME/.agent-memory"
success "Created ~/.agent-memory/"

# Copy memory server to global location
if [ -f "$SCRIPT_DIR/agent-memory-server.py" ]; then
    cp "$SCRIPT_DIR/agent-memory-server.py" "$HOME/.claude/mcp-servers/"
    success "Installed agent-memory-server.py"
fi

# Configure Context7 MCP Server
if which claude > /dev/null 2>&1; then
    info "Configuring Context7 MCP server..."
    claude mcp add --transport http context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: ctx7sk-8aa36368-67cf-4132-ba52-ee755a7cd710" 2>/dev/null && success "Context7 MCP server configured" || warning "Context7 MCP setup failed (may already exist)"
fi

# Start NATS if installed
if which nats-server > /dev/null 2>&1; then
    # Use 'nats stream ls' instead of 'nats server ping' (ping requires system account permissions)
    if ! nats stream ls > /dev/null 2>&1; then
        info "Starting NATS server..."
        # Kill any existing process on port 4222
        EXISTING_PID=$(lsof -ti:4222 2>/dev/null)
        if [ -n "$EXISTING_PID" ]; then
            kill -9 $EXISTING_PID 2>/dev/null
            sleep 1
        fi
        nats-server -js -p 4222 > /dev/null 2>&1 &
        sleep 2
        if nats stream ls > /dev/null 2>&1; then
            success "NATS server started"
            # Create streams
            info "Creating NATS streams..."
            nats stream add REQUIREMENTS \
                --subjects "work.requirements.*" \
                --storage file --replicas 1 --retention limits \
                --max-msgs 10000 --max-age 30d --discard old --defaults 2>/dev/null \
                && success "Created REQUIREMENTS stream" || warning "REQUIREMENTS stream may already exist"
            nats stream add WORK \
                --subjects "work.assigned.*,work.progress.*,work.complete.*" \
                --storage file --replicas 1 --retention limits \
                --max-msgs 50000 --max-age 7d --discard old --defaults 2>/dev/null \
                && success "Created WORK stream" || warning "WORK stream may already exist"
            nats stream add INTEGRATION \
                --subjects "work.integration.*" \
                --storage file --replicas 1 --retention limits \
                --max-msgs 10000 --max-age 7d --discard old --defaults 2>/dev/null \
                && success "Created INTEGRATION stream" || warning "INTEGRATION stream may already exist"
            nats stream add RELEASES \
                --subjects "work.releases.*" \
                --storage file --replicas 1 --retention limits \
                --max-msgs 5000 --max-age 30d --discard old --defaults 2>/dev/null \
                && success "Created RELEASES stream" || warning "RELEASES stream may already exist"
        else
            warning "NATS server failed to start"
        fi
    else
        success "NATS server already running"
    fi
fi

echo ""

# ============================================================================
# Phase 4: Project Structure
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 4: Creating Project Structure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create directories
mkdir -p .claude/agents
mkdir -p .claude/commands
mkdir -p plans
mkdir -p completed
mkdir -p progress
mkdir -p tests/patterns
mkdir -p tests/behavior
mkdir -p tests/e2e
mkdir -p scripts

success "Created project directories"

# Create roadmap if it doesn't exist
if [ ! -f plans/roadmap.md ]; then
    cat > plans/roadmap.md << 'EOF'
# Active Roadmap

> Last updated: $(date +%Y-%m-%d)
>
> Status: ⚪ Not Started | 🟡 In Progress | 🟢 Complete | 🔴 Blocked

---

## Current Phase: Setup

*Add requirements here*

---

## Backlog

*New ideas go here*

---

## Notes

- Effort sizing: S (1-4 hours) | M (4-8 hours)
- No L or XL - break those down further
EOF
    success "Created plans/roadmap.md"
fi

# Create feature contract if it doesn't exist
if [ ! -f plans/feature-contract.json ]; then
    cat > plans/feature-contract.json << 'EOF'
{
  "version": "1.0.0",
  "features": [],
  "metadata": {
    "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "note": "Acceptance criteria are IMMUTABLE - agents cannot modify them"
  }
}
EOF
    success "Created plans/feature-contract.json"
fi

# Create archive if it doesn't exist
if [ ! -f completed/roadmap-archive.md ]; then
    cat > completed/roadmap-archive.md << 'EOF'
# Roadmap Archive

> Historical record of completed work

---

*No completed items yet*
EOF
    success "Created completed/roadmap-archive.md"
fi

# Create MCP configuration
mkdir -p .claude
cat > .claude/mcp.json << 'EOF'
{
  "mcpServers": {
    "agent-memory": {
      "command": "python",
      "args": ["~/.claude/mcp-servers/agent-memory-server.py"],
      "env": {}
    }
  }
}
EOF
success "Created .claude/mcp.json"

echo ""

# ============================================================================
# Phase 5: Pre-commit Hooks
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 5: Setting Up Pre-commit Hooks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Install pre-commit if available
if python3 -c "import pre_commit" 2>/dev/null || pip install pre-commit 2>/dev/null; then
    success "pre-commit available"
else
    warning "pre-commit not installed (pip install pre-commit)"
fi

# Create pre-commit config
if [ ! -f .pre-commit-config.yaml ]; then
    cat > .pre-commit-config.yaml << 'EOF'
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
EOF
    success "Created .pre-commit-config.yaml"
fi

# Install hooks if in a git repo
if [ -d .git ]; then
    pre-commit install 2>/dev/null && success "Pre-commit hooks installed" || warning "Run 'pre-commit install' manually"
fi

# Create sample pattern test
if [ ! -f tests/patterns/test_no_silent_fallbacks.py ]; then
    cat > tests/patterns/test_no_silent_fallbacks.py << 'EOF'
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
    """Silent fallbacks (.get(x, default)) hide errors."""
    violations = []

    for filepath in get_python_files("src"):
        content = filepath.read_text()
        for line_num, line in enumerate(content.split("\n"), 1):
            if re.search(SILENT_FALLBACK_PATTERN, line):
                violations.append(f"{filepath}:{line_num}: {line.strip()}")

    assert not violations, (
        f"Silent fallbacks found:\n"
        + "\n".join(violations)
        + "\n\nUse explicit validation instead"
    )
EOF
    success "Created sample pattern test"
fi

echo ""

# ============================================================================
# Phase 6: Verification
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 6: Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_AGENTS=0
for agent in Project-Manager Dev-Backend Dev-Frontend Dev-Infrastructure Research-Analyst Research-Critic Code-Reviewer Release-Manager Agentic-SDLC-Initializer; do
    if [ -f "$HOME/.claude/agents/$agent.md" ]; then
        ((TOTAL_AGENTS++))
    fi
done

echo ""
echo "Global agents installed: $TOTAL_AGENTS/9"
echo "Memory server: $([ -f "$HOME/.claude/mcp-servers/agent-memory-server.py" ] && echo "✓" || echo "✗")"
echo "Project roadmap: $([ -f "plans/roadmap.md" ] && echo "✓" || echo "✗")"
echo "Feature contract: $([ -f "plans/feature-contract.json" ] && echo "✓" || echo "✗")"
echo "Pre-commit config: $([ -f ".pre-commit-config.yaml" ] && echo "✓" || echo "✗")"
echo "Pattern tests: $([ -d "tests/patterns" ] && echo "✓" || echo "✗")"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    Setup Complete!                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Review agents: ls ~/.claude/agents/"
echo "  2. Start NATS (if using): ./scripts/start-nats.sh"
echo "  3. Begin Phase 1: Create a simple requirement in plans/roadmap.md"
echo "  4. Test with: claude 'You are Dev-Backend. Check roadmap and complete REQ-001'"
echo ""
echo "Daily operations:"
echo "  • Morning review: ./scripts/morning-review.sh"
echo "  • Evening handoff: ./scripts/evening-handoff.sh"
echo "  • Verify setup: ./scripts/verify-setup.sh"
echo ""
echo "Documentation: docs/AgenticSDLC-Automated/"
