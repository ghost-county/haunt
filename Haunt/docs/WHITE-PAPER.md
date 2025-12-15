# Haunt Framework White Paper

## Executive Summary

**Haunt** is a lightweight framework that transforms AI language models into coordinated development teams through external memory patterns, structured workflows, and enforced invariants. By combining project management (roadmap-driven development), external memory (rules, skills, agents), and cognitive architecture (layered context management), Haunt enables developers to collaborate with AI agents that maintain context across sessions, follow consistent methodologies, and produce production-quality software.

**What makes Haunt unique:** While traditional AI coding assistants provide one-off code generation, Haunt creates persistent agent personalities that remember your project's standards, coordinate parallel workstreams, and maintain quality through automated verification—all while keeping the human developer in the decision-making seat.

---

## The Problem

### The Coordination Challenge

AI language models have demonstrated remarkable ability to write code, but building complex software requires more than isolated code generation:

1. **Context Loss Across Sessions**
   - LLMs are stateless; each conversation starts fresh
   - Previous architectural decisions are forgotten
   - Team conventions reset with every new chat
   - No memory of what was tried and failed

2. **Lack of Consistent Process**
   - Different prompts produce wildly different approaches
   - No enforcement of testing standards
   - Commit messages vary in quality
   - Requirements drift mid-implementation

3. **Multi-Agent Coordination Problems**
   - How do multiple AI agents work on the same codebase?
   - Who decides priorities when agents have conflicting tasks?
   - How do you prevent duplicate work or merge conflicts?
   - What happens when one agent's work blocks another?

4. **Quality Control**
   - No systematic review before merging
   - Tests written inconsistently (or not at all)
   - Technical debt accumulates silently
   - Anti-patterns spread across the codebase

### Why Existing Approaches Fall Short

**One-Shot Code Generation Tools:**
- Generate code without understanding project context
- No memory of previous conversations or decisions
- Cannot coordinate with other agents
- No enforcement of team standards

**Agent Frameworks Without Process:**
- Provide coordination but not methodology
- Leave quality standards to human discretion
- Lack enforcement mechanisms for best practices
- No built-in project management workflow

**IDE Plugins:**
- Excellent for autocomplete, poor for architecture
- Cannot manage multi-file features
- No cross-session memory
- Limited to single-developer workflows

---

## Introduction: Haunt's Solution

Haunt solves these problems by treating AI agents as **specialized team members with external memory**. Instead of monolithic "do everything" assistants, Haunt provides:

1. **Agent Specialization** - Distinct roles (Dev, PM, Researcher, Code Reviewer) with clear responsibilities
2. **External Memory System** - Rules (always-on invariants), Skills (on-demand workflows), Roadmap (working memory)
3. **Project Management Integration** - Roadmap-driven development with status tracking and dependency management
4. **Quality Enforcement** - Automated checklists, pattern detection, and verification gates

The result: AI agents that behave like experienced team members who remember your project's conventions, coordinate their work, and maintain quality standards—all while staying under your control.

---

## Core Concepts

### 1. Haunt as a Project Management System

At its heart, Haunt is a **roadmap-driven development framework** that tracks work through a structured lifecycle:

#### Roadmap Structure

**Location:** `.haunt/plans/roadmap.md`

Every project has a single source of truth containing:
- **Active requirements** with status tracking (⚪ Not Started, 🟡 In Progress, 🟢 Complete, 🔴 Blocked)
- **Agent assignments** mapping work to specialized agents
- **Dependency chains** ensuring work happens in the correct order
- **Batch organization** enabling parallel execution

