# Workshop 2: Autonomous Workers

> *Set up Claude to work while you sleep.*

---

## Overview

| | |
|---|---|
| **Duration** | 60 minutes |
| **Format** | Hands-on setup with live deployment |
| **Output** | Running autonomous agent with test pipeline |
| **Prerequisites** | OpenSpec proposals from Workshop 1, Claude API access |

---

## Learning Objectives

By the end of this workshop, you will:

- Set up Claude in headless/autonomous mode
- Establish testing infrastructure for unsupervised code generation
- Configure pre-commit and post-commit hooks
- Understand why end-to-end tests are non-negotiable for autonomous work

---

## The Autonomous Worker Concept

**Traditional AI coding assistance:**

```
Human: Write a function
AI: Here's a function
Human: Now write tests
AI: Here's tests
Human: Run them
AI: They pass
Human: Commit
```

**Autonomous worker:**

```
Agent: [Reads next task from openspec/changes/[change]/tasks.md]
Agent: [Writes implementation]
Agent: [Writes tests]
Agent: [Runs tests]
Agent: [If passing, marks task complete and commits]
Agent: [Picks next task]
Agent: [Repeat until all tasks complete]
```

The human isn't in the loop. **The tests are in the loop.**

---

## Setting Up Headless Claude

### Option 1: Claude Code in Headless Mode

```bash
# Start Claude Code in non-interactive mode
claude --headless --task "Work through changes in openspec/changes/, implementing tasks from tasks.md files"
```

### Option 2: API-Based Autonomous Worker

```python
# autonomous_worker.py
import anthropic
import subprocess
import time

client = anthropic.Anthropic()

SYSTEM_PROMPT = """
You are an autonomous software developer. Your job is to:
1. Read active changes from openspec/changes/
2. For each change, read tasks from openspec/changes/[change-name]/tasks.md
3. Implement the next uncompleted task
4. Write tests for your implementation
5. Run tests
6. If tests pass, mark task as complete in tasks.md and commit
7. If tests fail, fix and retry (max 3 attempts)
8. Move to next task

You have access to:
- File read/write
- Shell commands (npm, pytest, git, etc.)
- The full codebase
- OpenSpec CLI (openspec list, openspec show, openspec archive)

Rules:
- Never commit failing tests
- Never skip writing tests
- Always reference change name and task in commits
- Mark tasks complete in tasks.md as you finish them
- Stop and report if you're stuck after 3 attempts
"""

def run_autonomous_cycle():
    # Implementation details...
    pass
```

### Option 3: Cloud VM with Scheduled Execution

```bash
# cron job on cloud VM
0 */2 * * * /home/agent/run_autonomous_worker.sh
```

This runs the autonomous worker every 2 hours, lets it drain its queue, then sleeps.

---

## Execution Cadence: Time-Based Scheduling

When you have multiple agents working in parallel, timing matters. Agents stepping on each other cause git conflicts, race conditions, and chaos.

### The Core Problem

```
Bad: Everyone runs at the same time

┌──────────┐  ┌──────────┐  ┌──────────┐
│ Worker A │  │ Worker B │  │  Merge   │
│ @ :00    │  │ @ :00    │  │  @ :00   │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     └─────────────┼─────────────┘
                   ▼
             💥 CONFLICTS
```

```
Good: Staggered execution

┌──────────┐       ┌──────────┐       ┌──────────┐
│ Worker A │       │ Worker B │       │  Merge   │
│ @ :00    │       │ @ :30    │       │  @ :45   │
└────┬─────┘       └────┬─────┘       └────┬─────┘
     │                  │                  │
     ▼                  ▼                  ▼
   work              work               merge
```

### The 15-Minute Offset Pattern

Use consistent offsets to prevent conflicts:

| Agent Type | Runs At | Rationale |
|------------|---------|-----------|
| Autonomous Worker | :00 | Primary work |
| Watcher/Health Check | :15 | Monitor status |
| Researcher Worker | :30 | Secondary work stream |
| Merge Orchestrator | :45 | Merge after work completes |

### Full Daily Schedule Example

| Time (UTC) | Autonomous | Researcher | Merge | Senior Review |
|------------|------------|------------|-------|---------------|
| 00:00-05:59 | 🌙 Sleep | 🌙 Sleep | ✅ :45 | - |
| 06:00 | - | - | ⏸️ | 🔍 DAILY |
| 06:15-06:44 | - | - | ⏸️ | (reviewing) |
| 07:00-07:59 | - | - | ✅ :45 | - |
| 08:00-22:00 | ✅ :00 | ✅ :30 | ✅ :45 | - |
| 23:00-23:59 | 🌙 Stop | 🌙 Stop | ✅ :45 | - |

