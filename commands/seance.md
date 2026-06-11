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

The seance also starts **automatically**: the `gco-using-haunt` dispatcher (injected at session start) triages any build request and invokes this workflow for M/L-sized work without the command being typed. `/seance` remains the explicit entry point.

## Before Starting

Read the `gco-seance-orchestration` skill for detailed orchestration logic, delegation gates, and team management protocol.

## The Three Phases

### Phase 1: Scrying (Planning)
Transform a raw idea into a self-contained spec artifact at `.haunt/specs/{YYYY-MM-DD}-{HHMM}-{slug}/`. Creates a Team, spawns PM, and produces per-spec requirements + analysis + plan. Adds a row to the cross-spec roadmap index. Ends with an approval gate before execution.

### Phase 2: Summoning (Execution)
Reads the active spec's plan, spawns Dev and Code Reviewer teammates to work through REQ items in parallel batches. Tasks are created with dependency tracking.

### Phase 3: Banishing (Archival)
Verifies completed work, atomically moves `.haunt/specs/{slug}/` to `.haunt/completed/{slug}/`, updates the roadmap index row, and shuts down the team.

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
| `.haunt/active-session` | Sentinel — created at seance start, removed at banishing; activates all enforcement hooks |
| `.haunt/plans/roadmap.md` | Cross-spec index (active + completed specs with status icons) |
| `.haunt/specs/{slug}/plan.md` | Per-spec REQ items + dependencies |
| `.haunt/specs/{slug}/requirements.md` | Per-spec formal requirements |
| `.haunt/specs/{slug}/analysis.md` | Per-spec strategic analysis (medium/deep mode only) |
| `.haunt/specs/{slug}/references.md` | Pointers to reference implementations |
| `.haunt/specs/{slug}/visuals/` | Mockups, screenshots |
| `.haunt/completed/{slug}/` | Archived completed spec folder (whole artifact) |

Slug format: `{YYYY-MM-DD}-{HHMM}-{idea-slug}` — HHMM disambiguates multi-seance days.

## Recovery

If a seance is interrupted:
- The roadmap index + active spec folder persist with last-known status icons
- `/seance --summon` reads the active spec from the roadmap, re-reads `.haunt/specs/{slug}/plan.md`, creates a fresh team and picks up incomplete items
- `/seance --banish` cleans up any completed but unarchived work
