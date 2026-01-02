# Batch Organization Patterns

## Batch Organization Rules

### What Goes in Same Batch
- Requirements with **no dependencies** between them
- Work that can run **in parallel**
- Items assigned to **different agents**

### What Goes in Separate Batches
- Anything with `Blocked by:` pointing to another item
- Sequential work (API before UI)
- Same-file modifications

## Example: Good Batching

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
