# Haunt Framework: 10 Principles Evaluation (Synthesized)

**Date:** 2026-04-03 (synthesized from 2026-03-31 analysis + 2026-04-03 re-evaluation)
**Methodology:** Original analysis ran against an older, larger Haunt (7 agents, 40+ skills, 12 rules). This revision evaluates the **current** streamlined Haunt (4 agents, 17 skills, 6 rules) and resolves conflicts by trusting the current-state assessment.

---

## What Haunt Is (Current State)

Haunt is a **dev guardrails and agent coordination toolkit** for Claude Code, deployed globally at `~/.claude/`. It provides:

1. **4 Agent definitions** (`~/.claude/agents/`): Dev (Sonnet), Project Manager (Opus), Research (Opus), Code Reviewer (Sonnet)
2. **17 Skills** (`~/.claude/skills/`): Code quality, testing, standards, methodology, orchestration
3. **6 Rules** (`~/.claude/rules/`): Communication, completion checklist, decisions, team coordination, UI testing, visual verification
4. **4 Commands**: `/seance`, `/ship`, `/qa`, `/checkup`
5. **7 Hooks**: Commit validation, completion gates, file location enforcement, code formatting, phase enforcement, notifications, damage control patterns
6. **Seance workflow**: Scrying (planning) → Summoning (execution) → Banishing (archival), powered by Claude Code Agent Teams

**Notable changes since prior analysis:** Research Critic merged into Research agent (dual-mode), Release Manager removed (covered by `/ship`), MCP hygiene rule removed, session startup protocol removed, model selection rule removed, pattern-defeat skill removed, witching-hour debugging skill removed, framework-changes governance rule removed, roadmap-format rule removed. Agent count: 7→4, skill count: 40+→17, rule count: 12→6.

---

## The 10 Principles (Reference)

| Act | # | Principle | Core Idea |
|-----|---|-----------|-----------|
| Foundations | P1 | Hardening | Replace fuzzy LLM steps with deterministic tools |
| Foundations | P2 | Context Hygiene | Context is scarce — clear aggressively, externalize state, load minimally |
| Foundations | P3 | Living Documentation | Docs are agent instructions — structured, machine-readable, freshness-checked |
| Execution | P4 | Disposable Blueprint | Plan in versioned files; kill branches and restart when execution fails |
| Execution | P5 | Institutional Memory | Codify mistakes as Always/Never + BECAUSE rules |
| Execution | P6 | Specialized Review | Specialist agent panels > single generalist reviewer |
| Governance | P7 | Observability | Structured logging to detect 14 MAST failure modes |
| Governance | P8 | Strategic Human Gate | 2-3 human checkpoints at irreversible decisions |
| Governance | P9 | Token Economy | Start single-agent; multi-agent has diminishing returns past 3-5 |
| Capstone | P10 | Toolkit | Encode principles into automated tools |

Key citations: Liu et al. 2024 ("Lost in the Middle"), Wu et al. 2025 (U-shaped attention), Hong et al. 2023 (MetaGPT structured artifacts), PRISM persona framework, DeepMind 2025 multi-agent scaling, MAST failure taxonomy (14 failure modes), Zamfirescu-Pereira et al. CHI 2023 ("Why Johnny Can't Prompt"), Ranjan et al. 2024 (vocabulary routing in embedding space).

---

## Principle-by-Principle Evaluation

### Principle 1: The Hardening Principle — Score: 7/10

**What it says:** "Every fuzzy LLM step that must behave identically every time must eventually be replaced by a deterministic tool." 7-step framework: map → categorize → prototype → build → restrict LLM → test → log.

**What Haunt does well:**
- Damage control hooks (`patterns.yaml`, `commit-validator.sh`, `completion-gate.sh`, `file-location-enforcer.sh`, `phase-enforcement.sh`) are textbook hardening — regex and filesystem checks replace LLM judgment
- Phase enforcement uses a filesystem flag (`.haunt/state/summoning-approved`) rather than trusting the LLM to remember what phase it's in
- `format-code.sh` hook deterministically runs formatters by file type
- Completion gate checks for verification evidence files, not LLM self-assessment

