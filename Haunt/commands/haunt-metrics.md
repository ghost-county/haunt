---
name: haunt-metrics
description: Extract metrics from existing artifacts (git history, roadmap status changes, archived completions) with zero agent overhead.
---

# Haunt Metrics Command

**Alias:** `/haunt metrics`, `/metrics`

## Purpose

Extract performance metrics from existing artifacts WITHOUT requiring agents to log anything extra. Metrics are derived post-hoc from:

- **Git commit history** - REQ-XXX commit patterns and timestamps
- **Roadmap status changes** - ⚪→🟡→🟢 transitions
- **Archived completions** - Completed work metadata

## Metrics Extracted

| Metric | Source | Calculation |
|--------|--------|-------------|
| **Cycle Time** | Git commits + roadmap | Time from first REQ commit to 🟢 status |
| **Effort Accuracy** | Roadmap sizing + git | Estimated vs actual time (XS<1hr, S<2hr, M<4hr) |
| **First-Pass Success** | Git history | Commits without "fix", "revert", "oops" patterns |
| **Completion Rate** | Roadmap + archive | Requirements completed (🟢) vs abandoned |
| **Context Overhead** | Agent files, rules, CLAUDE.md, skills | Lines of context loaded before useful work (with --context) |

## Usage

```bash
# Basic usage - all metrics, text format
/haunt metrics

# JSON output (for tooling/dashboards)
/haunt metrics --format=json

# Specific requirement only
/haunt metrics --req=REQ-123

# Metrics since specific date
/haunt metrics --since=2025-12-01

# Include context overhead metrics
/haunt metrics --context

# Combined filters
/haunt metrics --format=json --since=2025-12-01 --context
```

## Output Formats

### Text Format (Default)

Human-readable summary with aggregate metrics:

```
═══════════════════════════════════════════
  Haunt Metrics - Post-Hoc Analysis
═══════════════════════════════════════════

═══ Individual Requirements ═══

  Requirement:      REQ-246
  Status:           🟢
  Effort Estimate:  S (2h expected)
  Cycle Time:       1h
  First-Pass:       Yes

  Requirement:      REQ-247
  Status:           🟢
  Effort Estimate:  S (2h expected)
  Cycle Time:       2h
  First-Pass:       Yes

═══ Aggregate Metrics ═══

  Total Requirements:    15
  Completed:             12 (80.0%)
  First-Pass Success:    10 (66.7%)
  Avg Cycle Time:        2.5h
```

### JSON Format

Machine-readable output for automation/dashboards:

```json
{
  "metrics": [
    {
      "requirement": "REQ-246",
      "status": "🟢",
      "effort_estimate": "S",
      "expected_hours": "2",
      "cycle_time": "1h",
      "first_pass_success": "Yes",
      "first_commit_ts": 1735570800,
      "last_commit_ts": 1735574400
    }
  ],
  "aggregate_metrics": {
    "total_requirements": 15,
    "completed_requirements": 12,
    "completion_rate": 80.0,
    "first_pass_successes": 10,
    "first_pass_rate": 66.7,
    "average_cycle_time_hours": 2.5
  },
  "context_overhead": {
    "agent_lines": 306,
    "rules_lines": 514,
    "claude_md_lines": 136,
    "estimated_skill_lines": 567,
    "base_overhead_lines": 956,
    "total_overhead_lines": 1523,
    "avg_skills_loaded_estimate": 3,
    "avg_skill_size_lines": 189,
    "total_skills_available": 29
  }
}
```

**Note:** `context_overhead` field only appears when `--context` flag is used.

## Metric Definitions

### Cycle Time

**Definition:** Time from first git commit mentioning REQ-XXX to requirement marked 🟢 Complete.

**Purpose:** Measures how long features take from start to delivery.

**Calculation:**
1. Find first commit with `[REQ-XXX]` in message
2. Find last commit before requirement marked 🟢
3. Calculate time difference in hours

**Example:**
- First commit: `[REQ-123] Add: Login form component` (2025-12-01 10:00)
- Last commit: `[REQ-123] Tests passing, mark complete` (2025-12-01 14:00)
- Cycle Time: **4h**

### Effort Accuracy

**Definition:** Comparison of estimated effort (XS/S/M) vs actual cycle time.

**Purpose:** Improves estimation accuracy over time by revealing patterns.

**Calculation:**
- XS estimate = 1h expected
- S estimate = 2h expected
- M estimate = 4h expected
- Compare actual cycle time to expected

**Example:**
- REQ-123 estimated as **S** (2h expected)
- Actual cycle time: **1h**
- Result: **Under-estimated** (could have been XS)

### First-Pass Success

**Definition:** Requirement implemented without follow-up "fix" commits.

**Purpose:** Measures code quality - high first-pass rate = fewer bugs.

**Calculation:**
1. Get all commits for REQ-XXX
2. Check if any contain: "fix", "revert", "oops", "undo", "wrong", "mistake"
3. If found: **No** (fixes were needed)
4. If not found: **Yes** (first implementation worked)

**Example:**
```bash
# REQ-123 commits:
[REQ-123] Add: Login form
[REQ-123] Fix: Validation not working  # ← FIX FOUND
[REQ-123] Tests passing

First-Pass Success: No
```

### Completion Rate

**Definition:** Percentage of started requirements that reached 🟢 Complete.

**Purpose:** Tracks project momentum and abandoned work.

**Calculation:**
1. Count requirements with any commits (started work)
2. Count requirements with 🟢 status (completed work)
3. Rate = (completed / started) * 100

**Example:**
- Started: 20 requirements (have commits)
- Completed: 16 requirements (status 🟢)
- Completion Rate: **80%** (4 abandoned)

### Context Overhead

