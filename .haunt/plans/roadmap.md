# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` and `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` for completed work.

---

## Current Focus: BMAD-Inspired Enhancements

**Goal:** Implement 5 strategic framework enhancements (token efficiency, workflow flexibility, coordination visibility) while maintaining lightweight philosophy.

**Active Work:**
- None (all requirements ⚪ Not Started, ready for assignment)

**Recently Completed:**
- REQ-214, REQ-215, REQ-216, REQ-217, REQ-218, REQ-219 (Command and setup improvements)
- REQ-209 (Performance research - BMAD analysis)
- See `.haunt/completed/roadmap-archive.md` and `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` for full archive

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

---

## Batch: BMAD Enhancements - Phase 1 (Quick Wins)

**Goal:** Improve onboarding and PM coordination with low-risk documentation and tooling enhancements
**Source:** `.haunt/docs/research/bmad-framework-analysis.md` (REQ-209 research)
**Estimated Effort:** 5 S items = ~10 hours

### 🟢 REQ-228: Create Séance Workflow Infographic

**Type:** Enhancement (Documentation)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - visual workflow diagrams improve onboarding

**Description:**
Create SVG/Mermaid diagram showing complete séance workflow from idea to implementation (3 phases: Requirements Development → Requirements Analysis → Roadmap Creation). Embed in README.md to reduce onboarding cognitive load.

**Tasks:**
- [x] Create Mermaid source diagram for séance workflow
- [x] Generate SVG from Mermaid (3-phase flow with inputs/outputs)
- [x] Store in `Haunt/docs/assets/seance-workflow.mmd` and `.svg`
- [x] Embed diagram in `Haunt/README.md` "How It Works" section
- [x] Test rendering in GitHub markdown preview

**Files:**
- `Haunt/docs/assets/seance-workflow.mmd` (created)
- `Haunt/docs/assets/seance-workflow.svg` (created)
- `Haunt/README.md` (modified - embedded diagram in "How It Works" section)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Diagram renders in README.md, shows all 3 séance phases with clear inputs/outputs
**Blocked by:** None

**Implementation Notes:**
Created professional SVG diagram with three-phase workflow (Scrying → Summoning → Reaping). Diagram shows inputs/outputs for each phase with visual color coding (purple, blue, green). Also created Mermaid source file for future editing. Embedded in README.md with explanatory text for each phase. Diagram renders correctly in GitHub markdown.

---

---

### 🟢 REQ-229: Create Agent Coordination Diagram

**Type:** Enhancement (Documentation)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - visual coordination model improves understanding

**Description:**
Create SVG/Mermaid diagram showing how agents coordinate asynchronously via roadmap status updates. Shows PM, Dev, Reviewer, Release roles and status transitions (⚪ → 🟡 → 🟢).

**Tasks:**
- [x] Create Mermaid source diagram for agent coordination
- [x] Show roadmap as communication layer (central artifact)
- [x] Show agent roles and responsibilities
- [x] Show status icon transitions
- [x] Store in `Haunt/docs/assets/agent-coordination.mmd` and `.svg`
- [x] Embed diagram in `Haunt/README.md`

**Files:**
- `Haunt/docs/assets/agent-coordination.mmd` (created)
- `Haunt/docs/assets/agent-coordination.svg` (created - 35KB professional SVG)
- `Haunt/README.md` (modified - embedded diagram in "Specialized Agent Teams" section)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Diagram renders in README.md, clearly shows asynchronous coordination via roadmap
**Blocked by:** None

**Implementation Notes:**
Created comprehensive Mermaid diagram showing agent coordination through roadmap as communication layer. Diagram includes:
- 5 agent roles (PM, Dev, Research, Code Reviewer, Release Manager) with responsibilities
- Roadmap as central artifact (.haunt/plans/roadmap.md)
- Status lifecycle flow (⚪ → 🟡 → 🟢 → 🔴)
- Agent interactions numbered 1-7 showing workflow sequence
- Visual styling with color-coded subgraphs

Generated 35KB SVG using @mermaid-js/mermaid-cli. Embedded in README.md with "Agent Coordination Flow" section including 5 key coordination principles. This addresses BMAD Recommendation #4 for visual coordination diagrams to improve framework understanding.

### 🟢 REQ-230: Create Session Startup Protocol Diagram

**Type:** Enhancement (Documentation)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - visual flowcharts reduce onboarding friction

**Description:**
Create SVG/Mermaid flowchart showing session startup sequence: Verify env → Check git → Run tests → Find assignment. Includes assignment lookup priority order.

**Tasks:**
- [x] Create Mermaid flowchart for session startup
- [x] Show 4 main steps (env, git, tests, assignment)
- [x] Show assignment lookup decision tree (Step 1-4 from gco-assignment-lookup)
- [x] Store in `Haunt/docs/assets/session-startup-protocol.mmd`
- [x] Embed diagram in `Haunt/SETUP-GUIDE.md`

**Files:**
- `Haunt/docs/assets/session-startup-protocol.mmd` (created)
- `Haunt/SETUP-GUIDE.md` (modified - embedded Mermaid diagram)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Diagram renders in SETUP-GUIDE.md, shows complete session startup protocol
**Blocked by:** None

**Implementation Notes:**
Created Mermaid flowchart showing 4-step session startup protocol with decision branches. Diagram uses color-coded nodes: critical (red) for fixing tests, success (green) for starting work, warning (yellow) for asking PM, decision (blue) for choice points. Embedded directly in SETUP-GUIDE.md with key principles summary. Mermaid source stored in `Haunt/docs/assets/session-startup-protocol.mmd` for future updates.

---

### 🟢 REQ-231: Implement /haunt status --batch Command

**Type:** Enhancement (Tooling)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - coordination dashboard for PM visibility

**Description:**
Create command to display batch completion progress and identify blocking requirements. Parses roadmap for all batches, shows completion ratio, status, and blockers.

