---
name: gco-coven-mode
description: Gather the coven - coordinate multiple agents working in parallel on the same task. Use when a single task requires diverse expertise (backend + frontend + infrastructure), when parallel work will speed completion, or when user says "gather the coven", "summon the coven", "call a coven", or "coven mode".
---

# Coven Mode: Multi-Agent Coordination

When the spirits work in concert, great things are accomplished. The Coven is Ghost County's pattern for coordinating multiple agents working together in parallel on the same task or tightly-coupled set of tasks.

## When to Use

- **Complex Features:** Require backend + frontend + infrastructure changes together
- **Parallel Speedup:** Work can be split into independent parallel streams
- **Cross-Domain Tasks:** Require diverse agent expertise working in coordination
- **Trigger Phrases:** "gather the coven", "summon the coven", "call a coven", "coven mode"

## Coven vs Seance

| Aspect | Seance | Coven |
|--------|--------|-------|
| **Purpose** | Sequential workflow orchestration | Parallel multi-agent coordination |
| **Timing** | Planning → Implementation | Implementation only |
| **Agent Pattern** | One at a time, batched by dependencies | Multiple in parallel, coordinated |
| **Use Case** | New features, roadmap creation | Complex existing task requiring multiple skills |

**Simple rule:** Seance for planning, Coven for parallel execution.

## Coordination Patterns

### Pattern 1: Domain Split (Vertical Slice)

Split a feature across technical domains that can work independently.

**Example:** Add user profile feature
- **Dev-Backend:** API endpoints, database schema
- **Dev-Frontend:** Profile UI components, form validation
- **Dev-Infrastructure:** CDN for profile images, caching layer

**Coordination:**
- Define API contract upfront (shared interface)
- Backend works on endpoints with mock data
- Frontend works on UI with mock API
- Infrastructure provisions resources
- Integration point: Backend + Frontend connect via agreed API

**Conflict Prevention:**
- Each domain owns specific files (minimal overlap)
- Shared contract defined before parallel work begins
- Integration testing after all streams complete

### Pattern 2: Layer Split (Horizontal Slice)

Split by architectural layers when making cross-cutting changes.

**Example:** Add authentication everywhere
- **Dev-Backend:** Auth middleware, token validation
- **Dev-Frontend:** Login UI, session management
- **Dev-Infrastructure:** Secret storage, rate limiting

**Coordination:**
- Define auth flow and token format first
- Each layer implements its responsibility
- Integration testing validates full flow

### Pattern 3: Feature Decomposition

Break large feature into parallel independent sub-features.

**Example:** Dashboard with multiple widgets
- **Agent 1 (Dev-Backend):** Widget data endpoints (all widgets)
- **Agent 2 (Dev-Frontend):** Chart widget UI
- **Agent 3 (Dev-Frontend):** Table widget UI
- **Agent 4 (Dev-Frontend):** Dashboard layout and integration

**Coordination:**
- Agent 4 defines layout contract
- Agents 2-3 build widgets to contract
- Agent 1 provides data endpoints
- Integration: Agent 4 assembles all widgets

### Pattern 4: Research + Implementation

Parallel research and implementation streams.

**Example:** Evaluate and implement new payment processor
- **Research-Analyst:** Evaluate options, document findings
- **Dev-Backend:** Build abstraction layer and initial integration (started based on likely choice)
- **Research-Critic:** Review implementation against best practices

**Coordination:**
- Research identifies top choice early
- Backend starts building based on likely winner
- Critic validates approach matches research findings
- Adjust implementation if research changes recommendation

## Coven Coordination Workflow

### Step 1: Task Analysis

Before gathering the coven, understand:
- What's the complete task/feature?
- What domains are involved? (backend, frontend, infrastructure, etc.)
- Can work truly happen in parallel, or are there blocking dependencies?
- What's the integration point where streams converge?

**If dependencies exist:** Consider using Seance instead (sequential batching).

### Step 2: Define Contracts

Establish shared interfaces before parallel work begins:

