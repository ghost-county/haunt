# 01: Prerequisites

> Everything you need before starting an Agentic SDLC implementation.

---

## Overview

| Item | Purpose |
|------|---------|
| **Time Required** | 30 minutes (manual) / 5 minutes (scripted) |
| **Output** | Development environment ready for agent deployment |
| **Automation** | `scripts/01-install-prerequisites.sh` |

---

## Quick Check: Already Set Up?

Run this to verify your environment:

```bash
# Check all prerequisites
./AgenticSDLC-Unified/scripts/check-prerequisites.sh

# Expected output:
# ✓ Python 3.11+
# ✓ Node.js 18+
# ✓ Git configured
# ✓ Claude API access
# ✓ NATS installed
# ✓ Required Python packages
```

If all checks pass, skip to [02-Infrastructure](02-Infrastructure.md).

---

## Required Components

### 1. Python 3.11+

**Why:** Agent scripts, MCP servers, and automation tools use Python.

**Check:**
```bash
python3 --version
# Expected: Python 3.11.x or higher
```

**Install (if needed):**

```bash
# macOS (Homebrew)
brew install python@3.11

# Ubuntu/Debian
sudo apt update && sudo apt install python3.11 python3.11-venv

# Windows (winget)
winget install Python.Python.3.11
```

---

### 2. Node.js 18+

**Why:** NATS CLI tools and some agent tooling use Node.

**Check:**
```bash
node --version
# Expected: v18.x.x or higher
```

**Install (if needed):**

```bash
# macOS (Homebrew)
brew install node@18

# Ubuntu/Debian (via nvm - recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18

# Windows (winget)
winget install OpenJS.NodeJS.LTS
```

---

### 3. Git Configuration

**Why:** Agents commit code. Git must be configured with valid credentials.

**Check:**
```bash
git config user.name && git config user.email
# Expected: Your name and email
```

**Configure (if needed):**

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# For agent commits, consider a dedicated agent identity:
# git config --global user.name "AI Agent Team"
# git config --global user.email "agents@yourcompany.com"
```

---

### 4. Claude API Access

**Why:** Agents are powered by Claude. You need API access or Claude Pro.

**Options:**

| Method | Setup |
|--------|-------|
| **Claude Pro** | Subscribe at claude.ai, use Claude Code CLI |
| **API Key** | Get key at console.anthropic.com |
| **Claude Code** | Install with `npm install -g @anthropic-ai/claude-code` |

**Check (Claude Code):**
```bash
claude --version
# Expected: claude-code version X.X.X
```

**Check (API Key):**
```bash
echo $ANTHROPIC_API_KEY
# Expected: sk-ant-... (your API key)
```

**Configure API Key (if needed):**

```bash
# Add to your shell profile (.bashrc, .zshrc, etc.)
export ANTHROPIC_API_KEY="sk-ant-your-key-here"

# Or create .env file in project root
echo 'ANTHROPIC_API_KEY=sk-ant-your-key-here' > .env
```

---

### 5. NATS Server

**Why:** Agent-to-agent communication uses NATS JetStream for message queues.

**Check:**
```bash
nats-server --version
# Expected: nats-server: vX.X.X
```

**Install (if needed):**

```bash
# macOS (Homebrew)
brew install nats-server

# Ubuntu/Debian
curl -L https://github.com/nats-io/nats-server/releases/download/v2.10.7/nats-server-v2.10.7-linux-amd64.tar.gz | tar xz
sudo mv nats-server-v2.10.7-linux-amd64/nats-server /usr/local/bin/

# Docker (alternative)
docker pull nats:latest
```

**Install NATS CLI:**

```bash
# macOS (Homebrew)
brew tap nats-io/nats-tools
brew install nats-io/nats-tools/nats

