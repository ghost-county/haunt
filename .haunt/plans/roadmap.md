# Monorepo Roadmap

> Single source of truth for all project work items. See `.haunt/completed/` for archived work.

---

## Current Focus

**Status:** All requirements complete. Roadmap clear.

Run `/seance` to start new work.

---

## Cross-Project Work

*Requirements affecting multiple projects go here.*

---

## Haunt Framework

*Haunt agent framework and SDLC tooling.*

### 🟢 REQ-381: Create gco-secure-coding Skill

**Type:** Enhancement
**Reported:** 2026-01-20
**Source:** User planning session
**Description:** On-demand security skill providing production security patterns for TypeScript/Python. Adapts TikiTribe framework (agent security, AI security, OWASP) into single skill with keyword auto-suggest.

**Tasks:**
- [x] Create skill file with YAML frontmatter and auto-suggest keywords
- [x] Add Agent Security section (tool validation, permission boundaries, output validation)
- [x] Add AI Security section (prompt injection, input sanitization)
- [x] Add OWASP/Web Security section and checklist

**Files:**
- `Haunt/skills/gco-secure-coding/SKILL.md` (created)

**Effort:** S
**Complexity:** SIMPLE
**Agent:** Dev-Backend
**Completion:** Skill deploys via setup-haunt.sh --verify; provides security patterns without blocking local dev
**Blocked by:** None

**Completed:** 2026-01-20
**Implementation Notes:**
- Created comprehensive skill with 13 security patterns (Do/Don't/Why format)
- 4 main sections: Agent Security, AI Security, Web Security (OWASP), Quick Checklist
- 13 TypeScript + 13 Python code examples
- Auto-suggest keywords in description trigger on production, deploy, auth, security, payments, PII, public API
- Deployed to ~/.claude/skills/gco-secure-coding/ via setup-haunt.sh
- Verified all patterns follow Do/Don't/Why/code example format

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
| Haunt | 0 | 0 | 1 |
| TrueSight | 0 | 0 | 0 |
| Familiar | 0 | 0 | 0 |
| **Total** | 0 | 0 | 1 |

**Archived:** 84 requirements → See `.haunt/completed/`

---

## Recent Archives

- **2026-01-08:** Context Rot Improvements + Ralph Wiggum Integration (8 requirements) → `2026-01-08-context-rot-and-ralph.md`
- **2026-01-07:** Git Workflow Integration (7 requirements) → `roadmap-archive.md`
- **2026-01-06:** Mandatory Solution Critique (4 requirements) → `mandatory-solution-critique.md`
- **2026-01-06:** Haunt Manifest System (1 requirement) → `roadmap-archive.md`
- **2026-01-05:** Repository Cleanup Batch (8 requirements) → `repo-cleanup-batch.md`
- **2026-01-05:** Damage Control Hooks (7 requirements) → `damage-control-hooks.md`
- **2026-01-05:** Secrets Management Core (6 requirements) → `secrets-management-batch1.md`
- **2026-01-05:** Skill Compression Seance (15 requirements) → `skill-compression-seance.md`
- **2026-01-03:** Various batches (28 requirements) → See `2026-01/`
