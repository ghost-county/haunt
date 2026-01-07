# Conduct Séance (Workflow Orchestration)

Hold a séance to guide ideas through the complete Ghost County workflow: the three-part ritual of scrying (planning), summoning (execution), and banishing (archival).

## Quick Start

```bash
# Recommended: Use the haunt alias for full functionality
alias haunt='claude --dangerously-skip-permissions'

# Start a séance
haunt
/seance "Add OAuth login support"
```

The `haunt` alias starts Claude Code with full tool access. The `/seance` command loads the orchestration workflow.

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
/seance --summon                      # All unblocked requirements
/seance --summon --project=TrueSight  # Only TrueSight section
/seance --execute --project=Haunt     # Only Haunt Framework section
```

**Purpose:** Spawn agents for ⚪ and 🟡 roadmap items (optionally filtered by project)
**Output:** Parallel agent execution working until 🟢 Complete

**Project Filter:** When `--project=` is specified, only summons agents for requirements under that project's section in the roadmap.

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

### Mode 9: Bug Detection (Auto-Triggered)

When input contains error patterns (stack traces, exceptions, error messages), séance auto-detects and offers a choice:

```bash
$ /seance SnowparkSQLException: (1304): invalid identifier 'USER'
> 🔮 Bug detected: SQL error - invalid identifier 'USER'
>
> Estimated: XS, SIMPLE complexity
>
> [A] Quick fix - Just fix it now, skip the ceremony
> [B] Log to roadmap - Create REQ-XXX and follow standard workflow
>
> Which path?
```

**Purpose:** Give user control over ceremony level for obvious bugs
**Trigger patterns:** `Traceback`, `Exception:`, `Error:`, `File "...", line X`, SQL error codes, "doesn't work", "broken", etc.
**Behavior:**
- [A] Quick fix → Investigate and fix immediately, no roadmap entry
- [B] Log to roadmap → Standard scrying workflow with REQ creation

## Task: $ARGUMENTS

**Step 1: Parse Arguments and Detect Mode**

```python
import os
import re

args = "$ARGUMENTS".strip()
has_haunt = os.path.exists(".haunt/")

# Bug/Error detection patterns
ERROR_PATTERNS = [
    r'Traceback',                    # Python stack traces
    r'Exception:',                   # Generic exceptions
    r'Error:',                       # Generic errors
    r'at line \d+',                  # Line number references
    r'File ".*", line \d+',          # Python file:line format
    r'invalid identifier',           # SQL errors
    r'\(\d{3,5}\):',                 # SQL/DB error codes like (1304):
    r'compilation error',            # SQL compilation errors
    r'TypeError|ValueError|KeyError|AttributeError',  # Python errors
    r'undefined|null pointer|segfault',  # Various runtime errors
    r"doesn't work|does not work|not working|broken|failed",  # Natural language
]

def looks_like_bug(text):
    """Detect if input contains error/bug patterns"""
    return any(re.search(p, text, re.IGNORECASE) for p in ERROR_PATTERNS)

is_bug = looks_like_bug(args)

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
elif is_bug and args and not args.startswith("--"):
    mode = 9  # Bug detected - present choice to user
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

**Step 1C: Project Detection and Confirmation**

For modes that create/modify requirements (1, 4, 9), detect and confirm the target project:

```python
# Project detection order:
# 1. Explicit in args: "for TrueSight", "in Familiar", "Haunt framework"
# 2. File path in args: "truesight/src/..." → TrueSight
# 3. Current working directory pattern
# 4. Ask user

PROJECT_PATTERNS = {
    "haunt": "Haunt Framework",
    "truesight": "TrueSight",
    "familiar": "Familiar",
    "cross": "Cross-Project Work",
}

def detect_project(args, cwd):
    """Detect project from args or cwd"""
    args_lower = args.lower()
    cwd_lower = cwd.lower()

    # Check explicit mention in args
    for key, name in PROJECT_PATTERNS.items():
        if key in args_lower or name.lower() in args_lower:
            return name

    # Check file paths in args
    for key, name in PROJECT_PATTERNS.items():
        if f"{key}/" in args_lower:
            return name

    # Check cwd
    for key, name in PROJECT_PATTERNS.items():
        if f"/{key}" in cwd_lower or cwd_lower.endswith(key):
            return name

    return None  # Will need to ask user

detected_project = detect_project(args, os.getcwd())
```

**Project Confirmation Flow:**

If project was detected, confirm with user:

```
🕯️ Detected project: {detected_project} (from cwd)
Continue with {detected_project}? [Y/n/other]
```

- **Y** → Proceed with detected project
- **n** → Show project selection menu
- **other** → Show project selection menu

If project was NOT detected (or user chose "other"):

```
Which project?
[A] Haunt Framework - Agent framework and SDLC tooling
[B] TrueSight - ADHD productivity dashboard
[C] Familiar - Personal command center
[D] Cross-Project - Affects multiple projects
```

Store selected project for use in requirement creation.

**Step 2: Execute Mode-Specific Flow**

**If MODE is 9 (Bug Detected):**

Use the AskUserQuestion tool to present the choice:

```markdown
🔮 Bug detected: [Extract brief summary - first line or key error message]

Estimated: XS, SIMPLE complexity

Options:
[A] Quick fix - Just fix it now, skip the ceremony
[B] Log to roadmap - Create REQ-XXX and follow standard workflow
```

Based on user's answer:
- **[A] Quick fix** → Investigate the error, identify the root cause, and fix it directly. No roadmap entry, no agent spawning. Just fix and report what was done.
- **[B] Log to roadmap** → Set `mode = 1` and continue with standard scrying workflow below.

**For all other modes:**

Invoke the `gco-orchestrator` skill with detected mode, arguments, planning depth, and project:

```
MODE: {mode}
ARGUMENTS: {args}  # With --quick/--deep removed
PLANNING_DEPTH: {planning_depth}  # "quick", "standard", or "deep"
PROJECT: {selected_project}  # From Step 1C confirmation
HAS_HAUNT: {has_haunt}
CURRENT_PHASE: SCRYING
```

The skill will handle the appropriate flow based on mode and planning depth. Requirements will be added under the appropriate `## {PROJECT}` section in roadmap.md.

## Complete Workflow Examples

### Full Ritual (Interactive with Project Detection)

```bash
$ cd ~/github_repos/truesight
$ haunt
> /seance
> 🕯️ Detected project: TrueSight (from cwd)
> Continue with TrueSight? [Y/n/other]

$ Y
> What would you like to add to TrueSight?

$ "Add dark mode toggle"
> 🔮 Scrying the future...
> [Planning happens...]
> ✅ Created REQ-042: Add dark mode toggle
>    Project: TrueSight
>    Effort: M
>    Agent: Dev-Frontend
> Ready to summon the spirits? [yes/no]

$ yes
> 👻 The spirits rise...
> [Spawns agents for implementation...]
> ⚰️ Banishing completed work...
> ✅ Dark mode toggle complete
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
> [Spawns dev agent...]
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

### Bug Detection Mode (Auto-Triggered)

```bash
$ /seance SnowparkSQLException: (1304): 01c18965-0c0e-46e2-0003-169611f5cf8a:
  000904 (42000): SQL compilation error: error line 2 at position 32
  invalid identifier 'USER'

> 🔮 Bug detected: SQL compilation error - invalid identifier 'USER'
>
> Estimated: XS, SIMPLE complexity
>
> [A] Quick fix - Just fix it now, skip the ceremony
> [B] Log to roadmap - Create REQ-XXX and follow standard workflow
>
> Which path?

$ [Choose A]
> Investigating...
> Found: USER is a reserved keyword in Snowflake, needs to be quoted as "USER"
> Fixed: utils/audit_data.py - changed USER to "USER" in 4 locations
> ✅ Done

$ [Choose B]
> 🔮 Scrying the future...
> ✅ Created REQ-XXX: Fix SQL reserved keyword error
>    Agent: Dev-Backend
>    Effort: XS
> Ready to summon? [yes/no]
```

## Setting Up the haunt Alias

Add to your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# Haunt alias - starts Claude Code with full tool access
alias haunt='claude --dangerously-skip-permissions'
```

Then reload your shell:

```bash
source ~/.bashrc   # or ~/.zshrc
```

**Why this works:**

- The main Claude Code session has access to ALL tools including Task
- The `/seance` command loads the orchestration workflow as a skill
- Agent spawning via Task tool works because you're in the main session

## See Also

- **`Haunt/docs/SEANCE-EXPLAINED.md`** - Complete documentation and philosophy
- **`Haunt/docs/assets/seance-infographic.html`** - Visual guide
- **`/summon <agent>`** - Directly spawn a specific agent
- **`/banish --all`** - Quick archive (same as `/seance --banish`)
- **`/haunting`** - View current active work
