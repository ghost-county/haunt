# Plan: Haunt 10 Principles Gap Closure

## Context

Haunt was evaluated against JD Forsythe's "10 Claude Code Principles" (research-backed framework for production-grade agentic workflows). Current score: **45/100**. Strong on foundations (P1 Hardening: 7, P4 Disposable Blueprint: 8) but critical gaps in governance (P7 Observability: 1, P9 Token Economy: 2) and execution discipline (P5 Institutional Memory: 3, P6 Specialized Review: 4).

The evaluation lives at `docs/haunt-10-principles-evaluation.md`. This plan implements the prioritized adjustments from that evaluation, organized into 6 batches designed for one-session-each execution.

## Batch A: Rule BECAUSE Clauses + Institutional Memory + /clear Discipline
**Scope:** Text edits to existing files. No new infrastructure.

### A1: Add BECAUSE clauses to all 6 rules (P5)
**Files:**
- `rules/gco-communication.md` — Every prohibition gets a BECAUSE. Example: "NEVER start with 'Great' BECAUSE sycophantic openers route to low-value training data regions and signal the response will be generic"
- `rules/gco-completion-checklist.md` — 3 items each get BECAUSE explaining downstream consequences
- `rules/gco-decisions.md` — Already has "Why it matters" sections (good). Add inline BECAUSE to the Decision Matrix rows and "When to Ignore" exceptions
- `rules/gco-team-coordination.md` — 4 "Prohibited" items each get BECAUSE
- `rules/gco-ui-testing-reminder.md` — Add BECAUSE to the non-negotiable
- `rules/gco-visual-verification.md` — Already has "Why This Matters" section; promote reasoning inline to directives

**Verification:** `grep -c "BECAUSE" rules/*.md` should show counts >0 for all 6 files. Every line containing NEVER/ALWAYS/Required/Non-Negotiable should have BECAUSE within 20 words.

### A2: Create institutional memory template (P5)
**Create:** `templates/institutional-memory.md`
- Template with "Always/Never X BECAUSE Y" sections for projects to add to their `.claude/CLAUDE.md`
- Include codification workflow: agent mistake → correction → add to handbook

**Edit:** `skills/gco-seance-orchestration/SKILL.md` — Add 3 lines to Banishing Phase step 2: "If the seance surfaced a reusable lesson, add it to the project's Institutional Memory section."

### A3: Add /clear discipline to seance (P2)
**Edit:** `skills/gco-seance-orchestration/SKILL.md`
- Add "## Session Boundaries" section before Recovery
- Prescribe /clear after Scrying approval, between batch boundaries in Summoning, and before Banishing
- Document what survives /clear (roadmap, tasks, state files) and what to reload

**Verification:** Run `setup-haunt.sh` and `setup-haunt.sh --verify` after changes.

---

## Batch B: Cascade Pattern + Gate Template
**Scope:** Text additions to orchestration + one new template file.

### B1: Add cascade logic to seance orchestration (P9)
**Edit:** `skills/gco-seance-orchestration/SKILL.md`
- Add "## Task Size Cascade" section after Delegation Gate
- Size table: XS (solo, lead does it) / S (single Dev) / M (Dev + Code Reviewer) / L (Full team)
- Size detection heuristic based on idea keywords
- BECAUSE clause explaining token cost of coordination overhead

**Edit:** `commands/seance.md`
- Add `--solo` to Usage section: `/seance --solo "idea"` — Solo mode, skip team creation

### B2: Create structured gate output template (P8)
**Create:** `templates/human-gate-output.md`
- Summary, Files Changed table, Risks checklist (security/breaking/data loss), Review Evidence, Confidence level, Decision options (APPROVE/REJECT/DEFER)

**Verification:** The seance orchestration should reference the new cascade section. `/seance --solo` should appear in the command help.

---

## Batch C: Skill Architecture Standard + Restructure 3 Skills
**Scope:** New reference doc + restructure 3 existing skills for attention-optimized layout.

### C1: Define skill architecture standard (P10)
**Create:** `docs/SKILL-ARCHITECTURE.md`
- Dual-register description format (keyword-dense + natural language)
- Body layout order: Vocabulary Payload FIRST → Anti-Patterns → Instructions (middle) → Questions This Skill Answers LAST
- Research citations (U-shaped attention curve: Liu et al. 2024, Wu et al. 2025)
- Vocabulary payload format: table with Term / Definition / Use When
- Size constraints: SKILL.md body 150-300 lines max, references/ for overflow

### C2: Restructure gco-code-review (P10)
**Edit:** `skills/gco-code-review/SKILL.md` (currently 115 lines)
- Add vocabulary payload at top: ~15 terms (APPROVED, CHANGES_REQUESTED, BLOCKED, severity:HIGH, silent fallback, god function, catch-all exception, N+1 query, evidence-backed verdict, etc.)
- Move anti-patterns table and quick rejection triggers UP to position 2
- Keep workflow in middle
- Add "Questions This Skill Answers" at END
- Update frontmatter description to dual-register

