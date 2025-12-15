# Integration Patterns: Built-in + Haunt Agents

This document provides detailed examples of hybrid workflows combining Claude Code's built-in agents (Explore, Plan, general-purpose) with Ghost County's Haunt agents (gco-*).

> **Key Insight:** Built-in agents and Haunt agents have complementary strengths. Combine them for optimal results.

---

## Quick Reference

| Built-in Agent | Model | Tools | Best For |
|----------------|-------|-------|----------|
| **Explore** | Haiku | Read, Grep, Glob (read-only) | Fast codebase searches |
| **Plan** | Sonnet | Read, Grep, Glob, Write (plan mode) | Strategic planning |
| **general-purpose** | Sonnet | Full toolset | General implementation |

| Haunt Agent | Model | Tools | Best For |
|-------------|-------|-------|----------|
| **gco-dev** | inherit | Full toolset + MCP | Feature implementation |
| **gco-research** | inherit | Read, Grep, Web, MCP | Technical investigation |
| **gco-project-manager** | inherit | Full toolset + MCP | Formal roadmap creation |
| **gco-code-reviewer** | inherit | Read, Grep, Glob | Code quality review |
| **gco-release-manager** | inherit | Full toolset + MCP | Deployment coordination |

---

## Pattern 1: Explore → gco-dev (Research then Implement)

### Use Case

You need to understand existing code patterns before making changes.

### When to Use

- Refactoring existing functionality
- Implementing features that integrate with existing code
- Need fast read-only search before modification
- Want to prevent "implement first, understand later" mistakes

### Example Flow

```
User: "Refactor authentication to use JWT instead of session cookies"

Main Agent (general-purpose):

  Step 1: Spawn Explore (built-in)
  ├─ Prompt: "Find all authentication-related code in the codebase"
  ├─ Searches: src/auth/, middleware/, routes/
  └─ Returns: List of 8 files with auth patterns, current session implementation details

  Step 2: Review findings with user
  "I found session-based auth in 8 files. The main flow is:
   - routes/auth.js: Login/logout endpoints
   - middleware/auth.js: Session validation
   - models/Session.js: Session storage

   Ready to implement JWT replacement?"

  Step 3: Spawn gco-dev (Haunt)
  ├─ Context: Explore findings (8 files, session flow)
  ├─ Prompt: "Implement JWT authentication to replace session-based auth"
  ├─ Follows: TDD workflow, session-startup protocol
  └─ Outputs: JWT implementation, tests, migration guide
```

### Why It Works

- **Explore** is read-only (fast, safe, no accidental modifications)
- **Explore** uses Haiku model (cost-effective for searches)
- **gco-dev** has full implementation tools (Write, Edit, Bash)
- **gco-dev** follows Ghost County protocols (TDD, commit conventions, roadmap updates)
- Separation prevents "code before understanding" anti-pattern

### Code Example

```javascript
// Main agent spawning sequence
const findings = await spawnAgent({
  type: "Explore",
  prompt: "Find all authentication-related code in the codebase",
  tools: ["Read", "Grep", "Glob"]
});

// Review with user (truncated for brevity)
console.log("Found:", findings.files);

// Spawn implementation agent
await spawnAgent({
  type: "gco-dev",
  prompt: `Implement JWT authentication to replace session-based auth.

  Context from Explore:
  ${findings.summary}

  Follow TDD workflow and update roadmap.`,
  tools: "full"
});
```

### Anti-Patterns

**❌ Don't spawn gco-dev first without research:**
```
User: "Refactor authentication to JWT"

Main Agent:
  └─> Spawns gco-dev immediately
      └─> Dev searches codebase manually during implementation
          └─> Wastes time, misses patterns, higher error risk
```

**❌ Don't use general-purpose for both research and implementation:**
```
Main Agent (general-purpose):
  1. Searches codebase for auth patterns
  2. Implements JWT replacement
  └─> Problem: No separation of concerns, no Ghost County protocols
```

---

## Pattern 2: Plan → gco-project-manager (Planning Handoff)

### Use Case

You want high-level strategic planning before detailed requirements and roadmap formalization.

