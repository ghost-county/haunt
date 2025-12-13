# 06: Patterns and Defeats

> TDD for agent behavior: Find patterns, write tests, defeat them permanently.

---

## Overview

| Item | Purpose |
|------|---------|
| **Time Required** | Ongoing (part of weekly refactor) |
| **Output** | Pattern-defeating test suite |
| **Automation** | Pre-commit hooks enforce defeats |
| **Prerequisites** | [04-Implementation-Phases](04-Implementation-Phases.md) Phase 2+ |

---

## The Pattern Defeat Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│    ┌─────────┐     ┌─────────┐     ┌─────────┐                  │
│    │  Find   │────▶│ Defeat  │────▶│  Teach  │                  │
│    │ Pattern │     │ Pattern │     │Discipline│                  │
│    └─────────┘     └─────────┘     └─────────┘                  │
│         ▲                               │                        │
│         │                               │                        │
│         └───────────────────────────────┘                        │
│                    Repeat                                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Traditional TDD vs Agent TDD

| Traditional TDD | Agent TDD |
|-----------------|-----------|
| Red → Green → Refactor | Pattern Found → Test Written → Agent Trained |
| Test before code | Test after pattern observed |
| Prevents future bugs | Defeats recurring patterns |
| Developer writes tests | You write tests based on agent behavior |

---

## Phase 1: Find the Pattern

### Where to Look

```markdown
## Pattern Sources

### Git History
- Same files getting fixed repeatedly
- Similar commit messages ("fix...", "handle...", "oops...")
- Reverts and re-dos

### Review Comments
- Same feedback appearing multiple times
- Recurring style issues
- Repeated security concerns

### Agent Memories
- Same learnings appearing repeatedly
- "I learned not to do X" happening often
- Patterns in recent_learnings

### Your Frustration
- "Not this again"
- "Why does it keep doing this?"
- Manual fixes you repeat
```

### Pattern Identification Template

```markdown
## Pattern: [Name]

### Identification
- **First noticed:** [Date]
- **Frequency:** [How often - daily, weekly, per feature]
- **Agents affected:** [Which agents exhibit this]

### Description
[What happens - specific, observable behavior]

### Examples
1. [Specific instance with file/line]
2. [Another instance]
3. [Another instance]

### Impact
- **Severity:** [High/Medium/Low]
- **What breaks:** [Consequences when pattern occurs]
- **Time cost:** [How much time spent fixing]

### Root Cause
[Why does this happen? What triggers it?]
```

### Common Patterns to Watch

| Category | Pattern | Symptom |
|----------|---------|---------|
| **Code Quality** | Silent fallback | `.get(x, 0)` hiding errors |
| | God function | 200+ line functions |
| | Magic numbers | `if x > 86400` |
| | Catch-all | `except Exception` |
| **Testing** | No edge cases | Only happy path tested |
| | Brittle tests | Tests break on unrelated changes |
| | No assertions | Tests that always pass |
| **Research** | Fabrication | Made-up citations |
| | Overconfidence | Claims without evidence |
| | Missing uncertainty | No acknowledgment of gaps |
| **Coordination** | Missed handoff | Work falls through cracks |
| | Duplicate work | Two agents same task |
| | Stale context | Using outdated info |

---

## Phase 2: Defeat the Pattern

### The Defeat Test Structure

```python
# tests/patterns/test_[pattern_name].py
"""
Defeat: [Pattern name]
Found: [Date]
Agent(s): [Who exhibited this]
Impact: [What went wrong]
"""

import pytest

def test_no_[pattern_name]():
    """
    [One sentence explaining what this prevents]
    """
    # Implementation that fails when pattern is present
    pass
```

### Example Defeat Tests

#### 1. Silent Fallback Pattern

```python
# tests/patterns/test_no_silent_fallbacks.py
"""
Defeat: Silent fallback pattern
Found: 2024-12-05
Agent(s): Dev-Backend
Impact: Validation errors were hidden, bad data propagated
"""

import re
from pathlib import Path

SILENT_FALLBACK_PATTERN = r'\.get\([^,]+,\s*(0|None|\'\'|\"\"|\[\]|\{\})\)'

def get_python_files(directory: str = "src") -> list[Path]:
    """Get all Python files in directory."""
    return list(Path(directory).rglob("*.py"))

def test_no_silent_fallbacks_in_codebase():
    """
    Silent fallbacks (.get(x, default)) hide errors.
    Use explicit validation instead.
    """
    violations = []

    for filepath in get_python_files("src"):
        content = filepath.read_text()
        for line_num, line in enumerate(content.split("\n"), 1):
            if re.search(SILENT_FALLBACK_PATTERN, line):
                violations.append(f"{filepath}:{line_num}: {line.strip()}")

    assert not violations, (
        f"Silent fallbacks found:\n"
        + "\n".join(violations)
        + "\n\nUse explicit validation: raise error if required key missing"
    )
```