**Definition:** Lines of context an agent consumes before doing useful work.

**Purpose:** Measures token/context efficiency and identifies opportunities for optimization.

**Calculation:**
```text
base_overhead = agent_lines + rules_lines + claude_md_lines
skill_overhead = avg_skills_loaded × avg_skill_size
total_context_overhead = base_overhead + skill_overhead
```

**Components:**
- **Agent Character Sheet**: Largest agent file (e.g., gco-dev.md)
- **Rules (all)**: Sum of all global rules (gco-*.md in Haunt/rules/)
- **CLAUDE.md**: Project-specific context
- **Estimated Skill Overhead**: Average skill size × estimated skills per session (default: 3)

**Example:**
```
Base Context:
  Agent Character Sheet:  306 lines
  Rules (all):            514 lines
  CLAUDE.md:              136 lines
  Subtotal:               956 lines

Estimated Skill Overhead:
  Avg Skills Loaded:      3 skills/session
  Avg Skill Size:         189 lines
  Subtotal:               567 lines

Total Context Overhead:   1523 lines
```

**Usage:**
- Enable with `--context` flag
- Track over time to detect context bloat
- Compare before/after refactoring (e.g., REQ-310 reduced gco-dev from 1,110 → 128 lines)

## When to Use

### Project Health Checks

Run periodically to track overall progress:

```bash
# Weekly health check
/haunt metrics --since=2025-12-24

# Sprint retrospective
/haunt metrics --since=2025-12-01
```

### Improve Estimations

Compare estimated vs actual effort to calibrate sizing:

```bash
# All completed requirements
/haunt metrics --format=json | jq '.metrics[] | select(.status == "🟢")'
```

### Identify Problem Areas

Find requirements with multiple fix commits:

```bash
# Requirements with low first-pass success
/haunt metrics --format=json | \
  jq '.metrics[] | select(.first_pass_success == "No")'
```

### Track Individual Requirements

Debug why specific requirement took longer than expected:

```bash
/haunt metrics --req=REQ-123
```

## Integration with Other Tools

### Dashboard Integration

Export JSON for visualization:

```bash
/haunt metrics --format=json > metrics-$(date +%Y-%m-%d).json
```

### CI/CD Quality Gates

Fail pipeline if completion rate drops below threshold:

```bash
completion_rate=$(/haunt metrics --format=json | jq '.aggregate_metrics.completion_rate')
if (( $(echo "$completion_rate < 75" | bc -l) )); then
  echo "ERROR: Completion rate below 75%"
  exit 1
fi
```

### Roadmap Reporting

Generate progress reports for stakeholders:

```bash
/haunt metrics --since=2025-12-01 > monthly-report-$(date +%Y-%m).txt
```

## Zero Agent Overhead

**Key principle:** Agents do NOT log metrics directly. They work normally, and metrics are extracted later.

**What agents do:**
- Commit with `[REQ-XXX]` convention (already standard practice)
- Update roadmap status (⚪→🟡→🟢) (already standard practice)
- Archive completed work (already standard practice)

**What metrics script does:**
- Parses git log for REQ patterns
- Extracts timestamps from commits
- Reads roadmap/archive for status and effort
- Calculates metrics from existing data

**No changes to agent workflows required.**

## Limitations

1. **Requires git history** - No metrics for requirements without commits
2. **Roadmap dependency** - Accurate status updates needed for completion metrics
3. **Commit convention** - Assumes `[REQ-XXX]` format used consistently
4. **Status transitions** - Can't detect ⚪→🟡→🟢 timing if roadmap not updated incrementally
5. **First-pass heuristic** - "fix" keyword detection may have false positives/negatives

## Examples

### Scenario 1: Weekly Team Review

**Goal:** See what got done this week and how estimation accuracy is trending.

```bash
/haunt metrics --since=2025-12-23
```

**Output:**
```
═══ Aggregate Metrics ═══

  Total Requirements:    5
  Completed:             4 (80.0%)
  First-Pass Success:    3 (60.0%)
  Avg Cycle Time:        3.2h
```

**Insight:** 80% completion rate is good, but 60% first-pass means quality issues. More careful implementation or better test coverage needed.

### Scenario 2: Estimate Calibration

**Goal:** Find out if we're consistently under/over-estimating S-sized work.

```bash
/haunt metrics --format=json | \
  jq '.metrics[] | select(.effort_estimate == "S") | {req: .requirement, cycle: .cycle_time, expected: .expected_hours}'
```

**Output:**
```json
{"req":"REQ-246","cycle":"1h","expected":"2"}
{"req":"REQ-247","cycle":"2h","expected":"2"}
{"req":"REQ-248","cycle":"3h","expected":"2"}
```

**Insight:** S-sized work averages 2h (1+2+3)/3, matching estimates. Estimation for S is accurate.

### Scenario 3: Identify Problem Requirements

**Goal:** Which requirements needed multiple fix attempts?

```bash
/haunt metrics --format=json | \
  jq -r '.metrics[] | select(.first_pass_success == "No") | .requirement'
```

**Output:**
```
REQ-248
REQ-251
```

**Action:** Review REQ-248 and REQ-251 commit history to understand what went wrong and prevent similar issues.

## See Also

- `gco-commit-conventions` - Commit format with REQ-XXX pattern
- `gco-roadmap-format` - Roadmap status update protocol
- `gco-completion-checklist` - When to mark requirements 🟢
- `.haunt/completed/roadmap-archive.md` - Archived completion metadata

## Implementation

**Script:** `Haunt/scripts/haunt-metrics.sh`
**Language:** Bash (portable, no dependencies beyond git/jq)
**Data Sources:** Git log, roadmap.md, roadmap-archive.md
**Output:** Text or JSON