### When to Use

- Complex features requiring strategic breakdown
- User explicitly asks "plan out..." or "create a plan for..."
- Need quick strategic thinking before formal requirements
- Want separation between strategy and execution planning

### Example Flow

```
User: "Plan out a task management feature for the app"

Main Agent:

  Step 1: Spawn Plan (built-in)
  ├─ Prompt: "Create strategic breakdown for task management feature"
  ├─ Outputs: High-level plan with:
  │   ├─ Major components (task CRUD, assignments, deadlines, notifications)
  │   ├─ Tech stack recommendations (React, Node.js, PostgreSQL)
  │   ├─ Phase breakdown (MVP → Enhancements → Polish)
  │   └─ Risk assessment (auth integration, notification delivery)
  └─ Uses: Plan mode (strategic thinking, not detailed requirements)

  Step 2: Review plan with user
  "Here's the strategic plan for task management:

   Phase 1 (MVP):
   - Basic CRUD for tasks
   - Simple assignment to users
   - Due dates

   Phase 2 (Enhancements):
   - Recurring tasks
   - Email notifications
   - Task dependencies

   Would you like me to formalize this into a Ghost County roadmap?"

  Step 3: Spawn gco-project-manager (Haunt)
  ├─ Context: Plan agent's strategic breakdown
  ├─ Prompt: "Convert this strategic plan into formal Ghost County requirements"
  ├─ Executes: 3-phase PM workflow
  │   ├─ Phase 1: Requirements Development (14-dimension rubric)
  │   ├─ Phase 2: Requirements Analysis (JTBD, Kano, RICE)
  │   └─ Phase 3: Roadmap Creation (S/M sizing, batches, assignments)
  └─ Outputs:
      ├─ .haunt/plans/requirements-document.md
      ├─ .haunt/plans/requirements-analysis.md
      └─ .haunt/plans/roadmap.md (12 requirements, 4 batches)
```

### Why It Works

- **Plan** agent provides quick strategic thinking (no requirements overhead)
- **Plan** agent uses Sonnet model (good reasoning for high-level planning)
- **gco-project-manager** formalizes with Ghost County format (14-dimension rubric, JTBD/Kano/RICE)
- **gco-project-manager** creates actionable roadmap (sized items, batches, agent assignments)
- Separation of concerns: Strategy → Formalization → Implementation

### Code Example

```javascript
// Step 1: Strategic planning
const strategicPlan = await spawnAgent({
  type: "Plan",
  prompt: "Create strategic breakdown for task management feature",
  mode: "plan"  // Uses plan mode for strategic thinking
});

// Step 2: User review (truncated)
if (await userApproves(strategicPlan)) {

  // Step 3: Formalize into roadmap
  await spawnAgent({
    type: "gco-project-manager",
    prompt: `Convert this strategic plan into Ghost County requirements and roadmap:

    ${strategicPlan.content}

    Follow the 3-phase PM workflow:
    - Phase 1: Requirements Development (14-dimension rubric)
    - Phase 2: Requirements Analysis (JTBD, Kano, RICE)
    - Phase 3: Roadmap Creation (S/M sizing, batches)`,
    tools: "full"
  });
}
```

### Integration with /seance Command

The `/seance` command can detect "Plan out..." trigger phrases and automatically use this pattern:

```
User: "/seance Plan out a task management app"

Seance skill:
  ├─ Detects "Plan out" trigger
  ├─ Spawns Plan agent first
  ├─ Reviews output with user
  ├─ If approved, spawns gco-project-manager
  └─ Standard summoning prompt to spawn workers
```

### Anti-Patterns

**❌ Don't skip Plan agent for complex features:**
```
User: "Create a task management feature"

Main Agent:
  └─> Spawns gco-project-manager immediately
      └─> PM guesses at strategic breakdown
          └─> Misses better architectural options
```

**❌ Don't use Plan agent for simple features:**
```
User: "Add a dark mode toggle"

Main Agent:
  └─> Spawns Plan agent
      └─> Overkill for simple feature, wastes time
```

