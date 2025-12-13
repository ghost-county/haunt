---
description: CRITICAL - All Haunt framework changes must update deployable source, not just local environment
globs:
  - "**/*.md"
  - "**/*.sh"
---

# Haunt Framework Change Protocol

## The Rule

**When modifying ANY Haunt framework asset, ALWAYS update the SOURCE in `Haunt/` FIRST, then deploy to local environment.**

## What This Means

### WRONG (What keeps happening)
1. User asks for new agent/skill/rule/command
2. Agent creates file in `~/.claude/` or `.claude/`
3. Change works locally but is NOT deployable
4. Next `setup-haunt.sh` run overwrites the change

### CORRECT (What must happen)
1. User asks for new agent/skill/rule/command
2. Agent creates/modifies file in `Haunt/` source directory
3. Agent runs `setup-haunt.sh` OR manually copies to local environment
4. Change is deployable AND works locally

## Source Directories (Edit These)

| Asset Type | Source Location | Naming Convention |
|------------|-----------------|-------------------|
| Agents | `Haunt/agents/` | `gco-*.md` |
| Skills | `Haunt/skills/gco-*/` | `SKILL.md` inside |
| Rules | `Haunt/rules/` | `gco-*.md` |
| Commands | `Haunt/commands/` | `gco-*.md` |
| Scripts | `Haunt/scripts/` | `*.sh` |

## Deployment Targets (These Get Overwritten)

| Asset Type | Global Deploy | Project Deploy |
|------------|---------------|----------------|
| Agents | `~/.claude/agents/` | `.claude/agents/` |
| Skills | `~/.claude/skills/` | `.claude/skills/` |
| Rules | `~/.claude/rules/` | `.claude/rules/` |
| Commands | `~/.claude/commands/` | `.claude/commands/` |

## Checklist for Framework Changes

- [ ] Did I edit the file in `Haunt/` (not `~/.claude/` or `.claude/`)?
- [ ] Does the filename have `gco-` prefix?
- [ ] Is it referenced correctly in `setup-haunt.sh` if it's a new asset type?
- [ ] Did I update any cross-references (agent skills lists, etc.)?

## If You Made Changes to Wrong Location

If you accidentally edited `~/.claude/` or `.claude/` instead of `Haunt/`:
1. Copy the file to the correct `Haunt/` location
2. Verify the source is correct
3. Re-run `setup-haunt.sh` to sync

## Remember

The `Haunt/` directory IS the framework. Everything else is just a deployed copy.
