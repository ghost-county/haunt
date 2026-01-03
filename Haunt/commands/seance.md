# Conduct Séance (Workflow Orchestration)

Hold a séance to guide ideas through the complete Ghost County workflow: the three-part ritual of scrying (planning), summoning (execution), and banishing (archival).

## ⚠️ Skill Mode Limitation

**Important:** The `/seance` command runs in **skill mode**, which has limited capabilities:

| Entry Point | Task Tool (Spawning) | Full Workflow |
|-------------|---------------------|---------------|
| `/seance` command | ❌ No | Scrying + Direct Execution |
| `haunt` alias | ✅ Yes | Full agent spawning |

**For full agent spawning capability, use the `haunt` alias instead:**
```bash
haunt "Add OAuth login support"    # Full Seer agent with Task tool
```

**What this means in practice:**
- `/seance` can do planning (scrying) and direct work
- `/seance` **cannot** spawn specialized agents (PM, Dev, Research)
- Use `haunt` when you need the full multi-agent workflow

---

## The Three-Part Ritual

```
🔮 Phase 1: Scrying   (Planning)   → /seance --scry    or --plan
👻 Phase 2: Summoning (Execution)  → /seance --summon  or --execute
⚰️ Phase 3: Banishing (Archival)   → /seance --banish  or --archive
```

**Mystical vs Normie:**
- **Mystical:** `--scry`, `--summon`, `--banish` (embrace the occult vibes)
- **Normie:** `--plan`, `--execute`, `--archive` (keep it practical)

## Scale-Adaptive Planning

The séance adapts to task complexity:

- **`--quick`** - Skip strategic analysis and critic review for simple tasks (typos, configs, small fixes)
- **Default** - Standard workflow with JTBD/Kano/RICE analysis + critical review
- **`--deep`** - Extended strategic analysis (SWOT, VRIO, risk matrix, stakeholder impact) + critical review

```bash
# Examples
/seance --quick "Fix typo in error message"        # Minimal ceremony, <60 sec
/seance "Add user login endpoint"                  # Standard analysis (default)
/seance --deep "Redesign authentication system"    # Extended strategic analysis
```

## Usage Modes

### Mode 1: With Prompt
```bash
/seance "Add OAuth login support"
/seance Build a task management app
/seance Fix the authentication bug and add tests
```
Starts idea-to-roadmap workflow immediately with the provided prompt.

### Mode 2: Interactive (No Arguments + Existing Project)
```bash
/seance
```
In a repository with `.haunt/`:
- **[A] Add something new** — Run scrying for new idea/feature/bug
- **[B] Summon the spirits** — Run summoning for existing roadmap
- **Tell Claude what to do** — Custom input

### Mode 3: Interactive (No Arguments + New Project)
```bash
/seance
```
In a repository without `.haunt/`:
- Prompt: "What would you like to build?"
- Run full scrying workflow for new project

### Mode 4: Explicit Scrying (Planning)
```bash
/seance --scry "Add rate limiting to API"
/seance --plan "Implement caching layer"

# With planning depth modifiers
/seance --scry --quick "Fix typo in header"
/seance --scry --deep "Redesign authentication architecture"
```
**Purpose:** Transform raw idea into formal roadmap
**Output:** `.haunt/plans/roadmap.md` with sized, assigned requirements

**Planning Depth:**
- `--quick`: Minimal ceremony (XS-S tasks only, skip strategic frameworks)
- No flag: Standard 3-phase workflow (default)
- `--deep`: Extended analysis (M-SPLIT features, add strategic analysis document)

### Mode 5: Explicit Summoning (Execution)
```bash
/seance --summon
/seance --execute
```
**Purpose:** Spawn agents for all ⚪ and 🟡 roadmap items
**Output:** Parallel agent execution working until 🟢 Complete

**⚠️ Note:** This mode requires Task tool. If running via `/seance`, will fall back to direct execution.

### Mode 6: Explicit Banishing (Archival)
```bash
/seance --banish
/seance --archive
```
**Purpose:** Archive completed work and clean roadmap (runs `/banish --all`)
**Output:** Clean roadmap + archived history in `.haunt/completed/`

### Mode 7: Quick Planning (--quick)
```bash
/seance --quick "Fix typo in README"
/seance --quick "Update config timeout value"
```
**Purpose:** Fast-track simple tasks - skip strategic analysis, create basic REQ
**Output:** Single requirement with minimal ceremony (<60 seconds)
**When to use:** XS-S sized tasks - typos, config changes, simple bug fixes

### Mode 8: Deep Planning (--deep)
```bash
/seance --deep "Redesign authentication system"
/seance --deep "Implement multi-tenancy architecture"
```
**Purpose:** Extended strategic analysis for high-impact features
**Output:** Standard roadmap PLUS `.haunt/plans/REQ-XXX-strategic-analysis.md` with:
- Expanded SWOT matrix
- VRIO competitive analysis
- Risk assessment matrix
- Stakeholder impact analysis
- Architectural implications
**When to use:** M-SPLIT sized features with high strategic impact

## Task: $ARGUMENTS

**Step 0: Skill Mode Detection**

⚠️ **CRITICAL:** Check if running in skill mode (no Task tool).

```
SKILL MODE CHECK:
- Running via /seance command = SKILL MODE
- Task tool is NOT available in skill mode
- Agent spawning will NOT work

IF attempting agent spawning later:
  Display: "⚠️ Running in skill mode. For agent spawning, use: haunt 'your idea'"
  Fall back to direct execution
```

