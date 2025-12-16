# Bind - Custom Workflow Rule Overrides

Create project-specific rule overrides that supersede Haunt's default workflow rules. Allows teams to customize workflows while maintaining most of Haunt's structure.

## Usage

```
/bind <rule-name> <override-file>
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `rule-name` | Yes | Name of the rule to override (e.g., `gco-commit-conventions`) |
| `override-file` | Yes | Path to custom rule markdown file |

## Options

| Option | Description |
|--------|-------------|
| `--scope=project` | Apply binding to current project only (default) |
| `--scope=user` | Apply binding globally to all user projects |
| `--validate` | Validate rule format without applying |
| `--dry-run` | Preview binding without creating it |
| `--force` | Skip validation and confirmation prompts |

## Examples

```bash
# Bind custom commit conventions for current project
/bind gco-commit-conventions ./custom-commits.md

# Preview what would happen
/bind gco-commit-conventions ./custom-commits.md --dry-run

# Validate rule format only
/bind gco-commit-conventions ./custom-commits.md --validate

# Apply globally to all projects
/bind gco-roadmap-format ./custom-roadmap.md --scope=user

# Force apply without validation (not recommended)
/bind gco-session-startup ./custom-startup.md --force
```

## How It Works

### Priority System

Rules are loaded in this priority order (highest to lowest):

1. **Project bindings** (`.haunt/bindings/`)
2. **User bindings** (`~/.haunt/bindings/`)
3. **Project rules** (`.claude/rules/`)
4. **Global rules** (`~/.claude/rules/`)
5. **Haunt defaults** (`Haunt/rules/`)

Custom bindings ALWAYS supersede lower-priority rules with the same name.

### Storage Locations

| Scope | Storage Location | When Loaded |
|-------|------------------|-------------|
| Project | `.haunt/bindings/<rule-name>.md` | This project only |
| User/Global | `~/.haunt/bindings/<rule-name>.md` | All projects for this user |

### Rule Format Requirements

Custom rule files MUST:
- Be valid markdown
- Use `.md` extension
- Have descriptive heading structure
- Follow Haunt rule naming (prefix `gco-`)

**Example custom rule:**

```markdown
# Custom Commit Conventions

Our team uses Jira tickets instead of REQ numbers.

## Commit Message Format

```
[PROJ-123] action: description

What was done:
- Change 1
- Change 2
```

## Rules

- Must reference Jira ticket
- Use lowercase action verbs
- Keep under 80 characters
```

## What Can Be Overridden

Common rules to customize:

| Rule | Override Use Case |
|------|-------------------|
| `gco-commit-conventions` | Use Jira/Linear tickets instead of REQ-XXX |
| `gco-roadmap-format` | Different requirement template |
| `gco-session-startup` | Skip test validation for prototypes |
| `gco-status-updates` | Custom status workflow |
| `gco-completion-checklist` | Different completion criteria |

## What Should NOT Be Overridden

Some rules are foundational and overriding them breaks agent coordination:

- `gco-assignment-lookup` - Core agent assignment protocol
- `gco-file-conventions` - Directory structure assumptions
- `gco-framework-changes` - Haunt source management

Override these only if you fully understand the implications.

## Binding Lifecycle

```
Create Binding:
  /bind gco-commit-conventions ./custom.md
  → Validates format
  → Copies to .haunt/bindings/gco-commit-conventions.md
  → Agents use custom rule immediately

Check Bindings:
  /bind-list
  → Shows active overrides and their scope

Remove Binding:
  /unbind gco-commit-conventions
  → Removes override
  → Agents revert to Haunt defaults
```

## Validation

The bind command validates:

1. **File exists** - Override file must be readable
2. **Valid markdown** - Basic syntax checking
3. **Naming convention** - Rule name should match `gco-*` pattern
4. **No conflicts** - Warns if binding already exists

Validation can be skipped with `--force` but is not recommended.

## Safety Features

1. **Dry-run mode** - Preview without applying
2. **Validation** - Check format before binding
3. **Backup** - Existing bindings backed up before overwrite
4. **Confirmation** - Prompt for approval (unless `--force`)
5. **List tracking** - All bindings tracked in `.haunt/bindings/index.txt`

## Workflow Example

**Scenario:** Team wants to use Linear tickets instead of REQ-XXX.

```bash
# 1. Create custom commit rule
cat > custom-commits.md << 'EOF'
# Custom Commit Conventions

Use Linear tickets: [PROJ-123]

## Format
[PROJ-123] Action: description

What was done:
- Changes
EOF

# 2. Validate format
/bind gco-commit-conventions custom-commits.md --validate

# 3. Preview binding
/bind gco-commit-conventions custom-commits.md --dry-run

# 4. Apply binding
/bind gco-commit-conventions custom-commits.md

# 5. Verify
/bind-list

# 6. Make commit using custom format
git commit -m "[PROJ-123] Add: new feature"
```

## Troubleshooting

### "Binding already exists"
```bash
# View current binding
/bind-list

# Unbind first
/unbind gco-commit-conventions

# Then re-bind
/bind gco-commit-conventions ./new-custom.md
```

### "Rule name doesn't follow convention"
```bash
# Use gco- prefix
/bind gco-my-custom-rule ./rule.md  # Good
/bind my-custom-rule ./rule.md      # Warning (still works)
```

### "Binding not taking effect"
```bash
# Check priority - project bindings override user bindings
/bind-list --verbose

# Remove conflicting lower-priority binding
/unbind gco-commit-conventions --scope=user
```

## Implementation

Runs the script: `bash Haunt/scripts/bind.sh <rule-name> <override-file> [options]`

## See Also

- `/unbind` - Remove custom rule overrides
- `/bind-list` - Show active bindings
- `/cleanse` - Environment management
- `gco-framework-changes` - Rule for modifying Haunt itself
