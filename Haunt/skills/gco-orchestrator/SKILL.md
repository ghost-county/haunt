---
name: gco-orchestrator
description: Conduct a séance - the Ghost County workflow orchestration ritual. Checks for Haunt framework updates, detects context (new vs existing project), guides through idea-to-roadmap planning, then optionally summons worker spirits. Use when starting a new project, adding features to existing projects, or when user says "start a seance", "hold a seance", "time for a seance", or "let's seance".
---

# Seance Workflow Orchestration

The Seance is Ghost County's primary workflow orchestration layer - a ritual that guides you from raw ideas to actionable roadmaps, then optionally summons worker agents ("spirits") to implement the plan.

**Framework Update Check:** Every seance begins by checking if the Haunt framework has been updated. If a new version is available, you'll be prompted to reinstall before continuing.

---

## DELEGATION GATE (Before ANY Action)

⛔ **CRITICAL CHECKPOINT:** Before executing any action, verify you're not about to do specialized work.

**Am I about to do specialized work?**
- [ ] WebSearch/WebFetch → ⛔ STOP: Spawn gco-research-analyst
- [ ] Multi-file analysis (>10 files) → ⛔ STOP: Spawn gco-research-analyst
- [ ] Requirements analysis (JTBD/Kano/RICE) → ⛔ STOP: Spawn gco-project-manager
- [ ] Write code/tests → ⛔ STOP: Spawn gco-dev-*
- [ ] Code review → ⛔ STOP: Spawn gco-code-reviewer

**If ALL boxes are unchecked:** Proceed (this is coordination work)
**If ANY box is checked:** STOP and spawn the indicated agent

⛔ **PROHIBITION:** Orchestrators NEVER execute WebSearch, WebFetch, or multi-file Read operations directly. These are research activities requiring specialist agents.

⛔ **PROHIBITION (NEW - Tool Permissions):** Orchestrators CANNOT use Edit or Write tools on source code files. These tools are RESTRICTED to dev agents only. Attempting to modify source code will fail with a permissions error.

**What this means:**
- Edit/Write on `.haunt/` files: ✅ ALLOWED (coordination work - roadmaps, notes, planning docs)
- Edit/Write on source code (`.py`, `.ts`, `.js`, etc.): ❌ FORBIDDEN (spawn dev agent instead)
- This is enforced by Claude Code's tool permissions system - not just guidance

**If you attempt to edit source code:**
1. Claude Code will return: "Error: Permission denied. This tool is restricted to dev agents."
2. STOP immediately
3. Spawn appropriate dev agent with task context
4. Let dev agent perform the edit

**Example (WRONG):**
```
User: "/seance Add login endpoint"

Orchestrator:
  [Creates REQ-042 in roadmap]
  [Attempts: Edit(src/api/auth.py, ...)]  # ❌ PERMISSION DENIED
```

**Example (RIGHT):**
```
User: "/seance Add login endpoint"

Orchestrator:
  [Creates REQ-042 in roadmap]
  [Spawns gco-dev-backend with REQ-042]

Dev Agent:
  [Edit(src/api/auth.py, ...)]  # ✅ ALLOWED (dev agent)
```

**See also:** `references/delegation-protocol.md` for detailed anti-patterns and examples

---

## SCRYING COMPLETION GATE (Before Implementation)

⛔ **CRITICAL:** Discussion is NOT scrying. Research is NOT scrying. Scrying is complete ONLY when:

1. **REQ-XXX exists** in `.haunt/plans/roadmap.md`
2. **User approved** the requirement (explicitly or via summoning prompt)

**Before spawning dev agents or using Edit/Write on source code:**

```
□ Does REQ-XXX exist in roadmap?
  - NO → STOP: Complete scrying first (spawn PM or create requirement)
  - YES → Continue

□ Did user approve the plan?
  - NO → STOP: Present summoning prompt and wait for approval
  - YES → Proceed with spawning agents
```

**Anti-Pattern:** Agent and user discuss a feature for 10 messages, then agent starts editing files directly. This skips the formal scrying gate - no REQ-XXX was ever created.

