---
paths:
  - .haunt/plans/roadmap.md
  - .haunt/plans/*.md
---

# Roadmap Format

This rule applies when editing roadmap and planning files.

## Requirement Format

Every requirement MUST follow this structure:

```
### 🟡 REQ-XXX: [Clear, action-oriented title]

**Type:** Enhancement | Bug Fix | Documentation | Research
**Reported:** YYYY-MM-DD
**Source:** [Where this requirement came from]

**Description:**
[Clear description of what needs to be done]

**Tasks:**
- [ ] Specific task 1
- [ ] Specific task 2
- [ ] Specific task 3

**Files:**
- `path/to/file.ext` (create | modify)

**Effort:** XS | S | M | SPLIT
**Agent:** [Agent type]
**Completion:** [Specific, testable criteria]
**Blocked by:** [REQ-XXX or "None"]
```

## Status Icons

| Icon | Meaning | When to Use |
|------|---------|-------------|
| ⚪ | Not Started | Work not begun |
| 🟡 | In Progress | Agent actively working |
| 🟢 | Complete | All criteria met |
| 🔴 | Blocked | Dependency unmet |

**Update status when:**
- Starting work: ⚪ → 🟡
- Hit blocker: 🟡 → 🔴
- Finish work: 🟡 → 🟢
- Unblock: 🔴 → 🟡

## Sizing Rules

Work items MUST be sized to complete in one uninterrupted session:

| Size | Time | Files | Lines Changed | When to Use |
|------|------|-------|---------------|-------------|
| **XS** | 30min-1hr | 1-2 files | <50 lines | Quick fixes, config changes, typo corrections |
| **S** | 1-2 hours | 2-4 files | 50-150 lines | Single component features, isolated bug fixes |
| **M** | 2-4 hours | 4-8 files | 150-300 lines | Multi-component features, moderate refactoring |
| **SPLIT** | >4 hours | >8 files | >300 lines | MUST decompose immediately into smaller requirements |

### The One Sitting Rule

**Every requirement MUST be completable in one uninterrupted work session.**

Why this matters:
- Reduces context switching and cognitive load
- Ensures testable, atomic commits
- Prevents partial implementations lingering across sessions
- Makes progress tracking accurate and visible
- Minimizes coordination overhead between sessions

**If you cannot complete a requirement in one sitting:**
1. Stop work immediately
2. Mark requirement as SPLIT in roadmap
3. Decompose into 2-4 smaller requirements
4. Size each piece as XS, S, or M
5. Create dependencies using "Blocked by:" field
6. Restart with first decomposed requirement

### File Count Constraints

File count limits prevent scope creep:

- **XS (1-2 files):** Single file + test file, or two tightly coupled files
- **S (2-4 files):** Component + test + related utility, or small feature module
- **M (4-8 files):** Multi-component feature with tests and integration
- **>8 files:** Automatic SPLIT - decompose before starting

**Counting rules:**
- Count only files you modify or create
- Don't count auto-generated files (migrations, builds)
- Test files DO count toward the limit
- Configuration changes (package.json, etc.) count if substantial

### Decomposition Examples

#### Example 1: Too Large → Properly Sized

**WRONG (SPLIT required):**
```
REQ-XXX: Add user authentication system
- Effort: M (actually 12+ hours)
- Files: 15+ files
- Tasks: Login, logout, registration, password reset, session management, OAuth
```

**RIGHT (Properly decomposed):**
```
REQ-XXX: Add login endpoint with JWT
- Effort: S (2 hours)
- Files: 4 files (auth.py, test_auth.py, middleware.py, test_middleware.py)
- Tasks: Create login route, generate JWT, add auth middleware, write tests
- Blocked by: None

REQ-YYY: Add registration endpoint with validation
- Effort: S (2 hours)
- Files: 3 files (register.py, test_register.py, validators.py)
- Tasks: Create registration route, validate input, hash password, write tests
- Blocked by: REQ-XXX

REQ-ZZZ: Add password reset flow
- Effort: M (3 hours)
- Files: 5 files (reset.py, test_reset.py, email_service.py, templates/reset.html, test_email.py)
- Tasks: Generate reset tokens, send email, verify token, update password, write tests
- Blocked by: REQ-XXX
```

#### Example 2: Right-Sizing Bug Fixes

**XS - Quick config fix:**
```
REQ-XXX: Fix CORS headers for API endpoints
- Effort: XS (30 min)
- Files: 1 file (config.py)
- Tasks: Update CORS middleware configuration, test with browser
```

**S - Logic bug requiring investigation:**
```
REQ-XXX: Fix authentication redirect loop
- Effort: S (1.5 hours)
- Files: 3 files (auth_middleware.py, test_auth_middleware.py, session.py)
- Tasks: Identify root cause, update middleware logic, add regression test
```

**If a requirement seems too large:**
1. Check file count - if >8 files, SPLIT immediately
2. Check time estimate - if >4 hours, SPLIT immediately
3. Check tasks list - if >6 tasks, likely needs splitting
4. Create dependencies using "Blocked by:" field
5. Organize into batch for coordination
6. Each piece should be independently testable and deployable

## Batch Organization

Group related requirements into phases:

```markdown
## Batch N: [Phase Name]

### 🟡 REQ-XXX: [First item]
...

### ⚪ REQ-XXX: [Second item]
...
```

**Batch rules:**
- Items in same batch CAN run in parallel (unless blocked)
- Items with "Blocked by:" dependencies go in later batches
- Each batch should have clear completion criteria
- Archive entire batch when all items complete

## Active Work Section Format

Every roadmap file MUST have an "Active Work" section at the top:

```markdown
## Current Focus: [Phase Name]

**Goal:** [One sentence goal]

**Active Work:**
- 🟡 REQ-XXX: [Title] - [Brief status]
- ⚪ REQ-XXX: [Title]

**Recently Completed:**
- 🟢 REQ-XXX: [Title]
```

**Rules for Active Work:**
- Keep only current batch items here (max 5-7 requirements)
- Update status in real-time as work progresses
- Move completed items to "Recently Completed" section
- Archive Recently Completed items after 2-3 sessions

## Required Fields

Every requirement MUST include:

| Field | Required | Format |
|-------|----------|--------|
| Status icon | YES | ⚪ 🟡 🟢 🔴 |
| REQ-XXX number | YES | Sequential numbering |
| Title | YES | Action-oriented (e.g., "Create X", "Fix Y") |
| Type | YES | Enhancement, Bug Fix, Documentation, Research |
| Reported | YES | YYYY-MM-DD |
| Source | YES | Where requirement originated |
| Description | YES | Clear explanation of what needs to be done |
| Tasks | YES | Specific, actionable checklist items |
| Files | YES | Exact paths with (create/modify) annotation |
| Effort | YES | XS, S, M, or SPLIT |
| Agent | YES | Agent type who will implement |
| Completion | YES | Testable criteria for marking complete |
| Blocked by | YES | REQ-XXX or "None" |

**Optional fields for completed requirements:**
- **Completed:** YYYY-MM-DD
- **Implementation Notes:** Brief summary of how it was done

## Archiving Rules

When requirements are completed:

1. Change status to 🟢
2. Add **Completed:** date
3. Move to "Recently Completed" section
4. After 2-3 sessions, archive to `.haunt/completed/roadmap-archive.md`

**Archive format:**
```markdown
### 🟢 REQ-XXX: [Title]
**Completed:** YYYY-MM-DD
**Summary:** [1-2 sentence implementation summary]
**Files Modified:** [List of changed files]
```

## File Size Limit

Roadmap files MUST stay under **500 lines** for readability:

**When exceeding limit:**
1. Archive ALL completed items immediately to `.haunt/completed/roadmap-archive.md`
2. Move "Recently Completed" items to archive
3. Consider splitting into multiple roadmap files by feature area

**Session startup:** Check file size before starting work. If >500 lines, archive first.
