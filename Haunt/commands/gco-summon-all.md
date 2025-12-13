# Summon All Spirits (Parallel Work)

Gather the full coven to work all unblocked items from the roadmap in parallel. Each spirit handles one requirement until all work is complete.

## What is Summon All?

`/summon-all` spawns Ghost County dev agents to work every unblocked ⚪ Not Started requirement from the roadmap simultaneously. This is Ghost County's mass parallel execution pattern for clearing the backlog.

## Task: Work All Unblocked Items

### Execution Workflow

#### 1. Read and Parse Roadmap

```bash
# Roadmap location
ROADMAP="/Users/heckatron/github_repos/ghost-county/.haunt/plans/roadmap.md"
```

Read `.haunt/plans/roadmap.md` and identify:
- All lines matching: `### ⚪ REQ-`
- Extract REQ number and title from each line

#### 2. Filter Out Blocked Items

For each identified requirement:
1. Read the full requirement section
2. Check the `**Blocked by:**` field
3. If value is "None", item is unblocked
4. If value is `REQ-XXX`, check if that REQ is 🟢 Complete
5. Skip requirement if blocker is not complete

Example filtering logic:
```python
# Pseudo-code for blocking check
if blocked_by == "None":
    unblocked = True
elif blocked_by.startswith("REQ-"):
    # Check if blocker REQ is 🟢 in roadmap
    blocker_status = get_requirement_status(blocked_by)
    unblocked = (blocker_status == "🟢")
else:
    unblocked = False
```

#### 3. Group by Agent Type

Organize unblocked requirements by their `**Agent:**` field:
- Dev-Backend → gco-dev
- Dev-Frontend → gco-dev
- Dev-Infrastructure → gco-dev
- Dev (generic) → gco-dev
- Research-Analyst → gco-research
- Code-Reviewer → gco-code-reviewer

#### 4. Spawn Parallel Agents

For each unblocked requirement, spawn a gco-dev agent using the Task tool:

```python
# For each requirement
Task(
    subagent_type="gco-dev",
    instruction=f"You are a Dev agent. Implement {req_id}: {req_title} from the roadmap.",
    run_in_background=True  # Critical for parallel execution
)
```

**Important:**
- Use `run_in_background=True` for all spawned agents
- This enables true parallel execution
- Agents work independently without blocking each other

#### 5. Track Progress

Report to user:
```
🕯️ GATHERING THE FULL COVEN 🕯️

Found X unblocked requirements in the roadmap:

By Domain:
- Dev-Backend: Y items
- Dev-Frontend: Z items
- Dev-Infrastructure: W items

Summoning spirits in parallel...

✓ Spawned gco-dev for REQ-101: Feature A
✓ Spawned gco-dev for REQ-102: Feature B
✓ Spawned gco-dev for REQ-103: Feature C
...

🌙 X spirits are now working the roadmap in parallel.

Each agent will:
1. Update roadmap status to 🟡 In Progress
2. Complete their assigned requirement
3. Mark complete (🟢) when done
4. Report completion

Monitor progress:
  /haunting              # View active work
  /haunt                 # Check overall status
  cat .haunt/plans/roadmap.md  # See status updates
```

#### 6. Handle Failures Gracefully

If a spawn fails:
- Log the error
- Continue spawning other agents
- Report failed spawns at end

Example error handling:
```
⚠️ WARNING: Failed to spawn agent for REQ-105

Error: {error_message}

Continuing with remaining work items...
```

### Output Format

#### Success
```
🕯️ GATHERING THE FULL COVEN 🕯️

Scanning roadmap for unblocked work...
Found 12 ⚪ Not Started requirements

Filtering blocked items...
✓ 12 unblocked and ready for work

Grouping by domain...
- Backend: 5 requirements
- Frontend: 4 requirements
- Infrastructure: 3 requirements

Summoning the spirits...
✓ REQ-171: Consolidate Haunt documentation → gco-dev (background)
✓ REQ-132: Rename .sdlc to .haunt → gco-dev (background)
✓ REQ-150: Create /ritual command → gco-dev (background)
✓ REQ-143: Create /summon command → gco-dev (background)
✓ REQ-144: Create /haunt command → gco-dev (background)
... (7 more)

🌙 THE COVEN IS ASSEMBLED 🌙

12 spirits are working the roadmap in parallel.

Monitor their progress:
  /haunting              # Active work view
  /haunt status          # Overall status

Check roadmap for real-time updates:
  cat .haunt/plans/roadmap.md

Each agent will update their requirement status:
  ⚪ → 🟡 (started) → 🟢 (complete)
```

#### No Work Available
```
🌙 The spirits are at rest...

No unblocked work found in the roadmap.

All ⚪ Not Started items are blocked by dependencies.
Complete blocking requirements first, then summon again.

Check roadmap:
  cat .haunt/plans/roadmap.md
```

#### Partial Failures
```
🕯️ COVEN SUMMONING COMPLETE (WITH WARNINGS) 🕯️

Successfully spawned: 10 spirits
Failed to spawn: 2 spirits

FAILURES:
⚠️ REQ-105: Failed to spawn agent
   Error: Task tool unavailable

⚠️ REQ-108: Failed to spawn agent
   Error: Invalid agent type specified

✓ 10 spirits are working successfully.

Review failures and retry manually:
  /summon dev Implement REQ-105
```

### Integration with Seance

This command is the default behavior for:
```
/seance
> [B] Summon the spirits
```

When user chooses "Summon the spirits" in an existing project, invoke this command automatically.

### Usage Examples

**Basic usage:**
```
/summon-all
```

**From seance workflow:**
```
/seance
> What would you like to do?
> [A] Add something new
> [B] Summon the spirits    ← Triggers /summon-all

Gathering the full coven...
```

### Requirements for Successful Execution

1. **Roadmap exists**: `.haunt/plans/roadmap.md` must exist
2. **Valid format**: Requirements follow GCO roadmap format
3. **Task tool available**: Claude Code Task tool must be accessible
4. **Background execution**: Agent runtime must support `run_in_background=True`

### Limitations

- **No coordination**: Agents work independently (use `/coven` for coordinated work)
- **No conflict detection**: Parallel work may touch same files (git will catch conflicts)
- **No retry logic**: Failed spawns must be manually retried
- **No completion aggregation**: User must check roadmap for final status

### When to Use

| Use `/summon-all` when: | Use `/coven` when: |
|-------------------------|---------------------|
| Many independent tasks | Single complex feature |
| Requirements don't share files | Need file ownership coordination |
| Speed over coordination | Coordination over speed |
| Backlog clearing mode | Integration-heavy work |

### Troubleshooting

**No agents spawned:**
- Check roadmap exists: `ls -la .haunt/plans/roadmap.md`
- Verify ⚪ items exist: `grep "### ⚪ REQ-" .haunt/plans/roadmap.md`
- Check all items aren't blocked: Look for `**Blocked by:** None`

**Spawn failures:**
- Verify Task tool is available in Claude Code
- Check agent type is valid (gco-dev, gco-research, etc.)
- Ensure `run_in_background=True` is supported

**Agents not making progress:**
- Check `/haunting` to see active work
- Review `.haunt/plans/roadmap.md` for status updates
- Look for 🟡 status changes (indicates agent started)

### See Also

- `/seance` - Workflow orchestration (planning → summoning)
- `/coven` - Coordinated parallel work with integration contracts
- `/summon <agent> <task>` - Spawn single agent for specific work
- `/haunting` - View currently active work across all agents
- `/haunt status` - Overall project status
