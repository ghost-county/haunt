# Language-Specific Error Handling Patterns

## Purpose

Detailed error handling patterns and examples for Python, JavaScript/TypeScript, and Go. Use this reference when implementing error handling in language-specific code.

## Python

### WRONG: Silent Fallback
```python
# Hides missing required data
value = data.get("amount", 0)
user_id = request.args.get("user_id", "unknown")
```

### RIGHT: Explicit Validation
```python
# Makes requirements clear, fails fast
if "amount" not in data:
    raise ValidationError("amount is required")
value = data["amount"]

user_id = request.args.get("user_id")
if not user_id:
    raise BadRequest("user_id parameter is required")
```

### WRONG: Catch-All Exception
```python
# Swallows all errors, including programmer mistakes
try:
    result = risky_operation()
except Exception:
    result = None
```

### RIGHT: Specific Exception Handling
```python
# Only catches expected errors
try:
    result = risky_operation()
except (NetworkError, TimeoutError) as e:
    logger.error(f"Operation failed: {e}")
    raise ServiceUnavailable("External service unreachable")
```

### Python Best Practices
- Use `raise` not `return None` for errors
- Prefer `dict["key"]` over `dict.get("key", default)` for required keys
- Type hints on public functions: `def process(data: dict[str, Any]) -> Result:`
- Context managers (`with`) for resource cleanup

---

## JavaScript/TypeScript

### WRONG: Truthy/Falsy Confusion
```javascript
// Treats 0, "", false as missing
if (userInput) {
    process(userInput);
}
```

### RIGHT: Explicit Checks
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

### WRONG: Silent Error Swallowing
```javascript
// Errors disappear silently
fetch('/api/data')
    .then(res => res.json())
    .catch(() => {});
```

### RIGHT: Proper Error Handling
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

### JavaScript/TypeScript Best Practices
- Use `throw new Error()` not `return null/undefined` for errors
- Async functions always return Promise (even if void)
- `const` by default, `let` when reassignment needed, never `var`
- Null checks before property access: `user?.profile?.email`

---

## Go

### WRONG: Ignoring Errors
```go
// Silently ignores potential failures
data, _ := ioutil.ReadFile("config.json")
```

### RIGHT: Explicit Error Handling
```go
// Handles or propagates errors
data, err := ioutil.ReadFile("config.json")
if err != nil {
    return fmt.Errorf("failed to read config: %w", err)
}
```

### Go Best Practices
- Always check `err != nil`
- Wrap errors with context: `fmt.Errorf("operation failed: %w", err)`
- Use `defer` for cleanup
- Return errors, don't panic (except for truly unrecoverable situations)

---

## Error Handling General Rules

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

---

## Complete Example: Before and After

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

---

## When to Consult This Reference

Read this file when:
- Implementing error handling in Python, JavaScript/TypeScript, or Go
- Reviewing code for language-specific error handling issues
- Teaching or documenting error handling patterns
- Fixing anti-patterns identified in code review