### C3: Restructure gco-code-patterns (P10)
**Edit:** `skills/gco-code-patterns/SKILL.md` (currently 61 lines)
- Add vocabulary payload: ~15 terms (silent fallback, god function, magic number, guard clause, early return, fail fast, idempotent, etc.)
- Anti-patterns already first (keep)
- Add "Questions This Skill Answers" at END
- Update frontmatter to dual-register

### C4: Restructure gco-secure-coding (P10)
**Edit:** `skills/gco-secure-coding/SKILL.md` (currently 898 lines — way over 300 target)
- Extract detailed code examples (lines ~36-893) to `references/security-patterns.md`
- SKILL.md body becomes: vocabulary payload (20 terms: allowlist, parameterized query, path traversal, prompt injection, CORS, CSP, XSS, SQL injection, OWASP Top 10, STRIDE, etc.) → Quick Security Checklist (moved up from line 827) → terse workflow pointing to references/ → Questions This Skill Answers at END
- **Create:** `skills/gco-secure-coding/references/security-patterns.md`

**Verification:** `wc -l skills/gco-secure-coding/SKILL.md` should be <300. All 3 skills should have vocabulary payload as first body section.

---

## Batch D: Specialist Reviewers
**Scope:** New agent files + restructure existing reviewer.

### D1: Create security reviewer agent (P6)
**Create:** `agents/gco-security-reviewer.md`
- Identity <50 tokens: "I review code exclusively for security vulnerabilities using OWASP Top 10, STRIDE threat modeling, and agent security patterns."
- Vocabulary: 20 security-specific terms (hardcoded secrets, SQL injection, XSS, CSRF, path traversal, privilege escalation, input validation boundary, auth bypass, IDOR, secrets rotation, rate limiting, CSP, CORS, allowlist validation, parameterized query, prompt injection, output escaping, defense-in-depth, zero trust, CWE classification)
- Tools: Glob, Grep, Read, Bash (read-only), TaskUpdate, TaskList, SendMessage
- Skills: gco-secure-coding, gco-code-patterns, gco-team-protocol
- Evidence requirement: every finding must include file:line + vulnerability class + exploit scenario + fix

### D2: Create quality reviewer agent (P6)
**Create:** `agents/gco-quality-reviewer.md`
- Identity <50 tokens: "I review code for maintainability, anti-patterns, test coverage, and convention adherence. Every finding names the specific anti-pattern."
- Vocabulary: 15 quality terms (silent fallback, god function, magic number, catch-all exception, N+1 query, deep nesting, copy-paste code, test brittleness, cyclomatic complexity, guard clause, single responsibility, dependency injection, test isolation, coverage gap, dead code)
- Tools: Glob, Grep, Read, Bash (read-only), TaskUpdate, TaskList, SendMessage
- Skills: gco-code-review, gco-code-patterns, gco-testing-mindset, gco-team-protocol

### D3: Restructure code reviewer as router (P6)
**Edit:** `agents/gco-code-reviewer.md`
- Identity becomes: "I am the review router. For S-sized work, I do a single quality+security pass. For M+ work, I delegate to specialist reviewers."
- Add routing logic: security-relevant code → spawn gco-security-reviewer, pattern/test-heavy code → spawn gco-quality-reviewer, M+ work → spawn both
- Add evidence-backed clearance requirement: "Every APPROVED verdict must cite specific evidence (files checked, patterns verified, tests confirmed). No bare LGTM."
- Add `gco-secure-coding` to skills list

**Edit:** `skills/gco-seance-orchestration/SKILL.md`
- Update Summoning phase teammates table: "Code Reviewer (routes to specialists for M+ work)"

**Edit:** `scripts/setup-haunt.sh` — ensure new agents are deployed
**Edit:** `manifest.yaml` — add 2 new agents

**Verification:** `ls ~/.claude/agents/gco-*-reviewer.md` should show 3 files (code-reviewer, security-reviewer, quality-reviewer). `setup-haunt.sh --verify` should count 6 agents.

---

## Batch E: Observability Logging + Approval Metrics
**Scope:** New hook + metrics tracking in reviewer workflow.

### E1: Create observability logging hook (P7)
**Create:** `hooks/observability-logger.sh`
- PostToolUse hook, matches all tools (`.*`)
- Reads JSON from stdin, extracts tool name, file path, cwd
- Appends JSONL to `.haunt/logs/tool-usage.jsonl`
- Format: `{"timestamp":"...","tool":"Edit","file_path":"...","cwd":"..."}`
- Creates `.haunt/logs/` if absent
- Always exits 0 (non-blocking)
- Follows existing hook patterns: `set -euo pipefail`, `HAUNT_HOOKS_DISABLED` check, jq parsing

**Edit:** `templates/settings.hooks.json` — add PostToolUse entry for observability-logger
**Edit:** `hooks/session-start/initialize-session.sh` — add `.haunt/logs/` to directory creation

