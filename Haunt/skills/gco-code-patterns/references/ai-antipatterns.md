# AI-Specific Anti-Patterns (2025 Research)

Based on industry research from 2025, AI-generated code exhibits specific anti-patterns with measurable occurrence rates. Use this reference when reviewing AI-assisted code.

## Top 10 AI Code Anti-Patterns (by Occurrence Rate)

**Source:** REQ-255 research - Veracode, CodeRabbit, Endor Labs studies

| Pattern | Occurrence | Severity | Auto-Detectable |
|---------|------------|----------|-----------------|
| 1. Missing Error Handling | 62% | HIGH | Yes (AST: no try/except on I/O) |
| 2. Missing Edge Case Validation | 60-75% | MEDIUM | Yes (check for null/empty handling) |
| 3. Missing Logging/Observability | 70-80% | MEDIUM | Yes (no logger calls) |
| 4. Magic Numbers | 50-60% | LOW | Yes (literal numbers in code) |
| 5. Silent Fallbacks | 45-60% | HIGH | Yes (`.get(key, default)` pattern) |
| 6. Hardcoded Secrets | 40-45% | CRITICAL | Yes (regex for keys/passwords) |
| 7. Catch-All Exceptions | 40-50% | HIGH | Yes (`except Exception`) |
| 8. SQL Injection | 30-40% | CRITICAL | Yes (string concat in queries) |
| 9. God Functions | 30-40% | MEDIUM | Yes (line count >100) |
| 10. N+1 Query Problems | 25-35% | MEDIUM | Yes (query in loop) |

---

## 1. Missing Error Handling (62% Occurrence)

**Detection:** Check if I/O operations (file, network, database) are wrapped in try/except.

**Pattern:**
```python
# ANTI-PATTERN
def fetch_user(user_id):
    response = requests.get(f"/api/users/{user_id}")
    return response.json()
```

**Detection Trigger:**
- `requests.get|post|put|delete` without `try`
- `open()` without `try` or context manager
- `db.execute` without `try`

**Severity:** HIGH - Unhandled exceptions crash applications

**Fix:**
```python
def fetch_user(user_id):
    if not user_id:
        raise ValueError("user_id is required")

    try:
        response = requests.get(f"/api/users/{user_id}", timeout=5)
        response.raise_for_status()
        return response.json()
    except requests.Timeout:
        logger.error(f"Timeout fetching user {user_id}")
        raise ServiceUnavailable("User service timeout")
    except requests.HTTPError as e:
        logger.error(f"HTTP error: {e}")
        raise
```

---

## 2. Missing Edge Case Validation (60-75% Occurrence)

**Detection:** Check if function validates null/empty/boundary inputs.

**Pattern:**
```javascript
function calculateDiscount(price, percentage) {
    return price * (percentage / 100);  // No validation!
}
```

**Detection Trigger:**
- Function accepts parameters but no validation before use
- No checks for null, undefined, empty, or type

**Severity:** MEDIUM-HIGH - Causes runtime errors on edge cases

**Fix:**
```javascript
function calculateDiscount(price, percentage) {
    if (typeof price !== 'number' || typeof percentage !== 'number') {
        throw new TypeError('price and percentage must be numbers');
    }
    if (price < 0) {
        throw new RangeError('price must be non-negative');
    }
    if (percentage < 0 || percentage > 100) {
        throw new RangeError('percentage must be 0-100');
    }
    return price * (percentage / 100);
}
```

---

## 3. Missing Logging/Observability (70-80% Occurrence)

**Detection:** Check if production code includes logging for errors and key operations.

**Pattern:**
```python
# ANTI-PATTERN
def process_payment(payment_data):
    result = payment_api.charge(payment_data['amount'])
    return result  # No logging!
```

**Detection Trigger:**
- Functions with I/O operations but no logger calls
- Error handlers without logging
- Production code without observability

**Severity:** MEDIUM - Makes debugging production issues difficult

**Fix:**
```python
import logging
logger = logging.getLogger(__name__)

def process_payment(payment_data, correlation_id=None):
    logger.info("Processing payment", extra={"amount": payment_data['amount'], "correlation_id": correlation_id})

    try:
        result = payment_api.charge(payment_data['amount'])
        logger.info("Payment successful", extra={"transaction_id": result.id, "correlation_id": correlation_id})
        return result
    except PaymentError as e:
        logger.error("Payment failed", extra={"error": str(e), "correlation_id": correlation_id}, exc_info=True)
        raise
```

---

## 4. Hardcoded Secrets (40-45% Occurrence)

**Detection:** Check for API keys, passwords, database URLs in source code.

**Pattern:**
```python
# ANTI-PATTERN
API_KEY = "sk-1234567890abcdef"
DATABASE_URL = "postgresql://user:pass@localhost/db"
```

**Detection Trigger (Regex):**
- `api[_-]?key\s*=\s*["\'][^"\']+["\']` (case-insensitive)
- `password\s*=\s*["\'][^"\']+["\']`
- `secret\s*=\s*["\'][^"\']+["\']`
- `postgresql://.*:.*@` (DB URL with credentials)

**Severity:** CRITICAL - Security vulnerability, credentials exposed

**Fix:**
```python
import os

API_KEY = os.environ.get("API_KEY")
if not API_KEY:
    raise EnvironmentError("API_KEY environment variable not set")

DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
    raise EnvironmentError("DATABASE_URL not set")
```

---

## 5. SQL Injection (30-40% Occurrence)

