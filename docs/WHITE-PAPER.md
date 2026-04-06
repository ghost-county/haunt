# Haunt Framework White Paper

## Executive Summary

**Haunt** is a lightweight framework that transforms AI language models into coordinated development teams through external memory patterns, structured workflows, and enforced invariants. By combining project management (roadmap-driven development), external memory (rules, skills, agents), and cognitive architecture (layered context management), Haunt enables developers to collaborate with AI agents that maintain context across sessions, follow consistent methodologies, and produce production-quality software.

**What makes Haunt unique:** While traditional AI coding assistants provide one-off code generation, Haunt creates persistent agent personalities that remember your project's standards, coordinate parallel workstreams, and maintain quality through automated verification—all while keeping the human developer in the decision-making seat.

---

## Document Navigation

**If you want to:**
- **Understand the problem Haunt solves** → Read "The Problem" and "Why Existing Approaches Fall Short"
- **Get a high-level overview** → Read "Introduction: Haunt's Solution" and "Core Concepts"
- **Learn the architecture** → Read "Architecture" section (four-layer system)
- **Start using Haunt immediately** → Jump to "Getting Started" and "Your First Project"
- **Understand key workflows** → Read "Key Workflows" (Session Startup, Séance, Daily Rituals)
- **See implementation specifics** → Read "Implementation Details" (Roadmap, Commits, Testing)
- **Quick reference** → Jump to "Appendix: Quick Reference" at the end

**Recommended reading paths:**
- **New users**: Executive Summary → Getting Started → Your First Project → Core Concepts
- **Architects/Leads**: The Problem → Architecture → Key Workflows → Implementation Details
- **Existing users**: Jump to specific sections as needed, use Appendix for quick reference

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
**Complexity:** MODERATE
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

#### Effort and Complexity Indicators

Requirements are sized using **two independent dimensions**:

**Effort (Time/Scope):**
| Size | Time | Files | Lines Changed | When to Use |
|------|------|-------|---------------|-------------|
| **XS** | 30min-1hr | 1-2 files | <50 lines | Quick fixes, config changes |
| **S** | 1-2 hours | 2-4 files | 50-150 lines | Single component features, isolated bugs |
| **M** | 2-4 hours | 4-8 files | 150-300 lines | Multi-component features, moderate refactoring |
| **SPLIT** | >4 hours | >8 files | >300 lines | Must decompose into smaller requirements |

**Complexity (Cognitive Difficulty):**
| Level | Definition | Characteristics |
|-------|------------|-----------------|
| **SIMPLE** | Clear requirements, single pattern | Obvious implementation, no unknowns |
| **MODERATE** | Some investigation needed | 2-3 patterns, bounded unknowns |
| **COMPLEX** | Significant unknowns | Cross-cutting concerns, architectural decisions |
| **UNKNOWN** | Cannot estimate | Needs research spike first |

**Why separate dimensions?**
- A quick fix can be **XS effort** but **COMPLEX** (hard-to-diagnose race condition)
- A large feature can be **M effort** but **SIMPLE** (straightforward CRUD endpoint)
- Helps agents estimate both time commitment and cognitive load

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
3. ✅ Tests passing (appropriate test command for work type)
4. ✅ Files modified as specified
5. ✅ Documentation updated (if applicable)
6. ✅ Security review completed (if code involves user input, auth, database queries, external APIs, file operations, or dependencies)
7. ✅ Self-validation performed (re-read requirement, review own code, confirm tests actually test the feature, check against known anti-patterns)

No shortcuts. No "I'll test it later." Quality is enforced through systematic verification at every stage.

#### Roadmap Sharding for Large Projects

For projects with many requirements, roadmaps can be **sharded into batch files** to reduce context size and improve agent performance:

**Monolithic roadmap** (default):
```
.haunt/plans/roadmap.md  ← All requirements in one file
```

**Sharded roadmap** (optimization):
```
.haunt/plans/roadmap.md           ← Overview + active batch only
.haunt/plans/batches/
  ├── batch-1-foundation.md       ← Batch 1 requirements
  ├── batch-2-features.md         ← Batch 2 requirements
  └── batch-3-polish.md           ← Batch 3 requirements
```

**How it works:**
- `roadmap.md` contains project overview and the currently active batch
- Completed batches move to `.haunt/plans/batches/` for archival reference
- Agents only load the active batch context, reducing token usage
- Assignment lookup checks for sharded structure and loads appropriate batch file

**When to shard:**
- Roadmap exceeds 500 lines (readability limit)
- More than 20-30 active requirements
- Multi-phase projects with clear batch boundaries
- Performance optimization needed

