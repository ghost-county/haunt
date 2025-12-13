---
name: gco-pattern-defeat
description: TDD framework for defeating recurring agent/code patterns. Use when identifying bad patterns in code, writing defeat tests, or establishing quality gates. Triggers on "pattern", "recurring issue", "keeps happening", "defeat test", "pre-commit", "anti-pattern", or when code review finds repeated problems.
---

# Pattern Defeat Framework

Permanently eliminate recurring problems through test-driven defeat.

## The Cycle

```
Find Pattern → Write Defeat Test → Add to Pre-commit → Update Agent Memory
     ↑                                                         ↓
     └─────────────────── Repeat ──────────────────────────────┘
```

## Error-to-Pattern Flow (SDK Integration)

When errors occur during agent execution, they should flow into pattern detection:

```
Error Occurs → Log Error Context → Analyze for Patterns → Create Defeat Test
```

### Capturing Errors for Pattern Analysis

1. **Tool Errors**: When a tool call fails, note the context
2. **Test Failures**: Recurring test failures indicate patterns
3. **User Corrections**: When user corrects agent behavior, that's a pattern signal
4. **Context Overflow**: Sessions hitting limits suggest context management patterns

### Error Template

```markdown
## Error: [Brief description]

**When:** [Timestamp]
**Agent:** [Which agent/subagent]
**Tool:** [Which tool failed, if applicable]
**Context:** [What was being attempted]

### Error Details
[Full error message or description]

### Pattern Signal?
- Is this recurring? [Yes/No]
- Similar to past errors? [Reference]
- Preventable by test? [Yes/No]

### Action
- [ ] One-off fix (no pattern)
- [ ] Create defeat test
- [ ] Update agent memory
- [ ] Update skill guidance
```

## Step 1: Identify the Pattern

### Where to Look

- **Git history**: Same files fixed repeatedly, similar commit messages ("fix...", "oops...")
- **Review comments**: Recurring feedback
- **Your frustration**: "Not this again"

### Pattern Template

```markdown
## Pattern: [Name]

**First noticed:** [Date]
**Frequency:** [Daily/Weekly/Per feature]
**Agents/Authors affected:** [Who]

### Description
[Specific, observable behavior]

### Examples
1. [File:line - what happened]
2. [File:line - what happened]

### Impact
- Severity: [High/Medium/Low]
- What breaks: [Consequences]
- Time cost: [Hours spent fixing]

### Root Cause
[Why does this happen?]
```

## Step 2: Write the Defeat Test

### Test Structure

```python
# .haunt/tests/patterns/test_[pattern_name].py
"""
Defeat: [Pattern name]
Found: [Date]
Impact: [What went wrong]
"""

import pytest

def test_no_[pattern_name]():
    """[One sentence explaining what this prevents]"""
    # Implementation that fails when pattern is present
    pass
```

### Common Defeat Tests

#### Silent Fallback (`.get(x, default)` hiding errors)

```python
import re
from pathlib import Path

PATTERN = r'\.get\([^,]+,\s*(0|None|\'\'|\"\"|\[\]|\{\})\)'

def test_no_silent_fallbacks():
    """Silent fallbacks hide validation errors."""
    violations = []
    for f in Path("src").rglob("*.py"):
        for i, line in enumerate(f.read_text().split("\n"), 1):
            if re.search(PATTERN, line):
                violations.append(f"{f}:{i}: {line.strip()}")
    assert not violations, f"Found:\n" + "\n".join(violations)
```

#### God Functions (>50 lines)

```python
import ast
from pathlib import Path

MAX_LINES = 50

def test_no_god_functions():
    """Functions over 50 lines are too complex."""
    violations = []
    for f in Path("src").rglob("*.py"):
        try:
            tree = ast.parse(f.read_text())
        except SyntaxError:
            continue
        for node in ast.walk(tree):
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                length = node.end_lineno - node.lineno + 1
                if length > MAX_LINES:
                    violations.append(f"{f}:{node.name} = {length} lines")
    assert not violations, f"God functions:\n" + "\n".join(violations)
```

#### Bare Except

```python
import ast
from pathlib import Path

def test_no_bare_except():
    """Catch specific exceptions, not bare except."""
    violations = []
    for f in Path("src").rglob("*.py"):
        try:
            tree = ast.parse(f.read_text())
        except SyntaxError:
            continue
        for node in ast.walk(tree):
            if isinstance(node, ast.ExceptHandler) and node.type is None:
                violations.append(f"{f}:{node.lineno}")
    assert not violations, f"Bare except:\n" + "\n".join(violations)
```

## Step 3: Add to Pre-commit

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: pattern-detection
        name: Pattern Detection
        entry: pytest .haunt/tests/patterns/ -x -q
        language: system
        types: [python]
        pass_filenames: false
```

Install: `pre-commit install`

## Step 4: Record the Learning

Add to agent memory or documentation:

```markdown
## [Pattern Name] Incident ([Date])

Using [bad pattern] caused [consequence]. Now enforced by
`test_[pattern_name]`. Always [correct approach] instead.
```

## Common Patterns Reference

| Pattern | Detection | Fix |
|---------|-----------|-----|
| Silent fallback | Regex `.get(x, default)` | Explicit validation |
| God function | AST line count | Split into focused functions |
| Magic numbers | Regex for literals | Named constants |
| Bare except | AST ExceptHandler | Specific exceptions |
| No assertions | AST test functions | Add meaningful asserts |
| Fabricated citations | URL verification | Verify sources exist |

## Common Agent Error Patterns

These patterns frequently emerge from agent workflows:

| Error Type | Pattern Signal | Defeat Strategy |
|------------|---------------|-----------------|
| Tool permission denied | Agent tried forbidden tool | Verify subagent_type matches task needs |
| File not found | Hardcoded paths, wrong directory | Use relative paths, verify pwd |
| Test failure cascade | One failure causes many | Isolate tests, fix root cause first |
| Context overflow | Session too long | Archive completed work, compact context |
| Missing dependency | Import/require fails | Add to setup prerequisites |
| API rate limit | Too many requests | Add backoff, batch requests |

### Agent-Specific Patterns

**Dev Agents:**
- Writing files without reading first (Edit tool requirement)
- Not running tests after changes
- Forgetting to commit or committing incomplete work

**Research Agents:**
- Can't write deliverables (missing Write tool)
- Citing sources that don't exist
- Not providing confidence levels

**Project Manager:**
- Creating oversized roadmap items (L/XL instead of S/M)
- Not archiving completed work
- Forgetting to update Active Work section

## Verification Checklist

After defeating a pattern:

- [ ] Test passing locally
- [ ] Test added to pre-commit
- [ ] Pattern hasn't recurred (7 days)
- [ ] Learning recorded
- [ ] Agent memory updated (if agent-specific pattern)
