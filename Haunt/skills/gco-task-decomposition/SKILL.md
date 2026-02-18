---
name: gco-task-decomposition
description: Break down large tasks into atomic, parallelizable pieces. Use when work is too big for one session, when user says "decompose", "break down", or "split this up".
---

# Task Decomposition

When a task is too large to complete in one sitting, break it down into atomic pieces.

## When to Use

- Task involves >8 files
- Task has >4 distinct steps
- Task spans multiple domains (backend + frontend + infra)
- User says "decompose", "break down", "split this up"

## The One Sitting Rule

Every piece MUST be completable in one work session:

| Size | Files | Characteristics |
|------|-------|-----------------|
| XS | 1-2 | Quick fixes, config changes |
| S | 2-4 | Single component features |
| M | 4-8 | Multi-component features |

If a piece is bigger than M, decompose further.

## Decomposition Process

### Step 1: Identify Natural Boundaries

| Strategy | Best For | Example |
|----------|----------|---------|
| **Layer Split** | Full-stack features | DB -> Backend -> API -> Frontend |
| **Domain Split** | Cross-cutting concerns | Auth module, User module, Payment module |
| **Feature Slice** | User-facing features | CRUD operations split by action |
| **Risk Isolation** | Uncertain requirements | Spike -> Foundation -> Feature |
| **Dependency Chain** | Sequential requirements | Data model -> Service -> API -> UI |

### Step 2: Map Dependencies

Create a dependency graph of tasks:

```
A -> B, C     (A blocks both B and C)
B -> D        (B blocks D)
C -> D        (C blocks D)
```

### Step 3: Identify Parallelization

Tasks with no dependencies between them can run in parallel:

```
Phase 1 (Sequential):  A
Phase 2 (Parallel):    B || C
Phase 3 (Sequential):  D
```

**Good parallel candidates:**
- Different file sets (no overlap)
- Different technical domains
- No data dependencies

**Poor parallel candidates:**
- Shared database migrations
- Same configuration files
- Interdependent data structures

### Step 4: Size Each Piece

Every piece must fit within XS/S/M limits. If not, decompose further.

## Quality Checklist

- [ ] Every piece fits within sizing limits
- [ ] Dependencies form a valid DAG (no cycles)
- [ ] Parallel opportunities identified
- [ ] Each piece has testable completion criteria
- [ ] No file overlap between parallel tasks

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| **Too granular** | Tiny pieces with no standalone value | Combine related tasks |
| **Circular deps** | A -> B -> C -> A | Break the cycle |
| **Hidden deps** | Shared files not declared | Analyze file overlap |
| **Uneven sizing** | 1 XS + 1 XL | Rebalance pieces |
| **No integration** | Parallel work never merges | Add final integration task |
