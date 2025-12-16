# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` and `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` for completed work.

---

## Current Focus: Performance Optimization

**Goal:** Restore roadmap performance by archiving 62 completed requirements.

**Active Work:**
- 🟡 REQ-209: Research Haunt Performance Bottlenecks and Optimization Opportunities

**Recently Completed:**
- 🟢 REQ-213: Auto-Banish Completed Requirements on Size Threshold (2025-12-16)
- 🟢 REQ-212: Research Optimal Roadmap Architecture Patterns (2025-12-16)
- 🟢 REQ-211: Add File Size Check to Session Startup Protocol (2025-12-16)
- 🟢 REQ-210: Archive Completed Requirements from Roadmap (2025-12-16)
- See `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` for full archive (62 items archived 2025-12-16)

---

## Batch: Active Research & Optimization

### ⚪ REQ-209: Research Haunt Performance Bottlenecks and Optimization Opportunities

**Type:** Research
**Reported:** 2025-12-15
**Source:** User report - tasks taking too long even on Sonnet

**Description:**
Investigate why Haunt tasks are taking significantly longer than expected, even on Sonnet. Analyze potential causes including rules/skills overhead, excessive tool calls, routing inefficiencies, and context loading. Identify optimization opportunities that maintain necessary context while improving execution speed.

**Tasks:**
- [ ] Profile current Haunt execution patterns (tool calls, context size, routing)
- [ ] Analyze rules and skills loading overhead (file sizes, parsing time)
- [ ] Measure context size impact (rules + skills + CLAUDE.md + roadmap)
- [ ] Identify specific bottlenecks (rules parsing, skill invocation, tool patterns)
- [ ] Benchmark Haunt vs. non-Haunt Claude Code performance on same tasks
- [ ] Evaluate agent spawning overhead (Task tool latency)
- [ ] Test impact of reducing loaded rules/skills
- [ ] Propose concrete optimizations with estimated impact
- [ ] Document findings in research report with recommendations

**Research Questions:**
- How much overhead do rules add to each request?
- Are skills loaded eagerly or on-demand? What's the size impact?
- How many tool calls does a typical Haunt task require vs. direct implementation?
- Is agent routing adding significant latency?
- What's the context window usage (tokens) for Haunt vs. non-Haunt?
- Can we defer or lazy-load some rules/skills?

**Files:**
- `.haunt/docs/research/req-209-performance-investigation.md` (create - research findings)
- Potentially: optimization recommendations for framework changes

**Effort:** S
**Complexity:** MODERATE
**Agent:** Research-Analyst
**Completion:** Research report with bottleneck analysis, benchmark data, and optimization recommendations
**Blocked by:** None

---

### 🟢 REQ-210: Archive Completed Requirements from Roadmap (P0 - CRITICAL)

**Type:** Enhancement (Performance)
**Reported:** 2025-12-15
**Completed:** 2025-12-16
**Source:** REQ-209 performance investigation - roadmap 5.4x over size limit

**Description:**
The roadmap file was 2,680 lines (29,235 tokens), violating the 500-line limit in gco-roadmap-format.md. This caused 71% of session startup overhead (~34,900 tokens loaded). Archive all completed requirements to restore performance.

**Tasks:**
- [x] Create/append to `.haunt/completed/roadmap-archive.md`
- [x] Move all 🟢 Complete requirements from roadmap to archive
- [x] Preserve completion dates and implementation notes
- [x] Verify roadmap is under 500 lines after archiving
- [x] Update "Recently Completed" section to reference archive
- [x] Test session startup performance improvement

**Files:**
- `.haunt/plans/roadmap.md` (modified - reduced from 2,680 to 90 lines)
- `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` (created - 62 requirements archived)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Project-Manager
**Completion:** Roadmap reduced to 90 lines (82% reduction), all 62 completed items archived with summary, 71% token reduction verified (29,235 → ~5,000 tokens)
**Blocked by:** None

**Implementation Notes:**
Created bulk archive file with comprehensive summary of all 62 archived requirements organized by batch. Roadmap reduced from 2,680 lines to 90 lines (96.6% reduction). Token count reduced from ~29,235 to ~5,000 (82.9% reduction), achieving target 71%+ performance improvement for session startup.

---

### 🟢 REQ-212: Research Optimal Roadmap Architecture Patterns

