# Tool Permissions Reference

This document explains how tool permissions work in the Haunt Framework.

## ⚠️ Critical: Agent YAML `tools` Field is Documentation Only

**The `tools` field in agent YAML does NOT grant tool access.** This is the most common misunderstanding in the Haunt framework.

### The Misconception

```yaml
---
name: gco-example-agent
tools: Task, Glob, Grep, Read, Write, mcp__agent_memory__*  # ← This does NOT work
---
```

Many assume that listing tools in the agent YAML frontmatter will grant those tools when running `claude --agent <name>`. **This is incorrect.**

### The Reality

When you run `claude --agent <name>`:

- ✅ Agent personality/instructions are loaded
- ✅ Skills are loaded
- ✅ Model selection is respected
- ❌ Tool permissions are NOT read from YAML

**Actual tool access is determined by:**

1. **Main Session:** When running plain `claude`, you get ALL tools (Glob, Grep, Read, Write, Edit, Bash, Task, etc.)
2. **Subagents via Task:** When spawning via Task tool, the `subagent_type` parameter determines tools
3. **Agent Mode:** When using `--agent` flag, you get a LIMITED subset (no Task tool)

### Historical Note

An earlier version of the framework included an agent that was deprecated due to this misconception. Coordination agents should be invoked via commands in the main session (like `/seance`) rather than as standalone agents.

---

## How Tool Permissions Are Actually Enforced

Tool permissions in Claude Code are enforced at two levels:

### 1. Main Session Tools

When running `claude` (without `--agent`), you have access to ALL tools:

- Glob, Grep, Read, Edit, Write, Bash
- Task (for spawning subagents)
- TodoWrite, TodoRead
- All configured MCP tools

### 2. Task Tool Subagent Types (Subagent Enforcement)

When spawning agents via the `Task` tool, the `subagent_type` parameter determines which tools the agent can access. This is **actual enforcement** - agents cannot access tools not assigned to their subagent type.

```
Task(subagent_type="Dev-Backend", prompt="...")
```

The subagent type maps to a predefined set of tools that Claude Code enforces.

### 3. Agent YAML Frontmatter (Documentation Only)

Agent character sheets in `Haunt/agents/` include a `tools` field in their YAML frontmatter. This serves **only as documentation** of intended tool access, helping humans understand what each agent should be able to do.

```yaml
---
name: dev
tools: Glob, Grep, Read, Edit, Write, Bash, TodoWrite, mcp__context7__*, mcp__agent_memory__*
# Tool permissions enforced by Task tool subagent_type (Dev-Backend, Dev-Frontend, Dev-Infrastructure)
# ^^^ This comment is the key - the tools field is informational
---
```

---

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
| gco-research.md | Research-Analyst, Research-Critic | Single agent handles both modes, has Write access |
| gco-code-reviewer.md | (uses main context) | Typically not spawned as subagent, has Edit/Write |
| gco-code-reviewer-readonly.md | (uses main context) | Read-only variant, no Edit/Write/Bash/TodoWrite |
| gco-project-manager.md | Project-Manager-Agent | |
| gco-release-manager.md | (uses main context) | Typically not spawned as subagent |

**Note:** The `gco-dev.md` agent is a single polyglot that adapts based on file paths and task context. The Task tool's subagent_type determines tool access, while the agent determines its working mode internally.

---

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

### Orchestration Tools

- **Task** - Spawn subagents (main session only)

### MCP Tools

- **mcp__context7__*** - Library documentation lookup
- **mcp__agent_memory__*** - Agent memory persistence
- **mcp__agent_chat__*** - Inter-agent communication

---

## Tool Restriction Patterns

### Why Restrict Tools?

Tool restrictions prevent accidental modifications and enforce separation of concerns. Inspired by Claude Code's built-in agents (Explore is read-only, Plan is plan mode), Haunt provides restricted variants for safety-critical tasks.

### Read-Only Variants

**Pattern:** Remove Write, Edit, Bash, and TodoWrite tools while keeping read-only analysis tools.

**When to use:**

- Reviewing untrusted or third-party code
- Investigating production systems
- Reconnaissance before making changes
- Research where modification risk must be zero

**Examples:**

- `gco-code-reviewer-readonly.md` - Code review without modification capability

**Benefits:**

- Zero accidental modification risk
- Clear separation of analysis from implementation
- Safe operation in shared/sensitive contexts
- Enforces "reviewer doesn't fix code" discipline

### Tool Access Philosophy

Each agent's tool access should be documented in the agent's header with:

```yaml
---
name: agent-name
tools: [list of tools]
# Tool Access Philosophy: [Why these tools and not others]
# Tool permissions enforced by Task tool subagent_type
---
```

**Philosophy statement should explain:**

1. Why this set of tools (not more, not less)
2. What the agent can and cannot do
3. When to use this agent vs an alternative variant
4. Specific safety or design rationale

