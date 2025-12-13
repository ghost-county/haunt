#!/usr/bin/env python3
"""
Helper script to consolidate agent memories via MCP server.

This script calls run_rem_sleep() on all agents with recent activity
by directly loading and updating the memory store (since MCP is stdio-based).
"""

import json
import sys
from pathlib import Path
from datetime import datetime

# Memory storage location
MEMORY_DIR = Path.home() / ".agent-memory"
MEMORY_FILE = MEMORY_DIR / "memories.json"

def consolidate_memories():
    """Run REM sleep consolidation on all agents with recent activity."""

    if not MEMORY_FILE.exists():
        print("No agent memories found (file doesn't exist)")
        return

    try:
        # Load memories
        data = json.loads(MEMORY_FILE.read_text())

        if not data:
            print("No agents have stored memories")
            return

        # Check if this is the correct MCP memory format (dict with agent_id keys)
        if not isinstance(data, dict):
            print("○ Memory file not in MCP format - no consolidation needed")
            return True

        # Filter for agents with AgentMemory structure
        if not any('agent_id' in v for v in data.values() if isinstance(v, dict)):
            print("○ Memory file not in MCP format - no consolidation needed")
            return True

        consolidated_agents = []

        for agent_id, memory in data.items():
            # Consolidation logic (same as agent-memory-server.py)
            old_tasks = len(memory.get('recent_tasks', []))
            old_learnings = len(memory.get('recent_learnings', []))
            old_patterns = len(memory.get('medium_term_patterns', []))

            recent_learnings = memory.get('recent_learnings', [])
            medium_patterns = memory.get('medium_term_patterns', [])
            recent_tasks = memory.get('recent_tasks', [])
            long_insights = memory.get('long_term_insights', [])

            # Consolidate learnings to patterns
            if len(recent_learnings) > 10:
                to_consolidate = recent_learnings[:-5]
                medium_patterns.extend([f"Pattern from learnings: {l}" for l in to_consolidate[:3]])
                recent_learnings = recent_learnings[-5:]

            # Promote patterns to long-term
            if len(medium_patterns) > 20:
                to_promote = medium_patterns[:-10]
                long_insights.extend([f"Consolidated: {p}" for p in to_promote[:2]])
                medium_patterns = medium_patterns[-10:]

            # Trim old tasks
            if len(recent_tasks) > 20:
                recent_tasks = recent_tasks[-10:]

            # Update memory
            memory['recent_learnings'] = recent_learnings
            memory['medium_term_patterns'] = medium_patterns
            memory['recent_tasks'] = recent_tasks
            memory['long_term_insights'] = long_insights
            memory['compost'] = []
            memory['last_rem_sleep'] = datetime.now().isoformat()

            new_tasks = len(recent_tasks)
            new_learnings = len(recent_learnings)
            new_patterns = len(medium_patterns)

            consolidated_agents.append({
                'agent_id': agent_id,
                'tasks': {'old': old_tasks, 'new': new_tasks},
                'learnings': {'old': old_learnings, 'new': new_learnings},
                'patterns': {'old': old_patterns, 'new': new_patterns}
            })

        # Save updated memories
        MEMORY_FILE.write_text(json.dumps(data, indent=2))

        # Output summary
        print(f"🧠 Memory consolidation complete for {len(consolidated_agents)} agent(s):")
        for agent in consolidated_agents:
            aid = agent['agent_id']
            t = agent['tasks']
            l = agent['learnings']
            p = agent['patterns']
            print(f"  • {aid}:")
            print(f"    - Tasks: {t['old']} → {t['new']}")
            print(f"    - Learnings: {l['old']} → {l['new']}")
            print(f"    - Patterns: {p['old']} → {p['new']}")

        return True

    except (json.JSONDecodeError, KeyError, TypeError) as e:
        print(f"Error consolidating memories: {e}", file=sys.stderr)
        return False

if __name__ == "__main__":
    success = consolidate_memories()
    sys.exit(0 if success else 1)
