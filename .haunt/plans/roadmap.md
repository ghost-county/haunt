# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` and `.haunt/completed/roadmap-bulk-archive-2025-12-16.md` for completed work.

---

## Current Focus: Framework Improvements

**Active Work:**
- None (all current work complete!)

**Recently Completed (2025-12-30 - Archived):**
- 🟢 REQ-262: Add Quiet Mode as Default (Setup Scripts)
- 🟢 REQ-263: Add Optional Playwright MCP Installation Prompt (Setup Scripts)
- 🟢 REQ-243: Fix Windows slash commands bug (Commands)
- 🟢 REQ-259: Remove Project Rule Duplication (Token Efficiency)
- 🟢 REQ-260: Convert Heavy Rules to Skills (Token Efficiency) - 84.6% reduction
- 🟢 REQ-261: Add Targeted Read Training to Agents (Token Efficiency)
- 🟢 REQ-264: Consolidate Overlapping Rules (Token Efficiency)
- 🟢 REQ-265: Add Delegation Protocol to Orchestrator Skill (Token Efficiency)
- 🟢 REQ-269: Lightweight Metrics Framework (Determinism)
- 🟢 REQ-270: Structured Git Operations Wrapper (Determinism)
- 🟢 REQ-271: Structured Build/Test Execution Wrapper (Determinism)
- 🟢 REQ-272: Phase Gates for TDD Workflow (Determinism)
- 🟢 REQ-273: Phase Gates for Séance Orchestration (Determinism)
- See `.haunt/completed/roadmap-archive.md` for full archive

---

## Backlog: BMAD-Inspired Enhancements

Phase 1 - Quick Wins (5 requirements, ~10 hours):
⚪ REQ-228: Create Séance Workflow Infographic (Agent: Dev-Infrastructure, S)
⚪ REQ-229: Create Agent Coordination Diagram (Agent: Dev-Infrastructure, S)
⚪ REQ-230: Create Session Startup Protocol Diagram (Agent: Dev-Infrastructure, S)
⚪ REQ-231: Implement /haunt status --batch Command (Agent: Dev-Infrastructure, M)
⚪ REQ-232: Add Effort Estimation to Batch Status (Agent: Dev-Infrastructure, S, blocked by REQ-231)

Phase 2 - Medium Effort (5 requirements, ~22 hours):
⚪ REQ-225: Add /seance --quick Mode (Agent: Dev-Infrastructure, S)
⚪ REQ-226: Add /seance --deep Mode (Agent: Dev-Infrastructure, M)
⚪ REQ-227: Update Séance Skill with Mode Selection (Agent: Dev-Infrastructure, S, blocked by REQ-225/226)
⚪ REQ-223: Create /story Command (Agent: Dev-Infrastructure, M)
⚪ REQ-224: Update Dev Agent Startup to Load Story Files (Agent: Dev-Infrastructure, S, blocked by REQ-223)

Phase 3 - High Impact (3 requirements, ~14 hours):
⚪ REQ-220: Implement Batch-Specific Roadmap Sharding (Agent: Dev-Infrastructure, M)
⚪ REQ-221: Update Session Startup to Load Active Batch Only (Agent: Dev-Infrastructure, S, blocked by REQ-220)
⚪ REQ-222: Archive Completed Batches Automatically (Agent: Dev-Infrastructure, M, blocked by REQ-220)

---

## Backlog: GitHub Integration

⚪ REQ-205: GitHub Issues Integration (Research-Analyst → Dev-Infrastructure)
⚪ REQ-206: Create /bind Command (Dev-Infrastructure)

---

## Backlog: Token Efficiency

### ⚪ REQ-274: Structured Roadmap Lookup Wrapper

**Type:** Enhancement
**Reported:** 2025-12-30
**Source:** User idea - reduce context when agents look up assignments

**Description:**
Create a `haunt-roadmap` wrapper (similar to `haunt-git` and `haunt-run`) that lets dev agents look up their specific requirements without reading the entire roadmap file. Returns structured JSON with just the requirement details they need.

**Example Usage:**
```bash
haunt-roadmap get REQ-274          # Get specific requirement as JSON
haunt-roadmap list --status=🟡     # List in-progress requirements
haunt-roadmap list --agent=Dev-Backend  # List requirements for agent type
haunt-roadmap my-work              # Show requirements assigned to caller's agent type
```

**Structured Output:**
```json
{
  "id": "REQ-274",
  "title": "Structured Roadmap Lookup Wrapper",
  "status": "⚪",
  "type": "Enhancement",
  "effort": "S",
  "agent": "Dev-Infrastructure",
  "blocked_by": null,
  "tasks": ["task1", "task2"],
  "completion": "Completion criteria here"
}
```

**Tasks:**
- [ ] Create `Haunt/scripts/haunt-roadmap.sh` wrapper
- [ ] Implement `get REQ-XXX` subcommand (grep + parse to JSON)
- [ ] Implement `list` with status/agent filters
- [ ] Implement `my-work` for quick agent lookup
- [ ] Handle requirement not found gracefully
- [ ] Update `gco-session-startup.md` to reference wrapper
- [ ] Test with current roadmap format

**Files:**
- `Haunt/scripts/haunt-roadmap.sh` (create)
- `Haunt/rules/gco-session-startup.md` (modify)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:** Agents can call `haunt-roadmap get REQ-XXX` and receive JSON; no full roadmap reads needed for assignment lookup
**Blocked by:** None

---

**Low Priority Items:**
⚪ REQ-248: Story Files for M-Sized Features (M, RICE: 63)
⚪ REQ-251: Add Haunt Reinstall Prompt to Seance (M)
⚪ REQ-249: Roadmap Sharding (M) - LOW PRIORITY
⚪ REQ-250: Adaptive Workflow Modes (M) - LOW PRIORITY

---

## Backlog: Interactive Prompts

🟢 REQ-245: Interactive dependency prompts - COMPLETE (M)

---
