---
name: gco-code-quality
description: Code quality refinement patterns and self-review checklists for iterative improvement. Use when performing code refinement passes or need guidance on quality improvements.
---

# Code Quality: Iterative Refinement Patterns

## Purpose

This skill provides detailed guidance for the iterative code refinement process, including self-review checklists, common improvement patterns, and examples for each refinement pass.

## When to Invoke

- Performing Pass 2 (Refinement) or Pass 3 (Enhancement) on code
- Need specific guidance on what to improve in each pass
- Reviewing code for quality issues before marking complete
- Stuck on how to improve "working but messy" code
- Teaching best practices for incremental improvement

## Refinement Pass Checklists

### Pass 1: Initial Implementation

**Goal:** Make it work.

**Checklist:**
- [ ] Functional requirements met
- [ ] Happy path implemented
- [ ] Basic tests written and passing
- [ ] Core acceptance criteria satisfied

**Common Issues to Accept (fix in Pass 2):**
- Hard-coded values and magic numbers
- Missing error handling
- Poor variable names
- Long functions
- Minimal test coverage

**When to Move to Pass 2:**
- All acceptance criteria functionally met
- Basic tests pass
- Ready to refine for quality

---

### Pass 2: Refinement

**Goal:** Make it right.

**Error Handling Checklist:**
- [ ] Try/except (or try/catch) around all I/O operations (file, network, database)
- [ ] Specific exception types caught (not `Exception` or `catch(e)` catch-all)
- [ ] Error messages include context (what failed, why it matters)
- [ ] Errors logged with appropriate level (error/warn)
- [ ] Errors propagated or handled gracefully (no silent swallowing)

