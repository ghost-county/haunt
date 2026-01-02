# Roadmap Templates and Examples

## Standard Roadmap Format

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
