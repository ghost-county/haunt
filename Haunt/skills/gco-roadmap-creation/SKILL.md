---
name: gco-roadmap-creation
description: Transform analyzed requirements into actionable roadmap items with atomic sizing, dependency batching, and agent assignments. Use after requirements-analysis to populate or update the project roadmap. Triggers on "create roadmap", "add to roadmap", "plan implementation", or when the Project Manager begins Phase 3 of the idea-to-roadmap workflow.
---

# Roadmap Creation

Transform analyzed requirements into atomic, actionable roadmap items.

## When to Use

- After Phase 2 (requirements-analysis) completes
- Adding new work to an existing roadmap
- Re-planning or re-batching existing requirements
- Phase 3 of the idea-to-roadmap workflow

## Inputs

- `.haunt/plans/requirements-document.md` (from Phase 1)
- `.haunt/plans/requirements-analysis.md` (from Phase 2)
- `.haunt/plans/roadmap.md` (existing, if any)

## Output Location

`.haunt/plans/roadmap.md` (append or create)

## Process

### Step 1: Read Existing Roadmap

If `.haunt/plans/roadmap.md` exists:

1. **Note highest REQ number** - Continue numbering from there
2. **Identify in-progress work** - Don't conflict with active items
3. **Map existing dependencies** - New items may depend on existing ones
4. **Check for duplicates** - Don't duplicate existing requirements

```markdown
## Existing Roadmap State

- Last REQ number: REQ-XXX
- In-progress items: [list]
- Completed items: [count]
- Potential dependencies for new work: [list]
```

### Step 2: Break Down L/XL Items

Any requirement sized L or XL from Phase 1 MUST be broken down:

**Rule:** Every roadmap item must be S (1-4 hours) or M (4-8 hours).

**Breakdown Strategy:**

| Original Size | Break Into |
|---------------|------------|
| L (1-2 weeks) | 3-5 M items or 5-8 S items |
| XL (2+ weeks) | Multiple L items first, then break those down |

**Breakdown Patterns:**

1. **By Layer:** Database → Backend → API → Frontend
2. **By Feature Slice:** Vertical slices that deliver value
3. **By Component:** Separate concerns (auth, validation, UI)
4. **By Risk:** High-risk items first to fail fast

Example breakdown:
```markdown
## Original (L)
REQ-010: User Authentication System

## Broken Down (S/M)
REQ-010a: Database schema for users table (S)
REQ-010b: User model and repository (S)
REQ-010c: Password hashing utility (S)
REQ-010d: Registration endpoint (M)
REQ-010e: Login endpoint with JWT (M)
REQ-010f: Auth middleware (S)
REQ-010g: Login UI component (M)
```

### Step 3: Map All Dependencies

Create comprehensive dependency mapping:

1. **Internal dependencies** - Between new requirements
2. **External dependencies** - To existing roadmap items
3. **Implicit dependencies** - Database before API, API before UI

```markdown
## Dependency Matrix

| New REQ | Depends On | Blocks |
|---------|------------|--------|
| REQ-050 | None | REQ-051, REQ-052 |
| REQ-051 | REQ-050 | REQ-053 |
| REQ-052 | REQ-050, REQ-015 (existing) | REQ-054 |
```

### Step 4: Organize into Batches

**Batch Rules:**

| Same Batch (Parallel OK) | Separate Batches (Sequential) |
|--------------------------|-------------------------------|
| No dependencies between items | Has `Blocked by` relationship |
| Different files/components | Same file modifications |
| Different agents | Must verify before next |
| Independent outcomes | Sequential logic flow |

**Batch Naming Convention:**
- Use descriptive names: "Foundation", "Core Backend", "API Layer", "Frontend"
- Number sequentially if adding to existing: "Batch 5: Auth Backend"

### Step 5: Assign Agents

Match requirements to agents by expertise:

| Agent | Expertise | Assign When |
|-------|-----------|-------------|
| **Dev-Backend** | APIs, services, business logic | `*/api/*`, `*/services/*`, database work |
| **Dev-Frontend** | UI, components, client state | `*/components/*`, `*/pages/*`, styles |
| **Dev-Infrastructure** | IaC, CI/CD, deployment | `*terraform/*`, `.github/*`, Docker |
| **Research** | Investigation, analysis | Spikes, unknowns, evaluations |

**Assignment Considerations:**
- Balance workload across agents
- Group related items for same agent when possible
- Consider agent availability (check in-progress items)

### Step 6: Write Completion Criteria

Every requirement needs testable completion criteria:

**Bad (vague):**
- "Works correctly"
- "User can login"
- "Tests pass"

**Good (specific):**
- "POST /api/register returns 201 with user object (no password)"
- "Login form submits to /api/login, stores JWT in localStorage, redirects to /dashboard"
- "`pytest tests/test_auth.py -v` passes with 100% auth module coverage"

### Step 7: Format and Append

Use the standard roadmap format:

