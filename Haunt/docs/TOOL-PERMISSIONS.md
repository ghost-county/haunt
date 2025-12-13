# Tool Permissions Reference

This document explains how tool permissions work in the Haunt Framework.

## How Tool Permissions Are Enforced

Tool permissions in Claude Code are enforced at two levels:

### 1. Task Tool Subagent Types (Actual Enforcement)

When spawning agents via the `Task` tool, the `subagent_type` parameter determines which tools the agent can access. This is **actual enforcement** - agents cannot access tools not assigned to their subagent type.

```
Task(subagent_type="Dev-Backend", prompt="...")
```

The subagent type maps to a predefined set of tools that Claude Code enforces.

### 2. Agent YAML Frontmatter (Documentation)

Agent character sheets in `Haunt/agents/` include a `tools` field in their YAML frontmatter. This serves as **documentation** of intended tool access, helping humans understand what each agent should be able to do.

```yaml
---
name: dev
tools: Glob, Grep, Read, Edit, Write, Bash, TodoWrite, mcp__context7__*, mcp__agent_memory__*
# Tool permissions enforced by Task tool subagent_type (Dev-Backend, Dev-Frontend, Dev-Infrastructure)
---
```

## Subagent Types and Their Tools

| Subagent Type | Tools Available |
|---------------|----------------|
| Dev-Backend | Glob, Grep, Read, Edit, Write, TodoWrite, Bash, mcp__context7__*, mcp__agent_memory__* |
| Dev-Frontend | Glob, Grep, Read, Edit, Write, TodoWrite, Bash, mcp__context7__*, mcp__agent_memory__* |
| Dev-Infrastructure | Glob, Grep, Read, Edit, Write, TodoWrite, Bash, mcp__context7__*, mcp__agent_memory__* |
| Research-Analyst | Glob, Grep, Read, Write, WebSearch, WebFetch, mcp__context7__*, mcp__agent_memory__* |
| Research-Critic | Glob, Grep, Read, WebSearch, WebFetch, mcp__agent_memory__* |
| Project-Manager-Agent | Glob, Grep, Read, Edit, Write, TodoWrite, mcp__agent_chat__*, mcp__agent_memory__* |

## Agent-to-Subagent Mapping

| Agent File | Subagent Type(s) | Notes |
|------------|------------------|-------|
| gco-dev.md | Dev-Backend, Dev-Frontend, Dev-Infrastructure | Single polyglot agent handles all 3 modes |
| gco-research.md | Research-Analyst, Research-Critic | Single agent handles both modes |
| gco-project-manager.md | Project-Manager-Agent | |
| gco-code-reviewer.md | (uses main context) | Typically not spawned as subagent |
| gco-release-manager.md | (uses main context) | Typically not spawned as subagent |

**Note:** The `gco-dev.md` agent is a single polyglot that adapts based on file paths and task context. The Task tool's subagent_type determines tool access, while the agent determines its working mode internally.

## Tool Categories

### Read-Only Tools
- **Glob** - File pattern matching
- **Grep** - Content search
- **Read** - File reading
- **WebSearch** - Web search
- **WebFetch** - Web page fetching

### Write Tools
- **Edit** - File editing
- **Write** - File creation
- **Bash** - Shell command execution
- **TodoWrite** - Task list management

### MCP Tools
- **mcp__context7__*** - Library documentation lookup
- **mcp__agent_memory__*** - Agent memory persistence
- **mcp__agent_chat__*** - Inter-agent communication

## Best Practices

### For Agent Designers

1. **Match YAML to Subagent** - Keep the `tools` field in agent YAML aligned with what the Task tool subagent_type actually provides
2. **Principle of Least Privilege** - Only request tools the agent actually needs
3. **Document Rationale** - Add comments explaining why specific tools are needed

### For Framework Users

1. **Use Correct Subagent Type** - When spawning agents, use the appropriate subagent_type for the task
2. **Don't Assume Tools** - Don't expect agents to have tools not in their subagent type
3. **Check Permissions First** - If an agent fails, verify the subagent_type has the required tools

## Troubleshooting

### Agent Can't Write Files

**Symptom:** Agent reports file creation but file doesn't exist on disk

**Possible Causes:**
1. **Mock reporting** - Agent describes what it would do without calling Write tool
2. **Path issues** - File written to unexpected location
3. **Tool not actually called** - Agent narrates action without executing

**Fix:**
- Verify agent explicitly calls Write tool (not just describes writing)
- Use absolute paths for file creation
- Check agent output for actual tool invocations vs descriptions
- Research-Analyst and Project-Manager-Agent both have Write access

### Agent Can't Access MCP Server

**Symptom:** Agent can't use Context7 or Agent Memory

**Cause:** Subagent type doesn't include mcp__* tools

**Fix:** Verify the subagent_type includes the required MCP tools

## SDK Integration Notes

Claude Code CLI already includes SDK features:
- **Context compaction** - Automatic, handles long sessions
- **Prompt caching** - 60-minute TTL for CLAUDE.md
- **Subagent isolation** - Each subagent has isolated context

The separate `@anthropic-ai/claude-agent-sdk` package is only needed for building custom programmatic agents outside of Claude Code.
