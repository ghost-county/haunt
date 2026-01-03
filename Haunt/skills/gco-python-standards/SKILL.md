---
name: gco-python-standards
description: Python coding standards and pytest testing patterns. Invoke when working on .py files, implementing Python modules, or writing pytest tests.
---

# Python Standards

Comprehensive Python coding standards and testing patterns based on PEP 8, modern Python idioms, and pytest best practices.

## When to Invoke

- Writing Python code (.py files)
- Implementing Python modules or packages
- Writing pytest tests
- Refactoring Python code for quality
- Deciding testing strategy (fixtures, mocking, parametrization)

## Core Principle

**Explicit over implicit. Readability over cleverness. One obvious way.**

Python emphasizes:
- **Clarity:** Code should be self-documenting
- **Simplicity:** Prefer simple solutions over complex ones
- **Explicitness:** Make assumptions and requirements clear
- **Consistency:** Follow conventions (PEP 8)

## Anti-Patterns (Never Do This)

| Anti-Pattern | Problem | Fix | Impact |
|--------------|---------|-----|--------|
| `def func(x, lst=[])` | Mutable defaults shared across calls | `lst=None; lst = lst or []` | HIGH - causes subtle bugs |
| `from module import *` | Namespace pollution, unclear origins | `import module` or specific imports | MEDIUM - maintainability |
| `if attr == True:` | Verbose, non-Pythonic | `if attr:` | LOW - style |
| `for i in range(len(items)):` | Index noise | `for i, item in enumerate(items):` | LOW - readability |
| Modify list while iterating | Skips/errors in iteration | New list via comprehension | HIGH - logic errors |
| Bare `except:` | Swallows all errors, hides bugs | Catch specific exceptions | CRITICAL - debugging |
| `if type(x) == int:` | Breaks inheritance | `if isinstance(x, int):` | MEDIUM - type checking |

### Detailed Examples

#### Mutable Default Arguments (HIGH SEVERITY)

```python
# WRONG - Default list shared across all calls
def append_to_list(item, lst=[]):
    lst.append(item)
    return lst

# Bug: Second call has item from first call
print(append_to_list(1))  # [1]
print(append_to_list(2))  # [1, 2]  ← UNEXPECTED!

# RIGHT - None default with initialization
def append_to_list(item, lst=None):
    if lst is None:
        lst = []
    lst.append(item)
    return lst

# OR using OR operator
def append_to_list(item, lst=None):
    lst = lst or []
    lst.append(item)
    return lst
```

#### Wildcard Imports

```python
# WRONG - Unclear where functions come from
from utils import *

result = process_data(x)  # Which module is process_data from?

# RIGHT - Explicit imports
from utils import process_data, validate_input

result = process_data(x)  # Clearly from utils
```

#### Modifying List While Iterating

```python
# WRONG - Skips items or raises errors
numbers = [1, 2, 3, 4, 5]
for num in numbers:
    if num % 2 == 0:
        numbers.remove(num)  # Modifies list during iteration!

# RIGHT - Create new list
numbers = [1, 2, 3, 4, 5]
numbers = [num for num in numbers if num % 2 != 0]

# OR use filter
numbers = [1, 2, 3, 4, 5]
numbers = list(filter(lambda x: x % 2 != 0, numbers))
```

## PEP 8 Essentials

### Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| **Functions** | snake_case | `def calculate_total():` |
| **Classes** | PascalCase | `class UserAccount:` |
| **Constants** | UPPER_CASE | `MAX_RETRIES = 3` |
| **Private** | _leading_underscore | `def _internal_helper():` |
| **Modules** | snake_case | `user_service.py` |
| **Packages** | short lowercase | `mypackage/` |

### Formatting

```python
# Indentation: 4 spaces (NEVER tabs)
def function():
    if condition:
        do_something()

# Line length: 79 characters for code, 72 for comments
# Break long lines with backslash or parentheses
result = some_function(argument1, argument2,
                       argument3, argument4)

# Imports: stdlib → third-party → local (alphabetical within)
import os
import sys

import requests
import pytest

from myapp.utils import helper
from myapp.models import User

# Whitespace: No space before function call
func(arg)      # CORRECT
func (arg)     # WRONG

# Binary operators: Space around =, ==, +, -, etc.
x = 5          # CORRECT
x=5            # WRONG

# Blank lines: 2 between top-level, 1 between methods
class MyClass:
    def method_one(self):
        pass

    def method_two(self):
        pass


class AnotherClass:
    pass
```

