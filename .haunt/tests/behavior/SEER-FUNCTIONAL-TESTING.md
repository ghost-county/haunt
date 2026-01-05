# Seer Agent Functional Testing Guide

**For REQ-320: Core Seer Agent Implementation**

This document describes manual functional testing steps for the Seer agent. These tests verify Task tool spawning, memory operations, and full séance workflow integration.

---

## Prerequisites

1. **Seer agent deployed:** `~/.claude/agents/gco-seer.md` exists
2. **Orchestrator skill deployed:** `~/.claude/skills/gco-orchestrator/SKILL.md` exists
3. **Agent Memory MCP server configured:** Check `~/.config/claude/config.json` for `mcp__agent_memory__*` tools
4. **All spawnable agents deployed:** gco-project-manager, gco-dev-*, gco-research, gco-code-reviewer

---

## Test 1: Seer Agent Invocation

**Objective:** Verify Seer agent can be invoked and loads correctly.

**Steps:**
1. Open terminal
2. Run: `claude --dangerously-skip-permissions --agent gco-seer`
3. Seer should greet with memory check
4. Expected output includes: "🔮" emoji, memory search attempt, prompt for user input

**Pass Criteria:**
- ✅ Seer loads without errors
- ✅ Memory check runs (even if no previous sessions found)
- ✅ Orchestrator skill is active
- ✅ User is prompted for input

**Fail Criteria:**
- ❌ Agent fails to load
- ❌ Error: "Agent gco-seer not found"
- ❌ Missing tools (Task, mcp__agent_memory__*)

---

## Test 2: Task Tool - Spawn Project Manager

**Objective:** Verify Seer can spawn gco-project-manager using Task tool.

**Steps:**
1. Invoke Seer: `claude --dangerously-skip-permissions --agent gco-seer`
2. Provide input: "I have an idea for a new feature - user authentication with JWT"
3. Seer should enter SCRYING phase
4. Seer should spawn gco-project-manager for requirements analysis

**Pass Criteria:**
- ✅ Seer detects "new idea" mode
- ✅ Task tool invoked to spawn gco-project-manager
- ✅ PM agent receives context: "You are in SCRYING phase. User idea: ..."
- ✅ PM performs JTBD, Kano, RICE analysis
- ✅ PM generates requirements in roadmap format

**Fail Criteria:**
- ❌ Seer attempts analysis itself (should delegate to PM)
- ❌ Task tool fails with permission error
- ❌ PM not spawned or receives incorrect context

---

## Test 3: Task Tool - Spawn Dev Agent

**Objective:** Verify Seer can spawn dev agents during SUMMONING phase.

**Steps:**
1. Continue from Test 2 (or start with existing requirement)
2. User approves roadmap
3. Seer transitions to SUMMONING phase
4. Seer should spawn appropriate dev agent (gco-dev-backend, gco-dev-frontend, etc.)

**Pass Criteria:**
- ✅ Phase transition logged: SCRYING → SUMMONING
- ✅ Task tool spawns dev agent based on requirement type
- ✅ Dev agent receives: "You are in SUMMONING phase. Implement REQ-XXX."
- ✅ Dev agent implements feature, runs tests
- ✅ Dev agent returns control to Seer when complete

**Fail Criteria:**
- ❌ Seer attempts implementation itself
- ❌ Wrong dev agent type spawned
- ❌ Dev agent not informed of SUMMONING phase

---

## Test 4: Task Tool - Spawn Research Agent

**Objective:** Verify Seer delegates research to gco-research.

**Steps:**
1. Invoke Seer with research question: "Research best practices for JWT token expiration"
2. Seer should recognize research task
3. Seer should spawn gco-research agent

**Pass Criteria:**
- ✅ Seer recognizes research is needed
- ✅ Task tool spawns gco-research (not gco-research-analyst if deprecated)
- ✅ Research agent performs WebSearch/WebFetch
- ✅ Research agent returns findings to Seer
- ✅ Seer summarizes findings for user

**Fail Criteria:**
- ❌ Seer attempts WebSearch/WebFetch itself
- ❌ Research not delegated to specialist agent

---

## Test 5: Task Tool - Spawn Code Reviewer

**Objective:** Verify Seer can spawn gco-code-reviewer for review.

**Steps:**
1. Complete implementation of a requirement
2. Seer should trigger code review before archiving
3. Seer spawns gco-code-reviewer

**Pass Criteria:**
- ✅ Code review triggered for M/SPLIT requirements (per hybrid workflow)
- ✅ Task tool spawns gco-code-reviewer
- ✅ Code Reviewer receives file list and requirement context
- ✅ Code Reviewer returns verdict (APPROVED, CHANGES_REQUESTED, BLOCKED)
- ✅ Seer updates requirement status based on verdict

**Fail Criteria:**
- ❌ Code review skipped for M-sized work
- ❌ Code Reviewer not spawned

---

## Test 6: Orchestrator Skill Integration

**Objective:** Verify gco-orchestrator skill guides Seer workflow.

**Steps:**
1. Invoke Seer with various entry points:
   - New idea
   - Continue existing work
   - Roadmap work
