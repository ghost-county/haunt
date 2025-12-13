---
name: gco-weekly-refactor
description: Structured 2-3 hour weekly ritual for continuous improvement of agent teams and codebase. Use when planning weekly maintenance, running refactor sessions, or improving agent prompts. Triggers on "weekly refactor", "weekly review", "maintenance ritual", "improve agents", "Friday refactor", or scheduled improvement time.
---

# Weekly Refactor Ritual

2-3 hour structured session for continuous improvement.

## Phase Overview

| Phase | Duration | Focus |
|-------|----------|-------|
| 1. Pattern Hunt | 30 min | Find recurring issues |
| 2. Defeat Tests | 30 min | Write tests for patterns |
| 3. Prompt Refactor | 30 min | Update agent prompts |
| 4. Memory Consolidation | 20 min | Run REM sleep |
| 5. Architecture Check | 20 min | Team structure review |
| 6. Version & Deploy | 10 min | Finalize changes |

---

## Phase 1: Pattern Hunt (30 min)

### Sources to Review

```bash
# Git patterns (same files fixed repeatedly)
git log --oneline --since="7 days ago" | grep -i "fix\|bug\|oops"

# Files changed most often
git log --since="7 days ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -10
```

### Pattern Hunt Worksheet

| Pattern | Frequency | Impact | Priority |
|---------|-----------|--------|----------|
| [Name] | [Daily/Weekly] | [High/Med/Low] | [Impact × Freq] |

### Sources Checklist
- [ ] Git log reviewed
- [ ] Agent memories checked
- [ ] Review comments scanned
- [ ] Personal frustrations noted

**Output:** Top 3 patterns to defeat this week

---

## Phase 2: Defeat Tests (30 min)

For each pattern from Phase 1:

```python
# .haunt/tests/patterns/test_week_[N]_patterns.py
"""Patterns defeated in Week [N]."""

def test_[pattern_1]():
    """
    Defeat: [Pattern name]
    Found: [Date]
    Impact: [What went wrong]
    """
    # Detection implementation
    pass
```

### Checklist
- [ ] Test written for pattern 1
- [ ] Test written for pattern 2
- [ ] Test written for pattern 3
- [ ] All tests passing locally
- [ ] Added to pre-commit config

---

## Phase 3: Prompt Refactor (30 min)

Update agent prompts based on learnings.

### Change Template

```markdown
## Agent: [Name]

### Added
- [ ] New discipline rule: [Description]
- [ ] Learning from pattern: [Description]

### Removed  
- [ ] Outdated instruction: [Description]

### Version
[Previous] → [New]
```

### Checklist
- [ ] Dev-Backend updated (if needed)
- [ ] Dev-Frontend updated (if needed)
- [ ] Dev-Infrastructure updated (if needed)
- [ ] Research agents updated (if needed)
- [ ] Version numbers bumped
- [ ] Changelog entries added

---

## Phase 4: Memory Consolidation (20 min)

Run REM sleep for all agents:

```bash
# Run consolidation script
python scripts/weekly_rem_sleep.py

# Or manually for each agent
for agent in dev-backend dev-frontend dev-infrastructure; do
    echo "=== $agent ==="
    # Check memory sizes
done
```

### Checklist
- [ ] REM sleep completed for all agents
- [ ] Memory sizes reviewed (not bloating)
- [ ] Stale memories cleared
- [ ] Important learnings preserved

---

## Phase 5: Architecture Check (20 min)

### Team Structure Review

| Question | Answer |
|----------|--------|
| Any agents doing too much? (should split) | |
| Any agents overlapping? (should merge) | |
| New domain emerging? (need specialist) | |
| Any agents underperforming? | |

### Infrastructure Check

- [ ] NATS queues healthy (depth < 100)
- [ ] Memory storage adequate (< 50MB)
- [ ] CI/CD pipeline efficient
- [ ] No bottlenecks identified

### Scaling Questions
- [ ] Could we add more parallel workers?
- [ ] Any coordination bottlenecks?

---

## Phase 6: Version & Deploy (10 min)

```bash
# Run full verification
pytest tests/ -v
pytest .haunt/tests/patterns/ -v
pytest .haunt/tests/behavior/ -v

# If all green, commit changes
git add .claude/agents/ .haunt/tests/patterns/
git commit -m "Weekly refactor: [summary]"
```

### Final Checklist
- [ ] All tests passing
- [ ] Behavior tests passing
- [ ] Changes committed
- [ ] Team notified (if applicable)

---

## Weekly Report Template

```markdown
## Weekly Refactor Report - Week [N]

### Patterns Defeated
1. [Pattern]: [Brief description]
2. [Pattern]: [Brief description]

### Agent Updates
- [Agent]: [Change summary]

### Memory Health
| Agent | Long-term | Medium | Recent | Status |
|-------|-----------|--------|--------|--------|
| dev-backend | X | X | X | ✓ |

### Architecture Decisions
- [Any changes or notes]

### Next Week Focus
- [Priority items]
```

---

## Quick Reference: When to Do What

| If you notice... | Do this... |
|-----------------|------------|
| Same bug 3+ times | Add to pattern hunt list |
| Agent ignoring instruction | Check prompt clarity |
| Memory growing too fast | Force consolidation |
| Two agents conflicting | Review responsibilities |
| New domain in project | Consider new specialist |