**Gaps:**
- **No explicit hardening principle or workflow.** No guidance on *when* to harden a workflow step vs. leave it fuzzy. The old version had `gco-pattern-defeat` (Find → Test → Enforce → Record cycle) which was a hardening workflow — now removed.
- **Orchestration delegation is entirely prompt-driven.** The seance orchestrator decides whether to spawn agents based on LLM interpretation of instructions, not a routing script.
- **No CI-level enforcement.** Hooks run locally but there's no pipeline preventing malformed requirements from persisting.

**Adjustment needed:** Add a skill or reference doc codifying the hardening decision framework: "If a step must behave identically every time, replace it with a script/hook. LLM handles orchestration and reasoning; scripts handle mechanical execution."

---

### Principle 2: The Context Hygiene Principle — Score: 4/10

**What it says:** Optimal performance at 15-40% context utilization. U-shaped attention curve (30%+ accuracy drop for mid-context info). Progressive disclosure in 4 layers. Clear conversations aggressively. Manage tool loading per session.

**What Haunt does well:**
- Skills use progressive disclosure (YAML frontmatter → slim body → `references/` subdirectory)
- Rules are lean (each under 100 lines), loaded automatically
- Seance dual-track model externalizes plans to files that survive session resets

**Gaps (significant):**
- **No `/clear` discipline.** No skill, rule, or guidance telling agents/users to clear between work units. The seance workflow doesn't prescribe session boundaries between scrying and summoning.
- **No context audit tooling.** No equivalent to `jig` — Haunt deploys *everything* to `~/.claude/` and loads it all. No per-task tool profiles. The old `gco-mcp-hygiene` rule (which tracked tool budget <80 and recommended agent-scoped MCPs) was removed in the streamline.
- **No U-shaped attention guidance.** Skills don't order content by attention priority (vocabulary first, retrieval anchors last).
- **CLAUDE.md has no size guard.** Currently ~100 lines (fine), but no mechanism preventing bloat.
- **No tool loading management.** All MCP servers, skills, and plugins load regardless of task type.

**Prior analysis rated this "Full"** based on features that no longer exist (MCP hygiene rule, session startup protocol with 98% token reduction via grep, model selection rule). Those were removed in the streamline. Current state has meaningful gaps.

**Adjustment needed:** (1) Add `/clear` guidance to seance workflow — prescribe session boundaries between phases and work units. (2) Explore `jig`-style profiles or equivalent for task-type-specific tool loading. (3) Add attention-optimized ordering guidance to the skill format spec.

---

### Principle 3: The Living Documentation Principle — Score: 5/10

**What it says:** Documentation is agent instructions, not human reference. Structured, machine-readable, automatically checked for freshness. Few-shot examples outperform abstract rules. Stale docs actively poison output. `last-verified` dates + CI freshness checks.

**What Haunt does well:**
- Documentation IS structured and machine-readable: YAML frontmatter on all skills/agents, consistent Markdown hierarchy
- Skills include few-shot examples (BAD/GOOD pairs in `gco-code-review`, pattern examples elsewhere)
- `setup-haunt.sh --verify` checks deployment health (file counts, SKILL.md existence)

**Gaps:**
- **No `last-verified` timestamps.** No mechanism detecting stale skills or rules.
- **No freshness automation.** Nothing flags a skill that hasn't been updated in 90 days. The old version lacked this too — it's a persistent gap.
- **No documentation-code co-location requirement.** No rule saying "when you change code patterns, update the relevant skill in the same PR."
- **No cross-reference validation.** No verification that tool lists in agent YAML match available MCP servers, or that skill references in agents point to skills that actually exist.

**Adjustment needed:** (1) Add `last-verified: YYYY-MM-DD` frontmatter to all skill and rule files. (2) Create `haunt-doc-freshness.sh` that flags files not verified within 30 days. (3) Add a cross-reference check to `setup-haunt.sh --verify`.

---

### Principle 4: The Disposable Blueprint Principle — Score: 8/10

**What it says:** "Never implement without a saved, versioned plan artifact." Blueprint-Branch-Build cycle. Plans are versioned, code is disposable. `/clear` between planning and implementation. ~40% fewer errors with structured artifacts (Hong et al. 2023).