**For API-driven splits:**
- API endpoint paths, methods, request/response schemas
- Authentication requirements
- Error handling conventions

**For UI/component splits:**
- Component props and interfaces
- Shared state management patterns
- Styling/theming conventions

**For infrastructure:**
- Resource naming conventions
- Configuration management approach
- Deployment sequence

**Document contracts in shared location:**
- Add to requirement in roadmap under "Integration Contract"
- Or create `.haunt/docs/integration-contracts/REQ-XXX.md`

### Step 3: Spawn Coven Members

Spawn each agent with:
1. **Clear scope:** Which part of the work they own
2. **Contract reference:** Link to shared interface definition
3. **Integration expectations:** When/how their work connects to others
4. **Conflict avoidance:** Which files they should/shouldn't touch

**Example spawn messages:**

```
Summon gco-dev-backend:
"You are part of a coven working on REQ-123 (user profiles).
Your scope: API endpoints and database schema.
Contract: See .haunt/docs/integration-contracts/REQ-123.md for API spec.
Files: Own src/api/profile.py and migrations/. DO NOT modify frontend files.
Integration: Frontend agent will consume your API once complete."

Summon gco-dev-frontend:
"You are part of a coven working on REQ-123 (user profiles).
Your scope: Profile UI and form validation.
Contract: See .haunt/docs/integration-contracts/REQ-123.md for API spec.
Use mock API responses during development.
Files: Own src/components/Profile/ and src/pages/profile.tsx.
Integration: Connect to real API once backend agent completes."

Summon gco-dev-infrastructure:
"You are part of a coven working on REQ-123 (user profiles).
Your scope: CDN for profile images and caching layer.
Contract: See .haunt/docs/integration-contracts/REQ-123.md.
Files: Own terraform/cdn.tf and deploy/cache-config.yml.
Integration: Backend will use your CDN URLs and cache endpoints."
```

### Step 4: Monitor Progress

Track each agent's progress:
- Check roadmap for task completion checkboxes
- Watch for blocking issues that affect other coven members
- Identify when integration points are ready

**Communication pattern:**
- Coven members update roadmap tasks as they complete
- If one agent hits blocker affecting others, escalate to coordinator (PM or user)
- When agent completes their scope, mark ready for integration

### Step 5: Integration & Testing

Once all coven members complete their scopes:

1. **Integration phase:** Connect the parallel streams
   - Backend + Frontend connect via API
   - Infrastructure resources configured in app
   - All pieces tested together

2. **Conflict resolution:** If file conflicts arose:
   - Review changes for logical conflicts (not just git conflicts)
   - Ensure consistent error handling across layers
   - Verify naming conventions align

3. **E2E testing:** Validate full feature works end-to-end
   - User flow testing
   - Error case testing
   - Performance validation

## Conflict Prevention Strategies

### File Ownership

Assign clear file ownership to prevent git conflicts:

**Good (No overlap):**
- Agent A: `src/api/users.py`, `tests/test_users_api.py`
- Agent B: `src/ui/UserProfile.tsx`, `tests/UserProfile.test.tsx`

**Bad (Overlap risk):**
- Agent A: "All backend files"
- Agent B: "All test files" ← Conflict! Both touch test files

**Solution:** Be specific about file paths. If overlap is unavoidable, serialize those changes.

### Shared State

For files that multiple agents need (config, constants, types):

**Option 1: Pre-create stubs**
- Before spawning coven, create shared type definitions
- Each agent uses but doesn't modify

**Option 2: Designate owner**
- One agent owns shared files
- Others reference but don't edit
- Owner integrates changes from other agents at end

**Option 3: Post-integration merge**
- Each agent works independently
- Integration phase: Coordinator merges shared file changes

### Database Migrations

Special case: Multiple agents creating migrations.

**Strategy:**
- Designate one "migration owner" (usually backend agent)
- Other agents describe needed schema changes in comments
- Migration owner creates all migrations after coordination
- Or: Use timestamp-based migration naming to avoid conflicts

