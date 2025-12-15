# Cleanse - Environment Management

Manage your Haunt framework installation with repair, uninstall, or purge modes. Fix stale files, remove artifacts, or completely remove Haunt.

## Usage

```
/cleanse [mode] [options]
```

## Modes

| Mode | Flag | Description |
|------|------|-------------|
| **Repair** | `--repair` | Detect stale files, remove them, re-sync from Haunt/ source |
| **Uninstall** | `--uninstall` | Remove gco-* artifacts (default) |
| **Purge** | `--purge` | Full removal: uninstall + remove .haunt/ directory |

## Scope Options

| Scope | Flag | Targets |
|-------|------|---------|
| **Project** | `--scope=project` | Only `.claude/` in current project |
| **User/Global** | `--scope=user` or `--scope=global` | Only `~/.claude/` |
| **Both** | `--scope=both` | Both locations (default) |

## Other Options

| Option | Description |
|--------|-------------|
| `--backup` | Create backup before any deletion |
| `--dry-run` | Preview what would happen without making changes |
| `--force` | Skip confirmation prompts (dangerous!) |
| `--help` | Show help message |

## Examples

```bash
# Fix stale files in global installation (most common use)
/cleanse --repair --scope=user

# Preview what repair would do
/cleanse --repair --dry-run

# Uninstall from project only
/cleanse --uninstall --scope=project

# Full removal with backup
/cleanse --purge --backup

# Remove everything from everywhere (careful!)
/cleanse --purge --scope=both --force
```

## Repair Mode - Fixing Stale Files

The most useful mode for maintaining your installation. Use when:
- Files from old Haunt versions are still deployed
- Skills/commands were renamed and old versions persist
- You're getting duplicate functionality

**How it works:**
1. Scans deployed locations (`~/.claude/` and/or `.claude/`)
2. Compares against current `Haunt/` source directory
3. Identifies stale files (deployed but not in source)
4. Removes stale files
5. Re-runs `setup-haunt.sh` to sync current source

**Example output:**
```
Scanning for Stale Spirits

Global (~/.claude/):
  Stale: /Users/you/.claude/skills/gco-old-skill-name/
  Stale: /Users/you/.claude/commands/gco-renamed-command.md

Found 2 stale file(s)/directory(ies)

Preview: Repair Plan
  Step 1: Remove stale items
    - /Users/you/.claude/skills/gco-old-skill-name/ (directory)
    - /Users/you/.claude/commands/gco-renamed-command.md

  Step 2: Re-sync from Source
    Will run: bash Haunt/scripts/setup-haunt.sh
```

## Uninstall Mode

Removes all gco-* artifacts from the specified scope. Does NOT remove `.haunt/` directory.

**What gets removed:**
- `~/.claude/agents/gco-*.md` (global agents)
- `~/.claude/rules/gco-*.md` (global rules)
- `~/.claude/skills/gco-*/` (global skills)
- `~/.claude/commands/gco-*.md` (global commands)
- Same for `.claude/` if project scope included

**What's preserved:**
- `.haunt/` directory (roadmap, progress, completed work)
- `Haunt/` source directory
- Non-gco agents/rules/skills/commands

## Purge Mode

Complete removal including project planning artifacts. Use when starting fresh or completely removing Haunt.

**What gets removed:**
Everything from uninstall mode PLUS:
- `.haunt/plans/` - Your roadmap
- `.haunt/progress/` - Session progress
- `.haunt/completed/` - Archived work
- `.haunt/tests/` - Test files
- `.haunt/docs/` - Documentation

**WARNING:** Purge destroys your planning history. Always use `--backup` with purge.

## Scope Combinations

| Mode | Scope | Effect |
|------|-------|--------|
| repair + user | Fix stale files only in `~/.claude/` |
| repair + project | Fix stale files only in `.claude/` |
| repair + both | Fix stale files everywhere |
| uninstall + user | Remove from `~/.claude/` only |
| uninstall + project | Remove from `.claude/` only |
| purge + project | Remove `.claude/` AND `.haunt/` |
| purge + user | Remove `~/.claude/` only (no .haunt) |
| purge + both | Remove everything |

## Safety Features

1. **Dry-run mode** - Preview without changes
2. **Backup creation** - Save before deletion
3. **Uncommitted work check** - Warns about in-progress items
4. **Confirmation required** - Must type "CLEANSE" to proceed
5. **Legacy flag support** - `--partial` and `--full` still work

## Backup and Restore

```bash
# Create backup during cleanse
/cleanse --purge --backup

# Restore from backup
cd ~
tar -xzf ~/haunt-backup-YYYY-MM-DD-HHMMSS.tar.gz
```

## Implementation

Runs the script: `bash Haunt/scripts/cleanse.sh [options]`

## Common Workflows

### "I have duplicate skills from old installation"
```bash
/cleanse --repair --scope=user --dry-run  # Preview first
/cleanse --repair --scope=user            # Then fix
```

### "I want to start fresh on this project"
```bash
/cleanse --purge --scope=project --backup
bash Haunt/scripts/setup-haunt.sh --project-only
```

### "I want to completely remove Haunt"
```bash
/cleanse --purge --scope=both --backup
```

### "I want to reinstall just the global agents"
```bash
/cleanse --uninstall --scope=user
bash Haunt/scripts/setup-haunt.sh --agents-only
```

## See Also

- `/haunt-update` - Update Haunt without full reinstall
- `/summon` - Spawn agents for roadmap work
- `setup-haunt.sh` - Installation script
