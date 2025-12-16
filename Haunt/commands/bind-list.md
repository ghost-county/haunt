# Bind-List - Show Active Rule Overrides

Display all active custom rule bindings and their priority order. Shows which rules are overridden and where they're loaded from.

## Usage

```
/bind-list [options]
```

## Options

| Option | Description |
|--------|-------------|
| `--scope=project` | Show project bindings only |
| `--scope=user` | Show user-global bindings only |
| `--scope=both` | Show all bindings (default) |
| `--verbose` | Include detailed information (size, dates, priority) |
| `--rule=<name>` | Show details for specific rule |

## Examples

```bash
# List all bindings
/bind-list

# Show project bindings only
/bind-list --scope=project

# Show user-global bindings
/bind-list --scope=user

# Detailed view with metadata
/bind-list --verbose

# Check specific rule
/bind-list --rule=gco-commit-conventions

# See everything
/bind-list --scope=both --verbose
```

## Output Format

### Standard Output

```
Active Rule Bindings

Project Bindings (.haunt/bindings/):
  gco-commit-conventions.md
  gco-roadmap-format.md

User Bindings (~/.haunt/bindings/):
  gco-session-startup.md

Total: 3 binding(s)
```

### Verbose Output

```
Active Rule Bindings (Detailed)

Project Bindings (.haunt/bindings/):
  gco-commit-conventions.md
    Priority: 1 (highest - overrides all)
    Size: 1.2 KB
    Created: 2025-12-15 14:23:45
    Overrides: Haunt/rules/gco-commit-conventions.md

  gco-roadmap-format.md
    Priority: 1 (highest - overrides all)
    Size: 3.4 KB
    Created: 2025-12-14 09:15:22
    Overrides: Haunt/rules/gco-roadmap-format.md

User Bindings (~/.haunt/bindings/):
  gco-session-startup.md
    Priority: 2 (overrides global and Haunt defaults)
    Size: 2.1 KB
    Created: 2025-12-13 16:42:10
    Overrides: Haunt/rules/gco-session-startup.md

Total: 3 binding(s)

Priority Order (highest to lowest):
  1. Project bindings (.haunt/bindings/)
  2. User bindings (~/.haunt/bindings/)
  3. Project rules (.claude/rules/)
  4. Global rules (~/.claude/rules/)
  5. Haunt defaults (Haunt/rules/)
```

### Specific Rule Output

```bash
/bind-list --rule=gco-commit-conventions
```

```
Rule: gco-commit-conventions

Active Binding:
  Location: .haunt/bindings/gco-commit-conventions.md (project scope)
  Priority: 1 (highest)
  Size: 1.2 KB
  Created: 2025-12-15 14:23:45
  Modified: 2025-12-15 14:23:45

Overrides:
  ~/.claude/rules/gco-commit-conventions.md (priority 4)
  Haunt/rules/gco-commit-conventions.md (priority 5)

Agents Load From:
  .haunt/bindings/gco-commit-conventions.md ← ACTIVE

To remove: /unbind gco-commit-conventions
```

## Understanding Priority

Bindings are loaded in priority order. Higher priority overrides lower:

| Priority | Location | Scope | When Used |
|----------|----------|-------|-----------|
| **1** | `.haunt/bindings/` | Project | This project only |
| **2** | `~/.haunt/bindings/` | User | All projects for user |
| **3** | `.claude/rules/` | Project | Project rules (not bindings) |
| **4** | `~/.claude/rules/` | Global | Global rules (not bindings) |
| **5** | `Haunt/rules/` | Framework | Haunt defaults |

**Example scenario:**

```
Project: .haunt/bindings/gco-commit-conventions.md exists
User: ~/.haunt/bindings/gco-commit-conventions.md exists
Haunt: Haunt/rules/gco-commit-conventions.md (default)

→ Agents use: .haunt/bindings/gco-commit-conventions.md (priority 1)
```

## Scope Filtering

### Project Scope Only

```bash
/bind-list --scope=project
```

Shows only bindings in `.haunt/bindings/` for current project.

### User Scope Only

```bash
/bind-list --scope=user
```

Shows only bindings in `~/.haunt/bindings/` (apply to all projects).

### Both Scopes (Default)

```bash
/bind-list --scope=both
# or just
/bind-list
```

Shows bindings from both locations with clear scope labels.

## Use Cases

### Audit Custom Rules

```bash
# See what's overridden
/bind-list --verbose

# Check if specific rule is bound
/bind-list --rule=gco-commit-conventions
```

### Troubleshoot Binding Issues

```bash
# Why is my project binding not working?
/bind-list --rule=gco-commit-conventions --verbose
# Check if user binding has higher priority

# Remove conflicting user binding
/unbind gco-commit-conventions --scope=user
```

### Document Project Customizations

```bash
# Export binding list for documentation
/bind-list --verbose > project-bindings.txt

# Share with team
git add project-bindings.txt
git commit -m "Document custom rule bindings"
```

### Verify Binding Creation

```bash
# Before
/bind-list

# Create binding
/bind gco-commit-conventions ./custom-commits.md

# After (verify)
/bind-list
# Should show new binding
```

## Empty State

When no bindings exist:

```
Active Rule Bindings

No custom bindings found.

All agents use Haunt default rules.

To create a binding: /bind <rule-name> <override-file>
```

## Troubleshooting

### "Binding listed but not taking effect"

```bash
# Check priority order
/bind-list --rule=gco-commit-conventions --verbose

# Higher priority binding might exist
# Remove to allow lower priority binding
/unbind gco-commit-conventions --scope=project
```

### "Can't find binding I just created"

```bash
# Check file exists
ls -la .haunt/bindings/

# Check scope matches
/bind-list --scope=project  # If you created project binding
/bind-list --scope=user     # If you created user binding

# Verify binding index
cat .haunt/bindings/index.txt
```

### "Want to know what's being used"

```bash
# Detailed view shows active binding
/bind-list --rule=gco-commit-conventions

# Or check all bindings
/bind-list --verbose
```

## Output Examples

### Multiple Bindings

```
Active Rule Bindings

Project Bindings (.haunt/bindings/):
  gco-commit-conventions.md
  gco-roadmap-format.md
  gco-status-updates.md

User Bindings (~/.haunt/bindings/):
  gco-session-startup.md

Total: 4 binding(s)

Priority: Project bindings override user bindings.

To see details: /bind-list --verbose
```

### Single Binding

```
Active Rule Bindings

Project Bindings (.haunt/bindings/):
  gco-commit-conventions.md

Total: 1 binding(s)
```

### Verbose with Conflicts

```
Rule: gco-commit-conventions

Bindings Found (highest priority first):
  1. .haunt/bindings/gco-commit-conventions.md (project) ← ACTIVE
     Size: 1.2 KB
     Created: 2025-12-15 14:23:45

  2. ~/.haunt/bindings/gco-commit-conventions.md (user)
     Size: 1.5 KB
     Created: 2025-12-14 09:15:22
     Note: Shadowed by higher-priority project binding

Agents Load From:
  .haunt/bindings/gco-commit-conventions.md

To remove project binding: /unbind gco-commit-conventions
```

## Implementation

Runs the script: `bash Haunt/scripts/bind-list.sh [options]`

## See Also

- `/bind` - Create custom rule overrides
- `/unbind` - Remove custom rule overrides
- `gco-framework-changes` - Rule modification protocol
