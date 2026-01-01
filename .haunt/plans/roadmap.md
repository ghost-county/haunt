# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` for completed/archived work.

---

## Current Focus

**Active Work:**
- None (all current work complete!)

**Recently Archived (2025-12-31):**
- 🟢 REQ-286: Documentation Update (WHITE-PAPER.md + README.md refreshed for v2.0)
- 🟢 REQ-282: Skill Token Optimization - gco-orchestrator refactored (1,773→326 lines, 5 reference files)
- 🟢 REQ-279-281: Agent Iteration & Verification (Ralph Wiggum-inspired improvements)
- 🟢 REQ-275-278: Deterministic Wrapper Scripts (haunt-lessons, haunt-story, haunt-read, haunt-archive)
- 🟢 REQ-274: Structured Roadmap Lookup Wrapper

---

## Backlog: Visual Documentation

⚪ REQ-228: Create Séance Workflow Infographic (Agent: Dev-Infrastructure, S)
⚪ REQ-229: Create Agent Coordination Diagram (Agent: Dev-Infrastructure, S)
⚪ REQ-230: Create Session Startup Protocol Diagram (Agent: Dev-Infrastructure, S)

---

## Backlog: CLI Improvements

⚪ REQ-231: Implement /haunt status --batch Command (Agent: Dev-Infrastructure, M)
⚪ REQ-232: Add Effort Estimation to Batch Status (Agent: Dev-Infrastructure, S, blocked by REQ-231)

---

## Backlog: GitHub Integration

⚪ REQ-205: GitHub Issues Integration (Research-Analyst → Dev-Infrastructure)
⚪ REQ-206: Create /bind Command (Dev-Infrastructure)

---

## Backlog: Haunt Uninstallation (/cleanse Command)

> Priority: HIGH (RICE 9.4) - Completes setup/teardown lifecycle, already documented in README

### 🟢 REQ-287: Implement Interactive Cleanse Mode

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Feature request - `/cleanse` command

**Description:**
Create interactive mode for `/cleanse` command that guides users through safe Haunt removal with menu-driven prompts. This is the user-friendly mode for non-technical users who want guided uninstallation.

**Tasks:**

- [x] Create `Haunt/scripts/cleanse.sh` or `Haunt/commands/gco-cleanse.md`
- [x] Implement interactive menu (Global / Project / Full / Cancel)
- [x] Show preview of what will be deleted before confirmation
- [x] Require explicit "yes" confirmation (not just Enter key)
- [x] Print summary of deleted items after completion
- [x] Add help text and usage documentation

**Files:**

- `Haunt/scripts/cleanse.sh` (create) OR `Haunt/commands/gco-cleanse.md` (create)
- `Haunt/README.md` (update with usage examples)