```markdown
---

## Batch X: [Name]

⚪ REQ-XXX: [Clear, action-oriented title]
   Tasks:
   - [ ] Specific task 1
   - [ ] Specific task 2
   - [ ] Specific task 3
   Files: path/to/file1.py, path/to/file2.py
   Effort: S
   Agent: Dev-Backend
   Completion: [Specific, testable criteria]
   Blocked by: None

⚪ REQ-XXX: [Title]
   Tasks:
   - [ ] Task 1
   - [ ] Task 2
   Files: path/to/files
   Effort: M
   Agent: Dev-Frontend
   Completion: [Criteria]
   Blocked by: REQ-XXX
```

## Roadmap Item Template

```markdown
⚪ REQ-XXX: [Clear, action-oriented title]
   Tasks:
   - [ ] [Verb] [specific action] [in specific location]
   - [ ] [Verb] [specific action]
   - [ ] Write tests for [component]
   Files: [Exact paths, comma-separated]
   Effort: [S or M only]
   Agent: [Dev-Backend | Dev-Frontend | Dev-Infrastructure | Research]
   Completion: [Specific, testable criteria - how do we KNOW it's done?]
   Blocked by: [REQ-XXX, REQ-YYY or "None"]
```

## Status Icons Reference

| Icon | Status | Meaning |
|------|--------|---------|
| ⚪ | Not Started | Work not begun |
| 🟡 | In Progress | Agent actively working |
| 🟢 | Complete | All criteria met, ready to archive |
| 🔴 | Blocked | Cannot proceed, dependency unmet |

## Integration with Existing Roadmap

When appending to an existing roadmap:

### Header Update
```markdown
**Last Updated:** [Today's date]
**Current Focus:** [Update if new work is higher priority]
**New Items Added:** REQ-XXX through REQ-YYY
```

### Batch Placement Options

1. **New batch at end** - If new work doesn't integrate with existing
2. **Insert into existing batch** - If dependencies align
3. **Create parallel batch** - If new work can run alongside existing

### Dependency Linking

Always check if new items should depend on existing items:
```markdown
⚪ REQ-050: Add OAuth login
   ...
   Blocked by: REQ-015 (existing user model), REQ-016 (existing auth endpoint)
```

## Quality Checklist

Before completing Phase 3:

- [ ] All items sized S or M (no L/XL)
- [ ] REQ numbers continue from existing roadmap
- [ ] Dependencies mapped (internal and external)
- [ ] Batches organized for parallelization
- [ ] Agents assigned appropriately
- [ ] Completion criteria are testable
- [ ] Files paths are specific
- [ ] No conflicts with in-progress work
- [ ] Roadmap header updated

## Final Output

After appending to roadmap, present summary to user:

```markdown
## Roadmap Updated

**Added:** [X] new requirements (REQ-XXX through REQ-YYY)

**New Batches:**
- Batch [N]: [Name] - [X] items ([agents involved])
- Batch [N+1]: [Name] - [X] items ([agents involved])

**Dependencies on Existing Work:**
- REQ-XXX depends on REQ-YYY (existing)

**Estimated Total Effort:** [X] S items + [Y] M items ≈ [Z] hours

**Recommended Starting Point:** REQ-XXX ([reason])

**Ready for implementation.** Agents can now claim work from the roadmap.
```

## Common Patterns

### Feature Addition Pattern
```
New Feature Request
    │
    ├── REQ-XXX: Database changes (S) - Dev-Infrastructure
    │       └── Blocked by: None
    │
    ├── REQ-XXX: Backend model/service (S/M) - Dev-Backend
    │       └── Blocked by: Database changes
    │
    ├── REQ-XXX: API endpoints (M) - Dev-Backend
    │       └── Blocked by: Backend model
    │
    └── REQ-XXX: Frontend components (M) - Dev-Frontend
            └── Blocked by: API endpoints
```

### Bug Fix Pattern
```
Bug Fix
    │
    ├── REQ-XXX: Write failing test (S) - Dev-Backend/Frontend
    │       └── Blocked by: None
    │
    └── REQ-XXX: Implement fix (S) - Dev-Backend/Frontend
            └── Blocked by: Failing test exists
```

### Refactor Pattern
```
Refactoring
    │
    ├── REQ-XXX: Add tests for current behavior (M)
    │       └── Blocked by: None
    │
    ├── REQ-XXX: Refactor implementation (M)
    │       └── Blocked by: Tests exist
    │
    └── REQ-XXX: Update dependent code (S/M)
            └── Blocked by: Refactor complete
```

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| L/XL items in roadmap | Too large to track | Break down further |
| Missing `Blocked by` | Hidden dependencies | Always state or "None" |
| Vague file paths | "Backend files" | Specific: `src/api/auth.py` |
| Untestable completion | "Works correctly" | Specific: "Returns 200 with JSON" |
| Overloaded batches | Everything in Batch 1 | Split by dependency |
| Agent overload | All items to one agent | Balance assignments |
