# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` and `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` for completed work.

---

## Current Focus: BMAD-Inspired Enhancements

**Goal:** Implement 5 strategic framework enhancements (token efficiency, workflow flexibility, coordination visibility) while maintaining lightweight philosophy.

**Active Work:**
- None (all requirements ⚪ Not Started, ready for assignment)

**Recently Completed:**
- REQ-242, REQ-248, REQ-249, REQ-250 (Dependency auto-install, story files, sharding, workflow modes)
- REQ-255 (AI coding best practices research)
- REQ-256, REQ-257, REQ-258 (Testing enforcement batch)
- See `.haunt/completed/roadmap-archive.md` for full archive

---

## Batch: Command Improvements

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

## Batch: BMAD Enhancements - Phase 1 (Quick Wins)

**Goal:** Improve onboarding and PM coordination with low-risk documentation and tooling enhancements
**Source:** `.haunt/docs/research/bmad-framework-analysis.md` (REQ-209 research)
**Estimated Effort:** 5 S items = ~10 hours

### 🟢 REQ-228: Create Séance Workflow Infographic

**Type:** Enhancement (Documentation)
**Reported:** 2025-12-18
**Completed:** 2025-12-28
**Source:** BMAD research - visual workflow diagrams improve onboarding

**Description:**
Create Mermaid diagram showing complete séance workflow from idea to implementation (3 phases: Requirements Development → Requirements Analysis → Roadmap Creation). Embed in README.md to reduce onboarding cognitive load.

**Tasks:**
- [x] Create Mermaid flowchart for séance workflow
- [x] Show 3 phases with inputs/outputs
- [x] Store in `Haunt/docs/assets/seance-workflow.mmd`
- [x] Create HTML file for browser preview
- [x] Document in assets README

**Files:**
- `Haunt/docs/assets/seance-workflow.mmd` (created)
- `Haunt/docs/assets/seance-workflow.html` (created)
- `Haunt/docs/assets/README.md` (created)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Diagram renders in README.md, shows all 3 séance phases with clear inputs/outputs
**Blocked by:** None

**Implementation Notes:**
Created Mermaid flowchart with three-phase workflow showing Phase 1 (Requirements Development), Phase 2 (Requirements Analysis), and Phase 3 (Roadmap Creation). Diagram uses color-coded subgraphs for visual clarity. HTML file created for browser preview using Mermaid.js CDN. Assets README documents all three diagrams.

---

### 🟢 REQ-229: Create Agent Coordination Diagram

**Type:** Enhancement (Documentation)
**Reported:** 2025-12-18
**Completed:** 2025-12-28
**Source:** BMAD research - visual coordination model improves understanding

**Description:**
Create Mermaid diagram showing how agents coordinate asynchronously via roadmap status updates. Shows PM, Dev, Reviewer, Release roles and status transitions (⚪ → 🟡 → 🟢).

**Tasks:**
- [x] Create Mermaid diagram for agent coordination
- [x] Show agent roles and roadmap communication layer
- [x] Show status transitions
- [x] Store in `Haunt/docs/assets/agent-coordination.mmd`
- [x] Create HTML file for browser preview

**Files:**
- `Haunt/docs/assets/agent-coordination.mmd` (created)
- `Haunt/docs/assets/agent-coordination.html` (created)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Diagram renders in WHITE-PAPER.md, shows complete agent coordination model
**Blocked by:** None

**Implementation Notes:**
Created Mermaid flowchart showing agents (PM, Dev, Code Reviewer, Release Manager) coordinating via roadmap as communication layer. Diagram shows status transitions, task checkbox updates, and implementation notes sharing. Uses color-coded subgraphs for visual organization.

---

### 🟢 REQ-230: Create Session Startup Protocol Diagram

**Type:** Enhancement (Documentation)
**Reported:** 2025-12-18
**Completed:** 2025-12-28
**Source:** BMAD research - visual flowcharts reduce onboarding friction

**Description:**
Create Mermaid flowchart showing session startup sequence: Verify env → Check git → Run tests → Find assignment. Includes assignment lookup priority order.

**Tasks:**
- [x] Create Mermaid flowchart for session startup
- [x] Show 4 main steps (env, git, tests, assignment)
- [x] Show assignment lookup decision tree (Step 1-4 from gco-assignment-lookup)
- [x] Store in `Haunt/docs/assets/session-startup.mmd`
- [x] Create HTML file for browser preview

**Files:**
- `Haunt/docs/assets/session-startup.mmd` (created)
- `Haunt/docs/assets/session-startup.html` (created)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Diagram renders in SETUP-GUIDE.md, shows complete session startup protocol
**Blocked by:** None

**Implementation Notes:**
Created Mermaid flowchart showing complete session startup protocol with three main sections: Environment Verification, Test Validation, and Assignment Lookup. Diagram uses decision nodes and color-coding to show critical paths (test failures, wrong directory) and success paths (assignment found).

---

## Batch: Testing Enforcement (Hybrid Minimal)

**Context:** Post-incident analysis from REQ-046/047 testing violations. Critical analysis showed original 3-layer plan was over-engineered. This batch implements minimal effective solution: agent identity change + external verification. Total effort: 3 hours.

**Strategy Document:** `.haunt/docs/research/testing-enforcement-critical-analysis.md`

**Status:** All 3 requirements in this batch have been completed and archived. See `.haunt/completed/roadmap-archive.md`.

---

