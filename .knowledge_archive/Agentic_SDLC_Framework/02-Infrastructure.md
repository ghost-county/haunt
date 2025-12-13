# 02: Infrastructure Setup

> Deploy NATS JetStream, MCP memory server, and communication channels.

---

## Overview

| Item | Purpose |
|------|---------|
| **Time Required** | 45 minutes (manual) / 10 minutes (scripted) |
| **Output** | Running message queue and memory system |
| **Automation** | `scripts/02-setup-infrastructure.sh` |
| **Prerequisites** | [01-Prerequisites](01-Prerequisites.md) complete |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                     INFRASTRUCTURE LAYER                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    NATS JetStream                             │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐ │   │
│  │  │REQUIREMENTS│ │   WORK     │ │INTEGRATION │ │  RELEASES  │ │   │
│  │  │  Stream    │ │  Stream    │ │   Stream   │ │   Stream   │ │   │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────┘ │   │
│  │                                                               │   │
│  │  Features: Guaranteed delivery, ACK/NAK, persistence         │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    MCP Memory Server                          │   │
│  │                                                               │   │
│  │  Tools: recall_context, add_recent_task, add_learning,        │   │
│  │         add_long_term_insight, run_rem_sleep                  │   │
│  │                                                               │   │
│  │  Storage: ~/.agent-memory/memories.json                       │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Part 1: NATS JetStream

### What NATS Does

NATS JetStream provides:

| Feature | Purpose |
|---------|---------|
| **Guaranteed Delivery** | Messages don't get lost |
| **ACK/NAK** | Agents confirm receipt or request retry |
| **Persistence** | Messages survive restarts |
| **Streams** | Organized channels for different work types |
| **Consumers** | Agents subscribe to work relevant to them |

### Start NATS Server

**Option 1: Direct (Development)**

```bash
# Start with JetStream enabled
nats-server --jetstream --store_dir /tmp/nats-store

# Verify running
nats server info
```

**Option 2: Background Service (Production)**

```bash
# Create configuration file
cat > /etc/nats/nats-server.conf << 'EOF'
# NATS Server Configuration for Agentic SDLC
port: 4222
http_port: 8222

jetstream {
    store_dir: /var/lib/nats/jetstream
    max_memory_store: 1GB
    max_file_store: 10GB
}

# Logging
debug: false
trace: false
logfile: /var/log/nats/nats-server.log
EOF

# Start as service (Linux)
sudo systemctl enable nats-server
sudo systemctl start nats-server

# Start as service (macOS)
brew services start nats-server
```

**Option 3: Docker**

```bash
docker run -d --name nats \
  -p 4222:4222 \
  -p 8222:8222 \
  -v nats-data:/data \
  nats:latest \
  --jetstream --store_dir /data
```

### Create Streams

**Automated:**

```bash
./AgenticSDLC-Unified/scripts/create-nats-streams.sh
```

**Manual:**

```bash
# REQUIREMENTS stream - Human decisions, new work items
nats stream add REQUIREMENTS \
    --subjects "work.requirements.*" \
    --storage file \
    --replicas 1 \
    --retention limits \
    --max-msgs 10000 \
    --max-age 30d \
    --discard old \
    --max-msg-size 1MB \
    --dupe-window 2m

# WORK stream - Agent assignments, task updates
nats stream add WORK \
    --subjects "work.assigned.*,work.progress.*,work.complete.*" \
    --storage file \
    --replicas 1 \
    --retention limits \
    --max-msgs 50000 \
    --max-age 7d \
    --discard old \
    --max-msg-size 1MB \
    --dupe-window 2m

# INTEGRATION stream - Ready for merge, test results
nats stream add INTEGRATION \
    --subjects "work.integration.*" \
    --storage file \
    --replicas 1 \
    --retention limits \
    --max-msgs 10000 \
    --max-age 7d \
    --discard old \
    --max-msg-size 1MB \
    --dupe-window 2m

# RELEASES stream - Merge coordination, deployment
nats stream add RELEASES \
    --subjects "work.releases.*" \
    --storage file \
    --replicas 1 \
    --retention limits \
    --max-msgs 5000 \
    --max-age 30d \
    --discard old \
    --max-msg-size 1MB \
    --dupe-window 2m
```

