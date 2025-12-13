# 04: Implementation Phases

> Phased deployment from first agent to full team operation.

---

## Overview

| Item | Purpose |
|------|---------|
| **Time Required** | Variable - see phase durations |
| **Output** | Operational agent team |
| **Automation** | `scripts/04-implement-phases.sh` |
| **Prerequisites** | [03-Agent-Definitions](03-Agent-Definitions.md) complete |

---

## Phase Timeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                     IMPLEMENTATION TIMELINE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Day 1-3                Day 4-7               Week 2                 │
│  ┌─────────┐           ┌─────────┐          ┌─────────┐             │
│  │ Phase 1 │    →      │ Phase 2 │    →     │ Phase 3 │             │
│  │  First  │           │ Process │          │  Scale  │             │
│  │  Agent  │           │  Gates  │          │  Team   │             │
│  └─────────┘           └─────────┘          └─────────┘             │
│                                                                      │
│  Week 3                 Week 4               Week 5+                 │
│  ┌─────────┐           ┌─────────┐          ┌─────────┐             │
│  │ Phase 4 │    →      │ Phase 5 │    →     │ Phase 6 │             │
│  │ Quality │           │Evolution│          │ Mastery │             │
│  │  Gates  │           │ Memory  │          │ Improve │             │
│  └─────────┘           └─────────┘          └─────────┘             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: First Agent (Days 1-3)

### Goal

Get **one agent** reliably committing code.

### Checklist

```markdown
## Phase 1 Checklist

### Infrastructure
- [ ] NATS server running
- [ ] Single stream created (WORK)
- [ ] Memory server running
- [ ] Basic roadmap initialized

### Agent Setup
- [ ] One worker agent defined (Dev-Backend recommended)
- [ ] Agent can read assignments
- [ ] Agent can write code
- [ ] Agent can run tests
- [ ] Agent can commit

### First Assignment
- [ ] Create simple REQ-001 (S-sized)
- [ ] Assign to agent manually
- [ ] Agent completes requirement
- [ ] Tests pass
- [ ] Commit succeeds

### Verification
- [ ] Review committed code
- [ ] Document any manual fixes needed
- [ ] Update agent prompt based on issues
```

### Implementation Steps

#### Step 1: Start Simple

Create a minimal first requirement:

```markdown
# plans/roadmap.md

## Phase 1: First Agent Test

🟡 REQ-001: Create hello world endpoint
   Tasks:
   - [ ] Create src/api/hello.py
   - [ ] Add GET /hello endpoint
   - [ ] Return {"message": "Hello, World!"}
   - [ ] Add unit test
   Files: src/api/hello.py, tests/test_hello.py
   Effort: S
   Agent: Dev-Backend
   Completion: Tests pass, endpoint returns correct response
```

#### Step 2: Invoke Agent

```bash
# Option 1: Claude Code CLI
claude "You are Dev-Backend. Read your character sheet at .claude/agents/dev-backend.md.
        Check the roadmap at plans/roadmap.md.
        Complete REQ-001."

# Option 2: API with system prompt
# Include dev-backend.md content as system message
```

#### Step 3: Observe and Document

Watch what happens. Document:

- Did the agent read the requirement correctly?
- Did it follow the completion criteria?
- Did tests pass on first try?
- What did you have to fix manually?

#### Step 4: Iterate on Prompt

Update the agent's character sheet based on observations:

```markdown
# Added to dev-backend.md after Phase 1

## Learnings from Phase 1

- Always check if files exist before editing
- Run pytest with -v flag for verbose output
- Commit message format: "[REQ-XXX] Description"
```

### Success Criteria

- [ ] Agent completes 3 requirements without manual intervention
- [ ] All tests pass before commit
- [ ] Code follows project patterns

---

## Phase 2: Process Gates (Days 4-7)

### Goal

Add **automated enforcement** so patterns can't slip through.

### Checklist

```markdown
## Phase 2 Checklist

### Pre-commit Hooks
- [ ] pytest runs on commit
- [ ] Type checking runs on commit
- [ ] Linting runs on commit
- [ ] First pattern detection test exists

### Pattern Detection
- [ ] Identify top 3 patterns from Phase 1
- [ ] Write defeat test for each
- [ ] Add to pre-commit pipeline

### Second Agent
- [ ] Define second worker agent (Dev-Frontend or Dev-Infrastructure)
- [ ] Test on independent requirement
- [ ] Verify no conflicts with first agent
```

