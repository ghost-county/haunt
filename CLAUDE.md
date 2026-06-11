# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

**Haunt** is a dev guardrails and agent coordination toolkit for Claude Code. It provides quality gates, coding standards, testing enforcement, and a spec-driven development workflow (the seance) powered by Claude Code Agent Teams. Designed around JD Forsythe's [10 Claude Code Principles](https://jdforsythe.github.io/10-principles/overview/).

Contents:
- **agents/** - Team-aware agent definitions (deployed to `~/.claude/agents/`)
- **rules/** - Always-loaded behavioral rules with BECAUSE clauses (deployed to `~/.claude/rules/`)
- **skills/** - On-demand methodology skills with attention-optimized layout (deployed to `~/.claude/skills/`)
- **commands/** - Slash commands (deployed to `~/.claude/commands/`)
- **hooks/** - Deterministic enforcement hooks (damage control, observability, completion gates)
- **templates/** - Reusable templates (gate outputs, institutional memory)
- **docs/** - Architecture standards, evaluation docs, task profiles

## Setup

Install as a Claude Code plugin:

```bash
# Add marketplace (one-time)
/plugin marketplace add ghost-county/haunt

# Install plugin
/plugin install haunt@ghost-county-haunt
```

Updates pull automatically. For existing `setup-haunt.sh` users, run the migration first:

```bash
bash scripts/migrate-to-plugin.sh          # Preview cleanup
bash scripts/migrate-to-plugin.sh --execute # Execute cleanup
```

## Repository Structure

```
haunt/
├── .claude-plugin/           # Plugin metadata
│   ├── plugin.json
│   └── marketplace.json
├── agents/                   # Team-aware agents (6 gco agents)
├── rules/                    # Always-loaded rules (8 gco rules)
├── skills/                   # On-demand skills (19 gco skills)
├── commands/                 # Slash commands (seance, haunt, ship, qa, checkup)
├── hooks/                    # Enforcement hooks + hooks.json manifest
├── templates/                # Gate output, institutional memory, settings templates
├── scripts/                  # Migration, metrics, freshness, cost tools
├── docs/                     # Architecture standards, white paper, guides
├── CLAUDE.md                 # Project instructions
└── README.md                 # Public-facing docs
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
| `gco-assumption-surfacing.md` | State assumptions explicitly; don't pick silently when uncertain |
| `gco-communication.md` | Direct communication style, no glazing |
| `gco-completion-checklist.md` | Tests pass + demo-ready before marking complete |
| `gco-decisions.md` | YAGNI, 4-question decision filter |
| `gco-surgical-changes.md` | Touch only what the task requires; match existing style |
| `gco-team-coordination.md` | Task claiming, completion reporting, team behavior |
| `gco-ui-testing-reminder.md` | E2E test enforcement for frontend work |
| `gco-visual-verification.md` | Screenshot verification for CSS changes |

### Skills (on-demand, attention-optimized layout)

Skills follow the [Skill Architecture Standard](docs/SKILL-ARCHITECTURE.md): vocabulary payload FIRST, anti-patterns SECOND, instructions in MIDDLE, retrieval anchors LAST. Each has `last-verified` freshness dates.

**Code quality:** `gco-code-review`, `gco-commit-conventions`, `gco-code-patterns`
**Testing:** `gco-tdd-workflow`, `gco-playwright-tests`, `gco-ui-testing`, `gco-testing-mindset`
**Standards:** `gco-secure-coding`, `gco-python-standards`, `gco-react-standards`, `gco-ui-design`
**Methodology:** `gco-task-decomposition`, `gco-requirements-development`, `gco-context7-usage`
**Auditing:** `gco-project-audit`
**Orchestration:** `gco-using-haunt` (session-start dispatcher), `gco-seance-orchestration`, `gco-haunt-orchestration` (standards layer), `gco-team-protocol`

### Commands

| Command | Purpose |
|---------|---------|
| `/seance` | Complete dev ritual: planning -> execution -> archival (also auto-triggered by the `gco-using-haunt` dispatcher for M/L build requests) |
| `/seance --solo` | Solo mode for XS/S tasks (skip team, lead does everything) |
| `/haunt` | Project init + project-local standards (init, discover, inject, status) |
| `/ship` | Create PR and enable auto-merge |
| `/qa` | Generate test scenarios (checklist, gherkin, playwright, charter) |
| `/checkup` | Verify deployment health |

### Hooks (deterministic enforcement)

**Hooks are seance-gated** — they only fire when the `.haunt/active-session` sentinel exists. The sentinel is created at seance start (Scrying step 1, solo mode, or `--summon` recovery) and removed at Banishing. **Exception:** `session-start/` always runs — it injects the `gco-using-haunt` dispatcher skill into every session so build requests route into the seance automatically (passive harness), and additionally surfaces handoff/staleness warnings when a seance is active.

| Hook | Trigger | Purpose |
|------|---------|---------|
| `session-start/` | SessionStart | Inject dispatcher (always); `.haunt/` setup + session-state warnings (seance only) |
| `observability-logger.sh` | PostToolUse | Structured JSONL logging |
| `format-code.sh` | PostToolUse (Edit/Write) | Auto-format by file type |
| `notify-completion.sh` | Stop/SubagentStop | Completion alerts |
| `damage-control/` | PreToolUse (Bash/Edit/Write) | Block destructive operations |
| `completion-gate.sh` | PreToolUse (Edit) | Block completion without test evidence |
| `phase-enforcement.sh` | PreToolUse (Agent) | Block dev agents before planning approval |
| `file-location-enforcer.sh` | PreToolUse (Edit/Write) | Enforce `.haunt/` artifact paths |

**Shipped but Disabled:**

| Hook | Purpose |
|------|---------|
| `commit-validator.sh` | Enforce commit prefix conventions (opt-in via settings.json) |

### Templates

| Template | Purpose |
|----------|---------|
| `institutional-memory.md` | Always/Never X BECAUSE Y format for project-specific lessons |
| `human-gate-output.md` | Structured format for human review gates (summary, risks, confidence) |
| `exploratory-charter.md` | Template for exploratory testing charters |
| `settings.hooks.json` | Reference hooks configuration for `settings.json` |
| `settings.damage-control.json` | Reference damage-control hook configuration |

## Seance Workflow

The seance is a 3-phase development ritual with built-in quality gates:

1. **Scrying** (Planning) — PM creates requirements + roadmap → user approval gate
2. **Summoning** (Execution) — Dev + Code Reviewer work through roadmap → pre-merge human gate for M+ work
3. **Banishing** (Archival) — Verify, archive, codify lessons learned

**Passive entry:** The session-start hook injects the `gco-using-haunt` dispatcher into every session. When the user asks to build, add, or change functionality, the dispatcher triages size and auto-invokes the seance for M/L work — `/seance` is the explicit entry point, not the only one.

**Sentinel lifecycle:** Scrying step 1 (and solo mode / `--summon` recovery) creates `.haunt/active-session`, which activates all enforcement hooks. Banishing removes it. Outside the sentinel, hooks are no-ops.

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

See [SKILL-ARCHITECTURE.md](docs/SKILL-ARCHITECTURE.md) for the full standard.

## Observability

- **Tool usage logs:** `.haunt/logs/tool-usage.jsonl` (written by observability hook)
- **Review verdicts:** `.haunt/logs/review-verdicts.jsonl` (written by code reviewer)
- **Cost logs:** `.haunt/logs/cost-log.jsonl` (written by haunt-cost-logger.sh)
- **Metrics:** `bash scripts/review-metrics.sh` (approval rates, rubber-stamp detection)
- **Freshness:** `bash scripts/haunt-doc-freshness.sh` (stale skill detection)
- **Skill versions:** `bash scripts/haunt-skill-versions.sh` (deployed vs source version check)
- **Manifest:** `bash scripts/utils/generate-manifest.sh` (regenerate manifest.yaml active sections after adding/removing agents, rules, skills, or commands; deprecated section is manually maintained)
- **Cost logging:** `bash scripts/haunt-cost-logger.sh` (per-session cost capture)
- **Cost report:** `bash scripts/haunt-cost-report.sh` (per-session costs, outlier detection)

## Key Documentation

| Doc | Purpose |
|-----|---------|
| [SKILL-ARCHITECTURE.md](docs/SKILL-ARCHITECTURE.md) | Attention-optimized skill layout standard |
| [TASK-PROFILES.md](docs/TASK-PROFILES.md) | Minimal context configs per session type |
| [CODE-REVIEW-WORKFLOW.md](docs/CODE-REVIEW-WORKFLOW.md) | Code review cascade and workflow |
| [SEANCE-EXPLAINED.md](docs/SEANCE-EXPLAINED.md) | Seance workflow deep dive |
| [WHITE-PAPER.md](docs/WHITE-PAPER.md) | Haunt architecture white paper |
| [SKILLS-REFERENCE.md](docs/SKILLS-REFERENCE.md) | Full skills catalog reference |
| [10-principles-evaluation.md](docs/haunt-10-principles-evaluation.md) | Gap analysis against 10 Claude Code Principles |
| [10-principles-refactor.md](docs/10-principles-refactor.md) | Implementation plan for closing gaps |

## Infrastructure Dependencies

- **MCP Servers** - Context7 (library docs)
- **Playwright** - E2E browser automation tests
