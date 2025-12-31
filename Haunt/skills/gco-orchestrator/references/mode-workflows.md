# Mode Workflows: Step-by-Step Implementation

## Project Detection Logic

The Seance workflow uses **three-state detection** to correctly identify project context:

### 1. New Project
**Triggers full idea-to-roadmap workflow**

**Detection criteria:**
- `.haunt/` directory does not exist, OR
- `.haunt/` exists but roadmap.md is empty (no REQ-XXX items), AND
- Directory has ≤3 source files (minimal/empty directory)

**User experience:**
- "🕯️ No .haunt/ detected. Beginning full séance ritual..." (no .haunt/)
- "🕯️ Fresh installation detected (empty roadmap). Beginning full séance ritual..." (empty roadmap, minimal files)

**Workflow:** Complete JTBD/Kano/RICE analysis for new project vision

### 2. Existing Codebase
**Triggers full idea-to-roadmap workflow for new features**

**Detection criteria:**
- `.haunt/` exists
- roadmap.md is empty (no REQ-XXX items)
- Directory has >3 source files (existing codebase detected)

**User experience:**
- "🕯️ Existing codebase detected. Beginning full séance for new features..."

**Workflow:** Complete JTBD/Kano/RICE analysis, but context is "add features to existing product"

### 3. Active Project
**Triggers incremental workflow (add to existing roadmap)**

**Detection criteria:**
- `.haunt/` exists
- roadmap.md contains actual requirements (pattern: `### [⚪🟡🟢🔴] REQ-\d+`)

**User experience:**
- "🕯️ Existing project detected. Beginning incremental séance..."

**Workflow:** Brief analysis, add new items to existing roadmap

### Source File Detection

**Files counted as "source files":**
- Extensions: `.py`, `.js`, `.ts`, `.tsx`, `.jsx`, `.go`, `.java`, `.rb`, `.php`, `.rs`, `.c`, `.cpp`, `.h`, `.sh`, `.ps1`, `.sql`

**Files/directories ignored:**
- Setup directories: `.git`, `.claude`, `.haunt`, `node_modules`, `__pycache__`, `.venv`, `venv`
- Config files: `package.json`, `README.md`, `.gitignore`, `LICENSE`

**Threshold:** >3 source files indicates existing codebase

### Why This Matters

**Before (bug):**
- Fresh HAUNT install → creates empty roadmap.md
- Séance sees roadmap.md exists → assumes "existing project"
- Skips full JTBD/Kano/RICE analysis inappropriately

**After (fix):**
- Fresh HAUNT install → detects empty roadmap + minimal files → "new_project"
- Runs full idea-to-roadmap workflow correctly
- Existing codebase with empty roadmap → still gets full workflow (correct for adding features to existing product)

---

## Mode 1: With Prompt (Immediate Workflow)

**Triggered by:** `/seance <user prompt>`

**Flow:**
1. Detect if `.haunt/` exists (determines full vs incremental)
2. Execute idea-to-roadmap workflow with user's prompt
3. Prompt to summon spirits after planning

**For New Projects:**
- Full workflow: Vision → Requirements → Analysis → Roadmap
- Creates `.haunt/plans/requirements-document.md`, `requirements-analysis.md`, `roadmap.md`

**For Existing Projects:**
- Incremental workflow: Brief analysis → Add to roadmap
- Updates `.haunt/plans/roadmap.md` with new items

---

## Mode 2: No Arguments + Existing Project (Choice Prompt)

**Triggered by:** `/seance` in repository with `.haunt/` directory

**Flow:**
1. Detect `.haunt/` exists
2. Present choice prompt using AskUserQuestion:

```python
AskUserQuestion(
    questions=[{
        "question": "What brings you to the veil?",
        "header": "Seance",
        "multiSelect": False,
        "options": [
            {
                "label": "Add something new",
                "description": "I have an idea, feature, or bug to add"
            },
            {
                "label": "Summon the spirits",
                "description": "The roadmap is ready. Let's work."
            }
        ]
    }]
)
```

3. **If Choice A:**
   - Ask: "What would you like to add?"
   - Wait for user input
   - Execute incremental idea-to-roadmap workflow
   - Add to existing roadmap
   - Prompt to summon spirits

4. **If Choice B:**
   - Read `.haunt/plans/roadmap.md`
   - Find all ⚪ Not Started items
   - Display items grouped by batch/phase
   - Ask: "Which requirements should the spirits work on? (e.g., REQ-042, REQ-043) or 'all' for the next batch"
   - Spawn agents for selected items