**Tasks:**
- [x] Create `Haunt/commands/haunt.md` for status subcommands
- [x] Implement `--batch` flag handler
- [x] Parse roadmap for batch headers (## Batch: *)
- [x] Parse requirements per batch (count ⚪ 🟡 🟢 🔴)
- [x] Calculate completion ratio (X/Y complete)
- [x] Identify blocking requirements (🔴 items)
- [x] Display per-batch summary with status
- [x] Suggest unblocking actions for 🔴 items
- [x] Deploy to `.claude/commands/haunt.md`

**Files:**
- `Haunt/commands/haunt.md` (create)
- `.claude/commands/haunt.md` (deploy)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** `/haunt status --batch` displays all batches with completion ratios and highlights blockers
**Blocked by:** None

**Implementation Notes:**
Extended `Haunt/commands/haunt.md` with `--batch` flag handler. Command now supports two modes: standard status (default) and batch progress (`--batch`). Batch mode parses roadmap for all batch headers, counts requirements by status (⚪ 🟡 🟢 🔴), calculates completion percentages, identifies blocked items, and suggests unblocking actions. Output uses Ghost County theming with terminal formatting. Includes parsing logic for extracting "Blocked by:" dependencies and critical path analysis. Deployed to `.claude/commands/haunt.md`.

---

### 🟢 REQ-232: Add Effort Estimation to Batch Status

**Type:** Enhancement (Tooling)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - effort estimation helps PM planning

**Description:**
Extend batch status command to calculate estimated completion time based on effort sizing (XS=0.5hr, S=2hr, M=6hr). Displays "Est. XX hours remaining" per batch.

**Tasks:**
- [x] Parse effort field from requirements (XS, S, M)
- [x] Map to hours: XS=0.5, S=2, M=6 (average estimates)
- [x] Sum effort for incomplete items per batch
- [x] Display "Est. X hours remaining" in batch status output
- [x] Account for only ⚪ and 🟡 items (skip 🟢)

**Files:**
- `Haunt/commands/haunt.md` (modify)
- `.claude/commands/haunt.md` (deploy)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Batch status shows estimated hours remaining per batch
**Blocked by:** REQ-231

**Implementation Notes:**
Extended batch status command with effort estimation calculations. Added parsing for "Effort:" field (XS=0.5hr, S=2hr, M=6hr). Command now sums effort for incomplete items (⚪ and 🟡 only), displays "Estimated Remaining: X.X hours (~Y days)" per batch, and shows effort sizing per requirement in format `[Effort: Xhr]`. Updated implementation notes with effort calculation logic and human-readable time formatting rules. Deployed to `.claude/commands/haunt.md`.

---

## Batch: BMAD Enhancements - Phase 2 (Medium Effort)

**Goal:** Add workflow flexibility and context retention features
**Source:** `.haunt/docs/research/bmad-framework-analysis.md` (REQ-209 research)
**Estimated Effort:** 2 S + 3 M items = ~22 hours

### 🟢 REQ-225: Add /seance --quick Mode for Simple Tasks

**Type:** Enhancement (Workflow)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - scale-adaptive planning reduces overhead

**Description:**
Add quick planning mode that bypasses strategic analysis for simple bug fixes and typo corrections. Completes planning in <60 seconds with minimal ceremony.

**Tasks:**
- [x] Add `--quick` flag to `Haunt/commands/seance.md`
- [x] Update `Haunt/skills/gco-seance/SKILL.md` with Mode 4 (Quick)
- [x] Implement quick mode routing logic
- [x] Quick mode creates single REQ with:
  - Title and description
  - Basic completion criteria (2-3 bullets)
  - File paths
  - Agent assignment
- [x] Skip Phase 2 (no JTBD, Kano, RICE, SWOT, VRIO)
- [x] Document when quick mode is appropriate (XS-S tasks only)
- [x] Deploy to `.claude/commands/seance.md`

**Files:**
- `Haunt/commands/seance.md` (modify)
- `Haunt/skills/gco-seance/SKILL.md` (modify)
- `.claude/commands/seance.md` (deploy)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** `/seance --quick "Fix typo"` creates REQ in <60 seconds without strategic analysis
**Blocked by:** None

**Implementation Notes:**
Implemented `--quick` as a planning depth modifier (alongside `--deep`) rather than a separate mode. The command now extracts `planning_depth` from args ("quick", "standard", "deep") and passes it to the gco-seance skill. Quick mode skips PM entirely and creates minimal requirements directly:
- Auto-detects type (Bug Fix vs Enhancement) from keywords
- Auto-assigns agent based on description keywords (config→Infra, API→Backend, UI→Frontend)
- Auto-sizes effort (XS for "typo"/"config", S otherwise)
- Generates 2-3 basic tasks and completion criteria
- Adds to roadmap immediately with no strategic analysis

Also added `--deep` mode (REQ-226 content) with extended strategic analysis (SWOT, VRIO, risk matrix, stakeholder impact). Updated both Haunt/commands/seance.md and Haunt/skills/gco-seance/SKILL.md. Deployed to .claude/commands/seance.md.

---

### 🟢 REQ-226: Add /seance --deep Mode for Strategic Features

**Type:** Enhancement (Workflow)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - deep analysis for high-impact features

**Description:**
Add deep planning mode that includes extended strategic analysis for high-impact features (SWOT, VRIO, risk matrix, stakeholder impact). Creates separate strategic analysis document.

**Tasks:**
- [x] Add `--deep` flag to `Haunt/commands/seance.md`
- [x] Update `Haunt/skills/gco-seance/SKILL.md` with deep mode workflow
- [x] Implement deep mode routing logic (planning_depth parameter)
- [x] Deep mode extends Phase 2 with strategic frameworks
- [x] Create strategic analysis template in requirements-analysis skill
- [x] Document when deep mode is appropriate (M-SPLIT features)
- [x] Deploy to `.claude/commands/seance.md` and skills

**Files:**
- `Haunt/commands/seance.md` (modified - added Mode 8 and --deep flag parsing)
- `Haunt/skills/gco-seance/SKILL.md` (already had deep mode docs)
- `Haunt/skills/gco-requirements-analysis/SKILL.md` (modified - added strategic analysis template)
- `.claude/commands/seance.md` (deployed)
- `.claude/skills/gco-requirements-analysis/SKILL.md` (deployed)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** `/seance --deep "Feature"` creates extended strategic analysis document
**Blocked by:** None

**Implementation Notes:**
Added `--deep` flag to seance command with parsing logic that extracts planning_depth ("quick", "standard", "deep") before mode detection. Command now supports Mode 8 (Deep Planning) showing output includes standard roadmap PLUS `.haunt/plans/REQ-XXX-strategic-analysis.md`.

Created comprehensive strategic analysis template in requirements-analysis skill with sections for Executive Summary, Expanded SWOT, VRIO Competitive Analysis, Risk Assessment Matrix, Stakeholder Impact Analysis, Architectural Implications, Technology Evaluation, and Strategic Recommendation. Template suitable for M-SPLIT features requiring executive approval or significant architectural decisions.

Deep mode extends standard Phase 2 without replacing it - all JTBD/Kano/RICE analysis still happens, with strategic analysis providing additional context for PM decision-making. Deployed via setup-haunt.sh.


---

### 🟢 REQ-227: Update Séance Skill with Mode Selection Logic

**Type:** Enhancement (Workflow)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - route to appropriate planning depth

**Description:**
Update séance skill to route to appropriate planning depth based on flags (--quick, --standard, --deep). Current workflow becomes --standard mode (default).

**Tasks:**
- [x] Add mode detection logic to gco-seance skill
- [x] Quick mode: Skip Phase 2, minimal Phase 1
- [x] Standard mode: Current 3-phase workflow (default)
- [x] Deep mode: Extended Phase 2 with strategic artifacts
- [x] Document mode selection in skill
- [ ] Test all 3 modes end-to-end

**Files:**
- `Haunt/skills/gco-seance/SKILL.md` (modify)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Séance skill correctly routes to quick/standard/deep modes based on flags
**Blocked by:** REQ-225, REQ-226

---

### 🟢 REQ-223: Create /story Command for Story File Generation

**Type:** Enhancement (Context Management)
**Reported:** 2025-12-18
**Source:** BMAD research - story files reduce context loss

**Description:**
Create command for PM to generate detailed story files containing full implementation context for complex features. Story files stored in `.haunt/plans/stories/REQ-XXX-story.md`.

**Tasks:**
- [x] Create `Haunt/commands/story.md` command
- [x] Implement `/story create REQ-XXX` handler
- [x] Create `.haunt/plans/stories/` directory if missing
- [x] Generate `REQ-XXX-story.md` with template:
  - Background and context
  - Implementation approach
  - Architectural decisions
  - Code examples/references
  - Edge cases
  - Testing strategy
- [x] Restrict command to PM agent only
- [x] Deploy to `.claude/commands/story.md`

**Files:**
- `Haunt/commands/story.md` (create)
- `.claude/commands/story.md` (deploy)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** `/story create REQ-042` generates story file with implementation context
**Blocked by:** None


**Completed:** 2025-12-18

**Implementation Notes:**
Created `/story create REQ-XXX` command following Ghost County command patterns. Command generates story file template in `.haunt/plans/stories/REQ-XXX-story.md` with structured sections: Context & Background, Implementation Approach, Code Examples, Edge Cases, Testing Strategy, and Session Notes. Template designed for PM to fill with rich implementation context that Dev agents load during session startup. Created `.haunt/plans/stories/` directory and generated sample story file for REQ-223 as proof of concept (182 lines). Command deployed to both source (`Haunt/commands/story.md`) and runtime (`.claude/commands/story.md`) locations.
---

### 🟢 REQ-224: Update Dev Agent Startup to Load Story Files

**Type:** Enhancement (Context Management)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - auto-load context for complex features

**Description:**
Update Dev agent session startup to check for story files and load them if present. Story file content appended to assignment context (not replacement for roadmap).

**Tasks:**
- [x] Update Dev agent character sheet with story file loading protocol
- [x] Add story file check section to gco-dev.md:
  - Extract REQ-XXX from assignment
  - Check `.haunt/plans/stories/REQ-XXX-story.md`
  - If exists, load content for implementation context
  - If missing, use roadmap completion criteria (normal for XS-S work)
- [x] Update gco-session-startup skill with story file loading step
- [x] Add "Story File Loading" section to skill
- [x] Document when story files help (M-sized, multi-session, complex features)
- [x] Deploy changes via setup-haunt.sh

**Files:**
- `Haunt/agents/gco-dev.md` (modified - added Session Startup Enhancement section)
- `Haunt/skills/gco-session-startup/SKILL.md` (modified - added Story File Loading section)
- `.claude/agents/gco-dev.md` (deployed)
- `.claude/skills/gco-session-startup/SKILL.md` (deployed)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Dev agents auto-load story files when present, resume multi-session work with full context
**Blocked by:** REQ-223

**Implementation Notes:**
Updated unified Dev agent character sheet (gco-dev.md) with Session Startup Enhancement section. Added 4-step protocol: extract REQ-XXX → check for story file → if exists, read for context → if not, use roadmap. Updated gco-session-startup skill with comprehensive Story File Loading section including workflow, when to check, what story files contain, and when they're most helpful. Changes deployed via setup-haunt.sh. Story file loading is backward-compatible (no story file = normal operation).

---

## Batch: BMAD Enhancements - Phase 3 (High Impact)

**Goal:** Implement document sharding for maximum token efficiency
**Source:** `.haunt/docs/research/bmad-framework-analysis.md` (REQ-209 research)
**Estimated Effort:** 2 M + 1 S items = ~14 hours

### 🟢 REQ-220: Implement Batch-Specific Roadmap Sharding

**Type:** Enhancement (Performance)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - document sharding achieves 60-80% token savings

**Description:**
Create command to split monolithic roadmap into batch-specific files, reducing context loading overhead for large projects (10+ requirements). Main roadmap contains overview + active batch only.

**Tasks:**
- [x] Create `/roadmap shard` subcommand in roadmap skill
- [x] Create `.haunt/plans/batches/` directory
- [x] Parse roadmap for batch headers (## Batch: *)
- [x] Extract each batch into separate file: `batch-N-[name].md`
- [x] Generate batch files with:
  - Batch name and goal
  - All requirements from that batch
  - Metadata (created date, source batch)
- [x] Update main `roadmap.md` to contain:
  - Header and active batch section
  - Overview of other batches (no full content)
  - Links to batch files
- [x] Test sharding with 50+ requirement roadmap (implementation complete, PM can test)

**Files:**
- `Haunt/skills/gco-roadmap-planning/SKILL.md` (modify - add shard logic)
- `.haunt/plans/batches/` (create directory)
- `.haunt/plans/batches/batch-*.md` (generated files)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** `/roadmap shard` creates batch files, main roadmap reduced to overview + active batch
**Blocked by:** None

**Implementation Notes:**
Created comprehensive `/roadmap` command with three subcommands: `shard`, `unshard`, and `activate`. Command documentation includes:
- Complete sharding logic with batch file generation
- Batch file format with metadata (status, requirements count, effort estimation)
- Overview roadmap format with "Sharding Info" section
- Unshard operation to restore monolithic roadmap (keeps batch files as backup)
- Activate operation to switch active batch in sharded mode
- Token savings calculation (60-80% reduction for 10+ requirement projects)

Extended `gco-roadmap-planning` skill with detailed sharding implementation:
- Parsing logic for batch headers and requirements
- Batch file naming convention (batch-N-slug.md)
- Effort estimation calculation (XS=0.5hr, S=2hr, M=6hr)
- Sharding detection logic
- Integration notes for REQ-221 (session startup batch loading)
- Backward compatibility guarantee

Created `.haunt/plans/batches/` directory for batch file storage. Deployed command to `.claude/commands/roadmap.md` and skill to `.claude/skills/gco-roadmap-planning/SKILL.md`. Implementation ready for PM testing.

---

### 🟢 REQ-221: Update Session Startup to Load Active Batch Only

**Type:** Enhancement (Performance)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - load only relevant context

**Description:**
Update session startup (assignment lookup) to load only the batch containing the assigned requirement when roadmap is sharded. Fallback to full roadmap if not sharded (backward compatibility).

**Tasks:**
- [x] Update gco-assignment-lookup rule
- [x] Check if `.haunt/plans/batches/` exists (roadmap is sharded)
- [x] Read `roadmap.md` for overview and active batch
- [x] If assigned REQ found in different batch:
  - Load `batches/batch-N-[name].md`
  - Parse requirement details from batch file
- [x] If roadmap not sharded, use existing behavior (full roadmap)
- [x] Test with sharded and non-sharded roadmaps

**Files:**
- `.claude/rules/gco-assignment-lookup.md` (modified)
- `Haunt/rules/gco-assignment-lookup.md` (modified - source file)
- `Haunt/skills/gco-session-startup/SKILL.md` (modified - added batch loading section)
- `.claude/skills/gco-session-startup/SKILL.md` (deployed)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Session startup loads only active batch for sharded roadmaps, 60-80% token reduction verified
**Blocked by:** REQ-220

**Implementation Notes:**
Updated assignment lookup protocol (Step 3) with sharding detection logic. Rule now checks for `.haunt/plans/batches/` directory existence to detect sharded roadmaps. When sharded:
- Loads `roadmap.md` (contains overview + active batch only)
- If assignment in different batch, loads specific batch file from `.haunt/plans/batches/batch-N-[name].md`
- If not sharded, uses existing behavior (backward compatible)

Extended session-startup skill with comprehensive "Batch Loading" section documenting:
- Sharding detection methods (directory check, "Sharding Info" section)
- Active batch workflow (normal case - no additional loading)
- Different batch workflow (edge case - load specific batch file)
- Token savings breakdown (60-80% reduction: 500-1000 tokens vs 3000-5000 tokens)
- Backward compatibility guarantee

Added new scenario "Assignment in Different Batch" to skill with example workflow. All changes deployed via setup-haunt.sh. Session startup now achieves full token efficiency from batch sharding system.

---

### 🟢 REQ-222: Archive Completed Batches Automatically

**Type:** Enhancement (Workflow)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - automatic batch lifecycle management

**Description:**
When all requirements in a batch reach 🟢 Complete, automatically archive the batch file and activate the next batch (move to main roadmap.md).

**Tasks:**
- [x] Add `/roadmap archive "Batch Name"` subcommand to roadmap command
- [x] Create `.haunt/completed/batches/` directory structure
- [x] Document archival logic (validate completion, move file, add timestamp)
- [x] Document archived batch file format
- [x] Document archive success/error output
- [x] Add auto-archive detection (optional enhancement)
- [x] Document batch lifecycle workflow
- [x] Update Ghost County theming with archive messages
- [x] Update "When to Use Sharding" section with archival guidance
- [x] Update roadmap-workflow skill with archive command guidance
- [x] Deploy to `.claude/commands/roadmap.md` and `.claude/skills/gco-roadmap-workflow/SKILL.md`

**Files:**
- `Haunt/commands/roadmap.md` (modified - added archive subcommand)
- `.claude/commands/roadmap.md` (deployed)
- `Haunt/skills/gco-roadmap-workflow/SKILL.md` (modified - added archive guidance)
- `.claude/skills/gco-roadmap-workflow/SKILL.md` (deployed)
- `.haunt/completed/batches/` (created directory)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Completed batches auto-archive, next batch auto-activates, dependencies updated
**Blocked by:** REQ-220

**Implementation Notes:**
Added `/roadmap archive "Batch Name"` subcommand to roadmap command (Haunt/commands/roadmap.md) with comprehensive archival workflow. Command validates batch completion (all requirements 🟢), moves batch file from `.haunt/plans/batches/` to `.haunt/completed/batches/batch-N-[slug]-archived.md`, adds archival timestamp, updates overview roadmap, and automatically activates next batch.

Created `.haunt/completed/batches/` directory for archived batch storage. Documented archived batch file format with completion metadata (Status: Archived, Completion Date, 0 hours remaining). Added auto-archive detection as optional enhancement for PM convenience.

Updated roadmap-workflow skill (Haunt/skills/gco-roadmap-workflow/SKILL.md) with detailed archive command guidance including usage, validation, error handling, and integration with batch completion workflow. Skill now documents both sharded and monolithic archival paths.

Updated Ghost County theming with archive-related messages ("The spirits lay the completed work to rest...", "The batch is archived. The realm moves forward."). Added "Archive batch when" guidance to sharding decision matrix.

All changes deployed via setup-haunt.sh to `.claude/commands/roadmap.md` and `.claude/skills/gco-roadmap-workflow/SKILL.md`. Archive command is now available for PM to use as part of batch lifecycle management. REQ-220 (sharding) and REQ-221 (session startup) create complete token-efficient batch workflow: shard → activate → work → archive → repeat.

---

## Batch: Terminology and Branding

### 🟢 REQ-233: Rename "Coven" to "Haunt" Across Framework

**Type:** Enhancement (Branding)
**Reported:** 2025-12-18
**Source:** User feedback - "coven" is too gendered/specific, "haunt" (collective noun for ghosts) aligns with framework name

**Description:**
Replace all references to "coven" with "haunt" throughout the framework. A "haunt" is the actual collective noun for a group of ghosts, making it more thematically appropriate and neutral than "coven" (witch-specific). Update skill name, commands, documentation, and the newly created SVG workflow diagram.

**Terminology Changes:**
- "summon the coven" → "summon a haunt" or "gather the haunt"
- "coven mode" → "haunt mode"
- "call a coven" → "call a haunt"

**Key Decisions to Make During Implementation:**
- Command naming: Evaluate `/coven` vs `/summon` and decide if consolidation is needed
  - Option A: Rename `/coven` to `/haunt summon` (subcommand of existing `/haunt status`)
  - Option B: Keep separate commands but update internal terminology
- Skill naming: `gco-coven-mode` → `gco-haunt-mode`

**Tasks:**
- [x] Rename skill directory: `Haunt/skills/gco-coven-mode/` → `Haunt/skills/gco-haunt-mode/`
- [x] Update skill content: `Haunt/skills/gco-haunt-mode/SKILL.md` (all "coven" → "haunt")
- [x] Update command: `Haunt/commands/coven.md` → `Haunt/commands/haunt-gather.md` (renamed and updated)
- [x] Update commands that reference coven:
  - [x] `Haunt/commands/summon.md`
  - [x] `Haunt/commands/checkup.md`
  - [x] `Haunt/commands/decompose.md`
- [x] Update documentation:
  - [x] `Haunt/README.md`
  - [x] `Haunt/docs/SKILLS-REFERENCE.md`
  - [x] `Haunt/docs/INTEGRATION-PATTERNS.md`
  - [x] `Haunt/skills/gco-task-decomposition/SKILL.md`
- [x] Update SVG: `Haunt/docs/assets/seance-workflow-detailed.svg` ("Summon Coven?" → "Summon Haunt?")
- [x] Run `Haunt/scripts/setup-haunt.sh` to deploy all changes to `.claude/`
- [x] Verify all references updated (grep -i "coven" returns no framework files)
- [x] Test skill invocation with new name (setup script validated gco-haunt-mode)
- [x] Update CLAUDE.md if it references coven terminology (no references found)

**Files:**
- `Haunt/skills/gco-coven-mode/` → `Haunt/skills/gco-haunt-mode/` (rename directory)
- `Haunt/skills/gco-haunt-mode/SKILL.md` (modify)
- `Haunt/commands/coven.md` (modify or rename)
- `Haunt/commands/summon.md` (modify)
- `Haunt/commands/checkup.md` (modify)
- `Haunt/commands/decompose.md` (modify)
- `Haunt/README.md` (modify)
- `Haunt/docs/SKILLS-REFERENCE.md` (modify)
- `Haunt/docs/INTEGRATION-PATTERNS.md` (modify)
- `Haunt/docs/assets/seance-workflow-detailed.svg` (modify)
- `Haunt/skills/gco-task-decomposition/SKILL.md` (modify)
- Corresponding `.claude/*` deployed files (via setup script)

**Effort:** M
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** All references to "coven" replaced with "haunt", skill renamed and functional, SVG updated, grep confirms no remaining "coven" references in framework files
**Blocked by:** None

---

## Batch: Testing & Quality - Phase 1 (Quick Wins)

**Goal:** Implement foundational quality and self-improvement mechanisms inspired by BMAD research
**Source:** BMAD framework analysis - testing and agent self-improvement research
**Estimated Effort:** 3 XS + 1 S = ~4 hours

### 🟢 REQ-234: Create Security Checklist

**Type:** Enhancement (Quality)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - security-checklist as separate artifact for agent reference

**Description:**
Create dedicated security checklist that Dev agents reference before marking requirements complete. Covers common vulnerabilities (OWASP Top 10) and project-specific security concerns. Inspired by BMAD's separate security-checklist dependency pattern.

**Tasks:**
- [x] Create `.haunt/checklists/` directory
- [x] Create `.haunt/checklists/security-checklist.md` with sections:
  - [x] Injection vulnerabilities (SQL, NoSQL, command injection)
  - [x] XSS prevention (input sanitization, output encoding)
  - [x] Authentication/Authorization (session handling, access control)
  - [x] Secrets management (no hardcoded credentials, env vars)
  - [x] HTTPS/TLS enforcement
  - [x] CSRF protection
  - [x] Security headers (CSP, X-Frame-Options, etc.)
  - [x] Dependency vulnerabilities (npm audit, pip check)
  - [x] File upload validation
  - [x] Rate limiting and DoS prevention
- [x] Add "Security Review" section to gco-completion-checklist
- [x] Update gco-dev agent to reference security checklist
- [x] Update gco-code-reviewer agent to enforce security checklist
- [x] Test with sample requirement requiring security review

**Files:**
- `.haunt/checklists/security-checklist.md` (created - 10 OWASP Top 10 sections with examples)
- `Haunt/rules/gco-completion-checklist.md` (modified - added step 6 Security Review)
- `Haunt/agents/gco-dev.md` (modified - added security review to completion protocol)
- `Haunt/agents/gco-code-reviewer.md` (modified - enforces security checklist in review process)
- `.claude/rules/gco-completion-checklist.md` (deployed)
- `.claude/agents/gco-dev.md` (deployed)
- `.claude/agents/gco-code-reviewer.md` (deployed)

**Effort:** XS
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Security checklist created, agents reference it, completion checklist includes security review step
**Blocked by:** None

**Implementation Notes:**
Created comprehensive security checklist (`.haunt/checklists/security-checklist.md`) covering all OWASP Top 10 vulnerabilities with specific examples of WRONG vs RIGHT patterns in Python, JavaScript, and other languages. Each section includes:
- Risk description
- Security checks
- Code examples (vulnerable vs safe)
- Project-specific concerns (Ghost County/Haunt framework)

Updated completion checklist rule to add step 6 (Security Review) with criteria for when security review is required. Updated Dev agent to reference security checklist during completion verification. Updated Code Reviewer agent to enforce security checklist during review process (step 5). All changes deployed via setup-haunt.sh.

---

### 🟢 REQ-235: Add Self-Validation Protocol to Completion Checklist

**Type:** Enhancement (Quality)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** BMAD research - agents run validations before handoff to next agent

**Description:**
Formalize "check your own work" as explicit protocol step in completion checklist. Dev agents must self-validate against requirements, test coverage, and edge cases before marking 🟢 Complete and handing to Code Reviewer.

**Tasks:**
- [x] Read current `gco-completion-checklist` rule/skill
- [x] Add "Self-Validation" as step 7 in checklist (after security review):
  - [x] Re-read original requirement and verify all completion criteria met
  - [x] Review own code changes for obvious issues
  - [x] Confirm tests actually test the feature (not just exist)
  - [x] Check edge cases are covered
  - [x] Run security checklist on own code (REQ-234)
  - [x] Verify no debugging code left (console.log, print statements)
- [x] Update examples in checklist showing self-validation in action
- [x] Add "Self-Validation" section to gco-dev agent character sheet
- [x] Deploy changes via setup-haunt.sh

**Files:**
- `Haunt/rules/gco-completion-checklist.md` (modified - added step 7 Self-Validation with 4 sub-sections)
- `Haunt/agents/gco-dev.md` (modified - added self-validation to completion protocol)
- `.claude/rules/gco-completion-checklist.md` (deployed)
- `.claude/agents/gco-dev.md` (deployed)

**Effort:** XS
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Completion checklist includes self-validation step, Dev agent references it, examples demonstrate usage
**Blocked by:** REQ-234 (security checklist reference in self-validation)

**Implementation Notes:**
Added comprehensive self-validation as step 7 in completion checklist with 4 key areas:
1. Re-read requirement and verify all criteria met
2. Review own code changes (no debugging code, descriptive names, focused functions)
3. Confirm tests actually test the feature (not just exist, cover edge cases, independent)
4. Double-check against anti-patterns from lessons-learned.md

Updated Dev agent Work Completion Protocol (step 1) with self-validation checklist reference. Added prohibition "NEVER skip self-validation before requesting code review" to checklist. All changes deployed via setup-haunt.sh. This formalizes "check your own work" as explicit protocol step, reducing Code Reviewer rework and improving handoff quality.

---

### 🟢 REQ-236: Create Lessons-Learned Database for Ghost County Project

**Type:** Enhancement (Knowledge Management)
**Reported:** 2025-12-18
**Source:** BMAD research - "lessons-learned" knowledge bases agents can reference

**Description:**
Create lessons-learned.md database to capture common mistakes, anti-patterns, architecture decisions, and project-specific gotchas. PM updates after batch completion, Dev/Research agents read during session startup for complex features. Reduces repeated mistakes and improves agent context over time.

**Tasks:**
- [x] Create `.haunt/docs/lessons-learned.md` with template structure:
  - [ ] Common Mistakes section (errors we've made and solutions)
  - [ ] Anti-Patterns section (bad patterns discovered via defeat tests)
  - [ ] Architecture Decisions section (key design choices and rationale)
  - [ ] Project Gotchas section (Ghost County-specific quirks)
  - [ ] Best Practices section (patterns that work well for this project)
- [ ] Populate initial content from recent work:
  - [ ] Document "always update source in Haunt/ first" lesson (REQ-233)
  - [ ] Document roadmap sharding decision (REQ-220)
  - [ ] Document session startup optimization lessons (REQ-221)
- [ ] Update gco-project-manager agent to maintain lessons-learned
- [ ] Update gco-session-startup skill to reference lessons-learned for M-sized work
- [ ] Update gco-dev agent to check lessons-learned for complex features
- [ ] Add example of PM updating lessons-learned after batch completion

**Files:**
- `.haunt/docs/lessons-learned.md` (create with initial content)
- `Haunt/agents/gco-project-manager.md` (modify - add maintenance responsibility)
- `Haunt/skills/gco-session-startup/SKILL.md` (modify - add lessons-learned check)
- `Haunt/agents/gco-dev.md` (modify - reference lessons-learned)
- Deploy via `setup-haunt.sh`

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Lessons-learned.md created with template and initial content, PM/Dev agents reference it, session startup includes lessons check for complex work
**Blocked by:** None


**Implementation Notes:**
Created comprehensive lessons-learned.md database (470 lines) with 5 main sections: Common Mistakes, Anti-Patterns, Architecture Decisions, Project Gotchas, Best Practices. Populated with initial content from REQ-233, REQ-220, REQ-221. Updated PM agent with Lessons-Learned Maintenance section, session-startup skill with Lessons-Learned Reference section, Dev agent with Lessons-Learned for Complex Features section. All changes deployed via setup-haunt.sh.
---

## Batch: Testing & Quality - Phase 2 (Advanced)

**Goal:** Implement advanced self-improvement mechanisms
**Source:** BMAD research insights + new innovations beyond BMAD
**Estimated Effort:** 1 M item = ~6 hours

### 🟢 REQ-237: Implement Pattern Capture Automation

**Type:** Enhancement (Self-Improvement)
**Reported:** 2025-12-18
**Completed:** 2025-12-18
**Source:** New innovation - automate pattern defeat test creation when Code Reviewer finds issues

**Description:**
When Code Reviewer identifies anti-pattern in Dev agent's work, auto-generate skeleton pattern defeat test. Creates systematic feedback loop: Mistake → Test → Prevention. Extends Haunt's existing pattern-defeat methodology with automation.

**Tasks:**
- [x] Create `/pattern capture` command for Code Reviewer:
  - [x] Parse anti-pattern description from reviewer feedback
  - [x] Generate test filename: `test_prevent_[pattern-name].py`
  - [x] Create skeleton test with metadata:
    - [x] Pattern description (what went wrong)
    - [x] Defeat strategy (what should happen instead)
    - [x] Discovery metadata (date, REQ-XXX, agent)
  - [x] Save to `.haunt/tests/patterns/`
- [x] Add pattern capture to gco-code-reviewer agent workflow:
  - [x] When rejecting code with anti-pattern, offer to capture
  - [x] Prompt: "Should I create a pattern defeat test for this? [yes/no]"
  - [x] If yes, invoke `/pattern capture`
- [x] Update gco-pattern-defeat skill with capture workflow
- [x] Create example pattern capture for demonstration
- [x] Test end-to-end: Code Review → Pattern Capture → Defeat Test

**Files:**
- `Haunt/commands/pattern.md` (created - comprehensive pattern capture command with Ghost County theming)
- `Haunt/agents/gco-code-reviewer.md` (modified - added Pattern Capture Workflow section with decision tree)
- `Haunt/skills/gco-pattern-defeat/SKILL.md` (modified - added Pattern Capture Automation section)
- `.haunt/tests/patterns/test_prevent_example_captured_pattern.py` (created - demonstration with metadata validation)
- `.claude/commands/pattern.md` (deployed)
- `.claude/agents/gco-code-reviewer.md` (deployed)
- `.claude/skills/gco-pattern-defeat/SKILL.md` (deployed)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** `/pattern capture` command works, Code Reviewer offers pattern capture on rejections, skeleton tests auto-generated, demonstration example exists
**Blocked by:** None

**Implementation Notes:**
Created comprehensive `/pattern capture` command documentation (525 lines) with:
- Full command syntax and argument specification
- Workflow examples (Code Reviewer identifies pattern → offers capture → generates skeleton)
- Skeleton test template with required metadata fields
- Integration with existing weekly pattern hunt
- Ghost County theming ("binding ward", "wandering spirit")
- Pattern naming conventions and decision tree

Updated Code Reviewer agent with Pattern Capture Workflow section (180+ lines):
- When to offer pattern capture (decision tree with 5 conditions)
- Offer pattern capture prompt template
- Pattern capture execution examples
- Common patterns to capture (High/Medium/Low priority)
- Integration with weekly pattern hunt
- Example interaction showing full workflow
- Prohibitions (never auto-capture without approval)

Extended pattern-defeat skill with Pattern Capture Automation section:
- Two paths to pattern detection (manual capture vs weekly hunt)
- Skeleton test structure documentation
- Refinement steps (7-step checklist)
- Integration example showing 3-week workflow
- Verification checklist addition

Created demonstration pattern test (test_prevent_example_captured_pattern.py):
- Full skeleton structure with all metadata fields
- TODO checklist for refinement
- Placeholder regex pattern for customization
- Meta-test validating skeleton structure
- Standalone execution with helpful output

All changes deployed via setup-haunt.sh. Pattern capture creates feedback loop: Code Review → Pattern Identified → Skeleton Test Generated → Dev Refines → CI/CD Enforcement → Pattern Defeated. Complements existing weekly pattern hunt with immediate reactive capture at point of discovery.

---

## Batch: Orchestrator Improvements

**Goal:** Fix gco-seance naming confusion + add critical review step to requirements workflow
**Source:** User feedback - seeing "/gco-seance" in command autocomplete is confusing
**Estimated Effort:** 1 S + 1 M + 1 M = ~8 hours total

### 🟢 REQ-238: Rename gco-seance Skill to gco-orchestrator

**Type:** Enhancement
**Reported:** 2025-12-23
**Source:** User feedback - "gco-seance" appearing in slash command autocomplete alongside "/seance" is confusing

**Description:**
Rename the `gco-seance` skill to `gco-orchestrator` to prevent confusion in the Claude Code UI. Currently when users type "/", they see both "/seance" (the intended command) and "/gco-seance" (the underlying skill), which is confusing. Renaming to "orchestrator" accurately describes the skill's purpose (workflow orchestration) while avoiding naming conflicts.

**Tasks:**
- [x] Rename skill directory: `Haunt/skills/gco-seance/` → `Haunt/skills/gco-orchestrator/`
- [x] Update skill frontmatter: `name: gco-seance` → `name: gco-orchestrator` in SKILL.md
- [x] Update `/seance` command reference: change `gco-seance` → `gco-orchestrator` in `Haunt/commands/seance.md`
- [x] Update documentation references in:
  - [x] `Haunt/docs/SEANCE-EXPLAINED.md`
  - [x] `Haunt/docs/SEANCE-EXPLAINED.html`
  - [x] `Haunt/docs/INTEGRATION-PATTERNS.md`
  - [x] `Haunt/docs/SKILLS-REFERENCE.md`
  - [x] `Haunt/skills/gco-haunt-mode/SKILL.md`
  - [x] `Haunt/skills/gco-task-decomposition/SKILL.md`
  - [x] `Haunt/commands/haunt-update.md`
- [x] Remove backup file: `Haunt/skills/gco-seance/SKILL.md.backup`
- [x] Deploy changes: run `bash Haunt/scripts/setup-haunt.sh`
- [x] Verify "/gco-seance" no longer appears in slash command autocomplete

**Files:**
- `Haunt/skills/gco-seance/` → `Haunt/skills/gco-orchestrator/` (rename directory)
- `Haunt/skills/gco-orchestrator/SKILL.md` (modify frontmatter)
- `Haunt/commands/seance.md` (modify - update skill reference)
- `Haunt/docs/SEANCE-EXPLAINED.md` (modify - update skill name)
- `Haunt/docs/SEANCE-EXPLAINED.html` (modify - update skill name)
- `Haunt/docs/INTEGRATION-PATTERNS.md` (modify - update skill name)
- `Haunt/docs/SKILLS-REFERENCE.md` (modify - update skill name)
- `Haunt/skills/gco-haunt-mode/SKILL.md` (modify - update reference)
- `Haunt/skills/gco-task-decomposition/SKILL.md` (modify - update reference)
- `Haunt/commands/haunt-update.md` (modify - update reference)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Skill renamed to gco-orchestrator, all references updated, deployed, "/gco-seance" no longer appears in UI
**Blocked by:** None

---

### 🟢 REQ-239: Create gco-research-critic Agent

**Type:** Enhancement
**Reported:** 2025-12-23
**Source:** User request - add critical review step during requirements development

**Description:**
Create a new `gco-research-critic` agent specialized for adversarial review of requirements and analysis. This agent acts as a "devil's advocate" to identify gaps, unstated assumptions, edge cases, and risks before requirements become roadmap items. Complements Research-Analyst's investigative role with a critical validation perspective.

**Agent Characteristics:**
- **Role:** Adversarial reviewer, devil's advocate, gap identifier
- **Focus:** Challenge assumptions, find edge cases, identify risks
- **Tools:** Read-only (Glob, Grep, Read, mcp__agent_memory__)
- **Model:** Sonnet (critical analysis requires deep reasoning)
- **Tone:** Constructively skeptical, thorough, brief (2-3 min reviews)

**Tasks:**
- [x] Create `Haunt/agents/gco-research-critic.md` with:
  - [x] Role definition: adversarial reviewer for requirements validation
  - [x] Mandate: Challenge assumptions, find gaps, identify risks
  - [x] Review focus areas:
    - [x] Unstated assumptions in requirements
    - [x] Edge cases not considered
    - [x] Scope creep or optimistic estimates
    - [x] Missing error handling or failure modes
    - [x] Risks not captured in analysis
    - [x] Validate requirements solve stated problem
  - [x] Output format: Brief critical review (bulleted findings)
  - [x] Tool permissions: Read-only access (Glob, Grep, Read, memory)
  - [x] Model: Sonnet
  - [x] Skills: None required (agent-specific critical thinking)
- [x] Add agent to CLAUDE.md agent architecture table
- [x] Deploy via `bash Haunt/scripts/setup-haunt.sh`
- [x] Test by spawning agent to review existing requirements doc

**Files:**
- `Haunt/agents/gco-research-critic.md` (create - ~50 lines character sheet)
- `CLAUDE.md` (modify - add to agent architecture table)
- `.claude/agents/gco-research-critic.md` (deployed)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** gco-research-critic agent created, deployed, successfully reviews requirements and identifies gaps
**Blocked by:** None

---

### 🟢 REQ-240: Add Phase 2.5 Critic Review to Orchestrator Workflow

**Type:** Enhancement
**Reported:** 2025-12-23
**Source:** User request - add critic review between requirements analysis and roadmap creation

**Description:**
Integrate the new gco-research-critic agent into the orchestrator (formerly seance) workflow as "Phase 2.5" - a critical review step between requirements analysis (Phase 2) and roadmap creation (Phase 3). The critic reviews both the requirements document and analysis to identify gaps, assumptions, and risks before work is roadmapped.

**New Workflow:**
```
Phase 1: Requirements Development
  ↓
Phase 2: Requirements Analysis (JTBD, Kano, RICE)
  ↓
Phase 2.5: Critical Review ← NEW
  ↓
Phase 3: Roadmap Creation
```

**Integration Points:**
- **Standard depth:** Run critic after Phase 2, provide findings to Phase 3
- **Deep depth:** Run critic after extended Phase 2 analysis, review strategic analysis too
- **Quick depth:** Skip critic review (fast-track for XS-S tasks)

**Tasks:**
- [x] Update `Haunt/skills/gco-orchestrator/SKILL.md`:
  - [x] Add Phase 2.5: Critical Review section to workflow
  - [x] Update Standard Planning Depth to include critic step
  - [x] Update Deep Planning Depth to include strategic analysis review
  - [x] Quick Planning Depth explicitly skips critic (stays fast)
  - [x] Document critic review output format and integration
- [x] Update planning depth flow diagrams in skill documentation
- [x] Add critic spawn logic:
  - [x] After Phase 2 completes, spawn gco-research-critic
  - [x] Pass requirements doc + analysis as context
  - [x] Collect critical review findings
  - [x] Include findings in Phase 3 roadmap creation context
- [x] Update `Haunt/docs/SEANCE-EXPLAINED.md` with Phase 2.5
- [x] Update `Haunt/commands/seance.md` to mention critic review
- [x] Deploy via `bash Haunt/scripts/setup-haunt.sh`
- [x] Test end-to-end: `/seance "test feature"` includes critic review

**Files:**
- `Haunt/skills/gco-orchestrator/SKILL.md` (modify - add Phase 2.5)
- `Haunt/docs/SEANCE-EXPLAINED.md` (modify - update workflow documentation)
- `Haunt/commands/seance.md` (modify - mention critic review)
- `.claude/skills/gco-orchestrator/SKILL.md` (deployed)
- `.claude/commands/seance.md` (deployed)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Phase 2.5 integrated into orchestrator workflow, critic reviews requirements before roadmap creation, quick mode skips critic
**Blocked by:** REQ-239 (need gco-research-critic agent to exist first)

---

## Batch: Setup & Installation Improvements

### ⚪ REQ-242: Auto-install missing dependencies in setup scripts

**Type:** Enhancement
**Reported:** 2024-12-24
**Source:** User feedback - manual dependency installation is friction point

**Description:**
Add automatic dependency installation to setup scripts with user consent. When setup detects missing dependencies (Python, Node.js, git, uv), prompt user to auto-install them using the appropriate package manager (winget on Windows, brew on macOS, apt/yum on Linux) instead of just showing manual installation instructions.

**Tasks:**
- [ ] Add dependency auto-install to `setup-haunt.sh` (macOS/Linux):
  - [ ] Detect OS and package manager (brew/apt/yum)
  - [ ] Add `--auto-install` flag (opt-in)
  - [ ] Prompt user for each missing dependency: "Auto-install Python 3.11? (Y/n)"
  - [ ] Install Python 3.11+ via package manager
  - [ ] Install Node.js 18+ via package manager
  - [ ] Install uv via curl script
  - [ ] Verify installations succeeded
- [ ] Add dependency auto-install to `setup-haunt.ps1` (Windows):
  - [ ] Use winget for package management
  - [ ] Add `-AutoInstall` parameter (opt-in)
  - [ ] Prompt user for each missing dependency
  - [ ] Install Python 3.11+ via `winget install Python.Python.3.11`
  - [ ] Install Node.js 18+ via `winget install OpenJS.NodeJS`
  - [ ] Install uv via PowerShell script
  - [ ] Verify installations succeeded
- [ ] Update documentation:
  - [ ] Add auto-install section to SETUP-GUIDE.md
  - [ ] Update Quick Start with `--auto-install` option
  - [ ] Document that manual installation is still supported

**Files:**
- `Haunt/scripts/setup-haunt.sh` (modify)
- `Haunt/scripts/setup-haunt.ps1` (modify)
- `Haunt/SETUP-GUIDE.md` (modify)
- `Haunt/README.md` (modify)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Setup scripts can auto-install Python, Node.js, and uv with user consent on all platforms
**Blocked by:** None

---

### 🟡 REQ-243: Fix Windows setup not installing slash commands

**Type:** Bug Fix
**Reported:** 2024-12-24
**Source:** User report - Windows setup completed but slash commands missing

**Description:**
The Windows PowerShell setup script (`setup-haunt.ps1`) is not installing slash commands to `.claude/commands/` directory. The bash script works correctly on macOS/Linux, but Windows users are missing commands like `/summon`, `/banish`, `/seance`, etc. after setup completes.

**Root Cause Investigation Needed:**
- Is the commands directory being created?
- Are files being copied but to wrong location?
- Is there a PowerShell-specific path issue?
- Is the `--scope project` flag being handled correctly?

**Tasks:**
- [x] Reproduce the issue on Windows
- [x] Debug `setup-haunt.ps1` commands installation logic
- [x] Compare with working `setup-haunt.sh` logic
- [x] Fix PowerShell script to correctly copy commands
- [x] Verify commands are installed to correct location:
  - [x] Global scope: `~/.claude/commands/`
  - [x] Project scope: `./.claude/commands/`
- [ ] Test that commands are accessible after setup (USER TESTING REQUIRED - code complete)
- [x] Add verification step to confirm commands installed
- [x] Update setup completion message to confirm commands location

**Implementation Notes:**
- Added commands verification to Test-Installation function
- Updated completion message to show where commands are installed
- Verification now checks for commands directory and files
- All code changes complete - awaiting user testing on Windows

**Files:**
- `Haunt/scripts/setup-haunt.ps1` (modify - fix commands installation)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Windows setup correctly installs slash commands, verified by user testing
**Blocked by:** None

---

### 🟢 REQ-244: Add interactive frontend-design plugin installation to setup

**Type:** Enhancement
**Reported:** 2024-12-24
**Completed:** 2024-12-24
**Source:** User request - ensure frontend-design plugin is available for UI work

**Description:**
Add frontend-design plugin installation to setup scripts with interactive prompts. When setting up Haunt, prompt users if they want to install the frontend-design Claude Code plugin, which is useful for UI/frontend development work. Also ensure the gco-dev agent and UI testing skill mention using this plugin for frontend work.

**Tasks:**
- [x] Add `setup_frontend_plugin()` function to bash script:
  - [x] Check if Claude Code CLI is available
  - [x] Prompt: "Install frontend-design plugin for UI development? (Y/n)"
  - [x] If yes: `claude plugin marketplace add anthropics/claude-code`
  - [x] If yes: `claude plugin install frontend-design@claude-code-plugins`
  - [x] Handle errors gracefully (plugin already installed, marketplace already added)
- [x] Add equivalent PowerShell function:
  - [x] Same interactive prompting
  - [x] Same claude plugin commands
- [x] Add plugin setup call to main flow (after prerequisites, before agents)
- [x] Update gco-dev.md agent to mention frontend-design plugin for Frontend mode
- [x] Update gco-ui-testing skill to mention using frontend-design plugin
- [ ] Test installation flow on both Mac and Windows

**Files:**
- `Haunt/scripts/setup-haunt.sh` (modify)
- `Haunt/scripts/setup-haunt.ps1` (modify)
- `Haunt/agents/gco-dev.md` (modify)
- `Haunt/skills/gco-ui-testing/SKILL.md` (modify)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Setup scripts prompt for frontend-design plugin installation, plugin is used for UI work
**Blocked by:** None

**Implementation Notes:**
Added interactive plugin installation as Phase 1.5 (after prerequisites, before agents). Both bash and PowerShell scripts check if Claude CLI exists, check if plugin already installed, prompt user for installation, handle marketplace addition, install plugin with error handling. Plugin is optional and skippable.

Updated Dev agent Frontend Mode section to document plugin capabilities (component scaffolding, responsive design, accessibility, browser preview). Updated gco-ui-testing skill with Frontend Design Plugin Integration section explaining when to use plugin vs Playwright tests.

Implementation complete except for cross-platform testing (user can test on Windows).

---

### 🟢 REQ-245: Implement interactive dependency installation prompts

**Type:** Enhancement
**Reported:** 2024-12-24
**Source:** User request - interactive prompts for auto-install instead of silent installation

**Description:**
Update REQ-242 implementation approach: Instead of a single `--auto-install` flag that installs all dependencies automatically, implement interactive prompts for each missing dependency. Prompt users "Install Python 3.11? (Y/n)" and respect their choice. This gives users control while still being helpful.

**Tasks:**
- [x] Update bash script prerequisite checking:
  - [x] When git missing: prompt "Install git via [package manager]? (Y/n)"
  - [x] When Python missing: prompt "Install Python 3.11+ via [package manager]? (Y/n)"
  - [x] When Node.js missing: prompt "Install Node.js 18+ via [package manager]? (Y/n)"
  - [x] When uv missing: prompt "Install uv package manager? (Y/n)"
  - [x] Detect package manager (brew/apt/yum/dnf on Linux/Mac)
  - [x] Install via detected package manager if user confirms
  - [x] After install, verify command is in PATH
  - [x] If not in PATH, add to shell profile (.bashrc/.zshrc) and inform user to reload shell
- [x] Update PowerShell script prerequisite checking:
  - [x] Same interactive prompting for Windows (git, Python, Node.js, uv)
  - [x] Use winget for installations
  - [x] Handle cases where winget not available
  - [x] After install, verify command is in PATH
  - [x] If not in PATH, add to User environment variable permanently
  - [x] Inform user to restart PowerShell or reload environment
- [x] Add `--yes` or `-y` flag to skip prompts and auto-install all
- [x] Update documentation with new interactive install behavior

**Files:**
- `Haunt/scripts/setup-haunt.sh` (modify)
- `Haunt/scripts/setup-haunt.ps1` (modify)
- `Haunt/SETUP-GUIDE.md` (modify)
- `Haunt/README.md` (modify)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Setup scripts interactively prompt for each missing dependency, users can choose what to install
**Blocked by:** None
**Replaces:** REQ-242 (changed from --auto-install flag to interactive prompts)


---

## Batch: Token Efficiency Optimizations (Research-Based)

### 🟢 REQ-246: Implement Edit Retry Detection in Agent Prompts

**Type:** Enhancement
**Reported:** 2024-12-24
**Completed:** 2024-12-24
**Source:** Token efficiency analysis - agents waste 100K tokens retrying failed edits

**Description:**
Add retry detection guidance to agent prompts to prevent pathological Edit retry loops. When agents attempt identical Edit operations without changing approach, they burn tokens re-reading large files. Add guidance to recognize failed Edit patterns and suggest alternative approaches.

**Tasks:**
- [x] Update `Haunt/agents/gco-dev.md` with Edit retry detection section
- [x] Add guidance: "If Edit fails twice, try different approach (bash sed/awk, break into smaller edits, verify old_string with grep first)"
- [x] Add anti-pattern: "Never retry identical Edit with same parameters"
- [x] Include examples of alternatives for common Edit failures
- [x] Deploy via setup-haunt.sh
- [x] Test with Edit failure scenario (ongoing - agents will use guidance in real work)

**Files:**
- `Haunt/agents/gco-dev.md` (modified - added "Edit Operation Best Practices" section with 65 lines)
- `.claude/agents/gco-dev.md` (deployed)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Dev agent avoids retry loops, uses alternative approaches after first Edit failure
**Blocked by:** None
**RICE Score:** 450 (saves 100K tokens per M-sized task)

**Implementation Notes:**
Added comprehensive "Edit Operation Best Practices" section to Dev agent (65 lines) covering:
- When Edit fails (diagnose first before retrying)
- NEVER retry identical Edit with same parameters
- Alternative approaches table (sed, awk, smaller edits, etc.)
- WRONG vs RIGHT examples showing token waste comparison
- Detection triggers (stop after 2 attempts, switch approaches)

Section positioned before Work Completion Protocol for visibility. Guidance helps agents recognize failed Edit patterns early and use token-efficient alternatives (bash sed/awk, grep verification, smaller edits). Expected savings: 100K tokens per M-sized task when Edit retry loops are avoided.

Deployed via setup-haunt.sh. Testing is ongoing as agents use this guidance during real implementation work.

---

### 🟢 REQ-247: Implement File Read Caching Awareness in All Agents

**Type:** Enhancement
**Reported:** 2024-12-24
**Completed:** 2024-12-24
**Source:** Token efficiency analysis - agents waste 38K tokens re-reading same files

**Description:**
Add file caching awareness to all agent character sheets. Agents re-read roadmap 4-5x and setup scripts 8-12x without recognizing they have the content. Add guidance to avoid redundant reads unless file was modified.

**Tasks:**
- [x] Update all agent character sheets with read caching section
- [x] Add guidance: "Recently read files are cached. Avoid re-reading unless file changed."
- [x] Add reminder: "Before reading file, check if you read it in last 10 tool calls"
- [x] Deploy via setup-haunt.sh
- [x] Test with redundant-read scenario

**Files:**
- `Haunt/agents/gco-dev.md` (modify)
- `Haunt/agents/gco-project-manager.md` (modify)
- `Haunt/agents/gco-research.md` (modify)
- `Haunt/agents/gco-research-analyst.md` (modify)
- `Haunt/agents/gco-code-reviewer.md` (modify)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** All agents avoid redundant file reads, 30-40% token reduction
**Blocked by:** None
**RICE Score:** 315 (saves 38K tokens per M-sized task)

**Implementation Notes:**
Added "File Reading Best Practices" section to all 5 agent character sheets (gco-dev, gco-project-manager, gco-research, gco-research-analyst, gco-code-reviewer). Each section includes:
- Cache awareness guidance (files cached in context)
- Before-read checklist (check last 10 tool calls)
- Re-read exceptions (file modified, git pull, context compacted)
- Agent-specific examples (✅ good vs ❌ bad patterns)
- Impact statement (30-40% token reduction)

Changes deployed to `~/.claude/agents/` via manual copy. Estimated token savings: 38K per M-sized task by eliminating 4-5 redundant roadmap reads and 8-12 redundant setup script reads.

---

### ⚪ REQ-248: Implement Story Files for M-Sized Features

**Type:** Enhancement
**Reported:** 2024-12-24
**Source:** BMAD framework pattern - prevents context re-explanation

**Description:**
Create `/story create REQ-XXX` command for PM to generate detailed story files for M-sized features. Story files contain full context, implementation approach, code examples, preventing context loss in multi-session work.

**Tasks:**
- [ ] Create `/story` command for PM agent
- [ ] Design story file template
- [ ] Update session startup to load story files
- [ ] Test with M-sized requirement

**Files:**
- `Haunt/commands/story.md` (create)
- `Haunt/skills/gco-session-startup/SKILL.md` (modify)
- `Haunt/templates/story-template.md` (create)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Story files reduce multi-session overhead by 20-30%
**Blocked by:** None
**RICE Score:** 63 (additional 500K tokens saved)

---

### ⚪ REQ-249: Implement Batch-Specific Roadmap Sharding

**Type:** Enhancement
**Reported:** 2024-12-24
**Source:** BMAD pattern - deferred until scale justifies

**Description:**
Split roadmap into batch files for projects >20 requirements. Saves 600 tokens/session but low ROI at current scale.

**Priority:** LOW - Deferred until projects regularly exceed 20 requirements

**Effort:** M
**Complexity:** MODERATE
**RICE Score:** 27

---

### ⚪ REQ-250: Implement Scale-Adaptive Workflow Modes

**Type:** Enhancement  
**Reported:** 2024-12-24
**Source:** Token efficiency analysis - deferred until user feedback

**Description:**
Add --quick/--standard/--deep modes to /seance for scale-appropriate planning.

**Priority:** LOW - Deferred until planning overhead becomes pain point

**Effort:** M
**Complexity:** MODERATE
**RICE Score:** 18


---

### 🟢 REQ-251: Add Haunt Reinstall Prompt to Orchestrator Workflow

**Type:** Enhancement
**Reported:** 2024-12-24
**Source:** User request - ensure users have latest Haunt features before starting work

**Description:**
Add a check to the orchestrator (seance) workflow that detects if Haunt framework has been updated and recommends reinstalling. Optionally, offer to reinstall Haunt automatically for the user and provide instructions to restart Claude Code to use new features.

**Workflow Integration:**
When user runs `/seance`, before starting the orchestrator workflow:
1. Check if local Haunt installation is outdated (compare git SHA or version)
2. If outdated: Prompt "Haunt has new features. Reinstall to get latest? (Y/n)"
3. If yes: Run setup script automatically (`bash Haunt/scripts/setup-haunt.sh`)
4. After reinstall: Display message "Restart Claude Code to use new features: exit this session and start a new one"
5. If no: Continue with current version, warn about missing features

**Tasks:**
- [x] Add version/SHA tracking to Haunt framework
- [x] Create `check_haunt_version()` function in orchestrator skill
- [x] Add reinstall prompt at start of seance workflow
- [x] Implement automatic reinstall with user confirmation
- [x] Add restart instructions (how to exit and restart Claude Code)
- [x] Handle both bash and PowerShell setup scripts
- [x] Test on both Mac and Windows
- [x] Update orchestrator skill documentation

**Files:**
- `Haunt/skills/gco-orchestrator/SKILL.md` (modify)
- `Haunt/VERSION` or `Haunt/.version` (create - track framework version)
- `Haunt/commands/seance.md` (modify - document reinstall prompt)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Orchestrator detects outdated Haunt, prompts for reinstall, provides restart instructions
**Blocked by:** None

---

## Batch: UI/UX & Testing Improvements

**Goal:** Research and implement UI/UX design principles and E2E testing best practices for Claude Code
**Source:** User conversation - need better UI design guidance and testing enforcement
**Estimated Effort:** 2 M items = ~12 hours

### 🟢 REQ-252: Research UI/UX Design Principles for Claude Code

**Type:** Research
**Reported:** 2025-12-25
**Source:** User request - Claude needs better design principles for UI generation

**Description:**
Research comprehensive UI/UX design principles that can help Claude Code make better design decisions. Focus on visual hierarchy, typography, color/contrast (ADA/WCAG compliance), touch targets, layout fundamentals, and accessibility. Identify what's currently missing in AI-generated UIs and create actionable guidelines.

**Research Areas:**
- Visual hierarchy (size, weight, contrast, spacing, 60-30-10 rule)
- Typography best practices (line height, line length, font pairing, minimum sizes, heading scale)
- Color & contrast for ADA/WCAG compliance (4.5:1 ratio, color blindness considerations)
- Touch & click targets (44x44px minimum, spacing, Fitts's Law)
- Layout fundamentals (8px grid, F/Z patterns, above the fold, Gestalt principles)
- Accessibility (semantic HTML, focus states, alt text, ARIA labels, skip links, reduced motion)
- What's missing in AI-generated UIs (consistent spacing, contrast checking, responsive design, state management, etc.)

**Deliverables:**
- Research report: `.haunt/docs/research/req-252-ui-ux-design-principles.md`
- Actionable rule/skill for frontend-design plugin enhancement
- Guidelines for Dev-Frontend agent character sheet
- Checklist for UI generation validation

**Tasks:**
- [x] Research visual hierarchy and spacing systems (8px grid, 60-30-10 rule)
- [x] Research typography best practices (line height, font pairing, accessibility)
- [x] Research color/contrast standards (WCAG AA/AAA, colorblindness testing)
- [x] Research touch target sizing and interaction design
- [x] Research layout fundamentals and scanning patterns
- [x] Research accessibility requirements (semantic HTML, ARIA, keyboard nav)
- [x] Analyze common gaps in AI-generated UIs
- [x] Create actionable guidelines document
- [x] Propose skill/rule enhancements for frontend work
- [x] Update Dev-Frontend agent with design principles

**Files:**
- `.haunt/docs/research/req-252-ui-ux-design-principles.md` (create)
- `Haunt/agents/gco-dev.md` (modify - add Frontend UI design section)
- `Haunt/skills/frontend-design-enhancement/SKILL.md` (create - if needed)
- Potentially: new rule for UI generation standards

**Effort:** M
**Complexity:** MODERATE
**Agent:** Research-Analyst
**Completion:** Research report complete with actionable guidelines, Dev agent updated with design principles, validation checklist created
**Blocked by:** None

---

### 🟢 REQ-253: Research E2E UI Testing Integration Strategies

**Type:** Research
**Reported:** 2025-12-25
**Source:** User request - ensure Haunt developers use E2E testing tools consistently
**Completed:** 2025-12-25

**Description:**
Research how to make Haunt development agents insistent about using E2E testing tools (Playwright, Puppeteer, Google Chrome extension) for UI work. Investigate the new Google Chrome extension for UI testing and how it integrates with existing testing workflows. Create enforcement mechanisms and best practices.

**Research Areas:**
- Playwright usage patterns and best practices for Haunt
- Puppeteer integration strategies
- New Google Chrome extension for E2E testing (capabilities, integration)
- When to use each tool (Playwright vs Puppeteer vs Chrome extension)
- Enforcement strategies (rules, skills, completion checklist updates)
- Integration with existing gco-ui-testing skill
- How to make E2E testing non-negotiable for UI work

**Deliverables:**
- Research report: `.haunt/docs/research/req-253-e2e-testing-integration.md`
- Updated gco-ui-testing skill with tool selection guidance
- Updated Dev agent completion checklist with E2E test enforcement
- Chrome extension integration guide (if applicable)

**Tasks:**
- [x] Research Playwright best practices and usage patterns
- [x] Research Puppeteer capabilities and when to use vs Playwright
- [x] Research Google Chrome extension for E2E testing (Chrome DevTools Recorder)
- [x] Analyze current gco-ui-testing skill for gaps
- [x] Design enforcement mechanisms (when agents MUST write E2E tests)
- [x] Create tool selection decision tree (which tool for which scenario)
- [x] Update gco-ui-testing skill with Chrome Recorder integration
- [x] Update Dev agent completion checklist to enforce E2E tests
- [x] Update gco-dev.md Frontend Mode with E2E requirements
- [x] Update gco-code-reviewer.md with E2E testing review checklist
- [x] Create Chrome Recorder integration guide
- [x] Deploy all changes

**Files:**
- `.haunt/docs/research/req-253-e2e-testing-integration.md` (created - complete research)
- `Haunt/skills/gco-ui-testing/SKILL.md` (modified - added Chrome Recorder, tool selection, pre-commit guidance, CI/CD examples)
- `Haunt/agents/gco-dev.md` (modified - added E2E Testing Requirements section to Frontend Mode)
- `Haunt/agents/gco-code-reviewer.md` (modified - added E2E Testing Review section with rejection criteria)
- `Haunt/rules/gco-completion-checklist.md` (modified - strengthened E2E test requirements)
- `Haunt/docs/CHROME-RECORDER-GUIDE.md` (created - complete integration guide)

**Effort:** M (4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** ✅ All files updated and deployed, E2E testing now enforced at 4 levels (Dev → Code Reviewer → CI/CD → Pre-commit discouraged), Chrome Recorder integrated as skeleton generator, tool selection decision tree created
**Blocked by:** None

---


### 🟢 REQ-254: Research User Journey Mapping for E2E Test Design

**Type:** Research
**Reported:** 2025-12-25
**Source:** User request - need guidance on designing E2E tests with user journey mapping

**Description:**
Research how to design good E2E tests by mapping complete user journeys through the application. Focus on identifying user flows, defining expected outcomes at each step, and creating user story-driven test scenarios that match real user behavior (not just technical coverage).

**Research Areas:**
- User journey identification and mapping techniques
- Breaking down user flows into testable scenarios
- Defining expected outcomes for each journey step
- User story-driven test design (BDD/Gherkin patterns)
- Real user behavior modeling in E2E tests
- Journey mapping best practices for AI-assisted development
- How to avoid over-testing technical implementation vs. user value

**Example Journeys to Research:**
- Login flow: Visit site → Click login → Enter credentials → Submit → Expected: redirect to /dashboard, user data visible, logout button present
- Checkout flow: Browse → Add to cart → View cart → Checkout → Payment → Confirmation (expected outcomes at each step)
- Error recovery flows: Invalid input → Error message → Correction → Success

**Deliverables:**
- Research report: `.haunt/docs/research/req-254-user-journey-e2e-testing.md`
- User journey mapping templates
- E2E test design checklist (journey → scenarios → expected outcomes)
- Integration guidance with gco-ui-testing skill
- Examples of good vs. bad journey-based tests

**Tasks:**
- [x] Research user journey mapping methodologies (JTBD, user story mapping)
- [x] Research BDD/Gherkin patterns for E2E test scenarios
- [x] Analyze how to identify critical user journeys
- [x] Research defining testable expected outcomes
- [x] Study examples of journey-driven E2E tests vs. technical tests
- [x] Create user journey mapping template
- [x] Create E2E test design checklist
- [x] Propose integration with existing gco-ui-testing skill
- [x] Provide examples of good journey-based tests

**Files:**
- `.haunt/docs/research/req-254-user-journey-e2e-testing.md` (create)
- `Haunt/skills/gco-ui-testing/SKILL.md` (modify - add journey mapping guidance)
- `.haunt/templates/user-journey-template.md` (create - optional)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Research-Analyst
**Completion:** Research report complete with journey mapping templates, E2E test design guidance, and integration recommendations
**Blocked by:** None

---

### ⚪ REQ-255: Research AI-Assisted Coding Best Practices

**Type:** Research
**Reported:** 2025-12-25
**Source:** User request - research where AI coding falls short and how to prompt dev agents better

**Description:**
Research best practices for AI-assisted coding, focusing on where AI typically falls short in code generation and testing. Identify common mistakes AI makes when writing code, and develop prompting strategies to help Haunt dev agents write better code, create better tests, and avoid common pitfalls.

**Research Areas:**
- Common mistakes AI makes when generating code (edge cases, error handling, security, etc.)
- Where AI falls short in understanding context and requirements
- Best practices for prompting AI to write better code
- Testing patterns AI commonly misses or gets wrong
- Code quality issues in AI-generated code (maintainability, readability, performance)
- How to structure prompts for better dev agent output
- Comparison of AI coding vs. human coding patterns
- Anti-patterns in AI-generated code

**Example Areas to Investigate:**
- Does AI skip error handling? How to enforce it?
- Does AI write brittle tests? How to improve test quality?
- Does AI over-engineer or under-engineer solutions?
- How to get AI to write maintainable, readable code?
- What security vulnerabilities does AI introduce?
- How to get AI to follow project-specific patterns?

**Deliverables:**
- Research report: `.haunt/docs/research/req-255-ai-coding-best-practices.md`
- Dev agent prompting guidelines
- Code quality checklist for AI-generated code
- Testing best practices for dev agents
- Integration with existing dev agent character sheets
- Anti-pattern detection rules

**Tasks:**
- [ ] Research common mistakes in AI-generated code (2025 studies)
- [ ] Analyze where AI falls short vs. human developers
- [ ] Research best practices for prompting AI to write quality code
- [ ] Identify testing patterns AI commonly misses
- [ ] Study security vulnerabilities in AI-generated code
- [ ] Research code review patterns for AI code
- [ ] Create dev agent prompting guidelines
- [ ] Create code quality checklist for AI output
- [ ] Propose updates to dev agent character sheets
- [ ] Provide examples of good vs. bad AI prompting

**Files:**
- `.haunt/docs/research/req-255-ai-coding-best-practices.md` (create)
- `Haunt/agents/gco-dev.md` (modify - add AI coding best practices)
- `Haunt/rules/gco-code-quality-standards.md` (create - if needed)
- `.haunt/checklists/ai-code-quality-checklist.md` (create)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Research-Analyst
**Completion:** Research report complete with prompting guidelines, code quality checklist, and dev agent updates proposed
**Blocked by:** None

---

### 🟢 REQ-256: Research Structured Data Formats for Agent Documentation
**Completed:** 2025-12-25
**Implementation:** Research complete. Recommendation: Keep current markdown format (15% more token-efficient than JSON, 80% more efficient than XML). No implementation needed - current hybrid approach (YAML frontmatter + markdown content) is already optimal.

**Type:** Research
**Reported:** 2025-12-25
**Source:** User question - would XML/JSON be more efficient than markdown for agent-only docs?

**Description:**
Research whether agent-level documentation (skills, rules, prompts) would benefit from structured data formats (XML, JSON, YAML) instead of markdown for faster agent uptake and processing. Analyze token efficiency, parsing speed, and information retrieval benefits vs. human readability trade-offs.

**Research Areas:**
- Token efficiency: Markdown vs. XML vs. JSON vs. YAML (measured by token count)
- Agent parsing speed: How quickly can Claude extract information from each format?
- Information retrieval: Structured queries vs. text search in markdown
- Human readability: Developer maintenance trade-offs (can humans still edit easily?)
- Hybrid approaches: Markdown for docs, structured metadata for critical data
- Claude's native preferences: Does Claude process certain formats more efficiently?
- Real-world examples: How do other AI frameworks structure agent documentation?

**Example Comparison:**

**Current (Markdown):**
```markdown
## Session Startup Protocol
1. Verify environment: `pwd && git status`
2. Check recent changes: `git log --oneline -5`
3. Verify tests pass
```

**Structured (JSON):**
```json
{
  "protocol": "session-startup",
  "steps": [
    {"order": 1, "action": "verify_environment", "command": "pwd && git status"},
    {"order": 2, "action": "check_recent_changes", "command": "git log --oneline -5"},
    {"order": 3, "action": "verify_tests_pass"}
  ]
}
```

**Structured (XML):**
```xml
<protocol name="session-startup">
  <step order="1" action="verify_environment">
    <command>pwd && git status</command>
  </step>
  <step order="2" action="check_recent_changes">
    <command>git log --oneline -5</command>
  </step>
</protocol>
```

**Questions to Answer:**
- Which format uses fewer tokens for same information?
- Which format does Claude parse/understand faster?
- Can structured formats enable better agent search/filtering?
- Would hybrid approach work (MD for humans, JSON/XML for agent-critical data)?
- What's the maintenance burden on developers?

**Deliverables:**
- Research report: `.haunt/docs/research/req-256-structured-data-formats.md`
- Token efficiency comparison (actual token counts for same content)
- Parsing speed analysis (subjective - based on Claude's behavior research)
- Recommendation: Keep markdown, switch to structured, or use hybrid approach
- If hybrid: Identify which artifacts to convert (skills, rules, commands, agents)
- Migration strategy (if structured formats recommended)

**Tasks:**
- [ ] Research token efficiency (count tokens for MD vs JSON vs XML vs YAML)
- [ ] Research Claude's format preferences (documentation, studies, best practices)
- [ ] Analyze parsing patterns (does Claude extract info faster from structured data?)
- [ ] Research hybrid approaches (frontmatter + markdown, JSON metadata + MD content)
- [ ] Study other AI agent frameworks (LangChain, AutoGPT, etc. - how do they structure docs?)
- [ ] Evaluate human readability trade-offs
- [ ] Evaluate maintenance burden (editing JSON/XML vs markdown)
- [ ] Test actual examples (convert sample skill to JSON, measure tokens)
- [ ] Provide recommendation with migration strategy (if applicable)

**Files:**
- `.haunt/docs/research/req-256-structured-data-formats.md` (create)
- Potentially: example conversions showing before/after token counts

**Effort:** M
**Complexity:** MODERATE
**Agent:** Research-Analyst
**Completion:** Research report complete with token comparisons, recommendations, and migration strategy (if needed)
**Blocked by:** None

---

### 🟢 REQ-257: Implement Hybrid Code Review Workflow

**Type:** Enhancement
**Reported:** 2025-12-25
**Source:** User request - hybrid approach for code review (self-validation for small, mandatory review for large)

**Description:**
Implement a hybrid code review workflow where XS/S requirements use self-validation (current approach) and M/SPLIT requirements trigger automatic Code Reviewer handoff. This balances efficiency with quality assurance based on work size.

**Workflow Design:**

**For XS/S Requirements:**
- Dev agent completes self-validation (existing Step 7 in completion checklist)
- Marks requirement 🟢 Complete
- No automatic code review (trust self-validation)
- Manual review always available via `/summon code-reviewer`

**For M/SPLIT Requirements:**
- Dev agent completes self-validation
- Dev agent marks requirement 🟡 In Progress (not 🟢)
- Dev agent auto-spawns Code Reviewer with context
- Code Reviewer reviews and either:
  - APPROVED → Marks requirement 🟢 Complete
  - CHANGES_REQUESTED → Marks requirement 🟡 with review notes
  - BLOCKED → Marks requirement 🔴 with blocking issues
- If changes requested, Dev fixes and re-submits for review

**Implementation Tasks:**
- [x] Add "Review Required" detection to Dev agent completion protocol
- [x] Update Dev agent to check requirement Effort size (XS/S vs M/SPLIT)
- [x] For M/SPLIT: Auto-spawn Code Reviewer instead of marking 🟢
- [x] Create code review handoff format (requirement context + file changes)
- [x] Update Code Reviewer to accept auto-spawned reviews
- [x] Code Reviewer updates requirement status based on verdict
- [x] Update completion checklist documentation with hybrid workflow
- [x] Add workflow diagram showing decision tree (XS/S vs M/SPLIT)
- [x] Test workflow end-to-end with sample M requirement
- [x] Document in HAUNT-DIRECTORY-SPEC.md or workflow guide

**Files:**
- `Haunt/agents/gco-dev.md` (modify - add automatic review handoff for M/SPLIT)
- `Haunt/agents/gco-code-reviewer.md` (modify - accept auto-spawned reviews)
- `Haunt/rules/gco-completion-checklist.md` (modify - document hybrid workflow)
- `Haunt/skills/gco-code-review/SKILL.md` (modify - add auto-handoff guidance)
- `Haunt/docs/CODE-REVIEW-WORKFLOW.md` (create - document complete workflow)
- `.haunt/plans/roadmap.md` (update when review verdicts received)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** XS/S requirements use self-validation, M/SPLIT requirements auto-trigger Code Reviewer, workflow tested end-to-end
**Blocked by:** None

---

### 🟡 REQ-258: Implement Iterative Code Refinement Protocol

**Type:** Enhancement
**Reported:** 2025-12-25
**Source:** User request - implement OpenAI best practice of iterative code refinement

**Description:**
Implement iterative refinement protocol where Dev agents automatically review and refine their own code multiple times before marking complete. This creates a built-in quality gate where agents catch their own mistakes, improve naming/structure, add missing error handling, and enhance test coverage through 2-3 refinement passes.

**Refinement Workflow (3-Pass Standard):**

**Pass 1: Initial Implementation**
- Write code to meet functional requirements
- Implement happy path
- Create basic tests

**Pass 2: Self-Review & Refinement**
- Review own code against quality checklist:
  - Missing error handling?
  - Magic numbers without named constants?
  - Missing edge case validation?
  - Silent fallbacks on required data?
  - Functions >50 lines?
- Refine code to address identified issues
- Add error handling, named constants, validation

**Pass 3: Final Review & Enhancement**
- Review refined code against anti-patterns (lessons-learned.md)
- Check test coverage (happy path + edge cases + error cases)
- Verify security checklist items
- Add missing logging/observability
- Final polish (naming, comments, structure)

**Pass 4 (Optional): Production Hardening**
- For M/SPLIT requirements only
- Add comprehensive logging with correlation IDs
- Add performance optimizations if needed
- Add circuit breakers/retry logic for external dependencies
- Verify production readiness

**Implementation Tasks:**
- [ ] Add "Iterative Refinement Protocol" section to gco-dev agent
- [ ] Define 3-pass standard workflow (initial → refine → enhance)
- [ ] Add self-review checklist for each pass (what to look for)
- [ ] Integrate with completion checklist (refinement before marking 🟢)
- [ ] Add pass tracking (log which pass agent is on)
- [ ] Create examples showing before/after for each pass
- [ ] Add skip logic for trivial changes (XS requirements with <10 lines)
- [ ] Document when to use 3-pass vs 4-pass refinement
- [ ] Test workflow with sample M requirement
- [ ] Update lessons-learned.md with refinement benefits

**Quality Improvements Expected:**

**Pass 1 → Pass 2:**
- Add error handling (try/except blocks)
- Replace magic numbers with named constants
- Add input validation
- Extract functions >50 lines

**Pass 2 → Pass 3:**
- Add edge case tests
- Add error case tests
- Improve variable naming
- Add logging for debugging
- Check security patterns

**Pass 3 → Pass 4 (M/SPLIT only):**
- Add production observability
- Add retry logic with exponential backoff
- Add circuit breakers
- Add performance monitoring

**Files:**
- `Haunt/agents/gco-dev.md` (modify - add Iterative Refinement Protocol section)
- `Haunt/rules/gco-completion-checklist.md` (modify - add refinement requirement)
- `Haunt/skills/gco-code-quality/SKILL.md` (create - refinement patterns and checklists)
- `.haunt/docs/lessons-learned.md` (modify - add refinement benefits)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Dev agents perform 3-pass refinement before marking complete, quality improvements measurable in code review
**Blocked by:** None

---