**Example Requirement:**
```markdown
### 🟡 REQ-042: Implement user authentication endpoints

**Type:** Enhancement
**Reported:** 2025-01-15
**Source:** User story - secure API access

**Description:**
Create REST endpoints for user registration, login, and token refresh
with JWT-based authentication.

**Tasks:**
- [x] Create POST /auth/register endpoint
- [x] Create POST /auth/login endpoint
- [ ] Create POST /auth/refresh endpoint
- [ ] Add rate limiting to auth endpoints

**Files:**
- `src/api/auth.py` (create)
- `tests/test_auth.py` (create)

**Effort:** M
**Agent:** Dev-Backend
**Completion:** All endpoints return correct status codes, tests pass, rate limiting verified
**Blocked by:** None
```

#### Status Icon System

| Icon | Status | Meaning |
|------|--------|---------|
| ⚪ | Not Started | Ready to begin (dependencies met) |
| 🟡 | In Progress | Agent actively working |
| 🟢 | Complete | All criteria met, tests passing |
| 🔴 | Blocked | Cannot proceed until dependency resolves |

Status updates flow automatically:
- **Worker agents** update roadmap status as they work
- **Project Manager** archives completed work and unblocks dependencies
- **Everyone** sees current state without asking

#### Batch Organization for Parallelization

Related requirements are organized into batches:

```markdown
## Batch 1: Foundation (can run in parallel)

### ⚪ REQ-001: Set up database schema
**Agent:** Dev-Backend

### ⚪ REQ-002: Create React app structure
**Agent:** Dev-Frontend

## Batch 2: Features (blocked by Batch 1)

### ⚪ REQ-003: User management API
**Agent:** Dev-Backend
**Blocked by:** REQ-001

### ⚪ REQ-004: User management UI
**Agent:** Dev-Frontend
**Blocked by:** REQ-002, REQ-003
```

**Benefits:**
- REQ-001 and REQ-002 can run simultaneously (different agents, no conflicts)
- REQ-003 waits until database schema exists
- REQ-004 waits for both backend and frontend foundations
- PM tracks batch completion and unblocks next phase automatically

#### Completion Verification

Before marking any requirement 🟢, agents verify:
1. ✅ All task checkboxes marked `[x]`
2. ✅ Completion criteria met
3. ✅ Tests passing
4. ✅ Files modified as specified
5. ✅ Documentation updated (if applicable)

No shortcuts. No "I'll test it later." Quality is enforced.

---

### 2. Haunt as an External Memory Framework

LLMs are stateless, but software development requires institutional memory. Haunt provides a **layered memory hierarchy** that gives agents persistent knowledge:

#### Memory Hierarchy

```
┌─────────────────────────────────────────────────┐
│ Layer 1: RULES (Always-On Invariant Memory)    │ ← Auto-loaded every session
│ - Session startup protocol                      │   Enforced as constraints
│ - Commit conventions                            │
│ - File location rules                           │
│ - Status update protocol                        │
├─────────────────────────────────────────────────┤
│ Layer 2: AGENTS (Identity Memory)              │ ← Loaded on agent spawn
│ - "I am a Dev agent"                            │   Character sheet
│ - Values, modes, responsibilities              │
│ - Tool permissions                              │
├─────────────────────────────────────────────────┤
│ Layer 3: SKILLS (Procedural Memory)            │ ← Loaded on-demand
│ - "How to write a commit message"              │   Workflow instructions
│ - "How to run TDD workflow"                     │
│ - "How to organize roadmap batches"            │
├─────────────────────────────────────────────────┤
│ Layer 4: CLAUDE.md (Project Context Memory)    │ ← Always loaded
│ - Repository purpose                            │   Project-specific
│ - Current active work                           │
│ - Key automation scripts                        │
├─────────────────────────────────────────────────┤
│ Layer 5: ROADMAP (Working Memory)              │ ← Checked at startup
│ - Current requirements                          │   Task-level detail
│ - Task checklists                               │
│ - Agent assignments                             │
│ - Completion criteria                           │
└─────────────────────────────────────────────────┘
```

#### How Each Layer Works

**Layer 1: Rules (Invariant Memory)**

Rules are markdown files in `.claude/rules/` that **auto-load and enforce protocols**.

