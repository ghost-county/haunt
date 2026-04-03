# Institutional Memory Template

Add this section to your project's `.claude/CLAUDE.md` to codify project-specific lessons.

## How to Use

1. Copy the template section below into your project's CLAUDE.md
2. Add entries when agents make mistakes or when patterns emerge
3. Review quarterly — remove obsolete entries, update stale reasoning

## Codification Workflow

When an agent makes a mistake:
1. **Correct** the immediate issue
2. **Identify** whether this could recur in future sessions
3. **Codify** as an Always/Never entry with BECAUSE clause
4. **Add** to the project's CLAUDE.md Institutional Memory section

## Template

### Institutional Memory

Project-specific lessons. Each entry uses "Always/Never X BECAUSE Y" format so agents can generalize the reasoning to novel situations.

#### Always Do
<!-- Format: Always [action] BECAUSE [reason that enables generalization] -->
<!-- Example: Always use parameterized queries BECAUSE string concatenation enables SQL injection even when input looks safe -->

#### Never Do
<!-- Format: Never [action] BECAUSE [reason that enables generalization] -->
<!-- Example: Never import from src/legacy/ BECAUSE those modules were superseded in v3.0 and will be removed -->

#### Named Anti-Patterns
<!-- Name recurring failures for quick knowledge activation -->
<!-- Format: **[Pattern Name]** — [description]. Detected: [date]. Fix: [what to do instead]. BECAUSE: [why this matters for THIS project] -->
