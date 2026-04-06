# /seance - Complete Development Ritual

The seance is the complete idea-to-shipped workflow: planning, execution, and archival with zero manual coordination.

## Usage

```
/seance                       Interactive mode
/seance "idea description"    Direct mode with idea
/seance --scry                Planning only (alias: --plan)
/seance --summon              Execution only (alias: --execute)
/seance --banish              Archival only (alias: --archive)
/seance --solo "idea"         Solo mode (skip team, lead does everything — XS/S tasks)
/seance --quick "idea"        Quick planning (skip strategic analysis)
/seance --deep "idea"         Deep planning (full JTBD/Kano/RICE + adversarial review)
```

## Before Starting

Read the `gco-seance-orchestration` skill for detailed orchestration logic, delegation gates, and team management protocol.

## The Three Phases

### Phase 1: Scrying (Planning)
Transform a raw idea into a formal, actionable roadmap. Creates a Team, spawns PM, and produces requirements + roadmap. Ends with an approval gate before execution.

### Phase 2: Summoning (Execution)
Spawns Dev and Code Reviewer teammates to work through the roadmap in parallel batches. Tasks are created from REQ-XXX items with dependency tracking.

### Phase 3: Banishing (Archival)
Verifies completed work, archives to `.haunt/completed/`, cleans the roadmap, and shuts down the team.

See `gco-seance-orchestration` skill for detailed step-by-step orchestration logic for each phase.

## Interactive Mode

When invoked with no arguments:

```
The spirits await. What would you like to do?

[A] Scry the future (plan something new)
[B] Summon the spirits (execute the roadmap)
[C] Banish the completed (archive finished work)

Or tell me what you want to build...
```

## Key Files

| File | Purpose |
|------|---------|
| `.haunt/plans/roadmap.md` | Active roadmap (persistent) |
| `.haunt/plans/requirements-document.md` | Formal requirements |
| `.haunt/plans/requirements-analysis.md` | Strategic analysis |
| `.haunt/completed/` | Archived completed work |

## Recovery

If a seance is interrupted:
- The roadmap file persists with last-known status icons
- `/seance --summon` creates a fresh team and picks up incomplete items
- `/seance --banish` cleans up any completed but unarchived work
