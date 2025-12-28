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

### 🟢 REQ-242: Auto-install missing dependencies in setup scripts

**Type:** Enhancement
**Reported:** 2024-12-24
**Completed:** 2024-12-28
**Source:** User feedback - manual dependency installation is friction point

**Description:**
Add automatic dependency installation to setup scripts with user consent. When setup detects missing dependencies (Python, Node.js, git, uv), prompt user to auto-install them using the appropriate package manager (winget on Windows, brew on macOS, apt/yum on Linux) instead of just showing manual installation instructions.

**Tasks:**
- [x] Add dependency auto-install to `setup-haunt.sh` (macOS/Linux):
  - [x] Detect OS and package manager (brew/apt/yum)
  - [x] Add `--yes` / `-y` flag (opt-in)
  - [x] Prompt user for each missing dependency: "Auto-install Python 3.11? (Y/n)"
  - [x] Install Python 3.11+ via package manager
  - [x] Install Node.js 18+ via package manager
  - [x] Install uv via curl script
  - [x] Verify installations succeeded
- [x] Add dependency auto-install to `setup-haunt.ps1` (Windows):
  - [x] Use winget for package management
  - [x] Add `-Yes` parameter (opt-in)
  - [x] Prompt user for each missing dependency
  - [x] Install Python 3.11+ via `winget install Python.Python.3.11`
  - [x] Install Node.js 18+ via `winget install OpenJS.NodeJS`
  - [x] Install uv via PowerShell script
  - [x] Verify installations succeeded
- [x] Update documentation:
  - [x] Add auto-install section to SETUP-GUIDE.md
  - [x] Update Quick Start with `--yes`/`-Yes` option
  - [x] Document that manual installation is still supported

**Files:**
- `Haunt/scripts/setup-haunt.sh` (modify)
- `Haunt/scripts/setup-haunt.ps1` (modify)
- `Haunt/SETUP-GUIDE.md` (modify)
- `Haunt/README.md` (modify)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Setup scripts can auto-install Python, Node.js, and uv with user consent on all platforms. Verified: `--yes`/`-Yes` flags exist in both scripts, documentation updated.
**Blocked by:** None

**Implementation Notes:**
Bash script uses `--yes` or `-y` flag with YES_TO_ALL variable. PowerShell uses `-Yes` parameter. Both scripts prompt for each dependency unless flag is set. Documentation in SETUP-GUIDE.md includes usage examples.

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

### 🟢 REQ-248: Implement Story Files for M-Sized Features

**Type:** Enhancement
**Reported:** 2024-12-24
**Completed:** 2024-12-28
**Source:** BMAD framework pattern - prevents context re-explanation

**Description:**
Create `/story create REQ-XXX` command for PM to generate detailed story files for M-sized features. Story files contain full context, implementation approach, code examples, preventing context loss in multi-session work.

**Tasks:**
- [x] Create `/story` command for PM agent
- [x] Design story file template
- [x] Update session startup to load story files
- [x] Test with M-sized requirement

**Files:**
- `Haunt/commands/story.md` (create)
- `Haunt/skills/gco-session-startup/SKILL.md` (modify)
- `Haunt/templates/story-template.md` (create)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Story files reduce multi-session overhead by 20-30%. Verified: `/story` command exists in Haunt/commands/story.md with full implementation.
**Blocked by:** None
**RICE Score:** 63 (additional 500K tokens saved)

---

### 🟢 REQ-249: Implement Batch-Specific Roadmap Sharding

**Type:** Enhancement
**Reported:** 2024-12-24
**Completed:** 2024-12-28
**Source:** BMAD pattern - deferred until scale justifies

**Description:**
Split roadmap into batch files for projects >20 requirements. Saves 600 tokens/session but low ROI at current scale.

**Priority:** LOW - Deferred until projects regularly exceed 20 requirements

**Effort:** M
**Complexity:** MODERATE
**RICE Score:** 27

**Implementation Notes:**
Verified: `/roadmap shard`, `/roadmap unshard`, `/roadmap activate`, and `/roadmap archive` commands exist in Haunt/commands/roadmap.md with full sharding implementation.

---

### 🟢 REQ-250: Implement Scale-Adaptive Workflow Modes