**Benefits:**
- Faster agent startup (less context to load)
- Better focus (agents see only relevant work)
- Easier navigation (batches are self-contained)
- Preserves history (completed batches archived, not deleted)

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
haunt/ (Source - Version Controlled)
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
  ├── agents/          ← Copied from agents/
  ├── rules/           ← Copied from rules/
  └── skills/          ← Copied from skills/
         ↓
.claude/ (Project Deployment - Project Root)
  ├── agents/          ← Optional overrides
  └── rules/           ← Optional overrides
```

**Critical principle:** ALWAYS edit source files in the repo root, then deploy. Editing deployed copies (`~/.claude/`) leads to inconsistency when setup script runs again.

**Deployment commands:**
```bash
# Full setup (global + project)
bash scripts/setup-haunt.sh

# Update only global agents
bash scripts/setup-haunt.sh --agents-only

# Setup only project structure (skip global agents)
bash scripts/setup-haunt.sh --project-only

# Verify installation
bash scripts/setup-haunt.sh --verify
```

---

### Wrapper Scripts: Structured Execution Layer

Haunt provides **structured wrapper scripts** that return JSON for programmatic verification and eliminate token-wasting manual file parsing.

**Why Wrappers Matter:**

Traditional workflow (token-intensive):
```bash
# Agent reads entire 1647-line roadmap to find one requirement
Read(.haunt/plans/roadmap.md)  # 1647 lines = ~4000 tokens

# Agent runs tests manually, parses output
pytest tests/ -v  # Parses human-readable output
```

Wrapper workflow (token-efficient):
```bash
# Get specific requirement as JSON
bash scripts/haunt-roadmap.sh get REQ-XXX  # Returns ~30 lines JSON

# Run tests with structured output
bash scripts/haunt-run.sh test  # Returns JSON with pass/fail/coverage
```

**Token savings:** 60-98% reduction for common operations.

#### Available Wrapper Scripts

| Script | Purpose | Output Format |
|--------|---------|---------------|
| `haunt-roadmap.sh` | Structured roadmap lookup | JSON (requirement details) |
| `haunt-run.sh` | Build/test/lint execution | JSON (results, coverage, failures) |
| `haunt-verify.sh` | Completion criteria verification | JSON (pass/fail per criterion) |
| `haunt-archive.sh` | Archive completed requirements | JSON (archival confirmation) |
| `haunt-read.sh` | Smart file reader with caching | Cached content or file path |
| `haunt-story.sh` | Story file management | JSON (story context, session notes) |
| `haunt-lessons.sh` | Lessons-learned query | Relevant lessons for requirement |
| `haunt-metrics.sh` | Performance metrics collection | JSON (execution time, token usage) |
| `haunt-git.sh` | Git operation wrappers | JSON (commit info, status) |

#### Example: Structured Roadmap Lookup

**Without wrapper (traditional):**
```bash
# Dev agent needs REQ-042 details
Read(.haunt/plans/roadmap.md)  # 1647 lines
grep -A 30 "REQ-042" .haunt/plans/roadmap.md  # Manual parsing
```

**With wrapper (optimized):**
```bash
# Get structured JSON output
$ bash scripts/haunt-roadmap.sh get REQ-042

{
  "id": "REQ-042",
  "title": "Implement user authentication endpoints",
  "status": "🟡",
  "agent": "Dev-Backend",
  "effort": "M",
  "complexity": "MODERATE",
  "tasks": [
    {"text": "Create POST /auth/register", "done": true},
    {"text": "Create POST /auth/login", "done": true},
    {"text": "Add rate limiting", "done": false}
  ],
  "blocked_by": "None"
}
```

**Result:** Agent gets exactly what it needs in 30 lines instead of reading 1647.

#### Example: Structured Test Execution

**Without wrapper:**
```bash
# Run tests, parse human-readable output
pytest tests/ -v

# Agent manually parses:
# "test_auth.py::test_register PASSED [10%]"
# "test_auth.py::test_login PASSED [20%]"
# ... 100+ lines of output ...
```

**With wrapper:**
```bash
$ bash scripts/haunt-run.sh test

