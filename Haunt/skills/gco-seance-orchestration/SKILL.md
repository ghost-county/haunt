---
last-verified: 2026-04-03
name: gco-seance-orchestration
description: Orchestration logic for the seance command. Defines delegation gates, team management, phase transitions, and task creation patterns.
---

# Seance Orchestration

The lead agent's guide for running a seance -- the 3-phase development ritual.

## Delegation Gate

Before ANY action, check: **Am I about to do specialized work?**

| If you're about to... | STOP. Delegate to... |
|----------------------|---------------------|
| Analyze requirements (JTBD/Kano/RICE) | PM teammate |
| Write code or tests | Dev teammate |
| Research a topic or investigate | Research teammate |
| Review code quality | Code Reviewer teammate |
| Use WebSearch/WebFetch | Research teammate |

**The lead READS, COORDINATES, and COMMUNICATES with the user. It does NOT implement.**

## Task Size Cascade

Before spawning a team, estimate task size. BECAUSE a 4-agent team for a 10-line config change wastes ~50K tokens on coordination overhead alone (DeepMind 2025: coordination costs grow superlinearly with team size).

| Size | Criteria | Agent Strategy |
|------|----------|---------------|
| XS | Single file, <30 min | **Solo:** lead does it directly (no team) |
| S | 1-3 files, <2 hrs | **Solo:** spawn single Dev agent |
| M | 4-10 files, half-day | **Team:** Dev + Code Reviewer |
| L | 10+ files, multi-day | **Full Team:** PM + Dev(s) + Code Reviewer |

### Solo Mode (`/seance --solo`)
Skip team creation entirely. The lead:
1. Plans inline (no PM spawn)
2. Implements directly (no Dev spawn)
3. Self-reviews against gco-code-review checklist
4. Commits and reports

### Size Detection Heuristic
Read the idea description. If it mentions:
- "config", "env", "typo", "rename", "bump", "fix text" → likely **XS**
- "add field", "fix bug", "update component", "small feature" → likely **S**
- "new feature", "refactor", "migration", "new endpoint" → likely **M+**

When in doubt, start solo. Escalate to team if scope expands.

## Team Management

### Creating a Team
```
TeamCreate: seance-{YYYY-MM-DD}-{slug}
```
Slug derived from the idea: "Add OAuth login" -> `seance-2026-03-30-oauth-login`

### Spawning Teammates
Spawn teammates based on phase needs:

| Phase | Teammates |
|-------|-----------|
| Scrying (quick) | PM only |
| Scrying (medium) | PM |
| Scrying (deep) | PM + Research |
| Summoning (M) | Dev + Code Reviewer (routes to specialists for M+ work) |
| Summoning (L) | Dev(s) + Code Reviewer + specialists as needed |

### Shutdown Protocol
1. Wait for all tasks to reach `completed` or `blocked`
2. SendMessage shutdown request to all teammates
3. Wait for confirmations
4. TeamDelete to clean up

## Phase 1: Scrying (Planning)

1. **Create team** via TeamCreate
2. **Spawn PM teammate** (gco-project-manager agent)
3. **Create planning task**: "Develop requirements for: {user's idea}"
   - Include depth flag (quick/medium/deep) in task description
4. **Wait for PM** to complete requirements -> analysis -> roadmap
5. **If deep mode**: PM will create a review task; spawn Research teammate if not already present
6. **Read roadmap** from `.haunt/plans/roadmap.md` when PM reports completion
7. **Present roadmap to user** with summary of REQ items, batches, and estimates
8. **Ask user**: "Ready to summon?" -- this is the approval gate

## Phase 2: Summoning (Execution)

1. **Read roadmap** from `.haunt/plans/roadmap.md`
2. **Create tasks** for each REQ-XXX item:
   - Task title: `REQ-XXX: {title}`
   - Task description: acceptance criteria + files + effort from roadmap
   - Set dependencies: `addBlockedBy` for items with "Blocked by" in roadmap
