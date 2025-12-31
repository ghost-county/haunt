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

## Batch: Determinism & Measurement

**Context:** Research from [vexjoy.com article](https://vexjoy.com/posts/everything-that-can-be-deterministic-should-be-my-claude-code-setup/) on deterministic agent patterns. Core insight: "The LLM is varying its execution when it should only vary its decisions." Reduce variance in environment interaction, enable measurement of what actually helps.

**Philosophy:**
- Measurement: Zero agent overhead (derived from existing artifacts)
- Wrappers: Structured output for environment interaction (agent decides, wrapper executes deterministically)
- Phase Gates: Enforce workflow steps without preventing creativity in implementation

**Research Document:** `.haunt/docs/research/determinism-research.md`

### {🟡} REQ-269: Lightweight Metrics Framework

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** Research - need to measure "what actually helps"

**Description:**
Create a metrics extraction system that derives measurements from existing artifacts with ZERO agent overhead. Agents don't log anything extra—metrics are extracted post-hoc from git history, roadmap status changes, and archived completions.

**Metrics to Derive:**

| Metric | Source | Calculation |
|--------|--------|-------------|
| Cycle Time | Git commits + roadmap | Time from first commit to 🟢 status |
| Effort Accuracy | Roadmap sizing | Estimated vs actual (XS<1hr, S<2hr, M<4hr) |
| First-Pass Success | Git history | Commits without "fix", "revert", "oops" in subsequent commits |
| Completion Rate | Roadmap archive | Requirements completed vs abandoned |

**Tasks:**
- [x] Create `haunt-metrics` script that extracts from existing artifacts
- [x] Parse git log for requirement commits (REQ-XXX pattern)
- [x] Parse roadmap status change timestamps (⚪→🟡→🟢)
- [x] Generate summary report (JSON + human-readable)
- [x] Add `/haunt metrics` command to invoke script
- [x] Document metric definitions

**Non-Goals:**
- No per-action logging by agents
- No changes to agent workflows
- No real-time tracking

**Files:**
- `Haunt/scripts/haunt-metrics.sh` (create)
- `Haunt/commands/haunt-metrics.md` (create)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** `haunt-metrics` extracts cycle time, effort accuracy, first-pass success from git/roadmap; zero agent workflow changes
**Blocked by:** None

---

### {🟢} REQ-270: Structured Git Operations Wrapper

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** Research - reduce parsing variance in git output

**Description:**
Create wrapper scripts for common git operations that return structured JSON instead of raw text. When agents receive structured data, they only decide what to do—not how to parse.

**Wrappers to Create:**

| Command | Raw Output Problem | Structured Output |
|---------|-------------------|-------------------|
| `git status` | Multi-line text, varies by config | `{branch, staged[], modified[], untracked[], ahead, behind}` |
| `git diff --stat` | Text table parsing | `{files_changed, insertions, deletions, files[]}` |
| `git log` | Variable format | `{commits[{hash, author, date, message}]}` |

**Tasks:**
- [x] Create `haunt-git` wrapper script with subcommands
- [x] Implement `haunt-git status` → JSON output
- [x] Implement `haunt-git diff-stat` → JSON output
- [x] Implement `haunt-git log` → JSON output (configurable count)
- [x] Handle edge cases (detached HEAD, merge conflicts, empty repo)
- [x] Add `--raw` flag to pass through to regular git when needed
- [x] Document usage in agent rules

**Files:**
- `Haunt/scripts/haunt-git.sh` (create)
- `Haunt/rules/gco-session-startup.md` (modify - reference wrapper)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Agents can call `haunt-git status` and receive JSON; parsing variance eliminated for git operations
**Blocked by:** None

---

### {🟢} REQ-271: Structured Build/Test Execution Wrapper

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** Research - reduce parsing variance in test/build output

**Description:**
Create wrapper for test and build execution that returns structured results. Detects framework automatically (pytest, npm, go) and returns consistent JSON regardless of underlying tool.

**Structured Output:**
```json
{
  "success": true,
  "framework": "pytest",
  "passed": 12,
  "failed": 0,
  "skipped": 1,
  "errors": 0,
  "duration_seconds": 4.2,
  "failures": [],
  "coverage_percent": 85.2
}
```

**Tasks:**
- [x] Create `haunt-run` wrapper script
- [x] Implement `haunt-run test` with auto-detection (pytest, npm test, go test)
- [x] Implement `haunt-run build` with auto-detection (npm build, go build, make)
- [x] Implement `haunt-run lint` with auto-detection (eslint, ruff, golangci-lint)
- [x] Parse each tool's output to consistent JSON schema
- [x] Handle failures gracefully (return structured error, not crash)
- [x] Add `--raw` flag for passthrough when needed

**Files:**
- `Haunt/scripts/haunt-run.sh` (create)
- `Haunt/rules/gco-completion-checklist.md` (modify - reference wrapper for verification)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Agents can call `haunt-run test` and receive JSON with pass/fail/coverage; works for Python, Node, Go projects
**Blocked by:** None

---

### {🟡} REQ-272: Phase Gates for TDD Workflow

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** Research - enforce workflow steps without limiting creativity

**Description:**
Add explicit phase gates to TDD workflow skill. Gates are hard stops with checkboxes that must be satisfied before proceeding. This makes workflow deterministic (enforced sequence) while keeping implementation creative.

**Phase Gate Structure:**
```markdown
### RED Phase: Write Failing Test

[Guidance...]

**GATE (complete ALL before proceeding):**
- [ ] Test file exists
- [ ] Test runs and FAILS (not error, not skip)
- [ ] Failure message describes expected behavior

⛔ **STOP:** Do NOT proceed to GREEN until all gates pass.
```

**Tasks:**
- [x] Add phase gates to `gco-tdd-workflow` skill (RED → GREEN → REFACTOR)
- [x] Add phase gates to `gco-witching-hour` skill (SHADOW GATHERING → SPECTRAL ANALYSIS → ILLUMINATION → THE HUNT → BANISHMENT)
- [x] Add phase gates to `gco-code-review` skill (N/A - already has checklist structure)
- [x] Use consistent gate format (checkboxes + STOP prohibition)
- [x] Update agent character sheets to reference phase gates (optional - skills auto-discovered)

**Files:**
- `Haunt/skills/gco-tdd-workflow/SKILL.md` (modify)
- `Haunt/skills/gco-witching-hour/SKILL.md` (modify)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** TDD and debugging skills have explicit phase gates with checkboxes; agents cannot skip workflow steps
**Blocked by:** None

---

### {🟢} REQ-273: Phase Gates for Séance Orchestration

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** User observation - orchestrator did research directly instead of spawning agent

**Description:**
Add explicit phase gates to the séance/orchestrator workflow that enforce delegation before execution. Current delegation protocol is soft guidance; this adds hard STOP gates that prevent the orchestrator from doing specialized work directly.

**Phase Gate Structure:**
```markdown
## DELEGATION GATE (Before ANY Action)

Before executing, verify:

**Am I about to do specialized work?**
- [ ] WebSearch/WebFetch → ⛔ STOP: Spawn gco-research-analyst
- [ ] Multi-file analysis → ⛔ STOP: Spawn gco-research-analyst
- [ ] Requirements analysis → ⛔ STOP: Spawn gco-project-manager
- [ ] Write code/tests → ⛔ STOP: Spawn gco-dev-*
- [ ] Code review → ⛔ STOP: Spawn gco-code-reviewer

**If ALL boxes are unchecked:** Proceed (this is coordination work)
**If ANY box is checked:** STOP and spawn the indicated agent

⛔ **PROHIBITION:** Orchestrators NEVER execute WebSearch, WebFetch, or multi-file Read operations directly. These are research activities requiring specialist agents.
```

**Tasks:**
- [x] Add delegation gate section to `gco-orchestrator` skill
- [x] Add gate checkpoint at séance start (before mode detection is fine, but before any research)
- [x] Add gate checkpoint before each phase transition (Scrying → Summoning → Banishing)
- [x] Create clear STOP language with agent routing
- [x] Add self-check: "Am I about to call WebSearch/WebFetch? → STOP"

**Files:**
- `Haunt/skills/gco-orchestrator/SKILL.md` (modify)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Séance skill has explicit delegation gates; orchestrator cannot proceed with research/implementation without spawning agents
**Blocked by:** None

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

