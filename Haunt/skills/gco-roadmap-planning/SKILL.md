---
name: gco-roadmap-planning
description: Structured roadmap format for coordinating agent teams with batches, dependencies, and status tracking. Use when creating roadmaps, planning sprints, organizing work batches, or tracking multi-agent progress. Triggers on "create roadmap", "plan sprint", "organize work", "batch planning", "dependency mapping", or work coordination requests.
---

# Roadmap Planning

Structure and manage work for agent teams.

## Purpose

This skill provides guidance for creating and managing project roadmaps with batch organization, dependency tracking, and progress monitoring. Use this when organizing work for multi-agent teams or planning complex features with interdependent requirements.

## When to Invoke

- Creating new project roadmaps
- Planning sprints or work phases
- Organizing requirements into batches
- Managing dependencies between requirements
- Tracking multi-agent team progress
- Sharding large roadmaps for token efficiency

## Roadmap Format (Quick Reference)

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
```

**For full format specification, see:** `.claude/rules/gco-roadmap-format.md`

## Status Icons

| Icon | Meaning | When to Use |
|------|---------|-------------|
| ⚪ | Not Started | Work not begun |
| 🟡 | In Progress | Agent actively working |
| 🟢 | Complete | All criteria met, archived |
| 🔴 | Blocked | Cannot proceed, dependency unmet |

## Batch Organization (Quick Guide)

**Same batch = parallel work possible:**
- No dependencies between requirements
- Different agents working simultaneously
- Different files or non-overlapping sections

**Separate batches = must run sequentially:**
- Requirements with `Blocked by:` dependencies
- Same-file modifications that could conflict
- Infrastructure changes other work depends on

⛔ **CONSULTATION GATE:** For detailed batch organization patterns, dependency visualization, and anti-patterns, READ `references/batch-organization.md`.

## Roadmap Sharding (Performance Optimization)

**When to shard:**
- Roadmap exceeds 500 lines
- 10+ requirements across multiple batches
- Token usage >2,000 tokens per request

**Token savings:** 60-80% reduction for projects with 10+ requirements.

**Commands:**
- `/roadmap shard` - Split roadmap into batch files
- `/roadmap unshard` - Restore monolithic format
- `/roadmap activate "Batch Name"` - Switch active batch

⛔ **CONSULTATION GATE:** For sharding implementation details, batch file naming, effort estimation, and token savings calculations, READ `references/roadmap-sharding.md`.

## Core Workflow

### 1. Create Roadmap

1. **Identify all requirements**
   - List all features, bugs, enhancements
   - Extract from user requests, backlog, issues

2. **Map dependencies**
   - What must be done first?
   - What can be done in parallel?
   - What blocks other work?

3. **Organize into batches**
   - Group independent work into same batch
   - Create sequential batches for dependent work
   - Number batches in execution order

4. **Assign agents**
   - Match work to agent type (Dev-Backend, Dev-Frontend, etc.)
   - Distribute load across team
   - Consider agent availability

### 2. Track Progress

**Update status in real-time:**
- Starting work: ⚪ → 🟡
- Blocking issue: 🟡 → 🔴 (update "Blocked by:" field)
- Task complete: `- [ ]` → `- [x]`
- Requirement complete: 🟡 → 🟢

**Monitor metrics:**
```bash
# Count by status
grep -c "⚪" .haunt/plans/roadmap.md  # Not started
grep -c "🟡" .haunt/plans/roadmap.md  # In progress
grep -c "🟢" .haunt/plans/roadmap.md  # Complete
grep -c "🔴" .haunt/plans/roadmap.md  # Blocked
```

### 3. Archive Completed Work

When requirement is 🟢:
1. Verify completion criteria met
2. Add completion date
3. Move to `.haunt/completed/roadmap-archive.md`
4. Update `Blocked by: None` for newly unblocked requirements

⛔ **CONSULTATION GATE:** For archiving format, dispatch protocol, and velocity metrics, READ `references/roadmap-templates.md`.

## Priority Sequencing

Within same batch, prioritize:

1. **Infrastructure** first (affects everything)
2. **Backend** second (APIs that frontend needs)
3. **Frontend** last (depends on backend)
4. **Same layer**: smaller (S) before larger (M)

## Multi-Agent Coordination

**Coordinating parallel work:**
- Assign different agents to same batch requirements
- Use `Agent:` field to track assignments
- Communicate file conflicts before they happen
- PM tracks overall batch completion

**Handoff between agents:**
- Completing agent: Mark 🟢, add implementation notes
- Next agent: Read implementation notes before starting
- Update `Blocked by:` field when dependency met

## Sharding Workflow

### When Roadmap Grows Large (>500 lines)

**Step 1: Shard the roadmap**
```bash
/roadmap shard
# OR specify active batch
/roadmap shard --active "Setup Improvements"
```

**Step 2: Work with active batch**
- Overview roadmap contains active batch
- Other batches in `.haunt/plans/batches/`
- Load only what you need

**Step 3: Switch batches as work progresses**
```bash
/roadmap activate "Next Batch Name"
```

**Step 4: Unshard when needed**
```bash
/roadmap unshard
# Restores monolithic format
```

**Token efficiency:**
- Before: 2,550+ tokens per request
- After: ~450 tokens per request
- Savings: 82% reduction

## Common Patterns

### Pattern 1: Foundation → Features → Integration

```markdown
## Batch 1: Foundation
⚪ REQ-001: Database setup
⚪ REQ-002: Config management
⚪ REQ-003: Logging