**Rule of thumb:** Use Plan agent for features requiring >8 requirements or cross-cutting concerns.

---

## Pattern 3: general-purpose → gco-code-reviewer (Implement then Review)

### Use Case

You want implementation separated from quality review to prevent bias.

### When to Use

- Implementing features without predefined code review agent
- Want independent review (not "review your own work")
- Need Ghost County pattern detection after implementation
- Prefer separate agents for implementation vs quality assurance

### Example Flow

```
User: "Add dark mode toggle component with theme persistence"

Main Agent:

  Step 1: Spawn general-purpose (built-in)
  ├─ Prompt: "Implement dark mode toggle component"
  ├─ Implements:
  │   ├─ src/components/DarkModeToggle.tsx
  │   ├─ src/store/theme.ts (state management)
  │   ├─ src/styles/themes.css
  │   └─ tests/DarkModeToggle.test.tsx
  └─ Commits: [REQ-042] Add: Dark mode toggle component

  Step 2: Spawn gco-code-reviewer (Haunt)
  ├─ Prompt: "Review dark mode toggle implementation"
  ├─ Checks:
  │   ├─ Code patterns (no silent fallbacks, proper error handling)
  │   ├─ Test coverage (>80% for new code)
  │   ├─ Accessibility (keyboard navigation, ARIA labels)
  │   ├─ Ghost County conventions (commit format, file locations)
  └─ Reports:
      ├─ ✅ Code patterns: Pass (no anti-patterns detected)
      ├─ ✅ Test coverage: 92% (exceeds threshold)
      ├─ ⚠️  Accessibility: Missing ARIA label on toggle button
      └─ Recommendations: Add aria-label="Toggle dark mode"
```

### Why It Works

- **general-purpose** agent has full implementation tools
- **general-purpose** agent doesn't have Ghost County pattern biases during implementation
- **gco-code-reviewer** provides independent review
- **gco-code-reviewer** knows Ghost County anti-patterns and conventions
- Separation prevents "I wrote it, so it must be good" confirmation bias

### Code Example

```javascript
// Step 1: Implementation
const implementation = await spawnAgent({
  type: "general-purpose",
  prompt: `Implement dark mode toggle component with:
  - Toggle UI component
  - Theme state management
  - localStorage persistence
  - Tests`,
  tools: "full"
});

// Step 2: Code review
const review = await spawnAgent({
  type: "gco-code-reviewer",
  prompt: `Review the dark mode toggle implementation:

  Files changed:
  ${implementation.files}

  Check:
  - Code patterns (gco-code-patterns skill)
  - Test coverage (>80%)
  - Accessibility
  - Ghost County conventions`,
  tools: ["Read", "Grep", "Glob"]  // Read-only for review
});

// Step 3: Address findings if needed
if (review.hasIssues) {
  await spawnAgent({
    type: "gco-dev",
    prompt: `Address code review findings:
    ${review.issues}`,
    tools: "full"
  });
}
```

### Anti-Patterns

**❌ Don't use same agent for implementation and review:**
```
Main Agent (gco-dev):
  1. Implements dark mode toggle
  2. Reviews own implementation
  └─> Problem: Confirmation bias, blind spots in own code
```

**❌ Don't use gco-code-reviewer for implementation:**
```
Main Agent:
  └─> Spawns gco-code-reviewer
      └─> Prompt: "Implement and review dark mode toggle"
          └─> Problem: Code reviewer has limited tools, meant for read-only review
```

---

## Pattern 4: Explore → gco-research → gco-dev (Deep Investigation)

### Use Case

You need both fast code searches AND deep technical research before implementation.

### When to Use

- Complex refactoring with external dependencies
- Investigating unfamiliar codebases or technologies
- Need both internal (codebase) and external (web) research
- Want thorough understanding before making changes

### Example Flow

