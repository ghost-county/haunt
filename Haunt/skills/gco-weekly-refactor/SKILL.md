---
name: gco-weekly-refactor
description: Structured 2-3 hour weekly ritual for continuous improvement of agent teams and codebase. Use when planning weekly maintenance, running refactor sessions, or improving agent prompts. Triggers on "weekly refactor", "weekly review", "maintenance ritual", "improve agents", "Friday refactor", or scheduled improvement time.
---

# Weekly Refactor Ritual

2-3 hour structured session for continuous improvement.

## Phase Overview

| Phase | Duration | Focus |
|-------|----------|-------|
| 0. Metrics Review | 10 min | Context overhead and regression check |
| 0.5. Regression Check | 10 min | Compare against baseline |
| 1. Pattern Hunt | 30 min | Find recurring issues |
| 2. Defeat Tests | 30 min | Write tests for patterns |
| 3. Prompt Refactor | 30 min | Update agent prompts |
| 4. Context Audit | 20 min | Review instruction count |
| 5. Memory Consolidation | 20 min | Run REM sleep |
| 6. Architecture Check | 20 min | Team structure review |
| 7. Version & Deploy | 10 min | Finalize changes |

---

## Phase 0: Metrics Review (10 min)

### Collect Current Metrics

Run the metrics script to establish baseline:

```bash
# Extract all metrics (includes context overhead by default)
bash Haunt/scripts/haunt-metrics.sh

# Save metrics for comparison
bash Haunt/scripts/haunt-metrics.sh --format=json > .haunt/metrics/weekly-$(date +%Y-%m-%d).json
```

### Metrics to Review

- **Context Overhead:** Total agent + rules + CLAUDE.md lines
- **Completion Rate:** Percentage of requirements completed
- **First-Pass Success:** Requirements without fix/revert commits
- **Average Cycle Time:** Time from first commit to completion

### Metrics Review Checklist

- [ ] Context overhead measured
- [ ] Baseline saved (if first week)
- [ ] Trends identified (increasing/decreasing)
- [ ] Anomalies noted (unexpected spikes)

**Output:** Current metrics snapshot and trend direction

---

## Phase 0.5: Regression Check (10 min)

### Compare Against Baseline

If baseline exists (after calibration period):

```bash
# Run regression check
bash Haunt/scripts/haunt-regression-check.sh

# Exit codes:
#   0 = All OK (within thresholds)
#   1 = Warnings detected
#   2 = Critical regressions
```

### Regression Response Decision Tree

```
Regression Check Result:
├─ OK (exit code 0)
│  └─ Continue to Phase 1 (Pattern Hunt)
│
├─ WARNING (exit code 1)
│  ├─ Check if expected (recent refactor, new features)
│  ├─ Note for Phase 4 (Context Audit)
│  └─ Continue to Phase 1 with increased scrutiny
│
└─ CRITICAL (exit code 2)
   ├─ STOP: Investigate immediately
   ├─ Identify root cause (which metric exceeded threshold)
   ├─ Decide:
   │  ├─ Roll back recent changes → Fix → Re-run check
   │  ├─ Justified increase → Update baseline after review
   │  └─ Refactor needed → Prioritize in Phase 3
   └─ DO NOT proceed until resolved or justified
```

### First Week (No Baseline Yet)

If no baseline exists:

```bash
# Create initial baseline (NOT calibrated yet)
bash Haunt/scripts/haunt-baseline.sh create "Weekly refactor baseline - Week 1"

# Wait 1 week for calibration
# During calibration: Run regression checks, verify stability
# After 1 week: If stable, mark calibrated and set active
```

### Calibration Period Guidance

**Week 1-4: Calibration Mode**
- Create baseline each week
- Run regression checks daily
- Track threshold violations
- Expect some variance (normal)
- Goal: Establish stable baseline over 4 weeks

**After 4 Weeks: Production Mode**
- Set calibrated baseline as active
- Regression violations are actionable signals
- Threshold breaches require investigation

### Regression Check Checklist

- [ ] Baseline exists (or created for Week 1)
- [ ] Regression check run
- [ ] Exit code checked (0/1/2)
- [ ] Warnings/criticals investigated
- [ ] Decision made (continue/stop/rollback)

**Output:** Regression status and action plan (if violations detected)

---

## Phase 1: Pattern Hunt (30 min)

### Sources to Review

```bash
# Git patterns (same files fixed repeatedly)
git log --oneline --since="7 days ago" | grep -i "fix\|bug\|oops"

# Files changed most often
git log --since="7 days ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -10

# Low first-pass success (from metrics)
# Review requirements with fix/revert commits for patterns
```

### Pattern Hunt Worksheet

| Pattern | Frequency | Impact | Priority | Metric Impact |
|---------|-----------|--------|----------|---------------|
| [Name] | [Daily/Weekly] | [High/Med/Low] | [Impact × Freq] | [Context/Quality] |