**Output (Choice A):**
- Updated `.haunt/plans/roadmap.md` with new items

**Output (Choice B):**
- Spawned agents working on selected requirements

---

## Mode 3: No Arguments + New Project (New Project Prompt)

**Triggered by:** `/seance` in repository without `.haunt/` directory

**Flow:**
1. Detect `.haunt/` does NOT exist
2. Present new project prompt:

```
🕯️ A fresh haunting ground. What would you like to build?
```

3. Wait for user input
4. Execute full idea-to-roadmap workflow
5. Prompt to summon spirits after planning

**Output:**
- `.haunt/plans/requirements-document.md`
- `.haunt/plans/requirements-analysis.md`
- `.haunt/plans/roadmap.md`

---

## Mode 4: Explicit Scrying (--scry / --plan)

**Triggered by:** `/seance --scry` or `/seance --plan` (with optional idea)

**Purpose:** Run only the planning phase - transform raw ideas into formal roadmaps.

**Flow:**
1. Check if idea provided in command args
2. If no idea: Ask "What would you like to scry?" and wait for user input
3. Execute idea-to-roadmap workflow (same as Mode 1/2A/3)
4. Output roadmap to `.haunt/plans/roadmap.md`
5. **Do NOT prompt to summon** - user explicitly requested planning only
6. Confirm roadmap created and suggest next step: `/seance --summon`

**Output:**
- `.haunt/plans/roadmap.md` updated with new requirements
- Success message with roadmap location
- Suggestion: "Ready to execute? Run `/seance --summon`"

**When to Use:**
- User wants to plan without immediate execution
- Separating planning from execution phases
- Building up a roadmap before batch execution

**Example:**
```
User: /seance --scry "Add OAuth login"
Agent:
🔮 Scrying the future...
[Planning workflow...]
✅ Roadmap created with 5 requirements
Ready to execute? Run `/seance --summon`
```

---

## Mode 5: Explicit Summoning (--summon / --execute)

**Triggered by:** `/seance --summon` or `/seance --execute`

**Purpose:** Run only the execution phase - spawn agents for existing roadmap items.

**Flow:**
1. Read `.haunt/plans/roadmap.md`
2. Parse and find all ⚪ Not Started items
3. Parse and find all 🟡 In Progress items
4. Filter out items with unmet dependencies ("Blocked by: REQ-XXX")
5. Group remaining items by batch
6. Spawn appropriate agents for all unblocked items in parallel
7. Wait for agents to complete (or run in background)
8. **Automatically trigger Mode 6 (--banish) after completion**

**Output:**
- Spawned agents working on requirements
- Real-time progress updates as agents complete
- Automatic archival and cleanup via Mode 6

**When to Use:**
- Roadmap already exists (from previous `/seance --scry`)
- Resuming work on existing roadmap
- Batch execution of multiple requirements
- User wants execution without re-planning

**Example:**
```
User: /seance --summon
Agent:
Reading roadmap...
Found 8 open requirements (5 ⚪ Not Started, 3 🟡 In Progress)

👻 The spirits rise...
Summoning gco-dev-backend for REQ-042...
Summoning gco-dev-backend for REQ-043...
Summoning gco-dev-frontend for REQ-044...

[Agents work autonomously...]
[All agents complete...]

⚰️ Automatically banishing completed work...
[Mode 6 archival happens...]
```

**Error Handling:**
- If no roadmap exists: "No roadmap found. Run `/seance --scry` first."
- If no open items: "All requirements complete. Roadmap is clear!"
- If all items blocked: "All requirements blocked by dependencies. Resolve blockers first."

---

## Mode 6: Explicit Banishing (--banish / --archive)

**Triggered by:** `/seance --banish` or `/seance --archive`

**Purpose:** Run only the archival phase - clean up completed work (runs `/banish --all`).

**Flow:**
1. Read `.haunt/plans/roadmap.md`
2. Find all 🟢 Complete items
3. **Verification Phase:**
   - For each 🟢 item, check all tasks are `- [x]` (not `- [ ]`)
   - Verify completion criteria met (if possible)
   - Flag any incomplete items
4. **Archival Phase:**
   - Read or create `.haunt/completed/roadmap-archive.md`
   - Append all verified 🟢 items with completion dates
   - Remove archived items from active roadmap
