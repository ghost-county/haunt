#!/bin/bash
# scripts/02-setup-infrastructure.sh
# Set up NATS JetStream and infrastructure for Agentic SDLC
set -e

echo "=== Setting Up Agentic SDLC Infrastructure ==="

# Start NATS if not running
# Use 'nats stream ls' instead of 'nats server ping' (ping requires system account permissions)
if ! nats stream ls > /dev/null 2>&1; then
    echo "Starting NATS server..."
    nats-server --jetstream --store_dir /tmp/nats-store &
    sleep 2
fi

# Create streams
echo ""
echo "## Creating NATS streams..."
./scripts/create-nats-streams.sh 2>/dev/null || {
    echo "Creating streams manually..."

    nats stream add REQUIREMENTS \
        --subjects "work.requirements.*" \
        --storage file \
        --replicas 1 \
        --retention limits \
        --max-msgs 10000 \
        --max-age 30d \
        --discard old \
        --defaults 2>/dev/null || echo "REQUIREMENTS stream exists"

    nats stream add WORK \
        --subjects "work.assigned.*,work.progress.*,work.complete.*" \
        --storage file \
        --replicas 1 \
        --retention limits \
        --max-msgs 50000 \
        --max-age 7d \
        --discard old \
        --defaults 2>/dev/null || echo "WORK stream exists"

    nats stream add INTEGRATION \
        --subjects "work.integration.*" \
        --storage file \
        --replicas 1 \
        --retention limits \
        --max-msgs 10000 \
        --max-age 7d \
        --discard old \
        --defaults 2>/dev/null || echo "INTEGRATION stream exists"

    nats stream add RELEASES \
        --subjects "work.releases.*" \
        --storage file \
        --replicas 1 \
        --retention limits \
        --max-msgs 5000 \
        --max-age 30d \
        --discard old \
        --defaults 2>/dev/null || echo "RELEASES stream exists"
}

# Create memory directory
echo ""
echo "## Setting up memory storage..."
mkdir -p ~/.agent-memory

# Create MCP configuration
echo ""
echo "## Configuring MCP..."
mkdir -p .claude
cat > .claude/mcp.json << 'EOF'
{
  "mcpServers": {
    "agent-memory": {
      "command": "python",
      "args": ["scripts/agent-memory-server.py"],
      "env": {}
    }
  }
}
EOF

# Initialize plans
echo ""
echo "## Initializing planning files..."
mkdir -p plans completed progress

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
EOF
    echo "✓ Created plans/roadmap.md"
fi

if [ ! -f completed/roadmap-archive.md ]; then
    cat > completed/roadmap-archive.md << 'EOF'
# Roadmap Archive

> Historical record of completed work

---

*No completed items yet*
EOF
    echo "✓ Created completed/roadmap-archive.md"
fi

if [ ! -f plans/feature-contract.json ]; then
    cat > plans/feature-contract.json << 'EOF'
{
  "version": "1.0.0",
  "features": [],
  "metadata": {
    "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF
    echo "✓ Created plans/feature-contract.json"
fi

echo ""
echo "=== Infrastructure setup complete! ==="
echo ""
echo "To verify: ./scripts/verify-infrastructure.sh"
echo "Next step: 03-Agent-Definitions.md"
