# SDK Integration Architecture

This document explains how the Haunt Framework integrates with the Anthropic Agent SDK and Claude Code.

## Overview

The Haunt Framework uses a **selective integration** approach:

- **SDK Infrastructure**: Context management, tool permissions, prompt caching
- **Custom Methodology**: Requirements workflow, roadmap management, pattern detection, skills

This gives us the reliability of SDK infrastructure while maintaining our specialized development methodology.

## What Claude Code Provides (SDK Features)

These features are **built into Claude Code** and work automatically:

### 1. Automatic Context Compaction

When context approaches limits, Claude Code automatically summarizes earlier messages.

**How it works:**
- Monitors context window usage
- Triggers compaction before overflow
- Preserves important context, summarizes routine exchanges

**Framework integration:**
- Session-startup skill acknowledges SDK handles context
- CLAUDE.md is cached for fast loading
- Active Work section optimized for minimal context usage

### 2. Prompt Caching (60-Minute TTL)

Frequently-used content is cached for cost and latency reduction.

**Benefits:**
- 90% cost reduction for cached content
- 85% latency reduction for cached prompts
- CLAUDE.md loaded once per session

**Framework integration:**
- CLAUDE.md kept under 500 tokens for efficient caching
- Agent definitions cached per subagent type
- Skills loaded on-demand (not cached)

### 3. Subagent Context Isolation

Each subagent spawned via Task tool has isolated context.

**How it works:**
- Parent passes task prompt to subagent
- Subagent works in isolation
- Only results propagate back to parent

**Framework integration:**
- Research agents run in isolation for focused investigation
- Dev agents work on specific features without context pollution
- Parallel agents don't interfere with each other

### 4. Tool Permission Enforcement

Task tool's `subagent_type` controls tool access.

**How it works:**
- Each subagent type has predefined tool access
- Claude Code enforces restrictions
- Agents cannot access unauthorized tools

**Framework integration:**
- Agent YAML documents intended tools
- TOOL-PERMISSIONS.md provides reference
- Subagent_type maps to agent roles

## What We Keep Custom (Framework Methodology)

These are **our own patterns**, not from SDK:

### 1. Requirements Workflow

Three-phase flow from idea to roadmap:
1. **Requirements Development** - Formal specs from ideas
2. **Requirements Analysis** - Strategic assessment
3. **Roadmap Creation** - Atomic breakdown

**Why custom:** SDK doesn't have Ghost County methodology.

### 2. Roadmap Management

Single source of truth for project work:
- Status tracking (⚪🟡🟢🔴)
- Batch organization for parallel work
- Archiving for completed work

**Why custom:** SDK doesn't manage project roadmaps.

### 3. Active Work Section

Optimized context delivery to spawned agents:
- Only current work items (~500 tokens)
- Project Manager maintains sync
- Prevents loading full roadmap (~5000+ tokens)

**Why custom:** SDK compaction doesn't prioritize specific content.

### 4. Pattern Detection & Defeat

TDD approach for eliminating recurring problems:
- Identify patterns from errors and reviews
- Write defeat tests
- Add to pre-commit hooks
- Update agent memory

**Why custom:** SDK doesn't learn from project-specific patterns.

### 5. Skills System

On-demand loading of specialized guidance:
- YAML frontmatter with triggers
- Invoked by keywords
- Loaded into context when needed

