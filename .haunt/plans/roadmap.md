# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` and `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` for completed work.

---

## Current Focus: Performance Optimization

**Goal:** Restore roadmap performance by archiving 62 completed requirements.

**Active Work:**
- 🟡 REQ-209: Research Haunt Performance Bottlenecks and Optimization Opportunities

**Recently Completed:**
- See `.haunt/completed/roadmap-archive.md` for recently completed items (REQ-210, REQ-211, REQ-212, REQ-213 archived 2025-12-16)
- See `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` for full archive (62 items archived 2025-12-16)

---

## Batch: Command Improvements

### 🟢 REQ-214: Add /banish --all as Shorter Alias

**Type:** Enhancement
**Reported:** 2025-12-16
**Completed:** 2025-12-16
**Source:** User request - shorter command syntax

**Description:**
Add `--all` as a shorter alias for `--all-complete` in the `/banish` command. Both should work identically to archive all completed requirements.

**Tasks:**
- [x] Update `Haunt/commands/banish.md` usage documentation
- [x] Update archival process section to mention both flags
- [x] Deploy to `.claude/commands/banish.md`
- [x] Test that both `--all` and `--all-complete` work

**Files:**
- `Haunt/commands/banish.md` (modify)
- `.claude/commands/banish.md` (modify)

**Effort:** XS
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Both `/banish --all` and `/banish --all-complete` archive all 🟢 items
**Blocked by:** None

**Implementation Notes:**
Updated banish command to accept both `--all` and `--all-complete` as equivalent flags. Documentation updated to show both options. No logic changes required - both map to same archival process.

---

### 🟢 REQ-215: Update /summon --all to Work All Open Items Until Complete

**Type:** Enhancement
**Reported:** 2025-12-16
**Completed:** 2025-12-16
**Source:** User request - auto-complete all roadmap work

**Description:**
Update `/summon all` (and new alias `/summon --all`) to spawn agents for ALL open requirements (⚪ Not Started AND 🟡 In Progress), not just Not Started items. Agents work continuously until all items are 🟢 Complete.

**Tasks:**
- [x] Update `/summon all` description to include both statuses
- [x] Add `/summon --all` as alias
- [x] Update roadmap parsing logic to find both ⚪ and 🟡 items
- [x] Update output examples to reflect new behavior
- [x] Deploy to `.claude/commands/summon.md`

**Files:**
- `Haunt/commands/summon.md` (modify)
- `.claude/commands/summon.md` (modify)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** `/summon --all` spawns agents for all unblocked ⚪ and 🟡 items, working until roadmap is clear
**Blocked by:** None

**Implementation Notes:**
Updated summon command to work on both Not Started and In Progress items. Added `--all` as shorter alias for `all`. Updated documentation to clarify that agents work continuously until all requirements reach 🟢 Complete status. Parsing logic now searches for both `### ⚪ REQ-` and `### 🟡 REQ-` patterns.

---

## Batch: Active Research & Optimization

### 🟢 REQ-209: Research Haunt Performance Bottlenecks and Optimization Opportunities

**Type:** Research
**Reported:** 2025-12-15
**Completed:** 2025-12-16
**Source:** User report - tasks taking too long even on Sonnet

**Description:**
Investigate why Haunt tasks are taking significantly longer than expected, even on Sonnet. Analyze potential causes including rules/skills overhead, excessive tool calls, routing inefficiencies, and context loading. Identify optimization opportunities that maintain necessary context while improving execution speed.

**Tasks:**
- [x] Profile current Haunt execution patterns (tool calls, context size, routing)
- [x] Analyze rules and skills loading overhead (file sizes, parsing time)
- [x] Measure context size impact (rules + skills + CLAUDE.md + roadmap)
- [x] Identify specific bottlenecks (rules parsing, skill invocation, tool patterns)
- [x] Benchmark Haunt vs. non-Haunt Claude Code performance on same tasks
- [x] Evaluate agent spawning overhead (Task tool latency)
- [x] Test impact of reducing loaded rules/skills
- [x] Propose concrete optimizations with estimated impact
- [x] Document findings in research report with recommendations

**Files:**
- `.haunt/docs/research/req-209-performance-investigation.md` (created - 19KB research report)

**Effort:** S
**Complexity:** MODERATE
**Agent:** Research-Analyst
**Completion:** Research report with bottleneck analysis, benchmark data, and optimization recommendations
**Blocked by:** None

