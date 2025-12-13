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

**Effort:** S | M
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

Work items MUST be sized appropriately to prevent long-running tasks:

| Size | Time | Files | Lines Changed | When to Use |
|------|------|-------|---------------|-------------|
| **S** | 1-4 hours | Single file or related files | <100 lines | Simple features, bug fixes, single-component changes |
| **M** | 4-8 hours | Multiple files | 100-500 lines | Multi-component features, moderate refactoring |
| **NEVER L or XL** | - | - | - | Break down into smaller requirements instead |

**If a requirement seems too large:**
1. Split into multiple smaller requirements
2. Create dependencies using "Blocked by:" field
3. Organize into batch for coordination
4. Each piece should be independently testable

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
| Effort | YES | S or M only |
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
