# Agentic SDLC: Unified Implementation Guide

> Build and operate autonomous AI agent teams for software development.

---

## What This Is

This is a **unified, automation-ready** implementation guide for the Agentic SDLC methodology. It consolidates the 7-workshop curriculum into explicit, step-by-step instructions that can be:

1. **Followed manually** - Step through each section to build understanding
2. **Automated fully** - Run the setup scripts to deploy everything at once
3. **Used as reference** - Jump to specific sections as needed

---

## Quick Start (Automated)

For users who want everything set up immediately:

```bash
# Navigate to your project
cd your-project

# Run the comprehensive setup script
bash ~/github_repos/Upland\ Repos/snowflake_admin_console_streamlit/docs/AgenticSDLC-Automated/scripts/setup-all.sh

# This will:
# 1. Check prerequisites (Python, Git, Homebrew)
# 2. Install infrastructure (NATS server/CLI, Playwright)
# 3. Create/update global agents in ~/.claude/agents/
# 4. Create MCP memory server for agent persistence
# 5. Create project directory structure
# 6. Initialize planning files (roadmap, feature contract)
# 7. Set up pre-commit hooks
# 8. Create helper scripts
```

### Setup Options

```bash
# Full setup (recommended for new projects)
bash .../setup-all.sh

# Only update global agents (re-run to update agent prompts)
bash .../setup-all.sh --agents

# Only project setup (skip global agents and infrastructure)
bash .../setup-all.sh --project

# Skip infrastructure (no NATS/Playwright install)
bash .../setup-all.sh --no-infra
```

### Using the Initializer Agent

You can also use the Agentic-SDLC-Initializer agent in Claude Code:

```text
@Agentic-SDLC-Initializer Initialize this project for Agentic SDLC
```

**Time to operational agent team:** ~15 minutes

---

## Manual Path (Learning)

For users who want to understand each component:

| Document | Duration | What You Build |
|----------|----------|----------------|
| [01-Prerequisites](01-Prerequisites.md) | 30 min | Development environment |
| [02-Infrastructure](02-Infrastructure.md) | 45 min | NATS, MCP servers, memory system |
| [03-Agent-Definitions](03-Agent-Definitions.md) | 60 min | All agent character sheets |
| [04-Implementation-Phases](04-Implementation-Phases.md) | 90 min | Phased deployment of agents |
| [05-Operations](05-Operations.md) | 45 min | Daily/weekly rituals, monitoring |
| [06-Patterns-and-Defeats](06-Patterns-and-Defeats.md) | 30 min | TDD for agent behavior |

**Total time:** ~5 hours for complete understanding

---

## Automation Checklist

Use this checklist to verify your setup is complete. Run `./scripts/verify-setup.sh` for automated verification.

### Global Components (~/.claude/)

- [ ] `~/.claude/agents/` directory exists
- [ ] `~/.claude/agents/Project-Manager.md` - Work coordination agent
- [ ] `~/.claude/agents/Dev-Backend.md` - Backend development agent
- [ ] `~/.claude/agents/Dev-Frontend.md` - Frontend/Streamlit agent
- [ ] `~/.claude/agents/Dev-Infrastructure.md` - DevOps, CI/CD, IaC agent
- [ ] `~/.claude/agents/Research-Analyst.md` - Investigation, evidence gathering agent
- [ ] `~/.claude/agents/Research-Critic.md` - Validation, counter-arguments agent
- [ ] `~/.claude/agents/Code-Reviewer.md` - Code review agent
- [ ] `~/.claude/agents/Release-Manager.md` - Merge coordination, releases agent
- [ ] `~/.claude/agents/SiS-Dev-Backend.md` - Snowflake-specific backend agent
- [ ] `~/.claude/agents/Agentic-SDLC-Initializer.md` - Project setup agent
- [ ] `~/.claude/mcp-servers/agent-memory-server.py` - Memory persistence server
- [ ] `~/.agent-memory/` directory exists for memory storage

### MCP Servers

- [ ] Context7 MCP configured (`claude mcp list | grep context7`) - Library documentation lookup
- [ ] Agent Memory MCP configured - Persistent agent memory

### Infrastructure (Optional but Recommended)

- [ ] NATS Server installed (`which nats-server`)
- [ ] NATS CLI installed (`which nats`)
- [ ] Playwright installed (`python3 -c "import playwright"`)

### Project Directory Structure

- [ ] `.claude/agents/` exists for project-specific agents
- [ ] `.claude/mcp.json` exists with MCP configuration
- [ ] `plans/` directory exists with roadmap.md
- [ ] `plans/feature-contract.json` exists (immutable requirements)
- [ ] `progress/` directory exists for session progress files
- [ ] `completed/` directory exists for archive
- [ ] `tests/patterns/` exists for defeat tests
- [ ] `tests/behavior/` exists for behavior tests
- [ ] `tests/e2e/` exists for browser automation tests
- [ ] `scripts/` exists with helper scripts