### Creating Restricted Variants

To create a read-only variant of an existing agent:

1. **Copy base agent** - Start with full-access version
2. **Remove write tools** - Strip Write, Edit, Bash, TodoWrite
3. **Add philosophy** - Document why read-only is beneficial
4. **Update output format** - Change from file-writing to chat reporting
5. **Document use cases** - Explain when to use this vs full-access variant

**Example transformation:**

```yaml
# Before (full access)
tools: Glob, Grep, Read, Write, Edit, Bash, mcp__*

# After (read-only)
tools: Glob, Grep, Read, WebSearch, WebFetch, mcp__context7__*, mcp__agent_memory__*
# Tool Access Philosophy: Read-only enforcement prevents accidental modifications during research.
```

---

## Model Selection

Agent character sheets can specify a preferred model via the `model` field in YAML frontmatter. This allows optimizing performance and cost for different agent types.

### Supported Model Values

| Value | Meaning | When to Use |
|-------|---------|-------------|
| `haiku` | Fast, cost-effective Claude Haiku | Quick searches, research tasks, read-only operations |
| `sonnet` | Balanced Claude Sonnet | Complex reasoning, planning, code review |
| `opus` | Most capable Claude Opus | Critical decisions, architecture design |
| `inherit` | Use spawning agent's model | Task-based model selection (default for most agents) |

### Model Selection Guidelines

**Use `haiku` for:**

- Web searches and research (gco-research)
- Quick code reviews (syntax/style checks)
- Fast file searches and pattern matching
- Read-only operations with low reasoning requirements

**Use `sonnet` for:**

- Complex code implementation
- Planning and roadmap management (gco-project-manager)
- Code review requiring architectural understanding
- Risk assessment and release management

**Use `opus` for:**

- Critical architectural decisions
- Security reviews
- Complex refactoring across many files
- High-stakes debugging

**Use `inherit` for:**

- Implementation agents (gco-dev) where task complexity varies
- Allows caller to specify appropriate model for the task
- Maintains flexibility for different use cases

### Example Configuration

```yaml
---
name: gco-research
description: Investigation and validation agent.
tools: Glob, Grep, Read, Write, WebSearch, WebFetch, mcp__context7__*, mcp__agent_memory__*
skills: gco-session-startup
model: haiku
# Tool permissions enforced by Task tool subagent_type (Research-Analyst, Research-Critic)
# Model: haiku for fast web searches and research tasks
---
```

### Task-Based Model Selection with `inherit`

When using `model: inherit`, the spawning agent can specify which model to use for that specific task:

```
/summon dev --model=haiku "Fix typo in README"
/summon dev --model=sonnet "Refactor authentication system"
/summon dev --model=opus "Redesign database schema"
```

If no model specified when spawning, the agent uses the current session's model. This allows dynamic model selection based on task complexity while maintaining a sensible default.

---

## Best Practices

### For Agent Designers

1. **Match YAML to Subagent** - Keep the `tools` field in agent YAML aligned with what the Task tool subagent_type actually provides
2. **Principle of Least Privilege** - Only request tools the agent actually needs
3. **Document Rationale** - Add Tool Access Philosophy comment explaining tool choices
4. **Consider Variants** - Create read-only variants for safety-critical use cases
5. **Choose Appropriate Model** - Select model based on agent's typical workload (haiku for speed, sonnet for reasoning, inherit for flexibility)
6. **Remember: tools field is docs** - The tools field helps humans understand intent, but doesn't grant access

### For Framework Users

1. **Use Main Session for Orchestration** - If you need Task tool access, use `claude` not `claude --agent`
2. **Use Correct Subagent Type** - When spawning agents, use the appropriate subagent_type for the task
3. **Don't Assume Tools** - Don't expect agents to have tools not in their subagent type
4. **Check Permissions First** - If an agent fails, verify the subagent_type has the required tools
5. **Choose Appropriate Variant** - Use read-only variants when modification risk must be zero

---

## Troubleshooting

### Agent Can't Spawn Other Agents

**Symptom:** Agent says "Task tool not available" or spawning fails

**Cause:** Running with `--agent` flag, which doesn't provide Task tool

**Fix:** Use main session with `/seance` command instead:

```bash
# Wrong - coordination agent with --agent flag (no Task tool)
claude --agent gco-coordination-agent

# Right - full tool access including Task in main session
claude --dangerously-skip-permissions
/seance "your idea"
```

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

---

## SDK Integration Notes

Claude Code CLI already includes SDK features:

- **Context compaction** - Automatic, handles long sessions
- **Prompt caching** - 60-minute TTL for CLAUDE.md
- **Subagent isolation** - Each subagent has isolated context

The separate `@anthropic-ai/claude-agent-sdk` package is only needed for building custom programmatic agents outside of Claude Code.
