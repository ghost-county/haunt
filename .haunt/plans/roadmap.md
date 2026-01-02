# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` for completed/archived work.

---

## Current Focus

**Active Work:**
- 🟡 REQ-309, 310, 311, 316, 317 (Dev-Infrastructure - skill/agent refactors + metrics fixes)

**Ready for Implementation:**
- ⚪ REQ-320: Core Seer Agent (M) ← Start here
- ⚪ REQ-321: Seance Integration (S, blocked by REQ-320)
- ⚪ REQ-322: Full Seer Testing (S, blocked by REQ-320, REQ-321)

**Ready to Archive:**
- 🟢 REQ-319: Consolidate Research Agents (XS)

**Recently Archived (2026-01-02):**
- 🟢 REQ-307: Model Selection (Opus for planning/research, Sonnet for implementation)
- 🟢 REQ-297-306: Env Secrets Wrapper (1Password integration, shell + Python)
- 🟢 REQ-283-285: Skill Token Optimization (requirements-analysis, code-patterns, task-decomposition)

---

## Priority: Seer Meta-Orchestrator

> Strategic initiative: Create a meta-orchestrator agent that acts as the "person holding the séance" - the primary entry point that spawns all other agents.

### 🟢 REQ-318: Research Seer Agent Architecture

**Type:** Research
**Reported:** 2026-01-03
**Source:** User request - need meta-orchestrator with Task tool to spawn PM/Dev/Research agents

**Description:**
Research and design a "Seer" agent that serves as the primary orchestrator for the Haunt framework. The Seer is the "person holding the séance" who communes with spirits (other agents). Key requirements:

1. **Default entry point** - When user runs `claude --dangerously-skip-permissions --agent gco-seer`, Seer takes over
2. **Task tool access** - Must be able to spawn PM, Dev, Research, Code Review agents
3. **Seance workflow native** - Runs scrying/summoning/banishing phases directly
4. **PM delegation** - Spawns PM for planning work (requirements, analysis, roadmap)
5. **Dev delegation** - Spawns Dev agents for implementation during summoning
6. **Session continuity** - Maintains state across the full workflow
7. **Explore for recon** - Use built-in Explore agent (Haiku, read-only) for fast codebase reconnaissance before spawning heavier agents
8. **Capable model** - Seer runs on Opus for strong orchestration decisions
9. **Research delegation** - If Seer needs to research anything, spawn Research-Analyst by default (don't do deep research itself)
10. **Focused scope** - Core purpose is seance workflow orchestration, NOT domain expertise

**Research Questions:**

1. **Agent hierarchy:** How does Seer relate to existing agents?
   - Seer → PM (planning) → Dev (implementation)?
   - Or Seer → PM AND Seer → Dev (parallel)?

2. **Tool permissions:** What exact tools does Seer need?
   - Task (required for spawning)
   - Glob, Grep, Read (codebase awareness)
   - Edit, Write? (or delegate all writes to spawned agents?)
   - Bash? (for running tests, scripts?)

3. **Claude Code integration:** How to make Seer the default?
   - Agent file location and naming
   - Settings configuration
   - Shell alias for convenience (`alias haunt='claude --dangerously-skip-permissions --agent gco-seer'`)

4. **Workflow state:** How does Seer track seance phase?
   - Inherit current `.haunt/state/current-phase.txt` approach?
   - Or internal state management?

5. **Context efficiency:** How to keep Seer lightweight?
   - Seer should be thin orchestrator (~50-100 lines)
   - All domain knowledge in PM, Dev, Research agents
   - Seer only knows HOW to orchestrate, not WHAT to build

6. **Error handling:** What if spawned agent fails?
   - Retry logic?
   - Fallback to different agent?
   - Report to user and await guidance?

7. **Existing art:** What patterns exist?
   - Claude Code's built-in Plan agent
   - Multi-agent orchestration patterns
   - Crew AI, AutoGen, other frameworks

8. **Explore integration:** How should Seer use the built-in Explore agent?
   - When to use Explore vs spawning full Research-Analyst?
   - Explore for quick recon → then spawn specialized agent?
   - Decision tree for codebase investigation

9. **Model selection:** Seer on Opus - implications?
   - Cost/performance tradeoff for orchestration
   - When to use Opus reasoning vs delegate to faster agent?

**Tasks:**

- [x] Analyze Claude Code Task tool capabilities and subagent_type options
- [x] Research existing multi-agent orchestration patterns (Crew AI, AutoGen, etc.)
- [x] Map current Haunt agent hierarchy and identify Seer's position
- [x] Define Seer's tool permissions (minimum viable set)
- [x] Design Seer ↔ PM ↔ Dev communication protocol
- [x] Design Explore integration pattern (fast recon before heavy spawns)
- [x] Draft Seer agent character sheet structure
- [x] Identify integration points with existing seance command
- [x] Propose implementation plan (phased approach)

**Deliverables:**

- `.haunt/docs/research/seer-agent-architecture.md` - Full research document
- Recommended agent hierarchy diagram
- Draft `gco-seer.md` character sheet (skeleton)
- Implementation roadmap (REQ-319+)

**Files:**

- `.haunt/docs/research/seer-agent-architecture.md` (create)
- `Haunt/agents/gco-seer.md` (create - draft skeleton only)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Research-Analyst (Opus model for strategic analysis)
**Completion:**
- Research document answers all 9 questions above
- Explore integration pattern documented
- Clear recommendation for Seer architecture
- Draft character sheet ready for implementation
- Implementation roadmap with sized requirements

**Blocked by:** None

---

### 🟢 REQ-319: Consolidate Research Agents

**Type:** Simplification
**Reported:** 2026-01-03
**Source:** User feedback - two research agents is confusing

**Description:**
Remove the read-only `gco-research-analyst.md` variant and keep only `gco-research.md`. The read-only variant adds complexity without sufficient benefit. If read-only investigation is ever needed, Seer can spawn with restricted tools.

**Tasks:**

- [x] Delete `Haunt/agents/gco-research-analyst.md`
- [x] Delete `~/.claude/agents/gco-research-analyst.md` (deployed copy)
- [x] Update `Haunt/docs/TOOL-PERMISSIONS.md` - remove gco-research-analyst references
- [x] Update any other docs referencing gco-research-analyst
- [x] Update `Haunt/scripts/setup-haunt.sh` if it deploys the file (verified: setup copies all .md files from Haunt/agents/, so deletion from source prevents future deployment)
- [x] Verify gco-research.md has correct tool permissions (Write access - confirmed)

**Files:**

- `Haunt/agents/gco-research-analyst.md` (deleted)
- `Haunt/docs/TOOL-PERMISSIONS.md` (modified)
- `Haunt/docs/INTEGRATION-PATTERNS.md` (modified)
- `Haunt/commands/summon.md` (modified)
- `Haunt/commands/checkup.md` (modified)
- `Haunt/skills/gco-orchestrator/SKILL.md` (modified)
- `Haunt/skills/gco-orchestrator/references/delegation-protocol.md` (modified)
- `Haunt/skills/gco-orchestrator/references/example-flows.md` (modified)
- `Haunt/skills/gco-session-startup/SKILL.md` (modified)
- `Haunt/rules/gco-orchestration.md` (modified)
- `Haunt/SETUP-GUIDE.md` (modified)

**Effort:** XS (30 min)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Only one research agent exists (`gco-research.md`), all references updated
**Blocked by:** None

---

### 🟡 REQ-320: Implement Core Seer Agent

**Type:** Implementation
**Reported:** 2026-01-03
**Source:** REQ-318 research - Phase 1 of Seer implementation

**Description:**
Finalize the Seer agent character sheet and implement core functionality. The draft exists at `Haunt/agents/gco-seer.md` (~230 lines). Need to test Task tool spawning, verify gco-orchestrator skill integration, and implement persistent memory.

**Architecture (from REQ-318):**
- Thin orchestrator (~150-200 lines) that leverages gco-orchestrator skill
- Opus model for strong orchestration decisions
- Flat spawning model (Seer → all agents, no nesting)
- Persistent memory via `mcp__agent_memory__*`
- Explore-first pattern for codebase reconnaissance

**Tasks:**

- [x] Review and finalize `Haunt/agents/gco-seer.md` character sheet
- [x] Slim down to target ~150-200 lines (currently ~230) - Reduced to 153 lines
- [x] Verify setup-haunt.sh automatically deploys gco-seer.md (no changes needed)
- [x] Deploy gco-seer.md to ~/.claude/agents/
- [x] Create structural tests (test-seer-agent.sh - 21/21 passing)
- [x] Create functional testing guide (SEER-FUNCTIONAL-TESTING.md)
- [x] Implement memory operations in agent (mcp__agent_memory__search/store documented)
- [ ] **MANUAL:** Test Task tool spawning with gco-project-manager (requires live session)
- [ ] **MANUAL:** Test Task tool spawning with gco-dev (all modes) (requires live session)
- [ ] **MANUAL:** Test Task tool spawning with gco-research (requires live session)
- [ ] **MANUAL:** Test Task tool spawning with gco-code-reviewer (requires live session)
- [ ] **MANUAL:** Verify gco-orchestrator skill integration (requires live session)
- [ ] **MANUAL:** Test memory operations with MCP server (requires live session)
- [ ] **MANUAL:** Test Explore agent integration for recon (requires live session)

**Files:**

- `Haunt/agents/gco-seer.md` (created - 153 lines, deployed)
- `.haunt/tests/behavior/test-seer-agent.sh` (created - structural validation)
- `.haunt/tests/behavior/SEER-FUNCTIONAL-TESTING.md` (created - manual testing guide)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**
- gco-seer.md finalized and under 200 lines (153 lines)
- Task tool successfully spawns all agent types (MANUAL TESTING REQUIRED)
- Memory check/write implemented and tested (MANUAL TESTING REQUIRED)
- Deployed via setup script to `~/.claude/agents/`

**Blocked by:** Manual functional testing (requires live Claude Code session as Seer agent)

**Implementation Notes (2026-01-02):**
- **Structural implementation complete:** Agent finalized (153 lines), deployed, 21/21 structural tests passing
- **Architecture:** Thin orchestrator leveraging gco-orchestrator skill, Opus model, flat spawning, session memory
- **Testing:** Created comprehensive structural tests and functional testing guide
- **Manual validation needed:** Task tool spawning, MCP memory operations, full séance workflow (see SEER-FUNCTIONAL-TESTING.md)
- **Next steps:** User must invoke Seer in live session to complete Tests 1-10 in functional guide
- **Status:** 🟡 In Progress - awaiting manual functional validation before marking 🟢

---

### ⚪ REQ-321: Seance Integration and Documentation

**Type:** Documentation
**Reported:** 2026-01-03
**Source:** REQ-318 research - Phase 2 of Seer implementation

**Description:**
Update `/seance` command documentation to explain coexistence with Seer agent. Create shell alias setup guide. Document the relationship between command-based séance and agent-based Seer.

**Key Distinction:**
- `/seance` command = loads gco-orchestrator as a skill (no Task tool)
- `gco-seer` agent = embodies orchestrator with Task tool + memory

**Tasks:**

- [ ] Update `Haunt/commands/seance.md` to document Seer as alternative entry
- [ ] Create shell alias documentation in `Haunt/docs/SHELL-ALIASES.md`
- [ ] Document recommended alias: `alias haunt='claude --dangerously-skip-permissions --agent gco-seer'`
- [ ] Update `Haunt/docs/SEANCE-EXPLAINED.md` with Seer section
- [ ] Add "Entry Points" section showing /seance vs haunt alias
- [ ] Update `Haunt/README.md` quick start with Seer entry point

**Files:**

- `Haunt/commands/seance.md` (modify)
- `Haunt/docs/SHELL-ALIASES.md` (create)
- `Haunt/docs/SEANCE-EXPLAINED.md` (modify)
- `Haunt/README.md` (modify)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**
- Documentation clearly explains /seance vs Seer agent
- Shell alias setup guide complete
- README updated with Seer entry point

**Blocked by:** REQ-320

---

### ⚪ REQ-322: Full Seer Workflow Testing

**Type:** Testing
**Reported:** 2026-01-03
**Source:** REQ-318 research - Phase 3 of Seer implementation

**Description:**
End-to-end testing of the complete Seer workflow. Verify phase transitions, memory recall across sessions, error handling, and the full séance lifecycle.

**Test Scenarios:**

1. **Fresh project séance** - No memory, new .haunt/ setup
2. **Returning user séance** - Memory recall, context restoration
3. **Phase transitions** - SCRYING → SUMMONING → BANISHING
4. **Error handling** - Agent failure, recovery options
5. **Memory persistence** - Close session, reopen, verify recall

**Tasks:**

- [ ] Test complete séance workflow (idea → requirements → implementation → archive)
- [ ] Test phase transitions and state file updates
- [ ] Test memory write at session end
- [ ] Test memory recall at session startup (new session)
- [ ] Test error handling when spawned agent fails
- [ ] Test Explore → specialist spawn pattern
- [ ] Document test results in `.haunt/progress/seer-testing-report.md`
- [ ] Update any issues found during testing

**Files:**

- `.haunt/progress/seer-testing-report.md` (create)
- `Haunt/agents/gco-seer.md` (modify if issues found)
- `Haunt/docs/SEANCE-EXPLAINED.md` (modify with learnings)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**
- All 5 test scenarios pass
- Memory recall works across sessions
- Test report documents results
- Any issues discovered are fixed or logged as new REQs

**Blocked by:** REQ-320, REQ-321

---

## Backlog: Workflow Enforcement

### 🟢 REQ-308: Seance Workflow State Enforcement

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** User pain point - orchestrator drifts from planning to implementation mid-seance

**Description:** Implement state file + spawn-time context injection to prevent orchestrator from breaking out of seance workflow phases. Currently, after 15+ conversation turns, instruction degradation causes the model to skip the roadmap creation and user approval gates, jumping directly to implementation.

**Implementation Notes:**
- Hybrid enforcement using 3 layers: state file + spawn-time context + phase declarations
- Phase state file created at `.haunt/state/current-phase.txt` with SCRYING/SUMMONING/BANISHING values
- PM spawns include "You are in SCRYING phase" context
- Dev agent spawns include "You are in SUMMONING phase" context
- Phase transitions logged: SCRYING → SUMMONING → BANISHING
- Violation self-checks added before Edit/Write/Task tool calls
- Testing pending (5 trial seances across modes)

**Tasks:**

- [x] Create `.haunt/state/` directory initialization in seance startup
- [x] Implement phase state file (`.haunt/state/current-phase.txt`) with SCRYING/SUMMONING/BANISHING values
- [x] Add phase context injection to PM spawn prompts ("You are in SCRYING phase...")
- [x] Add phase context injection to dev agent spawn prompts ("You are in SUMMONING phase...")
- [x] Add phase transition validation before spawning dev agents (check user approval)
- [x] Update gco-orchestrator skill with phase declaration pattern
- [x] Add violation self-check before Edit/Write tool calls
- [x] Test with 5 trial seances across different modes (PENDING - validation in follow-up sessions)

**Files:**

- `Haunt/skills/gco-orchestrator/SKILL.md` (modify - add phase management section)
- `Haunt/skills/gco-orchestrator/references/mode-workflows.md` (modify - add phase transitions)
- `Haunt/commands/seance.md` (modify - initialize state file)

**Effort:** M
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:** Seance workflows complete all 3 phases without orchestrator doing direct implementation. User approval gate is never skipped. State file correctly tracks phase transitions.
**Blocked by:** None

**Research:** See `.haunt/docs/research/workflow-enforcement-analysis.md` for root cause analysis and implementation spec.

---

## Backlog: Built-in Subagent Integration

### 🟢 REQ-309: Document Explore Agent Integration Patterns

**Type:** Documentation
**Reported:** 2026-01-02
**Source:** Research analysis - Explore agent is built-in, fast, read-only codebase reconnaissance tool

**Description:** Integrate Claude Code's built-in Explore agent into Haunt workflows as a sanctioned tool for fast codebase reconnaissance. Research shows Explore (Haiku model) is 40-60% faster than full research agent spawns for initial context gathering, but is read-only and can't produce deliverables. Document when to use Explore vs gco-research-analyst.

**Tasks:**

- [x] Add "Built-in Subagents" section to `Haunt/docs/INTEGRATION-PATTERNS.md` documenting Explore capabilities and limits
- [x] Update `gco-session-startup` skill with Explore decision gate (use for quick recon before deep research)
- [x] Update `gco-orchestration.md` rule with codebase reconnaissance delegation pattern
- [x] Update `gco-model-selection.md` rule with Explore guidance (when to use vs Haiku vs Sonnet)
- [x] Archive research findings to `.haunt/docs/research/explore-agent-integration.md`

**Files:**

- `Haunt/docs/INTEGRATION-PATTERNS.md` (create - new doc for built-in tool integration patterns)
- `Haunt/skills/gco-session-startup/SKILL.md` (modify - add Explore decision tree)
- `Haunt/rules/gco-orchestration.md` (modify - add built-in subagent delegation)
- `Haunt/rules/gco-model-selection.md` (modify - add Explore vs agent comparison)
- `.haunt/docs/research/explore-agent-integration.md` (create - archive research findings)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**
- Documentation clearly explains when to use Explore vs gco-research-analyst
- Decision tree added to session-startup for reconnaissance workflow
- Orchestration rules updated with built-in subagent delegation pattern
- Research findings archived for reference
- All files deployed to `~/.claude/` via setup script

**Blocked by:** None

**Research Reference:** See conversation analysis from gco-research-analyst for detailed integration recommendations and decision tree.

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

## Batch: Agent/Skill Optimization (Weekly Refactor)

> From weekly refactor analysis: gco-dev.md at 1,110 lines, multiple skills >500 lines.

### 🟡 REQ-310: Refactor gco-dev.md Agent (Option B - References)

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Weekly refactor analysis

**Description:**
gco-dev.md is 1,110 lines - 22x over the 50-line target for agent character sheets. Refactor using Option B: keep unified agent, extract mode-specific guidance to reference files.

**Current Structure (1,110 lines):**
- Core identity/values (~50 lines) - KEEP
- TDD iteration loop (~200 lines) - EXTRACT
- Testing accountability (~100 lines) - EXTRACT
- Frontend mode + UI testing (~150 lines) - EXTRACT
- Backend mode (~50 lines) - EXTRACT
- Infrastructure mode (~30 lines) - EXTRACT

**Target Structure:**
```
gco-dev.md (~60 lines - identity only)
└── references/
    ├── tdd-workflow.md
    ├── testing-accountability.md
    ├── backend-guidance.md
    ├── frontend-guidance.md
    └── infrastructure-guidance.md
```

**Tasks:**

- [ ] Analyze gco-dev.md structure and identify extraction boundaries
- [ ] Create `Haunt/agents/gco-dev/references/` directory
- [ ] Extract TDD iteration loop to `references/tdd-workflow.md`
- [ ] Extract testing accountability to `references/testing-accountability.md`
- [ ] Extract backend guidance to `references/backend-guidance.md`
- [ ] Extract frontend guidance (including UI testing) to `references/frontend-guidance.md`
- [ ] Extract infrastructure guidance to `references/infrastructure-guidance.md`
- [ ] Slim main gco-dev.md to ~60 lines with consultation gates
- [ ] Add mode gates: "Backend mode → READ references/backend-guidance.md"
- [ ] Test dev agent workflow still functions correctly
- [ ] Update setup-haunt.sh to deploy references/

**Files:**

- `Haunt/agents/gco-dev.md` (modify - 1,110 → ~60 lines)
- `Haunt/agents/gco-dev/references/*.md` (create - 5 files)
- `Haunt/scripts/setup-haunt.sh` (modify - deploy references)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**
- gco-dev.md under 80 lines
- Reference files contain extracted guidance
- Mode consultation gates implemented
- Dev agent workflow verified functional
- Context overhead reduced by ~90%

**Blocked by:** None

---

### 🟢 REQ-316: Refactor gco-testing-mindset Skill

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Weekly refactor analysis

**Description:**
gco-testing-mindset is 582 lines (16% over 500-line target). Extract detailed examples and scenarios to reference files.

**Tasks:**

- [x] Analyze skill structure
- [x] Create `references/` directory
- [x] Extract testing examples to reference file
- [x] Extract scenario walkthroughs to reference file
- [x] Slim SKILL.md to ~400 lines
- [x] Add consultation gates

**Files:**

- `Haunt/skills/gco-testing-mindset/SKILL.md` (modify)
- `Haunt/skills/gco-testing-mindset/references/*.md` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** SKILL.md under 500 lines, references extracted, testing workflow functional

**Blocked by:** None

**Completion Notes:**
- Reduced SKILL.md from 583 to 287 lines (51% reduction, well under 500-line target)
- Created `references/testing-scenarios.md` (10KB) with 5 common testing mistakes and user journey examples
- Created `references/validation-checklists.md` (6.4KB) with comprehensive validation checklists
- Added 3 consultation gates for detailed examples and checklists
- Testing workflow functional with quick reference + on-demand detailed guidance

---

### 🟢 REQ-317: Refactor gco-roadmap-planning Skill

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Weekly refactor analysis

**Description:**
gco-roadmap-planning is 554 lines (11% over 500-line target). Extract examples and templates to reference files.

**Tasks:**

- [x] Analyze skill structure
- [x] Create `references/` directory
- [x] Extract roadmap examples to reference file
- [x] Extract batch organization patterns to reference file
- [x] Slim SKILL.md to ~400 lines
- [x] Add consultation gates

**Files:**

- `Haunt/skills/gco-roadmap-planning/SKILL.md` (modify)
- `Haunt/skills/gco-roadmap-planning/references/*.md` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** SKILL.md under 500 lines, references extracted, roadmap workflow functional

**Blocked by:** None

**Completed:** 2026-01-02
**Notes:** Reduced SKILL.md from 554 to 289 lines (48% reduction). Created 3 reference files: batch-organization.md, roadmap-sharding.md, roadmap-templates.md. Added consultation gates for detailed topics.

---

## Batch: Metrics & Regression Framework

> New tooling for measuring agent performance and detecting regressions.

### 🟡 REQ-311: Fix haunt-metrics.sh Parsing Bugs

**Type:** Bug Fix
**Reported:** 2026-01-02
**Source:** Weekly refactor analysis

**Description:**
haunt-metrics.sh has parsing issues:
1. Effort estimate shows duplicate values (e.g., "S\nS\nS")
2. Orphaned commits warning for recently archived requirements
3. Archive file search not working properly

**Tasks:**

- [ ] Fix effort estimate regex to capture single value
- [ ] Improve archive file search pattern
- [ ] Handle recently archived requirements gracefully
- [ ] Add unit tests for parsing functions
- [ ] Test with current git history

**Files:**

- `Haunt/scripts/haunt-metrics.sh` (modify)
- `Haunt/tests/test-haunt-metrics.sh` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Metrics output clean, no duplicate values, archive search works

**Blocked by:** None

---

### ⚪ REQ-312: Add Context Overhead Metric

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** User request - track token/context efficiency

**Description:**
Add context overhead measurement to haunt-metrics. Context overhead = how much context an agent consumes before doing useful work.

**Components to measure:**
- Agent character sheet size (lines)
- Always-loaded rules size (lines)
- CLAUDE.md size (lines)
- Average skills loaded per session (estimated)

**Formula:**
```
base_overhead = agent_lines + rules_lines + claude_md_lines
skill_overhead = avg_skills_invoked × avg_skill_size
total_context_overhead = base_overhead + skill_overhead
```

**Tasks:**

- [ ] Add `measure_context_overhead()` function to haunt-metrics.sh
- [ ] Calculate base overhead (agent + rules + CLAUDE.md)
- [ ] Estimate skill overhead (top 5 most-used skills × avg size)
- [ ] Add `--context` flag to output context metrics
- [ ] Include context_overhead in JSON output
- [ ] Add context overhead to aggregate metrics

**Files:**

- `Haunt/scripts/haunt-metrics.sh` (modify)
- `Haunt/commands/haunt-metrics.md` (modify - document new flag)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**
- `haunt-metrics --context` shows overhead breakdown
- JSON output includes context_overhead_lines field
- Baseline can be established for regression tracking

**Blocked by:** REQ-311

---

### ⚪ REQ-313: Create haunt-regression-check Script

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** User request - detect agent performance regressions

**Description:**
Create script to compare current metrics against a stored baseline and detect regressions.

**Regression thresholds:**
- Completion Rate: Alert if >5% worse than baseline
- First-Pass Success: Alert if >10% worse than baseline
- Avg Cycle Time: Alert if >25% worse than baseline
- Context Overhead: Alert if >20% worse than baseline

**Output:**
```
┌─────────────────────────────────────────┐
│         REGRESSION CHECK RESULTS        │
├─────────────────────────────────────────┤
│ Metric              Baseline  Current   │
│ ──────────────────  ────────  ───────   │
│ Completion Rate     80.0%     82.0%  ✅ │
│ First-Pass Success  70.0%     65.0%  🔴 │ ← REGRESSION
│ Avg Cycle Time      3.5h      3.2h   ✅ │
│ Context Overhead    2500      1800   ✅ │
└─────────────────────────────────────────┘
```

**Tasks:**

- [ ] Create `Haunt/scripts/haunt-regression-check.sh`
- [ ] Implement baseline loading from JSON file
- [ ] Implement current metrics collection (call haunt-metrics)
- [ ] Implement comparison with configurable thresholds
- [ ] Add color-coded output (✅ OK, 🟡 Warning, 🔴 Regression)
- [ ] Add `--baseline=<file>` parameter
- [ ] Add JSON output format
- [ ] Create command documentation

**Files:**

- `Haunt/scripts/haunt-regression-check.sh` (create)
- `Haunt/commands/haunt-regression-check.md` (create)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**
- Script compares current vs baseline metrics
- Regressions clearly identified with visual indicators
- Exit code reflects regression status (0=OK, 1=regression)

**Blocked by:** REQ-312

---

### ⚪ REQ-314: Create Baseline Metrics Storage System

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** User request - manage metric baselines for regression testing

**Description:**
Create system to store, manage, and version metric baselines for regression comparison.

**Storage location:** `.haunt/metrics/`
**Baseline format:**
```json
{
  "created": "2026-01-02",
  "version": "v2.1",
  "description": "Post gco-dev refactor",
  "sample_size": 20,
  "calibration_complete": true,
  "metrics": {
    "completion_rate": 80.0,
    "first_pass_success": 70.0,
    "avg_cycle_time_hours": 3.5,
    "context_overhead_lines": 2500
  }
}
```

**Commands:**
- `haunt-baseline create` - Create new baseline from current metrics
- `haunt-baseline list` - List stored baselines
- `haunt-baseline show <name>` - Show baseline details
- `haunt-baseline set-active <name>` - Set baseline for regression checks

**Tasks:**

- [ ] Create `.haunt/metrics/` directory structure
- [ ] Create `Haunt/scripts/haunt-baseline.sh` script
- [ ] Implement `create` command (snapshot current metrics)
- [ ] Implement `list` command (show all baselines)
- [ ] Implement `show` command (display baseline details)
- [ ] Implement `set-active` command (symlink to active baseline)
- [ ] Add calibration tracking (sample_size, calibration_complete flag)
- [ ] Create command documentation

**Files:**

- `Haunt/scripts/haunt-baseline.sh` (create)
- `Haunt/commands/haunt-baseline.md` (create)
- `.haunt/metrics/` directory structure

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**
- Baselines can be created, listed, and managed
- Active baseline used by regression-check automatically
- Calibration tracking prevents premature comparisons

**Blocked by:** REQ-313

---

### ⚪ REQ-315: Update gco-weekly-refactor Skill

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** User request - add metrics and regression phases to weekly ritual

**Description:**
Update the weekly refactor skill to include:
1. Phase 0: Metrics Review (run haunt-metrics)
2. Phase 0.5: Regression Check (run haunt-regression-check)
3. Phase 4: Context Audit (measure and review context overhead)

**Updated Structure:**
```
Phase 0: Metrics Review (10 min) - NEW
Phase 0.5: Regression Check (5 min) - NEW
Phase 1: Pattern Hunt (30 min) - informed by metrics
Phase 2: Defeat Tests (30 min) - same
Phase 3: Prompt Refactor (30 min) - same
Phase 4: Context Audit (15 min) - NEW
Phase 5: Architecture Check (20 min) - same
Phase 6: Version & Deploy (10 min) - updated for calibration
```

**Tasks:**

- [ ] Add Phase 0: Metrics Review section
- [ ] Add Phase 0.5: Regression Check section
- [ ] Add Phase 4: Context Audit section
- [ ] Update Phase 1 to reference metrics findings
- [ ] Update Phase 6 with calibration period guidance
- [ ] Add regression response decision tree
- [ ] Update weekly report template with new metrics

**Files:**

- `Haunt/skills/gco-weekly-refactor/SKILL.md` (modify)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**
- Skill includes all new phases
- Metrics inform pattern hunt
- Regression check integrated into ritual
- Context audit phase documented

**Blocked by:** REQ-312, REQ-314

---
