# Session Startup Protocol

Execute in order, every session, before ANY work:

## 1. Verify Environment

```bash
pwd && git status
```

**What to check:**
- Confirm you're in the correct project directory
- Review git status for uncommitted changes or clean working tree
- Understand the current state before proceeding

## 2. Check Recent Changes

```bash
git log --oneline -5
```

**What to check:**
- Review the last 5 commits to understand what work was recently completed
- Identify any patterns or ongoing work streams
- Understand the project's current development state

## 2.5. Check Roadmap File Size

**CRITICAL:** Monitor roadmap file size to prevent performance degradation.

```bash
wc -l .haunt/plans/roadmap.md
```

**What to check:**
- Count of lines in `.haunt/plans/roadmap.md` (must be shown)
- **Normal (0-500 lines):** Continue normally, no action needed
- **Warning (501-750 lines):** Display warning - archiving should be done soon
- **Critical (751+ lines):** STOP work and require archiving before proceeding

**Actions:**

**If 0-500 lines:**
```
✓ Roadmap size normal (XXX lines). Continue.
```

**If 501-750 lines:**
Auto-run `/banish --all-complete` to archive completed requirements:
```bash
/banish --all-complete
```

After archiving, recheck roadmap size:
```bash
wc -l .haunt/plans/roadmap.md
```

**If archiving succeeds and roadmap is now < 500 lines:**
```
✓ Roadmap auto-archived (N items removed). Now XXX lines. Continue.
```

**If roadmap is still > 500 lines after archiving:**
```
⚠ WARNING: Roadmap is XXX lines even after auto-archiving
Manual review required. Some 🟢 items may need custom archiving.
See gco-roadmap-format.md for archiving guidelines.
Continue with caution.
```

**If 751+ lines:**
```
🛑 CRITICAL: Roadmap is XXX lines (hard limit: 750)
Cannot proceed with work. Roadmap MUST be archived below 500 lines.

Action Required:
1. Stop current work
2. Archive ALL completed (🟢) requirements to .haunt/completed/roadmap-archive.md
3. Verify roadmap is under 500 lines
4. See gco-roadmap-format.md for archiving guidelines
5. Restart session once roadmap is healthy
```

## 3. Verify Tests Pass

**CRITICAL:** If tests are broken, FIX THEM FIRST before starting new work.

Run appropriate test command for your agent type:

| Agent Type | Test Command |
|------------|--------------|
| Dev-Backend | `pytest tests/ -x -q` |
| Dev-Frontend | `npm test` |
| Dev-Infrastructure | Verify infrastructure state (no standard test command) |
| Release-Manager | Full test suite (`pytest tests/` or equivalent) |
| Others | N/A (skip this step) |

## 4. Find Your Assignment

Follow this priority order to locate your work assignment:

### Priority 1: Direct User Assignment
If the user provides an explicit assignment in their message, proceed immediately with that work. Skip the checks below.

### Priority 2: Active Work Section in CLAUDE.md
CLAUDE.md is already loaded in your context. Check the "Active Work" section:
- Look for requirements with "Agent:" field matching your agent type
- Check the status icon (⚪ Not Started, 🟡 In Progress, 🟢 Complete, 🔴 Blocked)
- Read the brief description to understand the task

### Priority 3: Project Roadmap
If Active Work is empty or has no assignment for you:
1. Read `.haunt/plans/roadmap.md`
2. Look for requirements matching your agent type with status ⚪ Not Started or 🟡 In Progress
3. If found: Update the status to 🟡 In Progress and proceed with the work
4. Note: Full requirement details and task lists are in the roadmap

### Priority 4: Ask Project Manager
If no assignment found after checking all sources above:
- STOP and explicitly ask the Project Manager for work
- Do NOT proceed without an assignment
- Do NOT assume what work needs to be done

## 5. Ready to Work

Session startup is complete when all of the following are true:
- Working directory verified (step 1)
- Git status checked and understood (step 1)
- Recent changes reviewed (step 2)
- Roadmap file size checked and within acceptable limits (step 2.5)
- Tests passing OR broken tests identified for immediate fix (step 3)
- Current assignment identified from one of:
  - Direct user assignment, OR
  - Active Work in CLAUDE.md, OR
  - Roadmap in `.haunt/plans/roadmap.md`, OR
  - Explicit "no work" state confirmed by PM

Once all steps complete, you may begin work on your assignment.

## Optional: Restore Agent Memory

For complex multi-session work requiring historical context:
```bash
recall_context("[agent-id]")
```

This is optional and typically only needed for long-running features spanning multiple sessions.