5. **Reporting Phase:**
   - Generate completion summary
   - Show what was archived
   - Report any verification issues
   - Confirm roadmap cleaned

**Output:**
- Clean roadmap with only ⚪, 🟡, 🔴 items
- Archived history in `.haunt/completed/roadmap-archive.md`
- Completion summary report

**When to Use:**
- After summoning completes
- Weekly/sprint-end cleanup ritual
- When roadmap has many 🟢 items (>10)
- Manual cleanup when automatic banishing didn't run

**Example:**
```
User: /seance --banish
Agent:
⚰️ Banishing completed work...

Verifying completion...
✓ REQ-087: All 5 tasks checked
✓ REQ-088: All 3 tasks checked
✓ REQ-089: All 4 tasks checked
⚠ REQ-090: 2/3 tasks unchecked - skipping archival

Archiving 3 requirements to .haunt/completed/roadmap-archive.md...

⚰️ The spirits rest.

Completed and Archived:
- 🟢 REQ-087: Implement OAuth provider integration
- 🟢 REQ-088: Add login redirect flow
- 🟢 REQ-089: Secure token storage

Needs Attention:
- 🟢 REQ-090: Add logout endpoint (incomplete tasks)

Active roadmap cleaned.
```

**Verification Rules:**
- All tasks must be `- [x]` (checked)
- If any tasks unchecked, skip archival and report
- User can fix and re-run `/seance --banish`

**Error Handling:**
- If no 🟢 items: "No completed requirements to archive."
- If archive write fails: "Error writing archive. Check permissions."

---

## Workflow Steps

### Step 0: Check Haunt Framework Version (Run First)

Before starting the seance workflow, check if the Haunt framework needs updating:

```python
import os
import subprocess

def check_haunt_version():
    """
    Check if local Haunt installation matches repository version.
    Returns tuple: (is_outdated: bool, local_sha: str, repo_sha: str)
    """
    # Get repository SHA from Haunt/.haunt-version
    repo_version_file = "Haunt/.haunt-version"
    if not os.path.exists(repo_version_file):
        return (False, None, None)  # Version tracking not available

    # Parse repo SHA
    repo_sha = None
    with open(repo_version_file, 'r') as f:
        for line in f:
            if line.startswith("HAUNT_SHA="):
                repo_sha = line.split('=')[1].strip()
                break

    if not repo_sha:
        return (False, None, None)

    # Get installed SHA from user's home directory
    home_version_file = os.path.expanduser("~/.claude/.haunt-version")
    if not os.path.exists(home_version_file):
        return (True, None, repo_sha)  # Not installed or old installation

    # Parse installed SHA
    local_sha = None
    with open(home_version_file, 'r') as f:
        for line in f:
            if line.startswith("HAUNT_SHA="):
                local_sha = line.split('=')[1].strip()
                break

    # Compare
    is_outdated = (local_sha != repo_sha)
    return (is_outdated, local_sha, repo_sha)

# At seance start, check version
is_outdated, local_sha, repo_sha = check_haunt_version()

if is_outdated:
    # Prompt user for reinstall
    print("\n🔮 Haunt framework has new features available.\n")
    if local_sha:
        print(f"   Installed: {local_sha[:8]}")
    else:
        print("   Installed: Unknown or not installed")
    print(f"   Available: {repo_sha[:8]}\n")

    user_response = input("Reinstall to get latest features? (Y/n): ").strip().lower()

    if user_response in ['', 'y', 'yes']:
        # Run setup script
        print("\n📦 Reinstalling Haunt framework...\n")

        # Detect platform
        import platform
        if platform.system() == "Windows":
            # PowerShell script
            subprocess.run(["powershell", "-File", "Haunt/scripts/setup-haunt.ps1"], check=False)
        else:
            # Bash script
            subprocess.run(["bash", "Haunt/scripts/setup-haunt.sh"], check=False)

        # Display restart instructions
        print("\n✅ Haunt framework reinstalled!\n")
        print("⚠️  To use new features, restart Claude Code:")
        print("   1. Type 'exit' or close this chat session")
        print("   2. Start a new session")
        print("   3. New agents, skills, and commands will be available\n")

        # Ask if user wants to continue or restart
        continue_response = input("Continue with current session? (y/N): ").strip().lower()
        if continue_response not in ['y', 'yes']:
            print("\n👻 The spirits rest. Restart Claude Code when ready.")
            return  # Exit seance
    else:
        print("\n⚠️  Continuing with current version. Some features may be unavailable.\n")

# Proceed with normal seance workflow...
```

