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

## Batch: Testing Enforcement (Hybrid Minimal)

**Context:** Post-incident analysis from REQ-046/047 testing violations. Critical analysis showed original 3-layer plan was over-engineered. This batch implements minimal effective solution: agent identity change + external verification. Total effort: 3 hours.

**Strategy Document:** `.haunt/docs/research/testing-enforcement-critical-analysis.md`

**Status:** All 3 requirements in this batch have been completed and archived. See `.haunt/completed/roadmap-archive.md`.

---

