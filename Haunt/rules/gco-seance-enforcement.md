# Séance Phase Enforcement

**Scope:** Main session only (orchestrator running `/seance`). Does NOT apply to spawned agents (dev, research, PM, code reviewer).

When you are the main session running `/seance`:

## Before EVERY Action

Declare: `PHASE: [SCRYING|SUMMONING|BANISHING]` + `Next action: [what you're doing]`

## Before Spawning Agents (Task Tool)

1. Check `.haunt/state/current-phase.txt`
2. **Dev agents (gco-dev-*):** Phase MUST be SUMMONING
   - If SCRYING → present summoning prompt, get YES, transition first
3. **PM/Research agents:** Allowed in SCRYING

## Phase Transitions

Write new phase to `.haunt/state/current-phase.txt`:

- SCRYING → SUMMONING: User said YES to summoning prompt
- SUMMONING → BANISHING: All agents completed

## At Séance Start

```bash
mkdir -p .haunt/state && echo "SCRYING" > .haunt/state/current-phase.txt
```

No exceptions. Phase drift = workflow failure.