#### 2. God Function Pattern

```python
# tests/patterns/test_no_god_functions.py
"""
Defeat: God function pattern
Found: 2024-12-07
Agent(s): Dev-Backend, Dev-Infrastructure
Impact: Functions too complex to test, maintain, or understand
"""

import ast
from pathlib import Path

MAX_FUNCTION_LINES = 50

def get_function_lengths(filepath: Path) -> list[tuple[str, int]]:
    """Get all function names and their line counts."""
    content = filepath.read_text()
    try:
        tree = ast.parse(content)
    except SyntaxError:
        return []

    functions = []
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            length = node.end_lineno - node.lineno + 1
            functions.append((node.name, length))

    return functions

def test_no_god_functions():
    """
    Functions over 50 lines are too complex.
    Break them into smaller, focused functions.
    """
    violations = []

    for filepath in Path("src").rglob("*.py"):
        for func_name, length in get_function_lengths(filepath):
            if length > MAX_FUNCTION_LINES:
                violations.append(f"{filepath}:{func_name} is {length} lines")

    assert not violations, (
        f"God functions found (>{MAX_FUNCTION_LINES} lines):\n"
        + "\n".join(violations)
        + "\n\nBreak these into smaller functions"
    )
```

#### 3. Magic Number Pattern

```python
# tests/patterns/test_no_magic_numbers.py
"""
Defeat: Magic number pattern
Found: 2024-12-08
Agent(s): Dev-Backend
Impact: Unclear code intent, hard to maintain
"""

import re
from pathlib import Path

# Numbers that should be constants
SUSPICIOUS_NUMBERS = [
    (r'\b86400\b', "SECONDS_PER_DAY"),
    (r'\b3600\b', "SECONDS_PER_HOUR"),
    (r'\b1000\b', "Could be MILLISECONDS or a limit"),
    (r'\b1024\b', "BYTES_PER_KB"),
    (r'\b65535\b', "MAX_PORT_NUMBER"),
]

def test_no_magic_numbers():
    """
    Magic numbers should be named constants.
    """
    violations = []

    for filepath in Path("src").rglob("*.py"):
        content = filepath.read_text()
        for line_num, line in enumerate(content.split("\n"), 1):
            # Skip comments and constant definitions
            if line.strip().startswith("#") or "=" in line and line.split("=")[0].isupper():
                continue

            for pattern, suggestion in SUSPICIOUS_NUMBERS:
                if re.search(pattern, line):
                    violations.append(
                        f"{filepath}:{line_num}: Found number, use {suggestion}"
                    )

    assert not violations, (
        f"Magic numbers found:\n"
        + "\n".join(violations[:10])  # Limit output
        + "\n\nDefine as named constants"
    )
```

#### 4. Missing Error Handling Pattern

```python
# tests/patterns/test_no_bare_except.py
"""
Defeat: Bare except pattern
Found: 2024-12-09
Agent(s): Dev-Backend, Dev-Infrastructure
Impact: Swallowing unexpected errors, hiding bugs
"""

import ast
from pathlib import Path

def test_no_bare_except():
    """
    Bare 'except:' or 'except Exception:' swallow errors.
    Catch specific exceptions only.
    """
    violations = []

    for filepath in Path("src").rglob("*.py"):
        content = filepath.read_text()
        try:
            tree = ast.parse(content)
        except SyntaxError:
            continue

        for node in ast.walk(tree):
            if isinstance(node, ast.ExceptHandler):
                if node.type is None:
                    violations.append(f"{filepath}:{node.lineno}: bare except:")
                elif isinstance(node.type, ast.Name) and node.type.id == "Exception":
                    violations.append(f"{filepath}:{node.lineno}: except Exception")

    assert not violations, (
        f"Overly broad exception handling:\n"
        + "\n".join(violations)
        + "\n\nCatch specific exceptions"
    )
```

#### 5. N+1 Query Pattern