Example: `gco-session-startup.md`
```markdown
# Session Startup Protocol

Execute in order, every session, before ANY work:

1. Verify Environment: `pwd && git status`
2. Check Recent Changes: `git log --oneline -5`
3. Verify Tests Pass: `pytest tests/ -x -q`
4. Find Your Assignment: Check Active Work → Roadmap → Ask PM
```

**What this achieves:**
- Agents always start sessions the same way (no forgetting to verify tests)
- Protocols are **enforced**, not suggested
- Updates propagate to all agents instantly (single source of truth)

**Layer 2: Agents (Identity Memory)**

Lightweight character sheets (30-50 lines) defining WHO the agent is:

```markdown
---
name: gco-dev
tools: Read, Write, Bash, Grep, Glob, mcp__context7__*
skills: gco-tdd-workflow, gco-commit-conventions
---

# Dev Agent

## Identity
I am a Dev agent. I implement features, write tests, and maintain
code quality across backend, frontend, and infrastructure modes.

## Values
- Tests before implementation
- Explicit over implicit
- Simple over clever
```

**What this achieves:**
- Consistent personality across sessions
- Clear tool permissions (Dev can run Bash, PM cannot)
- References skills instead of duplicating workflows (DRY for agents)

**Layer 3: Skills (Procedural Memory)**

Reusable workflows loaded on-demand when agents need specific guidance:

```markdown
---
name: gco-tdd-workflow
description: Red-Green-Refactor cycle for test-driven development
---

# TDD Workflow

## Red Phase: Write Failing Test
1. Understand requirement from roadmap
2. Write test that would pass if feature existed
3. Run test suite, verify new test fails
...
```

**What this achieves:**
- Skills shared across all agents (update once, all agents benefit)
- On-demand loading (skills only loaded when invoked, saving tokens)
- Version control for methodology (track workflow changes over time)

**Layer 4: CLAUDE.md (Project Context)**

Project-specific context, always loaded:
- Repository structure
- Active work summary (PM maintains this)
- Setup commands
- Tech stack

**Layer 5: Roadmap (Working Memory)**

The detailed task list agents check at session start:
- Full requirement specifications
- Task-level checklists
- Completion criteria
- Blocking dependencies

---

### 3. Agent Coordination Through Role Specialization

Rather than one omnipotent agent, Haunt uses **specialized agents with clear boundaries**:

#### Agent Roles

| Agent | Role | Tools | Responsibilities |
|-------|------|-------|------------------|
| **Project-Manager** | Coordinator | Read, Write, Grep, Glob | Roadmap maintenance, requirements analysis, batch coordination, archiving |
| **Dev** | Implementation | Read, Write, Bash, Grep, Glob, mcp__context7__* | Write code, tests, commits; adapts to Backend/Frontend/Infrastructure modes |
| **Research** | Investigation | Read, Write, WebSearch, WebFetch, mcp__context7__* | Technical research, library investigation, documentation validation |
| **Code-Reviewer** | Quality Gate | Read, Write, Grep, Glob | PR review, pattern detection, merge coordination |
| **Release-Manager** | Deployment | Read, Write, Bash, Grep, Glob | Release coordination, changelog generation, deployment orchestration |

#### Coordination Pattern: "The Séance"

Haunt's parallel agent execution pattern:

```
User: "I want to build a task management app"
   ↓
Project Manager spawns
   ↓
Creates roadmap with requirements REQ-001 through REQ-010
   ↓
Batch 1: Foundation (parallel)
   ├── Dev-Backend: REQ-001 (database schema)
   ├── Dev-Frontend: REQ-002 (React app structure)
   └── Dev-Infrastructure: REQ-003 (CI/CD pipeline)
   ↓
Batch 2: Features (sequential, after Batch 1)
   ├── Dev-Backend: REQ-004 (task CRUD API)
   └── Dev-Frontend: REQ-005 (task list UI)
   ↓
Code-Reviewer: Review all PRs
   ↓
Release-Manager: Deploy to staging
```