**When to run this check:**
- At the very start of every `/seance` invocation
- Before any mode detection or user prompts
- Skip if version file doesn't exist (backward compatibility)

**Restart Instructions:**

After successful reinstall, provide clear restart guidance:

```
✅ Haunt framework reinstalled!

⚠️  To use new features, restart Claude Code:
   1. Type 'exit' or close this chat session
   2. Start a new session
   3. New agents, skills, and commands will be available
```

**Error Handling:**
- If version file doesn't exist: Skip check silently (backward compatibility)
- If setup script fails: Report error, continue with current version
- If user declines reinstall: Warn about missing features, continue
- If user declines to continue after reinstall: Exit seance gracefully

---

### Step 1: Detect Mode and Context

```python
import os
import re

args = arguments.strip()

# Step 1A: Detect project state (three-state classification)
def detect_project_state():
    """
    Detect project state with three classifications:
    - "new_project": Empty/minimal dir with empty roadmap (HAUNT just installed)
    - "existing_codebase": Has source files but roadmap is empty (needs features)
    - "active_project": Roadmap contains actual requirements (add to existing work)

    Returns tuple: (state: str, has_haunt: bool, has_requirements: bool)
    """
    has_haunt = os.path.exists(".haunt/")

    # If no .haunt/ directory, it's a new project (will be created)
    if not has_haunt:
        return ("new_project", False, False)

    # Check if roadmap exists and has actual requirements
    roadmap_path = ".haunt/plans/roadmap.md"
    has_requirements = False

    if os.path.exists(roadmap_path):
        try:
            with open(roadmap_path, 'r') as f:
                content = f.read()
                # Search for actual requirement patterns (### ⚪ REQ-, ### 🟡 REQ-, etc.)
                req_pattern = r'### [⚪🟡🟢🔴] REQ-\d+'
                has_requirements = bool(re.search(req_pattern, content))
        except Exception:
            has_requirements = False

    # If has requirements, it's an active project
    if has_requirements:
        return ("active_project", True, True)

    # Roadmap empty - check if directory has meaningful source files
    has_source_files = count_source_files() > 3  # More than just setup files

    if has_source_files:
        return ("existing_codebase", True, False)
    else:
        return ("new_project", True, False)

def count_source_files():
    """
    Count meaningful source files (not setup/config).
    Returns count of files that suggest an existing codebase.
    """
    setup_patterns = {'.git', '.claude', '.haunt', 'node_modules', '__pycache__', '.venv', 'venv'}
    config_files = {'package.json', 'README.md', '.gitignore', 'LICENSE'}

    count = 0
    for root, dirs, files in os.walk('.'):
        # Skip setup directories
        dirs[:] = [d for d in dirs if d not in setup_patterns]

        # Count non-config source files
        for file in files:
            if file not in config_files:
                # Check for source file extensions
                if any(file.endswith(ext) for ext in ['.py', '.js', '.ts', '.tsx', '.jsx', '.go', '.java', '.rb', '.php', '.rs', '.c', '.cpp', '.h', '.sh', '.ps1', '.sql']):
                    count += 1

    return count

# Detect project state
project_state, has_haunt, has_requirements = detect_project_state()

# Extract planning depth modifiers first
planning_depth = "standard"  # default
if "--quick" in args:
    planning_depth = "quick"
    args = args.replace("--quick", "").strip()
elif "--deep" in args:
    planning_depth = "deep"
    args = args.replace("--deep", "").strip()

# Check for explicit phase flags (after removing depth modifiers)
if args in ["--scry", "--plan"]:
    mode = 4
elif args.startswith("--scry ") or args.startswith("--plan "):
    mode = 4
elif args in ["--summon", "--execute"]:
    mode = 5
elif args in ["--banish", "--archive"]:
    mode = 6
elif args:
    mode = 1  # Immediate workflow with prompt
    # Use project_state to determine workflow type
    workflow_type = "full" if project_state in ["new_project", "existing_codebase"] else "incremental"
elif has_haunt:
    mode = 2  # Choice prompt (add new vs work roadmap)
else:
    mode = 3  # New project prompt
```

**Communicate mode to user:**

