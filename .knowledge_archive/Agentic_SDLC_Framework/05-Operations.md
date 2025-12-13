# 05: Operations

> Daily rituals, weekly refactors, and long-term operation of agent teams.

---

## Overview

| Item | Purpose |
|------|---------|
| **Time Required** | Ongoing (15 min/day, 2-3 hrs/week) |
| **Output** | Sustainable agent team operation |
| **Automation** | Monitoring scripts and scheduled tasks |
| **Prerequisites** | [04-Implementation-Phases](04-Implementation-Phases.md) Phase 2+ |

---

## Operating Philosophy

### The Core Insight

> **With humans:** Change is expensive. Minimize it.
>
> **With agents:** Change is free. Maximize it.

Agents don't have:
- Change fatigue
- Ego about "their" code
- Resistance to new patterns
- Institutional memory that fights improvement

**Take advantage of this.** Weekly refactors aren't overhead—they're the point.

### Time Investment Curve

```
                    │
 Time saved by     │                          ╭──────
 agents            │                      ╭───╯
                   │                  ╭───╯
                   │              ╭───╯
                   │          ╭───╯
                   │      ╭───╯
                   │  ╭───╯
                   │ ╱
 Time spent on    │╱
 process          │──────╮
                   │      ╰───╮
                   │          ╰───╮
                   │              ╰───╮
                   │                  ╰───
                   └────────────────────────────────
                   Day 1              Week 4

The lines cross around Day 3-4.
After that, process investment pays dividends.
```

---

## Session Initialization Protocol

> Based on Anthropic's research on effective harnesses for long-running agents.

### The Two-Part Agent Harness

Every work session follows a two-part pattern:

```text
┌─────────────────────────────────────────────────────────────────────┐
│                     SESSION ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  FIRST SESSION (Initializer Phase)                                  │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │ 1. Create progress/REQ-XXX-progress.md                      │    │
│  │ 2. Document initial state assessment                         │    │
│  │ 3. Plan approach and files to touch                          │    │
│  │ 4. Make initial commit: "🚀 Begin REQ-XXX"                   │    │
│  │ 5. Then proceed to coding                                    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              ↓                                       │
│  SUBSEQUENT SESSIONS (Coding Phase)                                 │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │ 1. recall_context(agent_id) - Load memories                 │    │
│  │ 2. Read progress/REQ-XXX-progress.md                         │    │
│  │ 3. git log --oneline -10 - What changed?                     │    │
│  │ 4. Run E2E tests - Is system still working?                  │    │
│  │ 5. Identify next smallest increment                          │    │
│  │ 6. Complete ONE feature, commit, document                    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### First Session Protocol (Initializer Phase)

When an agent first touches a new work item:

**1. Create Progress File**

```markdown
# Progress: REQ-XXX - [Title]

## Initial State Assessment
- Current codebase state: [description]
- Related files: [list]
- Dependencies: [list]

## Planned Approach
- Step 1: [description]
- Step 2: [description]
- Step 3: [description]

## Files to Touch
- [ ] path/to/file1.py
- [ ] path/to/file2.py

## Session Log
### Session 1 - [DATE]
- Started work on REQ-XXX
- [What was accomplished]
- [What remains]
```

**2. Make Initial Commit**

```bash
git add progress/REQ-XXX-progress.md
git commit -m "🚀 Begin REQ-XXX: [Brief description]

Initial state documented.
Approach planned.

Status: IN_PROGRESS

🤖 Generated with Claude Code"
```

**3. Then Proceed to Coding Phase**

### Subsequent Session Protocol (Coding Phase)

Every session after the first:

```markdown
## Session Startup Checklist (Execute in Order)

1. [ ] `pwd` - Verify correct project directory
2. [ ] `recall_context(agent_id)` - Load memories
3. [ ] Read `progress/REQ-XXX-progress.md` - What was I doing?
4. [ ] `git log --oneline -10` - What changed since last session?
5. [ ] Run tests: `pytest tests/ -x -q` - Is system still working?
6. [ ] Check roadmap - What's my current assignment?
7. [ ] Identify next smallest increment - What can I complete this session?