# Direct download
curl -L https://github.com/nats-io/natscli/releases/latest/download/nats-0.0.35-linux-amd64.zip -o nats.zip
unzip nats.zip && sudo mv nats /usr/local/bin/
```

---

### 6. Python Packages

**Why:** Agent memory, MCP servers, and utilities require these packages.

**Required packages:**

```txt
# requirements-agentic.txt
nats-py>=2.6.0          # NATS client for Python
mcp>=1.0.0              # Model Context Protocol
fastmcp>=0.1.0          # Fast MCP server implementation
pydantic>=2.0.0         # Data validation
httpx>=0.25.0           # HTTP client
pytest>=7.0.0           # Testing framework
pytest-asyncio>=0.21.0  # Async test support
pre-commit>=3.0.0       # Git hooks
```

**Install:**

```bash
# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\activate on Windows

# Install packages
pip install nats-py mcp fastmcp pydantic httpx pytest pytest-asyncio pre-commit

# Or use requirements file
pip install -r AgenticSDLC-Unified/requirements-agentic.txt
```

---

## Directory Structure

Create the required directory structure:

```bash
# Automated
./AgenticSDLC-Unified/scripts/create-directories.sh

# Manual
mkdir -p .claude/agents
mkdir -p .claude/commands
mkdir -p plans
mkdir -p completed
mkdir -p tests/patterns
mkdir -p tests/behavior
mkdir -p tests/e2e
mkdir -p scripts
```

**Expected structure:**

```
your-project/
├── .claude/
│   ├── agents/           # Agent character sheets
│   │   ├── project-manager.md
│   │   ├── roy.md        # Backend specialist
│   │   ├── jen.md        # Frontend specialist
│   │   └── ...
│   └── commands/         # Custom slash commands
├── plans/
│   ├── roadmap.md        # Active work
│   └── [feature]-plan.md # Detailed feature plans
├── completed/
│   └── roadmap-archive.md # Historical record
├── tests/
│   ├── patterns/         # Defeat tests
│   ├── behavior/         # Agent behavior tests
│   └── e2e/              # End-to-end tests
├── scripts/
│   ├── agent-memory-server.py
│   └── ...
└── AgenticSDLC-Unified/  # This documentation
```

---

## Environment Variables

Set up required environment variables:

```bash
# .env file (project root)

# Required
ANTHROPIC_API_KEY=sk-ant-your-key-here

# Optional but recommended
NATS_URL=nats://localhost:4222
AGENT_MEMORY_PATH=~/.agent-memory/memories.json
LOG_LEVEL=INFO

# Cost controls (recommended)
CLAUDE_MAX_TOKENS_PER_DAY=1000000
CLAUDE_MAX_COST_PER_DAY=50
```

---

## Pre-Commit Hooks Setup

Install pre-commit hooks for quality enforcement:

```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: local
    hooks:
      - id: run-tests
        name: Run Tests
        entry: pytest tests/ -x -q
        language: system
        types: [python]
        pass_filenames: false

      - id: pattern-detection
        name: Pattern Detection
        entry: pytest tests/patterns/ -x -q
        language: system
        types: [python]
        pass_filenames: false

      - id: type-check
        name: Type Check
        entry: python -m mypy src/
        language: system
        types: [python]
        pass_filenames: false
EOF

# Install hooks
pre-commit install
```

---

## Verification Script

Create and run this verification script:

```bash
#!/bin/bash
# scripts/check-prerequisites.sh

echo "=== Checking Agentic SDLC Prerequisites ==="

check() {
    if $1 > /dev/null 2>&1; then
        echo "✓ $2"
        return 0
    else
        echo "✗ $2 - $3"
        return 1
    fi
}

FAILED=0

check "python3 --version | grep -E '3\.(11|12|13)'" \
    "Python 3.11+" \
    "Install with: brew install python@3.11" || FAILED=1

check "node --version | grep -E 'v(18|19|20|21)'" \
    "Node.js 18+" \
    "Install with: brew install node@18" || FAILED=1

check "git config user.email" \
    "Git configured" \
    "Run: git config --global user.email 'you@example.com'" || FAILED=1

check "which nats-server" \
    "NATS Server installed" \
    "Install with: brew install nats-server" || FAILED=1

check "which nats" \
    "NATS CLI installed" \
    "Install with: brew install nats-io/nats-tools/nats" || FAILED=1