**Mode 1 (With Prompt):**
- New Project (no .haunt/): "🕯️ No .haunt/ detected. Beginning full séance ritual..."
- New Project (empty roadmap): "🕯️ Fresh installation detected (empty roadmap). Beginning full séance ritual..."
- Existing Codebase (has source files, empty roadmap): "🕯️ Existing codebase detected. Beginning full séance for new features..."
- Active Project (has requirements): "🕯️ Existing project detected. Beginning incremental séance..."

**Planning Depth Messages:**
- Quick: `⚡ Quick scrying...`
- Standard: `🔮 Scrying the future...`
- Deep: `🔮 Deep scrying the future...`

---

### Step 2: Execute Mode-Specific Flow

**Mode 1 (With Prompt):** Handle planning based on depth

**If planning_depth == "quick":**
- Skip PM entirely
- Create requirement directly (see references/planning-depth.md)
- Add to roadmap immediately
- Prompt to summon

**If planning_depth == "standard":**
```
Spawn gco-project-manager with:
- User's original prompt/idea
- Instruction based on project_state:
  - "new_project" → "New project - execute full idea-to-roadmap workflow"
  - "existing_codebase" → "Existing codebase - execute full idea-to-roadmap workflow for new features"
  - "active_project" → "Existing project - add to roadmap"
- Planning depth: standard
- Project state: {project_state} (for debugging visibility)
```

**If planning_depth == "deep":**
```
Spawn gco-project-manager with:
- User's original prompt/idea
- Instruction based on project_state:
  - "new_project" → "New project - execute full idea-to-roadmap workflow"
  - "existing_codebase" → "Existing codebase - execute full idea-to-roadmap workflow for new features"
  - "active_project" → "Existing project - add to roadmap"
- Planning depth: deep (extended Phase 2 analysis)
- Create strategic analysis document: .haunt/plans/REQ-XXX-strategic-analysis.md
- Project state: {project_state} (for debugging visibility)
```

**Mode 2 (Choice Prompt):** Handle user choice

**Choice A (Add Something New):**
1. Ask: "What would you like to add?"
2. Wait for user response
3. Spawn gco-project-manager with incremental workflow:
```
Spawn gco-project-manager with:
- User's new feature/bug/enhancement
- Instruction: "Existing project - add to roadmap"
- Context: Existing roadmap path (.haunt/plans/roadmap.md)
```

**Choice B (Summon the Spirits):**
1. Read `.haunt/plans/roadmap.md`
2. Parse and extract all ⚪ Not Started requirements
3. Group by batch/phase for display
4. Present to user:
```
📋 Current roadmap shows these unstarted items:

Batch 3: Authentication
- ⚪ REQ-042: Implement JWT token generation
- ⚪ REQ-043: Add login endpoint
- ⚪ REQ-044: Add logout endpoint

Batch 4: User Management
- ⚪ REQ-045: Create user profile API
- ⚪ REQ-046: Add avatar upload

Which requirements should the spirits work on?
- Enter specific REQ numbers (e.g., "REQ-042, REQ-043")
- Or "all" for the next batch
- Or "batch 3" for all items in Batch 3
```
5. Parse user selection
6. Spawn appropriate agents for selected items (skip Step 3 & 4 summoning prompt)

**Mode 3 (New Project Prompt):**
1. Wait for user input to "What would you like to build?"
2. Handle based on planning_depth (same as Mode 1)

**Mode 4 (Explicit Scrying --scry/--plan):**
1. Check if idea provided in args
2. If no idea: Ask "What would you like to scry?" and wait
3. Handle based on planning_depth (same as Mode 1)
4. Do NOT prompt to summon (user explicitly wants planning only)
5. Suggest next step: `/seance --summon`

---

### Step 3: Planning Phase

The Project Manager executes its workflow:

**Full Mode (4 Phases):**
1. **Phase 1:** Requirements Development
   - Understanding confirmation checkpoint
   - 14-dimension rubric application
   - Formal requirements document

2. **Phase 2:** Requirements Analysis
   - JTBD, Kano, RICE scoring
   - Strategic analysis
   - Implementation sequencing

3. **Phase 2.5:** Critical Review (Standard & Deep modes only)
   - Spawn gco-research-critic agent
   - Review requirements document + analysis
   - Challenge assumptions, identify gaps
   - Provide findings for roadmap refinement
   - Quick mode skips this phase