### Create Consumers

Consumers define how agents receive messages:

```bash
# Project Manager consumes requirements
nats consumer add REQUIREMENTS pm-consumer \
    --filter "work.requirements.*" \
    --ack explicit \
    --deliver all \
    --max-deliver 3 \
    --wait 30s \
    --replay instant

# Worker agents consume assigned work
nats consumer add WORK worker-consumer \
    --filter "work.assigned.*" \
    --ack explicit \
    --deliver all \
    --max-deliver 5 \
    --wait 60s \
    --replay instant

# Release manager consumes integration requests
nats consumer add INTEGRATION release-consumer \
    --filter "work.integration.*" \
    --ack explicit \
    --deliver all \
    --max-deliver 3 \
    --wait 30s \
    --replay instant
```

### Verify NATS Setup

```bash
# List streams
nats stream ls
# Expected: REQUIREMENTS, WORK, INTEGRATION, RELEASES

# Check stream details
nats stream info WORK

# Test publish/subscribe
nats pub work.requirements.new '{"type":"test","message":"hello"}'
nats sub "work.requirements.*" --count 1
```

---

## Part 2: MCP Memory Server

### What the Memory Server Does

The MCP Memory Server provides:

| Tool | Purpose |
|------|---------|
| `recall_context` | Get concise summary of agent's memories |
| `add_recent_task` | Record completed work |
| `add_recent_learning` | Record new insights |
| `add_long_term_insight` | Preserve major learnings |
| `run_rem_sleep` | Consolidate and compress memories |
| `get_full_memory` | Debug access to all memory layers |

### Memory Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 1: CORE IDENTITY                                          │
│ ─────────────────────                                           │
│ Permanent. Set at agent creation. Never changes.                │
│                                                                 │
│ Example: "I am Dev-Backend. I specialize in server-side code,   │
│ APIs, and database operations. I use explicit error handling."  │
├─────────────────────────────────────────────────────────────────┤
│ Layer 2: LONG-TERM INSIGHTS                                     │
│ ─────────────────────────                                       │
│ Consolidates monthly. Major learnings preserved.                │
│                                                                 │
│ Example: "The April database incident taught us never to        │
│ exceed 100 connections. Use connection pooling always."         │
├─────────────────────────────────────────────────────────────────┤
│ Layer 3: MEDIUM-TERM PATTERNS                                   │
│ ────────────────────────────                                    │
│ Consolidates weekly. Project-specific knowledge.                │
│                                                                 │
│ Example: "This project uses FastAPI + SQLAlchemy.               │
│ Tests are in /tests/. Config is in /src/config/."               │
├─────────────────────────────────────────────────────────────────┤
│ Layer 4: RECENT TASKS                                           │
│ ─────────────────────                                           │
│ Consolidates daily. Recent work context.                        │
│                                                                 │
│ Example: "Today I fixed the auth bug in src/auth.py.            │
│ Related to REQ-023. Tests now passing."                         │
├─────────────────────────────────────────────────────────────────┤
│ Layer 5: COMPOST                                                │
│ ─────────────                                                   │
│ Things to forget. Outdated, irrelevant, temporary.              │
│                                                                 │
│ Example: "Temporary workaround for TICKET-123 - now fixed."     │
└─────────────────────────────────────────────────────────────────┘
```

### Create Memory Server

**File: `scripts/agent-memory-server.py`**

```python
#!/usr/bin/env python3
"""
MCP Memory Server for Agentic SDLC

Provides 5-layer memory hierarchy for AI agents with
consolidation (REM sleep) capabilities.

Start: python scripts/agent-memory-server.py
"""

import json
import os
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional
from dataclasses import dataclass, field, asdict
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

# Configuration
MEMORY_DIR = Path.home() / ".agent-memory"
MEMORY_FILE = MEMORY_DIR / "memories.json"

@dataclass
class AgentMemory:
    """Memory structure for a single agent."""
    agent_id: str
    core_identity: str = ""
    long_term_insights: list = field(default_factory=list)
    medium_term_patterns: list = field(default_factory=list)
    recent_tasks: list = field(default_factory=list)
    recent_learnings: list = field(default_factory=list)
    compost: list = field(default_factory=list)
    last_rem_sleep: Optional[str] = None
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())

