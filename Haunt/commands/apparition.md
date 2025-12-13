# Apparition (Agent Memory Interface)

Summon memories from past sessions - view or add agent memory entries through the MCP agent memory system.

## Usage

**Recall memories for a specific agent:**
```
/apparition recall dev
/apparition recall pm
/apparition recall research
```

**Remember a new insight:**
```
/apparition remember "Always validate input before processing"
/apparition remember "Pattern: silent fallbacks hide bugs"
```

**View cross-agent memories (recent hauntings):**
```
/apparition haunt
/apparition
```

## Implementation

When invoked:

### Recall Mode (`recall <agent>`)

1. Parse agent type from arguments (dev, pm, research, code-reviewer, release)
2. Map to full agent_id:
   - `dev` → `dev-backend` (or prompt for backend/frontend/infrastructure)
   - `pm` → `project-manager`
   - `research` → `research-analyst`
   - `code-reviewer` → `code-reviewer`
   - `release` → `release-manager`
3. Call MCP tool: `recall_context(agent_id="<mapped-id>")`
4. Display formatted output:
   ```
   ## Apparitions from <Agent Type>

   [Memory output from MCP server]

   Last manifestation: [last_rem_sleep timestamp if available]
   ```

### Remember Mode (`remember "<insight>"`)

1. Extract insight from quoted argument
2. Determine current agent context (use agent_id of invoking agent)
3. Call MCP tool: `add_long_term_insight(agent_id="<context>", insight="<text>")`
4. Confirm: "Insight preserved in long-term memory for <agent>"

### Haunt Mode (no args or `haunt`)

1. Call `recall_context()` for common agents: dev-backend, project-manager, research-analyst
2. Display cross-agent summary showing:
   - Recent shared patterns
   - Cross-cutting insights
   - Last consolidation (REM sleep) for each

## Theming

"Apparitions" are memories and insights from past sessions that manifest when summoned. The agent memory system is the "spirit realm" where past experiences echo forward in time.

**Language:**
- "Summon apparitions" = recall memories
- "Preserve in the void" = add to memory
- "Manifestation" = memory retrieval
- "Last haunting" = last REM sleep consolidation

## Error Handling

- If MCP agent_memory server not available: "The spirit realm is silent (MCP server not running)"
- If invalid agent type: List valid options and ask user to retry
- If empty memory: "No apparitions yet - the spirit has not been summoned before"

## Dependencies

Requires MCP agent_memory server running (`~/.claude/mcp-servers/agent-memory-server.py`).

Check availability: If MCP call fails, provide setup instructions.
