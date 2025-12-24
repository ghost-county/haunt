# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a knowledge base and framework repository for **Haunt** - a methodology for building and operating autonomous AI agent teams for software development. It contains:

- **Haunt/** - v2.0 Lightweight agent framework
  - **Haunt/agents/** - Agent character sheets (30-50 lines each)
  - **Haunt/rules/** - Invariant enforcement protocols (auto-loaded)
  - **Haunt/skills/** - SDLC methodology skills (on-demand)
  - **Haunt/scripts/** - Setup and validation scripts
- **Skills/** - Domain-specific Claude Code skills (career, business, finance, etc.)
- **Knowledge/** - Educational curriculum from "Ghost County - Multiverse Curriculum"
- **Agentic_SDLC_Framework/** - v1.0 Legacy framework (monolithic agents)

## Active Work

Current work items for spawned agents. PM maintains this section from `.haunt/plans/roadmap.md`.

See `.claude/rules/gco-status-updates.md` for update protocol.

### Current Items

**BMAD-Inspired Enhancements (3 Phases, 13 Requirements)**

Phase 1 - Quick Wins (5 requirements, ~10 hours):
⚪ REQ-228: Create Séance Workflow Infographic (Agent: Dev-Infrastructure, S)
⚪ REQ-229: Create Agent Coordination Diagram (Agent: Dev-Infrastructure, S)
⚪ REQ-230: Create Session Startup Protocol Diagram (Agent: Dev-Infrastructure, S)
⚪ REQ-231: Implement /haunt status --batch Command (Agent: Dev-Infrastructure, M)
⚪ REQ-232: Add Effort Estimation to Batch Status (Agent: Dev-Infrastructure, S, blocked by REQ-231)

Phase 2 - Medium Effort (5 requirements, ~22 hours):
⚪ REQ-225: Add /seance --quick Mode (Agent: Dev-Infrastructure, S)
⚪ REQ-226: Add /seance --deep Mode (Agent: Dev-Infrastructure, M)
⚪ REQ-227: Update Séance Skill with Mode Selection (Agent: Dev-Infrastructure, S, blocked by REQ-225/226)
⚪ REQ-223: Create /story Command (Agent: Dev-Infrastructure, M)
⚪ REQ-224: Update Dev Agent Startup to Load Story Files (Agent: Dev-Infrastructure, S, blocked by REQ-223)

Phase 3 - High Impact (3 requirements, ~14 hours):
⚪ REQ-220: Implement Batch-Specific Roadmap Sharding (Agent: Dev-Infrastructure, M)
⚪ REQ-221: Update Session Startup to Load Active Batch Only (Agent: Dev-Infrastructure, S, blocked by REQ-220)
⚪ REQ-222: Archive Completed Batches Automatically (Agent: Dev-Infrastructure, M, blocked by REQ-220)

**Also on roadmap:**
⚪ REQ-205: GitHub Issues Integration (Research-Analyst → Dev-Infrastructure)
⚪ REQ-206: Create /bind Command (Dev-Infrastructure)
⚪ REQ-242: Auto-install missing dependencies in setup scripts (Dev-Infrastructure, M)
⚪ REQ-243: Fix Windows setup not installing slash commands (Dev-Infrastructure, S)

See `.haunt/plans/roadmap.md` for full details.

## Repository Structure

```
ghost-county/
├── Haunt/                     # v2.0 Lightweight agent framework
│   ├── agents/               # Agent character sheets (30-50 lines each)
│   ├── rules/                # Invariant enforcement protocols (7 rules)
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
├── Knowledge/                 # Educational materials
│   └── Ghost County - Multiverse Curriculum/
├── Agentic_SDLC_Framework/   # v1.0 Legacy framework (monolithic agents)
│   ├── 00-Overview.md        # Quick start guide
│   ├── 01-Prerequisites.md   # Environment setup
│   ├── 02-Infrastructure.md  # MCP servers, memory
│   ├── 03-Agent-Definitions.md  # Agent character sheets
│   ├── 04-Implementation-Phases.md
│   ├── 05-Operations.md      # Daily/weekly rituals
│   ├── 06-Patterns-and-Defeats.md  # TDD for agent behavior
│   └── scripts/              # Automation scripts
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
| Project Manager | Sonnet/Opus | Strategic analysis (JTBD, Kano, RICE) - high leverage |
| Research | Sonnet | Deep investigation and architecture recommendations |
| Research Analyst | Sonnet | Investigation and validation require thorough analysis |
| Research Critic | Sonnet | Adversarial review and critical analysis require deep reasoning |
| Dev | Sonnet | Implementation requires reasoning (TDD, patterns, edge cases) |
| Code Reviewer | Sonnet | Quality gates and pattern detection |
| Release Manager | Sonnet | Risk assessment and coordination |

**Rationale:** High-leverage activities (requirements, research, implementation, review) require high-capability models. The cost difference is negligible compared to the cost of poor decisions or wasted dev time.

See `.claude/rules/gco-model-selection.md` for detailed guidance.



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

See `.claude/rules/gco-roadmap-format.md` for requirement structure and status icons.

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
