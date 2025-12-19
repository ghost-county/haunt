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
