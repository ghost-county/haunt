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
4. **Check for story file** (see Story File Loading below)
5. Use `recall_context("[agent-id]-[req-id]")` if feature is complex
6. Read implementation notes in roadmap entry
7. Continue from first unchecked task

**Never start new features with WIP in progress.**

## Story File Loading

**When to check:** After assignment identification, before starting work.

**Workflow:**
1. Extract REQ-XXX from assignment (e.g., "Implement REQ-224" → REQ-224)
2. Check if `.haunt/plans/stories/REQ-XXX-story.md` exists
3. If story file exists:
   - Read entire story file for implementation context
   - Pay special attention to:
     - **Implementation Approach**: Technical strategy and component breakdown
     - **Code Examples & References**: Similar patterns in codebase
     - **Known Edge Cases**: Scenarios to handle and error conditions
     - **Session Notes**: Progress from previous sessions, gotchas discovered
4. If no story file:
   - Normal for XS-S sized work
   - Proceed with roadmap completion criteria and task list

**Story files supplement (not replace) roadmap:**
- Roadmap has: title, tasks, completion criteria, file list
- Story file adds: technical context, approach details, code examples, edge cases
- Both are needed for complete understanding

**When story files are most helpful:**
- M-sized requirements spanning multiple sessions
- Complex features with architectural decisions
- Multi-component changes requiring coordination
- Work resumed after context compaction or long gap
- Features with known gotchas from previous attempts

**Example workflow:**
```bash
# Assignment: Implement REQ-224
# 1. Check for story file
ls .haunt/plans/stories/REQ-224-story.md

# 2. If exists, read it
cat .haunt/plans/stories/REQ-224-story.md

# 3. Use story context + roadmap to start work
# Story tells you HOW to implement
# Roadmap tells you WHAT to implement
```

## Agent Memory Best Practices

### When to Recall Context

Use `recall_context("[agent-type]")` when:

**Multi-session work:**
- Resuming M-sized requirements that span multiple sessions
- Continuing features started in previous sessions (>24 hour gap)
- Work with complex implementation history requiring prior context

**Complex debugging:**
- Debugging issues that span multiple investigation sessions
- Troubleshooting problems requiring knowledge of previous failed attempts
- Root cause analysis that builds on prior research findings

**Cross-agent handoffs:**
- Receiving work from another agent type (e.g., Dev receives from Research)
- Coordinating features requiring multiple agent specializations
- Understanding context from previous agent's decisions or discoveries

**Example workflow:**
```bash
# At session startup, after verifying assignment
recall_context("dev-backend")

# Review recalled context for:
# - Previous implementation decisions
# - Known blockers or gotchas
# - Partial work from last session
# - Cross-references to related requirements

# Proceed with work using historical context
```

### When to Skip Memory

Do NOT use `recall_context()` when:

**Simple, self-contained work:**
- S-sized tasks completable in single session
- Straightforward bug fixes with clear root cause
- New features with no dependency on prior sessions

**Clear requirements:**
- All context needed is documented in roadmap
- Acceptance criteria and tasks are self-explanatory
- No ambiguity about implementation approach

**Fresh starts:**
- Starting new feature with no prior attempts
- Clean-slate work with no historical context
- Requirements explicitly state "ignore previous approaches"

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