class MemoryStore:
    """Persistent memory storage."""

    def __init__(self, path: Path = MEMORY_FILE):
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.memories: dict[str, AgentMemory] = {}
        self._load()

    def _load(self):
        """Load memories from disk."""
        if self.path.exists():
            try:
                data = json.loads(self.path.read_text())
                for agent_id, mem_data in data.items():
                    self.memories[agent_id] = AgentMemory(**mem_data)
            except (json.JSONDecodeError, TypeError):
                self.memories = {}

    def _save(self):
        """Persist memories to disk."""
        data = {k: asdict(v) for k, v in self.memories.items()}
        self.path.write_text(json.dumps(data, indent=2, default=str))

    def get_or_create(self, agent_id: str) -> AgentMemory:
        """Get agent memory, creating if needed."""
        if agent_id not in self.memories:
            self.memories[agent_id] = AgentMemory(agent_id=agent_id)
            self._save()
        return self.memories[agent_id]

    def update(self, memory: AgentMemory):
        """Update and persist agent memory."""
        self.memories[memory.agent_id] = memory
        self._save()

# Initialize
store = MemoryStore()
server = Server("agent-memory")

@server.list_tools()
async def list_tools():
    """List available memory tools."""
    return [
        Tool(
            name="recall_context",
            description="Get concise summary of agent's memories. USE THIS ON SPAWN.",
            inputSchema={
                "type": "object",
                "properties": {
                    "agent_id": {"type": "string", "description": "Agent identifier (e.g., 'dev-backend', 'dev-frontend')"}
                },
                "required": ["agent_id"]
            }
        ),
        Tool(
            name="add_recent_task",
            description="Record a completed task in recent memory.",
            inputSchema={
                "type": "object",
                "properties": {
                    "agent_id": {"type": "string"},
                    "task": {"type": "string", "description": "Description of completed task"}
                },
                "required": ["agent_id", "task"]
            }
        ),
        Tool(
            name="add_recent_learning",
            description="Record a new learning or insight.",
            inputSchema={
                "type": "object",
                "properties": {
                    "agent_id": {"type": "string"},
                    "learning": {"type": "string", "description": "The learning to remember"}
                },
                "required": ["agent_id", "learning"]
            }
        ),
        Tool(
            name="add_long_term_insight",
            description="Preserve a major insight in long-term memory.",
            inputSchema={
                "type": "object",
                "properties": {
                    "agent_id": {"type": "string"},
                    "insight": {"type": "string", "description": "Major insight to preserve"}
                },
                "required": ["agent_id", "insight"]
            }
        ),
        Tool(
            name="set_core_identity",
            description="Set agent's core identity (permanent, use carefully).",
            inputSchema={
                "type": "object",
                "properties": {
                    "agent_id": {"type": "string"},
                    "identity": {"type": "string", "description": "Core identity statement"}
                },
                "required": ["agent_id", "identity"]
            }
        ),
        Tool(
            name="add_to_compost",
            description="Mark information for eventual forgetting.",
            inputSchema={
                "type": "object",
                "properties": {
                    "agent_id": {"type": "string"},
                    "item": {"type": "string", "description": "Information to forget"}
                },
                "required": ["agent_id", "item"]
            }
        ),
        Tool(
            name="run_rem_sleep",
            description="Consolidate memories: compress recent → patterns → insights.",
            inputSchema={
                "type": "object",
                "properties": {
                    "agent_id": {"type": "string"}
                },
                "required": ["agent_id"]
            }
        ),
        Tool(
            name="get_full_memory",
            description="Get complete memory dump (for debugging).",
            inputSchema={
                "type": "object",
                "properties": {
                    "agent_id": {"type": "string"}
                },
                "required": ["agent_id"]
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    """Execute memory tool."""
    agent_id = arguments.get("agent_id", "default")
    memory = store.get_or_create(agent_id)

    if name == "recall_context":
        # Build concise summary
        summary_parts = []

        if memory.core_identity:
            summary_parts.append(f"## Identity\n{memory.core_identity}")

        if memory.long_term_insights:
            recent_insights = memory.long_term_insights[-5:]
            summary_parts.append(f"## Long-term Insights\n" + "\n".join(f"- {i}" for i in recent_insights))

        if memory.medium_term_patterns:
            recent_patterns = memory.medium_term_patterns[-5:]
            summary_parts.append(f"## Current Patterns\n" + "\n".join(f"- {p}" for p in recent_patterns))

        if memory.recent_tasks:
            recent = memory.recent_tasks[-5:]
            summary_parts.append(f"## Recent Tasks\n" + "\n".join(f"- {t}" for t in recent))

        if memory.recent_learnings:
            recent = memory.recent_learnings[-5:]
            summary_parts.append(f"## Recent Learnings\n" + "\n".join(f"- {l}" for l in recent))

        summary = "\n\n".join(summary_parts) if summary_parts else "No memories yet."
        return [TextContent(type="text", text=summary)]

    elif name == "add_recent_task":
        task = f"[{datetime.now().strftime('%Y-%m-%d %H:%M')}] {arguments['task']}"
        memory.recent_tasks.append(task)
        # Keep only last 50
        memory.recent_tasks = memory.recent_tasks[-50:]
        store.update(memory)
        return [TextContent(type="text", text=f"Recorded task: {arguments['task']}")]

    elif name == "add_recent_learning":
        learning = f"[{datetime.now().strftime('%Y-%m-%d')}] {arguments['learning']}"
        memory.recent_learnings.append(learning)
        memory.recent_learnings = memory.recent_learnings[-30:]
        store.update(memory)
        return [TextContent(type="text", text=f"Recorded learning: {arguments['learning']}")]

    elif name == "add_long_term_insight":
        insight = f"[{datetime.now().strftime('%Y-%m')}] {arguments['insight']}"
        memory.long_term_insights.append(insight)
        memory.long_term_insights = memory.long_term_insights[-20:]
        store.update(memory)
        return [TextContent(type="text", text=f"Preserved insight: {arguments['insight']}")]

    elif name == "set_core_identity":
        memory.core_identity = arguments["identity"]
        store.update(memory)
        return [TextContent(type="text", text=f"Core identity set for {agent_id}")]

    elif name == "add_to_compost":
        item = f"[{datetime.now().strftime('%Y-%m-%d')}] {arguments['item']}"
        memory.compost.append(item)
        memory.compost = memory.compost[-100:]
        store.update(memory)
        return [TextContent(type="text", text=f"Marked for forgetting: {arguments['item']}")]

    elif name == "run_rem_sleep":
        # Consolidation logic
        old_tasks = len(memory.recent_tasks)
        old_learnings = len(memory.recent_learnings)

        # Group similar items (simplified - real implementation would use embeddings)
        if len(memory.recent_learnings) > 10:
            # Move oldest learnings to medium-term as patterns
            to_consolidate = memory.recent_learnings[:-5]
            memory.medium_term_patterns.extend([f"Pattern from learnings: {l}" for l in to_consolidate[:3]])
            memory.recent_learnings = memory.recent_learnings[-5:]

        if len(memory.medium_term_patterns) > 20:
            # Promote to long-term
            to_promote = memory.medium_term_patterns[:-10]
            memory.long_term_insights.extend([f"Consolidated: {p}" for p in to_promote[:2]])
            memory.medium_term_patterns = memory.medium_term_patterns[-10:]

        # Clear old tasks
        if len(memory.recent_tasks) > 20:
            memory.recent_tasks = memory.recent_tasks[-10:]

        # Clear compost
        memory.compost = []

        memory.last_rem_sleep = datetime.now().isoformat()
        store.update(memory)

        return [TextContent(type="text", text=f"""
REM Sleep complete for {agent_id}:
- Tasks: {old_tasks} → {len(memory.recent_tasks)}
- Learnings: {old_learnings} → {len(memory.recent_learnings)}
- Patterns: {len(memory.medium_term_patterns)}
- Insights: {len(memory.long_term_insights)}
- Compost cleared
""")]

    elif name == "get_full_memory":
        return [TextContent(type="text", text=json.dumps(asdict(memory), indent=2, default=str))]

    return [TextContent(type="text", text=f"Unknown tool: {name}")]

async def main():
    """Run the MCP server."""
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream)

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

### Configure Claude Code to Use Memory Server

**File: `.claude/mcp.json`**

```json
{
  "mcpServers": {
    "agent-memory": {
      "command": "python",
      "args": ["scripts/agent-memory-server.py"],
      "env": {}
    }
  }
}
```

### Verify Memory Server

```bash
# Start the server manually to test
python scripts/agent-memory-server.py

# In Claude Code, verify tools available:
# Type: /mcp
# Should show: agent-memory server with tools listed
```

---

## Part 3: Agent Base Class (Python)

Create a reusable base class for Python-based agents:

**File: `scripts/nats_agent.py`**

```python
"""
Base class for NATS-connected agents.

Usage:
    class MyAgent(NATSAgent):
        async def run_turn(self):
            # Your agent logic here
            pass
"""

import asyncio
import json
import os
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Optional
import nats
from nats.js.api import ConsumerConfig, AckPolicy, DeliverPolicy

@dataclass
class AgentConfig:
    """Configuration for a NATS agent."""
    name: str
    subjects: list[str]
    consumer_name: Optional[str] = None
    nats_url: str = "nats://localhost:4222"

class NATSAgent(ABC):
    """Base class for agents that communicate via NATS."""

    def __init__(self, config: AgentConfig):
        self.config = config
        self.nc: Optional[nats.NATS] = None
        self.js: Optional[nats.js.JetStreamContext] = None
        self.running = False

    async def connect(self):
        """Connect to NATS server."""
        self.nc = await nats.connect(self.config.nats_url)
        self.js = self.nc.jetstream()
        print(f"[{self.config.name}] Connected to NATS")

    async def disconnect(self):
        """Disconnect from NATS."""
        if self.nc:
            await self.nc.close()
            print(f"[{self.config.name}] Disconnected from NATS")

    async def publish(self, subject: str, data: dict):
        """Publish a message to a subject."""
        payload = json.dumps(data).encode()
        await self.js.publish(subject, payload)
        print(f"[{self.config.name}] Published to {subject}")

    async def pull_messages(self, stream: str, batch: int = 10, timeout: float = 5.0):
        """Pull messages from a stream."""
        consumer_name = self.config.consumer_name or f"{self.config.name}-consumer"

        try:
            psub = await self.js.pull_subscribe(
                subject=self.config.subjects[0],
                durable=consumer_name,
                stream=stream
            )
            messages = await psub.fetch(batch, timeout=timeout)
            return messages
        except nats.errors.TimeoutError:
            return []

    async def ack(self, msg):
        """Acknowledge a message."""
        await msg.ack()

    async def nak(self, msg, delay: int = 10):
        """Negative acknowledge - retry after delay."""
        await msg.nak(delay=delay)

    @abstractmethod
    async def run_turn(self):
        """Execute one turn of agent logic. Override in subclass."""
        pass

    async def run(self, interval: float = 60.0):
        """Main run loop with execution cadence."""
        self.running = True
        await self.connect()

        try:
            while self.running:
                try:
                    await self.run_turn()
                except Exception as e:
                    print(f"[{self.config.name}] Error in turn: {e}")

                await asyncio.sleep(interval)
        finally:
            await self.disconnect()

    def stop(self):
        """Signal the agent to stop."""
        self.running = False


# Example usage
if __name__ == "__main__":
    class ExampleAgent(NATSAgent):
        async def run_turn(self):
            print(f"[{self.config.name}] Running turn...")
            messages = await self.pull_messages("WORK", batch=5)
            for msg in messages:
                data = json.loads(msg.data.decode())
                print(f"  Received: {data}")
                await self.ack(msg)

    config = AgentConfig(
        name="example",
        subjects=["work.assigned.*"],
        consumer_name="example-consumer"
    )

    agent = ExampleAgent(config)
    asyncio.run(agent.run(interval=10))
```

---

## Part 4: Process Files

### Initialize Roadmap

**File: `plans/roadmap.md`**

```markdown
# Active Roadmap

> Last updated: [DATE]
>
> Status: ⚪ Not Started | 🟡 In Progress | 🟢 Complete | 🔴 Blocked

---

## Current Phase: Setup

### Batch 1: Infrastructure

⚪ SETUP-001: NATS JetStream deployment
   Tasks:
   - [ ] Install NATS server
   - [ ] Configure JetStream
   - [ ] Create streams
   - [ ] Verify connectivity
   Files: scripts/, .env
   Effort: S
   Completion: nats stream ls shows 4 streams

⚪ SETUP-002: Memory server deployment
   Tasks:
   - [ ] Create memory server script
   - [ ] Configure MCP integration
   - [ ] Test memory operations
   Files: scripts/agent-memory-server.py, .claude/mcp.json
   Effort: S
   Completion: recall_context returns data

---

## Backlog

> New requirements go here before prioritization

---

## Notes

- Effort sizing: S (1-4 hours) | M (4-8 hours)
- No L or XL - break those down further
```

### Initialize Archive

**File: `completed/roadmap-archive.md`**

```markdown
# Roadmap Archive

> Historical record of completed work

---

## [DATE]

*No completed items yet*

---

## Archive Format

When archiving, use this format:

```
🟢 REQ-XXX: [Title]
   Completed by: [Agent name]
   Tasks: X/X complete
   Notes: [Any relevant context]
   Time: X hours
```
```

---

## Verification Checklist

Run this to verify infrastructure is complete:

```bash
#!/bin/bash
# scripts/verify-infrastructure.sh

echo "=== Verifying Agentic SDLC Infrastructure ==="

FAILED=0

# NATS Server (use 'nats stream ls' - 'nats server ping' requires system account)
echo -n "NATS Server running: "
if nats stream ls > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗ - Start with: nats-server --jetstream"
    FAILED=1
fi

# NATS Streams
echo -n "NATS Streams created: "
STREAMS=$(nats stream ls 2>/dev/null | wc -l)
if [ "$STREAMS" -ge 4 ]; then
    echo "✓ ($STREAMS streams)"
else
    echo "✗ - Run: ./scripts/create-nats-streams.sh"
    FAILED=1
fi

# Memory file
echo -n "Memory directory exists: "
if [ -d "$HOME/.agent-memory" ]; then
    echo "✓"
else
    echo "✗ - Will be created on first use"
fi

# MCP configuration
echo -n "MCP configuration exists: "
if [ -f ".claude/mcp.json" ]; then
    echo "✓"
else
    echo "✗ - Create .claude/mcp.json"
    FAILED=1
fi

# Plans directory
echo -n "Plans directory exists: "
if [ -f "plans/roadmap.md" ]; then
    echo "✓"
else
    echo "✗ - Initialize plans/roadmap.md"
    FAILED=1
fi

# Archive directory
echo -n "Archive directory exists: "
if [ -f "completed/roadmap-archive.md" ]; then
    echo "✓"
else
    echo "✗ - Initialize completed/roadmap-archive.md"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo "=== Infrastructure ready! ==="
    echo "Proceed to: 03-Agent-Definitions.md"
else
    echo "=== Some components missing ==="
    echo "Fix the items marked with ✗ and run again."
    exit 1
fi
```

---

## Automated Setup Script

**File: `scripts/02-setup-infrastructure.sh`**

```bash
#!/bin/bash
# scripts/02-setup-infrastructure.sh
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
echo "Creating NATS streams..."

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

# Create memory directory
echo "Setting up memory storage..."
mkdir -p ~/.agent-memory

# Create MCP configuration
echo "Configuring MCP..."
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
echo "Initializing planning files..."
mkdir -p plans completed

if [ ! -f plans/roadmap.md ]; then
    cat > plans/roadmap.md << 'EOF'
# Active Roadmap

> Last updated: $(date +%Y-%m-%d)

---

## Current Phase: Setup

*Add requirements here*

---

## Backlog

*New ideas go here*
EOF
fi

if [ ! -f completed/roadmap-archive.md ]; then
    cat > completed/roadmap-archive.md << 'EOF'
# Roadmap Archive

> Historical record of completed work

---

*No completed items yet*
EOF
fi

echo ""
echo "=== Infrastructure setup complete! ==="
echo ""
echo "To verify: ./AgenticSDLC-Unified/scripts/verify-infrastructure.sh"
echo "Next step: 03-Agent-Definitions.md"
```

---

## Next Steps

After infrastructure is verified:

1. **Automated path:** Run `./AgenticSDLC-Unified/scripts/03-create-agents.sh`
2. **Manual path:** Continue to [03-Agent-Definitions](03-Agent-Definitions.md)