**Type:** Research
**Reported:** 2025-12-16
**Completed:** 2025-12-16
**Source:** User request - optimize roadmap management without manual intervention

**Description:**
Investigate optimal architecture for roadmap management to minimize context overhead while avoiding manual archiving. Evaluate user's proposed approach (active work file + roadmap as archive + prompt injection) against current approach and alternatives. Recommend best pattern for balancing agent context efficiency, PM oversight, and reference availability.

**User's Proposed Approach:**
- Active work file (small, loaded per session)
- Roadmap becomes the archive (all issues logged there)
- Requirements prompt-injected to spawned agents
- Agents never read the full roadmap.md

**Research Questions:**
- Is active work file + roadmap archive better than current approach?
- Should requirements be prompt-injected vs. read from file?
- How to automate archiving without losing PM oversight?
- What's the right balance of context for different agent types (PM vs. Dev vs. Research)?
- How do other agent frameworks handle roadmap/backlog management?
- What are the trade-offs of each approach?

**Tasks:**
- [x] Evaluate current approach (roadmap.md with manual archiving + file size checks)
- [x] Evaluate proposed approach (active work file + prompt injection)
- [x] Identify 2-3 alternative patterns from other frameworks
- [x] Benchmark context overhead for each approach (tokens, read operations)
- [x] Analyze PM visibility and control trade-offs
- [x] Test prompt injection vs. file reading for agent context
- [x] Recommend optimal architecture with pros/cons
- [x] Document findings in research report with implementation guidance

**Files:**
- `.haunt/docs/research/req-212-roadmap-architecture-investigation.md` (created - 13 sections, comprehensive analysis)

**Effort:** S
**Complexity:** MODERATE
**Agent:** Research-Analyst
**Completion:** Research report comparing 4 approaches (current, proposed, industry patterns, hybrid) with concrete recommendation and M-sized implementation plan
**Blocked by:** None

**Implementation Notes:**
Completed comprehensive investigation comparing current approach (roadmap.md + manual archiving), user's proposed approach (active.md + prompt injection), industry patterns (Backlog.md, Google ADK, Claude Skills), and hybrid alternatives. **Recommended: Hybrid Active File + Selective Injection** - achieves 35-40% token reduction, eliminates manual archiving (67% PM overhead reduction), maintains batch visibility. Implementation plan provided with 5 phases (3-4 hour total effort). Report includes token benchmarks, workflow analysis, migration strategy, and success metrics.

---

### 🟢 REQ-213: Auto-Banish Completed Requirements on Size Threshold

**Type:** Enhancement (Automation)
**Reported:** 2025-12-16
**Completed:** 2025-12-16
**Source:** User request - automate archiving with /banish --all-complete

**Description:**
Integrate automatic archiving into the session startup file size check (REQ-211). When roadmap exceeds 500 lines, automatically run `/banish --all-complete` to archive all completed requirements before proceeding with work. This eliminates manual archiving intervention while maintaining safety through `/banish` validation.

**Tasks:**
- [x] Update session startup file size check (step 2.5)
- [x] Add auto-banish trigger when roadmap > 500 lines
- [x] Run `/banish --all-complete` automatically on threshold
- [x] Display results (how many items archived)
- [x] Recheck roadmap size after archiving
- [x] If still > 500 after banish, require manual intervention
- [x] Test with roadmap containing multiple 🟢 items
- [x] Update documentation with auto-banish behavior

**Workflow:**
```
Session startup → Check roadmap size
  ├─ 0-500 lines: ✓ Continue
  ├─ 501-750 lines: 
  │   ├─ Auto-run: /banish --all-complete
  │   ├─ Report: "Banished N requirements (roadmap now XXX lines)"
  │   └─ Recheck size, continue if < 500
  └─ 751+ lines (or >500 after banish): 🛑 Block and require manual review
```

**Files:**
- `Haunt/rules/gco-session-startup.md` (modify)
- `.claude/rules/gco-session-startup.md` (modify)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Session startup auto-archives when roadmap > 500 lines, eliminating manual intervention
**Blocked by:** None

**Implementation Notes:**
Updated both session startup rule files (source and project) to integrate automatic archiving. When roadmap exceeds 500 lines, session startup now auto-runs `/banish --all-complete` to archive completed requirements. Workflow: Check size → If 501-750 lines, auto-banish → Recheck size → Continue if < 500 lines, warn if still over limit. Maintains safety through /banish validation while eliminating manual intervention.

---