### Implementation Steps

#### Step 1: Install Pre-commit Hooks

```bash
# Install pre-commit
pip install pre-commit

# Create configuration
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: local
    hooks:
      - id: pytest
        name: Run Tests
        entry: pytest tests/ -x -q
        language: system
        types: [python]
        pass_filenames: false
        stages: [commit]

      - id: patterns
        name: Pattern Detection
        entry: pytest tests/patterns/ -x -q
        language: system
        types: [python]
        pass_filenames: false
        stages: [commit]
EOF

# Install hooks
pre-commit install
```

#### Step 2: Create First Defeat Test

Based on patterns observed in Phase 1:

```python
# tests/patterns/test_no_silent_fallbacks.py
"""
Defeat: Silent fallback pattern (.get(x, default))
Found: Day 2 of Phase 1
Impact: Hid validation errors
"""

import re
from pathlib import Path

def get_python_files(directory: str = "src") -> list[Path]:
    """Get all Python files in directory."""
    return list(Path(directory).rglob("*.py"))

def test_no_silent_fallbacks_in_codebase():
    """Silent fallbacks hide errors. Use explicit validation."""
    pattern = r'\.get\([^,]+,\s*(0|None|\'\'|\"\"|\[\]|\{\})\)'

    violations = []
    for filepath in get_python_files("src"):
        content = filepath.read_text()
        matches = re.findall(pattern, content)
        if matches:
            violations.append(f"{filepath}: {matches}")

    assert not violations, f"Silent fallbacks found:\n" + "\n".join(violations)
```

#### Step 3: Add Second Agent

Create a requirement that doesn't overlap with Dev-Backend's work:

```markdown
## Phase 2: Process Gates

🟡 REQ-010: Add configuration management
   Tasks:
   - [ ] Create src/config/settings.py
   - [ ] Load from environment variables
   - [ ] Add tests
   Files: src/config/settings.py, tests/test_config.py
   Effort: S
   Agent: Dev-Infrastructure
   Completion: Config loads from env, tests pass
   Note: No overlap with Dev-Backend's API work
```

### Success Criteria

- [ ] Pre-commit hooks reject bad commits
- [ ] Pattern detection catches at least one issue
- [ ] Two agents working without conflict

---

## Phase 3: Scale Team (Week 2)

### Goal

Run **multiple agents in parallel** with coordination.

### Checklist

```markdown
## Phase 3 Checklist

### All Streams Active
- [ ] REQUIREMENTS stream: PM dispatches work
- [ ] WORK stream: Agents receive assignments
- [ ] INTEGRATION stream: Ready-for-merge signals
- [ ] RELEASES stream: Merge coordination

### Coordination
- [ ] PM Agent managing roadmap
- [ ] 3+ worker agents defined
- [ ] Execution cadence implemented (15-min offsets)
- [ ] Handoff protocol working

### Release Management
- [ ] Release Manager Agent defined
- [ ] Merge ordering implemented
- [ ] Conflict detection working
```

### Implementation Steps

#### Step 1: Execution Cadence

Offset agent execution to prevent conflicts:

```python
# scripts/run_agent_team.py
import asyncio
from datetime import datetime

AGENTS = [
    {"name": "dev-backend", "offset_minutes": 0},
    {"name": "dev-frontend", "offset_minutes": 5},
    {"name": "dev-infrastructure", "offset_minutes": 10},
]

TURN_INTERVAL = 15  # minutes

async def run_agent(agent_config):
    """Run an agent with offset timing."""
    name = agent_config["name"]
    offset = agent_config["offset_minutes"]

    # Wait for offset
    await asyncio.sleep(offset * 60)

    while True:
        print(f"[{datetime.now()}] {name} starting turn")

        # Execute agent turn
        # ... agent logic here ...

        # Wait for next turn
        await asyncio.sleep(TURN_INTERVAL * 60)

async def main():
    """Run all agents concurrently with offsets."""
    tasks = [run_agent(config) for config in AGENTS]
    await asyncio.gather(*tasks)

if __name__ == "__main__":
    asyncio.run(main())
```

#### Step 2: Handoff Protocol