**What Haunt does well:**
- Seance workflow explicitly implements Blueprint-Branch-Build: Scrying creates `roadmap.md` and `requirements-document.md` before Summoning begins
- Phase enforcement hook *blocks* spawning dev agents before planning approval — deterministic gate
- Plans are first-class versioned artifacts in `.haunt/plans/`
- PM produces structured deliverables with JTBD, Kano, RICE analysis
- Planning depths (Quick/Standard/Deep) match effort to complexity

**Gaps:**
- **No explicit "kill the branch and restart" guidance.** The seance doesn't have a restart ritual for when execution goes sideways. The core insight — "code is disposable, plans are capital" — isn't articulated in any rule.
- **No `/clear` between scrying and summoning.** The plan carries forward in conversation context rather than being re-read fresh.

**Adjustment needed:** Add restart guidance to seance orchestration: "When execution diverges fundamentally from the plan, kill the branch, update the blueprint with learned information, and restart fresh."

---

### Principle 5: The Institutional Memory Principle — Score: 3/10

**What it says:** Maintain a living engineering handbook of project-specific mistakes. "Always/Never [action] BECAUSE [reason]" format. Rules with explanations generalize; bare directives fossilize. Named anti-patterns activate knowledge clusters. Prune quarterly.

**What Haunt does well:**
- Skills contain anti-pattern lists (`gco-code-patterns` has 12, `gco-react-standards` has its own)
- `gco-decisions` rule provides a decision filter with rationale
- Some rules include reasoning (e.g., `gco-decisions` explains YAGNI exceptions)

**Gaps (significant):**
- **No "Always/Never X BECAUSE Y" section in CLAUDE.md.** The 10 Principles recommends a living section of project-specific learned mistakes. Haunt's anti-patterns are generic best practices, not project-specific institutional knowledge.
- **No codification workflow.** When an agent makes a mistake, there's no process to add it to a handbook. The fix happens in-session and is lost. The old version had `gco-pattern-defeat` (Find → Test → Enforce → Record) and `gco-witching-hour` (which created agent memory entries with pattern/root-cause/fix/prevention/lesson structure) — both removed.
- **No named anti-patterns with project history.** "The timezone bug" pattern — naming recurring failures for quick knowledge activation — isn't used.
- **Most rules lack BECAUSE clauses.** `gco-communication` says "NEVER start messages with 'Great'" but doesn't explain *why* (training distribution routing). Rules say *what* but not *why*, limiting generalization.
- **No quarterly pruning discipline.** No automated staleness detection or scheduled review.

**Prior analysis rated this "Full"** based on pattern-defeat skill, witching-hour debugging skill, and agent memory MCP integration — all removed in the streamline. Current state is a significant gap.

**Adjustment needed:** (1) Add "Always/Never X BECAUSE Y" section to CLAUDE.md for project-specific learned mistakes — start with 5-10 rules. (2) Create a codification workflow: agent mistake → immediate correction → add to handbook. (3) Add BECAUSE clauses to all directive rules.

---

### Principle 6: The Specialized Review Principle — Score: 4/10

**What it says:** Specialist agent panels > single generalist reviewer. Vocabulary routing (15-30 domain terms) activates domain knowledge. PRISM: identities <50 tokens, no flattery. Separate generation from evaluation completely. Run deterministic checks before LLM review.

**What Haunt does well:**
- Generation-evaluation separation exists: `gco-dev` generates, `gco-code-reviewer` evaluates
- Agent identities are brief and role-specific (no flattery, matching PRISM guidance)
- `gco-communication` rule prohibits enthusiasm markers
- Code review skill has named anti-patterns with detection signals

**Gaps (significant):**
- **Single generalist reviewer, not specialist panel.** The code reviewer checks security AND performance AND patterns AND testing simultaneously — exactly the "generalist trap" P6 warns about. "When a single prompt tries to activate security AND performance AND accessibility AND domain logic simultaneously, the model activates the shallow intersection of all four rather than the depth of any one."
- **No vocabulary routing.** No 15-30 domain-specific expert terms per review domain. No "OWASP Top 10, STRIDE threat model" for security; no "WCAG 2.2 AA, ARIA landmark patterns" for accessibility.
- **No deterministic checks before LLM review.** P6 says "Always run the build, linter, and test suite BEFORE sending code to LLM reviewers." The `format-code.sh` hook runs formatters but there's no explicit "run lint + tests first, then review" gate.
- **No evidence-backed clearance requirement.** The reviewer can say "APPROVED" without citing specific evidence. P6 requires "identify at least one issue OR provide evidence-backed justification for clearance."

