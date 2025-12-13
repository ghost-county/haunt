---
name: gco-session-startup
description: Advanced session initialization guidance for complex scenarios. For basic startup protocol, see `.claude/rules/gco-session-startup.md`.
---

# Session Startup Skill

## Purpose

Advanced session initialization guidance for edge cases and complex scenarios.

**For standard startup protocol**, see `.claude/rules/gco-session-startup.md` (enforced automatically).

## When to Invoke

- When resuming work after extended context loss or session interruption
- When dealing with complex multi-session feature work
- When troubleshooting startup issues or broken test states
- When initialization appears unclear or ambiguous

## Context Management (SDK Integration)

Claude Code's Agent SDK provides automatic context management. Understanding the division of responsibility helps optimize session startup:

### Automatic (SDK Handles)
- **Context compaction:** Automatically triggered when approaching token limits
- **CLAUDE.md caching:** 60-minute TTL ensures fast repeated access
- **Session continuity:** Summarization maintains conversation flow across context boundaries

### Manual (You Handle)
- **Assignment verification:** Check Active Work or roadmap for current tasks
- **Test validation:** Verify tests pass before starting new work (critical path)
- **Agent memory usage:** Explicitly invoke `recall_context()` for multi-session features
- **Broken state recovery:** Fix failing tests immediately, don't skip validation

## Complex Scenario Handling

### Scenario: Tests Failing on Startup

**Problem:** Test suite broken from previous session or recent changes.

**Resolution:**
1. Identify failing test(s) with full output: `pytest tests/ -v`
2. Review recent commits for potential breakage: `git diff HEAD~3..HEAD`
3. Fix tests BEFORE starting assigned work (non-negotiable)
4. Verify fix with full suite run
5. Document fix in commit if changes required

**Never skip this step.** Broken tests indicate unstable foundation.

### Scenario: No Clear Assignment After Full Lookup

**Problem:** Checked all sources (Direct → Active Work → Roadmap) but no work found.

**Resolution:**
1. Verify you checked ALL sources:
   - User's direct message (explicit task assignment)
   - CLAUDE.md Active Work section (your agent type)
   - `.haunt/plans/roadmap.md` (⚪ or 🟡 status, your domain)
2. If truly no assignment: STOP and explicitly ask PM
3. Include context: "Checked Active Work and roadmap, no assignments for [agent-type]"

**Do not assume** what work needs doing. PM coordinates priorities.

### Scenario: Multiple Potential Assignments

**Problem:** Roadmap shows several ⚪ requirements in your domain.

**Resolution:**
1. Check `Blocked by:` field for each - skip blocked items
2. Prefer items at top of current focus section (higher priority)
3. Check effort estimate - prefer S over M for session boundaries
4. If still ambiguous: Ask PM which to prioritize
5. Update chosen requirement to 🟡 and proceed

### Scenario: Resuming Mid-Feature Work

**Problem:** Previous session left feature partially complete.

**Resolution:**
1. Find feature in roadmap (should be 🟡 In Progress)
2. Review unchecked tasks in task list
3. Check `git diff` for uncommitted WIP
4. Use `recall_context("[agent-id]-[req-id]")` if feature is complex
5. Read implementation notes in roadmap entry
6. Continue from first unchecked task

**Never start new features with WIP in progress.**

## Agent Memory Best Practices

### When to Use `recall_context()`

**Use for:**
- Multi-session features (>1 day of work)
- Complex architectural decisions requiring historical rationale
- Features with cross-agent coordination history
- Work resuming after >24 hour gap

**Skip for:**
- Single-session tasks
- Simple bug fixes
- Well-documented requirements in roadmap
- Fresh features with no prior context

### Storage Pattern

After significant progress or insights:
```bash
store_memory(
  content="[Key decisions, gotchas, next steps]",
  category="dev-[backend|frontend|infra]",
  tags=["session", "REQ-XXX", "feature-name"]
)
```

## Success Criteria

Advanced startup complete when:
- Edge case handled (broken tests fixed, ambiguous assignment resolved, etc.)
- Context restored for complex multi-session work (if applicable)
- Ready to proceed with clear assignment and stable foundation
- Understand why basic protocol was insufficient (learning for future sessions)