Agents communicate work completion:

```python
# When agent completes work
async def signal_completion(self, requirement_id: str, branch: str):
    """Signal that work is ready for integration."""
    await self.publish("work.integration.ready", {
        "type": "ready_to_merge",
        "merge_info": {
            "agent": self.name,
            "branch": branch,
            "requirement": requirement_id,
            "files_changed": self.get_changed_files(),
            "systems_touched": self.get_systems(),
            "priority": self.get_priority(),
            "timestamp": time.time()
        }
    })
```

#### Step 3: PM Dispatch

Project Manager assigns work via NATS:

```python
# PM assigns work to agent
async def dispatch_work(self, requirement: dict, agent: str):
    """Dispatch requirement to specific agent."""
    await self.publish(f"work.assigned.{agent}", {
        "type": "assignment",
        "requirement": requirement,
        "assigned_at": time.time()
    })

    # Update roadmap
    self.update_roadmap_status(requirement["id"], "in_progress", agent)
```

### Success Criteria

- [ ] PM Agent dispatches work automatically
- [ ] 3+ agents complete work in parallel
- [ ] No merge conflicts on same-day work
- [ ] Handoffs work end-to-end

---

## Phase 4: Quality Gates (Week 3)

### Goal

Add **multi-layer validation** to catch issues before they ship.

### Checklist

```markdown
## Phase 4 Checklist

### Four-Layer Validation
- [ ] Research agent verifies claims
- [ ] Critic agent challenges findings
- [ ] Code agent implements safely
- [ ] Review agent gates merge

### Senior Review Agent
- [ ] Defined and active
- [ ] Reviews all PRs before merge
- [ ] Follows review checklist
- [ ] Can block or approve

### E2E Testing
- [ ] E2E test framework set up
- [ ] Key workflows tested
- [ ] Tests run post-commit
```

### Implementation Steps

#### Step 1: Four-Layer Validation

For any significant decision:

```markdown
## Validation Workflow

1. **Research (Research-Analyst)**
   Input: "What's the best approach for user authentication?"
   Output: Evidence-based options with citations

2. **Critique (Research-Critic)**
   Input: Research-Analyst's research
   Output: Counter-arguments, blind spots, recommendations

3. **Implementation (Dev-Backend)**
   Input: Validated approach
   Output: Working code with tests

4. **Review (Code-Reviewer)**
   Input: Dev-Backend's PR
   Output: APPROVED / CHANGES_REQUESTED / BLOCKED
```

#### Step 2: Review Agent Integration

Add review step to merge process:

```python
# Release Manager checks for review status
async def can_merge(self, branch: str) -> bool:
    """Check if branch can be merged."""
    # Get review status
    review = await self.get_review_status(branch)

    if review["status"] == "APPROVED":
        return True
    elif review["status"] == "CHANGES_REQUESTED":
        print(f"Changes requested: {review['issues']}")
        return False
    elif review["status"] == "BLOCKED":
        print(f"BLOCKED: {review['reason']}")
        return False

    # No review yet - request one
    await self.request_review(branch)
    return False
```

#### Step 3: E2E Test Framework

```python
# tests/e2e/test_user_workflow.py
"""E2E tests for user workflows."""

import pytest
from your_app.testing import TestClient

@pytest.fixture
def client():
    """Create test client."""
    return TestClient()

async def test_user_registration_workflow(client):
    """E2E: User can register, login, and view profile."""

    # Step 1: Register
    response = await client.post("/auth/register", json={
        "email": "test@example.com",
        "password": "secure123"
    })
    assert response.status_code == 201

    # Step 2: Login
    response = await client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "secure123"
    })
    assert response.status_code == 200
    token = response.json()["token"]

    # Step 3: View profile
    response = await client.get("/profile",
        headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json()["email"] == "test@example.com"
```

#### Step 4: Browser Automation for E2E Testing

> Based on Anthropic's research: "Browser automation tools dramatically improve bug detection
> by allowing agents to verify features as users would experience them."

For web applications, agents should use browser automation to verify actual user experience:

**Setup (Playwright recommended):**

```bash
pip install playwright
playwright install chromium
```

**Browser Test Utilities:**

