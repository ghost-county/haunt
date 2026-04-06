# Code Review Workflow

## Overview

The Haunt framework uses a **hybrid code review workflow** that balances efficiency with quality assurance based on requirement size:

- **XS/S Requirements** (1-2 hours, 1-4 files): Self-validation only, no automatic review
- **M/SPLIT Requirements** (2+ hours, 4+ files): Mandatory automatic code review

This approach optimizes for speed on low-risk changes while ensuring thorough review of complex features.

## Decision Tree

```
Dev agent completes work
  ↓
Check requirement Effort field in roadmap
  ↓
  ├─ XS or S?
  │    ↓
  │    Self-validation complete (Step 7 in completion checklist)?
  │    ↓
  │    YES → Mark requirement 🟢 Complete
  │    NO → Complete self-validation, then mark 🟢
  │
  └─ M or SPLIT?
       ↓
       Self-validation complete (Step 7 in completion checklist)?
       ↓
       YES → Spawn Code Reviewer with handoff context
       NO → Complete self-validation, then spawn Code Reviewer
       ↓
       Code Reviewer reviews and updates status:
       ├─ APPROVED → Mark 🟢 Complete
       ├─ CHANGES_REQUESTED → Keep 🟡, fix issues, re-submit
       └─ BLOCKED → Mark 🔴, resolve blockers
```

## Workflow for XS/S Requirements

**Effort:** XS (30min-1hr, 1-2 files) or S (1-2hr, 2-4 files)

**Process:**

1. **Complete work** following TDD and implementation patterns
2. **Run tests** to verify all passing
3. **Complete self-validation** (Step 7 in completion checklist):
   - Re-read requirement and verify all completion criteria met
   - Review code for obvious issues (debugging code, magic numbers, etc.)
   - Confirm tests actually test the feature
   - Run code manually if applicable
   - Check against anti-patterns from lessons-learned
4. **Mark requirement 🟢 Complete** in roadmap
5. **Commit changes** with proper commit message
6. **Notify PM** (if present) for coordination

**Manual review available:** User can always request manual review via `/summon code-reviewer` for any requirement size.

**Rationale:** XS/S changes have low complexity and risk. Self-validation provides sufficient quality assurance while enabling faster iteration.

## Workflow for M/SPLIT Requirements

**Effort:** M (2-4hr, 4-8 files) or SPLIT (>4hr, >8 files - should be decomposed)

**Process:**

### 1. Dev Agent Completes Work

- Implement feature following TDD workflow
- Run tests to verify all passing
- Commit changes with proper commit message
- **Complete self-validation** (Step 7 in completion checklist)
- **Do NOT mark requirement 🟢 yet** (keep status 🟡)

### 2. Dev Agent Spawns Code Reviewer

Use `/summon code-reviewer` with structured handoff context:

```
/summon code-reviewer "Review REQ-XXX: [Requirement Title]

**Context:**
- Effort: M/SPLIT (automatic review required)
- Files changed: [count] files ([list file paths])
- Tests: [passing count] passing

**Changes Summary:**
[2-3 sentence summary of what was implemented]

**Self-Validation:**
- [x] All tasks checked off
- [x] Tests passing ([test command output summary])
- [x] Security review complete (or N/A)
- [x] Code review for obvious issues
- [x] Anti-patterns checked

**Request:**
Please review and update REQ-XXX status based on verdict (APPROVED → 🟢, CHANGES_REQUESTED → 🟡, BLOCKED → 🔴)"
```

### 3. Code Reviewer Reviews Code

Code Reviewer applies structured review checklist:

- **Functionality:** Does code meet acceptance criteria?
- **Tests:** Are tests comprehensive and meaningful?
- **Security:** Any vulnerabilities or hardcoded secrets?
- **Anti-Patterns:** Silent fallbacks, god functions, magic numbers, catch-all exceptions?
- **Error Handling:** Proper validation and error handling?
- **Code Quality:** Readable, maintainable, follows project patterns?

### 4. Code Reviewer Updates Requirement Status

Based on review verdict, Code Reviewer updates roadmap status:

#### Verdict: APPROVED

**Actions:**
1. Update `.haunt/plans/roadmap.md`:
   - Change status from 🟡 to 🟢
   - Add completion note: `**Completion:** Code review APPROVED by Code Reviewer - all quality checks pass`
2. Inform Dev agent: "REQ-XXX approved and marked 🟢 Complete"

