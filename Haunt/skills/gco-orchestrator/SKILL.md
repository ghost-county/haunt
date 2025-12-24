---
name: gco-orchestrator
description: Conduct a séance - the Ghost County workflow orchestration ritual. Checks for Haunt framework updates, detects context (new vs existing project), guides through idea-to-roadmap planning, then optionally summons worker spirits. Use when starting a new project, adding features to existing projects, or when user says "start a seance", "hold a seance", "time for a seance", or "let's seance".
---

# Seance Workflow Orchestration

The Seance is Ghost County's primary workflow orchestration layer - a ritual that guides you from raw ideas to actionable roadmaps, then optionally summons worker agents ("spirits") to implement the plan.

**Framework Update Check:** Every seance begins by checking if the Haunt framework has been updated. If a new version is available, you'll be prompted to reinstall before continuing.

## When to Use

- **New Projects:** Full idea-to-roadmap workflow (vision → requirements → sizing → roadmap)
- **Existing Projects:** Incremental workflow for single enhancement/bug/issue
- **Trigger Phrases:** "start a seance", "hold a seance", "time for a seance", "let's seance"

## Six Operating Modes + Planning Depth

The Seance workflow has six modes (three context-aware and three phase-specific), with three planning depth levels that modify how deeply requirements are analyzed:

### Mode 1: With Prompt (Immediate Workflow)

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

### Mode 2: No Arguments + Existing Project (Choice Prompt)

**Triggered by:** `/seance` in repository with `.haunt/` directory

**Flow:**
1. Detect `.haunt/` exists
2. Present choice prompt:

```
🕯️ The spirits stir. What brings you to the veil?

[A] Add something new — I have an idea, feature, or bug to add
[B] Summon the spirits — The roadmap is ready. Let's work.

Your choice?
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

### Mode 3: No Arguments + New Project (New Project Prompt)

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


### Mode 4: Explicit Scrying (--scry / --plan)

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

### Mode 5: Explicit Summoning (--summon / --execute)

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
8. **Automatically trigger Mode 6 (--reap) after completion**

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

🌾 Automatically reaping the harvest...
[Mode 6 archival happens...]
```

**Error Handling:**
- If no roadmap exists: "No roadmap found. Run `/seance --scry` first."
- If no open items: "All requirements complete. Roadmap is clear!"
- If all items blocked: "All requirements blocked by dependencies. Resolve blockers first."

### Mode 6: Explicit Reaping (--reap / --archive)

**Triggered by:** `/seance --reap` or `/seance --archive`

**Purpose:** Run only the archival phase - clean up completed work.

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
- Manual cleanup when automatic reaping didn't run

**Example:**
```
User: /seance --reap
Agent:
🌾 Reaping the harvest...

Verifying completion...
✓ REQ-087: All 5 tasks checked
✓ REQ-088: All 3 tasks checked
✓ REQ-089: All 4 tasks checked
⚠ REQ-090: 2/3 tasks unchecked - skipping archival

Archiving 3 requirements to .haunt/completed/roadmap-archive.md...

🌙 The harvest is complete.

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
- User can fix and re-run `/seance --reap`

**Error Handling:**
- If no 🟢 items: "No completed requirements to archive."
- If archive write fails: "Error writing archive. Check permissions."

## Planning Depth Modifiers

All planning modes (1, 2, 3, 4) support three depth levels that control how thoroughly requirements are analyzed:

### Planning Depth: Quick (--quick)

**Triggered by:** `/seance --quick` or `/seance --quick <idea>`

**Purpose:** Fast-track simple tasks through minimal planning - skip strategic analysis, create basic requirement.

**Flow:**
1. Check if idea provided in command args
2. If no idea: Ask "What needs fixing?" and wait for user input
3. Create single requirement with minimal ceremony:
   - Parse idea to extract title
   - Infer affected files if obvious
   - Auto-assign to appropriate agent type
   - Set effort to XS or S based on description
   - Basic completion criteria (2-3 bullets)
4. **Skip Phase 2 entirely** - no JTBD, Kano, RICE, SWOT, VRIO analysis
5. Add requirement to roadmap immediately
6. Prompt to summon agent (same as other modes)

**Output:**
- Single requirement added to `.haunt/plans/roadmap.md`
- Minimal analysis overhead (<60 seconds total)
- Ready for immediate execution

**When to Use:**
- XS-S sized tasks only (typos, config changes, simple bug fixes)
- Obvious changes with clear scope
- Low-risk modifications
- Time-sensitive fixes

**When NOT to Use:**
- M-sized or larger features
- Changes with unclear scope
- Features requiring strategic analysis
- Cross-cutting changes affecting multiple systems

**Example:**
```
User: /seance --quick "Fix timeout value in config"
Agent:
⚡ Quick scrying...