```python
# tests/patterns/test_no_n_plus_one.py
"""
Defeat: N+1 query pattern
Found: 2024-12-10
Agent(s): Dev-Backend
Impact: Database performance degradation under load
"""

import pytest
from your_app.testing import TestClient, QueryCounter

@pytest.fixture
def client():
    return TestClient()

@pytest.fixture
def query_counter():
    return QueryCounter()

def test_list_endpoints_have_bounded_queries(client, query_counter):
    """
    List endpoints should not scale queries with result count.
    Max 10 queries per request.
    """
    endpoints = [
        "/api/users",
        "/api/projects",
        "/api/tasks",
    ]

    for endpoint in endpoints:
        with query_counter:
            response = client.get(f"{endpoint}?limit=100")

        assert response.status_code == 200
        assert query_counter.count <= 10, (
            f"{endpoint} made {query_counter.count} queries. "
            "Use eager loading to prevent N+1."
        )
```

---

## Phase 3: Teach Discipline

### Add to Pre-commit

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: pattern-detection
        name: Pattern Detection
        entry: pytest tests/patterns/ -x -q --tb=short
        language: system
        types: [python]
        pass_filenames: false
        stages: [commit]
```

### Add to Agent Prompts

```markdown
# Added to dev-backend.md

## Non-Negotiable Tests

Before any commit, these must pass:

- [ ] test_no_silent_fallbacks
- [ ] test_no_god_functions
- [ ] test_no_magic_numbers
- [ ] test_no_bare_except

You understand why these exist. Passing them is discipline.
```

### Add to Agent Memory

```python
# Record the pattern defeat in long-term memory
await memory.add_long_term_insight("dev-backend", """
Silent fallback incident (2024-12-05): Using .get(x, 0) hid validation
errors that caused bad data to propagate. Now enforced by
test_no_silent_fallbacks. Always validate required keys explicitly.
""")
```

---

## Behavior Testing

### The Problem

When you change an agent's prompt, how do you know you didn't break something?

```
Before: "Be thorough in your research"
After:  "Be concise and fast"

Did this break the agent's ability to find important details?
```

### Behavior Tests

```python
# tests/behavior/test_research_analyst_behavior.py
"""
Behavior tests for Research-Analyst agent.
Run on prompt changes to catch regressions.
"""

from agents.testing import prompt_agent, extract_citations

class TestResearchAnalystBehavior:
    """Baseline behaviors Research-Analyst must maintain."""

    def test_always_provides_citations(self):
        """Research must include citations."""
        response = prompt_agent("research-analyst",
            "What are the best practices for API design?")

        citations = extract_citations(response)
        assert len(citations) >= 1, "Response must include at least one citation"

    def test_acknowledges_uncertainty(self):
        """Uncertain claims must be marked."""
        response = prompt_agent("research-analyst",
            "Will quantum computing replace classical by 2030?")

        uncertainty_markers = [
            "uncertain", "unclear", "debated", "might", "could",
            "possibly", "it depends", "hard to say"
        ]
        assert any(m in response.lower() for m in uncertainty_markers), \
            "Speculative claims must acknowledge uncertainty"

    def test_no_fabricated_citations(self):
        """Citations must link to real sources."""
        response = prompt_agent("research-analyst",
            "Summarize recent research on transformer architectures")

        citations = extract_citations(response)
        for citation in citations:
            # Verify URL exists (integration test)
            assert verify_url_exists(citation.url), \
                f"Fabricated citation: {citation}"

    def test_maintains_optimistic_personality(self):
        """Research-Analyst should be optimistic but grounded."""
        response = prompt_agent("research-analyst",
            "Is climate change solvable?")

        # Should not be defeatist
        defeatist_markers = ["impossible", "hopeless", "no way", "never"]
        assert not any(m in response.lower() for m in defeatist_markers), \
            "Research-Analyst should maintain optimistic outlook"
```

### Behavior Baseline

Track expected behavior metrics:

```python
# tests/behavior/baselines.py
"""
Behavior baselines for agent personality validation.
Update these intentionally, not accidentally.
"""

BASELINES = {
    "research-analyst": {
        "citation_rate": 0.95,      # 95% of responses have citations
        "uncertainty_rate": 0.30,   # 30% acknowledge uncertainty
        "optimism_score": 0.7,      # Moderately optimistic
    },
    "research-critic": {
        "critique_rate": 0.90,      # 90% find something to critique
        "evidence_citation": 0.85,  # 85% cite counter-evidence
        "skepticism_score": 0.6,    # Moderately skeptical
    },
    "dev-backend": {
        "test_mention_rate": 0.80,  # 80% mention tests
        "explicit_error_rate": 0.90, # 90% use explicit error handling
        "documentation_rate": 0.70, # 70% document changes
    }
}

