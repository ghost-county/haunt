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

## Context Detection

The Seance workflow adapts based on project state:

### New Project (No `.haunt/` Directory)

**Full Workflow:**
1. Vision & Goals discussion
2. Requirements development (14-dimension rubric)
3. Strategic analysis (JTBD, Kano, RICE, etc.)
4. Roadmap creation (batching, sizing, dependencies)
5. Prompt to summon spirits for implementation

**Output:**
- `.haunt/plans/requirements-document.md`
- `.haunt/plans/requirements-analysis.md`
- `.haunt/plans/roadmap.md`

### Existing Project (Has `.haunt/` Directory)

**Incremental Workflow:**
1. Focus on single enhancement/bug/issue
2. Run abbreviated idea-to-roadmap for that item
3. Add to existing roadmap (continue REQ numbering)
4. Prompt to summon spirits for implementation

**Output:**
- Updated `.haunt/plans/roadmap.md` with new items

## Workflow Steps

### Step 1: Detect Context

```bash
# Check if .haunt/ exists
if [ -d ".haunt/" ]; then
  MODE="incremental"
else
  MODE="full"
fi
```

**Communicate mode to user:**
- Full: "🕯️ No .haunt/ detected. Beginning full séance ritual..."
- Incremental: "🕯️ Existing project detected. Beginning incremental séance..."

### Step 2: Invoke Project Manager

The Seance skill loads the `gco-project-manager` agent with appropriate context and user request.

**For Full Mode:**
```
Spawn gco-project-manager with:
- User's original prompt/idea
- Instruction: "New project - execute full idea-to-roadmap workflow"
- Run-through or review mode (ask user preference)
```

**For Incremental Mode:**
```
Spawn gco-project-manager with:
- User's feature/bug/enhancement request
- Instruction: "Existing project - add to roadmap"
- Context: Existing roadmap path (.haunt/plans/roadmap.md)
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

## Example Flow

### New Project Example

```
User: "Let's hold a seance to build a task management app"

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

### Existing Project Example

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

## Implementation Notes

### Theming Philosophy

- Keep atmospheric touches **light and quick**
- Theming enhances, doesn't obscure
- Core workflow stays clear and functional
- Random selection adds variety without being overwhelming

### Integration with PM Agent

The Seance skill is a **thin orchestration layer** that:
1. Detects context
2. Loads PM with appropriate mode
3. Adds themed prompts at the end
4. Optionally spawns workers

**The PM agent does all the real work** (requirements, analysis, roadmap creation).

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

- [ ] Context detected correctly (new vs existing)
- [ ] PM invoked with appropriate mode
- [ ] Planning workflow completed successfully
- [ ] Summoning prompt presented (random selection)
- [ ] User decision respected (yes/no)
- [ ] If yes: Appropriate agents spawned with assignments
- [ ] If no: Roadmap location confirmed
- [ ] All output stays in `.haunt/plans/`

## Skill References

This skill orchestrates these other skills:

- **gco-requirements-development** - Phase 1 of PM workflow
- **gco-requirements-analysis** - Phase 2 of PM workflow
- **gco-roadmap-creation** - Phase 3 of PM workflow
- **gco-project-manager** - Executes all three phases

The Seance doesn't duplicate their functionality - it just orchestrates them with themed prompts.