**Key insight:** Agents don't talk to each other directly. The **roadmap is the communication layer**. Status updates, implementation notes, and blocking dependencies all flow through the roadmap, eliminating coordination overhead.

---

## Architecture

### The Four-Layer System

Haunt's architecture is organized into four distinct layers:

```
┌──────────────────────────────────────────────┐
│ Layer 1: AGENTS                              │ ← WHO you are
│   Character sheets (identity, values, mode)  │   30-50 lines each
│   Tool permissions                           │
│   Skill references                           │
├──────────────────────────────────────────────┤
│ Layer 2: RULES                               │ ← You MUST do this
│   Invariant enforcement protocols            │   Auto-loaded
│   Non-negotiable constraints                 │   50-100 lines each
│   Session startup, commit format, status     │
├──────────────────────────────────────────────┤
│ Layer 3: SKILLS                              │ ← HOW to do this
│   Reusable workflows and procedures          │   On-demand loading
│   TDD, code review, roadmap management       │   100-500 lines each
│   Methodology guidance                       │
├──────────────────────────────────────────────┤
│ Layer 4: COMMANDS                            │ ← Shortcuts
│   Common task automation                     │   User-invoked
│   Archival, validation, reporting            │   Scripts + docs
└──────────────────────────────────────────────┘
```

#### Why This Layering Matters

**Agents are lightweight** because they reference skills rather than duplicating workflows.

**Rules are always on** because they enforce invariants that must never be violated (e.g., "always verify tests before starting work").

**Skills are on-demand** because they're detailed procedural guidance only needed in specific contexts (e.g., "how to conduct a strategic requirements analysis").

**Commands are shortcuts** because they automate repetitive tasks users would otherwise type manually.

---

### GCO Namespace Isolation

All Haunt framework assets use the `gco-*` prefix ("Ghost County" namespace):

- Agents: `gco-dev.md`, `gco-project-manager.md`
- Skills: `gco-session-startup/`, `gco-tdd-workflow/`
- Rules: `gco-commit-conventions.md`, `gco-roadmap-format.md`

**Why namespace isolation?**
- Prevents collisions with project-specific agents or skills
- Clearly identifies framework components vs. custom extensions
- Enables side-by-side deployment of multiple frameworks

---

### Deployment Model: Source → Deployment

Haunt follows a **deploy-from-source** architecture:

```
Haunt/ (Source - Version Controlled)
  ├── agents/          ← Edit here
  │   ├── gco-dev.md
  │   ├── gco-project-manager.md
  │   └── ...
  ├── rules/           ← Edit here
  │   ├── gco-session-startup.md
  │   └── ...
  ├── skills/          ← Edit here
  │   ├── gco-tdd-workflow/
  │   └── ...
  └── scripts/
      └── setup-haunt.sh  ← Deployment script
         ↓
~/.claude/ (Global Deployment - User Home)
  ├── agents/          ← Copied from Haunt/agents/
  ├── rules/           ← Copied from Haunt/rules/
  └── skills/          ← Copied from Haunt/skills/
         ↓
.claude/ (Project Deployment - Project Root)
  ├── agents/          ← Optional overrides
  └── rules/           ← Optional overrides
```

**Critical principle:** ALWAYS edit source files in `Haunt/`, then deploy. Editing deployed copies (`~/.claude/`) leads to inconsistency when setup script runs again.

**Deployment commands:**
```bash
# Full setup (global + project)
bash Haunt/scripts/setup-haunt.sh

# Update only global agents
bash Haunt/scripts/setup-haunt.sh --agents-only

# Setup only project structure (skip global agents)
bash Haunt/scripts/setup-haunt.sh --project-only

# Verify installation
bash Haunt/scripts/setup-haunt.sh --verify
```

---

## Key Workflows

### 1. Session Startup Protocol