**Detection:** Check for string concatenation or f-strings in SQL queries.

**Pattern:**
```python
# ANTI-PATTERN - SQL Injection vulnerability
query = f"SELECT * FROM users WHERE username = '{username}'"
db.execute(query)
```

**Detection Trigger:**
- SQL keywords (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) with f-strings or string concatenation
- `WHERE.*{` or `WHERE.*+` patterns in SQL

**Severity:** CRITICAL - Security vulnerability

**Fix:**
```python
# Parameterized query
query = "SELECT * FROM users WHERE username = ?"
db.execute(query, (username,))
```

---

## 6. N+1 Query Problems (25-35% Occurrence)

**Detection:** Check for database queries inside loops.

**Pattern:**
```python
# ANTI-PATTERN - N+1 queries
users = User.query.all()  # Query 1
for user in users:
    user.posts = Post.query.filter_by(user_id=user.id).all()  # N queries!
```

**Detection Trigger:**
- Query inside `for` loop
- `.query` or `.filter` inside loop iteration

**Severity:** MEDIUM - Performance issue, scalability problem

**Fix:**
```python
# Single query with JOIN
users = User.query.options(joinedload(User.posts)).all()
```

---

## 7. Over-Specification (80-90% Occurrence in AI Code)

**Description:** AI creates narrow solutions with hardcoded assumptions instead of reusable implementations.

**Pattern:**
```python
# ANTI-PATTERN - Over-specified
def calculate_product_discount(product_price):
    if product_price > 100:  # Hardcoded threshold
        return product_price * 0.10  # Hardcoded 10%
    return 0
```

**Detection Trigger:**
- Hardcoded business logic thresholds
- Function names overly specific
- No configuration or parameterization

**Severity:** LOW - Technical debt, reduces reusability

**Fix:**
```python
# REUSABLE
def calculate_discount(price, threshold=100, discount_rate=0.10):
    """Calculate discount if price exceeds threshold."""
    if price > threshold:
        return price * discount_rate
    return 0
```

---

## 8. Avoidance of Refactors (80-90% Occurrence in AI Code)

**Description:** AI stops at "good enough" without restructuring, leading to growing technical debt.

**Pattern:**
- AI adds new functionality without refactoring existing code
- Leaves duplicated logic instead of extracting
- Doesn't suggest architectural improvements

**Detection Trigger:**
- Similar code blocks in multiple locations
- Functions growing beyond 50 lines without extraction
- Classes with >10 methods doing similar things

**Severity:** MEDIUM - Accumulates technical debt over time

**Mitigation:** Explicitly request refactoring: "Extract this duplicated logic into a shared function" or "Simplify this conditional structure"

---

## 9. Comments Everywhere (90-100% Occurrence in AI Code)

**Description:** AI fills code with redundant comments, often as internal context markers.

**Pattern:**
```python
# ANTI-PATTERN - Redundant comments
# Create a new user
user = User()
# Set the user name
user.name = name
# Set the user email
user.email = email
# Save the user to database
user.save()
```

**Detection Trigger:**
- Comments that repeat the code
- Comments on every line or every statement
- Comments explaining obvious operations

**Severity:** LOW - Clutter, reduces readability

**Fix:**
```python
# CLEAN - Comments explain WHY, not WHAT
# User auto-activation bypassed for enterprise accounts
user = User(name=name, email=email, auto_activate=False)
user.save()
```

---

## 10. Brittle Tests (AI Testing Anti-Pattern)

**Description:** AI-generated tests break on refactoring even when behavior unchanged.

**Pattern:**
```javascript
// ANTI-PATTERN - Tests implementation, not behavior
test('user login', () => {
    const mockStore = { dispatch: jest.fn() };
    wrapper.find('.login-button').simulate('click');

    // Breaks if action creator changes
    expect(mockStore.dispatch).toHaveBeenCalledWith({
        type: 'LOGIN_REQUEST',
        payload: { username: 'test', password: 'pass' }
    });
});
```

**Detection Trigger:**
- Tests asserting on internal state or private methods
- Tests verifying implementation details (action types, mock calls)
- Tests using CSS selectors instead of accessible names

**Severity:** MEDIUM - False positive test failures, maintenance burden

**Fix:**
```javascript
// ROBUST - Tests behavior
test('user can log in with valid credentials', async () => {
    render(<Login />);

    await userEvent.type(screen.getByLabelText('Username'), 'test');
    await userEvent.type(screen.getByLabelText('Password'), 'pass');
    await userEvent.click(screen.getByRole('button', { name: 'Log in' }));

    // Tests outcome, not implementation
    expect(await screen.findByText('Welcome, test')).toBeInTheDocument();
});
```

---

## AI Code Review Quick Checklist

When reviewing AI-generated code, check for these top issues:

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

---

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

---

## When to Consult This Reference

Read this file when:
- Reviewing AI-generated code for common anti-patterns
- Implementing automated code review checks
- Teaching AI code quality best practices
- Debugging production issues caused by AI code patterns
- Setting up linting rules for AI-assisted development

---

## See Also

- `.haunt/docs/lessons-learned.md` - AI Code Anti-Patterns section (examples and prevention)
- `.haunt/docs/research/req-255-ai-coding-best-practices.md` - Full research report with 25 sources
- `Haunt/skills/gco-code-quality/SKILL.md` - Iterative refinement patterns for fixing these issues
- `Haunt/agents/gco-dev.md` - Iterative Code Refinement Protocol (systematic quality improvement)