```
User: "Migrate database ORM from Sequelize to Prisma"

Main Agent:

  Step 1: Spawn Explore (built-in)
  ├─ Prompt: "Find all Sequelize model definitions and queries"
  ├─ Searches: models/, services/, controllers/
  └─ Returns: 23 files using Sequelize, 45 model definitions

  Step 2: Spawn gco-research (Haunt)
  ├─ Context: Explore findings (23 files, 45 models)
  ├─ Prompt: "Research Sequelize to Prisma migration best practices"
  ├─ Investigates:
  │   ├─ Web search: Prisma migration guides
  │   ├─ Web search: Common pitfalls in Sequelize → Prisma
  │   ├─ Read docs: Prisma schema syntax
  │   └─ Compare: Sequelize vs Prisma query patterns
  └─ Reports:
      ├─ Migration strategy (schema-first vs database-first)
      ├─ Breaking changes (relation syntax differences)
      ├─ Testing approach (parallel ORM testing)
      └─ Rollback plan (feature flags, gradual migration)

  Step 3: Review research with user
  "I found 23 files using Sequelize with 45 models. Research recommends:
   - Use schema-first migration (generate Prisma schema from models)
   - Test in parallel (Sequelize + Prisma side-by-side)
   - Gradual rollout with feature flags

   Ready to proceed with implementation?"

  Step 4: Spawn gco-dev (Haunt)
  ├─ Context: Explore findings + Research recommendations
  ├─ Prompt: "Migrate Sequelize to Prisma following research plan"
  ├─ Implements:
  │   ├─ Generate Prisma schema from Sequelize models
  │   ├─ Set up parallel testing (Sequelize + Prisma)
  │   ├─ Implement feature flag for gradual rollout
  │   ├─ Migrate models one-by-one with tests
  │   └─ Document migration process
  └─ Outputs: Migration complete, all tests passing
```

### Why It Works

- **Explore** provides fast codebase mapping (read-only, Haiku)
- **gco-research** investigates external best practices (web search, docs)
- **gco-research** has time to compare options without implementation pressure
- **gco-dev** implements with full context (internal code + external research)
- Three-agent separation ensures thorough understanding before changes

### Code Example

```javascript
// Step 1: Fast codebase search
const codebaseFindings = await spawnAgent({
  type: "Explore",
  prompt: "Find all Sequelize model definitions and queries",
  tools: ["Read", "Grep", "Glob"]
});

// Step 2: Deep technical research
const research = await spawnAgent({
  type: "gco-research",
  prompt: `Research Sequelize to Prisma migration best practices.

  Context: Found ${codebaseFindings.fileCount} files with ${codebaseFindings.modelCount} models.

  Investigate:
  - Migration strategies
  - Common pitfalls
  - Testing approach
  - Rollback plan`,
  tools: ["Read", "Grep", "WebSearch", "WebFetch"]
});

// Step 3: User review (truncated)
if (await userApproves(research)) {

  // Step 4: Implementation
  await spawnAgent({
    type: "gco-dev",
    prompt: `Migrate Sequelize to Prisma:

    Codebase: ${codebaseFindings.summary}
    Strategy: ${research.migrationStrategy}

    Follow: TDD workflow, gradual rollout plan`,
    tools: "full"
  });
}
```

### Anti-Patterns

**❌ Don't skip research phase:**
```
Main Agent:
  └─> Spawns gco-dev immediately
      └─> Dev researches during implementation
          └─> Slower, more error-prone, misses best practices
```

**❌ Don't use gco-research for both codebase search AND web research:**
```
Main Agent:
  └─> Spawns gco-research
      ├─ Searches codebase manually (slower than Explore)
      └─> Then researches web (should have used Explore first)
```

---

## Pattern 5: Plan → gco-dev (Multiple) in Parallel (Plan then Execute)

### Use Case

You want strategic planning followed by parallel implementation across multiple domains.

### When to Use

- Large features spanning backend, frontend, infrastructure
- Want quick strategic breakdown before detailed work
- Need parallel execution for speed
- Have clear domain boundaries (can work independently)

### Example Flow