**Example:**
```markdown
### 🟢 REQ-XXX: Implement JWT authentication endpoints

**Completion:** Code review APPROVED by Code Reviewer - all quality checks pass
```

#### Verdict: CHANGES_REQUESTED

**Actions:**
1. Update `.haunt/plans/roadmap.md`:
   - Keep status 🟡 (In Progress)
   - Add review feedback section with specific issues
2. Inform Dev agent: "REQ-XXX requires changes, status remains 🟡. Address issues and re-submit."

**Example:**
```markdown
### 🟡 REQ-XXX: Implement JWT authentication endpoints

**Code Review Feedback:**
- [HIGH] auth.py:47 - Hardcoded API key, use environment variable
- [MEDIUM] utils.py:23 - Silent fallback on missing 'user_id', should raise ValueError
- [LOW] test_auth.py - Missing edge case test for expired tokens
```

#### Verdict: BLOCKED

**Actions:**
1. Update `.haunt/plans/roadmap.md`:
   - Change status from 🟡 to 🔴 (Blocked)
   - Update "Blocked by:" field with blocking issues
   - Add review notes explaining blockers
2. Inform Dev agent: "REQ-XXX blocked and marked 🔴. Resolve blocking issues before continuing."

**Example:**
```markdown
### 🔴 REQ-XXX: Implement JWT authentication endpoints

**Blocked by:** Tests failing (3 failures in token validation), merge conflicts in auth.py
**Code Review Notes:** Critical security issue - hardcoded secrets found in production code
```

### 5. Dev Agent Responds to Verdict

#### If APPROVED:
- Work complete, move to next assignment
- PM archives requirement when ready

#### If CHANGES_REQUESTED:
1. Review feedback in roadmap
2. Fix each issue listed
3. Re-run tests to verify fixes
4. Commit fixes with proper message
5. **Re-submit for review** using same handoff format
6. Code Reviewer re-reviews and updates status

#### If BLOCKED:
1. Review blocking issues in roadmap
2. Resolve blockers (fix failing tests, resolve merge conflicts, etc.)
3. Change status from 🔴 back to 🟡
4. Re-submit for review when ready

## Handoff Format Reference

### Dev to Code Reviewer (M/SPLIT Auto-Spawn)

```
/summon code-reviewer "Review REQ-XXX: [Requirement Title]

**Context:**
- Effort: M/SPLIT (automatic review required)
- Files changed: 5 files (Haunt/agents/gco-dev.md, Haunt/agents/gco-code-reviewer.md, etc.)
- Tests: All passing (infrastructure verification complete)

**Changes Summary:**
Implemented hybrid code review workflow where XS/S requirements use self-validation and M/SPLIT requirements auto-trigger Code Reviewer. Updated Dev agent to spawn Code Reviewer for M/SPLIT work. Updated Code Reviewer to accept auto-spawned reviews and update requirement status based on verdict.

**Self-Validation:**
- [x] All tasks checked off in REQ-XXX
- [x] Tests passing (bash scripts verified, framework integration tested)
- [x] Security review complete (N/A - no security-sensitive changes)
- [x] Code review for obvious issues (no debugging code, proper structure)
- [x] Anti-patterns checked (no silent fallbacks, proper error handling)

**Request:**
Please review and update REQ-XXX status based on verdict (APPROVED → 🟢, CHANGES_REQUESTED → 🟡, BLOCKED → 🔴)"
```

### Code Reviewer to Dev (Review Complete)

**APPROVED Example:**
```
APPROVED

Review findings:
✅ All quality checks pass
✅ Implementation matches requirement specification
✅ Tests are comprehensive and pass
✅ No security concerns
✅ Code follows project patterns
✅ No anti-patterns detected

REQ-XXX approved and marked 🟢 Complete in roadmap.
```

**CHANGES_REQUESTED Example:**
```
CHANGES_REQUESTED

Issues found:
[HIGH] Haunt/agents/gco-dev.md:47 - Missing error handling for Code Reviewer spawn failure
[MEDIUM] Haunt/rules/gco-completion-checklist.md:89 - Unclear guidance on re-submission after CHANGES_REQUESTED
[LOW] Haunt/docs/CODE-REVIEW-WORKFLOW.md - Missing example of iterative review cycle

Test coverage: All tests passing, but missing integration test for auto-spawn workflow

REQ-XXX status remains 🟡. Please address issues and re-submit for review.
```