**Type:** Enhancement
**Reported:** 2024-12-24
**Completed:** 2024-12-28
**Source:** Token efficiency analysis - deferred until user feedback

**Description:**
Add --quick/--standard/--deep modes to /seance for scale-appropriate planning.

**Priority:** LOW - Deferred until planning overhead becomes pain point

**Effort:** M
**Complexity:** MODERATE
**RICE Score:** 18

**Implementation Notes:**
Verified: `--quick` and `--deep` flags exist in Haunt/commands/seance.md with full implementation. Planning depth modifier extracts flags and passes to gco-orchestrator skill.


---

### 🟢 REQ-255: Research AI-Assisted Coding Best Practices

**Type:** Research
**Reported:** 2025-12-25
**Completed:** 2025-12-25
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
- [x] Research common mistakes in AI-generated code (2025 studies)
- [x] Analyze where AI falls short vs. human developers
- [x] Research best practices for prompting AI to write quality code
- [x] Identify testing patterns AI commonly misses
- [x] Study security vulnerabilities in AI-generated code
- [x] Research code review patterns for AI code
- [x] Create dev agent prompting guidelines
- [x] Create code quality checklist for AI output
- [x] Propose updates to dev agent character sheets
- [x] Provide examples of good vs. bad AI prompting

**Files:**
- `.haunt/docs/research/req-255-ai-coding-best-practices.md` (created - 814 lines)
- `Haunt/agents/gco-dev.md` (recommendations provided)
- `Haunt/rules/gco-code-quality-standards.md` (recommendations provided)
- `.haunt/checklists/ai-code-quality-checklist.md` (recommendations provided)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Research-Analyst
**Completion:** Research report complete (814 lines) with comprehensive 2025 data, prompting guidelines, code quality recommendations, and implementation roadmap for High/Medium priority improvements.
**Blocked by:** None

**Implementation Notes:**
Comprehensive research completed covering all requested areas. Report includes 25 industry sources from 2025, key findings (AI code has 45-62% security vulnerabilities, 1.7x more bugs), Top 10 AI anti-patterns, and specific recommendations for Haunt framework improvements prioritized as High/Medium.

---

## Batch: Testing Enforcement (Hybrid Minimal)

**Context:** Post-incident analysis from REQ-046/047 testing violations. Critical analysis showed original 3-layer plan was over-engineered. This batch implements minimal effective solution: agent identity change + external verification. Total effort: 3 hours.

**Strategy Document:** `.haunt/docs/research/testing-enforcement-critical-analysis.md`

### 🟢 REQ-256: Add testing accountability to Dev agent core values

**Type:** Enhancement
**Reported:** 2025-12-28
**Completed:** 2025-12-28
**Source:** Testing enforcement failure (REQ-046/047), critical analysis

**Description:**
Add "Professional Accountability" and "Testing Non-Negotiables" to Dev agent core values. This makes testing part of agent IDENTITY (who they are), not external rules (what they must do). Minimal context overhead - no new skills, just values loaded with agent.

**Rationale:**
- REQ-046/047 agents ignored explicit rules but knew what they should do
- Problem is discipline, not education
- Identity-level change more effective than external rules
- Values are always present (loaded with agent), unlike skills that must be invoked

**Tasks:**
- [x] Add "Core Values" section to `Haunt/agents/gco-dev.md`
- [x] Define "Professional Accountability" values:
  - [x] "If tests don't pass, code doesn't work - by definition"
  - [x] "'Tests written' ≠ 'Tests passing'"
  - [x] "Environment issues are problems to SOLVE, not excuses to SKIP"
  - [x] "Would I demonstrate this to my CTO? If no, it's not done"
- [x] Define "Testing Non-Negotiables":
  - [x] Frontend: npm test + npx playwright test MUST show 0 failures
  - [x] Backend: npm test (or pytest) MUST show 0 failures
  - [x] Paste test output in completion notes (evidence required)
- [x] Define "When Tests Fail" protocol (4-step: STOP, FIX, VERIFY, COMPLETE)
- [x] Define "When Environment Blocks Tests" protocol
- [x] Deploy to both global and project locations

