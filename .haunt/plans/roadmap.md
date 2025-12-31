# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` for completed/archived work.

---

## Current Focus

**Active Work:**
- None (all current work complete!)

**Recently Added (2025-12-31):**
- ⚪ REQ-279-281: Agent Iteration & Verification (Ralph Wiggum-inspired improvements)
- ⚪ REQ-275-278: Deterministic Wrapper Scripts (haunt-lessons, haunt-story, haunt-read, haunt-archive)

**Recently Archived (2025-12-30):**
- 🟢 REQ-274: Structured Roadmap Lookup Wrapper
- 🟢 REQ-245: Interactive dependency prompts
- ⚫ REQ-248/249/250/251: Banished as obsolete (solved by wrappers)
- ⚫ REQ-220-227: Banished as duplicates/obsolete

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

## Backlog: Deterministic Wrapper Scripts

**Goal:** Provide JSON-based wrappers for large markdown files to reduce token usage when agents query specific sections.

**Token Savings:** 60-97% reduction across wrapper types (see research findings in completed REQ-274)

### 🟢 REQ-275: Implement haunt-lessons.sh Wrapper

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Research findings from REQ-274 token analysis

**Description:**
Create wrapper script for `.haunt/docs/lessons-learned.md` (752 lines) to provide targeted section access instead of full file reads. Agents currently load entire lessons file when only needing specific sections, wasting ~2,200 tokens per query.

**Tasks:**
- [x] Create `Haunt/scripts/haunt-lessons.sh` with JSON output
- [x] Implement `haunt-lessons list` command (list all section titles)
- [x] Implement `haunt-lessons get "Section Name"` command (extract specific section)
- [x] Implement `haunt-lessons search "keyword"` command (search across lessons)
- [x] Add error handling for missing sections
- [x] Add usage help text (`--help` flag)
- [x] Test with actual lessons-learned.md file (verify section extraction)

**Files:**
- `Haunt/scripts/haunt-lessons.sh` (create)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**
- All commands return valid JSON with `{success: true, data: ...}` structure
- `haunt-lessons list` returns array of section titles
- `haunt-lessons get "Section"` returns section content + metadata (line count)
- `haunt-lessons search "term"` returns matching sections with context
- Script executable and works on macOS/Linux

**Blocked by:** None

---

### 🟢 REQ-276: Implement haunt-story.sh Wrapper

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Research findings from REQ-274 token analysis

**Description:**
Create wrapper script for story files in `.haunt/docs/stories/` directory. Story files average 300 lines each. Agents often only need existence check or specific sections (Problem/Solution/Impact), not full content.

**Tasks:**
- [x] Create `Haunt/scripts/haunt-story.sh` with JSON output
- [x] Implement `haunt-story check REQ-XXX` command (existence + metadata)
- [x] Implement `haunt-story get REQ-XXX` command (full story as JSON)
- [x] Implement `haunt-story section REQ-XXX "Heading"` command (extract section)
- [x] Implement `haunt-story list` command (list all story files)
- [x] Add error handling for missing stories/sections
- [x] Add usage help text (`--help` flag)
- [x] Test with actual story files (verify section parsing)

**Files:**
- `Haunt/scripts/haunt-story.sh` (create)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**
- All commands return valid JSON with `{success: true, data: ...}` structure
- `haunt-story check REQ-XXX` returns existence boolean + metadata (lines, size)
- `haunt-story get REQ-XXX` returns full story content + sections list
- `haunt-story section REQ-XXX "Heading"` returns specific section content
- `haunt-story list` returns array of {req_id, title, file_path}
- Script executable and works on macOS/Linux

**Blocked by:** None

---

### 🟢 REQ-277: Implement haunt-read.sh General Wrapper

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Research findings from REQ-274 token analysis

**Description:**
Create general-purpose file reading wrapper with multiple access modes (head, tail, section, grep). Provides JSON output for any file type, reducing token usage when agents need small portions of large files.

