# Bindings Guide: Customizing Workflow Rules

## Quick Start

The `/bind` command system lets you override Haunt's default workflow rules for project-specific or team-specific needs.

## Common Use Cases

### Use Jira Tickets Instead of REQ-XXX

**Problem:** Your team uses Jira, not REQ-XXX requirement IDs.

**Solution:**

```bash
# 1. Create custom commit rule
cat > custom-commits.md << 'EOF'
# Custom Commit Conventions

Use Jira tickets instead of REQ-XXX.

## Format
[PROJ-123] Action: description

What was done:
- Changes

🤖 Generated with Claude Code
EOF

# 2. Bind for this project
/bind gco-commit-conventions custom-commits.md

# 3. Verify
/bind-list
```

Now all commits in this project use `[PROJ-123]` format.

### Skip Session Tests for Prototypes

**Problem:** You're prototyping and don't want agents to enforce passing tests.

**Solution:**

```bash
# 1. Create custom startup rule
cat > custom-startup.md << 'EOF'
# Custom Session Startup

Skip test validation for rapid prototyping.

## Steps
1. Verify environment (pwd, git status)
2. Check recent changes (git log)
3. Find assignment (Active Work → Roadmap → Ask PM)
4. Start work (skip test validation)
EOF

# 2. Bind for this project
/bind gco-session-startup custom-startup.md

# 3. When done prototyping, remove
/unbind gco-session-startup
```

### Team-Specific Roadmap Format

**Problem:** Your team uses different requirement structure.

**Solution:**

```bash
# 1. Create custom roadmap format
cat > team-roadmap.md << 'EOF'
# Custom Roadmap Format

## Requirement Template

### STATUS TICKET-123: Title

**Priority:** P0 | P1 | P2
**Owner:** @username
**Sprint:** Sprint-42

**User Story:**
As a [user], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
EOF

# 2. Bind globally for all your projects
/bind gco-roadmap-format team-roadmap.md --scope=user

# 3. All your projects now use this format
```

## Priority System

Rules are loaded in this order (highest to lowest):

1. **Project bindings** (`.haunt/bindings/`)
   - Specific to current project
   - Created with `/bind <rule> <file>`

2. **User bindings** (`~/.haunt/bindings/`)
   - Apply to ALL your projects
   - Created with `/bind <rule> <file> --scope=user`

3. **Project rules** (`.claude/rules/`)
   - Project-specific rules (not bindings)

4. **Global rules** (`~/.claude/rules/`)
   - Haunt-deployed rules

5. **Haunt defaults** (`Haunt/rules/`)
   - Framework source rules

**Example:**

```
You have:
- .haunt/bindings/gco-commit-conventions.md (project binding)
- ~/.haunt/bindings/gco-commit-conventions.md (user binding)
- Haunt/rules/gco-commit-conventions.md (default)

Agents use: .haunt/bindings/gco-commit-conventions.md (priority 1)
```

## Command Reference

### /bind - Create Override

```bash
# Syntax
/bind <rule-name> <override-file> [options]

# Options
--scope=project       # Apply to current project (default)
--scope=user          # Apply to all user projects
--validate            # Check format without applying
--dry-run             # Preview without creating
--force               # Skip validation and prompts

# Examples
/bind gco-commit-conventions ./custom-commits.md
/bind gco-roadmap-format ./team-format.md --scope=user
/bind gco-session-startup ./quick-startup.md --dry-run
```

### /unbind - Remove Override

```bash
# Syntax
/unbind <rule-name> [options]

# Options
--scope=project       # Remove project binding (default)
--scope=user          # Remove user binding
--scope=both          # Remove from both
--backup              # Create backup before removal
--dry-run             # Preview removal
--force               # Skip confirmation

# Examples
/unbind gco-commit-conventions
/unbind gco-roadmap-format --scope=user
/unbind gco-session-startup --scope=both --backup
```

### /bind-list - View Active Bindings