**Every agent, every session, follows this checklist:**

```bash
# Step 1: Verify Environment
pwd && git status
# Check working directory, uncommitted changes

# Step 2: Check Recent Changes
git log --oneline -5
# Understand what was recently completed

# Step 3: Verify Tests Pass
pytest tests/ -x -q  # (or npm test, depending on mode)
# CRITICAL: Fix broken tests BEFORE starting new work

# Step 4: Find Your Assignment
# Priority 1: Direct user assignment ("implement REQ-042")
# Priority 2: CLAUDE.md Active Work section
# Priority 3: .haunt/plans/roadmap.md (⚪ or 🟡 for my agent type)
# Priority 4: Ask PM if nothing found
```

**Why this matters:**
- Prevents starting work on broken foundation
- Ensures agent knows git state before making changes
- Eliminates "what should I work on?" ambiguity
- Creates consistent behavior across all agents

---

### 2. The "Séance" (Parallel Agent Swarm)

Haunt's signature workflow for coordinating multiple agents:

**User initiates:**
```
User: "Build a task management API with React frontend"
```

**Project Manager responds:**
1. **Confirms understanding** - Summarizes requirements, asks clarifying questions
2. **Generates requirements** - Creates formal requirements doc (`.haunt/plans/requirements-document.md`)
3. **Performs strategic analysis** - JTBD, Kano Model, RICE scoring (`.haunt/plans/requirements-analysis.md`)
4. **Creates roadmap** - Breaks into S/M-sized requirements, assigns agents, maps dependencies

**Roadmap structure:**
```markdown
## Batch 1: Foundation

### ⚪ REQ-001: Database schema for tasks
**Agent:** Dev-Backend | **Effort:** S | **Blocked by:** None

### ⚪ REQ-002: React app with routing
**Agent:** Dev-Frontend | **Effort:** S | **Blocked by:** None

## Batch 2: API Implementation

### ⚪ REQ-003: Task CRUD endpoints
**Agent:** Dev-Backend | **Effort:** M | **Blocked by:** REQ-001

### ⚪ REQ-004: Authentication endpoints
**Agent:** Dev-Backend | **Effort:** M | **Blocked by:** REQ-001

## Batch 3: UI Features

### ⚪ REQ-005: Task list component
**Agent:** Dev-Frontend | **Effort:** M | **Blocked by:** REQ-002, REQ-003
```

**Agents execute in parallel:**
```bash
# Terminal 1: Backend developer
claude -a Dev-Backend
# Picks up REQ-001, then REQ-003, then REQ-004

# Terminal 2: Frontend developer
claude -a Dev-Frontend
# Picks up REQ-002, then REQ-005 (after REQ-003 completes)
```

**Coordination happens via roadmap:**
- Agents update status (⚪ → 🟡 → 🟢)
- PM monitors batch completion
- Dependencies prevent premature work
- No direct agent-to-agent communication needed

---

### 3. Daily Rituals

#### Morning Review (Project Manager)

```markdown
**Daily Checklist:**
1. Check roadmap for 🟢 items → archive immediately
2. Review 🟡 items for stalls (>2 days no movement)
3. Update CLAUDE.md Active Work section
4. Identify 🔴 blocked items → can blockers be resolved?
5. Prepare next batch if current batch near completion
```

#### Evening Handoff (All Agents)

Before ending session:
```markdown
1. Update task checkboxes in roadmap
2. Add implementation notes if work is mid-feature
3. Commit WIP with clear message if unable to complete
4. Update status:
   - Still working tomorrow? Keep 🟡
   - Done but needs review? Mark 🟢, notify PM
   - Hit blocker? Mark 🔴, update "Blocked by:" field
```

---

### 4. Pattern Detection and Defeat

Haunt includes a **TDD-for-agent-behavior** system:

**Pattern Found → Test Written → Agent Trained → Pattern Defeated**

Example anti-pattern: "Implementation summary in wrong location"

