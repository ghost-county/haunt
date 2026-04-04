---
last-verified: 2026-04-03
version: "1.0"
name: gco-requirements-development
description: Transform ideas into clear, actionable requirements. Use when user describes a feature, enhancement, or fix that needs structured definition.
---

# Requirements Development

Transform ideas into clear, testable requirements.

## Step 1: Understanding Checkpoint

Before writing requirements, confirm with user:

```
**What I heard:** [1-2 sentence summary]
**Scope:** [bullets]
**Assumptions:** [bullets]

Does this match your intent?
```

Wait for confirmation.

## Step 2: Write Requirements

For each requirement:

```markdown
### [Action-oriented title]

**Priority:** MUST | SHOULD | MAY
**Description:** [Specific, testable behavior]
**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]
**Dependencies:** [What this depends on or blocks]
**Size:** XS | S | M (if larger, break down)
```

## Step 3: Map Dependencies

Identify what must happen first:

```
Requirement A (Foundation)
    ├──> Requirement B
    └──> Requirement C
              └──> Requirement D
```

## Sizing Guide

| Size | Duration | Characteristics |
|------|----------|-----------------|
| XS | <1 hr | Single file, clear scope |
| S | 1-2 hrs | 2-4 files, straightforward |
| M | 2-4 hrs | 4-8 files, some complexity |
| Too big | >4 hrs | **Must be broken down** |

## Quality Checklist

- [ ] Understanding confirmed with user
- [ ] Requirements are atomic and testable
- [ ] Acceptance criteria are specific (not vague)
- [ ] Dependencies mapped
- [ ] Size estimated