**Prior analysis rated this "Full"** based on the Research Critic agent providing a second specialist reviewer — now merged into the dual-mode Research agent, which weakens the specialist separation. The vocabulary gap was acknowledged in the old analysis too.

**Adjustment needed:** (1) Split code reviewer into 2-3 specialist reviewers (minimum: security specialist + code quality specialist). (2) Add vocabulary routing (15-30 expert terms per domain). (3) Require evidence-backed justification for every clean review — no bare "APPROVED."

---

### Principle 7: The Observability Imperative — Score: 1/10

**What it says:** Log every tool call, LLM interaction, plan artifact, and workflow outcome with structured JSON. Detect the 14 MAST failure modes. Artifact hashing for handoff verification. Rubber-stamp detection (>85% approval rate, <5s latency = alarm).

**What Haunt does well:**
- Roadmap status tracking provides workflow-level visibility (icons, task checkboxes)
- Session handoff files document state transitions (though these were also largely removed)

**Gaps (critical — largest gap in framework):**
- **No structured logging of agent activity.** No JSON logs of tool calls, LLM interactions, handoff artifacts, or timing during normal operation.
- **No awareness of the 14 MAST failure modes.** No monitoring for message loss (FM-1.1), rubber-stamp approval (FM-3.1), error cascading (FM-3.2), regression (FM-3.5), groupthink (FM-3.4), or any other failure mode.
- **No approval metrics.** No tracking of code reviewer approval rates or response times. If the reviewer rubber-stamps everything, there's no signal.
- **No pipeline viewer.** No way to see what each agent produced and consumed during a seance.
- **No artifact hashing at handoffs.** When the PM hands requirements to the dev, there's no verification the full context was received.

**Both analyses agree:** This is the largest gap. The old version had `gco-witching-hour` (structured debugging with trace IDs) and `gco-code-quality` (Pass 4 hardening with observability), but these were reactive and skill-level, not continuous pipeline observability.

**Adjustment needed:** (1) Create a PostToolUse hook logging tool calls to `.haunt/logs/session-YYYY-MM-DD.jsonl` (structured JSON: agent, tool, inputs hash, outputs hash, duration, timestamp). (2) Add approval metrics to code reviewer. (3) Build a simple `haunt-observability.sh` script detecting rubber-stamp patterns. (4) Hash artifacts at agent handoff points.

---

### Principle 8: The Strategic Human Gate Principle — Score: 5/10

**What it says:** 2-3 human checkpoints at irreversible/high-blast-radius decisions. Low friction (5 min max), structured output (summary, risks, confidence). Rejection rate 5-20% is healthy; 0% = decorative gates. Circuit breakers, not toll booths.

**What Haunt does well:**
- Scrying gate requires user approval before summoning — enforced by phase enforcement hook with filesystem state
- `/ship` command creates PR (human review point before merge)
- Damage control hooks implement ASK pattern for potentially destructive operations
- Planning depths are user-selected, giving human control over workflow intensity

**Gaps:**
- **Only ONE explicit human gate** (summoning approval). The Three-Gate Pattern recommends: (1) Plan Review, (2) Pre-Hardening/Pre-Commit, (3) Pre-Deploy. Haunt has gate 1 but not 2 or 3 as structured gates.
- **No structured gate output format.** The orchestrator asks "Ready to summon?" but doesn't present a structured summary with files affected, risks identified, and confidence level.
- **No gate rejection rate tracking.** No observability on gate decisions — can't distinguish productive gates from decorative ones.
- **Code Reviewer is an LLM agent, not a human gate.** P8 specifically warns LLM reviewers share generator biases (FM-3.1 Rubber-Stamp, FM-3.4 Groupthink). For M-sized work, a human should review after the agent reviewer.

**Adjustment needed:** (1) Add structured gate output template: summary, files affected, risks, confidence, approve/reject prompt. (2) Add pre-merge human gate for M-sized work (after code reviewer, before marking complete). (3) Track rejection rates in `.haunt/logs/`.

---

### Principle 9: The Token Economy Principle — Score: 2/10

