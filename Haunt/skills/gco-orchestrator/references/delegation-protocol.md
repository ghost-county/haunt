# Delegation Protocol: Detailed Guidance

## What Orchestrators DO (Execute Directly)

- **Mode detection:** Detect project state (new vs existing vs active)
- **User prompts:** Present choice prompts and mode selection
- **Parse input:** Extract planning depth modifiers, phase flags
- **Coordinate workflows:** Invoke PM for planning, spawn agents for execution
- **Archive/garden:** Clean up completed work after agents finish

## What Orchestrators DO NOT DO (Spawn Agents Instead)

- **External research:** WebSearch/WebFetch for competitive analysis, library comparisons
- **Codebase investigation:** Multi-file analysis (>10 files), pattern detection
- **Requirements analysis:** JTBD, Kano, RICE scoring → Spawn gco-project-manager
- **Implementation:** Writing code, tests, configs → Spawn gco-dev-*
- **Code review:** Quality gates, anti-pattern detection → Spawn gco-code-reviewer
- **Deep analysis:** Architecture reviews, strategic planning → Spawn gco-research-analyst

## Decision Tree: When to Spawn vs Execute

**Ask yourself:**
1. **Is this orchestration work?** (mode detection, prompts, coordination)
   - **YES:** Execute directly
   - **NO:** Continue to step 2

2. **Does this produce a deliverable?** (research doc, code, tests, analysis)
   - **YES:** Spawn appropriate agent
   - **NO:** Continue to step 3

3. **Does this require domain expertise?** (research, implementation, review)
   - **YES:** Spawn specialist agent
   - **NO:** Execute directly (likely coordination work)

**Token Efficiency Note:** Spawning specialists is MORE efficient than generalist trial-and-error. A research agent completes investigation in one focused pass; an orchestrator doing research involves multiple false starts and context switching.

---

## Anti-Patterns: WRONG vs RIGHT

### Anti-Pattern 1: Orchestrator Doing Research

**❌ WRONG:**
```
User: "/seance Research best Node.js auth libraries"

Orchestrator:
  [Executes 8 WebSearch calls directly]
  [Reads 15 documentation pages]
  [Creates comparison matrix]
  [Writes research summary]
  [Spawns gco-project-manager with findings]
```

**✅ RIGHT:**
```
User: "/seance Research best Node.js auth libraries"

Orchestrator:
  Spawning gco-research-analyst for external research...

Research Agent:
  [Executes focused investigation]
  [Writes deliverable: .haunt/docs/research/auth-libraries-comparison.md]

Orchestrator:
  Research complete. Spawning gco-project-manager with research context...

PM:
  [Creates roadmap using research findings]
```

**Why RIGHT is better:**
- Research agent has domain-specific expertise
- Produces formal deliverable (reusable)
- Cleaner separation of concerns
- Token efficient (specialist completes in fewer steps)

---

### Anti-Pattern 2: Orchestrator Writing Implementation Code

**❌ WRONG:**
```
User: "/seance Add JWT authentication"

Orchestrator:
  [Creates 5 implementation files directly]
  [Writes authentication logic]
  [Generates tests]
  [Commits code]

Status: Feature complete (orchestrator did everything)
```

**✅ RIGHT:**
```
User: "/seance Add JWT authentication"

Orchestrator:
  Spawning gco-project-manager for planning...

PM:
  [Creates roadmap with REQ-042, REQ-043, REQ-044]

Orchestrator:
  Ready to summon the spirits?

User: "yes"

Orchestrator:
  Spawning gco-dev-backend for REQ-042...
  Spawning gco-dev-backend for REQ-043...
  Spawning gco-dev-backend for REQ-044...

[Agents implement features autonomously]
```

**Why RIGHT is better:**
- Dev agents follow TDD workflow
- Proper testing protocol enforced
- Completion checklist verified
- Code review protocol available

---

### Anti-Pattern 3: Orchestrator Doing Multi-File Analysis

**❌ WRONG:**
```
User: "/seance Analyze authentication patterns in codebase"

Orchestrator:
  [Reads 30 source files directly]
  [Analyzes patterns across files]
  [Creates analysis document]
  [Summarizes findings]
```

**✅ RIGHT:**
```
User: "/seance Analyze authentication patterns in codebase"

Orchestrator:
  Spawning gco-research-analyst for codebase investigation...

Research Agent:
  [Executes structured analysis]
  [Uses targeted grep/read for efficiency]
  [Writes deliverable: .haunt/docs/research/auth-patterns-analysis.md]

Orchestrator:
  Analysis complete. Next steps: Create roadmap? (yes/no)
```

**Why RIGHT is better:**
- Research agent trained in codebase analysis patterns
- Produces structured, reusable deliverable
- Token-efficient (targeted file access)
- Clear audit trail

---

## When Direct Execution is Appropriate

Orchestrators SHOULD execute directly when:

- **Mode detection:** Checking for `.haunt/` directory existence
- **User prompts:** Presenting choice menus, waiting for input
- **Coordination:** Parsing roadmap for agent assignments
- **Trivial reads:** Single-file checks (version file, roadmap header)
- **Archival:** Moving completed work to `.haunt/completed/`

These are lightweight coordination tasks that don't benefit from spawning.

---

## Self-Check: Am I About to Call WebSearch/WebFetch?

**Before EVERY WebSearch or WebFetch call:**

1. ⛔ **STOP** - Do NOT proceed with the call
2. Ask yourself: "Am I an orchestrator or a research agent?"
3. If orchestrator: Spawn gco-research-analyst instead
4. If research agent: Proceed with research

**Example (WRONG):**
```python
# Orchestrator trying to do research
results = WebSearch("best Node.js auth libraries")
```

**Example (RIGHT):**
```python
# Orchestrator spawning research agent
Spawn gco-research-analyst with prompt: "Research best Node.js auth libraries"
```

---

## Success Criteria

You're following delegation protocol correctly when:

1. **You never use WebSearch/WebFetch directly** → Always spawn Research agent
2. **You never write implementation code** → Always spawn Dev agent
3. **You never do multi-file analysis** → Always spawn Research agent
4. **You spawn PM for planning phases** → Not just for complex features
5. **Your token usage is low** → Coordination overhead only, not execution work
6. **You run delegation gate checks** → At start and before each phase transition