{
  "success": true,
  "framework": "pytest",
  "passed": 23,
  "failed": 0,
  "skipped": 1,
  "duration_seconds": 4.2,
  "coverage_percent": 87.3,
  "failures": []
}
```

**Result:** Structured output for programmatic verification, no manual parsing.

#### Example: Completion Verification

**Without wrapper:**
```bash
# Agent manually checks each criterion:
# 1. Read roadmap, count checkboxes
# 2. Run pytest, check exit code
# 3. Run coverage, parse output
# 4. Check file existence
# 5. Verify commit format
# ... 30+ commands, 5000+ tokens ...
```

**With wrapper:**
```bash
$ bash scripts/haunt-verify.sh REQ-042 backend

{
  "success": true,
  "requirement": "REQ-042",
  "summary": "5/5 criteria passed",
  "criteria": [
    {"name": "tasks_complete", "status": "PASS", "evidence": "3/3 tasks checked"},
    {"name": "files_exist", "status": "PASS", "evidence": "All 2 files exist"},
    {"name": "tests_pass", "status": "PASS", "evidence": "23/23 tests passed"},
    {"name": "coverage", "status": "PASS", "evidence": "87% coverage"},
    {"name": "commits_valid", "status": "PASS", "evidence": "3 commits follow convention"}
  ]
}
```

**Result:** One command verifies ALL completion criteria programmatically.

---

### Metrics Framework: Zero Agent Overhead

Haunt includes a **lightweight metrics collection system** that tracks framework performance without requiring agent awareness or manual instrumentation.

**Design principle:** Metrics collection happens **outside agent context**—wrapper scripts emit metrics, agents remain unaware.

#### How It Works

**Traditional metrics (problematic):**
```python
# Agent must manually track metrics (adds complexity)
start_time = time.time()
result = implement_feature()
metrics.record("feature_time", time.time() - start_time)
```

**Haunt metrics (transparent):**
```bash
# Wrapper script handles metrics automatically
$ bash scripts/haunt-run.sh test

# Emits metrics to .haunt/metrics/metrics.jsonl:
{"timestamp": "2025-12-31T10:30:00Z", "operation": "test", "duration_seconds": 4.2, "success": true}

# Agent sees only the test result (no metrics awareness needed)
```

#### What Gets Tracked

| Metric | Source | Purpose |
|--------|--------|---------|
| Test execution time | `haunt-run.sh test` | Performance regression detection |
| Build time | `haunt-run.sh build` | Build optimization opportunities |
| Requirement completion time | `haunt-verify.sh` | Effort estimation calibration |
| Token usage per operation | `haunt-read.sh`, `haunt-roadmap.sh` | Optimization validation |
| Wrapper script usage | All wrapper scripts | Adoption tracking |

#### Metrics Output Format

**File:** `.haunt/metrics/metrics.jsonl` (JSON Lines format)

```json
{"timestamp": "2025-12-31T10:15:00Z", "operation": "test", "framework": "pytest", "passed": 23, "failed": 0, "duration_seconds": 4.2, "coverage_percent": 87.3}
{"timestamp": "2025-12-31T10:20:00Z", "operation": "roadmap_lookup", "requirement": "REQ-042", "token_savings": 4100, "duration_ms": 45}
{"timestamp": "2025-12-31T10:25:00Z", "operation": "verify_completion", "requirement": "REQ-042", "criteria_passed": 5, "criteria_failed": 0}
```

#### Analysis and Reporting

```bash
# Generate summary report
$ bash scripts/haunt-metrics.sh report --last-week

Framework Performance (Last 7 Days):
- Average test execution: 4.3s
- Average token savings per lookup: 3,800 tokens
- Requirements completed: 12
- Wrapper script adoption: 89%

Top optimization opportunities:
1. Test execution +15% slower than baseline
2. Coverage dropped from 91% to 87%
3. REQ-042 took 3.2hr (estimated 2hr) - calibrate estimates
```

**Key insight:** Metrics inform framework improvements without burdening agents with instrumentation logic.

---

### Skill Refactoring Pattern: Reference Files + Consultation Gates

To prevent token bloat in rules while maintaining comprehensive guidance, Haunt uses a **two-tier skill architecture**:

**Tier 1: Slim Reference Files (Rules)**
- Auto-loaded every session (~50-100 lines)
- Core protocols and non-negotiable requirements
- Summary checklists with "invoke full skill" gates

**Tier 2: Comprehensive Skills (On-Demand)**
- Loaded only when invoked (~300-600 lines)
- Detailed examples, edge cases, anti-patterns
- Complete methodology and best practices

#### Example: Completion Checklist

**Before refactoring** (rule file bloated):
```markdown
# gco-completion-checklist.md (800 lines - auto-loaded!)
- Complete checklist with ALL details
- Detailed examples for each step
- Anti-patterns to avoid
- Edge case handling
- Integration with other workflows
- ... 700 more lines ...
```

**Token cost:** 800 lines × ~2.5 tokens/line = **2,000 tokens per session**

**After refactoring** (slim reference + consultation gate):

**Tier 1: Slim Reference (Rule)** - `gco-completion-checklist.md` (~100 lines)
```markdown
# Completion Checklist (Slim Reference)