3. **Spawn Dev teammates** (one per parallel batch, or one for sequential work)
4. **Spawn Code Reviewer** if any M-sized items exist
5. **Monitor via TaskList** -- check periodically for:
   - Completed tasks (dependencies may now unblock)
   - Blocked tasks needing intervention
   - All tasks complete (transition to Banishing)
6. **Report progress** to user at batch boundaries

## Phase 3: Banishing (Archival)

1. **Verify completion** for each completed REQ-XXX:
   - All task checkboxes marked in roadmap
   - Completion criteria met
   - Tests passing (check with Dev if unclear)
2. **Codify lessons** -- If the seance surfaced a reusable lesson (recurring mistake, surprising pattern, project-specific rule), add it to the project's Institutional Memory section in `.claude/CLAUDE.md` using the template from `~/.claude/templates/institutional-memory.md`
3. **Update roadmap** -- set status icons to 🟢 for completed items
4. **Archive** completed requirements to `.haunt/completed/`
5. **Clean roadmap** -- remove archived items
6. **Shutdown team** via shutdown protocol
7. **Report to user** -- completion summary with what shipped

## Dual-Track Task Management

Two systems track work for different purposes:

| System | Purpose | Lifetime | Authority |
|--------|---------|----------|-----------|
| Roadmap file (`.haunt/plans/roadmap.md`) | Requirements, criteria, persistent record | Survives sessions | PM creates, lead archives |
| Teams task list | Live execution tracking | Ephemeral per team | Lead creates from roadmap |

**Workflow:**
- Scrying: PM creates/updates roadmap
- Summoning: Lead creates Team tasks FROM roadmap items
- During execution: Task status lives in Team task list
- Banishing: Lead syncs final status BACK to roadmap, then archives

## Pre-Merge Human Gate

BECAUSE M-sized work involves 4-10 files and warrants human oversight before integration. LLM reviewers share generator biases (MAST FM-3.1 Rubber-Stamp, FM-3.4 Groupthink) — human judgment provides genuinely orthogonal review.

### When to Trigger
- Any **M or L** sized work (per Task Size Cascade)
- Any work touching **auth, payments, or production config**
- Any work where Code Reviewer issued **CHANGES_REQUESTED** (even after fixes)

### Gate Protocol
1. Collect all review verdicts from `.haunt/logs/review-verdicts.jsonl`
2. Generate structured gate output using template from `~/.claude/templates/human-gate-output.md`
3. Present to user: "This work is ready for your review before I proceed to archival."
4. Wait for user decision:
   - **APPROVE** → proceed to Banishing
   - **REJECT** → create fix tasks, return to Summoning
   - **DEFER** → save state to `.haunt/state/continue-here.md`, suggest /clear

### Skip Conditions
- XS/S work: skip gate (single-agent, low risk)
- Clean re-review: skip if all verdicts now APPROVED after fix cycle AND work does not touch auth/payments/production config

## Session Boundaries

BECAUSE context accumulates across phases and mid-context information suffers 30%+ accuracy drops (Liu et al. 2024). Fresh sessions with plan files outperform 50-message accumulated sessions.

### When to Clear
- **After Scrying completes** and user approves the roadmap → recommend /clear before Summoning
- **After each batch of tasks** completes in Summoning → /clear if conversation is long (>30 messages)
- **Before Banishing** → /clear to start archival with clean context

### What Survives /clear
- Roadmap file (`.haunt/plans/roadmap.md`) — persistent on disk
- Team task list — managed by Claude Code, external to conversation context
- State files (`.haunt/state/`) — filesystem-based
- Session log (`.haunt/session-history.log`) — append-only
- Review verdicts (`.haunt/logs/`) — persistent logs

### What to Reload After /clear
1. Read roadmap for current status
2. Check TaskList for pending work
3. Read any handoff notes from `.haunt/state/continue-here.md`

### Instruction to User
Between phases, tell the user: "Phase complete. I recommend starting a fresh session to keep context clean. The roadmap and task state persist on disk — the next session picks up where we left off."

## Recovery

If a seance is interrupted (session lost, teammate crash):
- The roadmap file persists with last-known status
- `/seance --summon` creates a fresh team and re-creates tasks for incomplete items
- Status icons in roadmap serve as recovery checkpoint