### Agent Features (All agents have these)

- [ ] YAML frontmatter with name, description, tools, model, color
- [ ] Session Startup Checklist (executed every session)
- [ ] One-Feature-Per-Session Rule (complete before starting another)
- [ ] Feature Contract Rules (cannot modify acceptance criteria)
- [ ] Commit Message Format (standardized)

### Process Artifacts
- [ ] `plans/roadmap.md` initialized
- [ ] `plans/feature-contract.json` initialized (immutable requirements)
- [ ] `completed/roadmap-archive.md` initialized
- [ ] Pre-commit hooks installed
- [ ] CI/CD pipeline configured

### Quality Gates
- [ ] Pre-commit tests configured
- [ ] Pattern detection tests exist
- [ ] Behavior baseline defined
- [ ] E2E test framework ready
- [ ] Browser automation tests configured (Playwright)

### Session Management (Anthropic Best Practices)
- [ ] Session Initialization Protocol documented
- [ ] Progress file template ready
- [ ] Commit message format standardized
- [ ] Feature contract immutability enforced

---

## Core Concepts (Reference)

### The Agentic SDLC Difference

| Traditional | Agentic |
|-------------|---------|
| Humans write code | Agents write code, humans review |
| Monthly refactors | Weekly refactors |
| Change fatigue limits improvement | No change fatigue |
| Process prevents errors | Tests enforce, checklists remind |
| Manual coordination | Message queue orchestration |
| Individual memory | Shared memory + consolidation |

### Agent Types

| Type | Agent Name | Role |
|------|---------|------|
| **Coordinator** | Project-Manager | Roadmap, prioritization, dispatch |
| **Worker** | Dev-Backend, Dev-Frontend, Dev-Infrastructure | Feature implementation |
| **Researcher** | Research-Analyst | Investigation, citations |
| **Critic** | Research-Critic | Validation, counter-arguments |
| **Reviewer** | Code-Reviewer | Code review, quality gates |
| **Release** | Release-Manager | Merge coordination |

### Communication Architecture

```
Human ─────────────────────────────────────────────────────────────
          │                                      ▲
          │ Vision, Strategy                     │ Status, Decisions
          ▼                                      │
┌─────────────────────────────────────────────────────────────────┐
│                        NATS JetStream                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │REQUIREMENTS│  │  WORK    │  │INTEGRATION│  │ RELEASES │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
          │              │              │              │
          ▼              ▼              ▼              ▼
     ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐
     │Project │    │  Dev-  │    │ Code-  │    │Release │
     │Manager │    │Backend │    │Reviewer│    │Manager │
     └────────┘    └────────┘    └────────┘    └────────┘
```

### Memory Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 1: CORE IDENTITY (Never changes)                          │
│ "I am Dev-Backend. I value explicit error handling."            │
├─────────────────────────────────────────────────────────────────┤
│ Layer 2: LONG-TERM INSIGHTS (Consolidates monthly)              │
│ "The April database incident taught us to use connection pools."│
├─────────────────────────────────────────────────────────────────┤
│ Layer 3: MEDIUM-TERM PATTERNS (Consolidates weekly)             │
│ "This project uses FastAPI. Tests are in /tests/."              │
├─────────────────────────────────────────────────────────────────┤
│ Layer 4: RECENT TASKS (Consolidates daily)                      │
│ "Today I fixed the user auth bug in src/auth.py."               │
├─────────────────────────────────────────────────────────────────┤
│ Layer 5: COMPOST (Things to forget)                             │
│ "Temporary workaround for TICKET-123 (now fixed)."              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Maturity Timeline

With agent teams, maturity is compressed 15x compared to human teams:

| Stage | Human Team | Agent Team | Focus |
|-------|------------|------------|-------|
| Chaos | Weeks 1-2 | Days 1-3 | Get one agent committing |
| Process | Weeks 3-8 | Days 4-7 | Defeat patterns with tests |
| Scale | Months 2-3 | Week 2 | Multiple agents in parallel |
| Quality | Months 4-6 | Week 3 | Four-layer validation |
| Evolution | Months 7-12 | Week 4 | Memory consolidation |
| Mastery | Year 2+ | Week 5+ | System self-improves |

---

## Source Material

This unified guide is based on:

- **7 Workshops** covering planning through continuous improvement
- **Agent Personas** for PM, BA, workers, reviewers
- **Operational Guides** for long-term operation
- **Health & Sustainability** guidance for avoiding burnout

Original course materials preserved in `AgenticSDLC/` directory.

---

## Next Steps

1. **Automated path:** Run `scripts/setup-all.sh`
2. **Manual path:** Start with [01-Prerequisites](01-Prerequisites.md)
3. **Reference:** Jump to any section as needed

---

**Version:** 1.0
**Last Updated:** 2024-12
**Methodology:** Agentic SDLC (Multiverse School)