**Step 1: Pattern Found**
```
Agent created: Haunt/scripts/REQ-042-IMPLEMENTATION.md
Violates: .claude/rules/gco-file-conventions.md
  "Implementation summaries go to .haunt/completed/"
```

**Step 2: Test Written**
```python
# .haunt/tests/patterns/test_file_conventions.py
def test_implementation_summary_location():
    """Verify implementation summaries go to .haunt/completed/"""
    summaries = glob.glob("Haunt/scripts/*IMPLEMENTATION.md")
    assert len(summaries) == 0, \
        f"Found summaries in wrong location: {summaries}"
```

**Step 3: Agent Trained**
Update `.claude/rules/gco-file-conventions.md`:
```markdown
## Prohibitions

NEVER put implementation summaries in source directories:
- NEVER: Haunt/scripts/REQ-XXX-IMPLEMENTATION.md
- ALWAYS: .haunt/completed/REQ-XXX-implementation-summary.md
```

**Step 4: Pattern Defeated**
- Rule auto-loads in all future sessions
- Test runs in CI to catch violations
- Pattern cannot recur

---

## Getting Started

### Quick Installation (3 Commands)

```bash
# 1. Clone repository
git clone https://github.com/yourusername/haunt.git
cd haunt

# 2. Run setup
bash Haunt/scripts/setup-haunt.sh

# 3. Verify installation
bash Haunt/scripts/setup-haunt.sh --verify
```

**What setup does:**
- Copies agent character sheets to `~/.claude/agents/`
- Installs rules to `~/.claude/rules/` (auto-loaded)
- Creates project structure (`.haunt/plans/`, `.haunt/completed/`, etc.)
- Verifies prerequisites (Git, Python 3.11+, Node.js 18+)

---

### Your First Project

#### Step 1: Start with Project Manager

```bash
claude -a Project-Manager
```

```
You: "I want to build a REST API for managing book reviews.
     Users can register, log in, post reviews, and rate books."
```

**PM will:**
1. Confirm understanding
2. Generate formal requirements
3. Perform strategic analysis (JTBD, Kano, RICE scoring)
4. Create roadmap with sized requirements (S: 1-4h, M: 4-8h)
5. Assign agents to requirements

---

#### Step 2: Implement Features with Dev Agent

```bash
claude -a Dev-Backend
```

Agent automatically:
- Runs session startup (verify tests, check git status)
- Finds assignment from roadmap
- Implements feature following TDD workflow
- Updates roadmap status (⚪ → 🟡 → 🟢)
- Commits with proper format: `[REQ-XXX] Action: Description`

---

#### Step 3: Review with Code Reviewer

```bash
claude -a Code-Reviewer
```

Reviewer checks:
- All tests passing
- Code follows patterns (no detected anti-patterns)
- Commit messages follow convention
- Implementation matches requirement completion criteria

---

#### Step 4: Track Progress

Check `.haunt/plans/roadmap.md`:
```markdown
## Current Focus: Book Review API

**Active Work:**
- 🟢 REQ-001: Database schema for users and reviews
- 🟡 REQ-002: User authentication endpoints
- ⚪ REQ-003: Book review CRUD endpoints

**Recently Completed:**
- 🟢 REQ-001: Database schema (2025-01-15)
```

PM archives completed work automatically, unblocking dependent requirements.

---

### First Session Success Criteria

You know setup succeeded when:
- ✅ `claude --list-agents` shows `gco-dev`, `gco-project-manager`, etc.
- ✅ Starting `claude -a Dev-Backend` runs session startup automatically
- ✅ Agent creates commits in format: `[REQ-XXX] Action: Description`
- ✅ `.haunt/plans/roadmap.md` exists with requirement structure
- ✅ Tests pass before agent starts new work

---

## Implementation Details

### Roadmap-Driven Development

**File:** `.haunt/plans/roadmap.md`

**Purpose:** Single source of truth for all active work