**Files:**
- `Haunt/agents/gco-dev.md` (modify - add Core Values section)

**Effort:** XS
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Core Values section added to Dev agent, values cover professional accountability, testing non-negotiables, failure protocols. Verified: Values appear in agent sheet when loaded.
**Blocked by:** None

---

### ⚪ REQ-257: Create universal test verification script

**Type:** Enhancement
**Reported:** 2025-12-28
**Source:** Testing enforcement failure, need external verification

**Description:**
Create ONE universal script (`verify-tests.sh`) that verifies tests pass for all requirement types (frontend, backend, infrastructure). Replaces self-reporting with automated verification. Script executes test commands, parses output for pass/fail counts, returns clear PASS/FAIL verdict.

**Key Features:**
- Handles frontend (npm test + npx playwright test)
- Handles backend (npm test or pytest detection)
- Handles infrastructure (manual verification placeholder)
- Clear output: "✅ VERIFICATION PASSED" or "❌ VERIFICATION FAILED"
- Exit codes: 0 = pass, 1 = fail

**Why Universal Script (Not Separate Scripts):**
- Lower maintenance (one script vs multiple)
- Simpler for agents (one command for all types)
- Token-efficient (less documentation needed)

**Tasks:**
- [ ] Create `Haunt/scripts/verify-tests.sh`
- [ ] Add usage: `verify-tests.sh REQ-XXX <frontend|backend|infrastructure>`
- [ ] Implement frontend verification:
  - [ ] Run `npm test`, capture exit code
  - [ ] Run `npx playwright test`, capture exit code
  - [ ] Both must pass (exit 0) for PASS verdict
- [ ] Implement backend verification:
  - [ ] Detect test framework (package.json → npm test, pytest.ini → pytest)
  - [ ] Run appropriate command
  - [ ] Exit 0 required for PASS
- [ ] Implement infrastructure verification:
  - [ ] Print "Infrastructure verification (manual)" and exit 0
  - [ ] Placeholder for future state validation
- [ ] Add clear output formatting
- [ ] Make script executable (`chmod +x`)
- [ ] Test with REQ-046/047 (should PASS now that tests fixed)

**Files:**
- `Haunt/scripts/verify-tests.sh` (create)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Script exists, handles all three types, returns clear PASS/FAIL, tested on at least one requirement per type. Verified: Exit code 0 for passing tests, 1 for failures.
**Blocked by:** None

---

### ⚪ REQ-258: Update completion checklist to require test verification

**Type:** Enhancement
**Reported:** 2025-12-28
**Source:** Testing enforcement failure, need evidence requirement

**Description:**
Update completion checklist Step 3 (Tests Passing) with stricter language and verification script requirement. Remove ambiguity, require evidence (pasted test output), reference agent Core Values for guidance.

**Changes:**
1. Update header: "Tests Passing (NON-NEGOTIABLE)"
2. Add verification script requirement: `bash Haunt/scripts/verify-tests.sh REQ-XXX <type>`
3. Require pasted output in completion notes (evidence)
4. Reference agent Core Values for "why this matters"
5. Remove exceptions language

**Locations to Update:**
- `Haunt/rules/gco-completion-checklist.md` (source)
- `.claude/rules/gco-completion-checklist.md` (deployed)

**Tasks:**
- [ ] Update `Haunt/rules/gco-completion-checklist.md` Step 3
- [ ] Change header to "Tests Passing (NON-NEGOTIABLE)"
- [ ] Add verification script requirement
- [ ] Add "Paste output in completion notes" requirement
- [ ] Add "If verification fails" protocol (STOP, FIX, RETRY)
- [ ] Add "NO EXCEPTIONS" with reference to Core Values
- [ ] Remove ambiguous language ("should", "typically")
- [ ] Deploy to `.claude/rules/gco-completion-checklist.md`

**Files:**
- `Haunt/rules/gco-completion-checklist.md` (modify)
- `.claude/rules/gco-completion-checklist.md` (modify - deployed copy)

**Effort:** XS
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Completion checklist Step 3 updated with stricter language, verification script requirement, evidence requirement. Verified: Both source and deployed copies updated.
**Blocked by:** REQ-257 (needs script to exist before requiring it)

---