**Correct Pattern:** After discussion, agent says "Let me formalize this into a requirement" → creates REQ-XXX → presents summoning prompt → user approves → spawns dev agent.

---

## Six Operating Modes Overview

| Mode | Trigger | Purpose |
|------|---------|---------|
| **Mode 1** | `/seance <prompt>` | Immediate workflow with user's idea |
| **Mode 2** | `/seance` (existing) | Choice prompt: Add new OR Work roadmap |
| **Mode 3** | `/seance` (new) | New project prompt: What to build? |
| **Mode 4** | `--scry / --plan` | Planning only (no summoning) |
| **Mode 5** | `--summon / --execute` | Execution only (spawn agents for roadmap) |
| **Mode 6** | `--banish / --archive` | Cleanup only (archive completed work) |

**See also:** `references/mode-workflows.md` for complete step-by-step flows

---

## Planning Depth Modifiers

| Depth | Trigger | When to Use |
|-------|---------|-------------|
| **Quick** | `--quick` | XS-S tasks, simple fixes, skip strategic analysis |
| **Standard** | (default) | S-M features, balanced analysis, most work |
| **Deep** | `--deep` | M-SPLIT features, strategic analysis, high-risk changes |

**See also:** `references/planning-depth.md` for detailed workflows and Phase 2.5 critical review

---

## Reference Index

**⛔ CONSULTATION GATE:** When you encounter these triggers, READ the corresponding reference file BEFORE proceeding.

| When You Need | Read This |
|---------------|-----------|
| **Anti-pattern examples** (WRONG vs RIGHT) | `references/delegation-protocol.md` |
| **Mode 1-6 step-by-step workflows** | `references/mode-workflows.md` |
| **Quick/Standard/Deep planning details** | `references/planning-depth.md` |
| **Phase 2.5 critical review workflow** | `references/planning-depth.md` |
| **Complete example conversations** | `references/example-flows.md` |
| **Themed prompts for summoning** | `references/themed-prompts.md` |
| **Project detection logic** | `references/mode-workflows.md` |
| **Framework version check code** | `references/mode-workflows.md` |
| **Gardening/archival workflow** | `references/mode-workflows.md` |

**Self-Check:** If you're unsure how to proceed at any step, check the reference index to find the appropriate guidance.

---

## When to Use

- **New Projects:** Full idea-to-roadmap workflow (vision → requirements → sizing → roadmap)
- **Existing Projects:** Incremental workflow for single enhancement/bug/issue
- **Trigger Phrases:** "start a seance", "hold a seance", "time for a seance", "let's seance"

---

## Core Delegation Principle

**Orchestrators coordinate workflows but DO NOT execute specialized work.**

### What Orchestrators DO (Execute Directly)

- **Mode detection:** Detect project state (new vs existing vs active)
- **User prompts:** Present choice prompts and mode selection (use AskUserQuestion for interactive UI)
- **Parse input:** Extract planning depth modifiers, phase flags
- **Coordinate workflows:** Invoke PM for planning, spawn agents for execution
- **Archive/garden:** Clean up completed work after agents finish

### What Orchestrators DO NOT DO (Spawn Agents Instead)

- **External research:** WebSearch/WebFetch → Spawn gco-research-analyst
- **Codebase investigation:** Multi-file analysis (>10 files) → Spawn gco-research-analyst
- **Requirements analysis:** JTBD, Kano, RICE → Spawn gco-project-manager
- **Implementation:** Write code, tests, configs → Spawn gco-dev-*
- **Code review:** Quality gates → Spawn gco-code-reviewer

**See also:** `references/delegation-protocol.md` for decision tree and success criteria

---

## Quick Start Guide

### New Project Workflow

```
1. User: /seance
2. Agent: "🕯️ A fresh haunting ground. What would you like to build?"
3. User: [Describes project idea]
4. Agent: Spawns gco-project-manager for full workflow
5. PM: Creates requirements-document.md, requirements-analysis.md, roadmap.md
6. Agent: [Random summoning prompt]
7. User: "yes"
8. Agent: Spawns dev agents for Batch 1
9. Agents: Implement features autonomously
10. Agent: Archives completed work automatically
```

