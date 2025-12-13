# Claude Code External Memory: Rules, Skills, Agents, and CLAUDE.md

Understanding how Claude Code's layered memory system works together to create consistent, intelligent behavior.

## The Four-Layer Memory Model

Claude Code uses four distinct layers of external memory, each serving a specific purpose:

| Layer | Location | Purpose | Loading | Priority |
|-------|----------|---------|---------|----------|
| **Rules** | `.claude/rules/*.md` | "You MUST always do this" | Automatic | Highest |
| **Agent Definitions** | `.claude/agents/*.md` | "This is WHO you are" | On spawn | High |
| **Skills** | Skills directory | "Here's HOW to do this" | On-demand | Medium |
| **CLAUDE.md** | Project root | "This is WHAT and WHY" | Always | Base context |

## Layer 1: Rules - Invariant Enforcement

**Purpose:** Non-negotiable protocols that must always be followed.

**Characteristics:**
- Loaded automatically at session start
- Cannot be overridden by user instructions
- Path-targeted (can activate only for specific files)
- Short, imperative statements

**Best For:**
- Commit message formats
- File location conventions
- Status update protocols
- Session startup checklists
- Security requirements

**Example Rule:**
```markdown
# Commit Format

Every commit MUST follow this structure:
[REQ-XXX] Action: Brief description

NEVER commit without a requirement reference.
```

**Path Targeting:**
Rules can use YAML frontmatter to activate only for specific files:
```yaml
---
paths:
  - .haunt/plans/roadmap.md
  - .haunt/plans/*.md
---
# Roadmap Format Rules
...
```

## Layer 2: Agent Definitions - Identity and Values

**Purpose:** Define who the agent is, their core values, and operating modes.

**Characteristics:**
- Loaded when agent is spawned via Task tool
- Defines identity, not procedures
- Stable over time (rarely changes)
- Short (30-50 lines)

**Best For:**
- Core values and principles
- Operating modes (e.g., Analyst vs Critic)
- Fundamental responsibilities
- Output format preferences
- What the agent does NOT do

**Example Agent Definition:**
```yaml
---
name: dev
description: Development agent for implementation
tools: Glob, Grep, Read, Edit, Write, Bash
skills: tdd-workflow, commit-conventions
---

# Dev Agent

## Identity
I implement features, write tests, and maintain code quality.

## Values
- Tests before implementation
- Simple over clever
- One feature per session

## What I Don't Do
- I don't plan roadmaps (PM does that)
- I don't validate research (Critic does that)
```

## Layer 3: Skills - Domain Expertise

**Purpose:** Detailed how-to guidance for complex workflows.

**Characteristics:**
- Loaded on-demand when triggered
- Can be extensive (100-500 lines)
- Contains examples, checklists, decision trees
- Iterative and judgment-based content

**Best For:**
- Complex methodologies (TDD workflow)
- Multi-step processes (requirements elicitation)
- Quality checklists (code review)
- Domain-specific expertise
- Educational content with examples

**Example Skill:**
```yaml
---
name: tdd-workflow
description: Test-driven development guidance
---

# TDD Workflow

## The Red-Green-Refactor Cycle

1. **Red:** Write a failing test
   - Define expected behavior
   - Run test, confirm it fails

2. **Green:** Write minimal code to pass
   - Only enough to make test pass
   - No premature optimization

3. **Refactor:** Improve without changing behavior
   - Clean up code
   - All tests still pass

## When to Use TDD
[Detailed guidance...]

## Examples
[Worked examples...]
```

## Layer 4: CLAUDE.md - Project Context

**Purpose:** Current project state and active work.

**Characteristics:**
- Always loaded (cached for 60 minutes)
- Project-specific information
- Changes frequently (active work updates)
- Should stay under 500 tokens

**Best For:**
- Repository purpose and structure
- Current work assignments (Active Work section)
- Project-specific conventions
- Infrastructure dependencies
- Recent decisions and context

**Example CLAUDE.md:**
```markdown
# CLAUDE.md

## Repository Purpose
E-commerce platform with React frontend and Node.js API.

## Active Work
- 🟡 REQ-042: Add payment processing
- ⚪ REQ-043: Implement order history

## Key Commands
npm test        # Run tests
npm run build   # Build for production

## Recent Decisions
- Using Stripe for payments (decided 2024-01-15)
- PostgreSQL for order data
```

## How the Layers Work Together

### Precedence Hierarchy

When there's a conflict, higher layers win:

```
Rules (highest)
  ↓
Agent Definitions
  ↓
Skills
  ↓
CLAUDE.md (base context)
```

### Information Flow Example

Consider an agent starting work:

1. **Rules load first** → "You MUST verify tests pass before starting work"
2. **Agent definition loads** → "I am a Dev agent focused on implementation"
3. **CLAUDE.md provides context** → "Current work: REQ-042 payment processing"
4. **Skills invoked as needed** → "Use TDD workflow for new features"

### Separation of Concerns

| Question | Layer |
|----------|-------|
| "What format must I use?" | Rules |
| "Who am I and what do I value?" | Agent Definition |
| "How do I do this complex task?" | Skills |
| "What am I working on right now?" | CLAUDE.md |

## Practical Guidelines

### Put it in Rules when:
- It's non-negotiable (MUST, NEVER)
- It applies to every session
- It's about format or protocol
- Violation would cause problems

### Put it in Agent Definition when:
- It defines identity or values
- It distinguishes this agent from others
- It's stable over time
- It's about what the agent IS, not what it DOES

### Put it in Skills when:
- It requires judgment or expertise
- It has multiple steps or decision points
- It benefits from examples
- It's not needed every session

### Put it in CLAUDE.md when:
- It's project-specific
- It changes frequently
- It's about current state
- It provides context, not instructions

## Token Efficiency

| Layer | Target Size | Loading Cost |
|-------|-------------|--------------|
| Rules (each) | 50-100 lines | On match (or always) |
| Agent Definition | 30-50 lines | On spawn |
| Skills (each) | 100-500 lines | On-demand only |
| CLAUDE.md | <500 tokens | Every session |

**Optimization Strategy:**
- Keep rules focused and short
- Don't duplicate content across layers
- Use path-targeting to limit rule loading
- Skills load only when triggered by description

## The "Three Imperatives" Model

A simple way to remember the layers:

1. **Rules:** "You MUST always..."
2. **Agent:** "You ARE a..."
3. **Skills:** "You CAN do this BY..."
4. **CLAUDE.md:** "You're WORKING ON..."

## Summary

Claude Code's external memory system provides:

- **Rules** for enforcement (invariants)
- **Agents** for identity (who)
- **Skills** for expertise (how)
- **CLAUDE.md** for context (what/why)

Together, these layers create a comprehensive memory system that guides consistent, intelligent behavior while remaining maintainable and token-efficient.