```
User: "Implement user authentication system"

Main Agent:

  Step 1: Spawn Plan (built-in)
  ├─ Prompt: "Plan authentication system implementation"
  └─ Returns: Strategic breakdown
      ├─ Backend: JWT generation, login/logout APIs
      ├─ Frontend: Login form, auth context, protected routes
      ├─ Infrastructure: Environment variables, CORS setup
      └─ Testing: Integration tests, E2E flows

  Step 2: Review plan with user
  "Authentication system plan:
   - Backend: 3 API endpoints (login, logout, refresh)
   - Frontend: 2 components, 1 context provider
   - Infrastructure: Environment config, CORS

   I can spawn agents to work these in parallel. Proceed?"

  Step 3: Spawn gco-dev agents in parallel

  ├─ gco-dev-backend:
  │   ├─ Prompt: "Implement JWT APIs (login, logout, refresh)"
  │   └─ Works: REQ-101, REQ-102, REQ-103

  ├─ gco-dev-frontend:
  │   ├─ Prompt: "Implement login UI and auth context"
  │   └─ Works: REQ-104, REQ-105

  └─ gco-dev-infrastructure:
      ├─ Prompt: "Configure auth environment and CORS"
      └─ Works: REQ-106

  All agents work simultaneously, following Ghost County protocols.
```

### Why It Works

- **Plan** agent provides quick domain breakdown (no detailed requirements)
- **Plan** agent identifies parallelization opportunities (independent work)
- **gco-dev** agents work in parallel (faster overall delivery)
- **gco-dev** agents follow Ghost County protocols (TDD, commit conventions, roadmap updates)
- Clear domain boundaries prevent merge conflicts

### Code Example

```javascript
// Step 1: Strategic planning
const plan = await spawnAgent({
  type: "Plan",
  prompt: "Plan authentication system implementation",
  mode: "plan"
});

// Step 2: User review (truncated)
if (await userApproves(plan)) {

  // Step 3: Spawn parallel workers
  await Promise.all([
    spawnAgent({
      type: "gco-dev-backend",
      prompt: `Implement JWT APIs: ${plan.backend}`,
      assignment: "REQ-101, REQ-102, REQ-103"
    }),

    spawnAgent({
      type: "gco-dev-frontend",
      prompt: `Implement login UI: ${plan.frontend}`,
      assignment: "REQ-104, REQ-105"
    }),

    spawnAgent({
      type: "gco-dev-infrastructure",
      prompt: `Configure auth environment: ${plan.infrastructure}`,
      assignment: "REQ-106"
    })
  ]);
}
```

### Anti-Patterns

**❌ Don't spawn parallel agents without domain boundaries:**
```
Main Agent:
  └─> Spawns 3 gco-dev agents to work "authentication"
      └─> All agents try to modify same files
          └─> Merge conflicts, wasted effort
```

**❌ Don't skip planning phase for complex features:**
```
User: "Implement authentication"

Main Agent:
  └─> Spawns gco-dev immediately
      └─> Dev guesses at scope, misses components
          └─> Incomplete implementation
```

---

## Decision Matrix: When to Use Each Pattern

| Scenario | Pattern | Why |
|----------|---------|-----|
| Refactoring existing code | Explore → gco-dev | Need fast read-only search first |
| Complex new feature | Plan → gco-project-manager | Need strategy then formalization |
| Implementation + review | general-purpose → gco-code-reviewer | Independent review prevents bias |
| Migration with unknowns | Explore → gco-research → gco-dev | Need both codebase + external research |
| Large multi-domain feature | Plan → gco-dev (parallel) | Strategic breakdown then parallel work |
| Simple bug fix | gco-dev only | No hybrid needed for straightforward work |
| Quick code search | Explore only | Fast read-only search, no implementation |
| Strategic planning | Plan only | High-level breakdown, no formalization yet |

---

## General Principles

### 1. Leverage Tool Restrictions

- **Explore:** Read-only (fast, safe, no accidental modifications)
- **Plan:** Plan mode (strategic thinking, no detailed implementation)
- **gco-code-reviewer:** Read-only (independent review, no implementation bias)

### 2. Separate Concerns

- **Research → Implementation:** Don't research during coding
- **Plan → Formalize:** Strategy separate from detailed requirements
- **Implement → Review:** Don't review your own code

### 3. Use Appropriate Models