## Before Marking ANY Requirement 🟢

Run through this checklist:

1. All Tasks Checked Off
2. Completion Criteria Met
3. Tests Passing (non-negotiable)
4. Files Updated
5. ...

## When to Invoke Full Skill

For detailed requirements, checklists for each step, examples, and anti-patterns:

**Invoke:** `/gco-completion` skill

The skill contains:
- Detailed verification requirements for each step
- Testing requirements by agent type
- Iterative refinement checklist
- Anti-patterns to avoid with examples
```

**Tier 2: Comprehensive Skill (On-Demand)** - `gco-completion/SKILL.md` (~600 lines)
```markdown
# Completion Checklist: Comprehensive Guide

## Purpose
Detailed verification workflow for marking requirements complete...

[Full 600 lines of examples, anti-patterns, edge cases, etc.]
```

**Token savings:** 1,900 tokens saved per session (agents only load 100-line reference unless they need details).

#### When to Use Consultation Gates

Add consultation gates when:
- Rule file exceeds 200 lines
- Content includes many examples or edge cases
- Guidance is context-specific (not needed every session)
- Methodology changes frequently (easier to update skill than rule)

**Pattern:**
1. Identify bloated rule file (>200 lines)
2. Extract detailed content to skill
3. Leave slim checklist in rule with "Invoke skill for details"
4. Agents load skill on-demand when they need comprehensive guidance

**Result:** Rules stay lightweight (auto-loaded), skills provide depth (on-demand).

---

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

### 2. The "Séance" (Complete Development Ritual)

The Séance is Haunt's complete idea-to-shipped workflow - a guided ritual that handles planning, execution, and archival with zero manual coordination.

**The Three-Part Ritual:**
```
🔮 Scrying   (Planning)   → /seance --scry    or --plan
👻 Summoning (Execution)  → /seance --summon  or --execute
⚰️ Banishing (Archival)   → /seance --banish  or --archive
```

**Quick Example:**
```bash
# One command: idea → shipped feature
$ /seance "Add OAuth login support"

🔮 Scrying... (creates formal requirements, strategic analysis, roadmap)
👻 Summoning... (spawns agents, implements features, runs tests)
⚰️ Banishing... (archives completed work, cleans roadmap)

✅ OAuth login shipped, tested, committed, documented, archived
```

**Key Features:**
- **Planning depth modes**: `--quick` (basic), default (standard), `--deep` (comprehensive JTBD/Kano/RICE analysis)
- **Parallel execution**: Agents work on independent requirements simultaneously
- **Automatic archival**: Completed work moves to `.haunt/completed/` automatically
- **Roadmap sharding**: Large projects split into batch files for performance
- **Phase gates**: Deterministic workflow with explicit pass/fail criteria at each phase transition

**Phase Gate Integration:**

Each Séance phase includes verification gates to ensure deterministic progression:

**Scrying Phase Gate:**
- ✅ Requirements document created with clear acceptance criteria
- ✅ Strategic analysis completed (or skipped if --quick)
- ✅ Roadmap updated with sized, assigned requirements
- ✅ No SPLIT-sized requirements (all decomposed to M or smaller)
- ⛔ FAIL: Blocks execution until requirements properly defined

**Summoning Phase Gate:**
- ✅ All tests passing before starting new work
- ✅ Git working directory clean or WIP properly committed
- ✅ Agent assignments clear and unambiguous
- ✅ Dependencies resolved (no 🔴 blocked requirements in batch)
- ⛔ FAIL: Cannot spawn agents until foundation stable

**Banishing Phase Gate:**
- ✅ All requirements in batch marked 🟢
- ✅ All task checkboxes checked
- ✅ All commits follow convention
- ✅ Documentation updated
- ⛔ FAIL: Cannot archive incomplete work

**Why it matters:**
- Say what you want (one line) → come back to shipped features
- Zero coordination overhead (roadmap is the communication layer)
- Full SDLC automation from idea to production
- Deterministic workflow prevents premature phase transitions

**📖 For complete Séance documentation**, including:
- All 6 operating modes (interactive, direct, explicit phases)
- Planning depth levels (quick/medium/deep)
- Phase gate details and failure recovery
- Complete workflow examples (OAuth login walkthrough)
- Advanced usage (batch execution, roadmap sharding)
- Troubleshooting and best practices

**See:** `docs/SEANCE-EXPLAINED.md` - The definitive Séance guide

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
Agent created: scripts/REQ-042-IMPLEMENTATION.md
Violates: .claude/rules/gco-file-conventions.md
  "Implementation summaries go to .haunt/completed/"
```