**CRITICAL:** If tests fail at step 5, FIX THAT FIRST before any new work.
```

### Session Shutdown Protocol

Before context ends:

```markdown
## Session Shutdown Checklist

1. [ ] Commit all work with descriptive message
2. [ ] Update `progress/REQ-XXX-progress.md` with:
   - What was accomplished this session
   - What remains to be done
   - Any blockers or issues discovered
3. [ ] If work complete: Signal to PM, archive progress file
4. [ ] If work incomplete: Document exact stopping point
```

### Progress File Location

```text
progress/
├── REQ-001-progress.md
├── REQ-002-progress.md
└── archive/
    └── REQ-000-progress.md  # Completed work
```

---

## Daily Operations

### Morning Review (15 minutes)

**When:** Start of your work day
**Purpose:** Catch issues from overnight work

```markdown
## Morning Review Checklist

### Overnight Results (5 min)
- [ ] Check git log: any commits from last night?
- [ ] Check CI/CD: any failures?
- [ ] Check NATS queues: any stuck messages?

### Agent Health (5 min)
- [ ] Review agent memories: any concerning learnings?
- [ ] Check error logs: new patterns?
- [ ] Token usage: within budget?

### Priority Check (5 min)
- [ ] Review roadmap: what's in progress?
- [ ] Any blockers to address?
- [ ] Set focus for today
```

**Script: `scripts/morning-review.sh`**

```bash
#!/bin/bash
# scripts/morning-review.sh

echo "=== Morning Review ==="
echo ""

echo "## Git Activity (last 24h)"
git log --since="24 hours ago" --oneline

echo ""
echo "## CI/CD Status"
# Check GitHub Actions or your CI
gh run list --limit 5

echo ""
echo "## NATS Queue Depths"
nats stream info WORK --json | jq '.state.messages'
nats stream info INTEGRATION --json | jq '.state.messages'

echo ""
echo "## Token Usage"
# Read from your tracking system
cat ~/.agent-metrics/daily-tokens.log | tail -1

echo ""
echo "## Roadmap Status"
head -50 plans/roadmap.md
```

### Evening Handoff (10 minutes)

**When:** End of your work day
**Purpose:** Set up overnight work

```markdown
## Evening Handoff Checklist

### Current Work (3 min)
- [ ] Review day's commits
- [ ] Archive any completed phases
- [ ] Update roadmap status

### Overnight Setup (5 min)
- [ ] Set overnight priorities in roadmap
- [ ] Ensure NATS queues have work
- [ ] Verify agents are healthy

### Systems Check (2 min)
- [ ] NATS server running
- [ ] Memory server running
- [ ] No stuck processes
```

**Script: `scripts/evening-handoff.sh`**

```bash
#!/bin/bash
# scripts/evening-handoff.sh

echo "=== Evening Handoff ==="
echo ""

echo "## Today's Commits"
git log --since="8 hours ago" --oneline

echo ""
echo "## Current Work"
grep -A5 "🟡" plans/roadmap.md

echo ""
echo "## Services Status"
pgrep -f nats-server > /dev/null && echo "✓ NATS running" || echo "✗ NATS stopped"
pgrep -f agent-memory > /dev/null && echo "✓ Memory running" || echo "✗ Memory stopped"

echo ""
echo "## Overnight Queue"
nats stream info WORK --json | jq '.state.messages'
```

---

## Weekly Operations

### The Weekly Refactor (2-3 hours)

**When:** Same day each week (e.g., Friday afternoon)
**Purpose:** Continuous improvement of agent team

```
┌─────────────────────────────────────────────────────────────────────┐
│                     WEEKLY REFACTOR PHASES                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Phase 1           Phase 2           Phase 3           Phase 4      │
│  ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐    │
│  │ Pattern │  →   │ Defeat  │  →   │ Prompt  │  →   │ Memory  │    │
│  │  Hunt   │      │  Tests  │      │ Refactor│      │ Consol  │    │
│  │ 30 min  │      │ 30 min  │      │ 30 min  │      │ 20 min  │    │
│  └─────────┘      └─────────┘      └─────────┘      └─────────┘    │
│                                                                      │
│  Phase 5           Phase 6                                          │
│  ┌─────────┐      ┌─────────┐                                       │
│  │  Arch   │  →   │ Version │                                       │
│  │  Check  │      │ Deploy  │                                       │
│  │ 20 min  │      │ 10 min  │                                       │
│  └─────────┘      └─────────┘                                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Phase 1: Pattern Hunt (30 min)