**Structure:**
```markdown
## Current Focus: [Phase Name]

**Goal:** [One sentence goal]

**Active Work:**
- 🟡 REQ-XXX: [Title] - [Brief status]

**Recently Completed:**
- 🟢 REQ-XXX: [Title]

---

## Batch N: [Phase Name]

### 🟡 REQ-XXX: [Action-oriented title]

**Type:** Enhancement | Bug Fix | Documentation | Research
**Reported:** YYYY-MM-DD
**Source:** User story | Bug report | Refactor

**Description:**
[What needs to be done and why]

**Tasks:**
- [x] Completed task
- [ ] Remaining task

**Files:**
- `path/to/file.py` (create | modify)

**Effort:** S | M
**Agent:** Dev-Backend | Dev-Frontend | Dev-Infrastructure
**Completion:** [Testable criteria]
**Blocked by:** REQ-XXX | None
```

---

### Commit Convention Enforcement

**Every commit follows:**
```
[REQ-XXX] Action: Brief description

What was done:
- Specific change 1
- Specific change 2

🤖 Generated with Claude Code
```

**Actions:**
- `Add` - New functionality or files
- `Update` - Enhance existing features
- `Fix` - Correct bugs
- `Remove` - Delete code or features
- `Refactor` - Restructure without changing behavior
- `Test` - Add or update tests
- `Docs` - Documentation changes

**Enforcement:**
- Rule file: `.claude/rules/gco-commit-conventions.md` (auto-loaded)
- Agents cannot commit without following format
- Pattern tests verify commit message quality
- Git hooks can validate commit format in CI

---

### Testing Philosophy

**Tests Before Code (Always)**

```markdown
# TDD Workflow (from gco-tdd-workflow skill)

## Red Phase
1. Understand requirement from roadmap
2. Write test that would pass if feature existed
3. Run test suite - verify new test FAILS
4. Commit: [REQ-XXX] Test: Add test for [feature]

## Green Phase
1. Implement simplest code to pass test
2. Run test suite - verify new test PASSES
3. Verify all existing tests still pass
4. Commit: [REQ-XXX] Add: Implement [feature]

## Refactor Phase
1. Clean up code (improve readability, remove duplication)
2. Run test suite - verify all tests still pass
3. Commit: [REQ-XXX] Refactor: Clean up [component]
```

**Test command enforcement:**
- Backend: `pytest tests/ -x -q`
- Frontend: `npm test`
- Infrastructure: `terraform plan`, `ansible --check`

**Session startup includes test verification** - broken tests MUST be fixed before starting new work.

---

### Agent Memory Integration

**MCP Agent Memory Server** (optional but recommended):

```bash
# Store significant decisions
store_memory(
  content="Chose PostgreSQL over MongoDB for ACID compliance requirements",
  category="dev-backend",
  tags=["architecture", "REQ-042", "database"]
)

# Recall context when resuming multi-session work
recall_context("dev-backend-REQ-042")
```

**When to use:**
- Multi-session features (>1 day of work)
- Complex architectural decisions
- Work resuming after >24 hour gap

**When to skip:**
- Single-session tasks
- Well-documented requirements
- Fresh features with no prior context

---

## Conclusion

### Summary of Benefits

**For Individual Developers:**
- ✅ AI agents that remember your project conventions across sessions
- ✅ Automated enforcement of testing standards and commit quality
- ✅ Roadmap-driven workflow prevents "what should I work on?" paralysis
- ✅ Pattern detection catches mistakes before they spread

**For Teams:**
- ✅ Consistent AI behavior across all team members
- ✅ Parallel agent execution (backend, frontend, infrastructure simultaneously)
- ✅ Clear dependency management prevents blocking issues
- ✅ Shared methodology scales tribal knowledge

