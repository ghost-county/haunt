# Workshop 7: Continuous Improvement

> *Find the patterns. Defeat the patterns. Teach discipline.*

---

## Overview

| | |
|---|---|
| **Duration** | 60 minutes |
| **Format** | Pattern analysis + test-driven improvement |
| **Output** | Improvement loop, behavior tests, discipline framework |
| **Prerequisites** | Running agent team with memory system |

---

## Learning Objectives

By the end of this workshop, you will:

- Identify recurring failure patterns in agent behavior
- Use TDD to defeat patterns permanently
- Implement E2E tests that prevent regressions
- Teach discipline through test requirements
- Set up behavior testing for prompt changes
- Create a continuous improvement loop

---

## The Improvement Loop

Your agents will develop bad habits. Your job is to:

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│    ┌─────────┐     ┌─────────┐     ┌─────────┐         │
│    │  Find   │────▶│ Defeat  │────▶│  Teach  │         │
│    │ Pattern │     │ Pattern │     │Discipline│         │
│    └─────────┘     └─────────┘     └─────────┘         │
│         ▲                               │               │
│         │                               │               │
│         └───────────────────────────────┘               │
│                    Repeat                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Phase 1: Find the Pattern

Look for:

- Same mistake appearing multiple times
- Workarounds you keep adding
- Manual fixes you repeat
- Reviewer feedback that recurs

**Sources of patterns:**

- Git history (same files getting fixed)
- Review comments (same feedback)
- Agent memories (same learnings repeated)
- Your own frustration ("not this again")

---

## Phase 2: Defeat the Pattern

Write a test that fails when the pattern occurs:

```python
# test_no_silent_fallbacks.py
def test_no_silent_fallbacks_in_codebase():
    """Defeat: Roy's silent fallback pattern."""
    pattern = r'\.get\([^,]+,\s*(0|None|\'\'|\"\")\)'

    for filepath in get_python_files('src/'):
        content = read_file(filepath)
        matches = re.findall(pattern, content)
        assert not matches, f"Silent fallback in {filepath}: {matches}"
```

Now the pattern **cannot return** without breaking CI.

---

## Phase 3: Teach Discipline

Add the test to the agent's requirements:

```markdown
# Agent: Roy

## Non-Negotiable Tests

Before any commit, these must pass:
- [ ] test_no_silent_fallbacks
- [ ] test_no_single_letter_vars
- [ ] test_assertions_on_all_mutations

You wrote these tests. You understand why. Passing them is discipline.
```

---

## TDD for Agent Behavior

### The Traditional TDD Cycle

```
Red → Green → Refactor
```

### The Agent TDD Cycle

```
Pattern Found → Test Written → Agent Trained → Pattern Defeated
```

### Example: The Citation Pattern

**Pattern found:** Cynthia fabricates citations.

**Test written:**

```python
# test_citation_validity.py
import pytest
from agents.cynthia import research_claim

def test_citations_are_verifiable():
    """Every citation must link to a real source."""
    result = research_claim("carbon capture effectiveness")

    for citation in result.citations:
        assert citation.url is not None, "Citation must have URL"
        assert verify_url_exists(citation.url), f"URL invalid: {citation.url}"
        assert citation.author in fetch_page_content(citation.url), \
            f"Author {citation.author} not found at {citation.url}"

def test_uncertain_claims_marked():
    """Claims without citations must be marked uncertain."""
    result = research_claim("speculative future technology")

    for claim in result.claims:
        if not claim.citations:
            assert "(needs citation)" in claim.text or claim.confidence < 0.5
```

**Agent trained:** Test added to Cynthia's pre-commit requirements.

**Pattern defeated:** Can't ship fabricated citations anymore.

---

## E2E Testing for Agents

### Why E2E, Not Just Unit Tests

Unit tests verify functions. E2E tests verify **behavior through the whole system**.

```
Unit Test: "Does this function validate citations?"
E2E Test:  "When Cynthia researches a topic, do the citations in the final
            output actually exist and say what she claims?"
```

### Agent E2E Test Structure

```python
# e2e/test_research_workflow.py

async def test_full_research_workflow():
    """E2E: Research claim → Critique → Validation → Output"""

    # Step 1: Cynthia researches
    research = await cynthia.research("climate adaptation strategies")
    assert research.citations, "Research must have citations"

    # Step 2: Sylvia critiques
    critique = await sylvia.critique(research)
    assert critique.methodology_check_passed

    # Step 3: Validate citations exist
    for citation in research.citations:
        response = await fetch(citation.url)
        assert response.status == 200, f"Citation URL broken: {citation.url}"

    # Step 4: Check final output format
    output = await format_research_output(research, critique)
    assert "Sources:" in output
    assert all(c.url in output for c in research.citations)
```