**Step 2: Test Written**
```python
# .haunt/tests/patterns/test_file_conventions.py
def test_implementation_summary_location():
    """Verify implementation summaries go to .haunt/completed/"""
    summaries = glob.glob("scripts/*IMPLEMENTATION.md")
    assert len(summaries) == 0, \
        f"Found summaries in wrong location: {summaries}"
```

**Step 3: Agent Trained**
Update `.claude/rules/gco-file-conventions.md`:
```markdown
## Prohibitions

NEVER put implementation summaries in source directories:
- NEVER: scripts/REQ-XXX-IMPLEMENTATION.md
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
git clone https://github.com/ghost-county/haunt.git
cd haunt

# 2. Run setup
bash scripts/setup-haunt.sh

# 3. Verify installation
bash scripts/setup-haunt.sh --verify
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
claude -a project-manager
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
claude -a dev
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
claude -a code-reviewer
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
- ✅ Starting `claude -a dev` runs session startup automatically
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

**Effort:** XS | S | M | SPLIT
**Complexity:** SIMPLE | MODERATE | COMPLEX | UNKNOWN
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
1. Read `README.md` - Architecture overview
2. Review `docs/SETUP-GUIDE.md` - Complete installation guide
3. Browse `agents/` - Agent character sheets
4. Study `skills/` - Reusable workflows

**Start Your First Project:**
1. Run setup: `bash scripts/setup-haunt.sh`
2. Spawn PM: `claude -a project-manager`
3. Describe what you want to build
4. Watch as PM creates roadmap with sized requirements
5. Spawn Dev agent: `claude -a dev` to implement first requirement

**Join the Community:**
- Share your roadmap patterns
- Contribute skills for common workflows
- Report anti-patterns you've detected
- Help improve the methodology

**Haunt is not just a tool—it's a methodology for building software with AI teammates who remember, coordinate, and deliver quality work session after session.**

### Key Takeaways

**What Haunt Is:**
- 🧠 External memory framework (rules, skills, agents) that gives stateless LLMs persistent knowledge
- 📋 Roadmap-driven project management with dependency tracking and batch parallelization
- 🔧 Specialized agent roles (Dev, PM, Research, Code Reviewer) with clear boundaries
- ✅ Quality enforcement through automated checklists, pattern detection, and verification gates

**What Haunt Provides:**
- **For developers**: AI agents that remember your conventions across sessions
- **For teams**: Parallel agent execution with consistent behavior
- **For projects**: Quality gates that prevent technical debt accumulation
- **For decisions**: Strategic analysis (JTBD, Kano, RICE) ensures high-impact work

**Core Philosophy:**
- Agents reference methodology, don't duplicate it (DRY for AI)
- Rules enforce invariants, skills provide workflows
- Roadmap is the communication layer between agents
- Human stays in control of what/when/how decisions

**Start in 3 commands:**
```bash
bash scripts/setup-haunt.sh
claude -a project-manager  # Describe what you want to build
claude -a dev              # Implement first requirement
```

---

## Appendix: Quick Reference

### Common Commands

```bash
# Setup and verification
bash scripts/setup-haunt.sh              # Full setup
bash scripts/setup-haunt.sh --verify     # Verify installation
bash scripts/setup-haunt.sh --agents-only # Update agents only

# Spawn agents
claude -a project-manager    # Roadmap coordination
claude -a dev                # Development (backend/frontend/infrastructure)
claude -a research           # Technical investigation
claude -a code-reviewer      # PR review
claude -a release-manager    # Release coordination

# Check status
cat .haunt/plans/roadmap.md  # View roadmap
git log --oneline -10        # Recent commits
ls .haunt/completed/         # Archived work
```

---

### Key File Locations

```
haunt/
├── agents/gco-*.md             # Agent character sheets
├── rules/gco-*.md              # Invariant enforcement
├── skills/gco-*/SKILL.md       # Reusable workflows
├── scripts/setup-haunt.sh      # Deployment script
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
**Last Updated:** 2025-12-31
**License:** MIT
**Documentation:** `README.md`, `docs/SETUP-GUIDE.md`, `docs/SEANCE-EXPLAINED.md`
