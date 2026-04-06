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

## Terminology

- **Haunt** (capitalized) — the project/framework name
- **haunt** (lowercase) — the plugin name in plugin.json and marketplace references
- **ghost-county-haunt** — the marketplace identifier (derived from GitHub org/repo)

## Repo Restructure

### Current → New

```
# CURRENT                          # NEW
haunt/                              haunt/
├── Haunt/                          ├── .claude-plugin/
│   ├── agents/                     │   ├── plugin.json
│   ├── rules/                      │   └── marketplace.json
│   ├── skills/                     ├── agents/
│   ├── commands/                   ├── skills/
│   ├── hooks/                      ├── commands/
│   ├── templates/                  ├── hooks/
│   ├── scripts/                    │   └── hooks.json
│   └── docs/                       ├── rules/
├── CLAUDE.md                       ├── templates/
                                    ├── scripts/
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
| `Haunt/docs/*` | `docs/*` | Merge with existing `docs/` |

### What Gets Removed

| Item | Action |
|------|--------|
| `Haunt/skills/upland-data-engineering` | Move to Familiar repo (`~/.claude/skills/`) |
| `Haunt/agents/archive/` | Move to `docs/archive/` for reference |
| `Haunt/` directory | Deleted after contents moved to root |

## Plugin Metadata

### `.claude-plugin/plugin.json`

Based on the superpowers plugin format (the most complete reference):

```json
{
  "name": "haunt",
  "description": "Dev guardrails and agent coordination toolkit. Quality gates, coding standards, testing enforcement, and the seance spec-driven development workflow.",
  "version": "1.0.0",
  "author": {
    "name": "heckatron"
  },
  "homepage": "https://github.com/ghost-county/haunt",
  "repository": "https://github.com/ghost-county/haunt",
  "license": "MIT",
  "keywords": [
    "guardrails",
    "agent-coordination",
    "quality-gates",
    "testing",
    "seance",
    "code-review"
  ]
}
```

**Version strategy:** Semantic versioning, updated manually in plugin.json. Git tags for releases (`v1.0.0`). No automated version bumping for now.

**License:** MIT (matches superpowers and most official plugins).

### `.claude-plugin/marketplace.json`

Based on the superpowers self-hosted marketplace format:

```json
{
  "name": "ghost-county-haunt",
  "description": "Dev guardrails and agent coordination toolkit for Claude Code",
  "owner": {
    "name": "heckatron"
  },
  "plugins": [
    {
      "name": "haunt",
      "description": "Dev guardrails and agent coordination toolkit. Quality gates, coding standards, testing enforcement, and the seance spec-driven development workflow.",
      "version": "1.0.0",
      "source": "./",
      "author": {
        "name": "heckatron"
      }
    }
  ]
}
```

**Location:** `.claude-plugin/marketplace.json` (same as superpowers, not repo root).

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

Concrete schema based on hookify and superpowers reference implementations.

**Matcher field:** The `matcher` field filters which tool triggers the hook (e.g., `"Bash"`, `"Edit|Write"`, `"Bash|Edit|Write"`). When omitted, the hook fires for all tools in that trigger category. Matchers use pipe-delimited tool names.

```json
{
  "description": "Haunt dev guardrails hooks",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/session-start/initialize-session.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/observability-logger.sh\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/format-code.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"${CLAUDE_PLUGIN_ROOT}/hooks/damage-control/bash-tool-damage-control.py\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"${CLAUDE_PLUGIN_ROOT}/hooks/damage-control/edit-tool-damage-control.py\"",
            "timeout": 5
          },
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/completion-gate.sh\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"${CLAUDE_PLUGIN_ROOT}/hooks/damage-control/write-tool-damage-control.py\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/file-location-enforcer.sh\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Agent",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/phase-enforcement.sh\"",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/notify-completion.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/notify-completion.sh\"",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### Hook Tiers

#### Always Enabled

Wired in `hooks.json`, run on every session. Users can override via `settings.json` if needed.

| Hook | Trigger | Purpose |
|------|---------|---------|
| `observability-logger.sh` | PostToolUse | Structured JSONL logging |
| `format-code.sh` | PostToolUse | Auto-format by file type |
| `session-start/initialize-session.sh` | SessionStart | `.haunt/` directory setup |
| `notify-completion.sh` | Stop/SubagentStop | Completion alerts |

#### Seance-Gated

Wired in `hooks.json` but self-gate on `.haunt/active-session` sentinel file. Outside of a seance, they exit 0 immediately (no-ops).

| Hook | Trigger | Purpose |
|------|---------|---------|
| `damage-control/` | PreToolUse | Block destructive operations |
| `completion-gate.sh` | PreToolUse | Block completion without test evidence |
| `phase-enforcement.sh` | PreToolUse (Agent) | Block dev agents before planning approval |
| `file-location-enforcer.sh` | PreToolUse | Enforce `.haunt/` artifact paths |

**Gate mechanism:** Each seance-gated hook checks for the sentinel at the top:

```bash
# Sentinel is always project-scoped (repo root), not global
SENTINEL="${PWD}/.haunt/active-session"
[[ -f "$SENTINEL" ]] || exit 0
```

**Sentinel lifecycle:**
- **Created by:** `/seance` command at Scrying phase start.
- **Removed by:** `/seance` command at Banishing phase end.
- **Scope:** Project-scoped at `${PWD}/.haunt/active-session`. Each project has its own sentinel — no cross-project interference.
- **Parallel sessions:** Each project root gets its own `.haunt/` directory. Two projects running seances simultaneously don't conflict.

**Sentinel file format** (plain text, one key=value per line):
```
session_id=abc123-def456
started_at=2026-04-06T10:30:00Z
task_size=medium
phase=scrying
```

Hooks only check for file existence (`[[ -f ... ]]`). The metadata is for debugging and observability — hooks don't parse it.

### `.haunt/` Directory Structure

The `.haunt/` directory is project-scoped (created at repo root by `session-start` hook):

```
.haunt/
├── active-session          # Sentinel file (exists only during seance)
├── logs/
│   ├── tool-usage.jsonl    # Written by observability-logger.sh
│   ├── review-verdicts.jsonl  # Written by code reviewer agent
│   └── cost-log.jsonl      # Written by haunt-cost-logger.sh
├── roadmap.md              # Seance planning artifact
└── state/                  # Seance phase state files
```

**Note:** `.haunt/` should be in `.gitignore` — it's runtime state, not source.

#### Shipped but Disabled

Present in `hooks/` directory but NOT wired in `hooks.json`. Users opt-in by adding to their project or user `settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash path/to/hooks/commit-validator.sh"
          }
        ]
      }
    ]
  }
}
```

| Hook | Purpose | Why Disabled |
|------|---------|--------------|
| `commit-validator.sh` | Enforce commit prefix conventions | Too opinionated (`[REQ-XXX]` pattern) |

## Migration Script

`setup-haunt.sh` is repurposed as `scripts/migrate-to-plugin.sh`.

### Detection

The script identifies Haunt-owned files by checking for a marker comment in each file. All files deployed by the old `setup-haunt.sh` contain:

```
# Deployed by setup-haunt.sh
```

If the marker is absent, the file is skipped (user-created or from another source).

### Migration Steps

1. **Scan** — Find files in `~/.claude/{agents,rules,skills,commands}/` with the `setup-haunt.sh` marker
2. **Preview** — Show what will be removed (dry-run by default)
3. **Confirm** — Require `--execute` flag to actually delete (no accidental deletions)
4. **Clean** — Remove marked files
5. **Report** — List what was removed, what was skipped, and next steps

```bash
# Preview what would be cleaned up
bash scripts/migrate-to-plugin.sh

# Actually execute the migration
bash scripts/migrate-to-plugin.sh --execute
```

**Note:** The migration script does NOT add the marketplace or install the plugin. Those are manual `/plugin` commands the user runs in Claude Code. The script only cleans up old file copies.

### Edge Cases

- **Modified files:** If a user modified a Haunt-deployed file, the marker still exists but the content differs. The script warns but still removes (the plugin version supersedes).
- **No old deployment:** Script exits cleanly with "Nothing to migrate."
- **Partial deployment:** Script handles missing directories gracefully.

## CLAUDE.md Updates

### New Setup Section

```markdown
## Setup

Install as a Claude Code plugin:

\`\`\`bash
# Add marketplace (one-time)
/plugin marketplace add ghost-county/haunt

# Install plugin
/plugin install haunt@ghost-county-haunt
\`\`\`

Updates pull automatically. For existing `setup-haunt.sh` users, run the migration first:

\`\`\`bash
bash scripts/migrate-to-plugin.sh          # Preview cleanup
bash scripts/migrate-to-plugin.sh --execute # Execute cleanup
\`\`\`
```

### New Repo Structure

```markdown
## Repository Structure

\`\`\`
haunt/
├── .claude-plugin/           # Plugin metadata
│   ├── plugin.json
│   └── marketplace.json
├── agents/                   # Team-aware agents (6 gco agents)
├── rules/                    # Always-loaded rules (6 gco rules)
├── skills/                   # On-demand skills (16 gco skills)
├── commands/                 # Slash commands (seance, ship, qa, checkup)
├── hooks/                    # Enforcement hooks + hooks.json manifest
├── templates/                # Gate output, institutional memory, settings templates
├── scripts/                  # Migration, metrics, freshness, cost tools
├── docs/                     # Architecture standards, white paper, guides
├── CLAUDE.md                 # Project instructions
└── README.md                 # Public-facing docs
\`\`\`
```

### New Hooks Section

Replace the flat hooks table with the three-tier structure (Always Enabled, Seance-Gated, Shipped but Disabled) as defined in this spec.

## README Onboarding

The README.md is the entry point for new users finding the repo on GitHub. It must include install instructions prominently.

### README Install Section

```markdown
## Quick Install

1. Add the Haunt marketplace (one-time):
   ```
   /plugin marketplace add ghost-county/haunt
   ```

2. Install the plugin:
   ```
   /plugin install haunt@ghost-county-haunt
   ```

That's it. Updates are automatic — when changes are pushed to `main`, Claude Code picks them up on its next marketplace refresh. No manual pulls or script re-runs needed.

### Migrating from setup-haunt.sh

If you previously used `setup-haunt.sh` to deploy Haunt:

```bash
bash scripts/migrate-to-plugin.sh          # Preview what gets cleaned up
bash scripts/migrate-to-plugin.sh --execute # Remove old file copies
```

Then follow the Quick Install steps above.
```

### How It Works

Claude Code's plugin marketplace system:
1. `/plugin marketplace add ghost-county/haunt` — tells Claude Code to track the `ghost-county/haunt` GitHub repo as a plugin source
2. `/plugin install haunt@ghost-county-haunt` — installs the plugin from that marketplace
3. Claude Code periodically refreshes marketplace repos — new commits to `main` are picked up automatically
4. No repo clone, no manual pulls, no scripts — fully managed by Claude Code

## Verification

After restructuring and installing:

1. **Plugin installed:** `/plugin list` shows `haunt@ghost-county-haunt`
2. **Skills available:** Skills appear in the skill list (e.g., `gco-code-review`, `gco-tdd-workflow`)
3. **Agents available:** Agents are spawnable (e.g., `gco-dev`, `gco-code-reviewer`)
4. **Commands available:** `/seance`, `/ship`, `/qa`, `/checkup` work
5. **Hooks firing:** Start a session, check `.haunt/logs/` for observability output
6. **Old files gone:** No `gco-*` files in `~/.claude/agents/`, `~/.claude/skills/`, etc.
7. **Seance gate:** Outside of seance, damage-control/completion-gate/phase-enforcement are no-ops

## Path to Public (Phase C)

When ready for public distribution:

1. Submit to `claude-plugins-official` via their [plugin directory submission form](https://clau.de/plugin-directory-submission)
2. No structural changes needed — the repo already matches the required format
3. Users switch from custom marketplace to official: `/plugin install haunt@claude-plugins-official`

**Phase C prerequisites (out of scope for now):**
- Hook configuration docs for new users (currently handled by `update-config` skill + manual `settings.json`)
- Versioning/changelog automation (currently manual semver + git tags)
- Public README polish and getting-started guide

## Out of Scope

- **Custom hook configuration UI** — Users configure via `update-config` skill or manual `settings.json`. Phase C may add a `/haunt configure` command.
- **Plugin versioning automation** — Manual semver in plugin.json + git tags. Phase C may add automated changelog generation.
- **Haunt CLI wrapper** — Users use native `/plugin` commands. No wrapper needed unless plugin management gets complex.
