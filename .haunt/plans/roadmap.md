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

## Batch: Haunt Efficiency Overhaul

> Critical batch to reduce instruction overhead from ~380 to ~100. Research shows LLM instruction-following degrades significantly above 150-200 instructions.

**Rationale:** Hooks provide deterministic enforcement. Rules duplicating hook behavior waste instruction budget and degrade model performance on ALL instructions.

### {🟢} REQ-332: Fix Completion Gate Hook False Positives

**Type:** Bug Fix
**Reported:** 2026-01-03
**Source:** Discovered during roadmap editing - hook matches any text containing emoji

**Description:**
The completion-gate.sh hook incorrectly triggers when editing roadmap.md with any content containing the green circle emoji, even if not marking a requirement complete. It matched "Unblocked" status in a summary table.

**Tasks:**

- [x] Update hook to only match status icon at start of requirement header
- [x] Add pattern to specifically match status changes in header format
- [x] Test that adding new requirements does not trigger hook
- [x] Test that updating summary tables does not trigger hook
- [x] Test that actual completion still gets validated

**Files:**

- `Haunt/hooks/completion-gate.sh` (modify)

**Effort:** XS (30min)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Hook only triggers on actual requirement completion, not text matches
**Blocked by:** None

---

### {🟢} REQ-327: Delete Hook-Redundant Rules

**Type:** Enhancement
**Reported:** 2026-01-03
**Source:** Efficiency audit - rules duplicate hook enforcement

**Description:**
Remove rules that duplicate behavior already enforced by hooks. Hooks are deterministic; rules telling Claude to do what hooks enforce anyway waste instruction budget.

**Tasks:**

- [x] Delete ~/.claude/rules/gco-seance-enforcement.md (hook: phase-enforcement.sh)
- [x] Delete ~/.claude/rules/gco-file-conventions.md (hook: file-location-enforcer.sh)
- [x] Delete source files from Haunt/rules/
- [x] Verify hooks still function correctly after rule removal

**Files:**

- `Haunt/rules/gco-seance-enforcement.md` (deleted)
- `Haunt/rules/gco-file-conventions.md` (deleted)

**Implementation Notes:**
- Deleted both source and deployed rule files
- Hooks remain configured in ~/.claude/settings.json and functional
- Setup script naturally skips deleted rules (uses wildcard *.md loop)
- Instruction overhead reduced by ~66 lines
- Manual verification: Confirmed hooks still exist and are properly configured

**Effort:** XS (30min-1hr)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Rules deleted, hooks still enforce behavior, setup script updated
**Blocked by:** None
### {⚪} REQ-328: Convert Domain Standards to Skills

**Type:** Enhancement
**Reported:** 2026-01-03
**Source:** Efficiency audit - domain rules load on every session

**Description:**
Move language/framework-specific standards from always-loaded rules to on-demand skills. These should only load when working on relevant file types.

**Tasks:**

- [ ] Create `Haunt/skills/gco-react-standards/SKILL.md` from rule content
- [ ] Create `Haunt/skills/gco-python-standards/SKILL.md` from rule content
- [ ] Create `Haunt/skills/gco-ui-design-standards/SKILL.md` from rule content
- [ ] Create `Haunt/skills/gco-ui-testing/SKILL.md` from rule content (merge with existing if present)
- [ ] Delete corresponding rules from `Haunt/rules/`
- [ ] Update setup script to deploy skills, not rules
- [ ] Update agent character sheets to reference skills instead of rules

**Files:**

- `Haunt/skills/gco-react-standards/SKILL.md` (create)
- `Haunt/skills/gco-python-standards/SKILL.md` (create)
- `Haunt/skills/gco-ui-design-standards/SKILL.md` (create)
- `Haunt/rules/gco-react-standards.md` (delete)
- `Haunt/rules/gco-python-standards.md` (delete)
- `Haunt/rules/gco-ui-design-standards.md` (delete)
- `Haunt/rules/gco-ui-testing.md` (delete)
- `Haunt/scripts/setup-agentic-sdlc.sh` (modify)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Domain standards available as skills, rules deleted, ~275 lines removed from auto-load
**Blocked by:** None

---

### {⚪} REQ-329: Slim Remaining Rules to References

**Type:** Enhancement
**Reported:** 2026-01-03
**Source:** Efficiency audit - rules contain full procedures instead of references

**Description:**
Reduce remaining rules to minimal reference cards that point to skills for details. Target: ~20-30 lines per rule max.

**Tasks:**