### E2E Tests Prevent Regressions

When you fix a bug, add an E2E test:

```python
# e2e/test_regressions.py

class TestRegressions:
    """Tests for bugs we've fixed. Never let them return."""

    async def test_citation_crisis_regression(self):
        """2024-03: Cynthia fabricated citations. Never again."""
        research = await cynthia.research("any topic")
        for citation in research.citations:
            # This would have caught the original bug
            assert await url_exists(citation.url)
            assert await page_mentions_author(citation.url, citation.author)

    async def test_nan_fallback_regression(self):
        """2024-04: Roy's ?? 0 fallback hid NaN. Never again."""
        result = await roy.run_simulation(seed=42)
        # Check no NaN anywhere in output
        assert not contains_nan(result.state)
        # Check no zeros where we expect positive values
        assert result.population > 0
        assert result.temperature != 0  # Can be negative, but not exactly 0
```

---

## Teaching Discipline

### The Discipline Stack

```
Level 1: External Enforcement (Hooks)
         └─ Pre-commit rejects bad patterns

Level 2: Checklist Awareness (Review)
         └─ Senior reviewer checks against list

Level 3: Memory Integration (Self-Check)
         └─ Agent remembers past failures

Level 4: Internalized Discipline (Habit)
         └─ Agent automatically avoids patterns
```

### Moving Up the Stack

**Week 1:** External enforcement catches everything

```
Hook: REJECTED - silent fallback detected
Agent: Oh, I need to fix that
```

**Week 2:** Agent starts checking before commit

```
Agent: Wait, is this a silent fallback? Let me check...
Agent: Yes, I should use explicit error handling instead
```

**Week 4:** Pattern becomes automatic

```
Agent: [Writes explicit error handling by default]
Agent: [Doesn't even consider fallbacks anymore]
```

### Discipline Through Test Requirements

Add to agent system prompts:

```markdown
## Test Discipline

Before committing ANY code:

1. Run the full test suite: `npm test`
2. Specifically run E2E tests: `npm run test:e2e`
3. Check for pattern violations: `npm run check:patterns`

If any test fails:
- Fix the issue
- Understand WHY it failed
- Add to your memory if it's a new pattern
- Only then retry the commit

Tests are not obstacles. Tests are discipline. Tests are how you prove
you've learned from past mistakes.
```

---

## Behavior Testing Framework

### The Problem

When you change an agent's prompt, how do you know you didn't break something?

```
Before: "Be concise in your responses"
After:  "Be extremely concise, use bullet points only"

Did this break the agent's ability to explain complex topics?
You won't know until it's too late.
```

### The Solution: Behavior Tests

```python
# tests/behavior/test_cynthia_behavior.py

class TestCynthiaBehavior:
    """Behavior tests for Cynthia's research agent."""

    def test_provides_citations(self):
        """Cynthia must always provide citations for claims."""
        response = prompt_agent("cynthia", "What is carbon capture?")
        assert extract_citations(response), "Response must include citations"

    def test_acknowledges_uncertainty(self):
        """Cynthia must acknowledge when evidence is weak."""
        response = prompt_agent("cynthia", "Will fusion power work by 2030?")
        uncertainty_markers = ["uncertain", "unclear", "debated", "might", "could"]
        assert any(m in response.lower() for m in uncertainty_markers)

    def test_no_fabrication(self):
        """Cynthia must not make up papers or authors."""
        response = prompt_agent("cynthia", "Research on X")
        citations = extract_citations(response)
        for c in citations:
            assert verify_citation_exists(c), f"Fabricated citation: {c}"

    def test_personality_maintained(self):
        """Cynthia should remain optimistic but grounded."""
        response = prompt_agent("cynthia", "Is climate change solvable?")
        # Should be hopeful but evidence-based
        assert "evidence" in response.lower() or "research" in response.lower()
        assert "impossible" not in response.lower()  # Not a pessimist
```

### Running Behavior Tests on Prompt Changes

