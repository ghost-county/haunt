---
name: gco-seance
description: Conduct a séance - the Ghost County workflow orchestration ritual. Detects context (new vs existing project), guides through idea-to-roadmap planning, then optionally summons worker spirits. Use when starting a new project, adding features to existing projects, or when user says "start a seance", "hold a seance", "time for a seance", or "let's seance".
---

# Seance Workflow Orchestration

The Seance is Ghost County's primary workflow orchestration layer - a ritual that guides you from raw ideas to actionable roadmaps, then optionally summons worker agents ("spirits") to implement the plan.

## When to Use

- **New Projects:** Full idea-to-roadmap workflow (vision → requirements → sizing → roadmap)
- **Existing Projects:** Incremental workflow for single enhancement/bug/issue
- **Trigger Phrases:** "start a seance", "hold a seance", "time for a seance", "let's seance"

## Three Operating Modes

The Seance workflow has three context-aware modes:

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

## Workflow Steps

### Step 1: Detect Mode and Context

```python
import os

has_args = bool(arguments.strip())
has_haunt = os.path.exists(".haunt/")

if has_args:
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

**Mode 2 (Choice Prompt):**
```
🕯️ The spirits stir. What brings you to the veil?

[A] Add something new — I have an idea, feature, or bug to add
[B] Summon the spirits — The roadmap is ready. Let's work.

Your choice?
```

**Mode 3 (New Project Prompt):**
```
🕯️ A fresh haunting ground. What would you like to build?
```

### Step 2: Execute Mode-Specific Flow

**Mode 1 (With Prompt):** Invoke Project Manager immediately

**For Full Workflow (New Project):**
```
Spawn gco-project-manager with:
- User's original prompt/idea
- Instruction: "New project - execute full idea-to-roadmap workflow"
- Run-through or review mode (ask user preference)
```

**For Incremental Workflow (Existing Project):**
```
Spawn gco-project-manager with:
- User's feature/bug/enhancement request
- Instruction: "Existing project - add to roadmap"
- Context: Existing roadmap path (.haunt/plans/roadmap.md)
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
2. Spawn gco-project-manager with full workflow:
```
Spawn gco-project-manager with:
- User's project idea
- Instruction: "New project - execute full idea-to-roadmap workflow"
- Run-through or review mode (ask user preference)
```

### Step 3: Planning Phase

The Project Manager executes its workflow:

**Full Mode (3 Phases):**
1. **Phase 1:** Requirements Development
   - Understanding confirmation checkpoint
   - 14-dimension rubric application
   - Formal requirements document

2. **Phase 2:** Requirements Analysis
   - JTBD, Kano, RICE scoring
   - Strategic analysis
   - Implementation sequencing

3. **Phase 3:** Roadmap Creation
   - Break into S/M items
   - Batch organization
   - Agent assignments
   - Completion criteria

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