2. Observe Seer's mode detection and workflow

**Pass Criteria:**
- ✅ Mode 1 (New Idea): Spawns PM for SCRYING
- ✅ Mode 2 (Continue Work): Recalls memory, resumes phase
- ✅ Mode 3 (Roadmap Work): Reads roadmap, spawns dev for implementation
- ✅ Delegation gate works: Seer coordinates, agents execute
- ✅ Phase state tracked: `.haunt/state/current-phase.txt` updated

**Fail Criteria:**
- ❌ Seer executes work itself (violates delegation principle)
- ❌ Mode detection fails
- ❌ Workflow phases skipped

---

## Test 7: Memory Operations - Session End

**Objective:** Verify Seer persists session summary to agent memory.

**Steps:**
1. Complete a séance session (any mode)
2. Seer should summarize session at end
3. Seer should invoke `mcp__agent_memory__store`

**Pass Criteria:**
- ✅ Session summary generated:
  - Requirements touched/completed
  - Agents spawned
  - Phase reached
  - User preferences observed
- ✅ `mcp__agent_memory__store` tool invoked
- ✅ Memory payload includes type: "seer_session"
- ✅ No errors from memory store operation

**Fail Criteria:**
- ❌ Session ends without memory write
- ❌ Memory store fails with MCP error
- ❌ Memory payload missing required fields

---

## Test 8: Memory Operations - Session Startup

**Objective:** Verify Seer recalls previous session context at startup.

**Steps:**
1. Complete Test 7 (ensure session memory persisted)
2. Exit Claude Code session
3. Re-invoke Seer: `claude --dangerously-skip-permissions --agent gco-seer`
4. Seer should greet with previous session context

**Pass Criteria:**
- ✅ `mcp__agent_memory__search` tool invoked at startup
- ✅ Previous session found and loaded
- ✅ Greeting includes:
  - "Welcome back..."
  - Last session date/time
  - Requirements worked on
  - User preferences
- ✅ User offered choice: continue or start fresh

**Fail Criteria:**
- ❌ Memory search not attempted
- ❌ Memory found but not used in greeting
- ❌ Seer treats returning user as new session

---

## Test 9: Explore Agent Integration

**Objective:** Verify Seer uses Explore agent for fast recon before spawning specialists.

**Steps:**
1. Invoke Seer with codebase question: "What files handle authentication?"
2. Seer should use Explore agent first
3. If deeper analysis needed, then spawn gco-research

**Pass Criteria:**
- ✅ Seer invokes Explore for quick file search
- ✅ Explore returns file list efficiently (<30 seconds)
- ✅ Seer decides if specialist needed based on findings
- ✅ Explore-first pattern reduces unnecessary heavy agent spawns

**Fail Criteria:**
- ❌ Seer immediately spawns research agent without Explore
- ❌ Explore not used for reconnaissance

---

## Test 10: Full Séance Workflow

**Objective:** End-to-end test from idea to archived requirement.

**Steps:**
1. Invoke Seer with new idea
2. SCRYING: PM analyzes, creates roadmap
3. User approves roadmap
4. SUMMONING: Dev implements requirement
5. Tests pass, code reviewed
6. BANISHING: Seer archives requirement
7. Session ends, memory persisted
8. Re-invoke Seer to verify memory recall

**Pass Criteria:**
- ✅ All three phases completed: SCRYING → SUMMONING → BANISHING
- ✅ User approval gate not skipped
- ✅ Requirement moves from ⚪ → 🟡 → 🟢
- ✅ Requirement archived to `.haunt/completed/`
- ✅ Memory persisted and recalled in next session
- ✅ No workflow enforcement violations

**Fail Criteria:**
- ❌ Phase skipped or out of order
- ❌ User approval bypassed
- ❌ Requirement not properly archived
- ❌ Memory not persisted

---

## Testing Summary Checklist

Mark each test as you complete it:

- [ ] Test 1: Seer Agent Invocation
- [ ] Test 2: Task Tool - Spawn Project Manager
- [ ] Test 3: Task Tool - Spawn Dev Agent
- [ ] Test 4: Task Tool - Spawn Research Agent
- [ ] Test 5: Task Tool - Spawn Code Reviewer
- [ ] Test 6: Orchestrator Skill Integration
- [ ] Test 7: Memory Operations - Session End
- [ ] Test 8: Memory Operations - Session Startup
- [ ] Test 9: Explore Agent Integration
- [ ] Test 10: Full Séance Workflow

**All tests passing = REQ-320 completion criteria met**

---

## Known Limitations

1. **Manual testing required:** Task tool spawning cannot be automated (requires live Claude Code session)
2. **MCP server dependency:** Agent Memory MCP must be running for memory tests
3. **Opus model requirement:** Seer runs on Opus, which may have cost implications for testing

---

## Reporting Issues

If any test fails:
1. Document which test failed
2. Capture error messages
3. Note environment context (OS, Claude Code version, MCP server status)
4. Create new requirement for fix if needed
5. Do NOT mark REQ-320 complete until all tests pass
