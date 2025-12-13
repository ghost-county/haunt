# Status Update Protocol

## Status Icons

| Icon | Meaning | When to Use |
|------|---------|-------------|
| ⚪ | Not Started | Work not begun |
| 🟡 | In Progress | Agent actively working |
| 🟢 | Complete | All criteria met, ready to archive |
| 🔴 | Blocked | Cannot proceed, dependency unmet |

## Who Updates What

### Worker Agents (Dev, Research, Code Review)

**You update:** `.haunt/plans/roadmap.md` directly

**When to update:**
- Starting work: ⚪ → 🟡
- Blocking issue: 🟡 → 🔴 (update "Blocked by:" field)
- Task complete: Check off `- [x]` (keep 🟡 until ALL done)
- Requirement complete: 🟡 → 🟢

**You do NOT update:** CLAUDE.md Active Work section

### Project Manager Only

**You update:** Both locations

**Starting work (⚪ → 🟡):**
1. Update `.haunt/plans/roadmap.md` to 🟡
2. Add to CLAUDE.md Active Work section

**Completing work (🟡 → 🟢):**
1. Verify worker updated roadmap to 🟢
2. Remove from CLAUDE.md Active Work section
3. Archive in `.haunt/completed/roadmap-archive.md`

## Task Checkbox Updates

When completing individual tasks within a requirement:
- Update in `.haunt/plans/roadmap.md`
- Change `- [ ]` to `- [x]`
- Keep status at 🟡 until ALL tasks complete
- Only change to 🟢 when everything is done

## Active Work Section Rules

**CLAUDE.md Active Work:**
- Keep under 500 tokens
- Only current/assigned work
- PM manages exclusively

**Roadmap is authoritative** - Full details live in `.haunt/plans/roadmap.md`
