---
last-verified: 2026-06-11
version: "1.1"
name: gco-seance-orchestration
description: >-
  Seance orchestration: delegation gates, team management, phase transitions (scrying/summoning/banishing), and task creation patterns.
  Use when planning or executing M/L-sized build work — invoked via /seance or automatically by the gco-using-haunt dispatcher when the user asks to build, add, or change functionality.
---

# Seance Orchestration

The lead agent's guide for running a seance -- the 3-phase development ritual.

## Sentinel Lifecycle

`.haunt/active-session` is the sentinel that activates Haunt's enforcement hooks (damage control, completion gate, phase enforcement, file location, observability, formatting). Outside a seance, those hooks are no-ops.

- **Seance start** (any phase entry, including solo mode and `--summon` recovery): `mkdir -p .haunt && touch .haunt/active-session`
- **Banishing complete**: `rm -f .haunt/active-session`

BECAUSE the hooks self-gate on this file — if it's never created, every guardrail silently no-ops; if it's never removed, Haunt interferes with non-seance work.

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
1. Touches the sentinel (`mkdir -p .haunt && touch .haunt/active-session`)
2. Plans inline (no PM spawn) — state verifiable success criteria
3. Implements directly (no Dev spawn)
4. Self-reviews against gco-code-review checklist
5. Commits, reports, removes the sentinel

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

1. **Activate the sentinel**: `mkdir -p .haunt && touch .haunt/active-session`
2. **Create team** via TeamCreate (team name: `seance-{YYYY-MM-DD}-{slug}`)
3. **Create spec folder** at `.haunt/specs/{YYYY-MM-DD}-{HHMM}-{slug}/` (HHMM disambiguates multi-seance days). This folder is the self-contained spec artifact for this seance.
4. **Spawn PM teammate** (gco-project-manager agent)
5. **Create planning task**: "Develop requirements for: {user's idea}"
   - Include depth flag (quick/medium/deep) in task description
   - **Include spec folder path** so PM writes per-spec outputs (`.haunt/specs/{slug}/requirements.md`, `analysis.md`, `plan.md`)
6. **Wait for PM** to complete requirements -> analysis -> per-spec plan. The plan must open with the execution header (see Plan Header below) and contain no placeholders.
7. **If deep mode**: PM will create a review task; spawn Research teammate if not already present
8. **Update roadmap index** at `.haunt/plans/roadmap.md`: add a row pointing at the spec folder with status 🔴 planned. The roadmap is a cross-spec index, not the per-spec requirements doc.
9. **Present spec to user** with summary of REQ items, batches, and estimates (read from `.haunt/specs/{slug}/plan.md`)
10. **Ask user**: "Ready to summon?" -- this is the approval gate
11. **Log approval** when user approves: append to `.haunt/logs/approvals.jsonl`:
    `{"timestamp":"<UTC>","event":"plan_approved","phase":"scrying","context":"Spec {slug} approved with N requirements"}`

### Plan Header

Every `plan.md` must start with this header so a fresh session opening the file knows how to execute it without any other context:

```markdown
# {Idea} — Spec Plan

> **For agentic workers:** Execute via the Summoning phase of `haunt:gco-seance-orchestration`.
> Create one Team task per REQ-XXX item with dependencies from the "Blocked by" fields below.
```

## Phase 2: Summoning (Execution)

1. **Read spec plan** from `.haunt/specs/{slug}/plan.md` (per-spec REQ items + dependencies). The roadmap (`.haunt/plans/roadmap.md`) is the cross-spec index — it tells you which spec is active, but the REQ details live in the spec folder.
2. **Create tasks** for each REQ-XXX item:
   - Task title: `REQ-XXX: {title}`
   - Task description: acceptance criteria + files + effort from spec plan
   - Set dependencies: `addBlockedBy` for items with "Blocked by" in spec plan
   - Before dispatching each task, write a checkpoint: `echo $(date -u) > .haunt/progress/{REQ}-started.txt`
   - After verifying a task is complete, write: `echo $(date -u) > .haunt/progress/{REQ}-verified.txt`
3. **Spawn Dev teammates** (one per parallel batch, or one for sequential work)
4. **Spawn Code Reviewer** if any M-sized items exist
5. **Monitor via TaskList** -- check periodically for:
   - Completed tasks (dependencies may now unblock)
   - Blocked tasks needing intervention
   - All tasks complete (transition to Banishing)