**BLOCKED Example:**
```
BLOCKED

Critical issues:
[CRITICAL] Setup script missing deployment of new workflow documentation
[CRITICAL] Code Reviewer missing Write tool permission to update roadmap status
[HIGH] Dev agent handoff format missing requirement effort size check

These blockers prevent the feature from functioning. Cannot approve until resolved.

REQ-XXX marked 🔴 Blocked in roadmap. Resolve blocking issues before continuing.
```

## Rationale for Hybrid Approach

### Why Self-Validation for XS/S?

**Benefits:**
- **Faster iteration** - No review delay for simple changes
- **Lower coordination overhead** - No handoff/waiting required
- **Developer trust** - Empowers devs to make quick fixes without review bottleneck
- **Resource efficiency** - Code Reviewer time focused on high-risk changes

**Risk mitigation:**
- Mandatory self-validation checklist (Step 7 in completion checklist)
- Manual review always available if dev has uncertainty
- Pattern defeat tests catch anti-patterns in CI/CD

### Why Mandatory Review for M/SPLIT?

**Benefits:**
- **Catch defects early** - Second set of eyes on complex changes
- **Knowledge sharing** - Code Reviewer learns codebase, provides feedback
- **Quality gate** - Prevents anti-patterns and security issues from entering codebase
- **Documentation** - Review notes provide implementation context for future

**Justification:**
- M/SPLIT changes have higher complexity and risk
- More files touched = more potential for unintended side effects
- Longer implementation time = more room for mistakes
- Higher cost of defects (harder to debug, more users affected)

## Integration with Other Workflows

### TDD Workflow

Code review complements TDD:

1. **Red:** Write failing test
2. **Green:** Implement feature to pass test
3. **Refactor:** Clean up code while tests stay green
4. **Review:** (M/SPLIT only) Code Reviewer verifies quality

Self-validation and code review ensure refactoring didn't introduce defects.

### Commit Conventions

Dev commits changes BEFORE requesting code review:

- All code must be committed before spawning Code Reviewer
- Code Reviewer reviews committed code, not work-in-progress
- If CHANGES_REQUESTED, dev makes new commits with fixes
- Commit messages follow standard format (see gco-commit-conventions)

### Iterative Refinement Protocol

For M/SPLIT requirements, dev completes 3-pass refinement BEFORE requesting review:

1. **Pass 1:** Initial implementation (functional requirements)
2. **Pass 2:** Self-review & refinement (code quality)
3. **Pass 3:** Final enhancement (tests, security, anti-patterns)
4. **Then:** Request code review (automatic for M/SPLIT)

Code review is the FINAL quality gate, not a replacement for self-refinement.

## FAQ

### Q: Can I request code review for XS/S requirements?

**A:** Yes! Manual review is always available via `/summon code-reviewer`. The hybrid workflow only controls AUTOMATIC review, not manual requests.

### Q: What if Code Reviewer is unavailable?

**A:** For M/SPLIT requirements, work remains 🟡 until review completes. If urgent, user can override and mark 🟢 manually, but this should be rare.

### Q: How many review iterations are acceptable?

**A:** Aim for 1-2 iterations:
- **1 iteration:** APPROVED on first review (ideal - means dev self-validation was thorough)
- **2 iterations:** CHANGES_REQUESTED, fixes applied, APPROVED on second review
- **3+ iterations:** Suggests incomplete self-validation or unclear requirements - revisit requirement

### Q: Who marks requirement 🟢 for M/SPLIT?

**A:** Code Reviewer marks 🟢 when verdict is APPROVED. Dev never marks M/SPLIT requirements 🟢 directly - they spawn Code Reviewer and wait for verdict.

### Q: What if dev disagrees with Code Reviewer feedback?

**A:** Discuss with Code Reviewer or escalate to PM/user. Code Reviewer feedback should be objective (based on quality standards, not personal preference). If disagreement persists, user makes final call.

### Q: Can dev skip self-validation before requesting review?

**A:** No. Self-validation is REQUIRED before spawning Code Reviewer (for M/SPLIT) or marking 🟢 (for XS/S). Code Reviewer checks that self-validation was completed.

## See Also

- `Haunt/agents/gco-dev.md` - Dev agent with automatic review handoff logic
- `Haunt/agents/gco-code-reviewer.md` - Code Reviewer agent with auto-spawned review handling
- `Haunt/rules/gco-completion-checklist.md` - Complete checklist including self-validation and code review steps
- `Haunt/skills/gco-code-review/SKILL.md` - Detailed code review checklist and patterns
- `Haunt/skills/gco-code-patterns/SKILL.md` - Anti-patterns and error handling standards