### Docstrings

```python
def calculate_total(items: list[dict], tax_rate: float) -> float:
    """Calculate total price including tax.

    Args:
        items: List of item dicts with 'price' key
        tax_rate: Tax rate as decimal (e.g., 0.08 for 8%)

    Returns:
        Total price with tax applied

    Raises:
        ValueError: If items empty or tax_rate negative
    """
    if not items or tax_rate < 0:
        raise ValueError("Invalid input")

    subtotal = sum(item['price'] for item in items)
    return subtotal * (1 + tax_rate)
```

## Type Hints (Python 3.10+)

### When to Use Type Hints

**REQUIRED:**
- Public APIs (library/module interfaces)
- Complex transformations (multi-step data processing)
- Framework integration (FastAPI, Pydantic models)

**OPTIONAL:**
- Private functions (if helpful for clarity)
- Simple utility functions (if types are obvious)

### Modern Syntax (Python 3.10+)

```python
# Union types with |
def process(data: str | bytes) -> dict[str, int] | None:
    if isinstance(data, str):
        return {"length": len(data)}
    elif isinstance(data, bytes):
        return {"size": len(data)}
    return None

# Generic types (no typing.List, typing.Dict)
def filter_items(items: list[str], pattern: str) -> list[str]:
    return [item for item in items if pattern in item]

# TypedDict for structured data
from typing import TypedDict

class User(TypedDict):
    name: str
    email: str
    age: int

def create_user(name: str, email: str, age: int) -> User:
    return {"name": name, "email": email, "age": age}
```

### Type Checking with mypy

```bash
# Install mypy
pip install mypy

# Run type checker (configure in pyproject.toml)
mypy --strict src/

# Configuration
# pyproject.toml
[tool.mypy]
python_version = "3.10"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true  # Require type hints on all functions
```

## Pytest Essentials

### Fixture Scopes

| Scope | Lifecycle | Use Case | Performance |
|-------|-----------|----------|-------------|
| `function` (default) | Per test | Isolated state, fresh data | High setup cost |
| `class` | Per test class | Shared across related tests | Medium cost |
| `module` | Per file | Expensive resources (DB connection) | Low cost |
| `session` | Entire test run | Global resources (test server) | Minimal cost |

**Principle:** Use broader scopes for expensive setup, ensure proper isolation via transaction rollback.

### Fixture Patterns

#### Basic Fixture

```python
import pytest

@pytest.fixture
def sample_user():
    """Provide sample user for tests."""
    return {
        "name": "Alice",
        "email": "alice@example.com",
        "age": 30
    }

def test_user_name(sample_user):
    assert sample_user["name"] == "Alice"
```

#### Fixture with Setup/Teardown

```python
@pytest.fixture
def database():
    """Provide database connection with cleanup."""
    db = create_database()
    yield db  # Test runs here
    db.close()  # Cleanup after test

def test_query(database):
    result = database.query("SELECT 1")
    assert result == 1
```

#### Fixture Composition

```python
@pytest.fixture
def database():
    db = create_database()
    yield db
    db.close()

@pytest.fixture
def user(database):  # Depends on database fixture
    return database.create_user("test@example.com")

@pytest.fixture
def authenticated_user(user):  # Chains dependencies
    user.authenticate()
    return user

def test_authenticated_access(authenticated_user):
    assert authenticated_user.is_authenticated
```

#### Factory Fixtures

```python
@pytest.fixture
def make_user(database):
    """Factory returns callable for on-demand user creation."""
    users = []

    def _make_user(name, email=None):
        user = User(name=name, email=email or f"{name}@test.com")
        database.add(user)
        users.append(user)
        return user

    yield _make_user

    # Cleanup all created users
    for user in users:
        database.delete(user)

def test_multiple_users(make_user):
    admin = make_user("admin")
    regular = make_user("user")
    assert admin.role != regular.role
```

### Built-in Fixtures

| Fixture | Purpose | Example |
|---------|---------|---------|
| `tmp_path` | Unique temp directory per test | File I/O testing |
| `monkeypatch` | Safe env/attribute patching | Mock environment variables |
| `capsys` | Capture stdout/stderr | Test CLI output |
| `caplog` | Capture log messages | Verify error logging |

