# Monorepo Roadmap

> Single source of truth for all project work items. See `.haunt/completed/` for archived work.

---

## Current Focus

**Batch:** Ralph Wiggum Dev Integration (4 requirements)
**Status:** Complete

| REQ | Title | Effort | Blocked By |
|-----|-------|--------|------------|
| REQ-408 | Create /ralph-req command definition | XS | None |
| REQ-409 | Create ralph-req.sh script | S | REQ-408 |
| REQ-410 | Add Ralph loop awareness to dev agent | XS | None |
| REQ-411 | Create gco-ralph-dev skill | S | REQ-410 |

---

## Cross-Project Work

*Requirements affecting multiple projects go here.*

---

## Haunt Framework

*Haunt agent framework and SDLC tooling.*

### Batch: Ralph Wiggum Dev Integration

### 🟢 REQ-408: Create /ralph-req command definition

**Type:** Enhancement
**Reported:** 2026-01-07
**Source:** Plan: Ralph Wiggum Integration
**Description:** Create the command definition file for /ralph-req that starts persistent dev work on a requirement using the Ralph Wiggum iteration loop.

**Tasks:**
- [x] Create `Haunt/commands/ralph-req.md` with YAML frontmatter
- [x] Define usage syntax: `/ralph-req REQ-XXX [--max-iterations N]`
- [x] Document workflow steps (read requirement, extract criteria, initialize loop)
- [x] Document completion promise protocol (`<promise>ALL_CRITERIA_VERIFIED</promise>`)

**Files:**
- `Haunt/commands/ralph-req.md` (created - 317 lines)

**Effort:** XS
**Complexity:** SIMPLE
**Agent:** gco-dev-infrastructure
**Completion:** Command file exists with proper YAML frontmatter, usage syntax, and workflow documentation
**Blocked by:** None
**Completed:** 2026-01-07

---

### 🟢 REQ-409: Create ralph-req.sh script

**Type:** Enhancement
**Reported:** 2026-01-07
**Source:** Plan: Ralph Wiggum Integration
**Description:** Create the bash script that extracts requirement from roadmap, validates size (XS/S/M), and invokes the Ralph loop with derived prompt and completion promise.

**Tasks:**
- [x] Create `Haunt/scripts/ralph-req.sh` with shebang and execute permissions
- [x] Implement requirement extraction from `.haunt/plans/roadmap.md`
- [x] Implement size validation (XS/S/M, error on SPLIT)
- [x] Set max iterations based on size (30 for XS, 50 for S, 75 for M)
- [x] Extract completion criteria from requirement
- [x] Build prompt with TDD workflow and completion rules
- [x] Include `<blocked>REASON</blocked>` exit protocol in prompt

**Files:**
- `Haunt/scripts/ralph-req.sh` (created - 345 lines)

**Effort:** S
**Complexity:** MODERATE
**Agent:** gco-dev-infrastructure
**Completion:** Script executes, validates size correctly, and outputs proper prompt for Ralph loop invocation
**Blocked by:** REQ-408
**Completed:** 2026-01-07

---

### 🟢 REQ-410: Add Ralph loop awareness to dev agent

**Type:** Enhancement
**Reported:** 2026-01-07
**Source:** Plan: Ralph Wiggum Integration
**Description:** Add a section to the dev agent character sheet describing behavior when running in a Ralph loop, including promise protocol, blocked protocol, and iteration awareness.

**Tasks:**
- [x] Add "Ralph Loop Mode" section to `Haunt/agents/gco-dev.md`
- [x] Document promise protocol (only output when TRUE)
- [x] Document blocked protocol (`<blocked>REASON</blocked>` for genuine blocks)
- [x] Document iteration awareness (check git log and file state)
- [x] Add gco-ralph-dev to skills list

**Files:**
- `Haunt/agents/gco-dev.md` (modified)

**Effort:** XS
**Complexity:** SIMPLE
**Agent:** gco-dev-infrastructure
**Completion:** Dev agent file contains Ralph Loop Mode section with all four protocol elements documented
**Blocked by:** None
**Completed:** 2026-01-07

---

### 🟢 REQ-411: Create gco-ralph-dev skill

**Type:** Enhancement
**Reported:** 2026-01-07
**Source:** Plan: Ralph Wiggum Integration
**Description:** Create detailed skill reference for Ralph loop dev work, covering when to use loops, completion criteria mapping, smart exit patterns, and iteration best practices.

**Tasks:**
- [x] Create `Haunt/skills/gco-ralph-dev/SKILL.md` directory and file
- [x] Document when to use Ralph loops for dev work (XS/S only)
- [x] Document completion criteria to promise mapping
- [x] Document smart exit vs blocked signaling
- [x] Document iteration best practices (check previous work, avoid loops)

**Files:**
- `Haunt/skills/gco-ralph-dev/SKILL.md` (created - 581 lines)

**Effort:** S
**Complexity:** MODERATE
**Agent:** gco-dev-infrastructure
**Completion:** Skill file exists with all four documentation sections, follows YAML frontmatter format
**Blocked by:** REQ-410
**Completed:** 2026-01-07

---

## TrueSight

*ADHD productivity dashboard.*

---

## Familiar

*Personal command center and knowledge management.*

---

## Summary

| Project | ⚪ | 🟡 | 🟢 |
|---------|---|---|---|
| Cross-Project | 0 | 0 | 0 |
| Haunt | 4 | 0 | 0 |
| TrueSight | 0 | 0 | 0 |
| Familiar | 0 | 0 | 0 |
| **Total** | 4 | 0 | 0 |

**Archived:** 76 requirements → See `.haunt/completed/`

---

## Recent Archives

- **2026-01-07:** Git Workflow Integration (7 requirements) → `roadmap-archive.md`
- **2026-01-06:** Mandatory Solution Critique (4 requirements) → `mandatory-solution-critique.md`
- **2026-01-06:** Haunt Manifest System (1 requirement) → `roadmap-archive.md`
- **2026-01-05:** Repository Cleanup Batch (8 requirements) → `repo-cleanup-batch.md`
- **2026-01-05:** Damage Control Hooks (7 requirements) → `damage-control-hooks.md`
- **2026-01-05:** Secrets Management Core (6 requirements) → `secrets-management-batch1.md`
- **2026-01-05:** Skill Compression Seance (15 requirements) → `skill-compression-seance.md`
- **2026-01-03:** Various batches (28 requirements) → See `2026-01/`
