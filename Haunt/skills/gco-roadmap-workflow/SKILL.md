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
2. Archive entire batch with summary to `.haunt/completed/roadmap-archive.md`
3. Unblock next batch: Update `Blocked by: None` for dependent work
4. Assign agents to next batch, update CLAUDE.md Active Work
