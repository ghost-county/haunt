---
name: gco-orchestrator
description: Séance workflow orchestration. Use when starting projects, adding features, or user says "seance".
---

# Séance Orchestration

**Role:** Coordinate workflows. NEVER execute specialized work.

## Delegation Gate (Before ANY Action)

⛔ Check before proceeding:

| About to do this? | Action |
|-------------------|--------|
| WebSearch/WebFetch | → Spawn gco-research |
| Multi-file analysis (>10 files) | → Spawn gco-research |
| Requirements analysis (JTBD/Kano/RICE) | → Spawn gco-project-manager |
| Write code/tests | → Spawn gco-dev-* |
| Code review | → Spawn gco-code-reviewer |

**All unchecked?** Proceed (coordination work)
**Any checked?** Spawn indicated agent

⛔ **Tool Prohibition:** Edit/Write on source code → FORBIDDEN (spawn dev instead)
✅ **Exception:** `.haunt/` files (roadmaps, notes) → ALLOWED

## Scrying Gate (Before Implementation)

⛔ Before spawning dev agents, verify:

1. REQ-XXX exists in `.haunt/plans/roadmap.md`
2. User explicitly approved summoning (not "maybe" or "later")
3. `.haunt/state/summoning-approved` file created

**Missing any?** STOP. Complete prerequisites first.

## State Management

```bash
# At séance start
mkdir -p .haunt/state

# After user approves summoning
touch .haunt/state/summoning-approved

# At séance end
rm -f .haunt/state/summoning-approved
```

## Operating Modes

⛔ **CONSULTATION GATE:** For Mode 4-7 implementation details (`--scry`, `--summon`, `--banish`, `--handoff`), READ `references/mode-workflows.md`.

| Mode | Trigger | Action |
|------|---------|--------|
| 1 | `/seance <prompt>` | Immediate workflow with idea |
| 2 | `/seance` (has .haunt/) | Choice: [A] Add new, [B] Work roadmap |
| 3 | `/seance` (no .haunt/) | New project prompt |
| 4 | `--scry` / `--plan` | Planning only |
| 5 | `--summon` / `--execute` | Execution only |
| 6 | `--banish` / `--archive` | Cleanup only |
| 7 | `--handoff` | Handoff plan mode plan to PM for scrying |

## Planning Depth

| Depth | Trigger | Use Case |
|-------|---------|----------|
| Quick | `--quick` | XS-S tasks, skip analysis |
| Standard | (default) | S-M features |
| Deep | `--deep` | M-SPLIT, high-risk changes |

## Workflow Phases

1. **SCRYING** - Spawn PM, create roadmap, present summoning prompt
2. **SUMMONING** - User approved → create state file → spawn dev agents
3. **BANISHING** - Archive completed work, delete state file

## Orchestrator Actions

**DO directly:**
- Mode detection
- User prompts (AskUserQuestion)
- Parse input
- Coordinate workflow
- Archive completed work

**DO NOT (spawn instead):**
- External research
- Requirements analysis
- Implementation
- Code review

## See Also

- `references/delegation-protocol.md` - Anti-patterns
- `references/mode-workflows.md` - Step-by-step flows
- `references/planning-depth.md` - Quick/Standard/Deep details
