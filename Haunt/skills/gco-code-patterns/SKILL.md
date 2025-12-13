---
name: gco-code-patterns
description: Anti-pattern detection and error handling conventions for code quality. Invoke when reviewing code, handling errors, validating quality, or checking for common coding mistakes. Triggers on "error handling", "anti-pattern", "code quality", "code smell", "bad practice", or quality validation requests.
---

# Code Patterns: Anti-Patterns and Error Handling

Comprehensive guide for identifying problematic code patterns and implementing proper error handling across languages.

## When to Invoke

- Reviewing code for quality issues
- Writing error handling logic
- Detecting code smells or anti-patterns
- Validating code before merge
- Refactoring problematic code
- Teaching best practices

## Anti-Patterns to Reject

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

## Error Handling: WRONG vs RIGHT

### Python

#### WRONG: Silent Fallback
```python
# Hides missing required data
value = data.get("amount", 0)
user_id = request.args.get("user_id", "unknown")
```

#### RIGHT: Explicit Validation
```python
# Makes requirements clear, fails fast
if "amount" not in data:
    raise ValidationError("amount is required")
value = data["amount"]

user_id = request.args.get("user_id")
if not user_id:
    raise BadRequest("user_id parameter is required")
```

#### WRONG: Catch-All Exception
```python
# Swallows all errors, including programmer mistakes
try:
    result = risky_operation()
except Exception:
    result = None
```

#### RIGHT: Specific Exception Handling
```python
# Only catches expected errors
try:
    result = risky_operation()
except (NetworkError, TimeoutError) as e:
    logger.error(f"Operation failed: {e}")
    raise ServiceUnavailable("External service unreachable")
```

### JavaScript/TypeScript

#### WRONG: Truthy/Falsy Confusion
```javascript
// Treats 0, "", false as missing
if (userInput) {
    process(userInput);
}
```

#### RIGHT: Explicit Checks
```javascript
// Clear about what's required
if (userInput !== null && userInput !== undefined) {
    process(userInput);
}
// Or for strings specifically:
if (typeof userInput === 'string' && userInput.length > 0) {
    process(userInput);
}
```

#### WRONG: Silent Error Swallowing
```javascript
// Errors disappear silently
fetch('/api/data')
    .then(res => res.json())
    .catch(() => {});
```

#### RIGHT: Proper Error Handling
```javascript
// Errors are logged and handled
fetch('/api/data')
    .then(res => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
    })
    .catch(err => {
        console.error('Fetch failed:', err);
        throw new ServiceError('Unable to load data');
    });
```

### Go

#### WRONG: Ignoring Errors
```go
// Silently ignores potential failures
data, _ := ioutil.ReadFile("config.json")
```

#### RIGHT: Explicit Error Handling
```go
// Handles or propagates errors
data, err := ioutil.ReadFile("config.json")
if err != nil {
    return fmt.Errorf("failed to read config: %w", err)
}
```

### General Rules

## Error Handling Do's

- **Fail fast** - Validate inputs at entry points
- **Be explicit** - Make requirements clear in code
- **Provide context** - Include relevant details in error messages
- **Log appropriately** - Error level for failures, warn for recoverable issues
- **Use types** - Let the type system catch mistakes (TypeScript, Go, typed Python)

## Error Handling Don'ts

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

## Language-Specific Patterns

### Python
- Use `raise` not `return None` for errors
- Prefer `dict["key"]` over `dict.get("key", default)` for required keys
- Type hints on public functions: `def process(data: dict[str, Any]) -> Result:`
- Context managers (`with`) for resource cleanup

### JavaScript/TypeScript
- Use `throw new Error()` not `return null/undefined` for errors
- Async functions always return Promise (even if void)
- `const` by default, `let` when reassignment needed, never `var`
- Null checks before property access: `user?.profile?.email`

### Go
- Always check `err != nil`
- Wrap errors with context: `fmt.Errorf("operation failed: %w", err)`
- Use `defer` for cleanup
- Return errors, don't panic (except for truly unrecoverable situations)

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

## Success Criteria

Code following these patterns will:
- Fail fast with clear error messages
- Be readable without comments
- Have no silent failure modes
- Use language idioms correctly
- Be maintainable by other developers
