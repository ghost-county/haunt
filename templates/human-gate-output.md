# Human Review Gate Template

Use this format when presenting work for human approval at gate points.

## Template

---

### GATE: [Gate Name]

**Feature:** [1-line description]

**Files Changed:**

| File | Change Type | Lines |
|------|------------|-------|
| path/to/file | Added/Modified/Deleted | +X/-Y |

**Approach:** [1-2 sentences on implementation strategy]

**Risks:**
- Security: [none / low / medium / high] — [brief reason if not none]
- Breaking change: [yes/no] — [what breaks if yes]
- Data loss potential: [yes/no] — [what data if yes]
- Scope creep: [yes/no] — [what expanded if yes]

**Review Evidence:**
- Tests: [pass/fail, count]
- Code Review: [verdict, findings count]
- Visual Verification: [yes/no, if applicable]

**Confidence:** [HIGH / MEDIUM / LOW] — [1-line reason]

**Decision:**
- [ ] **APPROVE** — proceed to next phase
- [ ] **REJECT** — send back with reason: ___
- [ ] **DEFER** — need more info: ___

---
