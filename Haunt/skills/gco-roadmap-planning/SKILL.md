---
name: gco-roadmap-planning
description: Structured roadmap format for coordinating agent teams with batches, dependencies, and status tracking. Use when creating roadmaps, planning sprints, organizing work batches, or tracking multi-agent progress. Triggers on "create roadmap", "plan sprint", "organize work", "batch planning", "dependency mapping", or work coordination requests.
---

# Roadmap Planning

Structure and manage work for agent teams.

## Roadmap Format

```markdown
# Project Roadmap

**Last Updated:** [Date]
**Current Focus:** [Batch name]

---

## Batch 1: [Name]

🟡 REQ-001: [Title]
   Tasks:
   - [x] Completed task
   - [ ] Pending task
   Files: path/to/files
   Effort: S
   Agent: [Name]
   Completion: [Criteria]

⚪ REQ-002: [Title]
   Tasks:
   - [ ] Task 1
   - [ ] Task 2
   Files: path/to/files
   Effort: M
   Agent: [Name]
   Completion: [Criteria]
   Blocked by: None

---

## Batch 2: [Name]

⚪ REQ-010: [Title]
   ...
   Blocked by: REQ-001, REQ-002
```

## Status Icons

| Icon | Meaning | When to Use |
|------|---------|-------------|
| ⚪ | Not Started | Work not begun |
| 🟡 | In Progress | Agent actively working |
| 🟢 | Complete | All criteria met, archived |
| 🔴 | Blocked | Cannot proceed, dependency unmet |

## Batch Organization Rules

### What Goes in Same Batch
- Requirements with **no dependencies** between them
- Work that can run **in parallel**
- Items assigned to **different agents**

### What Goes in Separate Batches
- Anything with `Blocked by:` pointing to another item
- Sequential work (API before UI)
- Same-file modifications

### Example: Good Batching

```markdown
## Batch 1: Foundation (Parallel OK)
⚪ REQ-001: Database schema (Dev-Infrastructure)
⚪ REQ-002: Config management (Dev-Infrastructure)
⚪ REQ-003: Logging setup (Dev-Infrastructure)

## Batch 2: Core Backend (Depends on Batch 1)
⚪ REQ-010: User model (Dev-Backend) - Blocked by: REQ-001
⚪ REQ-011: Auth service (Dev-Backend) - Blocked by: REQ-001

## Batch 3: API Layer (Depends on Batch 2)
⚪ REQ-020: User endpoints (Dev-Backend) - Blocked by: REQ-010
⚪ REQ-021: Auth endpoints (Dev-Backend) - Blocked by: REQ-011

## Batch 4: Frontend (Depends on Batch 3)
⚪ REQ-030: Login page (Dev-Frontend) - Blocked by: REQ-021
⚪ REQ-031: User profile (Dev-Frontend) - Blocked by: REQ-020
```

## Priority Order

Within same batch, sequence by:

1. **Infrastructure** first (affects everything)
2. **Backend** second (APIs that frontend needs)
3. **Frontend** last (depends on backend)
4. **Same layer**: smaller (S) before larger (M)

## Archiving Completed Work

When requirement is done:

1. Change status to 🟢
2. Add completion date
3. Move to `.haunt/completed/roadmap-archive.md`
4. Keep active roadmap clean

### Archive Format

```markdown
# Roadmap Archive

## 2024-12

### REQ-001: Database schema
- Completed: 2024-12-05
- Agent: Dev-Infrastructure
- Tasks: 3/3
- Notes: Added index on email column for performance
```

## Dispatch Protocol

When assigning work:

```markdown
## Assignment: REQ-XXX

**Agent:** [Name]
**Branch:** feature/REQ-XXX
**Goal:** [One sentence]

### Tasks
1. [ ] First task
2. [ ] Second task

### Files to Modify
- `src/path/to/file.py`
- `tests/path/to/test.py`

### Constraints
- Must maintain backward compatibility
- Use existing patterns from src/utils/

### Completion Criteria
- [ ] All tasks checked
- [ ] Tests passing
- [ ] Code reviewed
```

## Progress Tracking

### Daily Check
```bash
# Count by status
grep -c "⚪" .haunt/plans/roadmap.md  # Not started
grep -c "🟡" .haunt/plans/roadmap.md  # In progress
grep -c "🟢" .haunt/plans/roadmap.md  # Complete
grep -c "🔴" .haunt/plans/roadmap.md  # Blocked
```

### Velocity Metrics
| Metric | How to Calculate |
|--------|-----------------|
| Phases/day | Completed items ÷ days |
| Avg time/phase | Total hours ÷ completed items |
| Block rate | Blocked items ÷ total items |

## Dependency Visualization

For complex projects, create dependency graph:

```
REQ-001 (DB Schema)
    │
    ├──► REQ-010 (User Model)
    │        │
    │        └──► REQ-020 (User API)
    │                 │
    │                 └──► REQ-030 (User UI)
    │
    └──► REQ-011 (Auth Service)
             │
             └──► REQ-021 (Auth API)
                      │
                      └──► REQ-031 (Login UI)
```

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Everything in Batch 1 | No parallelization | Split by dependencies |
| Missing `Blocked by` | Hidden dependencies | Always state or "None" |
| Stale roadmap | Trust erosion | Update daily |
| No archive | Lost history | Archive completed items |
| Vague completion | Endless "in progress" | Testable criteria |
