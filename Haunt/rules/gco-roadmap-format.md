# Roadmap Format (Slim Reference)

## Requirement Structure

Every requirement MUST follow:

```markdown
### {🟡} REQ-XXX: [Action-oriented title]

**Type:** Enhancement | Bug Fix | Documentation | Research
**Reported:** YYYY-MM-DD
**Source:** [Origin]

**Description:** [What needs to be done]

**Tasks:**
- [ ] Specific task 1
- [ ] Specific task 2

**Files:**
- `path/to/file.ext` (create | modify)

**Effort:** XS | S | M | SPLIT
**Complexity:** SIMPLE | MODERATE | COMPLEX | UNKNOWN
**Agent:** [Agent type]
**Completion:** [Testable criteria]
**Blocked by:** [REQ-XXX or "None"]
```

## Status Icons

| Icon | Meaning | When to Use |
|------|---------|-------------|
| ⚪ | Not Started | Work not begun |
| 🟡 | In Progress | Agent actively working |
| 🟢 | Complete | All criteria met |
| 🔴 | Blocked | Dependency unmet |

## Sizing Rules (One Sitting Rule)

Work items MUST complete in one uninterrupted session:

| Size | Time | Files | Lines | Use For |
|------|------|-------|-------|---------|
| **XS** | 30min-1hr | 1-2 | <50 | Quick fixes, config changes |
| **S** | 1-2hr | 2-4 | 50-150 | Single component, isolated bug fix |
| **M** | 2-4hr | 4-8 | 150-300 | Multi-component feature |
| **SPLIT** | >4hr | >8 | >300 | MUST decompose immediately |

## When to Invoke Full Skill

For detailed format specifications, batch organization, dependency management, and archiving workflows:

**Invoke:** `/gco-roadmap-format` skill

The skill contains:
- Complete requirement format with all fields
- Batch organization and sequencing
- Complexity indicators (SIMPLE/MODERATE/COMPLEX/UNKNOWN)
- Active Work section management
- Archiving workflows
- File size limits and when to split

## Non-Negotiable

- NEVER create requirements without REQ-XXX numbering
- NEVER skip required fields (all fields in structure above)
- NEVER allow SPLIT-sized work (decompose first)
- NEVER exceed 500 lines in roadmap.md (archive immediately)