**What it says:** Single agents handle 70% of tasks over-provisioned to 3-5 agent teams. 45% threshold: if a single agent achieves >45% optimal, don't add agents. Cascade pattern: L0 (single) → L1 (single+tools) → L2 (worker+reviewer) → L3 (small team). Cap at 3-5 agents. Track cost per unit of useful output.

**What Haunt does well:**
- 4 agents is within the 3-5 cap (streamline helped here)
- Planning depths (Quick skips analysis for XS tasks) avoid over-provisioning somewhat

**Gaps (significant):**
- **No token tracking.** No measurement of cost per workflow step, per agent, or per seance.
- **No cascade pattern.** The seance defaults to a 4-agent team regardless of task complexity. Simple tasks that a single well-prompted agent could handle still assemble the full roster.
- **No 45% threshold check.** No "can a single agent handle this?" evaluation before team assembly. No `/seance --solo` mode.
- **No adaptive composition.** Every seance uses the same 4-agent roster. No task-based agent selection (Captain Agent research shows adaptive outperforms static by 15-25%).
- **No hard caps or per-step token budgets.**
- **Context loading not managed.** All skills, rules, and tools deploy and potentially load regardless of task type.

**Prior analysis noted** the old version had model selection rules (Opus for strategic, Sonnet for implementation, Haiku for reconnaissance) providing cost-conscious model assignment — removed in streamline. MCP hygiene rule tracking tool budget — also removed.

**Adjustment needed:** (1) Add cascade pattern to seance: XS/S tasks default to single-agent (L0/L1), only escalate to team when single agent demonstrably fails. (2) Add `/seance --solo` mode. (3) Instrument most expensive workflow for token tracking. (4) Make agent composition adaptive — not every task needs PM + Research + Dev + Reviewer.

---

### Principle 10: The Toolkit Principle — Score: 6/10

**What it says:** "Knowledge without automation decays. Encode principles into tools." Skill architecture: vocabulary payload FIRST, anti-pattern watchlist BEFORE behavioral instructions, "Questions This Skill Answers" at END. 15-30 domain terms per skill. Dual-register descriptions. Progressive disclosure via `references/`. Skills under 500 lines.

**What Haunt does well:**
- Haunt IS a toolkit — the framework itself encodes workflow principles into versioned, deployable, automated tools
- Skills use progressive disclosure (YAML → body → references/)
- Anti-pattern watchlists encoded in skills (`gco-code-review`, `gco-code-patterns`, `gco-secure-coding`)
- BAD/GOOD examples in code review and code patterns skills
- Generation separated from evaluation (Dev vs Code Reviewer)
- Setup script deploys everything; `/checkup` verifies health

**Gaps:**
- **No vocabulary routing in any skill.** Skills use natural language instructions but lack the 15-30 expert terms that route the model to correct knowledge regions. No "15-year practitioner test" applied.
- **No dual-register descriptions.** Skill `description` fields are single-register (either natural language or expert, not both).
- **Skills don't follow attention-optimized layout.** Vocabulary payload should be FIRST (high attention zone). "Questions This Skill Answers" should be at END (recency zone). Behavioral instructions in the middle (structured to survive degraded attention). No skill currently follows this ordering.
- **No skill freshness management.** No "librarian" function detecting stale or overlapping skills.
- **No skill quality framework.** No standard for evaluating whether a skill meets the research-backed criteria.

**Adjustment needed:** (1) Define the Haunt skill architecture standard based on P10 research. (2) Restructure 3-5 critical skills to follow attention-optimized layout. (3) Add vocabulary payloads to top skills. (4) Add dual-register descriptions.

---

## Summary Scorecard

| # | Principle | Score | Status | Priority |
|---|-----------|-------|--------|----------|
| P1 | Hardening | **7/10** | Strong hooks, missing hardening workflow | Low |
| P2 | Context Hygiene | **4/10** | No session management, no selective loading | Medium |
| P3 | Living Documentation | **5/10** | Structured but no freshness checks | Medium |
| P4 | Disposable Blueprint | **8/10** | Core seance strength | Low |
| P5 | Institutional Memory | **3/10** | Generic anti-patterns, no project-specific codification | Medium-High |
| P6 | Specialized Review | **4/10** | Single generalist reviewer, no vocabulary routing | Medium-High |
| P7 | Observability | **1/10** | Essentially absent — largest gap | **HIGH** |
| P8 | Strategic Human Gate | **5/10** | One gate exists, needs structured output + tracking | Medium |
| P9 | Token Economy | **2/10** | No measurement, no cascade, always 4 agents | **HIGH** |
| P10 | Toolkit | **6/10** | Is a toolkit, but skills lack science-backed structure | Medium |

