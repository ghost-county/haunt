# Unbind - Remove Custom Rule Overrides

Remove project-specific or user-global rule overrides created with `/bind`. Agents revert to using Haunt default rules.

## Usage

```
/unbind <rule-name> [options]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `rule-name` | Yes | Name of the bound rule to remove |

## Options

| Option | Description |
|--------|-------------|
| `--scope=project` | Remove project binding only (default) |
| `--scope=user` | Remove user-global binding |
| `--scope=both` | Remove from both project and user |
| `--backup` | Create backup before removing |
| `--dry-run` | Preview what would be removed |
| `--force` | Skip confirmation prompt |

## Examples

```bash
# Remove project binding (most common)
/unbind gco-commit-conventions

# Preview what would be removed
/unbind gco-commit-conventions --dry-run

# Remove user-global binding
/unbind gco-roadmap-format --scope=user

# Remove from both scopes with backup
/unbind gco-session-startup --scope=both --backup

# Force remove without confirmation
/unbind gco-status-updates --force
```

## How It Works

### Removal Behavior

1. Identifies binding location based on scope
2. Creates backup if `--backup` flag set
3. Removes binding file from `.haunt/bindings/` or `~/.haunt/bindings/`
4. Updates binding index (`.haunt/bindings/index.txt`)
5. Agents immediately revert to default Haunt rule

### Scope Resolution

| Scope | Removes From | Fallback After Removal |
|-------|--------------|------------------------|
| `project` | `.haunt/bindings/` | User binding or Haunt default |
| `user` | `~/.haunt/bindings/` | Haunt default |
| `both` | Both locations | Haunt default |

**Priority after removal:**
If you remove a project binding, agents use user binding (if exists), otherwise Haunt default.

## Safety Features

1. **Dry-run mode** - Preview removal without deleting
2. **Backup creation** - Save binding before removal
3. **Confirmation prompt** - Asks for approval (unless `--force`)
4. **Existence check** - Warns if binding doesn't exist

## Examples

### Remove Project Binding

```bash
# Check current bindings
/bind-list

# Preview removal
/unbind gco-commit-conventions --dry-run

# Remove with backup
/unbind gco-commit-conventions --backup

# Verify removal
/bind-list
```

**Output:**
```
Previewing Unbind: gco-commit-conventions (project scope)

Current binding:
  Location: .haunt/bindings/gco-commit-conventions.md
  Created: 2025-12-15 14:23:45
  Size: 1.2 KB

After removal:
  Agents will use: Haunt default (Haunt/rules/gco-commit-conventions.md)

To proceed: /unbind gco-commit-conventions
```

### Remove User-Global Binding

```bash
# Remove from global scope
/unbind gco-roadmap-format --scope=user --backup

# Check what's left
/bind-list --scope=user
```

### Remove From All Scopes

```bash
# Remove everywhere
/unbind gco-session-startup --scope=both --backup

# Verify complete removal
/bind-list --verbose
```

## Backup and Restore

When using `--backup`:

```bash
# Remove with backup
/unbind gco-commit-conventions --backup
# → Creates: .haunt/bindings/.backup/gco-commit-conventions.md.YYYY-MM-DD-HHMMSS

# Restore from backup
/bind gco-commit-conventions .haunt/bindings/.backup/gco-commit-conventions.md.YYYY-MM-DD-HHMMSS
```

## Troubleshooting

### "Binding not found"

```bash
# Check where bindings exist
/bind-list --verbose

# Binding might be in different scope
/unbind gco-commit-conventions --scope=user  # Try user scope
```

### "Still using custom rule after unbind"

```bash
# Check for bindings in both scopes
/bind-list

# Unbind from both
/unbind gco-commit-conventions --scope=both

# Verify removal
/bind-list
```

### "Want to restore removed binding"

```bash
# If you used --backup
ls .haunt/bindings/.backup/

# Restore
/bind gco-commit-conventions .haunt/bindings/.backup/gco-commit-conventions.md.TIMESTAMP

# Or manually copy
cp .haunt/bindings/.backup/gco-commit-conventions.md.TIMESTAMP .haunt/bindings/gco-commit-conventions.md
```

## Common Workflows

### Temporarily Disable Custom Rule

```bash
# Backup and remove
/unbind gco-commit-conventions --backup

# Work with default rule
# ...

# Restore when done
/bind gco-commit-conventions .haunt/bindings/.backup/gco-commit-conventions.md.TIMESTAMP
```

### Clean Up All Bindings

```bash
# List all bindings
/bind-list

# Remove each one
/unbind gco-commit-conventions
/unbind gco-roadmap-format
/unbind gco-session-startup

# Verify clean
/bind-list
```

### Switch Binding Scopes

```bash
# Remove from project, add to user
/unbind gco-commit-conventions --scope=project
/bind gco-commit-conventions ./custom-commits.md --scope=user
```

## What Happens After Unbind

When you remove a binding, agents immediately:

1. **Stop using custom rule** - No longer loaded
2. **Fall back to next priority** - User binding or Haunt default
3. **Retain rule history** - Backup preserves previous binding

**Example fallback chain:**

```
Before unbind:
  Project binding active → Agents use .haunt/bindings/gco-commit-conventions.md

After unbind (project scope):
  Project binding removed → Agents use ~/.haunt/bindings/gco-commit-conventions.md (if exists)
                         → Otherwise: Haunt/rules/gco-commit-conventions.md
```

## Implementation

Runs the script: `bash Haunt/scripts/unbind.sh <rule-name> [options]`

## See Also

- `/bind` - Create custom rule overrides
- `/bind-list` - Show active bindings
- `/cleanse` - Environment management