**Tasks:**
- [x] Create `Haunt/scripts/haunt-read.sh` with JSON output
- [x] Implement `haunt-read check <file>` command (existence + metadata)
- [x] Implement `haunt-read head <file> [--lines=N]` command (first N lines)
- [x] Implement `haunt-read tail <file> [--lines=N]` command (last N lines)
- [x] Implement `haunt-read section <file> "Heading"` command (markdown section extraction)
- [x] Implement `haunt-read grep <file> <pattern> [--context=N]` command (grep with context)
- [x] Add error handling for missing files/invalid ranges
- [x] Add usage help text (`--help` flag)
- [x] Test with various file types (markdown, code, config)
- [x] Test edge cases (empty files, missing sections, invalid patterns)

**Files:**
- `Haunt/scripts/haunt-read.sh` (create)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**
- All commands return valid JSON with `{success: true, data: ...}` structure
- `haunt-read check <file>` returns existence, lines, size, file type
- `haunt-read head/tail` returns content + line range + total lines
- `haunt-read section` returns markdown section content (handles heading levels)
- `haunt-read grep` returns matches with context lines (configurable)
- All modes include metadata (line ranges, total lines, file info)
- Script executable and works on macOS/Linux

**Blocked by:** None

---

### 🟢 REQ-278: Implement haunt-archive.sh Wrapper

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Research findings from REQ-274 token analysis

**Description:**
Create wrapper script for `.haunt/completed/roadmap-archive.md` (grows to 1,000+ lines). Agents rarely need full archive but occasionally need to reference completed requirements. Provides targeted lookup instead of full file reads.

**Tasks:**
- [x] Create `Haunt/scripts/haunt-archive.sh` with JSON output
- [x] Implement `haunt-archive search REQ-XXX` command (find specific requirement)
- [x] Implement `haunt-archive list [--since=DATE]` command (list completions)
- [x] Implement `haunt-archive get REQ-XXX` command (full completion details)
- [x] Implement `haunt-archive stats` command (summary statistics)
- [x] Add date filtering support for list command
- [x] Add error handling for missing requirements
- [x] Add usage help text (`--help` flag)
- [x] Test with actual archive file (verify requirement extraction)

**Files:**
- `Haunt/scripts/haunt-archive.sh` (create)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**
- All commands return valid JSON with `{success: true, data: ...}` structure
- `haunt-archive search REQ-XXX` returns requirement details if found
- `haunt-archive list` returns array of {req_id, title, completed_date, agent}
- `haunt-archive list --since=DATE` filters by completion date
- `haunt-archive get REQ-XXX` returns full requirement content + metadata
- Script executable and works on macOS/Linux

**Blocked by:** None

---

## Backlog: Agent Iteration & Verification

**Goal:** Add Ralph Wiggum-inspired iteration patterns with smart exit detection for genuine blockers.

**Research:** See `.haunt/docs/research/ralph-wiggum-analysis.md` for full analysis.

### 🟢 REQ-279: Add TDD Iteration Loop with Smart Exit to Dev Agents

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Ralph Wiggum pattern analysis - extract iteration benefits without token waste

**Description:**
Add structured TDD iteration loop to dev agent character sheets that allows multiple retry attempts before escalating, with smart exit detection for genuine blockers requiring user intervention (missing API keys, env vars, permissions, external service issues).

Key principles:
- Allow 5-10 iteration attempts before escalating (not 3)
- Detect "user intervention required" patterns and exit early with clear instructions
- Token-efficient: Don't re-read entire codebase each iteration, just relevant error context
- Track what was tried to avoid repeating failed approaches

**Tasks:**
- [x] Define smart exit patterns (missing env vars, auth failures, external service down, permission denied)
- [x] Create iteration loop section for unified `Haunt/agents/gco-dev.md` (Note: single file covers all modes)
- [x] Add "attempts tracking" format to prevent repeating failed approaches
- [x] Add escalation criteria (when to give up vs when to request user intervention)
- [x] Document smart exit patterns in agent character sheet
- [ ] Test with simulated failure scenarios (deferred - requires actual dev work to validate)

