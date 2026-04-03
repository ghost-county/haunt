---
last-verified: 2026-04-03
name: gco-python-standards
description: Python coding standards and pytest patterns. Invoke when working on .py files or pytest tests.
---

# Python Standards

**Core:** Explicit over implicit. Readability over cleverness. One obvious way.

## Anti-Patterns (Never Do)

| Pattern | Fix |
|---------|-----|
| `def func(lst=[])` | `lst=None; lst = lst or []` |
| `from module import *` | Explicit imports only |
| `except:` (bare) | Catch specific exceptions |
| `if type(x) == int:` | `isinstance(x, int)` |
| Modify list while iterating | List comprehension instead |
| `for i in range(len(items)):` | `enumerate(items)` |

## PEP 8 Quick Reference

| Item | Convention |
|------|------------|
| Functions | `snake_case` |
| Classes | `PascalCase` |
| Constants | `UPPER_CASE` |
| Private | `_leading_underscore` |
| Line length | 79 chars code, 72 comments |
| Indentation | 4 spaces (never tabs) |
| Imports | stdlib → third-party → local |

## Type Hints (Python 3.10+)

**Required:** Public APIs, complex transformations, framework integration
**Optional:** Private functions, obvious types

```python
# Modern syntax
def process(data: str | bytes) -> dict[str, int] | None:
```

## Pytest Essentials

### Fixture Scopes
| Scope | Use Case |
|-------|----------|
| `function` | Isolated state (default) |
| `module` | Expensive setup (DB connection) |
| `session` | Global resources (test server) |

### When to Mock
- ✅ External services, time, randomness, side effects
- ❌ Your own functions, pure functions, simple data

### Test Naming
`test_<component>_<scenario>_<expected>()`

## Commands

```bash
pytest                          # Run all
pytest --cov=src               # With coverage
pytest -m "not slow"           # Skip slow
pytest -n auto                 # Parallel
mypy --strict src/             # Type check
```

## Completion Checklist

- [ ] No mutable defaults, wildcard imports, bare except
- [ ] PEP 8 naming (snake_case functions, PascalCase classes)
- [ ] Type hints on public APIs
- [ ] Tests pass, ≥80% coverage
- [ ] Descriptive test names, no order dependency