**For Projects:**
- ✅ External memory system preserves architectural decisions
- ✅ Quality gates prevent technical debt accumulation
- ✅ Automated archival keeps roadmap clean and focused
- ✅ Strategic analysis (JTBD, Kano, RICE) ensures high-impact work

---

### The Vision: Autonomous AI Teams

Haunt's ultimate goal is **human-supervised AI autonomy**:

**Today:** Developer assigns work → Agent implements → Developer reviews
**Tomorrow:** PM agent triages issues → Dispatches to appropriate agents → Code Reviewer merges when ready → Release Manager deploys

**Human role shifts from:**
- Writing every line of code → Reviewing architectural decisions
- Manually tracking progress → Approving batch completions
- Debugging failing tests → Defining acceptance criteria

**AI agents handle:**
- Implementation details (code, tests, commits)
- Progress tracking (roadmap status updates)
- Quality enforcement (pattern detection, verification checklists)
- Coordination (dependency tracking, batch organization)

**The human remains the decision-maker** on:
- What to build (requirements approval)
- When to ship (release authorization)
- How to scale (architecture review)

Haunt provides the **scaffolding for AI teams to work autonomously while maintaining human oversight**.

---

### Next Steps

**Explore the Framework:**
1. Read `Haunt/README.md` - Architecture overview
2. Review `Haunt/SETUP-GUIDE.md` - Complete installation guide
3. Browse `Haunt/agents/` - Agent character sheets
4. Study `Haunt/skills/` - Reusable workflows

**Start Your First Project:**
1. Run setup: `bash Haunt/scripts/setup-haunt.sh`
2. Spawn PM: `claude -a Project-Manager`
3. Describe what you want to build
4. Watch as PM creates roadmap with sized requirements
5. Spawn Dev agent to implement first requirement

**Join the Community:**
- Share your roadmap patterns
- Contribute skills for common workflows
- Report anti-patterns you've detected
- Help improve the methodology

**Haunt is not just a tool—it's a methodology for building software with AI teammates who remember, coordinate, and deliver quality work session after session.**

---

## Appendix: Quick Reference

### Common Commands

```bash
# Setup and verification
bash Haunt/scripts/setup-haunt.sh              # Full setup
bash Haunt/scripts/setup-haunt.sh --verify     # Verify installation
bash Haunt/scripts/setup-haunt.sh --agents-only # Update agents only

# Spawn agents
claude -a Project-Manager    # Roadmap coordination
claude -a Dev-Backend        # Backend implementation
claude -a Dev-Frontend       # Frontend implementation
claude -a Research-Analyst   # Technical investigation
claude -a Code-Reviewer      # PR review

# Check status
cat .haunt/plans/roadmap.md  # View roadmap
git log --oneline -10        # Recent commits
ls .haunt/completed/         # Archived work
```

---

### Key File Locations

```
ghost-county/
├── Haunt/                          # Framework source
│   ├── agents/gco-*.md             # Agent character sheets
│   ├── rules/gco-*.md              # Invariant enforcement
│   ├── skills/gco-*/SKILL.md       # Reusable workflows
│   └── scripts/setup-haunt.sh      # Deployment script
├── .haunt/                         # Haunt project artifacts
│   ├── plans/roadmap.md            # Active requirements
│   ├── completed/                  # Archived work
│   ├── progress/                   # Session notes
│   └── tests/patterns/             # Pattern defeat tests
└── CLAUDE.md                       # Project context (always loaded)
```

---

### Status Icon Reference

| Icon | Status | Agent Action |
|------|--------|--------------|
| ⚪ | Not Started | Pick up when ready, update to 🟡 |
| 🟡 | In Progress | Working on this, update tasks as complete |
| 🟢 | Complete | All criteria met, notify PM for archival |
| 🔴 | Blocked | Cannot proceed, waiting for dependency |

---

**Version:** Haunt v2.0
**Last Updated:** 2025-01-15
**License:** MIT
**Documentation:** `Haunt/README.md`, `Haunt/SETUP-GUIDE.md`
