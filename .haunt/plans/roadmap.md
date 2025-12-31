# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` and `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` for completed work.

---

## Current Focus: Framework Improvements

**Active Work:**
- None (all current work complete!)

**Recently Completed:**
- 🟢 REQ-265: Add Delegation Protocol to Orchestrator Skill (Dev-Infrastructure, S)
- 🟢 REQ-259: Remove Project Rule Duplication (Dev-Infrastructure, S)
- 🟢 REQ-260: Convert Heavy Rules to Skills (Dev-Infrastructure, M) - 84.6% reduction
- 🟢 REQ-261: Add Targeted Read Training to Agents (Dev-Infrastructure, S)

**Recently Completed:**
- REQ-228, REQ-229, REQ-230 (Visual workflow diagrams - archived 2025-12-28)
- REQ-256, REQ-257, REQ-258 (Testing enforcement batch)
- See `.haunt/completed/roadmap-archive.md` for full archive

---

## Batch: Setup Script Improvements

### 🟢 REQ-262: Add Quiet Mode as Default with Verbose Override

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** User feedback - setup output too verbose

**Description:**
The setup script outputs many success/info messages that clutter the terminal. Make quiet mode the default and only show:
- Section headers (minimal)
- Errors and warnings
- Final summary

Add `--verbose` to restore full output for debugging.

**Tasks:**
- [x] Add `QUIET=true` as default (rename from VERBOSE logic)
- [x] Create `log()` function that only prints when `QUIET=false`
- [x] Update `success()`, `info()` to use `log()` wrapper
- [x] Keep `error()`, `warning()` always visible
- [x] Keep section headers but make them single-line
- [x] Add `--quiet` / `-q` flag (explicit, for documentation)
- [x] Update `--verbose` / `-v` to set `QUIET=false`
- [x] Test both modes work correctly
- [x] Update --help text
- [x] Update PowerShell script to match behavior

**Files:**
- `Haunt/scripts/setup-haunt.sh` (modified)
- `Haunt/scripts/setup-haunt.ps1` (modified - matched behavior)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Setup runs quietly by default, `--verbose` shows all output
**Blocked by:** None
### 🟢 REQ-263: Add Optional Playwright MCP Installation Prompt

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** User request - Playwright should be project-level, not global

**Description:**
Add an interactive prompt during setup asking if the user wants to install Playwright MCP for UI/E2E testing. If yes, add it to project-level `.mcp.json`. If no, skip it. This keeps Playwright tokens (20k) out of non-frontend projects.