### E2: Add approval metrics to code reviewer (P7)
**Edit:** `agents/gco-code-reviewer.md`
- Add step 7 to workflow: "Log verdict to `.haunt/logs/review-verdicts.jsonl`" with structured JSON (timestamp, req, verdict, findings_count, severity breakdown, files_reviewed, evidence_quality)

**Create:** `scripts/review-metrics.sh`
- Reads `.haunt/logs/review-verdicts.jsonl`
- Reports: total reviews, approval rate, average findings, rubber-stamp detection (>85% approval = warning)

**Verification:** Run a seance on a test task, then check `.haunt/logs/tool-usage.jsonl` exists with entries. Run `bash scripts/review-metrics.sh` on sample data.

---

## Batch F: Freshness Checking + Task Profiles + Pre-Merge Gate
**Scope:** Documentation freshness, context profiles, human gate.

### F1: Add freshness checking (P3)
**Edit:** All 17 skill SKILL.md files — add `last-verified: 2026-04-03` to YAML frontmatter
**Create:** `scripts/haunt-doc-freshness.sh`
- Scans all skills for `last-verified` dates
- Flags skills >90 days stale
- Reports MISSING (no date) and STALE (too old)

### F2: Document task-type profiles (P2/P9)
**Create:** `docs/TASK-PROFILES.md`
- Minimal tool/skill sets per session type: Planning, Implementation, Review, Research
- Token budget estimates per profile
- Reference from seance orchestration skill

### F3: Add pre-merge human gate for M-sized work (P8)
**Edit:** `skills/gco-seance-orchestration/SKILL.md`
- Add "## Pre-Merge Human Gate" section between Summoning and Banishing
- Triggers on M+ work, auth/payments/production code, or CHANGES_REQUESTED verdicts
- Uses gate template from `~/.claude/templates/human-gate-output.md`
- Skip conditions: XS/S work, clean re-review

**Verification:** `bash scripts/haunt-doc-freshness.sh` should show all skills as current. `grep "last-verified" skills/*/SKILL.md | wc -l` should equal 17.

---

## Expected Score Impact

| Principle | Before | After | Key Change |
|-----------|--------|-------|------------|
| P1 Hardening | 7 | 7 | (no changes this round) |
| P2 Context Hygiene | 4 | 6 | /clear discipline, task profiles |
| P3 Living Documentation | 5 | 7 | Freshness checking, last-verified dates |
| P4 Disposable Blueprint | 8 | 8 | (already strong) |
| P5 Institutional Memory | 3 | 7 | BECAUSE clauses, codification workflow, template |
| P6 Specialized Review | 4 | 7 | Security + quality specialists, vocabulary routing |
| P7 Observability | 1 | 5 | Logging hook, approval metrics |
| P8 Strategic Human Gate | 5 | 7 | Gate template, pre-merge gate for M+ |
| P9 Token Economy | 2 | 5 | Cascade pattern, solo mode, task profiles |
| P10 Toolkit | 6 | 8 | Skill architecture standard, 3 restructured exemplars |

**Projected total: 67/100** (up from 45)

## File Summary

### Files to create (11)
- `templates/institutional-memory.md`
- `templates/human-gate-output.md`
- `docs/SKILL-ARCHITECTURE.md`
- `docs/TASK-PROFILES.md`
- `skills/gco-secure-coding/references/security-patterns.md`
- `agents/gco-security-reviewer.md`
- `agents/gco-quality-reviewer.md`
- `hooks/observability-logger.sh`
- `scripts/review-metrics.sh`
- `scripts/haunt-doc-freshness.sh`

### Files to edit (most-touched first)
- `skills/gco-seance-orchestration/SKILL.md` — Batches A, B, D, F (cascade, /clear, gate, profiles ref)
- `agents/gco-code-reviewer.md` — Batches D, E (router + metrics)
- `skills/gco-secure-coding/SKILL.md` — Batch C (898→<300 lines)
- `skills/gco-code-review/SKILL.md` — Batch C (restructure)
- `skills/gco-code-patterns/SKILL.md` — Batch C (restructure)
- `rules/gco-communication.md` — Batch A (BECAUSE clauses)
- `rules/gco-completion-checklist.md` — Batch A
- `rules/gco-decisions.md` — Batch A
- `rules/gco-team-coordination.md` — Batch A
- `rules/gco-ui-testing-reminder.md` — Batch A
- `rules/gco-visual-verification.md` — Batch A
- `commands/seance.md` — Batch B (--solo)
- `templates/settings.hooks.json` — Batch E (hook registration)
- `hooks/session-start/initialize-session.sh` — Batch E (logs dir)
- `scripts/setup-haunt.sh` — Batch D (new agents)
- `manifest.yaml` — Batch D (new agents)
- All 17 skill SKILL.md files — Batch F (last-verified frontmatter)
