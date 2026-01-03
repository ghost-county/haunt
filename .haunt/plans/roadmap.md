# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/` for archived work.

---

## Current Focus

**Recently Completed (2026-01-03 Séance):**
- See `.haunt/completed/2026-01/seance-2026-01-03.md` for full archive
- 16 requirements archived including: REQ-312 (Context Overhead), REQ-326 (JetStream Research), REQ-228/229/230 (Infographics)

**Now Unblocked:**
- REQ-232: Effort Estimation (REQ-231 complete)
- REQ-313: Regression Check Script (REQ-312 complete)

---

## Batch: CLI Improvements

### ⚪ REQ-232: Add Effort Estimation to Batch Status

**Type:** Enhancement
**Reported:** 2026-01-03
**Source:** User request - need effort tracking per batch

**Description:**
Extend the `/haunt status --batch` command to include effort estimation summaries per batch.

**Tasks:**

- [ ] Parse effort fields from requirements (XS/S/M)
- [ ] Calculate effort totals per batch
- [ ] Add effort column to terminal output
- [ ] Add effort summary to JSON output
- [ ] Update command documentation

**Files:**

- `Haunt/scripts/haunt-status.sh` (modify)
- `Haunt/commands/haunt-status.md` (modify)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Batch status shows effort totals
**Blocked by:** None (REQ-231 complete)

---

## Batch: Metrics & Regression Framework

> Build on REQ-312 (Context Overhead Metric) to create automated regression detection.

### ⚪ REQ-313: Create haunt-regression-check Script

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** User request - detect agent performance regressions

**Description:**
Create script to compare current metrics against a stored baseline and detect regressions.

**Tasks:**

- [ ] Create `Haunt/scripts/haunt-regression-check.sh`
- [ ] Implement baseline loading from JSON file
- [ ] Implement current metrics collection
- [ ] Implement comparison with configurable thresholds
- [ ] Add color-coded output
- [ ] Add `--baseline=<file>` parameter
- [ ] Add JSON output format
- [ ] Create command documentation

**Files:**

- `Haunt/scripts/haunt-regression-check.sh` (create)
- `Haunt/commands/haunt-regression-check.md` (create)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Script compares current vs baseline metrics with visual indicators
**Blocked by:** None (REQ-312 complete)

---

### ⚪ REQ-314: Create Baseline Metrics Storage System

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** User request - manage metric baselines for regression testing

**Description:**
Create system to store, manage, and version metric baselines for regression comparison.

**Tasks:**

- [ ] Create `.haunt/metrics/` directory structure
- [ ] Create `Haunt/scripts/haunt-baseline.sh` script
- [ ] Implement `create` command
- [ ] Implement `list` command
- [ ] Implement `show` command
- [ ] Implement `set-active` command
- [ ] Add calibration tracking
- [ ] Create command documentation

**Files:**

- `Haunt/scripts/haunt-baseline.sh` (create)
- `Haunt/commands/haunt-baseline.md` (create)
- `.haunt/metrics/` directory structure

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Baselines can be created, listed, and managed
**Blocked by:** REQ-313

---

### ⚪ REQ-315: Update gco-weekly-refactor Skill

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** User request - add metrics and regression phases to weekly ritual

**Description:**
Update the weekly refactor skill to include metrics and regression phases.

**Tasks:**

- [ ] Add Phase 0: Metrics Review section
- [ ] Add Phase 0.5: Regression Check section
- [ ] Add Phase 4: Context Audit section
- [ ] Update Phase 1 to reference metrics findings
- [ ] Update Phase 6 with calibration period guidance
- [ ] Add regression response decision tree
- [ ] Update weekly report template with new metrics

**Files:**

- `Haunt/skills/gco-weekly-refactor/SKILL.md` (modify)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Skill includes all new phases
**Blocked by:** REQ-314

---

## Summary

| Status | Count | Items |
|--------|-------|-------|
| ⚪ Not Started | 4 | REQ-232, REQ-313, REQ-314, REQ-315 |
| 🟡 In Progress | 0 | - |
| 🔴 Blocked | 2 | REQ-314, REQ-315 |
| 🟢 Unblocked | 2 | REQ-232, REQ-313 |

**Total Effort Remaining:** ~6-10 hours (1 M + 3 S)

**Dependency Chain:**
```
REQ-232 (unblocked) ─────────────────────────────┐
                                                  │
REQ-313 (unblocked) → REQ-314 → REQ-315 ─────────┘
```
