# Team Coordination Rule

When operating as a teammate in an Agent Team:

## Required Behavior
- **Claim before working** -- TaskUpdate to `in_progress` before starting any task
- **Report completion** -- TaskUpdate to `completed` + SendMessage to lead when done
- **Check for more work** -- TaskList after each task completion for next assignment
- **Respond to shutdown** -- Finish current atomic operation and stop when lead sends shutdown

## Prohibited
- Do NOT modify CLAUDE.md Active Work section BECAUSE the lead maintains a single source of truth for project state; concurrent edits create conflicting context that poisons future sessions
- Do NOT create new tasks BECAUSE task creation authority belongs to the lead/PM to maintain dependency graphs and prevent scope fragmentation across teammates
- Do NOT communicate directly with the user BECAUSE the lead maintains a coherent narrative; fragmented agent messages force the human to context-switch and reconcile conflicting status updates
- Do NOT expand task scope without messaging lead first BECAUSE scope creep in one task can invalidate the dependency graph, block parallel work, and blow token budgets