Look for recurring issues:

```markdown
## Pattern Hunt Worksheet

### Sources to Review

- [ ] Git log (what got fixed repeatedly?)
- [ ] Agent memories (what did they learn?)
- [ ] Review comments (recurring feedback?)
- [ ] Your frustrations (what annoyed you?)

### Patterns Found

| Pattern | Frequency | Impact | Priority |
|---------|-----------|--------|----------|
| [Name]  | [Daily/Weekly] | [High/Med/Low] | Impact × Frequency |

### Top 3 to Defeat

1. [Pattern]
2. [Pattern]
3. [Pattern]
```

#### Phase 2: Defeat Tests (30 min)

Write tests for each pattern:

```python
# tests/patterns/test_week_X_patterns.py
"""
Patterns defeated in Week X.
"""

def test_[pattern_1]():
    """
    Defeat: [Pattern name]
    Found: [Date]
    Impact: [What went wrong]
    """
    # Test implementation
    pass

def test_[pattern_2]():
    """
    Defeat: [Pattern name]
    Found: [Date]
    Impact: [What went wrong]
    """
    # Test implementation
    pass
```

#### Phase 3: Prompt Refactor (30 min)

Update agent prompts based on learnings:

```markdown
## Prompt Changes This Week

### Dev-Backend

**Added:**
- [ ] New discipline rule: [Description]
- [ ] Learning from pattern: [Description]

**Removed:**
- [ ] Outdated instruction: [Description]

### Dev-Frontend

**Added:**
- [ ] ...

### Version Bumps
- Dev-Backend: 1.2.0 → 1.3.0
- Dev-Frontend: 1.1.0 → 1.2.0
```

#### Phase 4: Memory Consolidation (20 min)

Run REM sleep and verify:

```bash
# Run consolidation
python scripts/weekly_rem_sleep.py

# Review results
for agent in dev-backend dev-frontend dev-infrastructure research-analyst; do
    echo "=== $agent memories ==="
    python -c "
from scripts.agent_memory_server import MemoryStore
store = MemoryStore()
mem = store.get_or_create('$agent')
print(f'Long-term: {len(mem.long_term_insights)}')
print(f'Medium-term: {len(mem.medium_term_patterns)}')
print(f'Recent: {len(mem.recent_tasks)}')
print(f'Learnings: {len(mem.recent_learnings)}')
"
done
```

#### Phase 5: Architecture Check (20 min)

Evaluate team structure:

```markdown
## Architecture Review

### Agent Roles
- [ ] Any agents that should split? (doing too much)
- [ ] Any agents that should merge? (overlapping)
- [ ] New specialist needed? (emerging domain)
- [ ] Any agents underperforming?

### Infrastructure
- [ ] NATS queues healthy?
- [ ] Memory storage adequate?
- [ ] CI/CD pipeline efficient?

### Scaling
- [ ] Could we add more parallel workers?
- [ ] Any bottlenecks in coordination?
```

#### Phase 6: Version & Deploy (10 min)

Finalize changes:

```bash
# Bump versions if needed
# Update behavior baselines
# Verify tests pass

./AgenticSDLC-Unified/scripts/verify-all.sh

# If all green, done
echo "Weekly refactor complete!"
```

### Weekly Refactor Checklist

```markdown
## Weekly Refactor Checklist

Date: [YYYY-MM-DD]

### Pattern Hunt
- [ ] Reviewed git history
- [ ] Reviewed agent memories
- [ ] Reviewed review comments
- [ ] Identified top 3 patterns

### Defeat Tests
- [ ] Test written for pattern 1
- [ ] Test written for pattern 2
- [ ] Test written for pattern 3
- [ ] All tests added to pre-commit

### Prompt Refactor
- [ ] Dev-Backend updated (if needed)
- [ ] Dev-Frontend updated (if needed)
- [ ] Dev-Infrastructure updated (if needed)
- [ ] Research-Analyst updated (if needed)
- [ ] Research-Critic updated (if needed)
- [ ] Versions bumped

### Memory Consolidation
- [ ] REM sleep run for all agents
- [ ] Memory sizes reviewed
- [ ] Stale memories cleared

### Architecture
- [ ] Team structure reviewed
- [ ] No splitting/merging needed
- [ ] Infrastructure healthy

### Deployment
- [ ] All tests passing
- [ ] Behavior tests passing
- [ ] New versions live

### Notes
[Any observations or concerns for next week]
```