**Overall: 45/100.** Haunt is strong on foundations (P1, P4) but has critical gaps in governance (P7, P9) and meaningful gaps in execution discipline (P5, P6) and context management (P2).

**Comparison to prior analysis:** The prior analysis scored 5 Full, 4 Partial, 1 Gap. That was generous — it evaluated features that have since been removed (pattern-defeat, witching-hour, MCP hygiene, session startup, model selection, 7 agents, 40+ skills). The streamline to 4 agents and 17 skills improved focus and maintainability but widened several gaps that were previously partially covered.

---

## Forge and Jig Comparison

### Forge (github.com/jdforsythe/forge)

Forge automates agent team assembly from goals using four meta-skills (Mission Planner, Agent Creator, Skill Creator, Librarian) and three infrastructure agents (Verifier, Researcher, Reviewer). It includes 11 domain agents and 3 team templates.

| Dimension | Forge | Haunt |
|-----------|-------|-------|
| Purpose | Generate agent teams dynamically from goals | Fixed, curated agent framework + workflow |
| Agent creation | Automated (Mission Planner) | Manual (human-authored files) |
| Scope | Agent assembly tool | Full SDLC orchestration |
| Topology | Selects per-goal (pipeline/parallel/coordinator) | Fixed Seance (sequential) |
| Team sizing | Automatic cascade based on complexity | Always 4 agents |
| Vocabulary routing | Core design principle | Absent |
| Work management | None | Full roadmap/requirements/batch system |

**What Haunt should adopt:** (1) Vocabulary routing as explicit design pattern. (2) Cascade escalation (single → single+tools → worker+reviewer → team). (3) Adaptive topology selection.

### Jig (github.com/jdforsythe/jig)

Jig manages per-session tool loading via project-level profiles, enabling selective activation of plugins, MCP servers, skills, and hooks.

| Dimension | Jig | Haunt |
|-----------|-----|-------|
| Purpose | Selective tool/context loading | Orchestration + work management |
| Context management | Profile-driven (load only what you need) | Everything loads |
| Configurability | Per-project profiles with inheritance | Global deployment |

**What Haunt should adopt:** (1) Session profiles for task-type-specific tool loading. (2) Profile inheritance (base + project-specific extensions). (3) Launch-time tool selection instead of always-on everything.

---

## Recommended Adjustments (Prioritized)

### Phase 1: Quick Wins (XS-S effort, high impact)

**1. Institutional Memory Handbook** (P5)
Add "Always/Never X BECAUSE Y" section to project CLAUDE.md files. Start with 5-10 rules from real mistakes. Create codification workflow: agent mistake → correction → add to handbook.

**2. BECAUSE Clauses on Rules** (P5)
Every directive rule (`gco-communication`, `gco-completion-checklist`, etc.) gets an explanation of *why*. Enables generalization to novel situations.

**3. Cascade Pattern in Seance** (P9)
Add to orchestrator: "Before spawning a team, verify a single well-prompted agent cannot handle this. XS/S tasks default to single agent." Add `/seance --solo` mode. Document the L0-L4 cascade.

**4. `/clear` Discipline** (P2)
Add session boundary guidance to seance orchestration: clear between scrying and summoning, clear between work units within summoning, externalize state to plan files before clearing.

### Phase 2: Structural Improvements (S-M effort)

**5. Split Code Reviewer into Specialists** (P6)
Minimum: security specialist (OWASP vocabulary, STRIDE, CWE) + code quality specialist (pattern vocabulary, complexity metrics). Add 15-30 domain terms per specialist. Keep identities <50 tokens. Require evidence-backed justification for every clean review.

**6. Structured Gate Outputs** (P8)
Design template for human review points: summary, files affected, approach, identified risks, confidence level, approve/reject. Apply to summoning gate and add pre-merge gate for M-sized work.