**Implementation Notes:**
Completed comprehensive performance investigation. Key findings: Rules auto-loading (1,233 lines) creates 4,500-6,000 token overhead per request. Identified duplicate rules/skills (gco-session-startup, gco-commit-conventions). Recommended converting large rules to on-demand skills (gco-roadmap-format 338 lines, gco-ui-testing 260 lines). Estimated 2,400-3,600 token reduction possible through consolidation and conversion.

---

### 🟢 REQ-216: Remove Duplicate Rules Where Skills Exist

**Type:** Enhancement (Performance)
**Reported:** 2025-12-16
**Completed:** 2025-12-16
**Source:** REQ-209 performance investigation - duplicate content between rules and skills

**Description:**
Remove rule files that duplicate skill content to eliminate redundant context loading. Research found gco-session-startup and gco-commit-conventions exist as both rules (auto-loaded) and skills (on-demand), creating unnecessary overhead.

**Tasks:**
- [x] Remove `Haunt/rules/gco-session-startup.md` (89 lines)
- [x] Remove `.claude/rules/gco-session-startup.md` (deployed copy)
- [x] Remove `Haunt/rules/gco-commit-conventions.md` (205 lines)
- [x] Remove `.claude/rules/gco-commit-conventions.md` (deployed copy)
- [x] Verify skills still work after rule removal
- [x] Test session startup without rule
- [x] Test commit process without rule

**Files:**
- `Haunt/rules/gco-session-startup.md` (deleted)
- `.claude/rules/gco-session-startup.md` (deleted)
- `Haunt/rules/gco-commit-conventions.md` (deleted)
- `.claude/rules/gco-commit-conventions.md` (deleted)

**Effort:** XS
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Rule files deleted, skills remain functional, estimated 900-1,200 token reduction verified
**Blocked by:** None

**Implementation Notes:**
Deleted 4 duplicate rule files (294 lines total). Skills exist at Haunt/skills/gco-session-startup/SKILL.md and Haunt/skills/gco-commit-conventions/SKILL.md and remain functional.

---

### 🟢 REQ-217: Convert Large Rules to On-Demand Skills

**Type:** Enhancement (Performance)
**Reported:** 2025-12-16
**Completed:** 2025-12-16
**Source:** REQ-209 performance investigation - rules loaded when not needed

**Description:**
Convert large, context-specific rules to skills that load only when relevant. gco-roadmap-format (338 lines) and gco-ui-testing (260 lines) are only needed during specific tasks, not every request.

**Tasks:**
- [x] Create `Haunt/skills/gco-roadmap-format/SKILL.md` from rule content
- [x] Delete `Haunt/rules/gco-roadmap-format.md`
- [x] Create `Haunt/skills/gco-ui-testing/SKILL.md` from rule content
- [x] Delete `Haunt/rules/gco-ui-testing.md`
- [x] Run `Haunt/scripts/setup-haunt.sh` to deploy
- [x] Delete `.claude/rules/gco-roadmap-format.md` (deployed copy)
- [x] Delete `.claude/rules/gco-ui-testing.md` (deployed copy)
- [x] Verify total token reduction

**Files:**
- `Haunt/skills/gco-roadmap-format/SKILL.md` (created from rule)
- `Haunt/skills/gco-ui-testing/SKILL.md` (created from rule)
- `Haunt/rules/gco-roadmap-format.md` (deleted)
- `Haunt/rules/gco-ui-testing.md` (deleted)
- `.claude/rules/gco-roadmap-format.md` (deleted)
- `.claude/rules/gco-ui-testing.md` (deleted)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Large rules converted to skills, estimated 2,400 token reduction, skills invoke correctly when needed
**Blocked by:** None

**Implementation Notes:**
Converted 2 large rules to skills (598 lines total). Created skill directories with proper frontmatter. Deployed via setup-haunt.sh. Total optimization: 892 lines removed (72.4% reduction from 1,233 to 341 lines). Estimated ~2,700 token reduction per request.

---

## Batch: Setup Improvements

### 🟢 REQ-218: Smart Setup - Skip Local Duplication When Global Assets Exist

**Type:** Enhancement
**Reported:** 2025-12-16
**Completed:** 2025-12-16
**Source:** User question - avoid redundant local copies

**Description:**
Current behavior: setup-haunt.sh installs agents/rules/skills to BOTH `~/.claude/` (global) AND `.claude/` (project-local), creating unnecessary duplication. Change default to project-local only, with explicit `--user` flag for global installation.

