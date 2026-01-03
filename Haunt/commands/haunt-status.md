---
name: haunt-status
description: Display batch-organized status of roadmap requirements, showing progress by batch with blocking dependencies highlighted.
---

# /haunt-status - Batch Status Command

## Purpose

Display batch-organized status view of the roadmap, grouping requirements by batch and showing completion progress with blocking dependencies highlighted.

## When to Use

- **Quick status check** - Get overview of work across all batches
- **Batch planning** - See which batches are ready vs blocked
- **Dependency tracking** - Identify blocking requirements holding up work
- **Progress reporting** - Generate status reports for project updates
- **Unblocking work** - Find completed requirements that can unblock others

## Usage

```bash
# Display batch status (default)
/haunt status

# Get JSON output for scripting
/haunt status --json
```

## Command Implementation

This command runs: `bash Haunt/scripts/haunt-status.sh [OPTIONS]`

### Options

| Option | Description |
|--------|-------------|
| `--batch` | Show batch-organized view (default) |
| `--json` | Output as JSON for scripting |
| `--help` | Show help message |

## Output Format

### Batch View (Default)

```text
════════════════════════════════════════
    Haunt Framework Batch Status
════════════════════════════════════════

## Batch: Metrics & Regression Framework
  🟢 REQ-311: Fix haunt-metrics.sh Parsing Bugs
  🟡 REQ-312: Add Context Overhead Metric
  ⚪ REQ-313: Create haunt-regression-check Script (blocked by REQ-312)
  ⚪ REQ-314: Create Baseline Metrics Storage System (blocked by REQ-313)
  Status: 1/4 complete
  ⚠️  2 blocked

## Batch: Agent/Skill Optimization
  🟢 REQ-310: Refactor gco-dev.md Agent
  🟢 REQ-316: Refactor gco-testing-mindset Skill
  🟢 REQ-317: Refactor gco-roadmap-planning Skill
  Status: 3/3 complete
```

**Status Icons:**
- ⚪ Not Started
- 🟡 In Progress
- 🟢 Complete
- 🔴 Blocked

### JSON Format

```json
[
  {
    "batch": "Metrics & Regression Framework",
    "requirements": [
      {
        "id": "REQ-311",
        "title": "Fix haunt-metrics.sh Parsing Bugs",
        "status": "complete",
        "blockers": ""
      },
      {
        "id": "REQ-312",
        "title": "Add Context Overhead Metric",
        "status": "in_progress",
        "blockers": ""
      },
      {
        "id": "REQ-313",
        "title": "Create haunt-regression-check Script",
        "status": "pending",
        "blockers": "REQ-312"
      }
    ],
    "summary": {
      "total": 3,
      "pending": 1,
      "in_progress": 1,
      "complete": 1,
      "blocked": 1
    }
  }
]
```

## Use Cases

### 1. Morning Standup

```bash
/haunt status
```

Get quick overview of all batches to identify:
- Completed work that needs archiving
- Blocked work that can be unblocked
- In-progress work that needs attention

### 2. Batch Completion Check

```bash
# Check if batch is ready to archive
/haunt status | grep "Status: 3/3 complete"
```

Identify batches where all requirements are complete and ready for archival.

### 3. Dependency Analysis

```bash
# Find all blocked requirements
/haunt status | grep "blocked by"
```

Quickly identify which requirements are waiting on dependencies.

### 4. Scripted Reporting

```bash
# Generate JSON report
/haunt status --json > status-report.json

# Parse with jq
/haunt status --json | jq '.[] | select(.summary.blocked > 0)'
```

Use JSON output for automated reporting or dashboard integration.

### 5. Unblocking Workflow

**Workflow:**
1. Run `/haunt status` to see blocked requirements
2. Identify completed requirements that were blockers
3. Update blocked requirements: change `Blocked by: REQ-XXX` to `Blocked by: None`
4. Run `/haunt status` again to verify unblocking

## Integration with Roadmap

This command reads from `.haunt/plans/roadmap.md` and parses:

**Batch Headers:**
- `## Batch: [Batch Name]`
- `## Priority: [Priority Name]`

**Requirement Format:**
- `### [Status Icon] REQ-XXX: [Title]`
- Extracts status from icon (⚪, 🟡, 🟢, 🔴)
- Detects blocking dependencies from `Blocked by:` field

## Implementation Details

### Batch Detection

The script identifies batch boundaries by:
1. Finding lines starting with `## Batch:` or `## Priority:`
2. Extracting requirements between batch headers
3. Stopping at next `## ` header or end of file

### Status Counting

For each batch:
- **Total**: Count all `### [Icon] REQ-` lines
- **Pending**: Count ⚪ icons
- **In Progress**: Count 🟡 icons
- **Complete**: Count 🟢 icons
- **Blocked**: Count requirements with `Blocked by: REQ-` in content

### Dependency Highlighting

Requirements with `Blocked by: REQ-XXX` in their description are:
1. Flagged with "(blocked by REQ-XXX)" suffix in output
2. Counted in batch's blocked total
3. Highlighted with red color in terminal

## Error Handling

**Roadmap not found:**
```bash
Error: Roadmap file not found: .haunt/plans/roadmap.md
```

**Invalid format:**
- Script gracefully handles missing fields
- Skips malformed requirement headers
- Continues parsing remaining batches

## Command Aliases

```bash
# Create shell alias
alias haunt-status='bash Haunt/scripts/haunt-status.sh'

# Use alias
haunt-status
haunt-status --json
```

## See Also

- `Haunt/commands/roadmap.md` - Roadmap management commands
- `Haunt/scripts/haunt-metrics.sh` - Agent performance metrics
- `.haunt/plans/roadmap.md` - Source roadmap file
- `Haunt/rules/gco-roadmap-format.md` - Roadmap format specification

## Future Enhancements

Potential features for future versions:

1. **Filtering**
   - `--status=in_progress` - Show only in-progress requirements
   - `--batch="Metrics Framework"` - Show specific batch only
   - `--blocked-only` - Show only blocked requirements

2. **Effort Estimation (REQ-232)**
   - Display total effort per batch
   - Show remaining effort
   - Estimate completion time

3. **Historical Tracking**
   - Show velocity (completed work per week)
   - Trend analysis (completion rate increasing/decreasing)
   - Burndown charts in JSON output

4. **Interactive Mode**
   - Use `fzf` or similar for interactive batch selection
   - Quick navigation to requirement in roadmap
   - One-command unblocking workflow
