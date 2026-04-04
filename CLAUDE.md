# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

**Haunt** is a dev guardrails and agent coordination toolkit for Claude Code. It provides quality gates, coding standards, testing enforcement, and a spec-driven development workflow (the seance) powered by Claude Code Agent Teams. Designed around JD Forsythe's [10 Claude Code Principles](https://jdforsythe.github.io/10-principles/overview/).

Contents:
- **Haunt/agents/** - Team-aware agent definitions (deployed to `~/.claude/agents/`)
- **Haunt/rules/** - Always-loaded behavioral rules with BECAUSE clauses (deployed to `~/.claude/rules/`)
- **Haunt/skills/** - On-demand methodology skills with attention-optimized layout (deployed to `~/.claude/skills/`)
- **Haunt/commands/** - Slash commands (deployed to `~/.claude/commands/`)
- **Haunt/hooks/** - Deterministic enforcement hooks (damage control, observability, completion gates)
- **Haunt/templates/** - Reusable templates (gate outputs, institutional memory)
- **Haunt/docs/** - Architecture standards, evaluation docs, task profiles

## Setup

```bash
bash Haunt/scripts/setup-haunt.sh          # Deploy agents + rules + skills + commands + hooks
bash Haunt/scripts/setup-haunt.sh --verify  # Verify deployment
bash Haunt/scripts/haunt-doc-freshness.sh   # Check skill freshness (flags >90 days stale)
```

## Repository Structure

```
haunt/
├── Haunt/                     # Dev guardrails + agent coordination framework
│   ├── agents/               # Team-aware agents (6 gco agents)
│   ├── agents/archive/       # Archived original agent definitions (reference)
│   ├── rules/                # Always-loaded rules (6 gco rules, all with BECAUSE clauses)
│   ├── skills/               # On-demand skills (~17 gco skills, attention-optimized layout)
│   ├── commands/             # Slash commands (seance, ship, qa, checkup)
│   ├── hooks/                # Enforcement hooks (damage control, observability, gates)
│   ├── scripts/              # setup-haunt.sh, review-metrics.sh, haunt-doc-freshness.sh
│   ├── templates/            # Gate output, institutional memory templates
│   └── docs/                 # Architecture standards, evaluations, task profiles
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

The code reviewer uses a **cascade pattern**: XS/S work gets a single-pass review, M+ work delegates to specialist reviewers with domain-specific vocabulary routing.

### Rules (always loaded, enforce behavior)

All rules include BECAUSE clauses explaining *why* each directive exists, enabling agents to generalize reasoning to novel situations.

| Rule | Purpose |
|------|---------|
| `gco-communication.md` | Direct communication style, no glazing |
| `gco-completion-checklist.md` | Tests pass + demo-ready before marking complete |
| `gco-decisions.md` | YAGNI, 4-question decision filter |
| `gco-team-coordination.md` | Task claiming, completion reporting, team behavior |
| `gco-ui-testing-reminder.md` | E2E test enforcement for frontend work |
| `gco-visual-verification.md` | Screenshot verification for CSS changes |

### Skills (on-demand, attention-optimized layout)

Skills follow the [Skill Architecture Standard](Haunt/docs/SKILL-ARCHITECTURE.md): vocabulary payload FIRST, anti-patterns SECOND, instructions in MIDDLE, retrieval anchors LAST. Each has `last-verified` freshness dates.

**Code quality:** `gco-code-review`, `gco-commit-conventions`, `gco-code-patterns`
**Testing:** `gco-tdd-workflow`, `gco-playwright-tests`, `gco-ui-testing`, `gco-testing-mindset`
**Standards:** `gco-secure-coding`, `gco-python-standards`, `gco-react-standards`, `gco-ui-design`
**Methodology:** `gco-task-decomposition`, `gco-requirements-development`, `gco-context7-usage`
**Orchestration:** `gco-seance-orchestration`, `gco-team-protocol`

### Commands

| Command | Purpose |
|---------|---------|
| `/seance` | Complete dev ritual: planning -> execution -> archival |
| `/seance --solo` | Solo mode for XS/S tasks (skip team, lead does everything) |
| `/ship` | Create PR and enable auto-merge |
| `/qa` | Generate test scenarios (checklist, gherkin, playwright, charter) |
| `/checkup` | Verify deployment health |

### Hooks (deterministic enforcement)

| Hook | Trigger | Purpose |
|------|---------|---------|
| `observability-logger.sh` | PostToolUse (all) | Structured JSONL logging to `.haunt/logs/` |
| `completion-gate.sh` | PreToolUse (Edit) | Blocks marking work complete without test evidence |
| `commit-validator.sh` | PreToolUse (Bash) | Enforces `[REQ-XXX]` commit prefix |
| `phase-enforcement.sh` | PreToolUse (Task) | Blocks dev agents before planning approval |
| `file-location-enforcer.sh` | PreToolUse (Write/Edit) | Enforces `.haunt/` artifact locations |
| `format-code.sh` | PostToolUse (Edit/Write) | Auto-formats by file type |
| `damage-control` | PreToolUse (Bash/Edit/Write) | Blocks destructive operations via `patterns.yaml` |

### Templates

| Template | Purpose |
|----------|---------|
| `institutional-memory.md` | Always/Never X BECAUSE Y format for project-specific lessons |
| `human-gate-output.md` | Structured format for human review gates (summary, risks, confidence) |

## Seance Workflow

The seance is a 3-phase development ritual with built-in quality gates:

1. **Scrying** (Planning) — PM creates requirements + roadmap → user approval gate
2. **Summoning** (Execution) — Dev + Code Reviewer work through roadmap → pre-merge human gate for M+ work
3. **Banishing** (Archival) — Verify, archive, codify lessons learned

**Task Size Cascade** (P9 Token Economy): XS/S tasks use solo mode (no team). M tasks get Dev + Code Reviewer. L tasks get the full team. This prevents wasting tokens on coordination overhead for simple tasks.

**Session Boundaries** (P2 Context Hygiene): `/clear` recommended between phases. Roadmap, tasks, and state files persist on disk.

## Skills Format

Skills use attention-optimized YAML frontmatter with dual-register descriptions:

```yaml
---
name: skill-name
description: >-
  [Expert vocabulary sentence for embedding routing].
  [Natural language sentence for human disambiguation].
last-verified: YYYY-MM-DD
---
```

See [SKILL-ARCHITECTURE.md](Haunt/docs/SKILL-ARCHITECTURE.md) for the full standard.

## Observability

- **Tool usage logs:** `.haunt/logs/tool-usage.jsonl` (written by observability hook)
- **Review verdicts:** `.haunt/logs/review-verdicts.jsonl` (written by code reviewer)
- **Cost logs:** `.haunt/logs/cost-log.jsonl` (written by haunt-cost-logger.sh)
- **Metrics:** `bash Haunt/scripts/review-metrics.sh` (approval rates, rubber-stamp detection)
- **Freshness:** `bash Haunt/scripts/haunt-doc-freshness.sh` (stale skill detection)
- **Cost report:** `bash Haunt/scripts/haunt-cost-report.sh` (per-session costs, outlier detection)

## Key Documentation

| Doc | Purpose |
|-----|---------|
| [SKILL-ARCHITECTURE.md](Haunt/docs/SKILL-ARCHITECTURE.md) | Attention-optimized skill layout standard |
| [TASK-PROFILES.md](Haunt/docs/TASK-PROFILES.md) | Minimal context configs per session type |
| [10-principles-evaluation.md](Haunt/docs/haunt-10-principles-evaluation.md) | Gap analysis against 10 Claude Code Principles |
| [10-principles-refactor.md](Haunt/docs/10-principles-refactor.md) | Implementation plan for closing gaps |

## Infrastructure Dependencies

- **MCP Servers** - Context7 (library docs)
- **Playwright** - E2E browser automation tests
