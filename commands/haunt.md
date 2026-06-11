# /haunt - Project Initialization and Standards Layer

The `/haunt` command initializes Haunt in a repo and manages project-local coding standards. Standards are concise, scannable patterns that capture tribal knowledge unique to this codebase, indexed so they can be selectively loaded into agent context for the current task.

## Usage

```
/haunt                              Smart router: status if initialized, init if not
/haunt init                         Full setup: scaffold + interactive discovery
/haunt discover [area]              Add standards for a new area (skips scaffold)
/haunt inject                       Auto-suggest: surface 2-5 relevant standards
/haunt inject api/response-format   Explicit: load named standard
/haunt inject api                   Explicit: load all standards in a folder
/haunt status                       Inventory + index health check
```

## Before Starting

Read the `gco-haunt-orchestration` skill for the full orchestration logic of each subcommand. This file is a thin router — the procedure lives in the skill.

## What Gets Created

```
.haunt/standards/
├── index.yml                   # Map: {folder}/{name} → one-line description
├── api/
│   ├── response-format.md      # ≤30 lines, rule-led, code-exampled
│   └── error-handling.md
├── database/
│   └── migrations.md
└── react/
    └── form-validation.md
```

## Subcommands

### `/haunt` (smart router)

If `.haunt/standards/index.yml` exists with entries → run `status`.
Otherwise → run `init`.

### `/haunt init`

Interactive setup:
1. Idempotency check (continue / start fresh / cancel if existing setup found)
2. Scaffold `.haunt/standards/` and `.haunt/specs/`
3. Determine 3-5 focus areas based on repo structure
4. For chosen area: read representative files, surface 3-6 candidate patterns
5. For each selected pattern: ask why → draft → confirm → write (one at a time)
6. Update `.haunt/standards/index.yml`
7. Offer next area or exit

### `/haunt discover [area]`

Same as init Steps 3-6, but no scaffold and no idempotency clobber check. Adds to existing standards.

### `/haunt inject` (auto-suggest)

1. Read index
2. Detect scenario (conversation vs plan/spec)
3. Match index descriptions against current work signals
4. Present 2-5 candidates
5. Load by scenario:
   - **Conversation:** inline content
   - **Plan/spec:** `@path` references

### `/haunt inject {args}` (explicit)

Parse args (folder or folder/file), validate, load. On miss: "did you mean..." fallback.

### `/haunt status`

Print inventory by category, index health, last discovery date. Flag any drift (files without entries, entries without files).

## Key Files

| File | Purpose |
|------|---------|
| `.haunt/standards/index.yml` | Standards index (folder → file → one-line description) |
| `.haunt/standards/{cat}/{name}.md` | Individual standard file (≤30 lines) |
| `.haunt/specs/` | Per-seance spec folders (scaffolded here for /seance use) |
| `Skills/gco-haunt-orchestration/SKILL.md` | Full orchestration procedure |
| `Skills/gco-haunt-orchestration/references/example-standard.md` | Good vs bad standard format calibration |

## Relationship to Other Haunt Commands

- **`/seance`** uses `.haunt/specs/` (scaffolded here) for per-seance spec folders. Future enhancement: `/seance --scry` will auto-call `/haunt inject` to surface relevant standards.
- **Global `gco-*-standards` skills** (e.g., `gco-python-standards`, `gco-react-standards`) cover language/framework conventions. `/haunt`-managed standards cover **project-specific** patterns that those globals don't know about.

## When to Run

- **Once per new repo:** `/haunt init` captures conventions worth documenting.
- **When adding a new area:** `/haunt discover api` after building out a new domain.
- **At the start of a non-trivial task:** `/haunt inject` to surface relevant standards before implementation.
- **Periodically:** `/haunt status` to detect index drift if standards were edited manually.