**Constants & Validation Checklist:**
- [ ] All magic numbers replaced with named constants
- [ ] Constants grouped logically (e.g., `MIN_`, `MAX_`, `DEFAULT_` prefixes)
- [ ] Input validation explicit (check required fields, don't use `.get(key, default)`)
- [ ] Type checking added (isinstance, typeof, type hints)
- [ ] Range validation for numeric inputs (min/max bounds)

**Naming & Structure Checklist:**
- [ ] Variable names descriptive (no single letters except i, j, k in loops)
- [ ] Function names are verbs describing what they do
- [ ] Boolean variables named as questions (is_valid, has_permission, should_retry)
- [ ] Functions <50 lines (extract helpers if over)
- [ ] Functions do one thing (single responsibility)

**Cleanup Checklist:**
- [ ] No console.log, print, or debug statements
- [ ] No commented-out code (delete it, git preserves history)
- [ ] No TODO/FIXME without tracking (create REQ or remove)
- [ ] No unused imports or variables
- [ ] Consistent formatting (run formatter if available)

**When to Move to Pass 3:**
- All Pass 2 checklist items addressed
- Code is readable and maintainable
- Error handling comprehensive
- Ready for comprehensive testing

---

### Pass 3: Enhancement

**Goal:** Make it production-ready.

**Test Coverage Checklist:**
- [ ] Happy path tests exist (already from Pass 1)
- [ ] Edge case tests added:
  - Empty input (empty string, empty array, null)
  - Boundary values (0, max int, very large numbers)
  - Special characters in strings
  - Unexpected types
- [ ] Error case tests added:
  - Network failures
  - File not found
  - Permission denied
  - Invalid input formats
- [ ] Test independence verified (don't rely on order or shared state)
- [ ] Test coverage >80% for new code

**Security Checklist (if applicable):**
- [ ] User input sanitized (no SQL injection, XSS, command injection)
- [ ] Authentication/authorization checked
- [ ] Secrets not hardcoded (use env vars or config)
- [ ] Sensitive data not logged (passwords, tokens, PII)
- [ ] HTTPS used for external API calls
- [ ] Rate limiting considered for public endpoints

**Anti-Pattern Checklist:**
- [ ] No silent fallbacks on required data (`.get(key, default)` for required fields)
- [ ] No catch-all exception handlers (`except Exception`, `catch(e)`)
- [ ] No magic numbers without named constants
- [ ] No god functions (>100 lines, multiple responsibilities)
- [ ] No deep nesting (>3 levels of indent)
- [ ] No copy-paste code (extract to shared function)

**Logging Checklist:**
- [ ] Error conditions logged with context
- [ ] Important state transitions logged (not every line)
- [ ] Log levels appropriate (debug/info/warn/error)
- [ ] Sensitive data not logged
- [ ] Logs include correlation IDs (if applicable)

**When to Move to Pass 4 (optional):**
- All Pass 3 checklist items addressed
- For M/SPLIT requirements only
- Production-critical code requiring hardening
- Need observability, retry logic, circuit breakers

---

### Pass 4: Production Hardening (Optional)

**Goal:** Make it robust.

**Observability Checklist:**
- [ ] Correlation IDs added for request tracing
- [ ] Metrics emitted for key operations (latency, error rate, throughput)
- [ ] Structured logging used (JSON format, searchable fields)
- [ ] Debugging context included in logs

**Resilience Checklist:**
- [ ] Retry logic with exponential backoff for transient failures
- [ ] Circuit breaker pattern for failing external dependencies
- [ ] Timeouts configured for all external calls
- [ ] Graceful degradation when dependencies unavailable
- [ ] Bulkhead pattern to isolate failures

**Performance Checklist:**
- [ ] Performance acceptable under expected load
- [ ] Database queries optimized (indexes, no N+1 queries)
- [ ] Caching added where beneficial
- [ ] Resource cleanup (close connections, file handles)
- [ ] Memory leaks prevented (no unbounded growth)

---

## Common Improvement Patterns

### Pattern: Replace Magic Numbers

**Before (Pass 1):**
```python
if elapsed > 86400:
    expire_token()
```

**After (Pass 2):**
```python
SECONDS_PER_DAY = 86400

if elapsed > SECONDS_PER_DAY:
    expire_token()
```

---

### Pattern: Add Error Handling

**Before (Pass 1):**
```python
def load_config():
    data = json.load(open("config.json"))
    return data
```

**After (Pass 2):**
```python
def load_config():
    try:
        with open("config.json", "r") as f:
            return json.load(f)
    except FileNotFoundError:
        logger.error("Config file not found: config.json")
        raise ConfigurationError("Missing config.json")
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in config.json: {e}")
        raise ConfigurationError("Invalid config.json format")
```

---

### Pattern: Explicit Validation

**Before (Pass 1):**
```python
def process_user(data):
    user_id = data.get("user_id", "unknown")  # Silent fallback
    return api.fetch_user(user_id)
```

**After (Pass 2):**
```python
def process_user(data):
    if "user_id" not in data:
        raise ValidationError("user_id is required")

    user_id = data["user_id"]
    if not isinstance(user_id, str) or not user_id:
        raise ValidationError("user_id must be non-empty string")

    return api.fetch_user(user_id)
```

---

### Pattern: Extract Long Functions

**Before (Pass 1):**
```python
def handle_request(request):
    # 80 lines of validation, processing, DB queries, API calls, formatting...
```

**After (Pass 2):**
```python
def handle_request(request):
    validate_request(request)
    user = fetch_user(request.user_id)
    result = process_data(user, request.data)
    formatted = format_response(result)
    return formatted

def validate_request(request):
    # 15 lines of validation

def fetch_user(user_id):
    # 10 lines of DB query

def process_data(user, data):
    # 20 lines of business logic

def format_response(result):
    # 10 lines of formatting
```

---

### Pattern: Add Edge Case Tests

**Pass 1 Tests:**
```python
def test_calculate_total_happy_path():
    assert calculate_total([1, 2, 3]) == 6
```

**Pass 3 Tests (added):**
```python
def test_calculate_total_empty_input():
    assert calculate_total([]) == 0

def test_calculate_total_single_item():
    assert calculate_total([5]) == 5

def test_calculate_total_negative_numbers():
    assert calculate_total([-1, -2, -3]) == -6

def test_calculate_total_mixed_signs():
    assert calculate_total([1, -2, 3]) == 2

def test_calculate_total_invalid_input():
    with pytest.raises(TypeError):
        calculate_total(None)
```

---

### Pattern: Add Retry Logic (Pass 4)

**Before (Pass 2):**
```python
def call_external_api():
    try:
        return api.request()
    except NetworkError as e:
        logger.error(f"API call failed: {e}")
        raise
```

**After (Pass 4):**
```python
import time

MAX_RETRIES = 3
BASE_BACKOFF = 1  # seconds

def call_external_api():
    for attempt in range(MAX_RETRIES):
        try:
            logger.info(f"API call attempt {attempt + 1}/{MAX_RETRIES}")
            result = api.request()
            logger.info("API call successful")
            return result
        except NetworkError as e:
            if attempt == MAX_RETRIES - 1:
                logger.error(f"API call failed after {MAX_RETRIES} retries: {e}")
                raise ServiceUnavailable("External API unavailable")

            wait_time = BASE_BACKOFF * (2 ** attempt)  # Exponential backoff: 1s, 2s, 4s
            logger.warn(f"API call attempt {attempt + 1} failed, retrying in {wait_time}s: {e}")
            time.sleep(wait_time)
```

---

## Self-Review Questions by Pass

### Pass 1 Questions
- Does the code meet all stated functional requirements?
- Do the basic tests pass?
- Is the happy path working correctly?

### Pass 2 Questions
- What happens if this file doesn't exist?
- What happens if the network is down?
- What happens if the input is empty, null, or wrong type?
- Are there any hard-coded values that should be constants?
- Are the variable names clear enough for someone else to understand?
- Is this function trying to do too many things?

### Pass 3 Questions
- What edge cases am I not testing?
- What could fail that I'm not handling?
- Is this code vulnerable to any security issues?
- Am I repeating any anti-patterns from lessons-learned?
- Will this code be easy to debug in production?
- Is my test coverage comprehensive?

### Pass 4 Questions (M/SPLIT only)
- How will I debug this in production with logs?
- What happens if this external service goes down?
- How does this perform under high load?
- Can I add retry logic or circuit breakers?
- Do I need correlation IDs for tracing?

---

## Language-Specific Patterns

### Python

**Constants:**
```python
# Module-level constants in UPPER_CASE
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30
API_BASE_URL = "https://api.example.com"
```

**Error Handling:**
```python
# Catch specific exceptions
try:
    result = risky_operation()
except (NetworkError, TimeoutError) as e:
    logger.error(f"Operation failed: {e}")
    raise ServiceUnavailable("Service temporarily unavailable")
```

**Validation:**
```python
# Explicit validation
if not isinstance(user_id, int):
    raise TypeError(f"user_id must be int, got {type(user_id)}")
if user_id < 1:
    raise ValueError("user_id must be positive")
```

### JavaScript/TypeScript

**Constants:**
```javascript
// Constants in UPPER_CASE or camelCase
const MAX_RETRIES = 3;
const DEFAULT_TIMEOUT = 30000; // milliseconds
const API_BASE_URL = "https://api.example.com";
```

**Error Handling:**
```javascript
// Try/catch with specific error types
try {
    const result = await riskyOperation();
} catch (error) {
    if (error instanceof NetworkError) {
        logger.error(`Network error: ${error.message}`);
        throw new ServiceUnavailableError("Service temporarily unavailable");
    }
    throw error; // Re-throw unknown errors
}
```

**Validation:**
```javascript
// Explicit validation
if (typeof userId !== 'number') {
    throw new TypeError(`userId must be number, got ${typeof userId}`);
}
if (userId < 1) {
    throw new RangeError("userId must be positive");
}
```

---

## Anti-Pattern Examples

### Silent Fallback (WRONG)
```python
# Bad: Hides missing required data
amount = data.get("amount", 0)
user_id = data.get("user_id", "unknown")
```

**Fix (Pass 2):**
```python
# Good: Explicit validation
if "amount" not in data:
    raise ValidationError("amount is required")
amount = data["amount"]

if "user_id" not in data:
    raise ValidationError("user_id is required")
user_id = data["user_id"]
```

### Catch-All Exception (WRONG)
```python
# Bad: Swallows all errors, including programmer mistakes
try:
    result = process_data()
except Exception:
    result = None
```

**Fix (Pass 2):**
```python
# Good: Catch specific expected errors
try:
    result = process_data()
except (ValidationError, ProcessingError) as e:
    logger.error(f"Data processing failed: {e}")
    raise
```

### Magic Numbers (WRONG)
```python
# Bad: Unclear intent
if elapsed > 86400:
    expire_token()
if score > 100:
    award_bonus()
```

**Fix (Pass 2):**
```python
# Good: Named constants
SECONDS_PER_DAY = 86400
PERFECT_SCORE = 100

if elapsed > SECONDS_PER_DAY:
    expire_token()
if score > PERFECT_SCORE:
    award_bonus()
```

---

## Success Criteria

Code is ready for completion when:

**After Pass 2:**
- Error handling comprehensive
- Constants replace all magic numbers
- Validation explicit (no silent fallbacks)
- Naming clear and descriptive
- Functions focused (<50 lines)
- No debugging code left

**After Pass 3:**
- Test coverage >80%
- Edge cases and error cases tested
- Security review complete (if applicable)
- No anti-patterns from lessons-learned
- Logging added for errors
- Ready for production deployment

**After Pass 4 (optional):**
- Observability in place (correlation IDs, metrics)
- Retry logic with exponential backoff
- Circuit breakers for external dependencies
- Performance verified under load
- Graceful degradation tested
