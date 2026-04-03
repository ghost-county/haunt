# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

**Haunt** is a dev guardrails and agent coordination toolkit for Claude Code. It provides quality gates, coding standards, testing enforcement, and a spec-driven development workflow (the seance) powered by Claude Code Agent Teams.

Contents:
- **Haunt/agents/** - Team-aware agent definitions (deployed to `~/.claude/agents/`)
- **Haunt/rules/** - Always-loaded behavioral rules (deployed to `~/.claude/rules/`)
- **Haunt/skills/** - On-demand methodology skills (deployed to `~/.claude/skills/`)
- **Haunt/commands/** - Slash commands (deployed to `~/.claude/commands/`)
- **Skills/** - Domain-specific skills (career, business, finance, etc.)

## Setup

```bash
bash Haunt/scripts/setup-haunt.sh          # Deploy agents + rules + skills + commands
bash Haunt/scripts/setup-haunt.sh --verify  # Verify deployment
```

## Repository Structure

```
haunt/
├── Haunt/                     # Dev guardrails + agent coordination framework
│   ├── agents/               # Team-aware agents (6 gco agents)
│   ├── agents/archive/       # Archived original agent definitions (reference)
│   ├── rules/                # Always-loaded rules (6 gco rules)
│   ├── skills/               # On-demand skills (~16 gco skills)
│   ├── commands/             # Slash commands (seance, ship, qa, checkup)
│   ├── scripts/              # setup-haunt.sh
│   ├── hooks/                # Damage control hooks
│   └── docs/                 # Framework documentation
├── Skills/                    # Domain-specific skills (optional)
│   ├── */SKILL.md
│   └── */references/
└── CLAUDE.md                  # This file
```

## What's Included

### Agents (team teammates for seance workflow)

| Agent | Purpose |
|-------|---------|
| `gco-project-manager` | Requirements, strategic analysis, roadmap creation |
| `gco-dev` | Code implementation across backend/frontend/infrastructure |
| `gco-research` | Investigation, validation, adversarial requirements review |
| `gco-code-reviewer` | Review router: single-pass for S, delegates to specialists for M+ |
| `gco-security-reviewer` | Security-focused review: OWASP Top 10, STRIDE, CWE classification |
| `gco-quality-reviewer` | Quality-focused review: anti-patterns, test coverage, conventions |

### Rules (always loaded, enforce behavior)

| Rule | Purpose |
|------|---------|
| `gco-communication.md` | Direct communication style, no glazing |
| `gco-completion-checklist.md` | Tests pass + demo-ready before marking complete |
| `gco-decisions.md` | YAGNI, 4-question decision filter |
| `gco-team-coordination.md` | Task claiming, completion reporting, team behavior |
| `gco-ui-testing-reminder.md` | E2E test enforcement for frontend work |
| `gco-visual-verification.md` | Screenshot verification for CSS changes |

### Skills (on-demand, invoked when needed)

**Code quality:** `gco-code-review`, `gco-commit-conventions`, `gco-code-patterns`
**Testing:** `gco-tdd-workflow`, `gco-playwright-tests`, `gco-ui-testing`, `gco-testing-mindset`
**Standards:** `gco-secure-coding`, `gco-python-standards`, `gco-react-standards`, `gco-ui-design`
**Methodology:** `gco-task-decomposition`, `gco-requirements-development`, `gco-context7-usage`
**Orchestration:** `gco-seance-orchestration`, `gco-team-protocol`

### Commands

| Command | Purpose |
|---------|---------|
| `/seance` | Complete dev ritual: planning -> execution -> archival |
| `/ship` | Create PR and enable auto-merge |
| `/qa` | Generate test scenarios (checklist, gherkin, playwright, charter) |
| `/checkup` | Verify deployment health |

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

## Infrastructure Dependencies

- **MCP Servers** - Context7 (library docs)
- **Playwright** - E2E browser automation tests
