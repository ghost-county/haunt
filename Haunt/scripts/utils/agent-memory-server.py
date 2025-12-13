#!/usr/bin/env python3
"""
Agent Memory MCP Server - Reference Implementation

Provides 5-layer memory hierarchy for AI agents with
consolidation (REM sleep) capabilities.

LIMITATIONS (Reference Implementation Only):
- No semantic search (exact text matching only)
- No embeddings support (cannot query by meaning)
- Simple consolidation only (no sophisticated RAG algorithms)
- Single-user design (no multi-tenancy or team collaboration)
- JSON file storage (doesn't scale beyond ~1000 entries)

For production use with advanced features (semantic search, embeddings,
team collaboration), see alternatives documented in:
.haunt/docs/research/agent-memory-mcp-research.md

This server is suitable for:
- Learning MCP memory server architecture
- Simple single-developer projects
- Testing 5-layer memory hierarchy concepts
- Development and prototyping

Start: python ~/.claude/mcp-servers/agent-memory-server.py
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