---

## Monthly Operations

### Monthly Review (1 hour)

**When:** First week of each month
**Purpose:** Strategic assessment and long-term planning

```markdown
## Monthly Review Template

### Velocity Metrics

| Week | Phases Completed | Avg Time/Phase | Patterns Defeated |
|------|------------------|----------------|-------------------|
| 1    |                  |                |                   |
| 2    |                  |                |                   |
| 3    |                  |                |                   |
| 4    |                  |                |                   |

### Quality Metrics

| Metric | Start of Month | End of Month | Trend |
|--------|----------------|--------------|-------|
| PRs with changes requested |  |  |  |
| Test failures caught |  |  |  |
| Patterns recurring |  |  |  |

### Agent Evolution

| Agent | Version Start | Version End | Key Changes |
|-------|---------------|-------------|-------------|
| Dev-Backend       |               |             |             |
| Dev-Frontend      |               |             |             |
| Dev-Infrastructure|               |             |             |
| Research-Analyst  |               |             |             |
| Research-Critic   |               |             |             |

### Memory Health

| Agent | Long-term | Medium-term | Recent | Status |
|-------|-----------|-------------|--------|--------|
| Dev-Backend       |           |             |        | ✓/⚠/✗ |
| Dev-Frontend      |           |             |        | ✓/⚠/✗ |
| Dev-Infrastructure|           |             |        | ✓/⚠/✗ |
| Research-Analyst  |           |             |        | ✓/⚠/✗ |
| Research-Critic   |           |             |        | ✓/⚠/✗ |

### Costs

| Category | Budget | Actual | Variance |
|----------|--------|--------|----------|
| Claude API |  |  |  |
| Infrastructure |  |  |  |
| Total |  |  |  |

### Strategic Questions

1. Are we building the right things?
2. Is the agent team structure optimal?
3. What's blocking faster progress?
4. What should we stop doing?
5. What should we start doing?

### Goals for Next Month

1. [Goal]
2. [Goal]
3. [Goal]
```

---

## Monitoring & Alerts

### Key Metrics to Track

```yaml
# metrics.yaml
metrics:
  # Velocity
  - name: phases_completed_per_day
    source: git_commits
    threshold: "< 1.5 triggers warning"

  # Quality
  - name: test_failures_per_week
    source: ci_logs
    threshold: "> 5 triggers alert"

  - name: patterns_recurring
    source: defeat_tests
    threshold: "> 0 triggers investigation"

  # Costs
  - name: daily_token_usage
    source: api_logs
    threshold: "> budget triggers pause"

  # Health
  - name: nats_queue_depth
    source: nats_metrics
    threshold: "> 100 triggers warning"

  - name: memory_size_mb
    source: memory_file
    threshold: "> 50 triggers consolidation"
```

### Alert Script

```bash
#!/bin/bash
# scripts/check-alerts.sh

echo "=== Checking Alerts ==="

# Queue depth
QUEUE=$(nats stream info WORK --json | jq '.state.messages')
if [ "$QUEUE" -gt 100 ]; then
    echo "⚠ ALERT: Work queue depth at $QUEUE"
fi

# Token usage
TOKENS=$(cat ~/.agent-metrics/daily-tokens.log | tail -1)
if [ "$TOKENS" -gt 1000000 ]; then
    echo "⚠ ALERT: Token usage at $TOKENS"
fi

# Memory size
MEMORY_SIZE=$(wc -c < ~/.agent-memory/memories.json)
if [ "$MEMORY_SIZE" -gt 52428800 ]; then  # 50MB
    echo "⚠ ALERT: Memory file at $(($MEMORY_SIZE / 1048576))MB"
fi

# Test status
if ! pytest tests/ -x -q > /dev/null 2>&1; then
    echo "✗ ALERT: Tests failing"
fi

echo "=== Alert check complete ==="
```

