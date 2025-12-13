# .haunt Directory Structure Specification

**Version:** 1.0
**Status:** Draft
**Created:** 2025-12-10
**Purpose:** Define canonical structure for consolidated Ghost County project artifacts

---

## Executive Summary

This specification defines the `.haunt/` directory structure that consolidates all Ghost County framework artifacts into a single, gitignored location. This separates framework working files from project source code, providing cleaner repository organization.

**Key Benefits:**
- Single location for all Ghost County artifacts
- Cleaner project root (no scattered directories)
- Gitignored by default (framework artifacts don't pollute version control)
- Clear separation of concerns (framework vs. project code)
- Backward compatible migration path

---

## Directory Tree

```
.haunt/
├── plans/
│   ├── roadmap.md
│   └── feature-contract.json
├── progress/
│   ├── README.md
│   └── session-YYYY-MM-DD.md
├── completed/
│   ├── roadmap-archive.md
│   └── batch-N-name-YYYY-MM-DD.md
├── tests/
│   ├── patterns/
│   │   ├── README.md
│   │   └── test_*.py
│   ├── behavior/
│   │   ├── README.md
│   │   └── test_*.py
│   └── e2e/
│       ├── README.md
│       └── *.spec.js
├── docs/
│   └── INITIALIZATION.md
├── scripts/
│   ├── morning-review.sh
│   ├── evening-handoff.sh
│   └── weekly-refactor.sh
└── .gitignore
```

---

## Path Mapping Table

| Old Path | New Path | File Type | Notes |
|----------|----------|-----------|-------|
| `plans/roadmap.md` | `.haunt/plans/roadmap.md` | Work tracking | Active requirements |
| `plans/feature-contract.json` | `.haunt/plans/feature-contract.json` | Feature contracts | Immutable acceptance criteria |
| `progress/README.md` | `.haunt/progress/README.md` | Documentation | Progress templates |
| `progress/*.md` | `.haunt/progress/*.md` | Session notes | Daily progress reports |
| `completed/roadmap-archive.md` | `.haunt/completed/roadmap-archive.md` | Archive | Completed requirements |
| `completed/batch-*.md` | `.haunt/completed/batch-*.md` | Archive | Batch completion records |
| `tests/patterns/` | `.haunt/tests/patterns/` | Defeat tests | Pattern detection tests |
| `tests/behavior/` | `.haunt/tests/behavior/` | Behavior tests | Agent behavior verification |
| `tests/e2e/` | `.haunt/tests/e2e/` | E2E tests | Complete workflow tests |
| `INITIALIZATION.md` | `.haunt/docs/INITIALIZATION.md` | Documentation | Project initialization record |
| N/A (new) | `.haunt/scripts/morning-review.sh` | Ritual script | Daily startup ritual |
| N/A (new) | `.haunt/scripts/evening-handoff.sh` | Ritual script | Daily shutdown ritual |
| N/A (new) | `.haunt/scripts/weekly-refactor.sh` | Ritual script | Weekly pattern hunt |
| N/A (new) | `.haunt/.gitignore` | Config | Selective ignoring within .haunt/ |

---

## Directory Specifications

### `.haunt/plans/`

**Purpose:** Active work planning and feature contracts

**Contents:**
- `roadmap.md` - Single source of truth for all active work
- `feature-contract.json` - Immutable feature requirements with acceptance criteria
- `*.md` (optional) - Additional planning documents (architecture decision records, etc.)

**Rationale:** Plans are ephemeral working documents that change frequently. They shouldn't clutter version control history.

**Gitignore:** Entire directory ignored (plans are local to each agent's session)

---

### `.haunt/progress/`

**Purpose:** Session progress reports and verification results

**Contents:**
- `README.md` - Templates for session reports
- `session-YYYY-MM-DD.md` - Daily session summaries
- `req-NNN-completion.md` - Individual requirement completion reports
- `setup-verification-*.md` - Setup script verification results
- `batch-N-completion-*.md` - Batch completion summaries

**Rationale:** Progress files are historical records useful for learning but not for collaboration. They're agent-specific.

**Gitignore:** Entire directory ignored (progress is local context)

---

### `.haunt/completed/`

**Purpose:** Archive of completed requirements

**Contents:**
- `roadmap-archive.md` - Ongoing archive of completed requirements
- `batch-N-name-YYYY-MM-DD.md` - Batch-specific completion records
- `REQ-NNN-*.md` - Individual requirement archives with completion notes

**Rationale:** Completed work provides learning material for future sessions but isn't part of the project deliverable.

**Gitignore:** Entire directory ignored (archives are reference material, not deliverables)

---

### `.haunt/tests/`

**Purpose:** Framework-level tests (patterns, behavior, e2e)

**Subdirectories:**

#### `.haunt/tests/patterns/`
- **Purpose:** Pattern defeat tests (TDD for anti-patterns)
- **Contents:** `test_*.py` - Python tests that detect specific anti-patterns
- **Format:** pytest-compatible tests with docstring metadata
- **Rationale:** Pattern tests are specific to your agent team's learnings

#### `.haunt/tests/behavior/`
- **Purpose:** Agent behavior verification tests
- **Contents:** `test_*.py` - Tests that verify agents follow their character sheets
- **Format:** pytest-compatible behavioral tests
- **Rationale:** Behavior tests validate agent training, not application features

#### `.haunt/tests/e2e/`
- **Purpose:** End-to-end workflow tests
- **Contents:** `*.spec.js` - Playwright/Cypress tests for complete workflows
- **Format:** Framework-specific test files
- **Rationale:** E2E tests verify agent coordination, not just application behavior

**Gitignore:** `.haunt/tests/` is **NOT** ignored by default. Pattern tests should optionally be committed if team wants to share learnings. Use selective ignoring.

---

### `.haunt/docs/`

**Purpose:** Project initialization and framework documentation

**Contents:**
- `INITIALIZATION.md` - Record of project setup
- `PROJECT-NOTES.md` (optional) - Ongoing project-specific notes
- `LESSONS-LEARNED.md` (optional) - Team retrospective notes

**Rationale:** Project-level documentation that's specific to the Ghost County framework, not the project deliverable.

**Gitignore:** Entire directory ignored (initialization is point-in-time, not evolving documentation)

---

### `.haunt/scripts/`

**Purpose:** Daily and weekly ritual scripts

**Contents:**
- `morning-review.sh` - Daily startup ritual (git status, roadmap review, test check)
- `evening-handoff.sh` - Daily shutdown ritual (session summary, memory save)
- `weekly-refactor.sh` - Weekly pattern hunt automation
- `hunt-patterns` (symlink) - Shortcut to pattern detection CLI

**Rationale:** Ritual scripts are project-specific instantiations of framework patterns.

**Gitignore:** Scripts are **NOT** ignored. These can be committed if team wants consistent rituals.

---

### `.haunt/.gitignore`

**Purpose:** Selective ignoring within .haunt/ directory

**Contents:**

```gitignore
# Ignore working files (ephemeral)
plans/
progress/
completed/
docs/

# Preserve tests (optionally shareable)
!tests/

# Preserve scripts (team rituals)
!scripts/

# Ignore verification reports
*verification*.md

# Ignore session reports
session-*.md

# But preserve templates
!README.md
```

**Rationale:** Most .haunt/ content is local working files, but tests and scripts may be valuable to commit.

---

## What Goes Where?

### `.haunt/plans/` - Active Work
- Roadmap with current requirements
- Feature contracts with acceptance criteria
- Planning documents in flux

### `.haunt/progress/` - Session Records
- What happened today
- Verification results
- Completion summaries

### `.haunt/completed/` - Historical Archive
- Completed requirements
- Batch completion records
- Learnings from finished work

### `.haunt/tests/` - Framework Tests
- Pattern defeat tests (anti-pattern detection)
- Behavior tests (agent discipline verification)
- E2E tests (workflow coordination)

### `.haunt/docs/` - Project Meta
- Initialization record
- Project-specific framework notes
- Not application documentation (that goes in `docs/` at root)

### `.haunt/scripts/` - Rituals
- Daily startup/shutdown scripts
- Weekly refactor automation
- Project-specific automation

---

## Files NOT in .haunt/

These remain at project root or in their current locations:

| Path | Reason |
|------|--------|
| `.claude/agents/` | Project-specific agent overrides (part of project config) |
| `.claude/settings.json` | Claude Code configuration (not Ghost County-specific) |
| `Skills/` | Reusable skills library (shared across projects) |
| `Haunt/skills/` | Ghost County-specific skills (roadmap-workflow, feature-contracts, etc.) |
| `Haunt/` | Framework definitions and global agents (templates) |
| `Agentic_SDLC_Framework/` | Old framework (for comparison/migration) |
| `Knowledge/` | Educational curriculum (deliverable content) |
| `CLAUDE.md` | Project-level Claude Code instructions (config) |
| `.gitignore` | Project-level git ignore (covers .haunt/) |

---

## Backward Compatibility Strategy

### Phase 1: Dual-Path Support
- Skills, agents, and scripts support both old and new paths
- Check `.haunt/plans/roadmap.md` first, fall back to `plans/roadmap.md`
- Update references gradually over 2-3 releases

### Phase 2: Migration Tooling
- `migrate-to-sdlc-dir.sh` moves existing projects
- Preserves git history with `git mv` where possible
- Creates backup before migration
- Rollback capability if needed

### Phase 3: Old Path Deprecation
- Warn when old paths detected
- Update all documentation to new paths
- Remove fallback logic after 2 releases

### Migration Script Interface

```bash
# Dry-run to preview changes
bash scripts/migrate-to-sdlc-dir.sh --dry-run

# Perform migration
bash scripts/migrate-to-sdlc-dir.sh

# Rollback if needed
bash scripts/migrate-to-sdlc-dir.sh --rollback
```

---

## Project Root .gitignore Entry

Add this to project root `.gitignore`:

```gitignore
# Ghost County working files (ephemeral)
.haunt/plans/
.haunt/progress/
.haunt/completed/
.haunt/docs/

# Preserve SDLC tests and scripts (optionally shareable)
!.haunt/tests/
!.haunt/scripts/
!.haunt/README.md
```

---

## Implementation Checklist

### Stage 1: Definition (REQ-080)
- [x] Create this specification document
- [ ] Review with stakeholders
- [ ] Approve directory structure

### Stage 2: Update Tools (REQ-081-085)
- [ ] Update setup script to create `.haunt/` structure
- [ ] Update validation scripts for `.haunt/` paths
- [ ] Update skills to reference `.haunt/` paths
- [ ] Update agent definitions for `.haunt/` paths
- [ ] Update documentation to show `.haunt/` structure

### Stage 3: Migration (REQ-086)
- [ ] Create `migrate-to-sdlc-dir.sh` script
- [ ] Test migration on sample project
- [ ] Document migration process
- [ ] Provide rollback capability

### Stage 4: Ritual Scripts (REQ-087)
- [ ] Copy ritual scripts to `Haunt/scripts/`
- [ ] Update paths in scripts
- [ ] Test scripts in `.haunt/scripts/` location
- [ ] Add to setup script installation

### Stage 5: Verification (REQ-088)
- [ ] Update setup verification for `.haunt/` structure
- [ ] Test `--fix` mode creates correct structure
- [ ] Verify `.haunt/` in `.gitignore`

---

## Benefits Summary

### For Developers
- **Cleaner repository root:** No scattered SDLC directories
- **Clear separation:** Framework artifacts vs. project code
- **Gitignore simplicity:** One `.haunt/` entry instead of multiple
- **Portable:** `.haunt/` can be copied to new projects

### For Agents
- **Predictable paths:** Always know where to find roadmap
- **Centralized location:** All SDLC files in one place
- **Migration clarity:** Path mapping table guides updates
- **Backward compatible:** Gradual migration with fallbacks

### For Teams
- **Consistent structure:** Same layout across all projects
- **Selective sharing:** Can commit tests/scripts, ignore working files
- **Onboarding clarity:** `.haunt/` signals "framework territory"
- **Version control hygiene:** Working files don't pollute history

---

## FAQ

**Q: Why gitignore the entire .haunt/ directory?**
A: Most contents (plans, progress, completed) are ephemeral working files specific to each agent's session. They're valuable context but not collaboration artifacts. Tests and scripts can be selectively un-ignored.

**Q: What about sharing learnings via pattern tests?**
A: `.haunt/tests/` can be un-ignored in your project `.gitignore` if you want to commit pattern tests. The framework supports both approaches.

**Q: How do I know which path to use in my scripts?**
A: Always use `.haunt/` paths for new code. The path mapping table (above) shows the conversion for existing code.

**Q: What if I'm already using `plans/` in my project?**
A: The migration script will handle the move. If you have non-Ghost County files in `plans/`, manually separate them first or use selective migration.

**Q: Can I customize the structure?**
A: Yes, but maintain the core divisions (plans, progress, completed, tests, docs, scripts). Custom subdirectories are fine.

**Q: Why `.haunt/` instead of `.ghost-county/`?**
A: `.haunt/` is shorter and the directory tree makes the purpose clear. The "Ghost County" branding is reflected in documentation and agent names.

---

## References

- **REQ-080:** This specification (directory structure definition)
- **REQ-081:** Setup script project structure phase updates
- **REQ-082:** Validation script path updates
- **REQ-083:** Skills path updates
- **REQ-084:** Agent definition path updates
- **REQ-085:** Documentation path updates
- **REQ-086:** Migration script implementation
- **REQ-087:** Ritual scripts path updates
- **REQ-088:** Setup verification path updates

---

## Revision History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-12-10 | Initial specification | Dev (documentation mode) |

---

**Status:** Ready for implementation (REQ-081+)
**Approval Required:** Yes (before proceeding with Batch 7)
**Migration Impact:** Medium (requires script updates, backward compatibility maintained)