```python
# tests/e2e/browser_utils.py
"""
Browser automation utilities for agent-driven E2E testing.
Agents use these to verify features as users would experience them.
"""

from playwright.sync_api import sync_playwright, Page
from contextlib import contextmanager

@contextmanager
def browser_session(headless: bool = True):
    """Create a browser session for E2E testing."""
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=headless)
        context = browser.new_context()
        page = context.new_page()
        try:
            yield page
        finally:
            browser.close()

def verify_page_loads(page: Page, url: str, expected_title: str) -> bool:
    """Verify a page loads with expected title."""
    page.goto(url)
    return expected_title in page.title()

def verify_element_exists(page: Page, selector: str) -> bool:
    """Verify an element exists on the page."""
    return page.locator(selector).count() > 0

def verify_user_workflow(base_url: str) -> dict:
    """
    Agent-executable browser verification.
    Returns dict with success status and any errors.
    """
    results = {"success": True, "errors": []}

    with browser_session() as page:
        try:
            # Verify homepage loads
            page.goto(base_url)
            if not page.title():
                results["errors"].append("Homepage failed to load")
                results["success"] = False

            # Verify navigation works
            nav_links = page.locator("nav a").all()
            if len(nav_links) == 0:
                results["errors"].append("No navigation links found")

            # Verify no console errors
            console_errors = []
            page.on("console", lambda msg: console_errors.append(msg.text) if msg.type == "error" else None)
            page.reload()
            if console_errors:
                results["errors"].extend(console_errors)
                results["success"] = False

        except Exception as e:
            results["errors"].append(str(e))
            results["success"] = False

    return results
```

**Example Browser E2E Test:**

```python
# tests/e2e/test_browser_workflows.py
"""
Browser-based E2E tests for verifying actual user experience.
Run after implementing any user-facing feature.
"""

import pytest
from tests.e2e.browser_utils import browser_session, verify_user_workflow

class TestBrowserWorkflows:
    """Browser-based verification of user workflows."""

    def test_login_workflow_visual(self):
        """Verify login works as user would experience it."""
        with browser_session() as page:
            # Navigate to login
            page.goto("http://localhost:8501")

            # Fill login form
            page.fill("input[name='username']", "testuser")
            page.fill("input[name='password']", "testpass")
            page.click("button[type='submit']")

            # Verify redirect to dashboard
            page.wait_for_url("**/dashboard**")
            assert "Dashboard" in page.title()

    def test_no_console_errors(self):
        """Verify no JavaScript errors on main pages."""
        errors = []

        with browser_session() as page:
            page.on("console", lambda msg: errors.append(msg.text) if msg.type == "error" else None)

            # Visit main pages
            for path in ["/", "/dashboard", "/settings"]:
                page.goto(f"http://localhost:8501{path}")
                page.wait_for_load_state("networkidle")

        assert not errors, f"Console errors found: {errors}"

    def test_responsive_design(self):
        """Verify pages work on mobile viewport."""
        with browser_session() as page:
            # Set mobile viewport
            page.set_viewport_size({"width": 375, "height": 667})

            page.goto("http://localhost:8501")

            # Verify mobile menu is accessible
            assert page.locator("[data-testid='mobile-menu']").is_visible() or \
                   page.locator("nav").is_visible()
```

**Agent Prompt Addition for Browser Testing:**

Add this to worker agent prompts:

```markdown
## Browser Verification Rule

After implementing ANY user-facing feature:

1. Write a browser-based E2E test using Playwright
2. Verify the feature works as a user would experience it
3. Check for JavaScript console errors
4. Do NOT rely solely on unit tests for UI features

Browser tests catch issues that unit tests miss:
- CSS/layout problems
- JavaScript runtime errors
- Integration issues between frontend and backend
- Accessibility problems
```

### Success Criteria

- [ ] Review agent reviews all PRs
- [ ] No code merges without review
- [ ] E2E tests catch integration issues
- [ ] Four-layer validation used for decisions
- [ ] Browser automation verifies user-facing features

---

## Phase 5: Evolution & Memory (Week 4)

### Goal

Agents have **persistent memory** and **evolving personalities**.

### Checklist

```markdown
## Phase 5 Checklist

### Memory System
- [ ] All agents use recall_context on spawn
- [ ] Agents record tasks and learnings
- [ ] Weekly REM sleep consolidation
- [ ] Memory useful (not just growing)

### Character Development
- [ ] Core identity established for each agent
- [ ] Long-term insights accumulating
- [ ] Agents reference past learnings

### Agent Versioning
- [ ] Version numbers on prompts
- [ ] Changelog for prompt changes
- [ ] Behavior tests for regressions
```

