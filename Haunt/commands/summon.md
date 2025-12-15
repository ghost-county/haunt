# Summon Spirit(s)

Call forth Ghost County agents to handle tasks. Summon a single spirit for specific work, or gather the full coven to work all unblocked roadmap items in parallel.

## Usage Modes

### Single Spirit Summoning

**Format:** `/summon <agent-type> [--mode=<level>] <task-description>`

**Examples:**
- `/summon dev Fix the authentication bug`
- `/summon research Investigate React 19 server components`
- `/summon research --mode=quick "Find authentication patterns"`
- `/summon research --mode=thorough "Analyze all error handling"`
- `/summon code-reviewer Review PR #42`
- `/summon release-manager Prepare v1.2.0 release`
- `/summon project-manager Update roadmap priorities`

**Mode Parameter (Research Agent Only):**

The `--mode` parameter controls investigation thoroughness for research agents:

| Mode | Time | Scope | When to Use |
|------|------|-------|-------------|
| `quick` | <1 min | 5 files max | Time-sensitive, simple lookups |
| `standard` | 2-5 min | Up to 20 files | Most research tasks (default) |
| `thorough` | 10-30 min | All relevant files | Critical decisions, audits |

If `--mode` is not specified, research agents default to **standard** mode.

### Full Coven Summoning

**Format:** `/summon all`

Spawns agents for all unblocked ⚪ Not Started requirements from the roadmap in parallel.

### Interactive Mode

**Format:** `/summon` (no arguments)

Prompts the user:
```
🌫️ Which spirit do you wish to summon?

[1] Individual spirit - Spawn one agent for a specific task
[2] Full coven - Work all unblocked roadmap items in parallel

Choice (1/2): _
```

If choice 1, then prompt:
```
Available spirits:
- dev (backend, frontend, infrastructure)
- research
- code-reviewer
- release-manager
- project-manager

Which spirit? _
What task? _
```

If choice 2, proceed with full coven summoning (same as `/summon all`).

## Supported Agent Types

Parse the first argument to determine which spirit to summon:

| User Input | Maps To | Agent Character Sheet | Domain |
|------------|---------|----------------------|---------|
| `dev`, `dev-backend`, `backend` | Dev-Backend | `gco-dev-backend` | API, services, database |
| `dev-frontend`, `frontend` | Dev-Frontend | `gco-dev-frontend` | UI, components, client |
| `dev-infra`, `infrastructure`, `infra` | Dev-Infrastructure | `gco-dev-infrastructure` | IaC, CI/CD, deployment |
| `research`, `research-analyst`, `analyst` | Research-Analyst | `gco-research-analyst` | Investigation, analysis |
| `code-reviewer`, `reviewer`, `review` | Code-Reviewer | `gco-code-reviewer` | Code quality, review |
| `release-manager`, `release`, `rm` | Release-Manager | `gco-release-manager` | Release coordination |
| `project-manager`, `pm`, `manager` | Project-Manager | `gco-project-manager` | Planning, coordination |

## Single Spirit Summoning Logic

1. **Parse agent type** from first argument (case-insensitive)
2. **Extract mode parameter** if present (format: `--mode=quick|standard|thorough`)
3. **Extract task** from remaining arguments
4. **Map to gco-* agent** using table above
5. **Spawn the spirit** using Task tool with:
   - `subagent_type`: Mapped agent character sheet (e.g., `gco-dev-backend`)
   - `instructions`: Task description with Ghost County context and mode (if applicable)

### Example Invocation: Basic

If user types: `/summon dev Fix the authentication redirect loop`

**Parsing:**
- Agent type: `dev` → Maps to `gco-dev-backend`
- Mode: None
- Task: `Fix the authentication redirect loop`

**Spawn:**
```
Task tool with:
- subagent_type: "gco-dev-backend"
- instructions: "You are a Dev-Backend agent in Ghost County. Fix the authentication redirect loop."
```

### Example Invocation: With Mode Parameter

If user types: `/summon research --mode=quick "Find authentication patterns"`

**Parsing:**
- Agent type: `research` → Maps to `gco-research`
- Mode: `quick`
- Task: `Find authentication patterns`

**Spawn:**
```
Task tool with:
- subagent_type: "gco-research"
- instructions: "You are a Research agent in Ghost County. Use QUICK investigation mode. Find authentication patterns."
```

### Mode Parameter Processing

**Detection:**
- Look for `--mode=<value>` anywhere in arguments
- Valid values: `quick`, `standard`, `thorough`
- Case-insensitive matching
- Remove from task description after parsing