### Why This Works

- **Overnight Merge Window** - 7 uninterrupted hours (23:00-06:00) for merge orchestrator
- **Morning Review** - Senior dev reviews at 06:00 before workers start
- **Work Hours** - Workers run during active hours (08:00-22:00)
- **15-Minute Separation** - Workers and merge never run simultaneously

### Implementing with Cron

```bash
# crontab for autonomous worker
# Runs every hour at :00, from 8am-10pm UTC
0 8-22 * * * /home/agent/run_worker.sh autonomous >> /var/log/autonomous.log 2>&1

# Researcher at :30
30 8-22 * * * /home/agent/run_worker.sh researcher >> /var/log/researcher.log 2>&1

# Merge orchestrator at :45 (including overnight)
45 * * * * /home/agent/run_merge.sh >> /var/log/merge.log 2>&1

# Senior review once daily at 6am
0 6 * * * /home/agent/run_review.sh >> /var/log/review.log 2>&1

# Watcher every hour at :15
15 * * * * /home/agent/run_watcher.sh >> /var/log/watcher.log 2>&1
```

### The Overnight Merge Window

**Why merge overnight?**

- **No Worker Conflicts** - Workers are sleeping, merge has exclusive git access
- **Clean Slate** - Morning starts with all branches merged
- **Uninterrupted Processing** - 7 hours to process accumulated branches

```
# Merge orchestrator runs 7 times overnight:
# 23:45, 00:45, 01:45, 02:45, 03:45, 04:45, 05:45
```

### Statistics for Reference

| Agent | Runs/Day | Active Hours |
|-------|----------|--------------|
| Autonomous Worker | 15 | 8am-10pm |
| Researcher Worker | 15 | 8am-10pm |
| Merge Orchestrator | 23 | All day (pause 6:00-6:44) |
| Senior Review | 1 | 6:00am |
| Watcher | 24 | All day |

---

## The Testing Infrastructure

### Why Tests Are Non-Negotiable

**When humans write code:**

- They can eyeball if it works
- They can test manually
- They can catch obvious bugs

**When agents write code unsupervised:**

- No one is watching
- Manual testing doesn't happen
- Bugs ship silently

**Tests are your only safety net.**

### The Testing Pyramid for Autonomous Development

```
         /\
        /  \
       / E2E \        <- Expensive but critical
      /--------\
     /Integration\    <- Catches component issues
    /--------------\
   /   Unit Tests   \ <- Fast, catch logic errors
  /------------------\
```

| Test Type | What It Catches | When to Run | Time |
|-----------|-----------------|-------------|------|
| Unit | Logic errors in functions | Every commit | Seconds |
| Integration | Component communication failures | Every commit | Minutes |
| End-to-End | Full flow failures | Every commit | Minutes |
| Front-End E2E | UI flow failures | Every commit | Minutes |

### The Front-End E2E Requirement

If your app has a UI, you need front-end E2E tests.

**Why?** Because the front end is where things break. The API can work perfectly, but if the button doesn't trigger the right call, or the response doesn't render correctly, users see a broken app.

```javascript
// playwright.config.js
module.exports = {
  testDir: './e2e',
  use: {
    baseURL: 'http://localhost:3000',
  },
  webServer: {
    command: 'npm run dev',
    port: 3000,
  },
};
```

```javascript
// e2e/user-flow.spec.js
test('user can complete checkout', async ({ page }) => {
  await page.goto('/');
  await page.click('[data-testid="add-to-cart"]');
  await page.click('[data-testid="checkout"]');
  await page.fill('[data-testid="email"]', 'test@example.com');
  await page.click('[data-testid="submit"]');
  await expect(page.locator('[data-testid="confirmation"]')).toBeVisible();
});
```

### The Cost Question

"E2E tests are expensive to run."

**Yes. Run them anyway.**

Math:

- E2E test run: $0.10 in compute
- Bug shipped to production: Hours of debugging, user trust lost, potential data issues
- 100 E2E runs per day: $10/day
- One prevented production bug: Priceless (or at least worth way more than $10)

**If you're going to have an autonomous worker autonomously working, you've got to run the tests.**

---

## Pre-Commit Hook Setup

Pre-commit hooks run before a commit is accepted. If they fail, the commit is rejected.

### Basic Setup