6. **Report progress** to user at batch boundaries

**Continuous execution:** Do not pause to check in with the user between tasks or batches. Execute the full plan without stopping. The only reasons to stop are: a blocked task you cannot resolve, ambiguity that genuinely prevents progress, the pre-merge human gate, or all tasks complete. "Should I continue?" prompts waste the user's time — they approved the plan, so execute it.

## Phase 3: Banishing (Archival)

1. **Verify completion** for each completed REQ-XXX:
   - All task checkboxes marked in spec plan (`.haunt/specs/{slug}/plan.md`)
   - Completion criteria met
   - Tests passing (check with Dev if unclear)
2. **Codify lessons** -- If the seance surfaced a reusable lesson (recurring mistake, surprising pattern, project-specific rule), add it to the project's Institutional Memory section in `.claude/CLAUDE.md` using the template from `~/.claude/templates/institutional-memory.md`
3. **Update spec plan** -- set status icons to 🟢 for completed items in `.haunt/specs/{slug}/plan.md`
4. **Archive spec folder** -- `mv .haunt/specs/{slug}/ .haunt/completed/{slug}/` (atomic — whole artifact moves together with requirements, analysis, references, visuals)
5. **Update roadmap index** -- move the spec row from "Active" to "Completed" section in `.haunt/plans/roadmap.md`, mark 🟢, update path to `.haunt/completed/{slug}/`
6. **Shutdown team** via shutdown protocol
7. **Deactivate the sentinel** -- `rm -f .haunt/active-session` (only if no other spec remains active in the roadmap)
8. **Report to user** -- completion summary with what shipped, with a link to `.haunt/completed/{slug}/`

## Dual-Track Task Management

Two systems track work for different purposes:

| System | Purpose | Lifetime | Authority |
|--------|---------|----------|-----------|
| Spec folder (`.haunt/specs/{slug}/`) | Per-spec requirements, analysis, plan, references, visuals | Survives until banishing → `.haunt/completed/{slug}/` | PM creates per spec, lead orchestrates |
| Roadmap index (`.haunt/plans/roadmap.md`) | Cross-spec index: active/completed specs with status icons | Persistent across all seances | Lead maintains |
| Teams task list | Live execution tracking | Ephemeral per team | Lead creates from spec plan |

**Workflow:**
- Scrying: PM creates spec folder contents (`requirements.md`, `analysis.md`, `plan.md`); lead adds spec row to roadmap index
- Summoning: Lead creates Team tasks FROM the spec plan
- During execution: Task status lives in Team task list
- Banishing: Lead moves spec folder to `.haunt/completed/`, updates roadmap index row

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
5. **Log gate decision** — append to `.haunt/logs/approvals.jsonl`:
   `{"timestamp":"<UTC>","event":"gate_approved|gate_rejected|gate_deferred","phase":"summoning","context":"<brief reason>"}`

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
- Roadmap index (`.haunt/plans/roadmap.md`) — points at active/completed spec folders
- Active spec folder (`.haunt/specs/{slug}/`) — full spec artifact persists on disk
- Team task list — managed by Claude Code, external to conversation context
- State files (`.haunt/state/`) — filesystem-based
- Session log (`.haunt/session-history.log`) — append-only
- Review verdicts (`.haunt/logs/`) — persistent logs

### What to Reload After /clear
1. Read roadmap index for active spec(s)
2. Read active spec's `plan.md` for REQ status
3. Check TaskList for pending work
4. Read any handoff notes from `.haunt/state/continue-here.md`

### Instruction to User
Between phases, tell the user: "Phase complete. I recommend starting a fresh session to keep context clean. The roadmap and task state persist on disk — the next session picks up where we left off."

## Recovery

If a seance is interrupted (session lost, teammate crash):
- The roadmap index + active spec folder persist with last-known status
- `/seance --summon` re-touches the sentinel (`touch .haunt/active-session`), reads the active spec from the roadmap, re-reads `.haunt/specs/{slug}/plan.md`, creates a fresh team and re-creates tasks for incomplete items
- Status icons in the spec plan serve as recovery checkpoint
- Started-but-not-verified tasks are flagged on session start — review before re-executing

### Staleness Protocol

On resume, the session-start hook checks for git activity since the spec plan was written:
- **If changes detected**: review the git log, decide whether to proceed, re-plan, or abort
- **If no changes**: proceed normally