**Injection:**
- If mode specified: Add "Use [MODE] investigation mode." to instructions
- If no mode: Research agents default to standard mode (no explicit instruction needed)
- Non-research agents: Ignore mode parameter (no effect)

**Example parsing logic:**
```python
import re

def parse_summon_args(args_string):
    # Extract mode parameter
    mode_match = re.search(r'--mode=(quick|standard|thorough)', args_string, re.IGNORECASE)
    mode = mode_match.group(1).lower() if mode_match else None

    # Remove mode parameter from task description
    task = re.sub(r'--mode=(quick|standard|thorough)\s*', '', args_string, flags=re.IGNORECASE)

    # Remove quotes if present
    task = task.strip().strip('"').strip("'")

    return mode, task

# Example usage
mode, task = parse_summon_args('--mode=quick "Find authentication patterns"')
# mode = 'quick'
# task = 'Find authentication patterns'
```

## Full Coven Summoning Logic (`/summon all`)

### Execution Workflow

#### 1. Read and Parse Roadmap

```bash
# Roadmap location
ROADMAP=".haunt/plans/roadmap.md"
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

For each unblocked requirement, spawn the appropriate gco-* agent using the Task tool:

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

## Output Formats

### Single Spirit Success
```
🌫️ SUMMONING COMPLETE 🌫️

Spirit: {agent-type}
Task: {task-description}

✓ Agent spawned and working

The spirit will report back when complete.
```

### Full Coven Success
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
✓ REQ-132: Update directory structure → gco-dev (background)
✓ REQ-150: Create /ritual command → gco-dev (background)
... (9 more)

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

### No Work Available
```
🌙 The spirits are at rest...

No unblocked work found in the roadmap.

All ⚪ Not Started items are blocked by dependencies.
Complete blocking requirements first, then summon again.

Check roadmap:
  cat .haunt/plans/roadmap.md
```

### Partial Failures (Full Coven)
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

## Error Handling

### Unknown Agent Type (Single Spirit)
```
🌫️ The mists are unclear... Unknown agent type: <input>

Summon a spirit by name:
- dev, research, code-reviewer, release-manager, project-manager

Example: /summon dev Fix the login bug
```

### No Task Provided (Single Spirit)
```
🌫️ The summoning requires a task...

Usage: /summon <agent-type> [--mode=<level>] <task-description>
Example: /summon dev Fix the authentication bug
Example: /summon research --mode=quick "Find auth patterns"

Or: /summon all (to work all unblocked roadmap items)
```

### Invalid Mode Parameter
```
🌫️ Invalid investigation mode: <mode>

Valid modes for research agents:
- quick: Fast triage (<1 min, 5 files max)
- standard: Balanced investigation (2-5 min, default)
- thorough: Deep analysis (10-30 min, comprehensive)

Example: /summon research --mode=quick "Find authentication patterns"

Note: --mode parameter only applies to research agents.
```

## Requirements for Successful Execution

1. **Single spirit**: Agent type and task description
2. **Full coven**:
   - Roadmap exists: `.haunt/plans/roadmap.md`
   - Valid format: Requirements follow GCO roadmap format
   - Task tool available: Claude Code Task tool accessible
   - Background execution: Runtime supports `run_in_background=True`

## When to Use Each Mode

| Use `/summon <agent> <task>` when: | Use `/summon all` when: |
|------------------------------------|-------------------------|
| Specific one-off task | Many independent tasks in roadmap |
| Ad-hoc work not in roadmap | Backlog clearing mode |
| Quick investigation or fix | Batch processing requirements |
| Task assigned directly by user | Speed over coordination |

| Use `/summon all` when: | Use `/coven` when: |
|-------------------------|---------------------|
| Many independent tasks | Single complex feature |
| Requirements don't share files | Need file ownership coordination |
| Speed over coordination | Coordination over speed |
| Backlog clearing mode | Integration-heavy work |

## Ghost County Namespace

**IMPORTANT:** GCO agents should only spawn other GCO agents (gco-* prefix) to maintain namespace isolation. Never spawn non-prefixed agents from within Ghost County workflows.

## Integration with Seance

The full coven mode (`/summon all`) is the default behavior for:
```
/seance
> [B] Summon the spirits
```

When user chooses "Summon the spirits" in an existing project, invoke `/summon all` automatically.

## Troubleshooting

### Single Spirit Mode

**Agent doesn't start:**
- Verify agent type spelling matches supported types
- Check Task tool is available
- Ensure task description is clear and actionable

### Full Coven Mode

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

## See Also

- `/seance` - Workflow orchestration (planning → summoning)
- `/coven` - Coordinated parallel work with integration contracts
- `/haunting` - View currently active work across all agents
- `/haunt status` - Overall project status
