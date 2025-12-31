---
name: gco-tdd-workflow
description: Test-driven development workflow guidance. Invoke when implementing new features, writing tests, or following Red-Green-Refactor cycle. Covers testing commands for Python, JavaScript, and Go.
---

# TDD Workflow: Test-Driven Development

## Purpose

This skill provides guidance for following test-driven development (TDD) practices. Use this when implementing new features to ensure code quality and test coverage.

## When to Invoke

- Implementing new features or functionality
- Asked to "write tests" or "follow TDD"
- Need guidance on testing workflow
- Clarifying test coverage expectations

## The Red-Green-Refactor Cycle

TDD follows a simple three-step cycle with explicit phase gates to ensure proper workflow.

### 1. RED - Write a Failing Test

Write a test that describes the expected behavior BEFORE implementing the feature.

**Example (Python with pytest):**
```python
# test_calculator.py
def test_add_two_numbers():
    calc = Calculator()
    result = calc.add(2, 3)
    assert result == 5  # This will FAIL - Calculator doesn't exist yet
```

**Run test to confirm it fails:**
```bash
pytest test_calculator.py -v
```

**GATE (complete ALL before proceeding to GREEN):**
- [ ] Test file exists and is saved
- [ ] Test runs without syntax/import errors
- [ ] Test FAILS with clear assertion error (not crash, not skip)
- [ ] Failure message describes expected behavior
- [ ] Test is independent (doesn't rely on other tests or shared state)

⛔ **STOP:** Do NOT proceed to GREEN phase until all gate items are checked. The test must fail for the right reason (assertion), not crash or error.

---

### 2. GREEN - Write Minimal Code to Pass

Implement the simplest code that makes the test pass.

**Example (Python):**
```python
# calculator.py
class Calculator:
    def add(self, a, b):
        return a + b  # Minimal implementation
```

**Run test to confirm it passes:**
```bash
pytest test_calculator.py -v
```

**GATE (complete ALL before proceeding to REFACTOR):**
- [ ] Implementation code written
- [ ] Test that failed in RED now PASSES
- [ ] ALL existing tests still pass (no regressions)
- [ ] Implementation is minimal (simplest code that works)
- [ ] No debugging code left (console.log, print statements)

⛔ **STOP:** Do NOT proceed to REFACTOR phase until all gate items are checked. If tests don't pass, fix the implementation, don't skip to refactoring.

---

### 3. REFACTOR - Improve Code While Keeping Tests Green

Once tests pass, refactor for clarity, performance, or design improvements.

**Example (Python):**
```python
# calculator.py
class Calculator:
    def add(self, a: int, b: int) -> int:
        """Add two numbers and return the result."""
        return a + b  # Now with type hints and docstring
```

**Run tests again to ensure refactoring didn't break anything:**
```bash
pytest test_calculator.py -v
```

**GATE (complete ALL before marking feature complete):**
- [ ] Code refactored for clarity (descriptive names, focused functions)
- [ ] Code refactored for quality (type hints, docstrings, error handling)
- [ ] ALL tests still pass after refactoring
- [ ] No new functionality added (refactoring only improves existing code)
- [ ] Code follows project style guidelines

⛔ **STOP:** Do NOT mark feature complete until all gate items are checked. Refactoring should improve code structure without changing behavior.

---

## Phase Gate Summary

**RED → GREEN → REFACTOR flow:**
1. ⛔ RED gate: Test must fail with clear assertion
2. ⛔ GREEN gate: Test must pass, no regressions
3. ⛔ REFACTOR gate: All tests pass after improvements

**Skipping gates leads to:**
- Tests that don't actually test behavior (skip RED gate)
- Untested or broken code (skip GREEN gate)
- Technical debt and messy code (skip REFACTOR gate)

**Follow the gates strictly** to ensure deterministic workflow and high-quality code.

---

## Testing Commands by Language

### Python (pytest)
```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_feature.py

# Run with coverage
pytest --cov=src tests/

# Run verbose (show test names)
pytest -v
```

### JavaScript/TypeScript (Jest/Vitest)
```bash
# Run all tests (Jest)
npm test

# Run specific test file
npm test -- path/to/test.spec.ts

# Run with coverage
npm test -- --coverage

# Watch mode (re-run on changes)
npm test -- --watch
```

### Go
```bash
# Run all tests in current package
go test

# Run all tests in project
go test ./...

# Run with coverage
go test -cover ./...

# Run specific test
go test -run TestFunctionName
```

## Test Coverage Expectations

- All new functions/components must have tests
- Test happy paths AND error cases
- Test edge cases and boundary conditions
- Aim for >80% code coverage on new code
- Don't obsess over 100% - focus on critical paths

## When NOT to Use TDD

TDD is not always appropriate. Skip TDD for:

1. **Spike Code** - Exploratory prototypes to evaluate feasibility
2. **Throwaway Scripts** - One-off automation or data migration
3. **UI Prototypes** - Initial visual mockups before behavior is defined
4. **Configuration Files** - YAML, JSON, env files (no logic to test)
5. **Unclear Requirements** - When you don't know what "correct" looks like yet

**Guideline:** If you're exploring or the requirements are fuzzy, spike first, then TDD the real implementation.

## Anti-Patterns to Avoid

- Writing implementation before tests
- Committing failing tests
- Skipping tests because "it's simple code"
- Testing implementation details instead of behavior
- Writing tests after the fact (that's not TDD)

## Success Criteria

You're following TDD correctly when:
1. Every new feature starts with a failing test
2. Tests describe behavior, not implementation
3. Code is only written to make tests pass
4. Refactoring happens while tests stay green
5. All tests pass before committing