def check_baseline_drift(agent: str, current_metrics: dict):
    """Check if current metrics drift too far from baseline."""
    baseline = BASELINES[agent]
    drift_threshold = 0.20  # 20%

    for metric, expected in baseline.items():
        actual = current_metrics.get(metric, 0)
        drift = abs(actual - expected) / expected if expected else abs(actual)

        if drift > drift_threshold:
            raise BehaviorDriftError(
                f"{agent}.{metric} drifted {drift:.0%}: "
                f"expected {expected}, got {actual}"
            )
```

### CI Integration

```yaml
# .github/workflows/behavior-tests.yml
name: Behavior Tests

on:
  push:
    paths:
      - '.claude/agents/**'

jobs:
  behavior:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Run behavior tests
        run: pytest tests/behavior/ -v

      - name: Check baseline drift
        run: python scripts/check_behavior_baseline.py
```

---

## Pattern Defeat Template

Use this template for each pattern:

```markdown
## Pattern Defeat: [Name]

### 1. Identify

| Field | Value |
|-------|-------|
| **Pattern Name** | [Short descriptive name] |
| **First Noticed** | [Date] |
| **Frequency** | [How often it occurs] |
| **Impact** | [What goes wrong] |

### 2. Analyze

| Field | Value |
|-------|-------|
| **Root Cause** | [Why does this happen?] |
| **Agent(s) Affected** | [Who does this?] |
| **Trigger Conditions** | [When does it occur?] |

### 3. Test

| Field | Value |
|-------|-------|
| **Test Name** | test_[pattern_name] |
| **Test File** | tests/patterns/test_[pattern].py |
| **What It Checks** | [Specific condition] |

### 4. Implement

| Field | Value |
|-------|-------|
| **Code Changes** | [What was fixed] |
| **Prompt Changes** | [What was added to agent prompts] |
| **Memory Added** | [What agents should remember] |

### 5. Verify

- [ ] Test passing
- [ ] Pattern not recurring (7 days)
- [ ] Agent checklist updated
- [ ] Memory recorded
```

---

## Common Patterns Reference

### Code Quality Patterns

| Pattern | Detection | Defeat |
|---------|-----------|--------|
| Silent fallback | Regex `.get(x, default)` | Assert no matches in src/ |
| God function | AST parse, count lines | Assert < 50 lines |
| Magic numbers | Regex for suspicious constants | Assert named constants |
| Bare except | AST parse ExceptHandler | Assert specific exceptions |
| Single letter vars | Regex `\b[a-z]\s*=` | Assert descriptive names |

### Testing Patterns

| Pattern | Detection | Defeat |
|---------|-----------|--------|
| No assertions | AST parse test functions | Assert has assert statements |
| Happy path only | Coverage analysis | Assert edge case coverage |
| Test duplication | AST similarity | Assert unique test logic |

### Research Patterns

| Pattern | Detection | Defeat |
|---------|-----------|--------|
| Fabricated citations | URL verification | Assert all URLs exist |
| Missing uncertainty | NLP analysis | Assert uncertainty markers |
| Overconfidence | Confidence scoring | Assert confidence < 1.0 |

### Coordination Patterns

| Pattern | Detection | Defeat |
|---------|-----------|--------|
| Missed handoff | Queue analysis | Assert ACK for all assignments |
| Duplicate work | Work ID tracking | Assert unique assignments |
| Stale context | Timestamp checking | Assert fresh context |

---

## The Discipline Stack

Patterns get defeated at multiple levels:

```
Level 4: INTERNALIZED (Habit)
         └─ Agent automatically avoids patterns
         └─ No external enforcement needed

Level 3: MEMORY (Self-Check)
         └─ Agent remembers past failures
         └─ Checks before committing

Level 2: REVIEW (Checklist)
         └─ Reviewer catches during review
         └─ Changes requested

Level 1: ENFORCEMENT (Hooks)
         └─ Pre-commit rejects
         └─ Cannot bypass
```

### Progression Timeline

| Week | Level | What Happens |
|------|-------|--------------|
| 1 | Level 1 | External enforcement catches everything |
| 2 | Level 2 | Agent starts checking against checklist |
| 3 | Level 3 | Agent recalls past issues, self-corrects |
| 4+ | Level 4 | Pattern becomes automatic to avoid |

---

## Next Steps

1. **Identify** your first 3 patterns from Phase 1
2. **Write** defeat tests for each
3. **Add** to pre-commit hooks
4. **Update** agent prompts with discipline
5. **Track** recurrence (should be zero)
