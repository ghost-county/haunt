---
name: gco-using-haunt
description: >-
  Haunt dispatcher: task-size triage and automatic seance entry for build requests. Routes XS/S work to lightweight solo handling and M/L work into the scrying-summoning-banishing ritual.
  Use when the user asks to build, add, fix, or change functionality, before writing any code.
last-verified: 2026-06-11
version: "1.0"
---

# Using Haunt

This skill is injected at session start. It decides when work enters the seance — Haunt's planning and execution ritual — without the user typing `/seance`.

## Instruction Priority

1. **User's explicit instructions** (CLAUDE.md, direct requests) — highest priority
2. **Haunt skills and rules**
3. **Default system behavior**

If the user says "just do it" or "skip the planning," respect that. The user is in control.

## The Gate

Before writing code, scaffolding a project, or editing files for ANY request to build, add, fix, or change functionality: **run triage first.** Do not start implementing and size the work afterward.

| Size | Signals | Route |
|------|---------|-------|
| XS | typo, rename, config tweak, single file, <30 min | Do it directly. Verify before reporting done. |
| S | small fix or feature, 1-3 files | Solo seance: state a brief plan + verifiable success criteria, implement, self-review, report. |
| M | feature, refactor, migration, 4-10 files | Announce "Starting a seance to plan this," invoke `haunt:gco-seance-orchestration`, begin Scrying. |
| L | new subsystem, multi-day, 10+ files | Same as M — full team, deep planning. |

When in doubt between S and M, prefer M — one planning round costs less than unplanned M-sized rework.

**On seance start (M/L):** run `mkdir -p .haunt && touch .haunt/active-session`. This sentinel activates Haunt's enforcement hooks (damage control, completion gate, phase enforcement). Banishing removes it.

**If `.haunt/active-session` already exists:** a seance is in progress. Read `.haunt/plans/roadmap.md` and the active spec folder before doing anything else — do not start parallel unplanned work.

## Do NOT Trigger On

- Pure questions, explanations, code reading, reviews — the deliverable is your assessment
- Work the user explicitly scoped outside the seance
- Subagent/teammate dispatch — if you were spawned with a specific task, execute it; triage is the lead's job

## Red Flags — You're Rationalizing

| Thought | Reality |
|---------|---------|
| "This is too simple to plan" | Run triage anyway — for XS, triage IS the plan. |
| "I'll just start and see how it goes" | Unsized work becomes unfinished M-work. Size first. |
| "The user seems in a hurry" | Triage takes one sentence. Skipping it costs rework. |
| "I already know the design" | Then state it as a plan, get a nod, and build. |
| "This is exploration, not building" | The moment you edit a project file, it's building. |