```bash
# Syntax
/bind-list [options]

# Options
--scope=project       # Show project bindings only
--scope=user          # Show user bindings only
--scope=both          # Show all (default)
--verbose             # Detailed view
--rule=<name>         # Show specific rule

# Examples
/bind-list
/bind-list --verbose
/bind-list --rule=gco-commit-conventions
/bind-list --scope=user
```

## Best Practices

### DO

- Use `--dry-run` before binding to preview
- Use `--backup` when unbinding in case you need to restore
- Document your custom bindings in project README
- Use project scope for project-specific rules
- Use user scope for personal workflow preferences
- Version control custom rule files in your project

### DON'T

- Override foundational rules like `gco-assignment-lookup` or `gco-file-conventions`
- Create bindings without understanding what they replace
- Use `--force` without reviewing validation warnings
- Forget to communicate binding changes to your team
- Mix project-specific and user-global bindings carelessly

## Workflow Examples

### Temporary Override for Feature Branch

```bash
# Working on feature that needs different workflow
git checkout -b feature/experimental

# Bind custom rule for this branch
/bind gco-session-startup ./experimental-startup.md

# Work on feature...

# When merging back, remove override
/unbind gco-session-startup
git checkout main
```

### Team Onboarding with Bindings

```bash
# Team maintains custom rules in repo
git clone team-repo
cd team-repo

# Bindings documented in setup script
cat setup-team-workflow.sh

#!/bin/bash
/bind gco-commit-conventions ./team/commit-format.md
/bind gco-roadmap-format ./team/roadmap-template.md
/bind gco-completion-checklist ./team/definition-of-done.md

# New team members run setup
bash setup-team-workflow.sh
```

### Personal Productivity Tweaks

```bash
# You prefer terser commit messages
cat > ~/my-commits.md << 'EOF'
# Terse Commits

[REQ-XXX] Action: description

Done:
- Changes

🤖 Generated with Claude Code
EOF

# Apply to all your projects
/bind gco-commit-conventions ~/my-commits.md --scope=user

# All your projects now use terse format
```

## Troubleshooting

### "Binding not taking effect"

```bash
# Check what's active
/bind-list --rule=gco-commit-conventions

# Higher priority binding might exist
# Remove to allow lower priority
/unbind gco-commit-conventions --scope=project
```

### "Want to share binding with team"

```bash
# Add custom rule to repo
mkdir -p team-workflow
cp .haunt/bindings/gco-commit-conventions.md team-workflow/

# Commit to repo
git add team-workflow/
git commit -m "Add team commit conventions"

# Team members bind
/bind gco-commit-conventions team-workflow/gco-commit-conventions.md
```

### "Accidentally broke workflow"

```bash
# Remove problematic binding
/unbind gco-session-startup --backup

# Restore if needed
/bind gco-session-startup .haunt/bindings/.backup/gco-session-startup.md.TIMESTAMP

# Or just remove and use default
/unbind gco-session-startup
```

## Rules You Can Safely Override

| Rule | Safe to Override? | Use Case |
|------|-------------------|----------|
| `gco-commit-conventions` | ✅ Yes | Use different ticket system |
| `gco-roadmap-format` | ✅ Yes | Team-specific requirement template |
| `gco-session-startup` | ⚠️ Carefully | Skip tests for prototyping |
| `gco-status-updates` | ✅ Yes | Different status workflow |
| `gco-completion-checklist` | ✅ Yes | Custom definition of done |
| `gco-ui-testing-protocol` | ✅ Yes | Different test framework |
| `gco-assignment-lookup` | ❌ No | Core agent coordination |
| `gco-file-conventions` | ❌ No | Directory structure assumptions |
| `gco-framework-changes` | ❌ No | Haunt source management |

## See Also

- `/bind` command documentation: `Haunt/commands/bind.md`
- `/unbind` command documentation: `Haunt/commands/unbind.md`
- `/bind-list` command documentation: `Haunt/commands/bind-list.md`
- Rule development guide: `Haunt/docs/RULE-DEVELOPMENT.md` (if exists)