```bash
# .git/hooks/pre-commit
#!/bin/bash
set -e

echo "Running unit tests..."
npm run test:unit

echo "Running integration tests..."
npm run test:integration

echo "Running linter..."
npm run lint

echo "Running type check..."
npm run typecheck

echo "All checks passed!"
```

Make it executable:

```bash
chmod +x .git/hooks/pre-commit
```

### Using Husky (Recommended)

```bash
npm install husky --save-dev
npx husky install
npx husky add .git/hooks/pre-commit "npm run pre-commit"
```

```json
// package.json
{
  "scripts": {
    "pre-commit": "npm run lint && npm run typecheck && npm run test:unit && npm run test:integration",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration",
    "test:e2e": "playwright test"
  }
}
```

### For Python Projects

```bash
# .git/hooks/pre-commit
#!/bin/bash
set -e

echo "Running pytest..."
pytest tests/unit tests/integration

echo "Running mypy..."
mypy src/

echo "Running ruff..."
ruff check src/

echo "All checks passed!"
```

Or use pre-commit framework:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: pytest
        name: pytest
        entry: pytest tests/unit tests/integration
        language: system
        types: [python]
        pass_filenames: false
      - id: mypy
        name: mypy
        entry: mypy src/
        language: system
        types: [python]
        pass_filenames: false
```

---

## Post-Commit Hooks

Post-commit hooks run after a successful commit. Good for:

- Running expensive E2E tests
- Triggering deployments
- Notifying other agents
- Updating documentation

```bash
# .git/hooks/post-commit
#!/bin/bash

echo "Running E2E tests..."
npm run test:e2e

if [ $? -ne 0 ]; then
  echo "E2E tests failed! Reverting commit..."
  git revert HEAD --no-edit
  exit 1
fi

echo "Notifying release manager..."
curl -X POST http://localhost:8080/notify/commit \
  -H "Content-Type: application/json" \
  -d "{\"commit\": \"$(git rev-parse HEAD)\"}"
```

---

## The Autonomous Worker Loop

### Complete Implementation

```python
# autonomous_worker.py
import os
import subprocess
import json
from pathlib import Path
from anthropic import Anthropic

client = Anthropic()

class AutonomousWorker:
    def __init__(self, openspec_changes_dir: str = "openspec/changes", max_retries: int = 3):
        self.changes_dir = Path(openspec_changes_dir)
        self.max_retries = max_retries
        self.current_task = None

    def get_next_task(self) -> dict | None:
        """Find next uncompleted task from OpenSpec changes."""
        # Implementation:
        # 1. List directories in openspec/changes/
        # 2. For each change, read tasks.md
        # 3. Find first task that's not marked complete
        # 4. Return {change: str, task: str, task_index: int}
        pass

    def implement_task(self, task: dict) -> bool:
        """Use Claude to implement the task."""
        # Read the full proposal for context
        proposal_path = self.changes_dir / task['change'] / 'proposal.md'
        proposal = proposal_path.read_text()

        prompt = f"""
        Implement this task from the OpenSpec change "{task['change']}":

        Context (from proposal.md):
        {proposal}

        Task to implement:
        {task['task']}

        Write the implementation code and the tests.
        """

        response = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=4096,
            messages=[{"role": "user", "content": prompt}]
        )

        # Parse response, write files
        # Return True if successful
        pass

    def run_tests(self) -> bool:
        """Run the test suite."""
        result = subprocess.run(
            ["npm", "run", "test"],
            capture_output=True,
            text=True
        )
        return result.returncode == 0

    def commit(self, task: dict):
        """Commit changes with task reference."""
        subprocess.run(["git", "add", "."])
        subprocess.run([
            "git", "commit", "-m",
            f"{task['change']}: Complete task {task['task_index']}\n\n{task['task']}"
        ])

    def mark_task_complete(self, task: dict):
        """Mark task as complete in tasks.md."""
        tasks_path = self.changes_dir / task['change'] / 'tasks.md'
        # Implementation: Update tasks.md to mark task as complete
        pass

    def run(self):
        """Main autonomous loop."""
        while True:
            task = self.get_next_task()
            if not task:
                print("All tasks in openspec/changes/ complete!")
                break

            print(f"Working on {task['change']} - Task {task['task_index']}...")

            for attempt in range(self.max_retries):
                success = self.implement_task(task)
                if not success:
                    continue

                if self.run_tests():
                    self.commit(task)
                    self.mark_task_complete(task)
                    break
                else:
                    print(f"Tests failed, attempt {attempt + 1}/{self.max_retries}")
            else:
                print(f"Failed to complete task after {self.max_retries} attempts")
                self.flag_for_human_review(task)

