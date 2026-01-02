---
name: gco-code-patterns
description: Anti-pattern detection and error handling conventions for code quality. Invoke when reviewing code, handling errors, validating quality, or checking for common coding mistakes. Triggers on "error handling", "anti-pattern", "code quality", "code smell", "bad practice", or quality validation requests.
---

# Code Patterns: Anti-Patterns and Error Handling

Quick reference for identifying problematic code patterns and implementing proper error handling. For detailed examples and language-specific guidance, see reference files.

## When to Invoke

- Reviewing code for quality issues
- Writing error handling logic
- Detecting code smells or anti-patterns
- Validating code before merge
- Refactoring problematic code
- Teaching best practices
- Reviewing AI-generated code

## Core Anti-Patterns (Quick Reference)

| Pattern | Example | Why Bad | Fix |
|---------|---------|---------|-----|
| Silent fallback | `.get(x, 0)` without validation | Hides missing data, masks bugs | Validate required fields explicitly before use |
| God function | 200+ line function with multiple responsibilities | Unmaintainable, untestable, hard to debug | Split into focused, single-purpose functions |
| Magic numbers | `if elapsed > 86400` | Unclear intent, hard to maintain | `SECONDS_PER_DAY = 86400; if elapsed > SECONDS_PER_DAY` |
| Catch-all | `except Exception` or `catch (e)` | Swallows errors, hides bugs | Catch specific exception types only |
| Single-letter vars | `for x in y: z = x * 2` | Unreadable, unclear purpose | Use descriptive names: `for item in items: doubled = item * 2` |
| Deep nesting | 4+ indent levels | Hard to follow, cognitive overload | Early returns, extract helper functions, guard clauses |
| Copy-paste code | Duplicated logic blocks | Maintenance burden, bug propagation | Extract to shared function or class |
| Commented-out code | `# old_function()` in production | Clutter, confusion about intent | Delete it (git preserves history) |

## Reference Index

| When You Need | Read This |
|---------------|-----------|
| **Language-specific error handling** (Python, JS/TS, Go examples) | `references/language-patterns.md` |
| **AI anti-pattern detection** (10 common AI mistakes with fixes) | `references/ai-antipatterns.md` |

## Consultation Gates

⛔ **CONSULTATION GATE:** When implementing error handling in **Python, JavaScript/TypeScript, or Go**, READ `references/language-patterns.md` for detailed examples and best practices.

⛔ **CONSULTATION GATE:** When reviewing **AI-generated code**, READ `references/ai-antipatterns.md` for the top 10 AI anti-patterns (62-90% occurrence rates).

## Error Handling Essentials

### Do's
- **Fail fast** - Validate inputs at entry points
- **Be explicit** - Make requirements clear in code
- **Provide context** - Include relevant details in error messages
- **Log appropriately** - Error level for failures, warn for recoverable issues
- **Use types** - Let the type system catch mistakes (TypeScript, Go, typed Python)

### Don'ts
- **Silent fallbacks** - Never use defaults for required data
- **Catch-all handlers** - Don't swallow unexpected errors
- **Generic messages** - Avoid "Something went wrong"
- **Exposing internals** - Don't leak stack traces to users
- **Ignoring errors** - Always handle or propagate errors

## Code Quality Checks

Before committing code, verify:

- [ ] No silent fallbacks on required fields
- [ ] Specific exception/error types caught
- [ ] Error messages provide actionable context
- [ ] Functions under 50 lines (ideally under 30)
- [ ] No magic numbers (use named constants)
- [ ] Descriptive variable names (no single letters except loop indices)
- [ ] Maximum 3 levels of nesting
- [ ] No commented-out code blocks
- [ ] No duplicated logic (DRY principle)

## Quick Rejection Triggers

Immediately flag code with:

1. **Hardcoded secrets** - API keys, passwords, tokens
2. **No error handling** on I/O operations
3. **Bare except/catch** without re-raising
4. **SQL string concatenation** (injection risk)
5. **Unvalidated user input** used in queries or commands
6. **Functions over 100 lines** without clear separation
7. **Global mutable state** modified from multiple places

## Example: Before and After

### Before (Multiple Anti-Patterns)
```python
def process(d):
    x = d.get('id', 0)  # Silent fallback
    if x > 100:  # Magic number
        try:
            result = api.call(x)
        except:  # Catch-all
            result = None
    return result
```