**Effort:** S (2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- Running `/cleanse` (no flags) shows interactive menu
- Menu lists all removal options clearly
- Confirmation cannot be bypassed accidentally
- Summary shows count of deleted files/directories
- Script exits cleanly with appropriate exit codes (0/1/2)

**Blocked by:** None

**Implementation Notes:**
- Interactive mode triggers when script run with zero arguments
- Menu options: [G] Global, [P] Project, [A] All, [Q] Quit
- Shows preview using existing `preview_uninstall()` function
- Requires explicit "yes" confirmation (not case-sensitive)
- Displays removal summary with count via `REMOVED_COUNT` variable
- Exit codes: 0 (success/cancel), handled by existing error functions

---

### 🟢 REQ-288: Implement Flag-Based Cleanse Modes

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Feature request - `/cleanse` command flags

**Description:**
Implement command-line flags for targeted Haunt removal: `--global` (remove ~/.claude/gco-* only), `--project` (remove .claude/ and .haunt/ only), `--full` (remove both). This enables power users to quickly clean up specific scopes.

**Tasks:**

- [x] Implement `--global` flag (remove ~/.claude/agents/gco-*, skills/gco-*, rules/gco-*, commands/gco-*)
- [x] Implement `--project` flag (remove .claude/ and .haunt/ from current directory)
- [x] Implement `--full` flag (combine global + project removal)
- [x] Add confirmation prompts for each mode
- [x] Handle missing directories gracefully (don't error if already clean)
- [x] Add `--help` flag with usage documentation

**Files:**

- `Haunt/scripts/cleanse.sh` (modified - added flag parsing)
- `Haunt/commands/cleanse.md` (modified - documented new flags)

**Effort:** S (2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- `/cleanse --global` removes only global ~/.claude/gco-* artifacts ✓
- `/cleanse --project` removes only .claude/ and .haunt/ from current directory ✓
- `/cleanse --full` removes both global and project artifacts ✓
- Each mode shows clear confirmation prompt before deletion ✓
- Missing directories handled gracefully (no errors if already clean) ✓

**Implementation Notes:**
- Flags map to existing MODE and SCOPE settings
- `--global` → MODE=uninstall, SCOPE=user
- `--project` → MODE=purge, SCOPE=project
- `--full` → MODE=purge, SCOPE=both
- All flags work with existing options (--dry-run, --backup, --force)
- Help message updated with new quick cleanse flags section
- Command documentation includes power-user benefits and examples

**Blocked by:** REQ-287 (interactive mode provides base script structure)

---

### 🟢 REQ-289: Add Backup Functionality to Cleanse

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Feature request - `/cleanse --backup` flag

**Description:**
Add `--backup` flag to create timestamped archive before deletion. Enables safe removal with ability to restore if needed. Backup stored in ~/haunt-backups/ with format haunt-backup-YYYYMMDD-HHMMSS.tar.gz.

**Tasks:**

- [x] Implement `--backup` flag (can combine with other flags)
- [x] Create ~/haunt-backups/ directory if missing
- [x] Archive global artifacts (if --global or --full)
- [x] Archive project artifacts (if --project or --full)
- [x] Use timestamped filename: haunt-backup-YYYYMMDD-HHMMSS.tar.gz
- [x] Print backup location before proceeding with deletion
- [x] Handle disk space errors gracefully

**Files:**

- `Haunt/scripts/cleanse.sh` (modified)

**Effort:** S (2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- ✓ `/cleanse --backup --full` creates backup before deletion
- ✓ Backup format: haunt-backup-YYYYMMDD-HHMMSS.tar.gz
- ✓ Backup location: ~/haunt-backups/
- ✓ Backup includes all artifacts being deleted
- ✓ Script prints backup path and verifies archive created successfully

**Blocked by:** None

**Implementation Notes:**
- Backup directory: `~/haunt-backups/` (created automatically via `mkdir -p`)
- Backup filename format: `haunt-backup-YYYYMMDD-HHMMSS.tar.gz` (no dashes in date)
- Exit code 3 (`EXIT_BACKUP_FAILED`) on backup failures (aborts deletion)
- Works with all cleanse modes: `--global`, `--project`, `--full`, interactive
- E2E tests created in `.haunt/tests/e2e/test_cleanse_backup.sh` (8/8 passing)
- Help text updated with `--backup` flag and restore instructions

---

### 🟢 REQ-290: Add Safety Features to Cleanse

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Safety requirements for `/cleanse` command

**Description:**
Add comprehensive safety and error handling to cleanse command: dry-run mode, permission checks, installation verification, and proper exit codes. Prevents accidental data loss and handles edge cases gracefully.

**Tasks:**

- [x] Implement `--dry-run` flag (preview deletions without executing) - already exists
- [x] Add permission checks before deletion attempts
- [x] Implement proper exit codes (0=success, 1=cancelled, 2=permission denied, 3=backup failed, 4=nothing to clean)
- [x] Handle permission errors gracefully (inform user, suggest solutions)
- [x] Document --dry-run and exit codes in help text
- [x] Add error messaging for "nothing to clean" scenario

**Files:**

- `Haunt/scripts/cleanse.sh` (modified)

**Effort:** S (2 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**

- `--dry-run` shows what would be deleted without deleting ✓
- Permission checks verify write access before attempting deletion ✓
- Proper exit codes implemented (0=success, 1=cancelled, 2=permission denied, 3=backup failed, 4=nothing to clean) ✓
- Permission errors handled gracefully with helpful messages ✓
- Help text documents --dry-run and exit codes ✓

**Blocked by:** None (REQ-288 complete)

**Implementation Notes:**
- Added exit code constants (EXIT_SUCCESS=0, EXIT_CANCELLED=1, EXIT_PERMISSION_DENIED=2, EXIT_BACKUP_FAILED=3, EXIT_NOTHING_TO_CLEAN=4)
- Implemented `check_directory_writable()` function for permission verification
- Added `check_permissions()` to verify all target directories before deletion
- Added `check_has_artifacts()` to detect "nothing to clean" scenario
- Integrated permission checks into `perform_uninstall()` and `perform_purge()`
- Updated help text with exit codes and dry-run mode documentation
- All confirmations now exit with EXIT_CANCELLED when user aborts
- Backup failures exit with EXIT_BACKUP_FAILED
- Permission errors provide helpful messages with suggested solutions

---

---

## Backlog: Skill Token Optimization (>600 lines)

> Threshold: Focus on skills >600 lines. Skills 500-600 have marginal ROI.
> Pattern: Use REQ-282 as template (reference index + consultation gates).

### ⚪ REQ-283: Refactor gco-requirements-analysis Skill

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Skill refactoring analysis

**Description:**
gco-requirements-analysis is 824 lines (65% over 500-line limit). This is a core PM workflow skill used in every séance. High token cost per invocation.

**Tasks:**

- [ ] Analyze skill structure and identify natural domain splits
- [ ] Create `references/` directory
- [ ] Extract detailed rubric examples to reference file
- [ ] Extract JTBD/Kano/RICE implementation details to reference file
- [ ] Slim SKILL.md to ~400 lines with overview + reference index
- [ ] Add consultation gates (Pattern 1 + Pattern 5)
- [ ] Test PM workflow still functions correctly

**Files:**

- `Haunt/skills/gco-requirements-analysis/SKILL.md` (modify)
- `Haunt/skills/gco-requirements-analysis/references/*.md` (create)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**

- SKILL.md under 500 lines
- Reference files created with appropriate content
- Consultation gates implemented
- PM workflow functions correctly

**Blocked by:** None

---

### ⚪ REQ-284: Refactor gco-code-patterns Skill

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Skill refactoring analysis

**Description:**
gco-code-patterns is 658 lines (32% over limit). Used by code reviewer agent for anti-pattern detection.

**Tasks:**

- [ ] Analyze skill structure
- [ ] Create `references/` directory
- [ ] Extract pattern examples to reference files (by language or category)
- [ ] Slim SKILL.md to ~400 lines
- [ ] Add consultation gates
- [ ] Test code review workflow

**Files:**

- `Haunt/skills/gco-code-patterns/SKILL.md` (modify)
- `Haunt/skills/gco-code-patterns/references/*.md` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- SKILL.md under 500 lines
- Pattern examples in reference files
- Code review workflow functions correctly

**Blocked by:** None

---

### ⚪ REQ-285: Refactor gco-task-decomposition Skill

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Skill refactoring analysis

**Description:**
gco-task-decomposition is 600 lines (exactly at threshold). Used for breaking SPLIT-sized requirements into atomic tasks.

**Tasks:**

- [ ] Analyze skill structure
- [ ] Create `references/` directory
- [ ] Extract decomposition examples to reference file
- [ ] Extract DAG visualization guidance to reference file
- [ ] Slim SKILL.md to ~400 lines
- [ ] Add consultation gates

**Files:**

- `Haunt/skills/gco-task-decomposition/SKILL.md` (modify)
- `Haunt/skills/gco-task-decomposition/references/*.md` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- SKILL.md under 500 lines
- Decomposition examples in reference files
- Task decomposition workflow functions correctly

**Blocked by:** None

---
