# Framework Ergonomics Roadmap

> Source: n-agentic-harnesses evaluation deferred items (2026-04-04)
> Single source of truth for all work items. See `.haunt/completed/` for archived work.

---

## Current Focus

**Status:** All requirements complete. Ready to banish.

**Batch 1 (P2 — parallel):** REQ-411, REQ-412 (independent — different files)
**Batch 2 (P3):** REQ-413 (independent but lower priority)

---

## Haunt Framework

### 🟢 REQ-411: Agent Composition via Base Templates

**Type:** Enhancement
**Priority:** P2
**Size:** S
**Agent:** Dev

**Description:** Create base template files that define shared agent configuration. Update setup-haunt.sh to resolve `extends:` inheritance at deploy time, merging base tools/skills into agent definitions.

**Tasks:**
- [ ] Create `Haunt/agents/bases/base-teammate.yaml` with universal tools (TaskUpdate, TaskList, SendMessage, Read, Grep, Glob) + universal skill (gco-team-protocol)
- [ ] Create `Haunt/agents/bases/base-reviewer.yaml` extending teammate with Bash + gco-code-patterns
- [ ] Add `extends:` field to all 6 agent frontmatter; remove duplicated tools/skills from each
- [ ] Update `setup-haunt.sh` deploy section to resolve extends chains before copying
- [ ] Test: deploy, then `--verify`; compare deployed agents against pre-composition versions to confirm identical output

**Files:**
- `Haunt/agents/bases/base-teammate.yaml` (new)
- `Haunt/agents/bases/base-reviewer.yaml` (new)
- `Haunt/agents/gco-*.md` (update)
- `Haunt/scripts/setup-haunt.sh` (update)

**Effort:** S
**Blocked by:** None

---

### 🟢 REQ-412: Hook Registry in Manifest

**Type:** Enhancement
**Priority:** P2
**Size:** S
**Agent:** Dev

**Description:** Declare hooks in manifest.yaml with trigger/matcher/timeout. Update setup-haunt.sh to deploy hook scripts and generate the settings.json hook section from the manifest.

**Tasks:**
- [ ] Add `hooks:` section to `manifest.yaml` with all current hooks (7+ entries)
- [ ] Update `setup-haunt.sh` to copy hook scripts to `~/.claude/hooks/`
- [ ] Add settings.json generation from manifest hooks (merge into existing settings.json preserving non-hook keys)
- [ ] Add hook verification to `--verify` mode
- [ ] Remove static `settings.hooks.json` template
- [ ] Test: deploy, verify hooks in `~/.claude/hooks/` and settings.json match manifest

**Files:**
- `Haunt/manifest.yaml` (update)
- `Haunt/scripts/setup-haunt.sh` (update)
- `Haunt/templates/settings.hooks.json` (remove)

**Effort:** S
**Blocked by:** None

---

### 🟢 REQ-413: Skill Versioning

**Type:** Enhancement
**Priority:** P3
**Size:** S
**Agent:** Dev

**Description:** Add `version:` to skill frontmatter, create a version report script, and track versions in manifest.

**Tasks:**
- [ ] Add `version: 1.0` to all gco skill SKILL.md frontmatter
- [ ] Create `Haunt/scripts/haunt-skill-versions.sh` — compares source vs deployed versions, flags mismatches
- [ ] Add version field to manifest skill entries
- [ ] Update `haunt-doc-freshness.sh` to show version alongside last-verified date
- [ ] Test: run version report, verify it detects intentional mismatch

**Files:**
- `Haunt/skills/gco-*/SKILL.md` (update — all skills)
- `Haunt/scripts/haunt-skill-versions.sh` (new)
- `Haunt/manifest.yaml` (update)
- `Haunt/scripts/haunt-doc-freshness.sh` (update)

**Effort:** S
**Blocked by:** None

---

## Summary

| REQ | Title | Size | Status | Batch |
|-----|-------|------|--------|-------|
| REQ-411 | Agent Composition | S | ⚪ | 1 |
| REQ-412 | Hook Registry | S | ⚪ | 1 |
| REQ-413 | Skill Versioning | S | ⚪ | 2 |

**Total: 3 requirements, 2 batches**
**Team strategy:** S-sized individually → solo Dev agents in parallel