## Batch 2: Core Features
⚪ REQ-010: User model (Blocked by: REQ-001)
⚪ REQ-011: Auth service (Blocked by: REQ-001)

## Batch 3: Integration
⚪ REQ-020: API endpoints (Blocked by: REQ-010, REQ-011)
```

### Pattern 2: Parallel Streams by Agent Type

```markdown
## Batch 1: Backend Stream
⚪ REQ-001: User API (Dev-Backend)
⚪ REQ-002: Product API (Dev-Backend)

## Batch 1: Frontend Stream (Parallel OK)
⚪ REQ-010: Navigation (Dev-Frontend)
⚪ REQ-011: Layout (Dev-Frontend)

## Batch 2: Integration (Depends on Batch 1)
⚪ REQ-020: User profile page (Blocked by: REQ-001, REQ-010)
```

### Pattern 3: Infrastructure → Implementation → Testing

```markdown
## Batch 1: Infrastructure
⚪ REQ-001: CI/CD pipeline (Dev-Infrastructure)
⚪ REQ-002: Test framework (Dev-Infrastructure)

## Batch 2: Implementation
⚪ REQ-010: Feature A (Dev-Backend) (Blocked by: REQ-002)
⚪ REQ-011: Feature B (Dev-Frontend) (Blocked by: REQ-002)

## Batch 3: E2E Testing
⚪ REQ-020: Test suite (Dev-Frontend) (Blocked by: REQ-010, REQ-011)
```

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Everything in Batch 1 | No parallelization | Split by dependencies |
| Missing `Blocked by` | Hidden dependencies | Always state or "None" |
| Stale roadmap | Trust erosion | Update daily |
| No archive | Lost history | Archive completed items |
| Vague completion criteria | Endless "in progress" | Testable criteria |

## Reference Index

⛔ **CONSULTATION GATES:** When you need detailed guidance, READ the appropriate reference file:

| When You Need | Read This |
|---------------|-----------|
| **Batch organization rules, dependency visualization, priority sequencing** | `references/batch-organization.md` |
| **Roadmap sharding details, token savings, batch file structure** | `references/roadmap-sharding.md` |
| **Roadmap templates, archive format, dispatch protocol** | `references/roadmap-templates.md` |

## Integration with Other Skills

**Works with:**
- `gco-roadmap-workflow` - Multi-requirement coordination and archiving
- `gco-session-startup` - Assignment lookup from roadmap
- `gco-roadmap-format` (rule) - Requirement format specification

## Success Criteria

Effective roadmap planning when:
1. All requirements organized into logical batches
2. Dependencies clearly marked with `Blocked by:`
3. Agents assigned based on specialization
4. Progress tracked with real-time status updates
5. Completed work archived regularly
6. Token efficiency maintained (shard if >500 lines)

## See Also

- `.claude/rules/gco-roadmap-format.md` - Requirement format and status protocol
- `.claude/rules/gco-session-startup.md` - Assignment lookup workflow
- `Haunt/skills/gco-roadmap-workflow/SKILL.md` - Multi-session coordination