- **Explore:** Haiku (fast searches, cost-effective)
- **Plan:** Sonnet (strategic reasoning)
- **gco-dev:** Inherit (user's choice, usually Sonnet/Opus for implementation)

### 4. Follow Ghost County Protocols

When using Haunt agents, always follow:
- Session startup checklist (gco-session-startup)
- TDD workflow (gco-tdd-workflow)
- Commit conventions (gco-commit-conventions)
- Roadmap updates (gco-roadmap-workflow)

### 5. Avoid Over-Engineering

Don't use hybrid patterns for simple tasks:
- Single-file changes → Use gco-dev directly
- Documentation updates → Use general-purpose
- Quick fixes → No need for research phase

---

## Advanced Patterns

### Pattern 6: Coven Mode (Multi-Agent Orchestration)

For very large features requiring coordinated parallel work across multiple agents, use `/coven` command:

```
User: "/coven Implement e-commerce checkout flow"

Coven Mode:
  ├─ Analyzes feature scope
  ├─ Defines agent contracts (file ownership, interfaces)
  ├─ Spawns coordinated agents:
  │   ├─ gco-dev-backend (payment processing)
  │   ├─ gco-dev-frontend (checkout UI)
  │   ├─ gco-dev-infrastructure (payment gateway setup)
  │   └─ gco-research (PCI compliance requirements)
  └─ Aggregates results and resolves conflicts
```

**See:** `Haunt/skills/gco-coven-mode/SKILL.md` for details.

### Pattern 7: Seance Orchestration (Full Workflow)

For new projects or major features, use `/seance` for complete idea-to-implementation orchestration:

```
User: "/seance Build a task management app"

Seance Workflow:
  ├─ Mode detection (new vs existing project)
  ├─ Optional: Plan agent for strategic breakdown
  ├─ gco-project-manager for formal requirements
  ├─ Roadmap creation with batches
  └─ Optional: Summon worker spirits (gco-dev, gco-research)
```

**See:** `Haunt/skills/gco-seance/SKILL.md` for details.

---

## Anti-Patterns to Avoid

### ❌ Don't Use Haunt Agents for Everything

Built-in agents are optimized for specific tasks:
- **Explore** is faster for read-only searches (Haiku model)
- **Plan** is better for quick strategic thinking (no Ghost County overhead)

**Wrong:**
```
User: "Search for TODO comments"
Main Agent → Spawns gco-research
```

**Right:**
```
User: "Search for TODO comments"
Main Agent → Spawns Explore
```

### ❌ Don't Skip Agent Specialization

Use the right agent for the job:

**Wrong:**
```
User: "Implement and review authentication"
Main Agent → Spawns single gco-dev for both
```

**Right:**
```
Main Agent:
  ├─ Spawns general-purpose for implementation
  └─ Spawns gco-code-reviewer for review
```

### ❌ Don't Over-Orchestrate Simple Tasks

Hybrid patterns add overhead - use them wisely:

**Wrong:**
```
User: "Fix typo in README"
Main Agent:
  ├─ Spawns Explore to find README
  ├─ Spawns Plan for fix strategy
  └─ Spawns gco-dev for implementation
```

**Right:**
```
User: "Fix typo in README"
Main Agent → Makes edit directly (no agents needed)
```

---

## Summary

Hybrid workflows combining built-in and Haunt agents provide:

1. **Speed:** Haiku-powered Explore for fast searches
2. **Strategic Thinking:** Plan agent for quick high-level breakdown
3. **Formalization:** gco-project-manager for Ghost County roadmaps
4. **Quality:** Separate implementation and review agents
5. **Protocols:** Haunt agents enforce TDD, commit conventions, roadmap tracking

**Key Principle:** Use the right agent for each phase of work, combining strengths for optimal results.

---

**See Also:**
- `Haunt/docs/TOOL-PERMISSIONS.md` - Agent tool access reference
- `.haunt/docs/research/claude-builtin-agents-analysis.md` - Built-in agent research
- `Haunt/skills/gco-seance/SKILL.md` - Seance orchestration workflow
- `Haunt/skills/gco-coven-mode/SKILL.md` - Multi-agent coordination
