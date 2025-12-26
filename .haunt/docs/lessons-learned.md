# Lessons Learned - Ghost County Project

> Knowledge base capturing mistakes, anti-patterns, architecture decisions, and project-specific gotchas. PM maintains this file after batch completion. Dev/Research agents reference during session startup for complex features.

**Last Updated:** 2025-12-18

---

## Table of Contents

1. [Common Mistakes](#common-mistakes)
2. [Anti-Patterns](#anti-patterns)
3. [Architecture Decisions](#architecture-decisions)
4. [Project Gotchas](#project-gotchas)
5. [Best Practices](#best-practices)

---

## Common Mistakes

Errors we've made and solutions that prevent recurrence.

### Framework Changes: Always Update Source First

**Problem:** Agents create/modify files in `.claude/` or `~/.claude/` directly, thinking the change is complete. Next `setup-haunt.sh` run overwrites the local change because the source in `Haunt/` wasn't updated.

**Discovered:** REQ-233 (2025-12-18) - Coven→Haunt rename had to be done in 20+ files across both source and deployed locations

**Root Cause:** Framework uses deployment pattern - `Haunt/` is source of truth, `.claude/` and `~/.claude/` are deployment targets.

**Solution:**
1. ALWAYS edit source files in `Haunt/` first (agents, skills, rules, commands, scripts)
2. THEN run `setup-haunt.sh` OR manually copy to deployment targets
3. VERIFY change persists after setup script runs

**Prevention:** Added to `gco-framework-changes` rule and Dev agent character sheet.

---

### Roadmap File Size: Archive Before Exceeding 500 Lines

**Problem:** Roadmap files grow beyond 500 lines, becoming difficult to navigate and increasing token consumption during session startup.

**Discovered:** Multiple sessions where roadmap exceeded 1000 lines before archival

**Root Cause:** No automatic size limit enforcement, agents forget to archive completed work promptly.

**Solution:**
1. Check roadmap file size during session startup
2. If >500 lines, archive ALL 🟢 Complete items before starting new work
3. Use `/banish --all` for quick archival
4. For large projects (10+ requirements), use `/roadmap shard` to split into batches

**Prevention:** Added to `gco-file-conventions` rule and session startup checklist.

---

### Skill Duplication: Don't Create Both Rule and Skill for Same Content

**Problem:** Same content existed as both auto-loaded rule AND on-demand skill (gco-session-startup, gco-commit-conventions), creating 900-1200 token overhead per request.

**Discovered:** REQ-209 performance investigation (2025-12-16)

**Root Cause:** Unclear distinction between rule (invariant enforcement) vs skill (on-demand methodology).

**Solution:**
- **Rules:** Short, invariant enforcement (gco-assignment-lookup, gco-status-updates, gco-completion-checklist)
- **Skills:** Detailed methodology, context-specific guidance (gco-session-startup, gco-tdd-workflow, gco-playwright-tests)
- If content exceeds 200 lines, make it a skill (on-demand), not a rule (auto-loaded)

**Prevention:** See REQ-216, REQ-217 - removed duplicate rules, converted large rules to skills.

---

## Anti-Patterns

Bad patterns discovered via defeat tests or code review.

### Silent Fallbacks on Required Data

**Pattern:** Using `.get(key, default_value)` for required fields without validation.

**Why Bad:** Hides missing data, masks bugs, makes debugging harder. "0" or "unknown" is not a valid user ID or amount.

**Example (Python):**
```python
# Bad
amount = data.get("amount", 0)  # Hides missing amount

# Good
if "amount" not in data:
    raise ValidationError("amount is required")
amount = data["amount"]
```

**Prevention:** See `gco-code-patterns` skill - enforced by Code Reviewer agent.

---

### Magic Numbers Without Named Constants

**Pattern:** Using literal numbers (86400, 100, 30) in code without explanation.

**Why Bad:** Unclear intent, hard to maintain, easy to introduce bugs when changing values.

**Example:**
```python
# Bad
if elapsed > 86400:  # What does 86400 mean?

# Good
SECONDS_PER_DAY = 86400
if elapsed > SECONDS_PER_DAY:
```

**Prevention:** See `gco-code-patterns` skill - enforced during code review.

---

## Architecture Decisions

Key design choices and rationale.

### Roadmap Sharding: When to Split Monolithic Roadmap

**Decision:** Implement batch-specific roadmap sharding for projects with 10+ requirements (REQ-220, 2025-12-18)

**Rationale:**
- Monolithic roadmap with 50+ requirements = 3000-5000 tokens loaded every session
- Batch sharding reduces to 500-1000 tokens (60-80% reduction)
- Active batch loading means agents only load relevant context
- Backward compatible - works with both sharded and non-sharded roadmaps

**Implementation:**
- Create `.haunt/plans/batches/` directory
- Use `/roadmap shard` to split by batch headers
- Main `roadmap.md` contains overview + active batch only
- Other batches in separate files (`batch-N-[name].md`)

**When to Use:**
- 10+ requirements in roadmap
- Multiple distinct batches (features, bugs, research)
- Long-running projects spanning months

**When NOT to Use:**
- <10 requirements total
- Single focused batch
- Project nearing completion

**Related:** REQ-221 (session startup batch loading), REQ-222 (batch archival)

---

### Session Startup Optimization: Load Only What's Needed

**Decision:** Update session startup to load only active batch when roadmap is sharded (REQ-221, 2025-12-18)

**Rationale:**
- Loading entire roadmap wasteful when agent only needs one batch
- Sharding detection (check `.haunt/plans/batches/` directory) enables smart loading
- Backward compatible - fallback to full roadmap if not sharded

**Implementation:**
- Check if roadmap is sharded (directory exists, "Sharding Info" section in roadmap.md)
- If sharded, load `roadmap.md` (overview + active batch)
- If assignment in different batch, load specific batch file from `.haunt/plans/batches/`
- If not sharded, use existing behavior (full roadmap)

**Token Savings:**
- Sharded: 500-1000 tokens (active batch only)
- Monolithic: 3000-5000 tokens (entire roadmap)
- 60-80% reduction for large projects

**Related:** REQ-220 (roadmap sharding), REQ-222 (batch archival)

---

### Story Files for Multi-Session Features

**Decision:** Create story files for complex M-sized requirements spanning multiple sessions (REQ-223, REQ-224, 2025-12-18)

**Rationale:**
- Roadmap contains WHAT (tasks, completion criteria)
- Story files contain HOW (implementation approach, edge cases, architectural decisions)
- Reduces context loss between sessions for complex features
- Optional - only needed for M-sized work requiring detailed context

**Implementation:**
- PM creates story file: `.haunt/plans/stories/REQ-XXX-story.md`
- Dev agent checks for story file during session startup (after assignment identification)
- If exists, load for implementation context
- If missing, use roadmap completion criteria (normal for XS-S work)

**Story File Structure:**
- Context & Background (why this exists, system fit, user journey)
- Implementation Approach (technical strategy, components, data flow)
- Code Examples & References (similar patterns, key snippets, dependencies)
- Known Edge Cases (edge scenarios and error conditions)
- Testing Strategy (unit, integration, E2E test guidance)
- Session Notes (progress tracking from previous sessions)

**When to Use:**
- M-sized requirements spanning multiple sessions
- Complex features with architectural decisions
- Multi-component changes requiring coordination
- Features with known edge cases or gotchas
- Work requiring specific technical approaches

**Related:** REQ-223 (/story command), REQ-224 (Dev agent story file loading)

---

## Project Gotchas

Ghost County-specific quirks and conventions.

### Commands vs Skills: Naming and Placement

**Gotcha:** It's easy to confuse command files (`.claude/commands/`) with skill directories (`.claude/skills/`).

**Distinction:**
- **Commands** (`.claude/commands/*.md`): User-invocable shortcuts (e.g., `/seance`, `/summon`, `/banish`)
  - Single markdown file per command
  - Located in `Haunt/commands/` (source) and `.claude/commands/` (deployed)
  - Examples: `seance.md`, `summon.md`, `haunt.md`

- **Skills** (`.claude/skills/gco-*/`): Agent methodology/guidance (auto-triggered or on-demand)
  - Directory per skill with `SKILL.md` inside
  - Located in `Haunt/skills/gco-*/` (source) and `.claude/skills/gco-*/` (deployed)
  - Examples: `gco-seance/`, `gco-tdd-workflow/`, `gco-roadmap-planning/`

**Key Difference:** Users invoke commands directly (`/command-name`), agents invoke skills internally when needed.

---

### Roadmap Status Icons: Use Correct Format

**Gotcha:** Roadmap status icons MUST be in requirement header, not inline in tasks.

**Wrong:**
```markdown
### REQ-XXX: Feature Name
Status: In Progress
```

**Right:**
```markdown
### 🟡 REQ-XXX: Feature Name
```

**Icon Meanings:**
- ⚪ Not Started
- 🟡 In Progress
- 🟢 Complete
- 🔴 Blocked

**Why:** Roadmap parsing scripts search for `### [icon] REQ-` pattern. Inline status breaks automation.

---

### Test Commands by Agent Type

**Gotcha:** Different agent types use different test commands. Using wrong command wastes time.

**Commands:**
- Dev-Backend: `pytest tests/ -x -q`
- Dev-Frontend: `npm test` (or `npx playwright test` for E2E)
- Dev-Infrastructure: Verify state (no standard test command)
- Release-Manager: Full suite (`pytest tests/` or `npm test`)

**Session Startup:** Always run appropriate test command BEFORE starting new work.

---

### CLAUDE.md Active Work: PM Manages Exclusively

**Gotcha:** Dev/Research/Code Review agents should NOT modify CLAUDE.md Active Work section directly.

**Who Updates What:**
- **Worker Agents (Dev, Research, Code Review):** Update `.haunt/plans/roadmap.md` status directly (⚪→🟡→🟢)
- **Project Manager ONLY:** Updates CLAUDE.md Active Work section AND roadmap
  - Starting work: Add to Active Work, update roadmap to 🟡
  - Completing work: Remove from Active Work, archive to `.haunt/completed/`

**Rationale:** Prevents sync issues between CLAUDE.md and roadmap. PM maintains single source of truth.

**Related:** See `gco-status-updates` rule.

---

## Best Practices

Patterns that work well for this project.

### Session Startup Checklist: Never Skip Steps

**Practice:** Follow session startup protocol IN ORDER, every session, before ANY work.

**Protocol:**
1. Verify environment (`pwd && git status`)
2. Check recent changes (`git log --oneline -5`)
3. Verify tests pass (run appropriate test command for your agent type)
4. Find assignment (Direct → Active Work → Roadmap → Ask PM)

**Why It Works:**
- Catches broken tests before starting new work
- Ensures correct working directory and git state
- Identifies assignment from proper source (no assumptions)
- Reduces wasted work on wrong tasks or in broken environments

**Related:** See `gco-session-startup` rule and skill.

---

### TDD for All New Features: Red-Green-Refactor

**Practice:** Write failing test FIRST, implement to pass, then refactor.

**Workflow:**
1. **Red:** Write test describing expected behavior (it fails)
2. **Green:** Write minimal code to make test pass
3. **Refactor:** Improve code quality while keeping tests green

**Why It Works:**
- Tests document expected behavior before implementation bias
- Prevents over-engineering (only code needed to pass test)
- Ensures test actually tests the feature (not just exists)
- Catches regressions during refactoring

**Related:** See `gco-tdd-workflow` skill.

---

### Commit Early, Commit Often: One Feature Per Commit

**Practice:** Complete one feature/fix per session, commit with proper message, THEN start next feature.

**Commit Format:**
```
[REQ-XXX] Action: Brief description

What was done:
- Specific change 1
- Specific change 2
- Specific change 3

🤖 Generated with Claude Code
```

**Why It Works:**
- Each commit is atomic and revertable
- Git history is readable and traceable
- Requirement tracking is accurate
- Reduces WIP across multiple sessions

**Related:** See `gco-commit-conventions` skill.

---

### Ask User Questions for Ambiguous Requirements

**Practice:** When multiple valid approaches exist, ask user to choose (don't assume).

**When to Ask:**
- Framework/library choice (React vs Vue, Redux vs Zustand)
- Architecture decisions affecting >3 files
- Ambiguous requirements ("Add authentication" → which method?)
- Trade-off decisions (performance vs simplicity, cost vs convenience)

**Why It Works:**
- Prevents wasted implementation time on wrong approach
- Surfaces trade-offs early (user makes informed decision)
- Reduces back-and-forth during code review

**Related:** See `gco-interactive-decisions` rule and AskUserQuestion tool.

---

### Batch Work by Type: Group Related Requirements

**Practice:** Organize roadmap into batches by feature area or work type.

**Example Batches:**
- "Command Improvements" (tooling enhancements)
- "Performance Optimization" (token reduction, speed improvements)
- "Documentation Updates" (README, guides, diagrams)
- "Bug Fixes - Authentication" (related bugs)

**Why It Works:**
- Context switching reduced (similar work grouped)
- Dependencies easier to track (batch completion gates next batch)
- Progress tracking clearer (batch completion percentage)
- Archival simpler (archive whole batch when done)

**Related:** See roadmap sharding (REQ-220), batch status (REQ-231), batch archival (REQ-222).

---

## How to Use This Document

### For Project Managers
- **After batch completion:** Review work and add new lessons learned
- **During planning:** Reference architecture decisions when creating similar requirements
- **Weekly:** Review and consolidate similar lessons to reduce redundancy

### For Dev Agents
- **Session startup (M-sized work):** Skim relevant sections before implementation
- **When stuck:** Check "Common Mistakes" and "Project Gotchas" for known issues
- **Before code review:** Verify work against "Anti-Patterns" section

### For Research Agents
- **Before investigation:** Check "Architecture Decisions" for existing patterns/rationale
- **After findings:** Suggest additions to "Best Practices" if new pattern discovered

### For Code Reviewers
- **During review:** Cross-reference against "Anti-Patterns" section
- **When rejecting code:** Add discovered anti-pattern to this document (if not already listed)

---

## Contribution Guidelines

**Who Can Update:**
- **PM:** All sections (maintains document, consolidates lessons after batch completion)
- **Dev/Research/Code Review:** Suggest additions via PR or mention to PM

**Update Frequency:**
- After batch completion (PM review and consolidation)
- When significant anti-pattern discovered (Code Reviewer suggests, PM adds)
- Monthly review to remove obsolete lessons or consolidate duplicates

**Formatting:**
- Use H3 headers (`###`) for individual lessons
- Include "Discovered:" date and REQ-XXX reference
- Provide code examples for anti-patterns and best practices
- Keep "Why It Works" / "Why Bad" explanations concise (2-3 sentences)

### Iterative Code Refinement: Multiple Passes Before Completion

**Practice:** All code goes through 2-3 refinement passes before marking complete (XS: 1-pass, S: 2-pass, M: 3-pass).

**Workflow:**
1. **Pass 1 (Initial):** Make it work - implement functional requirements and happy path
2. **Pass 2 (Refinement):** Make it right - add error handling, validation, proper naming
3. **Pass 3 (Enhancement):** Make it production-ready - comprehensive tests, security, anti-patterns check
4. **Pass 4 (Optional, M/SPLIT only):** Make it robust - observability, retry logic, circuit breakers

**Why It Works:**
- **Catches AI code mistakes systematically:** First AI output typically has missing error handling, magic numbers, poor naming, incomplete tests
- **Each pass focuses on specific quality dimension:** Functional → Quality → Production-ready → Robust
- **Reduces Code Reviewer rework:** Catching own mistakes before review saves 30-50% review cycles
- **Builds quality incrementally:** Don't try to write perfect code first time - refine iteratively

**Quality Improvements by Pass:**

**Pass 1 → Pass 2 improvements:**
- Add error handling (try/except blocks around I/O)
- Replace magic numbers with named constants
- Add input validation (no silent fallbacks)
- Improve naming (descriptive variables, verb function names)
- Extract long functions (>50 lines) into helpers

**Pass 2 → Pass 3 improvements:**
- Add edge case tests (empty input, boundary values, null)
- Add error case tests (network failures, invalid input)
- Security review (sanitize input, check auth, no secrets)
- Anti-pattern check (lessons-learned.md reference)
- Add logging for errors

**Pass 3 → Pass 4 improvements (optional, M/SPLIT only):**
- Add correlation IDs for request tracing
- Add retry logic with exponential backoff
- Add circuit breakers for external dependencies
- Performance optimization and load testing
- Graceful degradation under failure

**Example Improvement (3-Pass):**

**Pass 1 (Initial):**
```python
def process_payment(amount):
    return api.charge(amount)
```
**Issues:** No error handling, no validation, no logging.

**Pass 2 (Refined):**
```python
def process_payment(amount):
    if not amount or amount <= 0:
        raise ValueError("amount must be positive")
    try:
        return api.charge(amount)
    except NetworkError as e:
        logger.error(f"Payment failed: {e}")
        raise
```
**Improvements:** Validation, error handling, logging added.

**Pass 3 (Enhanced):**
```python
MIN_AMOUNT = 0.01
MAX_AMOUNT = 999999.99

def process_payment(amount, retries=3):
    # Validation
    if not amount or not isinstance(amount, (int, float)):
        raise TypeError("amount must be a number")
    if amount < MIN_AMOUNT or amount > MAX_AMOUNT:
        raise ValueError(f"amount must be {MIN_AMOUNT}-{MAX_AMOUNT}")

    # Retry logic with exponential backoff
    for attempt in range(retries):
        try:
            logger.info(f"Processing payment: amount={amount}, attempt={attempt+1}")
            result = api.charge(amount)
            logger.info(f"Payment successful: transaction_id={result.id}")
            return result
        except NetworkError as e:
            if attempt == retries - 1:
                logger.error(f"Payment failed after {retries} retries: {e}")
                raise ServiceUnavailable("Payment service unavailable")
            wait_time = 2 ** attempt
            logger.warn(f"Attempt {attempt+1} failed, retrying in {wait_time}s: {e}")
            time.sleep(wait_time)
```
**Improvements:** Named constants, comprehensive validation, retry logic, detailed logging, docstring.

**Discovered:** REQ-258 (2025-12-25) - Research from OpenAI best practices shows iterative refinement significantly improves AI code quality.

**Prevention:** Added to Dev agent character sheet, completion checklist, and gco-code-quality skill.

**Related:** See Dev agent "Iterative Code Refinement Protocol" section and `gco-code-quality` skill for detailed checklists and patterns.

---

