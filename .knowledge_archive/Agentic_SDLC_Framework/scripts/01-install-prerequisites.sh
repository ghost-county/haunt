#!/bin/bash
# scripts/01-install-prerequisites.sh
# Install all prerequisites for Agentic SDLC
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

echo "Detected OS: $OS"
echo ""

# Install system dependencies
if [ "$OS" == "macos" ]; then
    echo "## Installing via Homebrew..."

    # Check if Homebrew is installed
    if ! which brew > /dev/null 2>&1; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install core tools
    brew install python@3.11 node@18 nats-server 2>/dev/null || true

    # Install NATS CLI
    brew tap nats-io/nats-tools 2>/dev/null || true
    brew install nats-io/nats-tools/nats 2>/dev/null || true

elif [ "$OS" == "linux" ]; then
    echo "## Installing for Linux..."
    sudo apt update
    sudo apt install -y python3.11 python3.11-venv nodejs npm curl

    # NATS manual install for Linux
    if ! which nats-server > /dev/null 2>&1; then
        echo "Installing NATS Server..."
        curl -L https://github.com/nats-io/nats-server/releases/download/v2.10.7/nats-server-v2.10.7-linux-amd64.tar.gz | tar xz
        sudo mv nats-server-v2.10.7-linux-amd64/nats-server /usr/local/bin/
        rm -rf nats-server-v2.10.7-linux-amd64
    fi

    # NATS CLI for Linux
    if ! which nats > /dev/null 2>&1; then
        echo "Installing NATS CLI..."
        curl -L https://github.com/nats-io/natscli/releases/latest/download/nats-0.0.35-linux-amd64.zip -o nats.zip
        unzip nats.zip && sudo mv nats /usr/local/bin/
        rm nats.zip
    fi
fi

echo ""
echo "## Setting up Python environment..."

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "✓ Created virtual environment"
fi

# Activate virtual environment
source .venv/bin/activate

# Install Python packages
pip install --upgrade pip
pip install nats-py mcp fastmcp pydantic httpx pytest pytest-asyncio pre-commit playwright

echo ""
echo "## Creating directory structure..."

# Create directory structure
mkdir -p .claude/agents .claude/commands plans completed progress tests/patterns tests/behavior tests/e2e scripts

echo ""
echo "## Installing pre-commit hooks..."

# Initialize git hooks
pre-commit install 2>/dev/null || echo "Note: pre-commit hooks will be installed when .pre-commit-config.yaml exists"

echo ""
echo "## Installing Playwright browsers..."
playwright install chromium 2>/dev/null || echo "Note: Run 'playwright install chromium' after activating venv"

echo ""
echo "=== Prerequisites installed! ==="
echo ""
echo "Next steps:"
echo "  1. Activate the virtual environment: source .venv/bin/activate"
echo "  2. Verify installation: ./scripts/check-prerequisites.sh"
echo "  3. Continue to: 02-Infrastructure.md"
