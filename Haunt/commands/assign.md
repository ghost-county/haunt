# Assign - Bind Agent to Requirement

Assign yourself (the current agent) to a specific requirement for the session. This command:

1. Marks the requirement as 🟡 In Progress in the roadmap
2. Sets session context to that requirement
3. Loads requirement details into working memory for easy reference

## Usage

```
/assign REQ-XXX
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `REQ-XXX` | Yes | Requirement ID to assign (e.g., REQ-312, REQ-042) |

## Options

| Option | Description |
|--------|-------------|
| `--force` | Skip validation checks (not recommended) |
| `--dry-run` | Preview assignment without making changes |

## Examples

```bash
# Assign yourself to REQ-312
/assign REQ-312

# Preview assignment without changes
/assign REQ-312 --dry-run

# Force assignment even if already in progress
/assign REQ-312 --force
```

## What It Does

### 1. Validation

Before assigning, the command checks:

- ✓ Requirement exists in roadmap
- ✓ Requirement is not blocked (status != 🔴)
- ✓ Requirement is not already complete (status != 🟢)
- ✓ Agent type matches requirement (if specified)

### 2. Status Update

Updates the requirement status in `.haunt/plans/roadmap.md`:

```markdown
Before:
⚪ REQ-312: Add Context Overhead Metric

After:
🟡 REQ-312: Add Context Overhead Metric
```

### 3. Context Loading

Outputs requirement details for your working context:

```
✓ Assigned to REQ-312: Add Context Overhead Metric

  Type: Enhancement
  Agent: Dev-Infrastructure
  Effort: M (2-4 hours)
  Complexity: MODERATE
  Status: ⚪ → 🟡

  Description:
  Add context overhead measurement to haunt-metrics. Context overhead =
  how much context an agent consumes before doing useful work.

  Tasks:
  - [ ] Add measure_context_overhead() function to haunt-metrics.sh
  - [ ] Calculate base overhead (agent + rules + CLAUDE.md)
  - [ ] Estimate skill overhead (top 5 most-used skills × avg size)
  - [ ] Add --context flag to output context metrics
  - [ ] Include context_overhead in JSON output
  - [ ] Add context overhead to aggregate metrics

  Files:
  - Haunt/scripts/haunt-metrics.sh (modify)
  - Haunt/commands/haunt-metrics.md (modify - document new flag)

  Completion Criteria:
  - haunt-metrics --context shows overhead breakdown
  - JSON output includes context_overhead_lines field
  - Baseline can be established for regression tracking

  Blocked by: REQ-311
```

## Workflow Integration

### Typical Session Flow

```bash
# 1. Start session and look for work
/assign REQ-312

# 2. Requirement details loaded, ready to work
# Tasks visible, completion criteria clear

# 3. Complete work
# ... implement feature ...

# 4. Mark complete in roadmap
# Update status to 🟢 manually after verification
```

### Multi-Session Work

For M-sized requirements spanning multiple sessions:

```bash
# Session 1: Start work
/assign REQ-312
# ... complete some tasks ...
# Exit session with tasks partially checked

# Session 2: Resume work
/assign REQ-312
# Requirement already 🟡, tasks show progress
# Continue from last unchecked task
```

## Warnings and Errors

### Warning: Already In Progress

```
⚠️  REQ-312 is already 🟡 In Progress

Do you want to:
  1. Continue with this requirement (load context)
  2. Cancel and choose different requirement

Choose [1/2]:
```

### Error: Requirement Blocked

```
❌ Cannot assign REQ-312: Add Context Overhead Metric

Reason: Requirement is blocked
Blocked by: REQ-311 (Fix haunt-metrics.sh Parsing Bugs)

Recommendation: Work on REQ-311 first, or choose unblocked requirement.
```

### Error: Requirement Complete

```
❌ Cannot assign REQ-312: Add Context Overhead Metric

Reason: Requirement is already 🟢 Complete

Archived: 2026-01-02 (see .haunt/completed/roadmap-archive.md)
```

### Error: Agent Mismatch

```
⚠️  REQ-312 is assigned to: Dev-Infrastructure
You are: Dev-Frontend

This requirement may not be in your domain. Continue anyway? [y/N]
```

## Roadmap Sharding Support

Works with both monolithic and sharded roadmaps:

**Monolithic roadmap:**
- Searches `.haunt/plans/roadmap.md` directly

**Sharded roadmap:**
- Searches active batch in `roadmap.md`
- If not found, searches `.haunt/plans/batches/batch-*.md`
- Loads correct batch file for requirement details

## Story File Integration

After assigning, checks for story file:

```bash
# If .haunt/plans/stories/REQ-312-story.md exists:
✓ Story file found: .haunt/plans/stories/REQ-312-story.md

Recommendation: Read story file for implementation context before starting.

The story file contains:
- Implementation approach and technical strategy
- Code examples and references from codebase
- Known edge cases and gotchas
- Session notes from previous work
```

## Implementation

Runs the script: `bash Haunt/scripts/haunt-assign.sh <REQ-XXX> [options]`

## See Also

- `/roadmap` - View and manage requirements
- `gco-session-startup` - Assignment lookup protocol
- `gco-roadmap-workflow` - Work coordination patterns
- `gco-completion-checklist` - Requirements for marking complete