if __name__ == "__main__":
    worker = AutonomousWorker("openspec/changes")
    worker.run()
```

---

## Exercise 2.1: Testing Pipeline Setup

**Time:** 30 minutes
**Output:** Working pre-commit hooks with full test coverage

### Part A: Create Test Structure (10 min)

Set up your test directories:

```
tests/
├── unit/
│   └── test_example.py
├── integration/
│   └── test_api.py
└── e2e/
    └── test_user_flow.py
```

Create at least one test in each category, even if it's just a placeholder:

```python
# tests/unit/test_example.py
def test_placeholder():
    """Replace with real unit tests."""
    assert True

# tests/integration/test_api.py
def test_placeholder():
    """Replace with real integration tests."""
    assert True
```

### Part B: Set Up Pre-Commit Hook (10 min)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
set -e
echo "=== Running Pre-Commit Checks ==="
echo "Unit tests..."
pytest tests/unit -v
echo "Integration tests..."
pytest tests/integration -v
echo "=== All Checks Passed ==="
```

Test it:

```bash
chmod +x .git/hooks/pre-commit
git add .
git commit -m "Test pre-commit hook"
```

### Part C: Set Up Post-Commit Hook (10 min)

Create `.git/hooks/post-commit`:

```bash
#!/bin/bash
echo "=== Running Post-Commit E2E Tests ==="
pytest tests/e2e -v

if [ $? -ne 0 ]; then
  echo "E2E tests failed!"
  echo "Consider reverting: git revert HEAD"
  exit 1
fi
echo "=== E2E Tests Passed ==="
```

---

## Exercise 2.2: Autonomous Worker Deployment

**Time:** 20 minutes
**Output:** Running autonomous worker on a cloud instance

### Part A: Prepare Cloud Instance

1. Spin up a small VM (AWS EC2, DigitalOcean, etc.)
2. Install dependencies:

```bash
sudo apt update
sudo apt install python3 python3-pip nodejs npm git
pip3 install anthropic
```

3. Clone your repo
4. Set up API keys:

```bash
export ANTHROPIC_API_KEY="your-key-here"
```

### Part B: Create Worker Script

Save the autonomous worker script from above as `autonomous_worker.py`.

### Part C: Test Manual Execution

```bash
python3 autonomous_worker.py
```

Watch it:
- Read next task from openspec/changes/
- Write code
- Run tests
- Mark task complete and commit (or retry)

### Part D: Schedule Autonomous Execution

```bash
# Add to crontab
crontab -e

# Run every 2 hours
0 */2 * * * cd /home/ubuntu/myproject && python3 autonomous_worker.py >> /var/log/agent.log 2>&1
```

---

## Common Issues

### Issue: Tests Pass Locally, Fail in Hook

Usually environment differences. Ensure:
- Same Node/Python version
- Same environment variables
- Dependencies installed

### Issue: Hook Takes Too Long

Split into pre-commit (fast) and post-commit (slow):
- Pre-commit: Unit tests, lint, typecheck
- Post-commit: Integration, E2E

### Issue: Agent Gets Stuck in Retry Loop

Add circuit breaker:

```python
if attempt >= max_retries:
    flag_for_human_review(task)
    skip_to_next_task()
```

### Issue: Commits Happening Too Fast

Add cooldown between commits:

```python
import time
time.sleep(60)  # Wait 1 minute between commits
```

---

## Checklist Before Going Autonomous

- [ ] Unit tests exist and pass
- [ ] Integration tests exist and pass
- [ ] E2E tests exist and pass
- [ ] Pre-commit hook runs all fast tests
- [ ] Post-commit hook runs E2E tests
- [ ] Failing E2E can trigger revert or flag
- [ ] Agent has clear stopping conditions
- [ ] Human notification on failures
- [ ] Logs are being captured
- [ ] API keys are secure (not in repo)

---

## What You'll Have After This Workshop

1. **Pre-commit hooks** that prevent bad commits
2. **Post-commit hooks** that catch integration issues
3. **Autonomous worker script** ready for cloud deployment
4. **Scheduled execution** for continuous development

Your agent can now work through OpenSpec changes while you sleep.

---

## Next Steps

- [Workshop 3 - Agent Orchestration](Workshop-3-Agent-Orchestration.md) - Add specialist agents and communication
- Start Phase 1 execution with your autonomous worker

---

**Previous:** [Workshop 1 - Planning and Requirements](Workshop-1-Planning-and-Requirements.md) | **Next:** [Workshop 3 - Agent Orchestration](Workshop-3-Agent-Orchestration.md)
