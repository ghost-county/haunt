---
last-verified: 2026-04-03
version: "1.0"
name: gco-team-protocol
description: Shared protocol for all team-aware agents. Defines task claiming, completion reporting, messaging, and status conventions for Agent Teams.
---

# Team Protocol

Shared behavior for all agents operating as teammates in a seance Team.

## Task Lifecycle

### Claiming Work
1. Check `TaskList` for tasks assigned to you or unassigned tasks matching your role
2. `TaskUpdate` the task to `in_progress` before starting
3. If a task is blocked, skip it and check for other available work

### Completing Work
1. Verify your work meets the task's acceptance criteria
2. `TaskUpdate` the task to `completed`
3. `SendMessage` to the lead with a brief completion summary:
   - What was done (1-2 sentences)
   - Files modified
   - Test results (pass/fail)
   - Blockers encountered (if any)
4. Check `TaskList` for next available work

### Handling Blocked Tasks
- If you discover a blocker mid-task, `SendMessage` the lead explaining the blocker
- `TaskUpdate` the task with a note about the blocker
- Move to next available task rather than waiting

### Requesting Help
- `SendMessage` the specific teammate who can help (not broadcast)
- Include: what you need, why, and what you've already tried
- Continue other work while waiting for response

## Status Conventions

| Task Status | Meaning | Roadmap Icon |
|-------------|---------|-------------|
| `pending` | Not started | ⚪ |
| `in_progress` | Actively being worked | 🟡 |
| `completed` | Done and verified | 🟢 |
| `blocked` | Waiting on dependency | 🔴 |

## Communication Rules

- **Be concise** -- SendMessage summaries should be 3-5 lines max
- **Include file paths** -- Always list files you modified or need reviewed
- **Flag scope creep** -- If a task is bigger than described, message the lead before expanding scope
- **Respond to shutdown** -- When lead sends a shutdown message, finish current atomic operation and stop

## What NOT to Do

- Don't modify CLAUDE.md (lead responsibility)
- Don't create tasks (lead or PM responsibility)
- Don't message the user directly (lead handles user communication)
- Don't start work without claiming the task first via TaskUpdate