### After (Corrected)
```python
MAX_ID_THRESHOLD = 100

def process_user_data(data: dict[str, Any]) -> UserResult:
    """Process user data with ID validation."""
    if 'id' not in data:
        raise ValidationError("id field is required")

    user_id = data['id']
    if user_id > MAX_ID_THRESHOLD:
        try:
            return api.call_user_endpoint(user_id)
        except (NetworkError, TimeoutError) as e:
            logger.error(f"API call failed for user {user_id}: {e}")
            raise ServiceUnavailable(f"Unable to process user {user_id}")

    raise ValidationError(f"User ID {user_id} below threshold")
```

## AI Anti-Patterns (Quick Checklist)

**Top 10 AI Code Anti-Patterns** (from 2025 research):

| Pattern | Occurrence | Severity |
|---------|------------|----------|
| 1. Missing Error Handling | 62% | HIGH |
| 2. Missing Edge Case Validation | 60-75% | MEDIUM-HIGH |
| 3. Missing Logging/Observability | 70-80% | MEDIUM |
| 4. Magic Numbers | 50-60% | LOW |
| 5. Silent Fallbacks | 45-60% | HIGH |
| 6. Hardcoded Secrets | 40-45% | CRITICAL |
| 7. Catch-All Exceptions | 40-50% | HIGH |
| 8. SQL Injection | 30-40% | CRITICAL |
| 9. God Functions | 30-40% | MEDIUM |
| 10. N+1 Query Problems | 25-35% | MEDIUM |

⛔ **CONSULTATION GATE:** For detailed detection triggers and fixes for each pattern, READ `references/ai-antipatterns.md`.

### AI Code Review Quick Checklist

When reviewing AI-generated code, check for:

**Security (CRITICAL):**
- [ ] No hardcoded API keys, passwords, or tokens
- [ ] SQL queries use parameterization (no string concatenation)
- [ ] User input sanitized before use
- [ ] Secrets loaded from environment variables

**Error Handling (HIGH):**
- [ ] Try/except around all I/O operations
- [ ] Specific exception types (no `except Exception`)
- [ ] Error messages include context
- [ ] Errors logged appropriately

**Validation (HIGH):**
- [ ] Required fields validated explicitly (no `.get(key, default)`)
- [ ] Null/empty/type checking before use
- [ ] Boundary value validation (min/max)

**Performance (MEDIUM):**
- [ ] No N+1 query problems (use JOINs or eager loading)
- [ ] No inefficient algorithms (check Big-O)
- [ ] Resource cleanup (close connections, files)

**Quality (LOW-MEDIUM):**
- [ ] No magic numbers (use named constants)
- [ ] Functions <50 lines (extract if longer)
- [ ] Descriptive naming (no single letters)
- [ ] No commented-out code
- [ ] No redundant comments

**Testing (MEDIUM):**
- [ ] Tests exist for new functionality
- [ ] Tests cover edge cases (empty, null, boundary)
- [ ] Tests validate behavior, not implementation
- [ ] Tests are independent (no shared state)

## Quick Rejection Triggers (AI Code)

Immediately flag code if you find:

1. **Hardcoded secrets** - API keys, passwords, tokens in source
2. **SQL string concatenation** - `f"SELECT * FROM users WHERE id = {id}"`
3. **Bare except clause** - `except:` or `except Exception:` without re-raise
4. **No error handling on I/O** - requests, file operations, DB queries without try/except
5. **Silent fallbacks on required data** - `.get("required_field", default_value)`
6. **Functions >100 lines** - God functions with multiple responsibilities
7. **No tests for new functionality** - Code without corresponding test coverage
8. **Unvalidated user input** - Used in queries/commands without validation

These patterns occur in 30-80% of AI-generated code and should be caught in code review.

## Success Criteria

Code following these patterns will:
- Fail fast with clear error messages
- Be readable without comments
- Have no silent failure modes
- Use language idioms correctly
- Be maintainable by other developers

## See Also

- `references/language-patterns.md` - Language-specific error handling examples (Python, JS/TS, Go)
- `references/ai-antipatterns.md` - Top 10 AI anti-patterns with detection triggers and fixes
- `.haunt/docs/lessons-learned.md` - AI Code Anti-Patterns section (project-specific examples)
- `.haunt/docs/research/req-255-ai-coding-best-practices.md` - Full research report with 25 sources
- `Haunt/skills/gco-code-quality/SKILL.md` - Iterative refinement patterns for fixing these issues
- `Haunt/agents/gco-dev.md` - Iterative Code Refinement Protocol (systematic quality improvement)
