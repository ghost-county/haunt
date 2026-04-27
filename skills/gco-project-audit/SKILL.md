---
name: gco-project-audit
description: >-
  Audit a Claude Code project against the 10 Principles: hardening, context hygiene, living documentation, disposable blueprints, institutional memory, specialized review, observability, human gates, token economy, and toolkit design.
  Use when evaluating project quality, onboarding to a new codebase, or assessing gaps in AI-assisted development practices.
last-verified: 2026-04-09
---

# Project Audit — 10 Claude Code Principles

## Vocabulary Payload

| Term | Definition | Use When |
|------|-----------|----------|
| hardening | Replacing fuzzy LLM steps with deterministic tools | Evaluating workflow reliability |
| context hygiene | Managing context as scarce resource; U-shaped attention curve | Assessing CLAUDE.md, session discipline |
| living documentation | Docs with freshness tracking, structured format, canonical examples | Checking doc maintenance practices |
| disposable blueprint | Versioned plan artifacts that survive context resets | Evaluating planning discipline |
| institutional memory | Always/Never X BECAUSE Y rules codified in CLAUDE.md | Assessing knowledge retention |
| specialized review | Domain-specific reviewers with vocabulary routing (<50 token identities) | Evaluating code review agents |
| observability | Structured JSON logging at all agent/tool boundaries | Assessing pipeline visibility |
| strategic human gate | 2-3 approval points at irreversible decisions (5-20% rejection rate) | Checking human oversight |
| token economy | Cascade escalation; 45% threshold; team cap at 3-5 agents | Evaluating cost discipline |
| toolkit principle | Encoding practices into automated tools, not manual discipline | Assessing automation maturity |
| MAST taxonomy | 14 multi-agent failure modes across communication, coordination, quality | Diagnosing pipeline failures |
| vocabulary routing | Domain terms that activate expert knowledge clusters in embedding space | Evaluating agent/skill quality |
| progressive disclosure | 4-layer context loading: identity -> SOPs -> full docs -> compressed | Assessing context strategy |
| rubber-stamp (FM-3.1) | Reviewer approving without scrutiny; >85% approval in <5s | Detecting review quality issues |

## Anti-Patterns

| Anti-Pattern | Detection Signal | Resolution |
|-------------|-----------------|------------|
| Kitchen-sink context | CLAUDE.md >500 lines; 15+ plugins loaded | Trim to essentials; disable unused plugins |
| Session death spiral | 40+ message sessions with quality drift | `/clear` between work units; externalize state |
| Stale documentation | No `last-verified` dates; prose-only conventions | Add freshness tracking; restructure as heading+rule+example |
| Sunk-cost attachment | Patching failed approaches instead of restarting | Kill branch, revise blueprint, restart clean |
| Rules without reasons | Bare "Never do X" directives in CLAUDE.md | Add BECAUSE clause to every rule |
| Generalist reviewer | Single agent reviewing all domains | Split into domain specialists with vocabulary routing |
| Black box pipeline | No logging between agent handoffs | Add structured JSON logging at boundaries |
| Flattery persona | "World's best expert" in agent definitions | Replace with real job title + vocabulary (<50 tokens) |
| Default multi-agent | 5-agent team for every task | Start single-agent; cascade only with evidence |
| Manual discipline dependency | Practices that work only if developer remembers | Encode in tools, hooks, or CI |

## Audit Procedure

### Step 1: Read Project Context

Read CLAUDE.md, project structure, hooks, agents, skills, and recent git history. Build a mental model of the project's current practices.

### Step 2: Score Each Principle

For each of the 10 principles, READ the corresponding reference file and score the project:

| # | Principle | Reference | Score |
|---|-----------|-----------|-------|
| P1 | Hardening | `references/p01-hardening.md` | Strong / Partial / Weak / Missing |
| P2 | Context Hygiene | `references/p02-context-hygiene.md` | Strong / Partial / Weak / Missing |
| P3 | Living Documentation | `references/p03-living-documentation.md` | Strong / Partial / Weak / Missing |
| P4 | Disposable Blueprints | `references/p04-disposable-blueprints.md` | Strong / Partial / Weak / Missing |
| P5 | Institutional Memory | `references/p05-institutional-memory.md` | Strong / Partial / Weak / Missing |
| P6 | Specialized Review | `references/p06-specialized-review.md` | Strong / Partial / Weak / Missing |
| P7 | Observability | `references/p07-observability.md` | Strong / Partial / Weak / Missing |
| P8 | Strategic Human Gates | `references/p08-strategic-human-gates.md` | Strong / Partial / Weak / Missing |
| P9 | Token Economy | `references/p09-token-economy.md` | Strong / Partial / Weak / Missing |
| P10 | Toolkit | `references/p10-toolkit.md` | Strong / Partial / Weak / Missing |

For each principle, use the reference file's "What to Check" checklist and "Common Violations" list.

### Step 3: Identify Top Gaps

Rank principles by impact gap (distance between current state and Strong). Focus on:
- Any principle scored **Missing** (critical gap)
- Any principle scored **Weak** with high blast radius (P1, P7, P8)
- Patterns where multiple principles intersect (e.g., stale docs + no freshness automation = P3 + P10)

### Step 4: Produce Report

```markdown
## Project Audit Report — 10 Principles

### Scorecard

| # | Principle | Score | Key Finding |
|---|-----------|-------|-------------|
| P1 | Hardening | ... | ... |
| ... | ... | ... | ... |

### Top 3 Gaps (Prioritized)

1. **[Principle]** — [What's missing and why it matters]
   - Evidence: [Specific files/configs observed]
   - Recommendation: [Concrete first step]

2. ...

3. ...

### Strengths

- [What the project does well, with evidence]

### Full Findings

[Per-principle details with file:line references]
```

## Questions This Skill Answers

- How does this project measure against the 10 Claude Code Principles?
- What are the biggest gaps in this project's AI-assisted development practices?
- Is our CLAUDE.md well-structured for LLM consumption?
- Do we have proper institutional memory (always/never rules with BECAUSE)?
- Are our review agents using vocabulary routing and brief identities?
- Is our pipeline observable or a black box?
- Do we have strategic human gates at the right decision points?
- Are we over-spending on multi-agent workflows?
- Is our documentation structured and maintained?
- Are our practices encoded in tools or dependent on manual discipline?
- Should we audit this project before onboarding a new developer?
- What should we fix first to get the most improvement?
