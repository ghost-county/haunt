---
name: gco-roadmap-workflow
description: Complex workflow coordination for batch organization, multi-agent sequencing, archiving, and session management. Use when organizing complex phases into batches, coordinating dependencies, managing multi-session work, or archiving completed requirements. For basic protocols, see `.claude/rules/`.
---

# Roadmap Workflow

Complex coordination workflows for multi-requirement batches and agent coordination.

**For basic protocols, see:**
- `.claude/rules/gco-session-startup.md` - Session startup checklist
- `.claude/rules/gco-roadmap-format.md` - Requirement format and status icons
- `.claude/rules/gco-status-updates.md` - Who updates what
- `.claude/rules/gco-completion-checklist.md` - Verification before marking complete

## Batch Organization and Coordination

### Batch Parallelization Strategy

**Same batch = parallel work possible**
- No dependencies between requirements
- Different agents working simultaneously
- Different files or non-overlapping file sections
- Can all be started at once

**Separate batches = must run sequentially**
- Requirements with `Blocked by:` dependencies
- Same-file modifications that could conflict
- Shared state changes requiring ordering
- Infrastructure changes that other work depends on

### Batch Sequencing for Dependencies

When organizing a phase with dependencies:

1. **Map the dependency graph:**
   - List all requirements
   - Identify `Blocked by:` relationships
   - Find requirements with no blockers (Batch 1)

2. **Create sequential batches:**
   ```markdown
   ## Batch 1: Foundation
   ### ⚪ REQ-001: Base infrastructure (Blocked by: None)
   ### ⚪ REQ-002: Core API (Blocked by: None)

   ## Batch 2: Features
   ### ⚪ REQ-003: Feature A (Blocked by: REQ-001)
   ### ⚪ REQ-004: Feature B (Blocked by: REQ-002)

   ## Batch 3: Integration
   ### ⚪ REQ-005: Integration layer (Blocked by: REQ-003, REQ-004)
   ```

3. **Update as work completes:**
   - When batch completes, verify next batch is unblocked
   - If blocker removed, update `Blocked by: None`
   - Move newly unblocked work to active batch

### Multi-Agent Coordination

**Coordinating parallel work:**
- Assign different agents to same batch requirements
- Use `Agent:` field to track assignments
- Communicate file conflicts before they happen
- PM tracks overall batch completion

**Handoff between agents:**
- Completing agent: Mark 🟢, add implementation notes
- Next agent: Read implementation notes before starting
- Update `Blocked by:` field when dependency met

## Incremental Progress Tracking

**For all work (single or multi-session):**

1. **Before starting:** Review unchecked tasks in requirement
2. **During work:** After completing each task:
   - Update roadmap immediately: `- [ ]` → `- [x]`
   - Add brief implementation note if helpful
   - Keep status at 🟡 until ALL tasks done
3. **At completion:** Verify all `- [x]`, then mark 🟢

**Why incremental updates matter:**
- Provides real-time progress visibility
- Prevents "forgetting to update" at end
- Helps multi-session work resume easily
- Required by completion checklist (not optional)

**Anti-pattern:**
❌ Complete all work → Try to remember what was done → Update checkboxes → Mark 🟢
✅ Complete task → Update checkbox → Complete next task → ... → Mark 🟢

## Archiving Workflow (Project Manager Only)

**When requirement is 🟢 Complete:**
1. Verify completion criteria met (see `.claude/rules/gco-completion-checklist.md`)
2. Remove from CLAUDE.md Active Work section
3. Archive to `.haunt/completed/roadmap-archive.md` with date and metadata
4. Delete from `.haunt/plans/roadmap.md`
5. Update `Blocked by: None` for newly unblocked requirements

**For M-sized or infrastructure changes:**
- Create `.haunt/completed/REQ-XXX-implementation-summary.md`
- Include: overview, approach, changes, testing, integration notes

## Multi-Session Work Coordination

**Breaking M-sized into multiple sessions:**
- Update task checkboxes after each session (keep status 🟡)
- Add implementation notes for next session
- Final session: Verify all criteria, mark 🟢

**Session handoff:**
- Read previous notes before resuming
- Verify tests still pass
- Continue from last checked task

## Batch Completion (Project Manager)

**When all batch requirements are 🟢:**
1. Verify all completion criteria met, tests passing
2. **If roadmap is sharded:** Use `/roadmap archive "Batch Name"` to:
   - Verify batch is 100% complete (all requirements 🟢)
   - Move batch file from `.haunt/plans/batches/` to `.haunt/completed/batches/`
   - Add archival timestamp to batch metadata
   - Update overview roadmap (remove archived batch)
   - Automatically activate next batch (if available)
3. **If roadmap is monolithic:** Archive entire batch with summary to `.haunt/completed/roadmap-archive.md`
4. Unblock next batch: Update `Blocked by: None` for dependent work (if not auto-updated by archive command)
5. Assign agents to next batch, update CLAUDE.md Active Work

### Archive Command (Sharded Roadmaps Only)

**Usage:**
```bash
/roadmap archive "Batch Name"
```

**When to use:**
- Roadmap is sharded (via `/roadmap shard`)
- All requirements in batch are 🟢 Complete
- All tasks checked off (no `- [ ]` remaining)
- Ready to move to next phase of work

**What it does:**
1. Validates batch is 100% complete (strict check)
2. Moves batch file to `.haunt/completed/batches/batch-N-[slug]-archived.md`
3. Adds archival timestamp and completion metadata
4. Removes batch from overview roadmap
5. Activates next batch automatically (if available)
6. Reports batch transition (archived → activated)

**Auto-archive detection (optional enhancement):**
- When running `/roadmap shard` or `/roadmap activate`, command can detect completed batches
- Suggests archiving: "Batch X is 100% complete. Archive it? [yes/no]"
- Reduces manual archival overhead

**Error handling:**
- Incomplete batch: Lists incomplete requirements (🟡, ⚪, 🔴)
- Not sharded: Errors gracefully, suggests using standard archival workflow
- No next batch: Reports successful archival with "All work complete!" message