```yaml
# .github/workflows/agent-behavior.yml
name: Agent Behavior Tests

on:
  push:
    paths:
      - 'agents/*.md'  # Trigger on prompt changes

jobs:
  behavior-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run behavior tests
        run: pytest tests/behavior/ -v

      - name: Compare to baseline
        run: python scripts/compare_behavior_baseline.py
```

### Behavior Baselines

Store expected behaviors and compare:

```python
# scripts/compare_behavior_baseline.py

BASELINE = {
    "cynthia": {
        "citation_rate": 0.95,      # 95% of responses have citations
        "uncertainty_rate": 0.30,   # 30% acknowledge uncertainty
        "optimism_score": 0.7,      # Moderately optimistic
    },
    "sylvia": {
        "critique_rate": 0.90,      # 90% find something to critique
        "evidence_citation": 0.85,  # 85% cite counter-evidence
        "pessimism_score": 0.6,     # Moderately skeptical
    }
}

def compare_to_baseline(agent_name, current_metrics):
    baseline = BASELINE[agent_name]
    for metric, expected in baseline.items():
        actual = current_metrics[metric]
        drift = abs(actual - expected) / expected
        if drift > 0.20:  # 20% drift threshold
            raise BehaviorDriftError(
                f"{agent_name}.{metric} drifted {drift:.0%}: "
                f"expected {expected}, got {actual}"
            )
```

---

## Mobile Workflow with Claude Code

### The Problem

You're on your phone. You have an idea. You want to:

- Add something to the roadmap
- Kick off an agent task
- Check on progress

### The Solution: claude.ai/code

Access Claude Code from any device at **claude.ai/code**.

### Mobile Workflow Patterns

**Pattern 1: Add to Roadmap**

```
You: "Add a new requirement to ROADMAP.md:
      REQ-047: Add rate limiting to the API.
      Priority: High.
      Assign to Roy."

Claude: [Reads current roadmap]
        [Adds requirement in correct format]
        [Commits change]

You: [Done from your phone, Roy picks it up on next turn]
```

**Pattern 2: Kickoff Agent Work**

```
You: "Start Roy working on REQ-047 rate limiting"

Claude: [Creates handoff document]
        [Publishes to NATS queue]
        [Roy receives on next turn]
```

**Pattern 3: Check Progress**

```
You: "What's the status of the agent team?"

Claude: [Checks git log for recent commits]
        [Reads NATS queue depths]
        [Summarizes active work]

You: "Roy completed 3 tasks, Jen has 2 pending,
      merge orchestrator ran 5 times overnight"
```

### Setting Up Mobile Access

1. Go to: **claude.ai/code**
2. Connect your repo (GitHub integration)
3. Bookmark for quick access
4. Use voice input for faster mobile typing

### Mobile-Friendly Commands

Keep a cheat sheet:

```markdown
## Quick Mobile Commands

### Roadmap
- "Add requirement: [description]"
- "Show current phase progress"
- "What's blocking phase 2?"

### Agents
- "Start [agent] on [task]"
- "What is [agent] working on?"
- "Check agent queue depths"

### Review
- "Show recent commits"
- "Any failed tests?"
- "Summarize today's progress"
```

---

## The Pattern Defeat Cycle

### Step-by-Step Process

```markdown
## Pattern Defeat Template

### 1. Identify
**Pattern Name:** [Short descriptive name]
**First Noticed:** [Date]
**Frequency:** [How often it occurs]
**Impact:** [What goes wrong]

### 2. Analyze
**Root Cause:** [Why does this happen?]
**Agent(s) Affected:** [Who does this?]
**Trigger Conditions:** [When does it occur?]

### 3. Test
**Test Name:** test_[pattern_name]
**Test File:** tests/patterns/test_[pattern].py
**What It Checks:** [Specific condition]

### 4. Implement
**Code Changes:** [What was fixed]
**Prompt Changes:** [What was added to agent prompts]
**Memory Added:** [What agents should remember]

### 5. Verify
**Test Passing:** [ ] Yes
**Pattern Recurrence:** [ ] None in 7 days
**Checklist Updated:** [ ] Yes
```

### Real Example: The N+1 Query Pattern

```markdown
## Pattern Defeat: N+1 Queries

### 1. Identify
**Pattern Name:** N+1 Query Explosion
**First Noticed:** 2024-04-15
**Frequency:** Every new endpoint Roy builds
**Impact:** Database nearly crashed under load

### 2. Analyze
**Root Cause:** Roy uses loops to fetch related data
**Agent(s) Affected:** Roy (Backend)
**Trigger Conditions:** Any endpoint with relationships

### 3. Test
**Test Name:** test_no_n_plus_one_queries
**Test File:** tests/patterns/test_query_count.py
**What It Checks:** No endpoint makes more than 10 queries
```

