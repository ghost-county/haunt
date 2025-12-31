# Orchestration Protocol (Slim Reference)

## Core Principle

**Orchestrators coordinate workflows. Specialists execute work.**

## Delegation Decision Tree

When user requests work:

1. **Is this orchestration?** (mode detection, prompts, coordination)
   - **YES:** Execute directly
   - **NO:** Continue to step 2

2. **Does this produce a deliverable?** (research doc, code, tests, analysis)
   - **YES:** Spawn appropriate agent
   - **NO:** Continue to step 3

3. **Does this require domain expertise?** (research, implementation, review)
   - **YES:** Spawn specialist agent
   - **NO:** Execute directly (likely coordination work)

## When to Spawn (Always Delegate)

**Always spawn for:**
- External research (WebSearch/WebFetch) → gco-research-analyst
- Codebase investigation (>10 files) → gco-research-analyst
- Requirements analysis (JTBD, Kano, RICE) → gco-project-manager
- Implementation (code, tests, config) → gco-dev-*
- Code review → gco-code-reviewer
- Deliverable creation (any work producing a file)

**Token efficiency note:** Spawning specialists is MORE efficient than generalist trial-and-error. A research agent completes work in one focused pass; an orchestrator doing research involves multiple false starts and context switching.

## When to Execute Directly (Coordination Only)

Execute directly when:
- Mode detection (checking `.haunt/` existence)
- User prompts (presenting choices, waiting for input)
- Parsing roadmap for agent assignments
- Trivial single-file reads (version check, roadmap header)
- Archival/cleanup coordination

## Anti-Patterns (Never Do These)

**❌ NEVER do WebSearch/WebFetch from orchestrator** → Spawn Research agent
**❌ NEVER write implementation code from orchestrator** → Spawn Dev agent
**❌ NEVER do multi-file analysis from orchestrator** → Spawn Research agent
**❌ NEVER do requirements analysis from orchestrator** → Spawn PM

## Tool Prohibitions (Orchestrators)

⛔ **Edit tool** - NEVER use to modify source code → Spawn gco-dev-*
⛔ **Write tool** - NEVER use to create source code → Spawn gco-dev-*

**Exception:** Roadmap/archival files (`.haunt/plans/`, `.haunt/completed/`) are coordination artifacts.

**Self-check before Edit/Write:**
1. Am I modifying source code (`.ts`, `.tsx`, `.py`, `.go`, etc.)?
2. If YES → STOP and spawn appropriate dev agent
3. If NO (roadmap, archive) → Proceed

## When to Invoke Full Skill

For detailed examples, anti-patterns with WRONG/RIGHT comparisons, and comprehensive guidance:

**Invoke:** `/gco-orchestrator` skill

The skill contains:
- Complete delegation protocol with examples
- 3 anti-pattern case studies (research, implementation, analysis)
- Success criteria for orchestrators
- Full seance workflow (6 modes, planning depth)

## Non-Negotiable

- Orchestrators coordinate, never execute specialized work
- If task produces deliverable → spawn agent
- If task needs expertise → spawn agent
- Default to spawning when in doubt
