---
name: gco-requirements-rubric
description: Framework for writing atomic, actionable requirements that agents can execute. Use when creating requirements, user stories, tasks, tickets, or roadmap items. Triggers on "write requirement", "create task", "break down feature", "roadmap", "REQ-", "user story", or when planning work for agents.
---

# Requirements Rubric

Write requirements that agents can execute without ambiguity.

## Effort Sizing

| Size | Duration | Rule |
|------|----------|------|
| **S (Small)** | 1-4 hours | One focused session |
| **M (Medium)** | 4-8 hours | Can split into 2 sessions |

**Never use L or XL.** Break those down until every item is S or M.

## Required Fields

Every requirement MUST have:

```markdown
🟡 REQ-XXX: [Clear, action-oriented title]
   Tasks:
   - [ ] Specific task 1
   - [ ] Specific task 2
   Files: [Exact paths to create/modify]
   Effort: [S or M]
   Agent: [Assigned agent]
   Completion: [Specific, testable criteria]
   Blocked by: [Dependencies, if any]
```

### Status Icons

- ⚪ Not Started
- 🟡 In Progress  
- 🟢 Complete
- 🔴 Blocked

## Quality Checklist

Before finalizing any requirement:

- [ ] **Atomic**: Single responsibility, one PR scope
- [ ] **Actionable**: Clear what to do (not vague goals)
- [ ] **Testable**: Completion criteria are verifiable
- [ ] **Sized correctly**: S or M only
- [ ] **Files listed**: Exact paths, not "relevant files"
- [ ] **Dependencies explicit**: Blocked-by stated or "None"

## Completion Criteria Examples

**Bad (vague):**
- "Works correctly"
- "User can login"
- "Tests pass"

**Good (specific):**
- "GET /api/users returns 200 with JSON array"
- "Login form submits credentials, receives JWT, stores in localStorage"
- "`pytest tests/test_auth.py` passes with 100% coverage on auth module"

## Batch Organization

Group requirements by dependencies for parallelization:

```markdown
## Batch 1: Infrastructure (No dependencies)
⚪ REQ-001: Database schema (Dev-Infrastructure)
⚪ REQ-002: Config management (Dev-Infrastructure)

## Batch 2: Backend (Depends on Batch 1)
⚪ REQ-010: User model (Dev-Backend) - Blocked by: REQ-001
⚪ REQ-011: Auth endpoints (Dev-Backend) - Blocked by: REQ-001

## Batch 3: Frontend (Depends on Batch 2)
⚪ REQ-020: Login component (Dev-Frontend) - Blocked by: REQ-011
```

### Priority Order Within Batches

1. Infrastructure changes (affect everything)
2. Backend changes (APIs that frontend needs)
3. Frontend changes (depends on backend)
4. Within same layer: smaller first

## Breaking Down Large Work

When a feature is too big:

1. **List all components** needed
2. **Identify dependencies** between them
3. **Split by boundary**: API vs UI vs DB vs Config
4. **Size each piece**: Must be S or M
5. **Sequence by dependency**

### Example Breakdown

**Large feature:** "User authentication system"

**Broken down:**
```markdown
## Batch 1: Infrastructure
⚪ REQ-001: Create users table schema
   Tasks:
   - [ ] Create migration file
   - [ ] Define id, email, password_hash, created_at columns
   - [ ] Add unique constraint on email
   Files: migrations/001_users.sql
   Effort: S
   Completion: Migration runs without error, table exists

## Batch 2: Backend  
⚪ REQ-010: User model and repository
   Tasks:
   - [ ] Create User pydantic model
   - [ ] Create UserRepository with CRUD methods
   - [ ] Add password hashing utility
   Files: src/models/user.py, src/repositories/user.py
   Effort: S
   Blocked by: REQ-001
   Completion: Unit tests pass for all repository methods

⚪ REQ-011: Auth endpoints
   Tasks:
   - [ ] POST /register - create user
   - [ ] POST /login - return JWT
   - [ ] GET /me - return current user
   Files: src/api/auth.py, tests/test_auth.py
   Effort: M
   Blocked by: REQ-010
   Completion: All endpoints return correct status codes, JWT valid

## Batch 3: Frontend
⚪ REQ-020: Login form component
   Tasks:
   - [ ] Create LoginForm with email/password fields
   - [ ] Submit to /login endpoint
   - [ ] Store JWT in localStorage
   - [ ] Redirect to dashboard on success
   Files: src/components/LoginForm.tsx
   Effort: S
   Blocked by: REQ-011
   Completion: Can log in with valid credentials, see dashboard
```

## Anti-Patterns to Avoid

| Anti-Pattern | Example | Fix |
|--------------|---------|-----|
| Vague scope | "Improve performance" | "Reduce /api/users P95 latency to <200ms" |
| No files listed | "Update the backend" | "Files: src/api/users.py, src/models/user.py" |
| L/XL sizing | "Build auth system" | Break into 4-6 S/M requirements |
| Implicit dependencies | Missing blocked-by | Always state dependencies or "None" |
| Compound tasks | "Add and test endpoint" | Separate: Add endpoint (REQ-1), Add tests (REQ-2) |
