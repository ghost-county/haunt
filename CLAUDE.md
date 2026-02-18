# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

**Haunt** is a dev guardrails toolkit for Claude Code. It provides quality gates, coding standards, and testing enforcement that make Claude a better development partner — without the coordination overhead.

Contents:
- **Haunt/rules/** - Always-loaded behavioral rules (deployed to `~/.claude/rules/`)
- **Haunt/skills/** - On-demand methodology skills (deployed to `~/.claude/skills/`)
- **Haunt/commands/** - Slash commands (deployed to `~/.claude/commands/`)
- **Skills/** - Domain-specific skills (career, business, finance, etc.)

## Setup

```bash
bash Haunt/scripts/setup-haunt.sh          # Deploy rules + skills + commands
bash Haunt/scripts/setup-haunt.sh --verify  # Verify deployment
```

## Repository Structure

```
haunt/
├── Haunt/                     # Dev guardrails framework
│   ├── rules/                # Always-loaded rules (5 gco rules)
│   ├── skills/               # On-demand skills (~14 gco skills)
│   ├── commands/             # Slash commands (ship, qa, checkup)
│   ├── scripts/              # setup-haunt.sh
│   ├── hooks/                # Damage control hooks
│   └── docs/                 # Framework documentation
├── Skills/                    # Domain-specific skills (optional)
│   ├── */SKILL.md
│   └── */references/
└── CLAUDE.md                  # This file
```

## What's Included

### Rules (always loaded, enforce behavior)

| Rule | Purpose |
|------|---------|
| `gco-communication.md` | Direct communication style, no glazing |
| `gco-completion-checklist.md` | Tests pass + demo-ready before marking complete |
| `gco-decisions.md` | YAGNI, 4-question decision filter |
| `gco-ui-testing-reminder.md` | E2E test enforcement for frontend work |
| `gco-visual-verification.md` | Screenshot verification for CSS changes |

### Skills (on-demand, invoked when needed)

**Code quality:** `gco-code-review`, `gco-commit-conventions`, `gco-code-patterns`
**Testing:** `gco-tdd-workflow`, `gco-playwright-tests`, `gco-ui-testing`, `gco-testing-mindset`
**Standards:** `gco-secure-coding`, `gco-python-standards`, `gco-react-standards`, `gco-ui-design`
**Methodology:** `gco-task-decomposition`, `gco-requirements-development`, `gco-context7-usage`

### Commands

| Command | Purpose |
|---------|---------|
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