### Implementation Steps

#### Step 1: Memory Usage in Agents

Add to every agent's turn:

```python
async def run_turn(self):
    """One turn of agent work."""

    # 1. Restore memory on spawn
    context = await self.memory.recall_context(self.name)
    print(f"[{self.name}] Context: {context}")

    # 2. Do work
    result = await self.do_assigned_work()

    # 3. Record completion
    await self.memory.add_recent_task(self.name, f"Completed {result['id']}")

    # 4. Record learnings (if any)
    if result.get("learnings"):
        for learning in result["learnings"]:
            await self.memory.add_recent_learning(self.name, learning)
```

#### Step 2: Weekly REM Sleep

Schedule consolidation:

```python
# scripts/weekly_rem_sleep.py
"""Run weekly memory consolidation for all agents."""

import asyncio
from agent_memory import MemoryStore

AGENTS = ["dev-backend", "dev-frontend", "dev-infrastructure", "research-analyst", "research-critic"]

async def consolidate_all():
    """Run REM sleep for all agents."""
    store = MemoryStore()

    for agent_id in AGENTS:
        print(f"Running REM sleep for {agent_id}...")
        result = await store.run_rem_sleep(agent_id)
        print(f"  {result}")

    print("Weekly consolidation complete!")

if __name__ == "__main__":
    asyncio.run(consolidate_all())
```

Add to crontab:
```bash
# Run every Sunday at 3am
0 3 * * 0 cd /path/to/project && python scripts/weekly_rem_sleep.py
```

#### Step 3: Agent Versioning

Track prompt versions:

```markdown
# .claude/agents/dev-backend.md

# Agent: Dev-Backend
**Version:** 1.3.0
**Last Updated:** 2024-12-15

## Changelog

### 1.3.0 (2024-12-15)
- Added explicit error handling requirement
- Removed allowance for silent fallbacks

### 1.2.0 (2024-12-10)
- Added test-first development requirement
- Clarified commit message format

### 1.1.0 (2024-12-07)
- Initial agent definition
- Basic responsibilities defined
```

### Success Criteria

- [ ] Agents recall context on spawn
- [ ] Memories consolidate without bloat
- [ ] Agents reference past learnings
- [ ] Prompt versions tracked

---

## Phase 6: Mastery & Continuous Improvement (Week 5+)

### Goal

System **improves itself**. You provide **vision**, agents execute.

### Checklist

```markdown
## Phase 6 Checklist

### Pattern Defeat Loop
- [ ] Pattern identification is routine
- [ ] Defeat tests written for each pattern
- [ ] Patterns don't recur

### Behavior Testing
- [ ] Behavior baseline defined
- [ ] Prompt changes trigger behavior tests
- [ ] Drift caught before shipping

### Mobile Workflow
- [ ] Can manage team from phone
- [ ] Quick commands documented
- [ ] Status available remotely

### Self-Improvement
- [ ] New agents spawn for new domains
- [ ] Old patterns permanently defeated
- [ ] Quality improves week-over-week
```

### Implementation Steps

#### Step 1: Pattern Defeat Cycle

Weekly ritual:

```markdown
## Pattern Defeat Template

### 1. Identify
**Pattern Name:** [Name]
**First Noticed:** [Date]
**Frequency:** [How often]
**Impact:** [What goes wrong]

### 2. Analyze
**Root Cause:** [Why it happens]
**Agent(s) Affected:** [Who]
**Trigger Conditions:** [When]

### 3. Test
**Test Name:** test_[pattern_name]
**Test File:** tests/patterns/test_[pattern].py
**What It Checks:** [Specific condition]

### 4. Implement
**Code Changes:** [What was fixed]
**Prompt Changes:** [What was added]
**Memory Added:** [What to remember]

### 5. Verify
**Test Passing:** [ ] Yes
**Pattern Recurrence:** [ ] None in 7 days
**Checklist Updated:** [ ] Yes
```

#### Step 2: Behavior Testing