**Why custom:** Claude Code has slash commands, but our skills have project-specific content.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Claude Code CLI                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              SDK Infrastructure                      │    │
│  │  - Context Compaction (automatic)                   │    │
│  │  - Prompt Caching (CLAUDE.md, agents)               │    │
│  │  - Subagent Isolation (Task tool)                   │    │
│  │  - Tool Permissions (subagent_type)                 │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 Haunt Framework               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Custom Methodology                       │    │
│  │  - Requirements Workflow (3-phase)                   │    │
│  │  - Roadmap Management (status, batches)              │    │
│  │  - Active Work Section (context optimization)        │    │
│  │  - Pattern Detection (defeat tests)                  │    │
│  │  - Skills System (on-demand guidance)                │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  Agents                               │    │
│  │  - Dev (backend/frontend/infrastructure)             │    │
│  │  - Research (analyst/critic)                         │    │
│  │  - Project Manager                                   │    │
│  │  - Code Reviewer                                     │    │
│  │  - Release Manager                                   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    MCP Servers                               │
│  - Context7 (library documentation)                         │
│  - Agent Memory (persistent context)                        │
└─────────────────────────────────────────────────────────────┘
```

## SDK Packages Explained

| Package | Purpose | When to Use |
|---------|---------|-------------|
| `@anthropic-ai/claude-code` | CLI tool with built-in SDK | Default for Haunt |
| `@anthropic-ai/claude-agent-sdk` | Programmatic agent building | Custom applications outside CLI |
| `@anthropic-ai/sdk` | Direct API access | Low-level API calls |

**For Haunt:** Use Claude Code CLI (`@anthropic-ai/claude-code`). It includes all SDK features.

## Integration Points

### Session Startup

```
SDK: Context restored from previous session (automatic)
Framework: Read Active Work, verify environment, check tests
```

### Agent Spawning

```
Framework: Project Manager dispatches via Task tool
SDK: Subagent created with isolated context and tool permissions
Framework: Agent executes skill-based workflow
SDK: Results returned, context cleaned up
```

### Error Handling

```
SDK: Tool errors surfaced in response
Framework: Errors flow to pattern detection
Framework: Recurring errors become defeat tests
```

### Context Management

```
SDK: Automatic compaction when approaching limits
Framework: Active Work section keeps context minimal
Framework: Archiving removes completed work from context
```

## Configuration

### CLAUDE.md Structure

```markdown
# CLAUDE.md

## Repository Purpose
[Brief description]

## Active Work
[Current items - kept under 500 tokens]

## Key Information
[What agents need to know]
```

### Agent YAML

```yaml
---
name: agent-name
description: When to use this agent
tools: Glob, Grep, Read, Edit, Write, Bash, ...
skills: skill1, skill2, skill3
# Tool permissions enforced by Task tool subagent_type
---
```

### Subagent Types

Use these with the Task tool:

| Agent Role | Subagent Type | Agent File |
|------------|---------------|------------|
| Backend development | Dev-Backend | gco-dev.md (polyglot) |
| Frontend development | Dev-Frontend | gco-dev.md (polyglot) |
| Infrastructure | Dev-Infrastructure | gco-dev.md (polyglot) |
| Research | Research-Analyst | gco-research.md |
| Validation | Research-Critic | gco-research.md |
| Planning | Project-Manager-Agent | gco-project-manager.md |

**Note:** `gco-dev.md` is a single polyglot agent that handles all three development modes. The subagent_type determines tool access; the agent determines its working mode from file paths and task context.

## Best Practices

### Do

- Let SDK handle context compaction automatically
- Keep CLAUDE.md Active Work section small
- Use appropriate subagent_type for tool access
- Document patterns when errors recur
- Archive completed roadmap items promptly

### Don't

- Try to manually manage context window
- Load full roadmap into every agent
- Expect agents to have tools outside their subagent_type
- Ignore recurring errors (they become patterns)
- Keep completed work in active roadmap

## Troubleshooting

### Context Overflow

**Symptom:** Session ends abruptly or summarization occurs frequently

**Cause:** Too much context accumulated

**Fix:**
1. Archive completed roadmap items
2. Reduce CLAUDE.md Active Work section
3. Use subagents for large tasks (isolated context)

### Agent Missing Tools

**Symptom:** Agent can't perform required operation

**Cause:** Subagent_type doesn't include needed tool

**Fix:**
1. Check TOOL-PERMISSIONS.md for subagent capabilities
2. Use different subagent_type if appropriate
3. Have orchestrator perform the operation

### Slow Response

**Symptom:** Agent responses are slow

**Cause:** Context too large or cache miss

**Fix:**
1. Reduce CLAUDE.md size
2. Ensure consistent CLAUDE.md content (helps caching)
3. Use subagents for isolated work

## References

- [SDK Context Integration Research](../../.haunt/plans/sdk-context-integration.md)
- [Tool Permissions Reference](TOOL-PERMISSIONS.md)
- [Session Startup Skill](../skills/gco-session-startup/SKILL.md)
- [Pattern Defeat Skill](../skills/gco-pattern-defeat/SKILL.md)
