---
last-verified: 2026-04-03
version: "1.0"
name: gco-code-patterns
description: >-
  Anti-pattern detection, error handling conventions, and code quality assessment with severity classification and AI-specific occurrence rates.
  Use when reviewing code, handling errors, detecting code smells, validating quality, or checking AI-generated code for common mistakes.
---

# Code Patterns: Anti-Patterns and Error Handling

## Vocabulary Payload

| Term | Definition | Use When |
|------|-----------|----------|
| guard clause | Early return that reduces nesting depth | Suggesting refactoring for deep nesting |
| early return | Exiting a function as soon as result is known | Reducing complexity |
| fail fast | Validate inputs at boundaries, reject invalid data immediately | Reviewing input handling |
| defensive copy | Copying mutable data to prevent aliasing bugs | Reviewing shared state |
| idempotent | Operation that produces same result regardless of repetition count | Reviewing retry logic, API endpoints |
| cyclomatic complexity | Count of independent paths through code | Assessing function complexity |
| single responsibility | A function/class does one thing well | Reviewing god functions |
| test isolation | Tests don't depend on each other or shared state | Reviewing test quality |
| dead code | Unreachable code that adds maintenance burden | Reviewing for cleanup |
| feature envy | Function that uses another class's data more than its own | Reviewing object boundaries |

## Core Anti-Patterns

| Pattern | Problem | Fix | Severity |
|---------|---------|-----|----------|
| Silent fallback | `.get(x, 0)` hides missing data | Validate required fields explicitly | HIGH |
| God function | 200+ lines, multiple responsibilities | Split into focused functions | MEDIUM |
| Magic numbers | `if x > 86400` unclear intent | `SECONDS_PER_DAY = 86400` | LOW |
| Catch-all | `except Exception` swallows errors | Catch specific types only | HIGH |
| Single-letter vars | `for x in y` unreadable | Descriptive names | LOW |
| Deep nesting | 4+ indent levels | Early returns, guard clauses | MEDIUM |
| Copy-paste code | Duplicated logic | Extract to shared function | MEDIUM |
| Commented-out code | Clutter in production | Delete (git has history) | LOW |
| Hardcoded secrets | API keys in source | Load from env vars | CRITICAL |
| SQL concatenation | `f"WHERE id={id}"` injection risk | Parameterized queries | CRITICAL |
| No error handling | I/O without try/except | Add error handling | HIGH |
| N+1 queries | Loop with DB call | JOINs or eager loading | MEDIUM |

## AI Anti-Patterns (Top 10 by Occurrence)

| Pattern | Occurrence in AI Code | Severity |
|---------|----------------------|----------|
| Missing Error Handling | 62% | HIGH |
| Missing Edge Case Validation | 60-75% | MEDIUM-HIGH |
| Missing Logging/Observability | 70-80% | MEDIUM |
| Magic Numbers | 50-60% | LOW |
| Silent Fallbacks | 45-60% | HIGH |
| Hardcoded Secrets | 40-45% | CRITICAL |
| Catch-All Exceptions | 40-50% | HIGH |
| SQL Injection | 30-40% | CRITICAL |
| God Functions | 30-40% | MEDIUM |
| N+1 Query Problems | 25-35% | MEDIUM |

## Error Handling Essentials

**Do:** Fail fast, be explicit, provide context, log appropriately, use typed errors
**Don't:** Silent fallbacks, catch-all handlers, generic messages, expose internals, ignore errors

## Quick Rejection Triggers

1. Hardcoded secrets (keys, passwords, tokens)
2. No error handling on I/O operations
3. Bare except/catch without re-raise
4. SQL string concatenation with user input
5. Unvalidated user input in queries
6. Functions over 100 lines
7. Global mutable state

## Consultation Gates

For detailed examples and language-specific patterns, READ reference files:
- `references/language-patterns.md` — Python, JS/TS, Go error handling
- `references/ai-antipatterns.md` — Detection triggers and fixes

## Questions This Skill Answers

- Is this a code smell or anti-pattern?
- What anti-pattern is this code exhibiting?
- How do I fix this error handling?
- What severity is this code quality issue?
- What are the most common AI-generated code mistakes?
- Should this function be split up?
- Is this error handling adequate?
- What's the right way to handle this edge case?
- How prevalent is this anti-pattern in AI-generated code?