```python
# tests/behavior/test_dev_backend_behavior.py
"""Behavior tests for Dev-Backend agent."""

from agents.testing import prompt_agent

class TestDevBackendBehavior:
    """Ensure Dev-Backend maintains expected behavior."""

    def test_uses_explicit_error_handling(self):
        """Dev-Backend should use explicit error handling."""
        response = prompt_agent("dev-backend",
            "Write a function to get a value from a dict")

        # Should NOT contain silent fallbacks
        assert ".get(" not in response or "raise" in response

    def test_writes_tests_first(self):
        """Dev-Backend should mention tests before implementation."""
        response = prompt_agent("dev-backend",
            "How would you implement user registration?")

        # Should mention tests early
        test_position = response.lower().find("test")
        impl_position = response.lower().find("implement")
        assert test_position < impl_position

    def test_maintains_personality(self):
        """Dev-Backend should maintain explicit/careful personality."""
        response = prompt_agent("dev-backend",
            "What's your approach to handling edge cases?")

        keywords = ["explicit", "validate", "check", "error", "test"]
        assert any(k in response.lower() for k in keywords)
```

#### Step 3: Continuous Improvement Metrics

Track these weekly:

```markdown
## Weekly Metrics

### Velocity
- Requirements completed: X
- Average time per requirement: X hours
- Phases per day: X

### Quality
- PRs blocked by review: X%
- PRs with changes requested: X%
- Test failures caught pre-commit: X

### Patterns
- New patterns identified: X
- Patterns defeated: X
- Recurring patterns: X (should be 0)

### Memory
- Total memories: X
- Consolidated this week: X
- Memory recall usefulness: [High/Medium/Low]
```

### Success Criteria

- [ ] Patterns defeated permanently
- [ ] Behavior tests catch regressions
- [ ] Week-over-week quality improvement
- [ ] You provide vision, not direction

---

## Automated Phase Implementation

**File: `scripts/04-implement-phases.sh`**

```bash
#!/bin/bash
# scripts/04-implement-phases.sh
set -e

echo "=== Agentic SDLC Phase Implementation ==="
echo ""
echo "This script guides you through the implementation phases."
echo "Each phase has its own verification before proceeding."
echo ""

# Phase 1
echo "=== PHASE 1: First Agent (Days 1-3) ==="
echo ""
echo "Goals:"
echo "  - Get one agent reliably committing code"
echo "  - Document any issues for prompt iteration"
echo ""
echo "Steps:"
echo "  1. Create simple REQ-001 in plans/roadmap.md"
echo "  2. Invoke Dev-Backend agent on the requirement"
echo "  3. Observe and document results"
echo "  4. Iterate on prompt until 3 requirements complete unassisted"
echo ""
read -p "Press Enter when Phase 1 is complete..."

# Phase 2
echo ""
echo "=== PHASE 2: Process Gates (Days 4-7) ==="
echo ""
echo "Goals:"
echo "  - Add automated enforcement (pre-commit hooks)"
echo "  - Create first pattern defeat tests"
echo "  - Add second agent"
echo ""

# Install pre-commit if not already
if ! pre-commit --version > /dev/null 2>&1; then
    pip install pre-commit
fi

# Create pattern test directory
mkdir -p tests/patterns

# Install hooks
pre-commit install

echo "Pre-commit hooks installed."
echo ""
echo "Steps:"
echo "  1. Create defeat test in tests/patterns/"
echo "  2. Verify pre-commit rejects bad patterns"
echo "  3. Define second agent (Dev-Frontend or Dev-Infrastructure)"
echo "  4. Test second agent on independent requirement"
echo ""
read -p "Press Enter when Phase 2 is complete..."

# Continue for remaining phases...
echo ""
echo "=== Phases 3-6 require ongoing iteration ==="
echo ""
echo "Continue with manual implementation following:"
echo "  - 04-Implementation-Phases.md"
echo "  - 05-Operations.md"
echo "  - 06-Patterns-and-Defeats.md"
echo ""
echo "Remember: Agent teams reach mastery in ~5 weeks."
echo "Trust the process!"
```

---

## Next Steps

After completing Phase 2:

1. **Continue phases manually** as your team matures
2. **Reference:** [05-Operations](05-Operations.md) for daily/weekly rituals
3. **Reference:** [06-Patterns-and-Defeats](06-Patterns-and-Defeats.md) for TDD