4. **Phase 3:** Roadmap Creation
   - Break into S/M items
   - Batch organization
   - Agent assignments
   - Completion criteria
   - Incorporate critic findings

**Incremental Mode (Streamlined):**
1. Understanding confirmation
2. Brief analysis
3. Add to existing roadmap with proper numbering

---

### Step 4: Summoning Prompt

After planning completes, **ALWAYS prompt before spawning agents**.

**Response Selection (75/25 Rule):**
- **75% of the time:** Pick randomly from canned prompts (see references/themed-prompts.md)
- **25% of the time:** Create your own original themed prompt in the Ghost County style (spooky, atmospheric, but brief)

Wait for user response.

---

### Step 5: User Decision

**If "Yes" (or affirmative):**

**Response Selection (75/25 Rule):**
- **75% of the time:** Pick randomly from canned responses (see references/themed-prompts.md)
- **25% of the time:** Create your own original themed response (spooky emoji + brief atmospheric line)

Then spawn appropriate gco-* agents based on roadmap assignments:
- Batch 1 items with no dependencies can spawn in parallel
- Pass each agent its specific REQ-XXX assignment
- Use Task tool with appropriate subagent_type

**If "No" (or decline):**

**Response Selection (75/25 Rule):**
- **75% of the time:** Pick randomly from canned responses (see references/themed-prompts.md)
- **25% of the time:** Create your own original themed response (spooky emoji + brief atmospheric line)

Confirm roadmap location:
> "Your roadmap is ready at `.haunt/plans/roadmap.md`. You can summon spirits later with `/summon <agent>` or begin implementation yourself."

---

### Step 6: Garden and Archive (After Agents Complete Work)

**When spawned agents finish their work**, automatically perform roadmap gardening:

**Gardening Process:**

1. **Wait for agent completion** - Track all spawned agents, wait for them to return
2. **Read completed work** - Review `.haunt/plans/roadmap.md` for all 🟢 Complete items
3. **Verify task checkboxes** - For each 🟢 requirement:
   - Check all tasks are `- [x]` (not `- [ ]`)
   - If any unchecked: Report to user, don't archive
4. **Archive completed work** - For fully complete requirements:
   - Use `/banish` logic to move to `.haunt/completed/roadmap-archive.md`
   - Remove from active roadmap
5. **Generate completion report** - Summarize what was accomplished

**When to Skip Gardening:**

- Mode 2 Choice A (user just added items, didn't summon)
- User declined summoning in Mode 1 or 3
- No agents were spawned

**Error Handling:**

- If agent fails: Report error, don't attempt gardening
- If roadmap parse fails: Report issue, leave roadmap unchanged
- If archive write fails: Report error, keep items in roadmap

---

## Hybrid Workflow: Plan → gco-project-manager Handoff

The Seance skill can leverage Claude Code's built-in Plan agent for high-level strategic planning before invoking gco-project-manager for detailed roadmap creation.

**When to use this pattern:**
- User wants strategic breakdown first ("Plan out this feature")
- Complex features benefit from two-phase planning (strategy → formalization)
- User explicitly requests Plan agent or mentions "planning mode"

**Example Flow:**

```
User: "/seance Plan out a task management app"

Main Agent:
  1. Detects "Plan out" trigger phrase
  2. Spawns Plan agent (built-in):
     - Prompt: "Create strategic breakdown for task management app"
     - Output: High-level plan with phases, major components, tech stack recommendations

  3. Reviews Plan agent output with user:
     "Here's the strategic plan. Would you like me to formalize this into a Ghost County roadmap?"

  4. If yes, spawns gco-project-manager (Haunt):
     - Context: Plan agent's strategic breakdown
     - Instruction: "Convert this plan into formal requirements and roadmap"
     - Output: requirements-document.md, requirements-analysis.md, roadmap.md

  5. Summoning prompt (standard flow from here)
```

**Why it works:**
- Plan agent (Sonnet) provides quick strategic thinking without getting into requirements details
- gco-project-manager formalizes with Ghost County requirements format (14-dimension rubric, JTBD/Kano/RICE analysis)
- Separation of concerns: Strategy → Formalization → Implementation

**Trigger phrases:**
- "Plan out..."
- "Create a plan for..."
- "Strategic breakdown of..."
- "High-level plan..."

**Anti-pattern:** Don't invoke Plan agent for simple incremental features - it adds unnecessary overhead.