Created REQ-225: Fix timeout value in config
- Type: Enhancement
- Effort: XS (~30 min)
- Agent: Dev-Infrastructure
- Files: config.yaml

Completion:
- Timeout value updated to recommended 30s
- Config file validated
- Changes tested

Ready to summon the spirits?
```

**Template for Quick Requirements:**

```markdown
### ⚪ REQ-XXX: [Title from user input]

**Type:** [Enhancement|Bug Fix]
**Reported:** [Today's date]
**Source:** Quick séance

**Description:**
[User's original input, lightly cleaned]

**Tasks:**
- [ ] [Inferred task 1]
- [ ] [Inferred task 2]
- [ ] [Inferred task 3]

**Files:**
- [Inferred file paths if obvious, otherwise "TBD - determine during implementation"]

**Effort:** [XS or S based on description keywords]
**Complexity:** SIMPLE
**Agent:** [Auto-assigned based on file types or description]
**Completion:** [2-3 basic acceptance criteria]
**Blocked by:** None
```

**Auto-Assignment Logic:**

Based on keywords in description:
- "config", "setup", "script" → Dev-Infrastructure
- "API", "endpoint", "database", "backend" → Dev-Backend
- "UI", "component", "page", "frontend" → Dev-Frontend
- "documentation", "README", "docs" → Dev-Infrastructure
- "test" only → Dev (whichever type matches file)

**Effort Detection:**

Based on keywords:
- "typo", "fix typo", "update config" → XS
- "add simple", "quick fix", "small change" → XS
- "add", "create simple", "update" → S
- Default: S (conservative)

**Error Handling:**
- If description is too vague: Ask clarifying question
- If scope appears too large: Warn and suggest standard mode instead
- If `.haunt/` missing: Create it with minimal setup

### Planning Depth: Standard (default)

**Triggered by:** No depth modifier, or explicitly `/seance <idea>` (no `--quick` or `--deep`)

**Purpose:** Balanced analysis for most features - full workflow with strategic frameworks and critical review.

**Flow:**
1. Phase 1: Requirements Development (14-dimension rubric, understanding confirmation)
2. Phase 2: Requirements Analysis (JTBD, Kano, RICE scoring)
3. **Phase 2.5: Critical Review** (spawn gco-research-critic to challenge assumptions, identify gaps)
4. Phase 3: Roadmap Creation (batching, sizing, agent assignment with critic findings)

**When to Use:**
- S-M sized features
- Standard features with clear-ish scope
- When depth needs are unknown (default choice)
- Most day-to-day development work

**Output:**
- `.haunt/plans/requirements-document.md` (new projects)
- `.haunt/plans/requirements-analysis.md` (new projects)
- `.haunt/plans/roadmap.md` (updated)

### Planning Depth: Deep (--deep)

**Triggered by:** `/seance --deep <idea>`

**Purpose:** Extended strategic analysis for high-impact, high-risk features.

**Flow:**
1. Phase 1: Requirements Development (standard)
2. **Phase 2 Extended:** Requirements Analysis PLUS:
   - Expanded SWOT matrix
   - VRIO competitive analysis
   - Risk assessment matrix
   - Stakeholder impact analysis
   - Architectural implications document
3. **Phase 2.5: Critical Review** (spawn gco-research-critic to review both requirements AND strategic analysis)
4. Phase 3: Roadmap Creation (standard, incorporating critic findings)

**When to Use:**
- M-SPLIT sized features
- High strategic impact features
- Features with significant architectural decisions
- Features affecting multiple systems or stakeholders
- When risk assessment is critical

**Output:**
- Standard outputs (requirements-document.md, requirements-analysis.md, roadmap.md)
- **PLUS:** `.haunt/plans/REQ-XXX-strategic-analysis.md` (extended analysis)

**Example Deep Analysis Document:**
```markdown
# REQ-XXX Strategic Analysis

## Expanded SWOT Matrix
[Detailed strengths, weaknesses, opportunities, threats]

## VRIO Competitive Analysis
[Value, Rarity, Imitability, Organization assessment]

## Risk Assessment Matrix
[Likelihood x Impact grid with mitigation strategies]

## Stakeholder Impact Analysis
[User segments, internal teams, external partners]

## Architectural Implications
[System dependencies, migration paths, rollback strategies]
```

## Phase 2.5: Critical Review (Detailed)

**Applies to:** Standard and Deep planning modes only (Quick mode skips this phase)

**Purpose:** Adversarial review of requirements and analysis to identify gaps, unstated assumptions, edge cases, and risks before roadmap creation.

**Workflow:**

1. **After Phase 2 Completes:**
   - Requirements document exists
   - Analysis complete (JTBD, Kano, RICE for Standard; plus strategic analysis for Deep)
   - Before roadmap creation begins

2. **Spawn gco-research-critic Agent:**
   ```
   Spawn gco-research-critic with context:
   - Requirements document path
   - Analysis document path(s)
   - Planning depth (Standard or Deep)

   Prompt: "Review the requirements and analysis for [feature name]. Challenge assumptions, identify gaps, and flag risks before roadmap creation."
   ```

3. **Critic Review Focus:**
   - **Unstated assumptions:** What's assumed but not written?
   - **Missing edge cases:** What boundary conditions aren't covered?
   - **Scope creep:** Are estimates realistic? Is requirement trying to do too much?
   - **Error handling gaps:** What failure modes aren't addressed?
   - **Unstated risks:** What could block this work?
   - **Problem-solution alignment:** Does the requirement actually solve the stated problem?

4. **Critic Output Format:**
   ```
   🔴 Critical Issues (must fix before roadmap):
   - [Specific finding with requirement reference]

   🟡 Warnings (should address):
   - [Potential problem or missing detail]

   🟢 Strengths (well-defined):
   - [What's done well - positive reinforcement]

   💡 Suggestions (consider):
   - [Alternative approaches or improvements]
   ```

5. **Integrate Findings into Phase 3:**
   - PM receives critic findings
   - Critical issues addressed before roadmap creation
   - Warnings incorporated into task lists or completion criteria
   - Suggestions noted for implementation consideration
   - Strengths reinforce confidence in approach

**Example Flow:**

```
[Phase 2 completes: JTBD, Kano, RICE analysis done]

> 🔍 Summoning the Research Critic for adversarial review...

[gco-research-critic spawned, reviews requirements + analysis]

Critic Findings:

🔴 Critical Issues:
- Requirements assume database migration is zero-downtime but no rollback strategy defined
- Completion criteria don't specify what happens if external API is unavailable

🟡 Warnings:
- Effort estimate (M, 3 hours) seems optimistic for 8 file changes across auth layer
- Edge case not addressed: What if user has existing session during migration?

🟢 Strengths:
- Clear problem statement with user impact quantified
- Error handling paths well-defined for primary flow

💡 Suggestions:
- Consider phased rollout instead of big-bang deployment
- Add feature flag for gradual migration

> 📋 Incorporating critic findings into roadmap...

[Phase 3: Roadmap creation with findings integrated]

REQ-XXX Tasks now include:
- [ ] Define database migration rollback strategy
- [ ] Add fallback handling for external API unavailability
- [ ] Implement feature flag for gradual rollout
- [ ] Test migration with existing user sessions
```

**When Critic Review Adds Value:**

- **Standard mode (most features):** Catches common oversights before implementation
- **Deep mode (strategic features):** Reviews both requirements AND strategic analysis for alignment
- **M-sized work:** Complex features benefit most from adversarial review
- **High-risk changes:** Auth, data integrity, breaking changes deserve extra scrutiny

**When to Skip (Quick mode):**

- XS-S tasks with obvious scope
- Typos, config changes, simple fixes
- Time-sensitive hotfixes
- Low-risk documentation updates

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

### Step 1: Detect Mode and Context

```python
import os

args = arguments.strip()
has_haunt = os.path.exists(".haunt/")

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
elif args in ["--reap", "--archive"]:
    mode = 6
elif args:
    mode = 1  # Immediate workflow with prompt
    workflow_type = "full" if not has_haunt else "incremental"
elif has_haunt:
    mode = 2  # Choice prompt (add new vs work roadmap)
else:
    mode = 3  # New project prompt
```

**Communicate mode to user:**

**Mode 1 (With Prompt):**
- New Project: "🕯️ No .haunt/ detected. Beginning full séance ritual..."
- Existing Project: "🕯️ Existing project detected. Beginning incremental séance..."
**Mode 2 (Choice Prompt with Interactive UI):**

Use the `AskUserQuestion` tool to present selectable options:

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

This provides:
- Clickable option selection
- Automatic "Tell Claude what to do" escape hatch
- Better UX than text-based prompts

**Mode 3 (New Project Prompt):**
```
🕯️ A fresh haunting ground. What would you like to build?
```

**Planning Depth Messages:**
- Quick: `⚡ Quick scrying...`
- Standard: `🔮 Scrying the future...`
- Deep: `🔮 Deep scrying the future...`

### Step 2: Execute Mode-Specific Flow

**Mode 1 (With Prompt):** Handle planning based on depth

**If planning_depth == "quick":**
- Skip PM entirely
- Create requirement directly (see Quick Planning implementation below)
- Add to roadmap immediately
- Prompt to summon

**If planning_depth == "standard":**
```
Spawn gco-project-manager with:
- User's original prompt/idea
- Instruction: "New project - execute full idea-to-roadmap workflow" OR "Existing project - add to roadmap"
- Planning depth: standard
```

**If planning_depth == "deep":**
```
Spawn gco-project-manager with:
- User's original prompt/idea
- Instruction: "New project - execute full idea-to-roadmap workflow" OR "Existing project - add to roadmap"
- Planning depth: deep (extended Phase 2 analysis)
- Create strategic analysis document: .haunt/plans/REQ-XXX-strategic-analysis.md
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

## Quick Planning Implementation

When `planning_depth == "quick"`, create requirements directly without PM:

```python
# Parse user input (from args or prompt)
idea = user_input.strip()

# Detect type
bug_keywords = ["fix", "bug", "error", "broken", "issue"]
is_bug = any(kw in idea.lower() for kw in bug_keywords)
req_type = "Bug Fix" if is_bug else "Enhancement"

# Auto-assign agent
if any(kw in idea.lower() for kw in ["config", "setup", "script", "doc"]):
    agent = "Dev-Infrastructure"
elif any(kw in idea.lower() for kw in ["api", "endpoint", "database", "backend"]):
    agent = "Dev-Backend"
elif any(kw in idea.lower() for kw in ["ui", "component", "page", "frontend"]):
    agent = "Dev-Frontend"
else:
    agent = "Dev-Infrastructure"  # Default

# Infer effort
xs_keywords = ["typo", "config", "small", "quick"]
effort = "XS" if any(kw in idea.lower() for kw in xs_keywords) else "S"

# Generate requirement
req_number = get_next_req_number()  # Parse roadmap for highest REQ-XXX
requirement = create_quick_requirement(
    number=req_number,
    title=idea,
    type=req_type,
    agent=agent,
    effort=effort
)

# Add to roadmap
append_to_roadmap(requirement)

# Display summary
print(f"✅ Created REQ-{req_number}: {title}")
print(f"   Agent: {agent}")
print(f"   Effort: {effort} (~30 min)" if effort == "XS" else f"   Effort: {effort} (~2 hours)")
```

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

### Step 4: Summoning Prompt

After planning completes, **ALWAYS prompt before spawning agents**.

**Response Selection (75/25 Rule):**
- **75% of the time:** Pick randomly from the canned prompts below
- **25% of the time:** Create your own original themed prompt in the Ghost County style (spooky, atmospheric, but brief)

**Canned Prompts:**
- "Ready to summon the spirits?"
- "Are you brave enough to summon the spirits?"
- "Shall we invoke the spirits for our dark intent?"
- "The spirits grow restless. Shall we release them?"
- "The veil is thin. Ready to call forth the spirits?"
- "Your roadmap is complete. Dare we wake the dead?"
- "The ritual is prepared. Summon the spirits?"
- "The incantation is ready. Shall we begin the summoning?"
- "The spirits await your command. Give the word?"
- "By candlelight and code, shall we summon our ghostly allies?"

Wait for user response.

### Step 5: User Decision

**If "Yes" (or affirmative):**

**Response Selection (75/25 Rule):**
- **75% of the time:** Pick randomly from the canned responses below
- **25% of the time:** Create your own original themed response (spooky emoji + brief atmospheric line)

**Canned Responses:**
- "👻 The spirits rise..."
- "🕯️ The candles flicker. They come."
- "💀 So be it. The summoning begins."
- "🌙 The veil parts..."
- "👁️ They hear your call."

Then spawn appropriate gco-* agents based on roadmap assignments:
- Batch 1 items with no dependencies can spawn in parallel
- Pass each agent its specific REQ-XXX assignment
- Use Task tool with appropriate subagent_type

**If "No" (or decline):**

**Response Selection (75/25 Rule):**
- **75% of the time:** Pick randomly from the canned responses below
- **25% of the time:** Create your own original themed response (spooky emoji + brief atmospheric line)

**Canned Responses:**
- "🕯️ The candles dim. The spirits rest... for now."
- "👻 Wise. The spirits will wait."
- "🌑 The séance concludes. Your roadmap stands ready."
- "💤 The dead sleep a while longer."

Confirm roadmap location:
> "Your roadmap is ready at `.haunt/plans/roadmap.md`. You can summon spirits later with `/summon <agent>` or begin implementation yourself."

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
5. **Generate completion report** - Summarize what was accomplished:

```
🌙 The spirits have returned. Their work is done.

Completed:
- 🟢 REQ-042: Implement JWT token generation
- 🟢 REQ-043: Add login endpoint
- 🟢 REQ-044: Add logout endpoint

Archived to .haunt/completed/roadmap-archive.md

Active roadmap cleaned. Ready for the next summoning.
```

**Partial Completion Handling:**

If some work is incomplete:
```
🌙 The spirits have returned. Some work remains.

Completed and Archived:
- 🟢 REQ-042: Implement JWT token generation

Still In Progress:
- 🟡 REQ-043: Add login endpoint (2/5 tasks complete)
- 🟡 REQ-044: Add logout endpoint (blocked - waiting on REQ-043)

Continue work with: /summon gco-dev-backend REQ-043
```

**Verification Issues:**

If checkboxes not updated:
```
⚠️ Roadmap needs attention:

REQ-042 marked 🟢 but tasks not checked:
- [ ] Implement token generation logic
- [ ] Add refresh token support
- [x] Write unit tests

Cannot archive until all tasks verified. Please update roadmap.
```

**When to Skip Gardening:**

- Mode 2 Choice A (user just added items, didn't summon)
- User declined summoning in Mode 1 or 3
- No agents were spawned

**Error Handling:**

- If agent fails: Report error, don't attempt gardening
- If roadmap parse fails: Report issue, leave roadmap unchanged
- If archive write fails: Report error, keep items in roadmap

## Example Flows

### Mode 1 Example: With Prompt (New Project)

```
User: "/seance Build a task management app"

Agent:
🕯️ No .haunt/ detected. Beginning full séance ritual...

I'll guide you through the complete idea-to-roadmap workflow.
Would you like to:
- [A] Review each phase (requirements → analysis → roadmap)
- [B] Run through all phases and present the final roadmap

[User chooses A]

[Phase 1: Requirements Development proceeds...]
[Phase 2: Strategic Analysis proceeds...]
[Phase 3: Roadmap Creation proceeds...]

✅ Roadmap complete with 12 requirements across 4 batches.

[Random selection from summoning prompts]
"The spirits await your command. Give the word?"

[User: "yes"]

[Random response]
"🌙 The veil parts..."

[Spawn agents for Batch 1 items]
Summoning gco-dev-infrastructure for REQ-001...
Summoning gco-dev-backend for REQ-002...
Summoning gco-dev-backend for REQ-003...
```

### Mode 1 Example: With Prompt (Existing Project)

```
User: "/seance Add OAuth login support"

Agent:
🕯️ Existing project detected. Beginning incremental séance...

[PM creates requirements for OAuth feature]
[PM analyzes and breaks into 5 requirements]
[PM adds REQ-087 through REQ-091 to roadmap]

✅ Added 5 new requirements in Batch 8: OAuth Integration

[Random selection]
"Ready to summon the spirits?"

[User: "no"]

[Random response]
"🌑 The séance concludes. Your roadmap stands ready."

Your roadmap is ready at `.haunt/plans/roadmap.md`.
You can summon spirits later with `/summon gco-dev-backend REQ-087`
```

### Mode 2 Example: Choice Prompt - Add New

```
User: "/seance"

Agent:
🕯️ The spirits stir. What brings you to the veil?

[A] Add something new — I have an idea, feature, or bug to add
[B] Summon the spirits — The roadmap is ready. Let's work.

Your choice?

User: "A"

Agent:
What would you like to add?

User: "Add rate limiting to the API"

Agent:
🕯️ Existing project detected. Beginning incremental séance...

[PM creates requirements for rate limiting]
[PM adds REQ-092 through REQ-094 to roadmap]

✅ Added 3 new requirements in Batch 9: Rate Limiting

[Random selection]
"Shall we invoke the spirits for our dark intent?"

[User: "yes"]

[Random response]
"👻 The spirits rise..."

Summoning gco-dev-backend for REQ-092...
Summoning gco-dev-backend for REQ-093...
Summoning gco-dev-infrastructure for REQ-094...
```

### Mode 2 Example: Choice Prompt - Work Roadmap

```
User: "/seance"

Agent:
🕯️ The spirits stir. What brings you to the veil?

[A] Add something new — I have an idea, feature, or bug to add
[B] Summon the spirits — The roadmap is ready. Let's work.

Your choice?

User: "B"

Agent:
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

User: "batch 3"

Agent:
[Random response]
"👁️ They hear your call."

Summoning gco-dev-backend for REQ-042...
Summoning gco-dev-backend for REQ-043...
Summoning gco-dev-backend for REQ-044...

[Agents work in parallel...]

[After all agents complete:]

Agent:
🌙 The spirits have returned. Their work is done.

Verifying roadmap...
✅ All tasks checked off for REQ-042, REQ-043, REQ-044
✅ All requirements properly completed

Archiving to .haunt/completed/roadmap-archive.md...

Completed and Archived:
- 🟢 REQ-042: Implement JWT token generation
- 🟢 REQ-043: Add login endpoint
- 🟢 REQ-044: Add logout endpoint

Active roadmap cleaned. Batch 3: Authentication complete.
Ready for the next summoning.
```

### Mode 3 Example: New Project Prompt

```
User: "/seance"

Agent:
🕯️ A fresh haunting ground. What would you like to build?

User: "A personal finance tracker"

Agent:
🕯️ No .haunt/ detected. Beginning full séance ritual...

[Full workflow proceeds as in Mode 1...]
```

## Implementation Notes

### Themed Prompts for Mode Transitions

Use these atmospheric prompts to enhance each mode:

**Mode 1 Detection (New Project):**
- "🕯️ No .haunt/ detected. Beginning full séance ritual..."
- "🕯️ A virgin repository. Let us prepare the full ritual..."
- "🕯️ Fresh ground for a haunting. The full séance begins..."

**Mode 1 Detection (Existing Project):**
- "🕯️ Existing project detected. Beginning incremental séance..."
- "🕯️ The spirits recognize this place. An incremental summoning..."
- "🕯️ A familiar haunting. Beginning targeted ritual..."

**Mode 2 Initial Prompt:**
- "🕯️ The spirits stir. What brings you to the veil?"
- "🕯️ The séance chamber awaits. What is your intent?"
- "🕯️ The candles flicker. Speak your purpose."

**Mode 2 Choice A Follow-up:**
- "What would you like to add?"
- "Tell me your vision. What shall we manifest?"
- "Speak it into being. What do you wish to create?"

**Mode 2 Choice B - Roadmap Display Header:**
- "📋 Current roadmap shows these unstarted items:"
- "📜 The grimoire reveals these pending rituals:"
- "📋 The spirits await these tasks:"

**Mode 2 Choice B - Agent Spawn Responses:**
Use the existing 75/25 random selection from summoning prompts:
- "👁️ They hear your call."
- "🌙 The veil parts..."
- "💀 So be it. The summoning begins."

**Mode 3 Initial Prompt:**
- "🕯️ A fresh haunting ground. What would you like to build?"
- "🕯️ Untouched soil. What shall we raise from nothing?"
- "🕯️ A blank slate awaits. What is your vision?"

### Theming Philosophy

- Keep atmospheric touches **light and quick**
- Theming enhances, doesn't obscure
- Core workflow stays clear and functional
- Random selection adds variety without being overwhelming
- Mode transitions should feel natural, not jarring

### Integration with PM Agent

The Seance skill is a **thin orchestration layer** that:
1. Detects context
2. Loads PM with appropriate mode
3. Adds themed prompts at the end
4. Optionally spawns workers

**The PM agent does all the real work** (requirements, analysis, roadmap creation).

### Hybrid Workflow: Plan → gco-project-manager Handoff

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

### Error Handling

**If `.haunt/` detection fails:**
- Default to incremental mode
- Inform user of assumption

**If PM fails during workflow:**
- Report error with context
- Don't proceed to summoning prompt
- Leave partial artifacts for debugging

**If user input is ambiguous:**
- Treat "maybe", "not sure", "later" as "No"
- Always err on side of NOT spawning agents

## Quality Checklist

Before completing the Seance:

**Mode Detection:**
- [ ] Mode detected correctly (1, 2, or 3)
- [ ] `.haunt/` directory check performed
- [ ] Arguments presence checked
- [ ] Appropriate themed prompt displayed for mode

**Mode 1 (With Prompt):**
- [ ] PM invoked with user's prompt
- [ ] Full vs incremental workflow determined correctly
- [ ] Planning workflow completed successfully
- [ ] Summoning prompt presented (random selection)
- [ ] User decision respected (yes/no)
- [ ] If yes: Appropriate agents spawned with assignments
- [ ] If no: Roadmap location confirmed

**Mode 2 (Choice Prompt):**
- [ ] Choice prompt presented correctly
- [ ] User choice [A] or [B] captured
- [ ] If A: Follow-up question asked, PM invoked for incremental workflow
- [ ] If B: Roadmap parsed, ⚪ items displayed grouped by batch
- [ ] If B: User selection parsed correctly (specific REQs, "all", or "batch N")
- [ ] If B: Appropriate agents spawned (skip summoning prompt)

**Mode 3 (New Project Prompt):**
- [ ] New project prompt presented
- [ ] User input captured for "What would you like to build?"
- [ ] PM invoked with full workflow

**All Modes:**
- [ ] All output stays in `.haunt/plans/`
- [ ] Themed prompts enhance without obscuring workflow
- [ ] Error handling for invalid user input

**Gardening Phase (After Agent Completion):**
- [ ] Waited for all spawned agents to complete
- [ ] Read roadmap and identified all 🟢 Complete items
- [ ] Verified all tasks are `- [x]` for each completed requirement
- [ ] Archived fully complete requirements to `.haunt/completed/roadmap-archive.md`
- [ ] Removed archived requirements from active roadmap
- [ ] Generated completion summary report
- [ ] Reported any verification issues (unchecked tasks)
- [ ] Handled partial completion appropriately
- [ ] Skipped gardening when no agents were spawned

## Skill References

This skill orchestrates these other skills:

- **gco-requirements-development** - Phase 1 of PM workflow
- **gco-requirements-analysis** - Phase 2 of PM workflow
- **gco-roadmap-creation** - Phase 3 of PM workflow
- **gco-project-manager** - Executes all three phases

The Seance doesn't duplicate their functionality - it just orchestrates them with themed prompts.