**7. Skill Architecture Standard** (P10)
Define and document the attention-optimized skill format: vocabulary payload FIRST, anti-pattern watchlist BEFORE instructions, "Questions This Skill Answers" at END. Add dual-register descriptions. Restructure 3-5 critical skills as exemplars.

**8. Documentation Freshness** (P3)
Add `last-verified: YYYY-MM-DD` to all skill/rule frontmatter. Create `haunt-doc-freshness.sh` flagging files >30 days stale. Add cross-reference validation to `setup-haunt.sh --verify`.

### Phase 3: Observability (M effort, critical gap)

**9. Structured Agent Logging** (P7)
Create a PostToolUse hook logging to `.haunt/logs/session-YYYY-MM-DD.jsonl`. Structured JSON: agent, tool, inputs hash, outputs hash, duration, timestamp.

**10. Approval Metrics** (P7)
Track code reviewer approval rate and latency. Alert on >85% approval with <5s response (rubber-stamp detection).

**11. Pipeline Viewer** (P7)
Build minimal CLI tool reading structured logs, showing what each agent produced and consumed during a seance. Start with `haunt-observability.sh` script.

### Phase 4: Context Economy (M effort)

**12. Task-Type Profiles** (P2/P9)
Explore `jig`-style profiles or build native: different tool/skill loading for planning vs. implementation vs. review sessions. Default to minimal loading.

**13. Token Tracking** (P9)
Instrument seance to measure token spend per phase and per agent. Track cost per unit of useful output over time.

---

## Cited Research

| Citation | Year | Key Finding | Haunt Relevance |
|----------|------|-------------|-----------------|
| Liu et al., "Lost in the Middle" | 2024 | 30%+ accuracy drop for mid-context info | Validates front-loading constraints; exposes skill ordering gap |
| Wu et al. (MIT) | 2025 | U-shaped attention from RoPE + causal masking | Explains why attention-optimized skill layout matters |
| Hong et al. (MetaGPT) | 2023 | Structured artifacts reduce errors ~40% | Validates Haunt's REQ-XXX format and versioned plans |
| Ranjan et al. | 2024 | Word choice routes to knowledge clusters | Supports vocabulary payloads — Haunt's missing piece |
| PRISM | 2024 | Brief personas (<50 tokens) outperform elaborate; flattery degrades | Validates Haunt's lean agent identities |
| DeepMind | 2025 | Multi-agent plateaus at 3-4; 7+ underperforms | Supports cascade pattern; Haunt's 4 agents within cap |
| Captain Agent | 2024 | Adaptive composition beats static by 15-25% | Argues for dynamic agent selection per task |
| MAST Framework | 2024-2025 | 14 failure modes across communication/coordination/quality | Identifies what Haunt's observability gap cannot detect |
| Anthropic Harness Design | 2026 | Generators share evaluator biases; separate required | Validates Dev/Reviewer separation; warns about LLM-only review |
| Zamfirescu-Pereira et al. (CHI) | 2023 | "Positive + negative + reason" optimal format | Validates BECAUSE clauses and BAD/GOOD pairs |
| LangChain | 2024 | 3 well-chosen examples match 9 | Supports Haunt's compact example approach |
| Vaswani et al. | 2017 | Transformer self-attention mechanism | Foundation: context is quadratically expensive |

---

## Conclusion

Haunt's streamline from 7 agents to 4 and 40+ skills to 17 improved focus and maintainability, but it also removed several features that partially addressed the 10 Principles (pattern-defeat for P5, MCP hygiene for P2, witching-hour for P7, model selection for P9). The current framework is strong on **foundations** (hardening, disposable blueprints) but has critical gaps in **governance** (observability, token economy) and meaningful gaps in **execution discipline** (institutional memory, specialized review).

The recommended adjustments are incremental, not architectural. Phase 1 items (institutional memory, BECAUSE clauses, cascade pattern, `/clear` discipline) are text-level changes that can be done immediately. Phase 2 (specialist reviewers, gate outputs, skill architecture) requires structural changes to existing files. Phase 3 (observability) requires new tooling but follows existing hook patterns. Phase 4 (context economy) is the most exploratory.

The foundation is sound. The work is about adding measurement, codification, and specialization layers on top of existing workflow patterns.