### Scheduled Monitoring

Add to crontab:

```bash
# Morning check (before you start)
30 8 * * * cd /path/to/project && ./scripts/morning-review.sh > ~/.agent-logs/morning.log 2>&1

# Hourly alert check
0 * * * * cd /path/to/project && ./scripts/check-alerts.sh >> ~/.agent-logs/alerts.log 2>&1

# Weekly consolidation (Sunday 3am)
0 3 * * 0 cd /path/to/project && python scripts/weekly_rem_sleep.py >> ~/.agent-logs/consolidation.log 2>&1
```

---

## Failure Modes & Recovery

### Failure Mode 1: Runaway Costs

**Symptoms:** Token usage spikes, unexpected bills

**Prevention:**
- Set hard budget limits via Privacy.com
- Configure daily token caps
- Alert on unusual usage

**Recovery:**
```bash
# Pause all agents
pkill -f "agent"

# Review what happened
cat ~/.agent-logs/alerts.log

# Identify cause
grep "tokens" ~/.agent-metrics/*.log | sort -t: -k2 -n

# Fix and resume with limits
```

### Failure Mode 2: Queue Backup

**Symptoms:** NATS queues growing, work not completing

**Prevention:**
- Monitor queue depths
- Alert on > 100 pending
- Rate limit agent submissions

**Recovery:**
```bash
# Check queue status
nats stream info WORK

# See what's stuck
nats consumer info WORK worker-consumer

# Clear if needed (careful!)
nats stream purge WORK --force

# Restart agents
./scripts/restart-agents.sh
```

### Failure Mode 3: Memory Bloat

**Symptoms:** Slow recall, context window issues

**Prevention:**
- Weekly REM sleep
- Monitor memory file size
- Limit entries per layer

**Recovery:**
```bash
# Force consolidation
python scripts/weekly_rem_sleep.py

# If still too large, manual cleanup
python -c "
from scripts.agent_memory_server import MemoryStore
store = MemoryStore()
for agent_id in ['dev-backend', 'dev-frontend', 'dev-infrastructure']:
    mem = store.get_or_create(agent_id)
    # Keep only recent
    mem.recent_tasks = mem.recent_tasks[-10:]
    mem.recent_learnings = mem.recent_learnings[-10:]
    store.update(mem)
"
```

### Failure Mode 4: Personality Drift

**Symptoms:** Agent behavior changes unexpectedly

**Prevention:**
- Behavior tests for key traits
- Version control on prompts
- Regular behavior audits

**Recovery:**
```bash
# Run behavior tests
pytest tests/behavior/ -v

# If failing, check recent prompt changes
git log --oneline .claude/agents/

# Revert if needed
git checkout HEAD~1 -- .claude/agents/roy.md

# Or update behavior baseline if drift was intentional
python scripts/update_behavior_baseline.py
```

---

## The Sustainable Pace

### What Sustainable Looks Like

```markdown
## Daily Time Investment

| Activity | Time | When |
|----------|------|------|
| Morning review | 15 min | Start of day |
| Monitoring | 5 min | Periodically |
| Evening handoff | 10 min | End of day |
| **Total** | **30 min/day** | |

## Weekly Time Investment

| Activity | Time | When |
|----------|------|------|
| Weekly refactor | 2-3 hours | Friday |
| Ad-hoc issues | 1-2 hours | As needed |
| **Total** | **3-5 hours/week** | |
```

### What Unsustainable Looks Like

- 12-hour coding marathons
- "I'll sleep when the sprint is done"
- Checking agent status at 3am
- Skipping meals to fix "one more thing"
- Weekend work as default

### The Goal

After ~5 weeks, you should be:

- **Providing vision**, not direction
- **Reviewing strategy**, not code
- **Making decisions**, not implementations
- **Enjoying output**, not grinding

---

## Next Steps

1. **Reference:** [06-Patterns-and-Defeats](06-Patterns-and-Defeats.md) for TDD approach
2. **Set up:** Monitoring scripts from this document
3. **Schedule:** Weekly refactor on your calendar
4. **Commit:** To sustainable pace
