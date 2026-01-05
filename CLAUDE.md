# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a knowledge base and framework repository for **Haunt** - a methodology for building and operating autonomous AI agent teams for software development. It contains:

- **Haunt/** - v2.0 Lightweight agent framework
  - **Haunt/agents/** - Agent character sheets (30-50 lines each)
  - **Haunt/rules/** - Invariant enforcement protocols (deployed to ~/.claude/rules/)
  - **Haunt/skills/** - SDLC methodology skills (on-demand)
  - **Haunt/scripts/** - Setup and validation scripts
- **Skills/** - Domain-specific Claude Code skills (career, business, finance, etc.)

## Active Work

Current work items for spawned agents. PM maintains this section from `.haunt/plans/roadmap.md`.

See `~/.claude/rules/gco-roadmap-format.md` for status update protocol (global rules location).

### Current Items

**Status:** All requirements complete. Roadmap clear.

**Archived (2026-01-05):**
- 64 total requirements archived to `.haunt/completed/2026-01/`
- Latest: Repository Cleanup Batch (8 requirements) + Task Checkbox Enforcement
- Previous: Damage Control Hooks, Secrets Management Core, Skill Compression

Run `/seance` to start new work.

## Repository Structure

```
ghost-county/
├── Haunt/                     # v2.0 Lightweight agent framework
│   ├── agents/               # Agent character sheets (30-50 lines each)
│   ├── rules/                # Invariant enforcement protocols (source - deployed to ~/.claude/rules/)
│   ├── skills/               # SDLC methodology skills (on-demand)
│   ├── scripts/              # Setup and validation scripts
│   ├── docs/                 # Detailed framework documentation
│   │   ├── WHITE-PAPER.md
│   │   ├── SDK-INTEGRATION.md
│   │   ├── TOOL-PERMISSIONS.md
│   │   ├── SKILLS-REFERENCE.md
│   │   ├── PATTERN-DETECTION.md
│   │   └── HAUNT-DIRECTORY-SPEC.md
│   ├── README.md             # Architecture overview
│   ├── SETUP-GUIDE.md        # Complete setup instructions
│   └── QUICK-REFERENCE.md    # Quick reference card
├── Skills/                    # Domain-specific skills (optional)
│   ├── */SKILL.md            # Career, business, finance skills
│   └── */references/         # Supporting documentation
├── .haunt/                   # Project SDLC artifacts (gitignored)
│   ├── plans/                # Feature roadmaps and planning
│   │   └── roadmap.md        # Main project roadmap
│   ├── progress/             # Session progress tracking
│   ├── completed/            # Archived completed work
│   ├── tests/                # SDLC-related tests
│   │   ├── patterns/         # Pattern defeat tests
│   │   ├── behavior/         # Agent behavior tests
│   │   └── e2e/              # End-to-end tests
│   └── docs/                 # SDLC documentation
│       └── INITIALIZATION.md # Project initialization guide
```

## Key Automation Scripts

Located in `Haunt/scripts/`:

```bash
# Full setup (v2.0 recommended)
bash Haunt/scripts/setup-agentic-sdlc.sh

# Only update global agents
bash Haunt/scripts/setup-agentic-sdlc.sh --agents-only

# Project setup only (skip global agents)
bash Haunt/scripts/setup-agentic-sdlc.sh --project-only

# Verify setup completeness
bash Haunt/scripts/setup-agentic-sdlc.sh --verify

# Validation scripts
bash Haunt/scripts/validation/validate-skills.sh
bash Haunt/scripts/validation/validate-agent-skills.sh
```

## Agent Architecture

## Model Selection

Agents use models specified in their character sheets:

| Agent | Model | Why |
|-------|-------|-----|
| Project Manager | Opus | Strategic analysis (JTBD, Kano, RICE) determines all downstream work |
| Research | Opus | Deep investigation and architecture recommendations require highest reasoning |
| Research Analyst | Opus | Deep investigation and architecture recommendations require highest reasoning |
| Research Critic | Opus | Adversarial review requires thorough analysis and critical reasoning |
| Dev (all types) | Sonnet | Implementation is well-scoped, Sonnet sufficient for TDD and patterns |
| Code Reviewer | Sonnet | Pattern detection and quality gates, not strategic decisions |
| Release Manager | Sonnet | Coordination and risk assessment, not deep strategic reasoning |

**Rationale:** Planning/research agents use Opus for higher reasoning quality in strategic work. Implementation agents use Sonnet for efficiency in well-scoped execution work. The cost difference is negligible compared to the cost of poor strategic decisions.

See `~/.claude/rules/gco-model-selection.md` for detailed guidance (global rules location).



Agents follow a naming convention: `[Category]-[Role]`

| Type | Agents | Purpose |
|------|--------|---------|
| Coordinator | Project-Manager | Roadmap, prioritization, dispatch |
| Worker | Dev-Backend, Dev-Frontend, Dev-Infrastructure | Feature implementation |
| Researcher | Research-Analyst, Research-Critic | Investigation, validation |
| Quality | Code-Reviewer, Release-Manager | Code review, merge coordination |

Agent character sheets belong in `~/.claude/agents/` (global) or `.claude/agents/` (project-specific).

## Skills Format

Skills use YAML frontmatter with `name` and `description`, followed by markdown content:

```markdown
---
name: skill-name
description: When to trigger this skill and what it does.
---

# Skill Title
[Skill content...]
```

## Requirements Format

See `~/.claude/rules/gco-roadmap-format.md` for requirement structure and status icons (global rules location).

Key: ⚪ Not Started | 🟡 In Progress | 🟢 Complete | 🔴 Blocked

## Core Methodology Principles

1. **One-Feature-Per-Session Rule** - Complete one feature/fix per session before starting another
2. **Feature Contract Immutability** - Acceptance criteria cannot be modified mid-implementation
3. **Tests Before Code** - Pattern: Pattern Found → Test Written → Agent Trained → Pattern Defeated
4. **Memory Hierarchy** - 5 layers: Core Identity, Long-term Insights, Medium-term Patterns, Recent Tasks, Compost

## Auto-Triggered Workflows

### Issue/Bug/Feature Reporting → Roadmap

When the user reports an issue, bug, idea, or feature request, **automatically invoke the `issue-to-roadmap` skill**.

**Trigger phrases include:**
- Problems: "I found a bug", "there's an issue", "this is broken", "X doesn't work", "getting an error"
- Ideas: "I want to add", "we should build", "new feature", "what if we", "can we add"
- Explicit: "log this", "track this", "add to roadmap", "create a ticket", "we need to fix"

**Workflow:**
1. Acknowledge and confirm understanding (1-2 sentences)
2. Ask clarifying question ONLY if critical context is missing
3. Generate requirement, size it, assign agent
4. Add to `.haunt/plans/roadmap.md`
5. Confirm to user with REQ number and assignment

Do NOT ask the user "should I log this?" - if it sounds like an issue or request, log it automatically.

## Infrastructure Dependencies

- **MCP Servers** - Context7 (library docs), Agent Memory (persistence)
- **Playwright** - E2E browser automation tests

Verify with: `bash scripts/verify-infrastructure.sh`
