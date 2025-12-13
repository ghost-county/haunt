# File Location Conventions

## Ghost County Artifact Locations

All Ghost County artifacts MUST be placed in the correct directories under `.haunt/`:

| Artifact Type | Location | Purpose |
|---------------|----------|---------|
| Active roadmap | `.haunt/plans/roadmap.md` | Current work items and active requirements |
| Requirements docs | `.haunt/plans/*.md` | Feature specifications, analysis documents |
| Completed work | `.haunt/completed/` | Archived requirements and implementation summaries |
| Progress reports | `.haunt/progress/` | Session notes, verification reports |
| Pattern tests | `.haunt/tests/patterns/` | Defeat tests for anti-patterns |
| Behavior tests | `.haunt/tests/behavior/` | Agent behavior validation tests |
| E2E tests | `.haunt/tests/e2e/` | End-to-end integration tests |
| Research docs | `.haunt/docs/research/` | Investigation findings, technical analysis |
| Validation docs | `.haunt/docs/validation/` | Review reports, audit results |
| Project init | `.haunt/docs/INITIALIZATION.md` | Project initialization guide |

## Prohibitions

**NEVER create Ghost County artifacts outside `.haunt/`:**

- NEVER put implementation summaries in source directories (`src/`, `scripts/`, `Haunt/scripts/`, etc.)
- NEVER store roadmap files outside `.haunt/plans/`
- NEVER put progress reports in project root or source directories
- NEVER store pattern defeat tests outside `.haunt/tests/patterns/`
- NEVER mix Ghost County artifacts with source code

## Project Files (Not Ghost County Artifacts)

These stay in their standard project locations:

| File Type | Location | Examples |
|-----------|----------|----------|
| Source code | Project-specific directories | `src/`, `lib/`, `Haunt/scripts/` |
| Project tests | Project test directories | `tests/`, `__tests__/`, `.haunt/tests/patterns/` |
| Project docs | Project documentation | `README.md`, `docs/`, `Haunt/README.md` |
| Configuration | Project root | `.gitignore`, `package.json`, `.pre-commit-config.yaml` |
| Agent definitions | `.claude/agents/` | Agent character sheets |
| Skills | `.claude/skills/` or `Haunt/skills/` | Methodology skills |
| Rules | `.claude/rules/` | Invariant enforcement rules |
| Framework docs | `Haunt/docs/` | Detailed framework documentation (WHITE-PAPER.md, SDK-INTEGRATION.md, etc.) |

## Haunt Framework Documentation Structure

The Haunt framework has a specific documentation structure:

**Root-level (user-facing essentials):**
- `Haunt/README.md` - Architecture overview
- `Haunt/SETUP-GUIDE.md` - Setup instructions
- `Haunt/QUICK-REFERENCE.md` - Quick reference card

**Haunt/docs/ (detailed documentation):**
- `Haunt/docs/WHITE-PAPER.md` - Framework design philosophy
- `Haunt/docs/SDK-INTEGRATION.md` - SDK integration details
- `Haunt/docs/TOOL-PERMISSIONS.md` - Agent tool access reference
- `Haunt/docs/SKILLS-REFERENCE.md` - Complete skills catalog
- `Haunt/docs/PATTERN-DETECTION.md` - Pattern detection methodology
- `Haunt/docs/HAUNT-DIRECTORY-SPEC.md` - Directory structure specification

**Rule:** User-facing documentation stays at Haunt root, detailed/reference documentation goes in Haunt/docs/

## Special Cases

### Implementation Summaries
**Always:** `.haunt/completed/REQ-XXX-implementation-summary.md`
**Never:** `Haunt/scripts/REQ-XXX-IMPLEMENTATION.md` (wrong location)

### Roadmap Archives
**Always:** `.haunt/completed/roadmap-archive.md`
**Never:** `roadmap-archive.md` in project root

### Pattern Defeat Tests
**Always:** `.haunt/tests/patterns/test_*.py`
**Never:** `tests/patterns/` (unless project has separate test suite)

## File Size Limits

Plan files in `.haunt/plans/` MUST stay under **1000 lines** to remain readable:

| File | Max Lines | Action When Exceeded |
|------|-----------|---------------------|
| `roadmap.md` | 500 | Archive all completed items immediately |
| `requirements-*.md` | 800 | Split by feature area or archive |
| `*-analysis.md` | 600 | Summarize and archive details to `.haunt/completed/` |

**Session startup check:** If any plan file exceeds 1000 lines, archive before starting work.

## Directory Creation

These directories should exist after running setup script:

```
.haunt/
├── plans/           # Active planning documents
├── completed/       # Archived work and implementation summaries
├── progress/        # Session progress tracking
├── tests/           # Ghost County-related tests
│   ├── patterns/    # Pattern defeat tests
│   ├── behavior/    # Agent behavior tests
│   └── e2e/         # End-to-end tests
└── docs/            # Ghost County documentation
    ├── research/    # Investigation findings
    └── validation/  # Review reports
```

If any are missing, create them before storing artifacts.