check "test -n \"$ANTHROPIC_API_KEY\"" \
    "ANTHROPIC_API_KEY set" \
    "Set in .env or export ANTHROPIC_API_KEY=..." || FAILED=1

check "python3 -c 'import nats'" \
    "nats-py package" \
    "Install with: pip install nats-py" || FAILED=1

check "test -d .claude/agents" \
    "Agent directory exists" \
    "Create with: mkdir -p .claude/agents" || FAILED=1

check "test -d plans" \
    "Plans directory exists" \
    "Create with: mkdir -p plans" || FAILED=1

echo ""
if [ $FAILED -eq 0 ]; then
    echo "=== All prerequisites met! ==="
    echo "Proceed to: 02-Infrastructure.md"
else
    echo "=== Some prerequisites missing ==="
    echo "Fix the items marked with ✗ and run again."
    exit 1
fi
```

---

## Automated Installation

Run the full prerequisites installation:

```bash
./AgenticSDLC-Unified/scripts/01-install-prerequisites.sh
```

**Script contents:**

```bash
#!/bin/bash
# scripts/01-install-prerequisites.sh
set -e

echo "=== Installing Agentic SDLC Prerequisites ==="

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Install system dependencies
if [ "$OS" == "macos" ]; then
    echo "Installing via Homebrew..."
    brew install python@3.11 node@18 nats-server
    brew tap nats-io/nats-tools
    brew install nats-io/nats-tools/nats
elif [ "$OS" == "linux" ]; then
    echo "Installing for Linux..."
    sudo apt update
    sudo apt install -y python3.11 python3.11-venv nodejs npm
    # NATS manual install for Linux
    curl -L https://github.com/nats-io/nats-server/releases/download/v2.10.7/nats-server-v2.10.7-linux-amd64.tar.gz | tar xz
    sudo mv nats-server-v2.10.7-linux-amd64/nats-server /usr/local/bin/
fi

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install Python packages
pip install --upgrade pip
pip install nats-py mcp fastmcp pydantic httpx pytest pytest-asyncio pre-commit

# Create directory structure
mkdir -p .claude/agents .claude/commands plans completed tests/patterns tests/behavior tests/e2e scripts

# Initialize git hooks
pre-commit install

echo "=== Prerequisites installed! ==="
echo "Next: Run ./AgenticSDLC-Unified/scripts/check-prerequisites.sh to verify"
```

---

## Budget Controls (Recommended)

Set spending limits to prevent runaway costs:

### Privacy.com Virtual Card

1. Create account at privacy.com
2. Create merchant-locked card for Anthropic
3. Set monthly limit (e.g., $200)
4. Card auto-declines when limit reached

### Environment Variable Limits

```bash
# .env
CLAUDE_MAX_TOKENS_PER_DAY=1000000
CLAUDE_MAX_COST_PER_DAY=50
CLAUDE_MAX_REQUESTS_PER_HOUR=100
```

### Why This Matters

From the course materials:

> "I've seen people spend $800+ in a month on tokens during a manic episode. Don't be that person."

Set limits **before** you start. Excited-you will thank rational-you later.

---

## Next Steps

After all prerequisites are installed and verified:

1. **Automated path:** Run `./AgenticSDLC-Unified/scripts/02-setup-infrastructure.sh`
2. **Manual path:** Continue to [02-Infrastructure](02-Infrastructure.md)

---

## Troubleshooting

### Python Version Conflicts

```bash
# Use pyenv to manage Python versions
brew install pyenv
pyenv install 3.11.7
pyenv local 3.11.7
```

### NATS Won't Start

```bash
# Check if port 4222 is in use
lsof -i :4222

# Kill existing process
kill -9 $(lsof -t -i:4222)

# Start with verbose logging
nats-server -V --jetstream
```

### Pre-commit Hooks Failing

```bash
# Skip hooks temporarily (not recommended)
git commit --no-verify

# Fix the issue instead
pytest tests/patterns/ -v  # See what's failing
```

### API Key Not Working

```bash
# Test API key
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-3-opus-20240229","max_tokens":10,"messages":[{"role":"user","content":"Hi"}]}'
```
