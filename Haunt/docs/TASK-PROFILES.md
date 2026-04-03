# Task-Type Profiles

Minimal context configurations for different work modes. Load only what the current task demands.

BECAUSE loading all 17 skills + all MCP servers for a documentation fix wastes tokens on attention competition. Every irrelevant token actively degrades performance on relevant tokens (quadratic self-attention scaling).

## Planning Session

| Dimension | Configuration |
|-----------|--------------|
| Agent | gco-project-manager (solo) or lead in solo mode |
| Skills | gco-requirements-development, gco-task-decomposition |
| Tools | Read, Glob, Grep, Write, Edit |
| MCP servers | None |
| Token budget | ~20K |

**When:** `/seance --scry`, requirements analysis, roadmap creation

## Implementation Session

| Dimension | Configuration |
|-----------|--------------|
| Agent | gco-dev |
| Skills | gco-tdd-workflow, gco-commit-conventions, gco-code-patterns + language-specific |
| Tools | Glob, Grep, Read, Edit, Write, Bash |
| MCP servers | context7 (if using external libs) |
| Token budget | ~50K |

**Language-specific skills:**
- Python: + gco-python-standards
- React/TS: + gco-react-standards, gco-ui-design, gco-playwright-tests
- SQL: + upland-data-engineering (if UCG project)

**When:** `/seance --summon`, feature implementation, bug fixes

## Review Session

| Dimension | Configuration |
|-----------|--------------|
| Agent | gco-code-reviewer (routes to specialists for M+) |
| Skills | gco-code-review, gco-code-patterns, gco-secure-coding |
| Tools | Glob, Grep, Read, Bash (read-only) |
| MCP servers | None |
| Token budget | ~30K |

**When:** Code review tasks, PR review, pre-merge quality gates

## Research Session

| Dimension | Configuration |
|-----------|--------------|
| Agent | gco-research |
| Skills | gco-context7-usage |
| Tools | Read, Glob, Grep, WebSearch, WebFetch |
| MCP servers | context7 |
| Token budget | ~40K |

**When:** `/seance --deep`, investigation tasks, technology evaluation

## Solo Session (XS/S tasks)

| Dimension | Configuration |
|-----------|--------------|
| Agent | Lead only (no team) |
| Skills | Task-appropriate subset (1-3 skills max) |
| Tools | Minimal for task |
| MCP servers | Only if needed |
| Token budget | ~15K |

**When:** `/seance --solo`, config changes, typo fixes, single-file edits

## How to Apply

These profiles are aspirational guidance. Claude Code doesn't yet support per-agent skill filtering at runtime. Use these profiles to:

1. **Manually configure lighter sessions** — disable unused MCP servers before starting
2. **Guide team assembly** — spawn agents with only the skills listed for their session type
3. **Estimate costs** — token budgets help predict seance expense before starting
4. **Plan future tooling** — when jig-style profiles become available, these define the configurations