**Files:**
- `Haunt/agents/gco-dev.md` (modified - unified dev agent for all modes)

**Implementation Notes:**
- Discovered single unified `gco-dev.md` instead of separate backend/frontend/infrastructure files
- Added comprehensive "TDD Iteration Loop (Smart Exit Detection)" section with:
  - Smart exit pattern table (6 patterns: env file, API key, permissions, external service, auth, rate limits)
  - 5-step implementation loop protocol
  - Attempt tracking format with examples
  - Token-efficient iteration guidelines
  - Example scenarios (API key missing, async validation challenge)
  - Integration with completion checklist

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**
- All dev agent character sheets include "Implementation Loop" section
- Smart exit patterns documented (env vars, auth, permissions, external services)
- Iteration allows 5-10 attempts before human escalation
- Early exit triggers for user-intervention-required scenarios
- Attempts tracking format prevents repeating same failed approach
- Token-efficient: Only reads error context, not full codebase per iteration

**Blocked by:** None

---

### 🟢 REQ-281: Enhance Completion Checklist with Explicit Verification Patterns

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Ralph Wiggum pattern analysis - explicit confirmation and self-assessment

**Description:**
Enhance the `gco-completion-checklist.md` rule with Ralph-inspired explicit verification patterns. Currently Steps 2 and 8 are vague; this adds structured confirmation output and specific self-assessment questions.

**Tasks:**

- [x] Update Step 2 to require per-criterion confirmation output format
- [x] Replace Step 8 with specific self-assessment questions
- [x] Add to Non-Negotiable section
- [x] Update source file in `Haunt/rules/gco-completion-checklist.md`
- [x] Re-run setup script to deploy to `~/.claude/rules/`

**Files:**

- `Haunt/rules/gco-completion-checklist.md` (modify)

**Effort:** XS
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- Step 2 requires explicit "✓ [criterion] - VERIFIED" output for each criterion
- Step 8 contains 4-5 specific yes/no self-assessment questions
- Non-Negotiable includes "NEVER mark 🟢 without explicit criterion-by-criterion verification"
- Rule deployed to `~/.claude/rules/` via setup script

**Blocked by:** None

---

### ⚪ REQ-280: Create haunt-verify.sh Completion Verification Script

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Ralph Wiggum pattern analysis - programmatic completion verification

**Description:**
Create wrapper script that programmatically verifies requirement completion criteria. Agents run this before marking requirements 🟢 to ensure all criteria are objectively met. Returns JSON with pass/fail for each criterion.

Verification types:
- Test results (parse test output for pass/fail counts)
- Coverage thresholds (parse coverage reports)
- Lint/type errors (run linters and check exit codes)
- File existence (verify expected files created)
- Task checkboxes (parse requirement for unchecked tasks)

**Tasks:**
- [ ] Create `Haunt/scripts/haunt-verify.sh` with JSON output
- [ ] Implement `haunt-verify REQ-XXX` command (full verification)
- [ ] Add test result verification (detect test framework, parse output)
- [ ] Add coverage verification (parse coverage report if available)
- [ ] Add lint verification (run project linter, check exit code)
- [ ] Add task checkbox verification (parse requirement, count checked/unchecked)
- [ ] Add file existence verification (check files listed in requirement exist)
- [ ] Return structured JSON with pass/fail per criterion
- [ ] Add usage help text (`--help` flag)
- [ ] Test with sample requirements

**Files:**
- `Haunt/scripts/haunt-verify.sh` (create)

**Effort:** S
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**
- `haunt-verify REQ-XXX` returns JSON with verification results
- Output format: `{success: bool, requirement: "REQ-XXX", criteria: [{name, status, evidence}]}`
- Detects common test frameworks (pytest, jest, vitest, go test)
- Parses task checkboxes from requirement in roadmap
- Verifies files listed in requirement exist
- Returns overall pass/fail plus per-criterion breakdown
- Script executable and works on macOS/Linux

**Blocked by:** None

---
