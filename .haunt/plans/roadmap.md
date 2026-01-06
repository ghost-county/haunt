# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/` for archived work.

---

## Current Focus

**Status:** Haunt Manifest System - 1 requirement

---

## Batch: Haunt Manifest System

### 🟢 REQ-380: Create Haunt manifest.yaml as single source of truth

**Type:** Enhancement
**Reported:** 2026-01-05
**Source:** User report (git-push skill not cleaned) + architecture decision
**Description:** Create a unified manifest.yaml that serves as the single source of truth for all Haunt objects. Enables consistent install/update/delete operations and explicit tracking of deprecated items. The `--clean` flag currently only detects stale `gco-*` prefixed items, missing non-gco items like the `git-push` skill.

**Tasks:**
- [x] Create `Haunt/manifest.yaml` with schema documentation
- [x] Populate active sections (agents, rules, skills, commands) from filesystem
- [x] Add deprecated section with `git-push` skill as first entry
- [x] Create `Haunt/scripts/utils/generate-manifest.sh` to sync active section
- [x] Update `setup-haunt.sh` to read manifest for deployment
- [x] Add `remove_deprecated_items()` function parsing manifest deprecated section
- [x] Integrate deprecated cleanup with `--clean` flag
- [x] Test manifest generation matches filesystem
- [x] Test --clean removes deprecated items

**Files:**
- `Haunt/manifest.yaml` (created - 369 lines)
- `Haunt/scripts/utils/generate-manifest.sh` (created - 217 lines)
- `Haunt/scripts/utils/validate-manifest.sh` (created - bonus)
- `Haunt/scripts/setup-haunt.sh` (modified - ~80 lines)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** ✓ All criteria verified
**Blocked by:** None

---

## Active Work

*No active requirements.*

---

## Summary

| Status | Count | Requirements |
|--------|-------|--------------|
| 🟢 Complete | 1 | REQ-380 |
| 🟢 Archived | 64 | See `.haunt/completed/2026-01/` |
| ⚪ Not Started | 0 | - |
| 🟡 In Progress | 0 | - |

---

## Recent Archives

- **2026-01-05:** Repository Cleanup Batch (8 requirements) → `repo-cleanup-batch.md`
- **2026-01-05:** Damage Control Hooks (7 requirements) → `damage-control-hooks.md`
- **2026-01-05:** Secrets Management Core (6 requirements) → `secrets-management-batch1.md`
- **2026-01-05:** Skill Compression Séance (15 requirements) → `skill-compression-seance.md`
- **2026-01-03:** Various batches (28 requirements) → See `2026-01/`