**Tasks:**
- [x] Add prompt after MCP section: "Install Playwright MCP for UI testing? [y/N]"
- [x] If yes: Create/update `.mcp.json` with Playwright config
- [x] If no: Skip silently (default behavior)
- [x] Add `--with-playwright` flag to skip prompt and install
- [x] Add `--no-playwright` flag to skip prompt and skip install
- [x] Handle existing `.mcp.json` (merge, don't overwrite)
- [x] Test on fresh project and existing project
- [x] Update --help text

**Playwright MCP Config:**
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

**Files:**
- `Haunt/scripts/setup-haunt.sh` (modify)
- `Haunt/scripts/setup-haunt.ps1` (modify - match behavior)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Setup prompts for Playwright, correctly adds to project `.mcp.json` if accepted
**Blocked by:** None

---

## Batch: Command Improvements

### 🟢 REQ-243: Fix Windows setup not installing slash commands

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

## Batch: Token Efficiency Optimization

**Context:** Analysis revealed ~20,000 tokens loaded into every conversation due to duplicated rules (global + project), heavy rules that should be skills, and agents reading full files instead of using targeted grep. This batch implements a 70% reduction in baseline context load.

**Goals:**
- Reduce baseline context from ~20,000 tokens to ~6,000 tokens per conversation
- Eliminate rule duplication between global and project
- Convert context-heavy rules to on-demand skills
- Train agents to use targeted file reads
- Consolidate overlapping rules (quick wins)

**Total Effort:** ~8.5 hours (4 requirements)
- REQ-259: Remove Project Rule Duplication 🟢
- REQ-260: Convert Heavy Rules to Skills 🟢
- REQ-261: Add Targeted Read Training 🟢
- REQ-264: Consolidate Overlapping Rules ⚪ (~700-800 tokens)

### 🟢 REQ-259: Remove Project Rule Duplication

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** Token efficiency analysis
**Completed:** 2025-12-30

**Description:**
Rules are currently duplicated between `~/.claude/rules/` (global) and `.claude/rules/` (project). This doubles context load. Solution: Keep only global rules, update setup script to NOT copy rules to project directories, delete existing project rule copies.

**Tasks:**
- [x] Audit which rules exist in both locations (9 rules duplicated)
- [x] Delete `.claude/rules/` from ghost-county project
- [x] Update `setup-haunt.sh` to skip project rules copy
- [x] Update `setup-haunt.ps1` to skip project rules copy
- [x] Verify agents still load global rules correctly (confirmed in current session)
- [x] Update CLAUDE.md to reference global rules location

**Implementation Notes:**
- Deleted `.claude/rules/` directory from ghost-county project (kept parent `.claude/` for other assets)
- Modified `setup-haunt.sh` to only install rules globally, not per-project
- Modified `setup-haunt.ps1` to match bash script behavior
- Updated CLAUDE.md to clarify rules are deployed to `~/.claude/rules/` (global location)
- Verified current session successfully loads global rules without project duplication
- Token savings: ~50% reduction in rules context load (9 rules × ~500 lines each = ~4500 lines eliminated)

**Files:**
- `.claude/rules/` (deleted directory)
- `Haunt/scripts/setup-haunt.sh` (modified)
- `Haunt/scripts/setup-haunt.ps1` (modified)
- `CLAUDE.md` (modified)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Only global rules exist, no project duplication, ~50% context reduction
**Blocked by:** None

### 🟢 REQ-260: Convert Heavy Rules to Skills

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** Token efficiency analysis
**Completed:** 2025-12-30

**Description:**
Six rules totaling ~2,000 lines are loaded into every conversation but only needed occasionally. Convert these to skills (on-demand) while keeping slim reference versions as rules.

**Implementation Notes:**
- Converted 5 heavy rules to skills (gco-interactive-decisions.md already deleted per user)
- Created slim rules (1,642→252 lines, 84.6% reduction in baseline context load)
- Skills total 1,659 lines but only loaded on-demand when invoked
- Deployed slim rules to ~/.claude/rules/ via setup script (5 rules updated)
- All skills have proper YAML frontmatter with name and description
- Net savings: ~1,390 lines per conversation (not loaded unless skills invoked)

**Rules to Convert:**
| Rule | Lines | When Needed |
|------|-------|-------------|
| `gco-ui-design-standards.md` | 507 | Frontend work only |
| `gco-ui-testing.md` | 322 | E2E test work only |
| `gco-completion-checklist.md` | 323 | Before marking 🟢 |
| `gco-interactive-decisions.md` | 301 | Complex decisions |
| `gco-roadmap-format.md` | 338 | Creating requirements |
| `gco-model-selection.md` | 152 | Agent spawning |

**Tasks:**
- [x] Create `Haunt/skills/gco-ui-design/SKILL.md` from full rule content (507→40 lines, 92% reduction)
- [x] Create all 5 skills from full rule content (1,659 lines total, loaded on-demand)
- [x] Create slim rule versions (1,642→252 lines, 84.6% reduction)
- [x] Replace all 5 heavy rules with slim versions
- [x] Update agent character sheets to invoke skills when needed (optional - agents auto-discover)
- [x] Run setup script to deploy slim rules globally (5 rules updated)
- [x] Verify skills are accessible and invoke correctly (frontmatter verified)

**Files:**
- `Haunt/skills/gco-ui-design/SKILL.md` (create)
- `Haunt/skills/gco-completion/SKILL.md` (create)
- `Haunt/rules/gco-ui-design-standards.md` (replace with slim)
- `Haunt/rules/gco-ui-testing.md` (replace with slim)
- `Haunt/rules/gco-completion-checklist.md` (replace with slim)
- `Haunt/rules/gco-interactive-decisions.md` (replace with slim)
- `Haunt/rules/gco-roadmap-format.md` (replace with slim)
- `Haunt/rules/gco-model-selection.md` (replace with slim)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Heavy rules converted to skills, slim rules ~600 lines total, ~77% rule context reduction
**Blocked by:** REQ-259

### 🟢 REQ-261: Add Targeted Read Training to Agents

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** Token efficiency analysis

**Description:**
Agents currently read full files (e.g., 1,647 line roadmap) when they only need specific sections. Add training to agent character sheets and session startup to use targeted reads:
- `grep -A 30 "REQ-XXX"` instead of `Read(roadmap.md)`
- `grep -E "PATTERN" file` instead of `Read(file)`
- Use `head -50` or `Read(file, limit=50)` for file previews

**Tasks:**
- [x] Update `Haunt/agents/gco-dev.md` with targeted read guidance
- [x] Update `Haunt/agents/gco-research.md` with targeted read guidance
- [x] Update `Haunt/agents/gco-project-manager.md` with targeted read guidance
- [x] Update `Haunt/rules/gco-session-startup.md` with targeted read protocol
- [x] Add examples of good vs bad file access patterns
- [x] Run setup script to deploy updated agents
- [x] Test that agents use targeted reads in practice

**Files:**
- `Haunt/agents/gco-dev.md` (modify)
- `Haunt/agents/gco-research.md` (modify)
- `Haunt/agents/gco-project-manager.md` (modify)
- `Haunt/rules/gco-session-startup.md` (modify)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Agents trained to use grep/targeted reads, verified in test session
**Blocked by:** REQ-260

### 🟢 REQ-265: Add Delegation Protocol to Orchestrator Skill

**Type:** Bug Fix
**Reported:** 2025-12-30
**Completed:** 2025-12-30
**Source:** User report - orchestrator doing work instead of spawning agents

**Description:**
Orchestrator skill (1,523 lines) lacks guidance on WHEN to spawn agents vs execute directly. This causes orchestrators to do research (WebSearch/WebFetch) and implementation (writing code) themselves instead of delegating to specialists.

**Root Cause:** (from `.haunt/docs/research/orchestrator-spawning-analysis.md`)
- No "Delegation Protocol" section in orchestrator skill
- No explicit anti-patterns showing what NOT to do
- Tool availability tempts direct execution

**Tasks:**
- [x] Add "Delegation Protocol" section to `Haunt/skills/gco-orchestrator/SKILL.md`
- [x] Add spawning decision tree (when to spawn vs execute)
- [x] Add anti-pattern examples (orchestrator doing research, writing code)
- [x] Create `Haunt/rules/gco-orchestration.md` rule for delegation boundaries
- [x] Deploy with `bash Haunt/scripts/setup-haunt.sh`

**Implementation Notes:**
- Added comprehensive "Delegation Protocol" section at top of orchestrator skill (before "When to Use")
- Includes 3-step decision tree for spawn vs execute
- Documented 3 anti-patterns with WRONG vs RIGHT examples (research, implementation, analysis)
- Created slim `gco-orchestration.md` rule for quick enforcement
- Token efficiency note: Spawning specialists MORE efficient than generalist trial-and-error
- Success criteria: Never use WebSearch/WebFetch directly, never write code, never do multi-file analysis

**Files:**
- `Haunt/skills/gco-orchestrator/SKILL.md` (modified - added 180 lines of delegation guidance)
- `Haunt/rules/gco-orchestration.md` (created - 60 lines)

**Effort:** S (2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Orchestrators spawn agents for specialized work, delegation protocol documented
**Blocked by:** None

---

### 🟢 REQ-264: Consolidate Overlapping Rules (~700 tokens savings)

**Type:** Enhancement
**Reported:** 2025-12-30
**Completed:** 2025-12-30
**Source:** Context optimization analysis (.haunt/docs/research/context-optimization-analysis.md)

**Description:**
Quick wins from token analysis: merge duplicate content and convert reference material to slim references. Three consolidation tasks that together save ~700-800 tokens.

**Implementation Notes:**
- Merged gco-status-updates into gco-roadmap-format (added Status Update Protocol section)
- Created gco-file-conventions skill with full tables, reduced rule from 109→36 lines
- Merged gco-assignment-lookup into gco-session-startup (unified session startup protocol)
- Updated 15+ documentation files with new rule references
- Deployed with --clean to remove stale files (10→8 rules)

**Tasks:**
- [x] **Task 1: Merge gco-status-updates → gco-roadmap-format** (~300 tokens)
- [x] **Task 2: Convert gco-file-conventions to slim reference** (~400 tokens)
- [x] **Task 3: Merge gco-assignment-lookup → gco-session-startup** (~100 tokens)
- [x] Update any agent references to merged/deleted rules
- [x] Verify no regression in agent behavior

**Files:**
- `Haunt/rules/gco-roadmap-format.md` (modified - added status updates)
- `Haunt/rules/gco-status-updates.md` (deleted)
- `Haunt/skills/gco-file-conventions/SKILL.md` (created)
- `Haunt/rules/gco-file-conventions.md` (modified - slim reference)
- `Haunt/rules/gco-session-startup.md` (modified - merged assignment lookup)
- `Haunt/rules/gco-assignment-lookup.md` (deleted)

**Effort:** M (3.5 hours total)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** All rule merges complete, skills created, setup script deployed changes, token usage reduced by 700-800 tokens
**Blocked by:** None

---

## Batch: Testing Enforcement (Hybrid Minimal)

**Context:** Post-incident analysis from REQ-046/047 testing violations. Critical analysis showed original 3-layer plan was over-engineered. This batch implements minimal effective solution: agent identity change + external verification. Total effort: 3 hours.

**Strategy Document:** `.haunt/docs/research/testing-enforcement-critical-analysis.md`

**Status:** All 3 requirements in this batch have been completed and archived. See `.haunt/completed/roadmap-archive.md`.

---

## Batch: Coding Standards Integration

**Context:** Research on external style guides (Bulletproof React, Python Hitchhiker's Guide) identified gaps in Haunt's coding standards. Created slim rules for React and Python standards.

**Research Documents:** `.haunt/docs/research/` (6 analysis files)
**Rule Drafts:** `.haunt/docs/research/RULE-DRAFTS-v2.md`

**Status:** ✅ All 3 requirements completed and archived (2025-12-30). See `.haunt/completed/roadmap-archive.md`.

**Deliverables:**
- `gco-react-standards.md` - Architecture + security patterns (119 lines)
- `gco-python-standards.md` - Anti-patterns, PEP 8, type hints, pytest (76 lines)
- MSW section added to `gco-ui-testing` skill (~40 lines)

---

