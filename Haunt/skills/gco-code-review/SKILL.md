---
last-verified: 2026-04-03
version: "1.0"
name: gco-code-review
description: >-
  Structured code review with anti-pattern detection, severity classification, and evidence-backed verdicts for quality gates.
  Use when reviewing PRs, code submissions, or validating code before merge.
---

# Code Review Checklist

## Vocabulary Payload

| Term | Definition | Use When |
|------|-----------|----------|
| APPROVED | Code meets all standards, ready to merge | Final verdict, clean review |
| CHANGES_REQUESTED | Issues found, Dev should fix and re-request | Actionable issues found |
| BLOCKED | Critical issue, must not merge under any circumstances | Security, failing CI, unresolved conflicts |
| severity:HIGH | Security risk or data loss potential — must fix | Hardcoded secrets, injection, silent data loss |
| severity:MEDIUM | Maintainability or reliability issue — should fix | God functions, missing edge cases, brittle tests |
| severity:LOW | Style or minor improvement — optional | Magic numbers, naming, documentation |
| evidence-backed verdict | Verdict citing specific file:line references and patterns checked | Every APPROVED or CHANGES_REQUESTED |
| quick rejection trigger | Pattern that auto-triggers CHANGES_REQUESTED | Hardcoded secrets, no tests, bare except |
| test brittleness | Tests that break on unrelated changes | Assertions coupled to implementation details |
| coverage gap | New functionality without corresponding tests | Code paths with no test coverage |

## Anti-Patterns and Quick Rejection

See `gco-code-patterns` for the full anti-pattern table with severity classifications and AI occurrence rates.

**Quick rejection triggers** (auto-CHANGES_REQUESTED):
1. Hardcoded secrets — API keys, passwords, tokens in source
2. No tests for new functionality
3. Bare `except:` without re-raising
4. SQL string concatenation (injection risk)
5. Unvalidated user input used directly

For security-specific patterns, see `gco-secure-coding`.

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
- [ ] No anti-patterns (see table above)
- [ ] Documentation updated if needed
- [ ] Type annotations on public functions

## Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| **High** | Security risk or data loss potential | Must fix before merge |
| **Medium** | Maintainability or reliability issue | Should fix, can discuss |
| **Low** | Style or minor improvement | Optional, note for future |

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

### Summary
[Evidence-backed summary citing specific files and patterns checked]
```

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

## Questions This Skill Answers

- Should I approve this code for merge?
- What anti-patterns are present in this code?
- Is this code secure enough to merge?
- What severity level is this issue?
- Does this PR have adequate test coverage?
- What's the structured format for a code review?
- When should I BLOCK vs request changes?
- Is this code review finding high, medium, or low severity?
