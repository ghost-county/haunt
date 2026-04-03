---
last-verified: 2026-04-03
name: gco-commit-conventions
description: Advanced commit scenarios - WIP tracking, multi-requirement commits, breaking changes, and special git operations. Invoke for complex commit scenarios beyond basic format.
---

# Commit Conventions - Advanced Scenarios

> **Note:** For basic commit format, see `.claude/rules/gco-commit-conventions.md`

## Work-in-Progress Commits

**Format:**
```
[REQ-XXX] Action: Brief description

What was done:
- Completed change 1
- Completed change 2

Next steps:
- What remains

Status: IN_PROGRESS | BLOCKED

🤖 Generated with Claude Code
```

**Rules:** Use Status only when incomplete. "Next steps" required for IN_PROGRESS/BLOCKED. WIP commits must still pass tests.

## Multi-Requirement Commits

**Format:**
```
[REQ-XXX, REQ-YYY] Action: Brief description

What was done:
- REQ-XXX: Change for first requirement
- REQ-YYY: Change for second requirement

🤖 Generated with Claude Code
```

**Rules:** Only when changes are TRULY interdependent. Max 2-3 requirements. Update roadmap for ALL requirements. Don't batch unrelated changes.

## Breaking Changes

**Format:**
```
[REQ-XXX] BREAKING: Brief description

What was done:
- Changed API/interface detail
- Updated dependent code

BREAKING CHANGE:
Previous: <what used to work>
New: <what works now>
Migration: <how to update>

🤖 Generated with Claude Code
```

**Rules:** Use BREAKING: prefix. Document migration. Update ALL dependent code in same commit. Notify team.

## Special Commits

| Type | Format |
|------|--------|
| **Merge** | `Merge branch 'feature/REQ-XXX' into main` (auto) + structured body |
| **Release** | `[RELEASE] v1.2.0: Description` + list of included REQ-XXX |
| **Skip CI** | `[REQ-XXX] Docs: Description [skip ci]` (docs-only, end of line) |

## Branch Naming

### Format

**Pattern:** `{type}/REQ-XXX-{slug}`

Where:
- `{type}` - One of: feature, fix, docs, refactor
- `{REQ-XXX}` - Requirement ID from roadmap
- `{slug}` - Descriptive slug (lowercase, hyphens, 30 char max)

### Branch Types

| Type | Purpose | Example |
|------|---------|---------|
| **feature/** | New functionality | `feature/REQ-042-dark-mode` |
| **fix/** | Bug fixes | `fix/REQ-099-login-bug` |
| **docs/** | Documentation only | `docs/REQ-101-api-docs` |
| **refactor/** | Code restructuring | `refactor/REQ-150-auth-cleanup` |

### Slug Generation Rules

1. Convert requirement title to lowercase
2. Replace spaces with hyphens
3. Remove special characters
4. Truncate to 30 characters max

**Examples:**
- "Add OAuth Login Support" → `add-oauth-login-support`
- "Fix: User profile not loading" → `user-profile-not-loading`
- "Update API documentation for v2" → `update-api-documentation-for`

### When to Use Feature Branches

**Use feature branches when:**
- Implementing M-sized requirements (2-4 hours, multiple files)
- Working on features that need PR review/audit trail
- Isolating experimental changes from main
- Team collaboration requires clean separation

**Skip feature branches when:**
- XS-sized requirements (single file, < 30 min)
- Hotfixes that must deploy immediately
- Documentation-only changes to markdown files
- Solo work with no review requirement

**Default recommendation:** Use feature branches for all S/M/SPLIT requirements. Optional for XS.

## Git Operations

**Undo before push:** `git reset --soft HEAD~1` (keep changes) or `git reset --hard HEAD~1` (discard)
**Undo after push:** `git revert HEAD` (safe)
**Amend hook changes:** `git add -u && git commit --amend --no-edit` (only if not pushed)

**Non-Negotiable:** Never force push to main/master. Never amend pushed commits. Communicate before destructive operations.
