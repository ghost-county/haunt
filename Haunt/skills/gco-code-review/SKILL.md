---
name: gco-code-review
description: Structured code review checklist with anti-pattern detection for quality gates. Use when reviewing PRs, code submissions, or validating code before merge. Triggers on "review this code", "PR review", "code review", "check this before merge", "is this code good", or quality validation requests.
---

# Code Review Checklist

Systematic review process ensuring code quality before merge.

## Review Checklist

### Functionality
- [ ] Code does what the requirement asks
- [ ] Edge cases handled (null, empty, boundaries)
- [ ] Error handling appropriate (not silent)
- [ ] No hardcoded values that should be config

### Testing
- [ ] Tests exist and are meaningful
- [ ] Happy path covered
- [ ] Edge cases covered
- [ ] Tests are not brittle (don't break on unrelated changes)
- [ ] No assertions that always pass

### Security
- [ ] No hardcoded secrets/credentials
- [ ] Input validation present
- [ ] No SQL injection vectors
- [ ] No XSS vulnerabilities
- [ ] Sensitive data not logged

### Patterns
- [ ] Follows project conventions
- [ ] No anti-patterns (see table below)
- [ ] Documentation updated if needed
- [ ] Type annotations on public functions

## Anti-Patterns to Reject

| Pattern | Example | Why Bad | Fix |
|---------|---------|---------|-----|
| Silent fallback | `.get(x, 0)` | Hides errors | Explicit validation |
| God function | 200+ line function | Unmaintainable | Split into focused functions |
| Magic numbers | `if x > 86400` | Unclear intent | `SECONDS_PER_DAY = 86400` |
| Catch-all | `except Exception` | Swallows errors | Catch specific exceptions |
| Single-letter vars | `for x in y` | Unreadable | Descriptive names |
| Deep nesting | 4+ indent levels | Hard to follow | Early returns, extract functions |
| Copy-paste code | Duplicated blocks | Maintenance burden | Extract to shared function |
| Commented-out code | `# old_function()` | Clutter | Delete it (git has history) |

## Review Output Format

```markdown
## Review: [PR/Branch Name]

### Status: APPROVED | CHANGES_REQUESTED | BLOCKED

### Checklist
- [x] Functionality verified
- [x] Tests adequate  
- [ ] Security concern (see below)
- [x] Patterns followed

### Issues Found

1. **[High]** Silent fallback on line 42
   File: `src/api/users.py:42`
   Code: `user_id = data.get("id", 0)`
   Fix: Validate required field explicitly
   
2. **[Medium]** Magic number
   File: `src/utils/time.py:15`
   Code: `if elapsed > 3600:`
   Fix: Define `SECONDS_PER_HOUR = 3600`

### Positive Notes
- Good test coverage on happy path
- Clean separation of concerns

### Summary
Two issues to address before merge. Security concern is blocking.
```

## Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| **High** | Security risk or data loss potential | Must fix before merge |
| **Medium** | Maintainability or reliability issue | Should fix, can discuss |
| **Low** | Style or minor improvement | Optional, note for future |

## Quick Rejection Triggers

Immediately request changes if you find:

1. **Hardcoded secrets** - API keys, passwords, tokens
2. **No tests** for new functionality
3. **Bare `except:`** without re-raising
4. **SQL string concatenation** (injection risk)
5. **Unvalidated user input** used directly

## When to Block vs Request Changes

**BLOCKED** (cannot merge even with fixes):
- Tests failing in CI
- Merge conflicts unresolved
- Missing required approvals
- Dependency on unmerged PR

**CHANGES_REQUESTED** (can merge after fixes):
- Code issues found
- Missing tests
- Documentation incomplete
- Style violations
