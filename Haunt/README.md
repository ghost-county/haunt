# Haunt v2.0 - Lightweight Agent Architecture

> Lightweight agent definitions (30-50 lines) + reusable Skills library

---

## What's Different from Agentic_SDLC_Framework/

**Old (v1.0)**: Monolithic agent files with duplicated content across agents (~200+ lines each)
**New (v2.0)**: Lightweight agent character sheets that reference shared Skills (~30-50 lines each)

### Key Changes
- **Agent files**: Character sheets only (identity, values, responsibilities, skills referenced)
- **Skills library**: Reusable SKILL.md files in `Haunt/skills/` directory with YAML frontmatter
- **Reduced duplication**: Common workflows (session-startup, commit-conventions, tdd-workflow) now shared
- **Easier maintenance**: Update a skill once, all agents benefit immediately
- **Faster onboarding**: Agents load 85% smaller files, reference skills on-demand

---

## New in v2.0

### Agent Definitions (30-50 lines each)
- **gco-dev.md** - Polyglot developer (backend, frontend, infrastructure modes)
- **gco-project-manager.md** - Coordinator for roadmap, dispatch, archiving
- **gco-research.md** - Investigator for technical research and validation
- **gco-code-reviewer.md** - Quality enforcer for merge requests
- **gco-release-manager.md** - Release coordinator for deployment orchestration

### Skills Library (15+ reusable Haunt skills)
Skills use YAML frontmatter with `name` and `description`, followed by markdown content.

**Haunt Methodology Skills** (in `Haunt/skills/`):
- `session-startup` - Session initialization checklist (pwd, git status, tests, assignments)
- `commit-conventions` - Commit message format and branch naming standards
- `feature-contracts` - Understanding immutable acceptance criteria
- `tdd-workflow` - Red-Green-Refactor cycle and testing guidance
- `roadmap-workflow` - Roadmap format, batch organization, archiving procedures
- `requirements-rubric` - Framework for writing atomic, actionable requirements
- `code-review` - Structured code review checklist with anti-pattern detection
- `code-patterns` - Anti-pattern detection and error handling conventions

**Domain-Specific Skills** (in `Skills/`):
- Various specialized skills like xlsx-editor, pitch-deck-builder, etc. (not part of Haunt framework)

Browse Haunt skills: `Haunt/skills/*/SKILL.md`

### Rules Library (Invariant Enforcement)
Rules are markdown files in `.claude/rules/` that auto-load and enforce protocols:

- `session-startup.md` - 5-step startup checklist (environment, tests, git, changes, assignment)
- `file-conventions.md` - Haunt artifact locations (plans, completed, tests, docs)
- `commit-conventions.md` - Commit format: `[REQ-XXX] Action: Description`
- `status-updates.md` - Worker vs PM responsibilities for roadmap updates
- `assignment-lookup.md` - 4-step assignment sequence (Direct → Active Work → Roadmap → Ask PM)
- `completion-checklist.md` - 5-point verification before marking work done
- `roadmap-format.md` - Path-targeted rule for roadmap file structure

Rules vs Skills vs Agents (GCO framework layers):
| Layer | Purpose | Loading | Size |
|-------|---------|---------|------|
| **Rules** | "You MUST always do this" | Auto-load | 50-100 lines |
| **Agents** | "This is WHO you are" | On spawn | 30-50 lines |
| **Skills** | "Here's HOW to do this" | On-demand | 100-500 lines |
| **CLAUDE.md** | "This is WHAT and WHY" | Always | <500 tokens |

Browse rules: `Haunt/rules/*.md`

### Benefits
- Faster agent initialization (smaller files to load)
- Single source of truth for workflows (update once, all agents benefit)
- Easier experimentation (swap skills without rewriting agents)
- Better version control (track skill changes independently)

---

## Agent Definitions

| Agent | Purpose |
|-------|---------|
| gco-dev.md | Polyglot developer (backend/frontend/infrastructure modes) |
| gco-project-manager.md | Roadmap coordinator, dispatch, archiving |
| gco-research.md | Technical research and validation |
| gco-code-reviewer.md | Code quality enforcement for PRs |
| gco-release-manager.md | Deployment orchestration and release management |

---

## How to Use

### Option 1: Copy agents to .claude/agents/ (Recommended)
```bash
# Global agents (available in all projects)
cp Haunt/agents/*.md ~/.claude/agents/

# Project-specific agents (override global)
cp Haunt/agents/*.md ./.claude/agents/
```

