# Haunt Plugin Distribution Design

**Date:** 2026-04-06
**Status:** Draft
**Author:** heckatron + Claude

## Problem

Haunt is distributed via `setup-haunt.sh`, which copies files from `Haunt/` into `~/.claude/`. This requires manual re-runs to update, doesn't scale to team distribution, and creates drift between source and deployed files.

## Solution

Restructure the `ghost-county/haunt` repo to be a native Claude Code plugin, distributed via the custom marketplace system. Users install once with `/plugin install`, and updates flow automatically when the repo is updated.

## Target Audience

- **Now (B):** Team/collaborators install via custom marketplace
- **Later (C):** Public discovery via `claude-plugins-official` submission

## Repo Restructure

### Current → New

```
# CURRENT                          # NEW
haunt/                              haunt/
├── Haunt/                          ├── .claude-plugin/
│   ├── agents/                     │   └── plugin.json
│   ├── rules/                      ├── agents/
│   ├── skills/                     ├── skills/
│   ├── commands/                   ├── commands/
│   ├── hooks/                      ├── hooks/
│   ├── templates/                  │   └── hooks.json
│   ├── scripts/                    ├── rules/
│   └── docs/                       ├── templates/
├── CLAUDE.md                       ├── scripts/
                                    ├── docs/
                                    ├── CLAUDE.md
                                    └── README.md
```

### What Moves

| Source | Destination | Notes |
|--------|-------------|-------|
| `Haunt/agents/*.md` | `agents/*.md` | No changes needed |
| `Haunt/rules/*.md` | `rules/*.md` | No changes needed |
| `Haunt/skills/gco-*` | `skills/gco-*` | Already use `SKILL.md` format |
| `Haunt/commands/*.md` | `commands/*.md` | No changes needed |
| `Haunt/hooks/*` | `hooks/*` | Add `hooks.json` manifest |
| `Haunt/templates/*` | `templates/*` | No changes needed |
| `Haunt/scripts/*` | `scripts/*` | No changes needed |
| `Haunt/docs/*` | `docs/*` | No changes needed |

### What Gets Removed

| Item | Action |
|------|--------|
| `Haunt/skills/upland-data-engineering` | Move to Familiar repo |
| `Haunt/agents/archive/` | Move to `docs/archive/` for reference |
| `Haunt/` directory | Deleted after contents moved to root |

## Plugin Metadata

### `.claude-plugin/plugin.json`

```json
{
  "name": "haunt",
  "description": "Dev guardrails and agent coordination toolkit. Quality gates, coding standards, testing enforcement, and the seance spec-driven development workflow.",
  "author": {
    "name": "heckatron"
  }
}
```

### `marketplace.json` (repo root)

```json
{
  "plugins": {
    "haunt": {
      "path": "."
    }
  }
}
```

## Installation

```bash
# One-time: add marketplace
/plugin marketplace add ghost-county/haunt

# Install
/plugin install haunt@ghost-county-haunt
```

Updates pull automatically when Claude Code refreshes marketplaces.

## Hooks Configuration

### `hooks/hooks.json`

Hooks are organized into three tiers based on when they enforce.

#### Always Enabled

Non-blocking or universally useful. Run on every session.

| Hook | Trigger | Purpose |
|------|---------|---------|
| `observability-logger.sh` | PostToolUse | Structured JSONL logging |
| `format-code.sh` | PostToolUse (Edit/Write) | Auto-format by file type |
| `session-start/initialize-session.sh` | SessionStart | `.haunt/` directory setup |
| `notify-completion.sh` | Stop/SubagentStop | Completion alerts |

#### Seance-Gated

Enabled in `hooks.json` but self-gate on `.haunt/active-session` sentinel file. Outside of a seance, they exit 0 immediately (no-ops).

| Hook | Trigger | Purpose |
|------|---------|---------|
| `damage-control/` | PreToolUse (Bash/Edit/Write) | Block destructive operations |
| `completion-gate.sh` | PreToolUse (Edit) | Block completion without test evidence |
| `phase-enforcement.sh` | PreToolUse (Task) | Block dev before planning approval |
| `file-location-enforcer.sh` | PreToolUse (Write/Edit) | Enforce `.haunt/` artifact paths |

**Gate mechanism:** Each seance-gated hook checks for the sentinel at the top:

```bash
[[ -f .haunt/active-session ]] || exit 0
```

The `/seance` command creates `.haunt/active-session` at Scrying start and removes it at Banishing end.

#### Shipped but Disabled

Present in the repo but NOT wired in `hooks.json`. Users opt-in via `settings.json` or the `update-config` skill.

| Hook | Purpose | Why Disabled |
|------|---------|--------------|
| `commit-validator.sh` | Enforce commit prefix conventions | Too opinionated (`[REQ-XXX]` pattern) |

## Migration Script

`setup-haunt.sh` is repurposed as `scripts/migrate-to-plugin.sh`:

1. Detects old copy-based deployment (`~/.claude/agents/gco-*.md`, `~/.claude/skills/gco-*`, etc.)
2. Removes old copied files
3. Adds the `ghost-county/haunt` custom marketplace
4. Installs the plugin
5. Reports what was cleaned up

Run once, then discard.

## CLAUDE.md Updates

CLAUDE.md must be updated to reflect:
- New repo structure (no `Haunt/` prefix in paths)
- Plugin-based installation instead of `setup-haunt.sh`
- Hook tiers (always, seance-gated, disabled)

## Path to Public (Phase C)

When ready for public distribution:
1. Submit to `claude-plugins-official` via their [plugin directory submission form](https://clau.de/plugin-directory-submission)
2. No structural changes needed — the repo already matches the required format
3. Users switch from custom marketplace to official: `/plugin install haunt@claude-plugins-official`

## Out of Scope

- Custom hook configuration UI (use `update-config` skill or manual `settings.json`)
- Plugin versioning/changelog automation (use git tags)
- Haunt CLI wrapper around `/plugin` commands