**Display this notice at startup when in skill mode:**
```
🕯️ Séance Initiated (Skill Mode)

Note: Running via /seance command (limited mode).
For full agent spawning: haunt "your idea"

Continuing with direct execution...
```

**Step 1: Parse Arguments and Detect Mode**

```python
import os

args = "$ARGUMENTS".strip()
has_haunt = os.path.exists(".haunt/")

# Extract planning depth modifiers
planning_depth = "standard"  # default
if "--quick" in args:
    planning_depth = "quick"
    args = args.replace("--quick", "").strip()
elif "--deep" in args:
    planning_depth = "deep"
    args = args.replace("--deep", "").strip()

# Check for explicit phase flags (after extracting planning depth)
if args in ["--scry", "--plan"]:
    mode = 4  # Explicit scrying
    prompt = ""  # Will prompt user for idea
elif args.startswith("--scry ") or args.startswith("--plan "):
    mode = 4  # Explicit scrying with idea
    prompt = args.split(None, 1)[1] if len(args.split(None, 1)) > 1 else ""
elif args in ["--summon", "--execute"]:
    mode = 5  # Explicit summoning
elif args in ["--banish", "--archive"]:
    mode = 6  # Explicit banishing
elif args:
    mode = 1  # With prompt - immediate workflow
elif has_haunt:
    mode = 2  # No args + existing - choice prompt
else:
    mode = 3  # No args + new - new project prompt
```

**Step 1B: Initialize Phase State**

Create state directory and initialize phase tracking:

```python
import os

# Ensure .haunt/state/ directory exists
os.makedirs(".haunt/state", exist_ok=True)

# Set initial phase to SCRYING
with open(".haunt/state/current-phase.txt", "w") as f:
    f.write("SCRYING")
```

**Step 2: Execute Mode-Specific Flow**

Invoke the `gco-orchestrator` skill with detected mode, arguments, and planning depth:

```
MODE: {mode}
ARGUMENTS: {args}  # With --quick/--deep removed
PLANNING_DEPTH: {planning_depth}  # "quick", "standard", or "deep"
HAS_HAUNT: {has_haunt}
CURRENT_PHASE: SCRYING
SKILL_MODE: true  # Task tool NOT available
```

The skill will handle the appropriate flow based on mode and planning depth.

**Important:** In skill mode, the orchestrator will execute work directly instead of spawning agents.

## Complete Workflow Examples

### Full Ritual (Interactive)
```bash
$ /seance
> 🕯️ The spirits stir. What brings you to the veil?
> [A] Add something new
> [B] Summon the spirits

$ [Choose A]
> What would you like to add?

$ "Add OAuth login"
> 🔮 Scrying the future...
> [Planning happens...]
> Ready to summon the spirits? [yes/no]

$ yes
> 👻 The spirits rise...
> [Execution happens...]
> ⚰️ Banishing completed work...
> [Archival happens automatically...]
> ✅ OAuth login complete
```

### Partial Ritual (Explicit Phases)
```bash
# Just planning
$ /seance --scry "Add dark mode"
> 🔮 Scrying the future...
> ✅ Roadmap created at .haunt/plans/roadmap.md

# Later: Just execution
$ /seance --summon
> 👻 The spirits rise...
> [Agents work...]
> ✅ All requirements complete

# Later: Just cleanup
$ /seance --banish
> ⚰️ Banishing completed work...
> ✅ 5 spirits sent to rest
```

### Quick Full Ritual (With Prompt)
```bash
$ /seance "Fix login bug and add tests"
> 🔮 Scrying the future...
> ✅ Requirements developed
> Ready to summon? [yes]
> 👻 The spirits rise...
> [Work happens...]
> ⚰️ Banishing completed work...
> ✅ Complete
```

### Quick Mode (Simple Tasks)
```bash
$ /seance --quick "Fix typo in error message"
> ⚡ Quick scrying...
> ✅ Created REQ-225: Fix typo in error message
>    Agent: Dev-Infrastructure
>    Effort: XS (~30 min)
> Ready to summon? [yes]
> 👻 Summoning gco-dev-infrastructure...
> ✅ Complete in 8 minutes
```

### Deep Mode (Strategic Features)
```bash
$ /seance --deep "Redesign authentication system"
> 🔮 Deep scrying the future...
> [Phase 1: Requirements Development...]
> [Phase 2: Strategic Analysis...]
>   - SWOT matrix created
>   - VRIO analysis complete
>   - Risk assessment documented
>   - Stakeholder impact mapped
> [Phase 3: Roadmap Creation...]
> ✅ Roadmap created: .haunt/plans/roadmap.md
> ✅ Strategic analysis: .haunt/plans/REQ-XXX-strategic-analysis.md
> Ready to summon the spirits? [yes/no]
```

### Using haunt Alias (Full Agent Spawning)
```bash
# For full multi-agent workflow, use haunt alias:
$ haunt "Add OAuth login support"
> 🔮 Seer agent activated...
> [Spawns PM for planning...]
> [PM completes roadmap...]
> Ready to summon? [yes]
> [Spawns Dev agents...]
> ✅ Complete
```

## See Also

- **`Haunt/docs/SEANCE-EXPLAINED.md`** - Complete documentation and philosophy
- **`Haunt/docs/assets/seance-infographic.html`** - Visual guide
- **`/summon <agent>`** - Directly spawn a specific agent
- **`/banish --all`** - Quick archive (same as `/seance --banish`)
- **`/haunting`** - View current active work
- **`haunt` alias** - Full Seer agent with Task tool for multi-agent workflows