- [ ] Slim `gco-orchestration.md` to delegation decision tree only (~30 lines)
- [ ] Slim `gco-completion-checklist.md` to hook awareness + skill reference (~15 lines)
- [ ] Slim `gco-model-selection.md` to agent/model table only (~20 lines)
- [ ] Slim `gco-roadmap-format.md` to format template only (~30 lines)
- [ ] Slim `gco-session-startup.md` to 4-step lookup only (~20 lines)
- [ ] Slim `gco-framework-changes.md` to core warning only (~15 lines)
- [ ] Verify skills contain full details that rules reference
- [ ] Update any cross-references

**Files:**

- `Haunt/rules/gco-orchestration.md` (modify)
- `Haunt/rules/gco-completion-checklist.md` (modify)
- `Haunt/rules/gco-model-selection.md` (modify)
- `Haunt/rules/gco-roadmap-format.md` (modify)
- `Haunt/rules/gco-session-startup.md` (modify)
- `Haunt/rules/gco-framework-changes.md` (modify)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Each rule <35 lines, total rules <200 lines, skills contain full details
**Blocked by:** REQ-328 (need skills to exist before slimming rules)

---

### {⚪} REQ-330: Measure Post-Optimization Instruction Count

**Type:** Research
**Reported:** 2026-01-03
**Source:** Efficiency audit - need to verify improvement

**Description:**
After completing REQ-327, REQ-328, REQ-329, measure the new instruction count and document the improvement.

**Tasks:**

- [ ] Count instructions in remaining rules (target: <100)
- [ ] Count total lines in remaining rules (target: <200)
- [ ] Document before/after comparison
- [ ] Run test sessions to verify model behavior improvement
- [ ] Update `.haunt/docs/research/claude-code-best-practices-research.md` with results
- [ ] Create baseline metrics for future regression checks

**Files:**

- `.haunt/docs/research/haunt-efficiency-results.md` (create)
- `.haunt/metrics/instruction-count-baseline.json` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Research
**Completion:** Documented reduction to <100 instructions, before/after metrics captured
**Blocked by:** REQ-327, REQ-328, REQ-329

---

### {⚪} REQ-331: Add Context Overhead to Metrics System

**Type:** Enhancement
**Reported:** 2026-01-03
**Source:** Efficiency audit - need ongoing monitoring

**Description:**
Extend the metrics system (REQ-312) to track instruction count and rule overhead as regression indicators.

**Tasks:**

- [ ] Add instruction count metric to `haunt-metrics.sh`
- [ ] Add rule line count metric
- [ ] Add skill count metric
- [ ] Add thresholds: instructions >150 = warning, >200 = critical
- [ ] Integrate with regression check system (REQ-313)

**Files:**

- `Haunt/scripts/haunt-metrics.sh` (modify)
- `Haunt/scripts/haunt-regression-check.sh` (modify - if exists)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Metrics include instruction overhead, regression alerts for threshold violations
**Blocked by:** REQ-330, REQ-313

---

## Summary

| Status | Count | Items |
|--------|-------|-------|
| ⚪ Not Started | 10 | REQ-232, REQ-313, REQ-314, REQ-315, REQ-327, REQ-328, REQ-329, REQ-330, REQ-331, REQ-332 |
| 🟡 In Progress | 0 | - |
| 🔴 Blocked | 4 | REQ-314, REQ-315, REQ-329, REQ-330, REQ-331 |
| ⚪ Unblocked | 6 | REQ-232, REQ-313, REQ-327, REQ-328, REQ-332 |

**Total Effort Remaining:** ~12-18 hours (2 M + 7 S/XS)

**Dependency Chains:**
```
Existing:
REQ-232 (unblocked) ─────────────────────────────────────────────┐
                                                                  │
REQ-313 (unblocked) → REQ-314 → REQ-315 ─────────────────────────┤
                          │                                       │
                          └───────────────────→ REQ-331 ──────────┘

Efficiency Overhaul (PRIORITY):
REQ-327 (unblocked) ──────────────────────────────┐
                                                   │
REQ-328 (unblocked) → REQ-329 → REQ-330 → REQ-331 ┘
```

**Recommended Execution Order:**
0. **REQ-332** (XS, 30 min) - Fix hook false positives first (enables easier roadmap editing)
1. **REQ-327** (XS, 45 min) - Quick win, removes 66 lines immediately
2. **REQ-328** (S, 2 hrs) - Biggest impact, removes 275 lines from auto-load
3. **REQ-329** (M, 3 hrs) - Final consolidation, needs REQ-328 skills first
4. **REQ-330** (S, 1 hr) - Measure results
5. **REQ-331** (S, 1 hr) - Add monitoring