```python
def test_no_n_plus_one_queries():
    with track_queries() as queries:
        response = client.get("/users?limit=100")

    assert len(queries) <= 10, \
        f"Endpoint made {len(queries)} queries (N+1 pattern?)"
```

```markdown
### 4. Implement
**Code Changes:** Added query count assertion utilities
**Prompt Changes:** "Always use eager loading for relationships"
**Memory Added:** Core memory about the April database incident

### 5. Verify
**Test Passing:** [x] Yes
**Pattern Recurrence:** [x] None in 7 days
**Checklist Updated:** [x] Yes - "Use eager loading"
```

---

## Exercise 7.1: Pattern Hunt

**Time:** 15 minutes
**Output:** List of patterns to defeat

### Part A: Review Recent History (5 min)

Look at:

- Last 20 git commits
- Last 10 code review comments
- Agent memory files (recent learnings)
- Your own notes/frustrations

### Part B: Identify Top 3 Patterns (5 min)

For each pattern:

- Name it specifically
- Note frequency
- Estimate impact

### Part C: Prioritize (5 min)

Rank by: `Impact × Frequency = Priority`

---

## Exercise 7.2: Write a Defeat Test

**Time:** 20 minutes
**Output:** Working test that catches your #1 pattern

### Part A: Define the Test (5 min)

```python
def test_[your_pattern]():
    """
    Defeat: [Pattern name]
    Why: [What goes wrong]
    """
    # What should this test check?
```

### Part B: Implement (10 min)

Write the test. Make sure it:

- Fails when the pattern is present
- Passes when the pattern is absent
- Has a clear error message

### Part C: Add to CI (5 min)

Add to your pre-commit or CI pipeline.

---

## Exercise 7.3: Mobile Workflow Setup

**Time:** 10 minutes
**Output:** Working mobile access to your agent team

### Part A: Access claude.ai/code

1. Open claude.ai/code on your phone
2. Connect your repository
3. Verify you can read files

### Part B: Test Commands

Try:

- "Show me the current ROADMAP.md"
- "What commits happened today?"
- "Add a note to Roy's memory: Test the mobile workflow"

### Part C: Bookmark

Save for quick access. You now have mobile command of your agent team.

---

## Common Patterns to Watch For

### The Repeat Patterns

| Pattern | Symptom | Defeat Test |
|---------|---------|-------------|
| Silent Fallback | `.get(x, 0)` everywhere | Regex for fallback patterns |
| N+1 Query | Slow endpoints | Query count limits |
| Fabrication | Made-up citations | URL verification |
| God Function | 200-line functions | Line count limits |
| Catch-All File | `utils.py` grows forever | File line limits |

### The Drift Patterns

| Pattern | Symptom | Defeat Test |
|---------|---------|-------------|
| Personality Drift | Agent sounds different | Behavior baseline comparison |
| Quality Drift | Output getting sloppier | Quality metric tracking |
| Scope Creep | Agent doing too much | Responsibility boundary tests |

### The Coordination Patterns

| Pattern | Symptom | Defeat Test |
|---------|---------|-------------|
| Missed Handoff | Work falls through cracks | Handoff verification |
| Duplicate Work | Two agents do same thing | Work item uniqueness |
| Stale Context | Agent uses outdated info | Context freshness checks |

---

## What You'll Have After This Workshop

1. **Pattern identification skills** - You can spot recurring problems
2. **Defeat tests** - Tests that make patterns impossible
3. **Behavior testing** - Catch prompt regressions before they ship
4. **Discipline framework** - Agents that self-enforce quality
5. **Mobile workflow** - Manage your team from anywhere
6. **Improvement loop** - Continuous system for getting better

Your agent team now improves itself. Patterns are defeated permanently.

---

## Next Steps

With all seven workshops complete, you have:

1. A planning system
2. Autonomous workers with execution cadence
3. Orchestrated specialist agents
4. Release management
5. Anti-pattern detection with security
6. Memory and character evolution
7. Continuous improvement with discipline

**Go build something.**

---

**Previous:** [Workshop 6 - Agent Memory and Evolution](Workshop-6-Agent-Memory-and-Evolution.md)