```python
def test_file_processing(tmp_path):
    """Test with temporary directory."""
    test_file = tmp_path / "input.txt"
    test_file.write_text("test data")
    result = process_file(test_file)
    assert result == expected

def test_environment_config(monkeypatch):
    """Mock environment variable."""
    monkeypatch.setenv("DATABASE_URL", "sqlite:///:memory:")
    config = load_config()
    assert config.database == "sqlite:///:memory:"

def test_cli_output(capsys):
    """Capture and verify stdout."""
    print_greeting("Alice")
    captured = capsys.readouterr()
    assert "Hello, Alice" in captured.out
```

### Parametrization

```python
# Basic parametrization
@pytest.mark.parametrize("input,expected", [
    ("3+5", 8),
    ("2+4", 6),
    ("10-3", 7),
], ids=["addition_1", "addition_2", "subtraction"])
def test_eval(input, expected):
    assert eval(input) == expected

# Stacking (Cartesian product)
@pytest.mark.parametrize("x", [0, 1])
@pytest.mark.parametrize("y", [2, 3])
def test_combinations(x, y):
    # Runs 4 times: (0,2), (0,3), (1,2), (1,3)
    assert x + y >= 2

# Indirect (parameters → fixtures)
@pytest.fixture
def database(request):
    db_type = request.param  # Receives parametrized value
    db = create_database(db_type)
    yield db
    db.teardown()

@pytest.mark.parametrize("database", ["sqlite", "postgres"], indirect=True)
def test_query(database):
    result = database.query("SELECT 1")
    assert result == 1
```

### Mocking Strategy

#### When to Mock

**DO mock:**
- External services (APIs, databases, S3)
- Time-dependent code (`datetime.now()`)
- Expensive operations (ML inference, large I/O)
- Non-deterministic behavior (random)
- Side effects (email sending, file writes)

**DON'T mock:**
- Your own functions (test real implementation)
- Pure functions (fast, deterministic)
- Simple data structures
- Low-level implementation details

#### monkeypatch vs pytest-mock

| Feature | monkeypatch | pytest-mock |
|---------|-------------|-------------|
| **Simplicity** | Minimal API | More features |
| **Call tracking** | No | Yes (`assert_called_with`) |
| **Auto-cleanup** | Yes | Yes |
| **Use case** | Simple substitution | Verification needed |

```python
# monkeypatch for simple cases
def test_config(monkeypatch):
    monkeypatch.setenv("API_KEY", "test_key")
    assert get_api_key() == "test_key"

def test_datetime(monkeypatch):
    class MockDatetime:
        @staticmethod
        def now():
            return datetime(2025, 1, 1)

    monkeypatch.setattr("myapp.utils.datetime", MockDatetime)
    assert get_current_year() == 2025

# pytest-mock for verification
def test_notification(mocker):
    send_mock = mocker.patch("app.email.send")
    notify_user(user_id=123)
    send_mock.assert_called_once_with(to="user@example.com", subject="Notification")
```

### Test Naming Convention

**Pattern:** `test_<component>_<scenario>_<expected>()`

```python
# Good: Descriptive test names
def test_login_valid_credentials_returns_token():
    pass

def test_login_invalid_password_raises_error():
    pass

def test_cart_add_item_increases_quantity():
    pass

# Bad: Vague test names
def test_login():
    pass

def test_cart():
    pass
```

### Test Isolation

```python
# BAD - Depends on execution order
def test_create_user(database):
    database.create_user("alice")

def test_find_user(database):
    user = database.find_user("alice")  # Fails if run alone!

# GOOD - Self-contained
def test_create_user(database):
    database.create_user("alice")
    assert database.find_user("alice") is not None

def test_find_user(database):
    database.create_user("bob")  # Setup within test
    assert database.find_user("bob") is not None
```

### Transaction Rollback Pattern

```python
# For database tests - session-level engine, function-level transaction
@pytest.fixture(scope="session")
def database_engine():
    engine = create_engine("postgresql://...")
    yield engine
    engine.dispose()

@pytest.fixture(scope="function")
def database(database_engine):
    connection = database_engine.connect()
    transaction = connection.begin()
    yield connection
    transaction.rollback()  # Undo all changes
    connection.close()

def test_create_user(database):
    database.execute("INSERT INTO users (name) VALUES ('Alice')")
    result = database.execute("SELECT name FROM users").fetchone()
    assert result[0] == "Alice"
    # Transaction rolled back automatically after test
```

## Code Validation Checklist

Before marking Python work complete:

### Anti-Pattern Check
- [ ] No mutable default arguments (`[]`, `{}` as defaults)
- [ ] No wildcard imports (`from module import *`)
- [ ] No bare `except:` clauses (catch specific exceptions)
- [ ] No `type(x) == SomeType` (use `isinstance(x, SomeType)`)
- [ ] Context managers for file operations (`with open()`)

### PEP 8 Compliance
- [ ] snake_case for functions, PascalCase for classes
- [ ] 4 spaces indentation (no tabs)
- [ ] Line length ≤79 chars for code
- [ ] Imports ordered: stdlib → third-party → local
- [ ] Docstrings for public functions

### Type Hints
- [ ] Type hints on public APIs
- [ ] Modern syntax (Python 3.10+ with `|` for unions)
- [ ] mypy passes in strict mode (if applicable)

### Testing
- [ ] Tests pass with `pytest`
- [ ] Test coverage ≥80% (`pytest --cov=src --cov-fail-under=80`)
- [ ] Descriptive test function names (`test_<component>_<scenario>_<expected>`)
- [ ] Tests are independent (no shared state between tests)

## Project Configuration

### pyproject.toml

```toml
[tool.pytest.ini_options]
minversion = "8.0"
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]

addopts = [
    "-ra",                        # Show summary
    "--strict-markers",           # Fail on undefined markers
    "--cov=src",                  # Coverage
    "--cov-report=term-missing",  # Show missing lines
    "--cov-fail-under=80",        # Enforce 80% minimum
]

markers = [
    "unit: fast isolated tests",
    "integration: external services",
    "slow: tests >1s",
]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "*/migrations/*"]

[tool.mypy]
python_version = "3.10"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.black]
line-length = 88
target-version = ["py310"]
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific markers
pytest -m unit                  # Only unit tests
pytest -m "not slow"            # Skip slow tests
pytest -m "integration and not slow"

# Parallel execution (60-80% faster)
pytest -n auto

# Verbose output
pytest -v
```

## Non-Negotiable Rules

### Code Quality
- ❌ NEVER use mutable default arguments (causes shared state bugs)
- ❌ NEVER use wildcard imports in production code
- ❌ NEVER use bare `except:` (catch specific exceptions)
- ❌ NEVER modify lists while iterating (causes skips/errors)
- ✅ ALWAYS use context managers for file operations
- ✅ ALWAYS follow PEP 8 naming conventions

### Type Hints
- ❌ NEVER skip type hints on public APIs
- ❌ NEVER use old-style typing (use `list` not `typing.List`)
- ✅ ALWAYS use modern Python 3.10+ syntax (`|` for unions)
- ✅ ALWAYS run mypy on typed code

### Testing
- ❌ NEVER write tests that depend on execution order
- ❌ NEVER mock your own functions (test real implementation)
- ❌ NEVER skip test cleanup (use fixtures with yield)
- ✅ ALWAYS use descriptive test function names
- ✅ ALWAYS aim for 80%+ test coverage
- ✅ ALWAYS use appropriate fixture scopes (function for isolation, session for performance)

## Quick Reference

### Common Patterns

```python
# Context manager for resources
with open("file.txt") as f:
    data = f.read()

# List comprehension
evens = [x for x in range(10) if x % 2 == 0]

# Dictionary comprehension
squares = {x: x**2 for x in range(5)}

# Enumerate for index + value
for i, item in enumerate(items):
    print(f"{i}: {item}")

# Zip for parallel iteration
for name, age in zip(names, ages):
    print(f"{name} is {age}")

# Exception handling (specific exceptions)
try:
    result = risky_operation()
except (ValueError, TypeError) as e:
    logger.error(f"Operation failed: {e}")
    raise
```

### Testing Quick Start

```python
# Test file: test_mymodule.py
import pytest
from myapp.mymodule import calculate_total

@pytest.fixture
def sample_items():
    return [{"price": 10}, {"price": 20}]

def test_calculate_total_sums_prices(sample_items):
    result = calculate_total(sample_items)
    assert result == 30

def test_calculate_total_empty_list_returns_zero():
    assert calculate_total([]) == 0

@pytest.mark.parametrize("items,expected", [
    ([{"price": 5}], 5),
    ([{"price": 10}, {"price": 15}], 25),
])
def test_calculate_total_parametrized(items, expected):
    assert calculate_total(items) == expected
```

## See Also

- `gco-tdd-workflow` skill - Test-driven development process
- `gco-code-patterns` skill - Anti-patterns and error handling
- `gco-completion-checklist` - Completion requirements
- `.haunt/docs/research/pytest-patterns.md` - Deep dive on pytest