### Integrate Metrics Findings

**From Phase 0 Metrics:**
- If **completion rate low:** Investigate blockers in roadmap
- If **first-pass success low:** Patterns causing rework (prioritize)
- If **cycle time high:** Process inefficiencies or complex requirements
- If **context overhead high:** Rules/agents may be too verbose

**Priority Formula:**
```
Priority = (Frequency × Impact) + Metric_Signal
where Metric_Signal:
  - Context regression = +2 priority
  - Quality regression (first-pass) = +3 priority
  - Cycle time regression = +1 priority
```

### Sources Checklist
- [ ] Git log reviewed
- [ ] Metrics findings integrated (Phase 0 context)
- [ ] Agent memories checked
- [ ] Review comments scanned
- [ ] Personal frustrations noted

**Output:** Top 3 patterns to defeat this week (prioritized by metrics + frequency)

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

## Phase 4: Context Audit (20 min)

### Review Instruction Count

Audit agent prompts and rules for verbosity:

```bash
# Count instructions in rules
for rule in Haunt/rules/*.md; do
  echo "$(basename $rule): $(grep -iE '^\s*(MUST|NEVER|ALWAYS|DO NOT)' "$rule" | wc -l) instructions"
done

# Count effective lines (context overhead)
bash Haunt/scripts/haunt-metrics.sh | grep -A 10 "Context Overhead"
```

### Context Audit Worksheet

| File | Type | Lines | Instructions | Status |
|------|------|-------|--------------|--------|
| gco-*.md | Rule | XXX | YYY | OK/HIGH |
| gco-*.md | Agent | XXX | - | OK/HIGH |

**Thresholds:**
- Rules: <100 lines each (slim format)
- Agents: <150 lines each (focused)
- Total overhead: <1500 lines (all agents + rules + CLAUDE.md)

### Refactor Targets

If context overhead high (from Phase 0.5 regression):

**High-Value Refactors:**
1. **Extract to references/** - Move examples/tables to reference files
2. **Consultation gates** - Convert verbose sections to "READ file for details"
3. **Deduplicate** - Find repeated content across rules/agents
4. **Consolidate** - Merge overlapping rules if appropriate

**Example Patterns:**
```markdown
# BEFORE (verbose inline)
## Error Handling (50 lines of examples)
[Python example]
[JavaScript example]
[Go example]

# AFTER (slim with reference)
## Error Handling

⛔ **CONSULTATION GATE:** For language-specific error handling examples, READ `references/error-handling.md`.
```

### Context Audit Checklist

- [ ] Instruction count per rule reviewed
- [ ] Context overhead compared to baseline
- [ ] Refactor targets identified (if high)
- [ ] Extraction opportunities noted
- [ ] Consolidation candidates listed

**Output:** Refactor plan for context reduction (if needed)

---

## Phase 5: Memory Consolidation (20 min)

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

## Phase 6: Architecture Check (20 min)

### Team Structure Review

| Question | Answer |
|----------|--------|
| Any agents doing too much? (should split) | |
| Any agents overlapping? (should merge) | |
| New domain emerging? (need specialist) | |
| Any agents underperforming? | |

### Infrastructure Check

- [ ] Memory storage adequate (< 50MB)
- [ ] CI/CD pipeline efficient
- [ ] No bottlenecks identified

### Scaling Questions
- [ ] Could we add more parallel workers?
- [ ] Any coordination bottlenecks?

---

## Phase 7: Version & Deploy (10 min)

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

### Metrics Summary

**Context Overhead:**
- Total Lines: [current] (baseline: [baseline], Δ: [+/-X])
- Status: ✅ OK / ⚠️ WARNING / 🚨 CRITICAL

**Quality Metrics:**
- Completion Rate: [X]%
- First-Pass Success: [X]%
- Average Cycle Time: [X]h

**Regression Status:**
- Overall: ✅ OK / ⚠️ WARNING / 🚨 CRITICAL
- Violations: [None / List if any]

### Patterns Defeated
1. [Pattern]: [Brief description] (Metric impact: [Context/Quality/Cycle])
2. [Pattern]: [Brief description] (Metric impact: [Context/Quality/Cycle])

### Agent Updates
- [Agent]: [Change summary] (Lines: [before] → [after])

### Context Refactoring
- Rules refactored: [List]
- Total reduction: [X] lines
- Techniques used: [Extract/Gate/Consolidate]

### Memory Health
| Agent | Long-term | Medium | Recent | Status |
|-------|-----------|--------|--------|--------|
| dev-backend | X | X | X | ✓ |

### Architecture Decisions
- [Any changes or notes]

### Baseline Updates
- Baseline status: [Calibrating Week X/4 | Production]
- New baseline: [Created/Not created]
- Calibration notes: [Variance observed, stability assessment]

### Next Week Focus
- [Priority items based on metrics]
- [Regression follow-ups if any]
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