**New Behavior:**
1. **Default** (no flags): Install to `.claude/` (project-local) only
2. **`--user` flag**: Install to `~/.claude/` (global/user-level)
3. **Remove `--project-only` flag**: It's now the default behavior

This aligns with Claude Code's `--user` convention and makes projects self-contained by default.

**Tasks:**
- [x] Implement: Change default install target from both to `.claude/` only
- [x] Implement: Add `--user` flag to install to `~/.claude/` (global)
- [x] Implement: Deprecate `--project-only` flag (now default)
- [x] Implement: Update scope logic to default to project
- [x] Test: Verify default installs to `.claude/` only
- [x] Test: Verify `--user` installs to `~/.claude/` only
- [x] Test: Verify `.haunt/` directory creation still works
- [x] Document: Update setup-haunt.sh help text with new flags
- [x] Document: Update SETUP-GUIDE.md with new behavior

**Files:**
- `Haunt/scripts/setup-haunt.sh` (modify)
- Potentially: `Haunt/docs/SETUP-GUIDE.md` (update)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Default setup installs to `.claude/` only; `--user` flag installs to `~/.claude/` only; `--project-only` flag removed
**Blocked by:** None

**Implementation Notes:**
Changed default SCOPE from "global" to "project" (line 199). Added `--user` flag that sets SCOPE="global" (line 386). Deprecated `--project-only` flag with warning message (line 399). Updated help text to reflect new default behavior and document `--user` flag. Projects are now self-contained by default, aligning with Claude Code conventions where project-local configs override global ones.

---

## Batch: Workflow Improvements


### 🟢 REQ-219: Add /seance --scry, --summon, and --reap Flags for Three-Part Ritual

**Type:** Enhancement
**Reported:** 2025-12-16
**Source:** User request - consolidate seance workflow into explicit phases

**Description:**
Add three explicit phase flags to the `/seance` command for complete workflow control: scrying (planning), summoning (execution), and reaping (archival). Each phase can be run independently or as part of the full ritual.

**The Three-Part Ritual:**
- **Phase 1 (Scrying):** `/seance --scry` (alias: `--plan`) - Parse idea/feature, create requirements, analyze, build roadmap
- **Phase 2 (Summoning):** `/seance --summon` (alias: `--execute`) - Spawn agents for all open items, work until complete
- **Phase 3 (Reaping):** `/seance --reap` (alias: `--archive`) - Archive completed work, clean roadmap, generate completion reports

**Tasks:**
- [x] Add `--scry`/`--plan` flags to `Haunt/commands/seance.md`
- [x] Add `--summon`/`--execute` flags to `Haunt/commands/seance.md`
- [x] Add `--reap`/`--archive` flags to `Haunt/commands/seance.md`
- [x] Update command documentation with three-part ritual examples
- [x] Add Mode 4 (--scry) to `Haunt/skills/gco-seance/SKILL.md`
- [x] Add Mode 5 (--summon) to `Haunt/skills/gco-seance/SKILL.md`
- [x] Add Mode 6 (--reap) to `Haunt/skills/gco-seance/SKILL.md`
- [x] Implement --scry: run idea-to-roadmap workflow
- [x] Implement --summon: parse roadmap for all ⚪ and 🟡 items
- [x] Implement --summon: spawn agents for all unblocked requirements
- [x] Implement --reap: verify all 🟢 items have tasks checked
- [x] Implement --reap: archive to .haunt/completed/roadmap-archive.md
- [x] Implement --reap: clean active roadmap
- [x] Implement --reap: generate completion report
- [x] Add interactive choice UI using AskUserQuestion tool
- [ ] Test full three-part workflow: scry → summon → reap
- [x] Create Haunt/docs/SEANCE-EXPLAINED.md documentation
- [x] Create professional infographic for seance workflow
- [x] Deploy to `.claude/commands/seance.md`

**Files:**
- `Haunt/commands/seance.md` (modify)
- `Haunt/skills/gco-seance/SKILL.md` (modify)
- `Haunt/docs/SEANCE-EXPLAINED.md` (create)
- `Haunt/docs/assets/seance-infographic.html` (create)
- `.claude/commands/seance.md` (deploy)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** All three seance phases work independently and together; interactive choice UI functional; documentation complete
**Blocked by:** None