### Existing Project Workflow (Add Feature)

```
1. User: /seance
2. Agent: Choice prompt [A] Add new or [B] Work roadmap
3. User: "A"
4. Agent: "What would you like to add?"
5. User: [Describes feature]
6. Agent: Spawns PM for incremental workflow
7. PM: Adds REQ-XXX to existing roadmap
8. Agent: [Random summoning prompt]
9. User: "yes"
10. Agent: Spawns dev agent for new requirement
```

### Existing Project Workflow (Work Roadmap)

```
1. User: /seance
2. Agent: Choice prompt [A] Add new or [B] Work roadmap
3. User: "B"
4. Agent: Shows unstarted requirements grouped by batch
5. User: "batch 3" or "REQ-042, REQ-043"
6. Agent: Spawns dev agents for selected items (no summoning prompt)
7. Agents: Implement features autonomously
8. Agent: Archives completed work automatically
```

### Explicit Scrying (Planning Only)

```
1. User: /seance --scry "Add OAuth login"
2. Agent: Spawns PM for planning
3. PM: Creates requirements, adds to roadmap
4. Agent: "✅ Roadmap created with 5 requirements"
5. Agent: "Ready to execute? Run /seance --summon"
```

### Explicit Summoning (Execution Only)

```
1. User: /seance --summon
2. Agent: Reads roadmap, finds unstarted items
3. Agent: Spawns dev agents for all unblocked items
4. Agents: Implement features autonomously
5. Agent: Archives completed work automatically
```

---

## Quality Checklist

Before completing the Seance:

**Mode Detection:**
- [ ] Mode detected correctly (1-6)
- [ ] `.haunt/` directory check performed
- [ ] Arguments presence checked
- [ ] Appropriate themed prompt displayed

**Delegation:**
- [ ] No WebSearch/WebFetch calls from orchestrator
- [ ] No implementation code written by orchestrator
- [ ] No multi-file analysis performed by orchestrator
- [ ] PM spawned for all planning phases
- [ ] Dev agents spawned for all implementation work

**Gates:**
- [ ] Delegation gate checked before each action
- [ ] Scrying gate verified before spawning dev agents
- [ ] REQ-XXX exists in roadmap before implementation
- [ ] User approved plan before summoning

**Gardening (if agents spawned):**
- [ ] Waited for all agents to complete
- [ ] Verified task checkboxes for 🟢 items
- [ ] Archived fully complete requirements
- [ ] Reported any verification issues
- [ ] Generated completion summary

---

## Error Handling

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

**If no roadmap exists for --summon:**
- "No roadmap found. Run `/seance --scry` first."

**If all requirements blocked:**
- List blocking dependencies
- Suggest which to resolve first

---

## Integration with PM Agent

The Seance skill is a **thin orchestration layer** that:
1. Detects context
2. Loads PM with appropriate mode
3. Adds themed prompts at the end
4. Optionally spawns workers

**The PM agent does all the real work** (requirements, analysis, roadmap creation).

---

## Skill References

This skill orchestrates these other skills:

- **gco-requirements-development** - Phase 1 of PM workflow
- **gco-requirements-analysis** - Phase 2 of PM workflow
- **gco-roadmap-creation** - Phase 3 of PM workflow
- **gco-project-manager** - Executes all three phases

The Seance doesn't duplicate their functionality - it just orchestrates them with themed prompts.

---

## See Also

- `references/delegation-protocol.md` - Anti-patterns, decision tree, success criteria
- `references/mode-workflows.md` - All 6 modes with step-by-step implementation
- `references/planning-depth.md` - Quick/Standard/Deep modifiers and Phase 2.5 critical review
- `references/example-flows.md` - Complete example conversations for all modes
- `references/themed-prompts.md` - Atmospheric prompt collections and 75/25 rule guidance
