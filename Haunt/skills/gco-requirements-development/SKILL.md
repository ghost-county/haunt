---
name: gco-requirements-development
description: Transform ideas, brain dumps, and rough concepts into formal, testable requirements documents. Use when starting new features, processing user requests, or formalizing project scope. Triggers on "new feature", "I want to build", "add capability", "requirements for", or when the Project Manager begins Phase 1 of the idea-to-roadmap workflow.
---

# Requirements Development

Transform rough ideas into formal, testable requirements using the 14-dimension rubric.

## When to Use

- User provides a new feature idea or request
- Processing brain dumps, design docs, or rough concepts
- Formalizing scope before development begins
- Phase 1 of the idea-to-roadmap workflow

## Output Location

`.haunt/plans/requirements-document.md`

## Process

### Step 1: Understanding Checkpoint (REQUIRED)

Before writing any requirements, explain back to the user:

```markdown
## Understanding Confirmation

**What I heard:** [1-2 sentence summary of the request]

**Scope I'm interpreting:**
- [Bullet point 1]
- [Bullet point 2]
- [Bullet point 3]

**Assumptions I'm making:**
- [Any assumptions about technology, users, or constraints]

Before I develop formal requirements, would you like to:
- **[A] Review each document** as I create it (requirements → analysis → roadmap)
- **[B] Run through** all phases and present the final roadmap additions

Which would you prefer?
```

Wait for user confirmation before proceeding.

### Step 2: Apply the 14-Dimension Rubric

Review and document each dimension. Not all will apply to every feature.

| # | Dimension | Key Questions |
|---|-----------|---------------|
| 1 | **Introduction** | Purpose? Scope? Target audience? |
| 2 | **Goals & Objectives** | Business goals? User goals? Success metrics? |
| 3 | **User Stories** | Who? What? Why? (INVEST criteria) |
| 4 | **Functional Requirements** | What MUST the system do? |
| 5 | **Non-Functional Requirements** | Performance? Security? Usability? Reliability? |
| 6 | **Technical Requirements** | Platform? Stack? Integrations? |
| 7 | **Design Considerations** | UI/UX requirements? Accessibility? |
| 8 | **Testing & QA** | Test strategy? Acceptance criteria? |
| 9 | **Deployment & Release** | Deploy process? Release criteria? |
| 10 | **Maintenance & Support** | Support procedures? SLAs? |
| 11 | **Future Considerations** | Out-of-scope items for later? |
| 12 | **Training Requirements** | User training? Admin training? |
| 13 | **Stakeholder Responsibilities** | Who approves? Who owns? |
| 14 | **Change Management** | How are changes handled? |

### Step 3: Write Formal Requirements

Use this format for each requirement:

```markdown
### REQ-XXX: [Clear, action-oriented title]

**Priority:** MUST | SHOULD | MAY | COULD (RFC 2119)

**Description:**
The system SHALL [specific, testable behavior].

**Acceptance Criteria:**
- [ ] [Specific condition 1]
- [ ] [Specific condition 2]
- [ ] [Edge case handling]

**Dependencies:**
- Depends on: [REQ-XXX or "None"]
- Blocks: [REQ-XXX or "None"]

**Complexity:** S | M | L | XL

**Notes:** [Any clarifications or constraints]
```

### Step 4: Map Dependencies

Create a dependency matrix showing:
- Which requirements must complete before others
- Which can run in parallel
- Critical path identification

```markdown
## Dependency Map

REQ-001 (Foundation)
    ├──► REQ-002 (depends on 001)
    └──► REQ-003 (depends on 001)
              └──► REQ-004 (depends on 003)
```

### Step 5: Check Existing Roadmap

Before finalizing, read `.haunt/plans/roadmap.md` if it exists:
- Note existing REQ-XXX numbers (continue numbering)
- Identify potential dependencies on existing items
- Flag any conflicts with in-progress work

## Requirements Document Template

```markdown
# Requirements Document: [Feature Name]

**Created:** [Date]
**Author:** Project Manager Agent
**Status:** Draft | Under Review | Approved
**Version:** 1.0

---

## 1. Executive Summary

[2-3 sentence overview of what this feature accomplishes]

## 2. Goals & Objectives

### Business Goals
- [Goal 1]
- [Goal 2]

### User Goals
- [Goal 1]
- [Goal 2]

### Success Metrics
| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| [Metric] | [Target] | [How measured] |

## 3. User Stories

### US-001: [Story Title]
**As a** [user type]
**I want** [capability]
**So that** [benefit]

**Acceptance Criteria:**
- Given [context], when [action], then [outcome]

## 4. Functional Requirements

### REQ-001: [Title]
...

### REQ-002: [Title]
...

## 5. Non-Functional Requirements

### Performance
- [Requirement]

### Security
- [Requirement]

### Usability
- [Requirement]

## 6. Technical Constraints

- [Constraint 1]
- [Constraint 2]

## 7. Dependencies

### Internal Dependencies
| Requirement | Depends On | Blocks |
|-------------|------------|--------|
| REQ-001 | None | REQ-002, REQ-003 |

### External Dependencies
- [External system or team dependency]

## 8. Out of Scope

- [Explicitly excluded item 1]
- [Explicitly excluded item 2]

## 9. Open Questions

- [ ] [Question needing stakeholder input]
- [ ] [Technical decision pending]

## 10. Appendix

### Glossary
| Term | Definition |
|------|------------|
| [Term] | [Definition] |

### References
- [Link or document reference]
```

## RFC 2119 Keywords

Use these precisely:

| Keyword | Meaning |
|---------|---------|
| **MUST** / **SHALL** | Absolute requirement |
| **MUST NOT** / **SHALL NOT** | Absolute prohibition |
| **SHOULD** / **RECOMMENDED** | Strong recommendation, valid reasons to ignore |
| **SHOULD NOT** / **NOT RECOMMENDED** | Strong discouragement, valid reasons to do |
| **MAY** / **OPTIONAL** | Truly optional |

## Complexity Sizing

| Size | Duration | Characteristics |
|------|----------|-----------------|
| **S** | 1-4 hours | Single file, clear scope, minimal risk |
| **M** | 4-8 hours | 2-3 files, some complexity, manageable risk |
| **L** | 1-2 weeks | Multiple components, significant complexity |
| **XL** | 2+ weeks | **Must be broken down** - too large |

**Rule:** L and XL items must be flagged for breakdown in Phase 3.

## Quality Checklist

Before completing Phase 1:

- [ ] Understanding confirmed with user
- [ ] All applicable dimensions addressed
- [ ] Each requirement is atomic and testable
- [ ] RFC 2119 keywords used correctly
- [ ] Dependencies mapped
- [ ] Complexity estimated
- [ ] Existing roadmap checked for conflicts
- [ ] Open questions documented
- [ ] Out of scope explicitly stated

## Handoff to Phase 2

After creating `requirements-document.md`:

If user selected **review mode**:
> "I've created the requirements document at `.haunt/plans/requirements-document.md`.
> It contains [X] requirements covering [summary].
> Please review and let me know if you'd like any changes before I proceed to strategic analysis."

If user selected **run-through mode**:
> Proceed directly to Phase 2 (requirements-analysis skill)