### Test Conflicts

When multiple agents write tests for same system:

**Strategy:**
- Each agent owns tests for their domain
- Backend: API tests
- Frontend: Component tests
- Integration tests: Created after parallel work completes

## Result Aggregation

After coven completes work:

### Aggregate Changes

Collect all changes from parallel streams:
```bash
# Review what each agent changed
git log --oneline --author="Claude" -10

# Check for conflicts
git status

# Review integration points
git diff main...feature/REQ-123
```

### Consolidated Testing

Run full test suite across all changes:
```bash
# Backend tests
pytest tests/

# Frontend tests
npm test

# E2E tests
playwright test

# Infrastructure validation
terraform plan
```

### Unified Commit

Create single commit representing the coven's work:

```
[REQ-123] Add: User profile feature (coven)

What was done:
- Backend: Profile API endpoints and user table schema (gco-dev-backend)
- Frontend: Profile UI component with form validation (gco-dev-frontend)
- Infrastructure: CDN for profile images and Redis caching (gco-dev-infrastructure)
- Integration: Connected all layers via profile API contract
- Tests: Added 23 tests across all layers

🤖 Generated with Claude Code
```

Note the "(coven)" tag in header to indicate multi-agent work.

## Example Coven Session

```
User: "Gather the coven to implement REQ-089: Real-time notifications"

Coordinator:
🌙 Gathering the coven for REQ-089...

Analyzing task complexity:
- Backend: WebSocket server, notification queue, persistence
- Frontend: Notification bell UI, WebSocket client, toast components
- Infrastructure: Redis for pub/sub, load balancer WebSocket support

This is suitable for coven mode (3 parallel streams).

Defining contract:
- WebSocket message format: { type, payload, timestamp }
- API: /api/notifications (REST), ws://api/notifications (WebSocket)
- Redis channel: "notifications:{user_id}"

Ready to summon the coven?

[User: "yes"]

🕯️ The spirits gather...

Summoning gco-dev-backend for WebSocket server and persistence...
Summoning gco-dev-frontend for notification UI and client...
Summoning gco-dev-infrastructure for Redis and load balancer...

[All three agents work in parallel]
[Each updates roadmap tasks as they progress]
[Integration phase begins when all complete]

🎉 The coven has completed its work!

Summary:
- Backend: WebSocket server operational, 8 tests passing
- Frontend: Notification bell and toasts working, 12 tests passing
- Infrastructure: Redis deployed, load balancer configured
- Integration: E2E test validates full notification flow

All changes ready for commit.
```

## Quality Checklist

Before completing coven coordination:

- [ ] Task analyzed and confirmed suitable for parallel work
- [ ] Contracts defined (API specs, interfaces, naming conventions)
- [ ] Clear scope assigned to each coven member (no overlap)
- [ ] All agents completed their scopes
- [ ] Integration phase completed successfully
- [ ] No unresolved file or logical conflicts
- [ ] Full test suite passes (all layers)
- [ ] Unified commit created with all changes
- [ ] Roadmap updated to reflect completion

## Anti-Patterns (Don't Do This)

**Don't gather coven when work is sequential:**
- If backend must finish before frontend can start → Use Seance batching
- If infrastructure must provision before app can deploy → Use Seance batching

**Don't spawn coven without contracts:**
- Parallel work without agreed interfaces = integration chaos
- Always define API/interface contracts BEFORE parallel work

**Don't ignore conflicts:**
- Git conflicts mean logical conflicts might exist too
- Review ALL changes at integration, not just auto-merge

**Don't skip integration testing:**
- Unit tests passing ≠ integrated system working
- Always validate E2E flow after coven completes

## Skill References

This skill works alongside:

- **gco-seance** - For sequential workflow orchestration (planning then execution)
- **gco-roadmap-workflow** - For understanding requirement structure
- **gco-tdd-workflow** - For ensuring each coven member writes tests

The Coven complements Seance - use Seance for planning and sequential work, use Coven for parallel execution of complex tasks.