### Option 2: Reference agents directly
Point Claude Code to `Haunt/agents/` when starting a session.

### Skills Usage
Agents reference skills by name (e.g., "session-startup"). Haunt methodology skills are located in `Haunt/skills/` directory. Claude Code automatically finds and uses skills when agents invoke them.

---

## FAQ

### Why v2.0 instead of patching v1.0?
Architectural change (monolithic to lightweight) required clean break. Old framework remains available for rollback.

### Are all skills referenced by agents?
No. Agents reference core Haunt methodology skills from `Haunt/skills/` (session-startup, commit-conventions, tdd-workflow, etc). Other domain-specific skills in `/Skills/` (xlsx-editor, pitch-deck-builder) are invoked only when needed and are not part of the Haunt framework.

### Can I use both v1.0 and v2.0 agents?
Not recommended. Choose one architecture per project to avoid conflicting instructions.

### How do I add a new skill?
Create `Haunt/skills/new-skill-name/SKILL.md` with YAML frontmatter (`name`, `description`) + markdown content. Reference it in agent's "Skills Used" section.

### Do agents still use NATS, MCP servers, and memory?
Yes. Infrastructure requirements unchanged. Only agent file structure refactored.

### How does this integrate with the Anthropic Agent SDK?
The framework uses a **selective integration** approach. SDK infrastructure (context compaction, prompt caching, tool permissions) is used automatically via Claude Code CLI. Custom methodology (roadmap workflow, pattern detection, skills) remains framework-specific. See `docs/SDK-INTEGRATION.md` for details.

### What if a skill is missing?
Agent will continue without error. Add missing skill to `Haunt/skills/` directory and reference it in agent file.

### How do I customize an agent for my project?
Copy agent to `./.claude/agents/` (project-specific) and modify. Project agents override global agents.

### What's the migration path from v1.0 to v2.0?
1. Backup old agents (`~/.claude/agents/*.md` → `~/.claude/agents.backup/`)
2. Copy new agents (`Haunt/agents/*.md` → `~/.claude/agents/`)
3. Test with one project before rolling out globally
4. Keep old framework for 30 days in case rollback needed

### Can I mix old and new agents?
Not recommended. Monolithic agents (v1.0) contain duplicated content that conflicts with skill references (v2.0).

### How do I know which version I'm using?
Check agent file size: v1.0 agents are 150-300 lines, v2.0 agents are 30-50 lines.

---

## Rollback Procedure

If v2.0 doesn't work for your use case, rollback to v1.0:

```bash
# 1. Remove v2.0 agents
rm ~/.claude/agents/gco-dev.md
rm ~/.claude/agents/gco-project-manager.md
rm ~/.claude/agents/gco-research.md
rm ~/.claude/agents/gco-code-reviewer.md
rm ~/.claude/agents/gco-release-manager.md

# 2. Use old framework
# Follow instructions in Agentic_SDLC_Framework/00-Overview.md
bash Agentic_SDLC_Framework/scripts/setup-all.sh --agents

# 3. Delete Haunt/ directory (optional)
# Only if you want to fully revert
rm -rf Haunt/
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| `README.md` | This file - architecture overview |
| `SETUP-GUIDE.md` | Complete setup instructions |
| `QUICK-REFERENCE.md` | Quick reference card |
| `docs/SDK-INTEGRATION.md` | How SDK features integrate with framework |
| `docs/TOOL-PERMISSIONS.md` | Agent tool access reference |
| `docs/SKILLS-REFERENCE.md` | Complete catalog of all available skills |
| `docs/WHITE-PAPER.md` | Framework design philosophy |
| `docs/PATTERN-DETECTION.md` | Pattern detection methodology |
| `docs/HAUNT-DIRECTORY-SPEC.md` | Directory structure specification |
| `.claude/rules/` | Invariant enforcement protocols (auto-enforced) |

## Next Steps

1. Review agent definitions in `Haunt/agents/`
2. Browse skills library in `Haunt/skills/*/SKILL.md`
3. Read `docs/SDK-INTEGRATION.md` to understand how SDK features work
4. Copy agents to `~/.claude/agents/` or `./.claude/agents/`
5. Start a session and verify agents reference skills correctly
6. Provide feedback on v2.0 architecture
