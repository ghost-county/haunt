# Skills Quick Reference

Quick reference table for all workflow skills in the Ghost County framework.

## Workflow Skills

| Skill Name | Purpose | When to Invoke | Triggers |
|------------|---------|----------------|----------|
| **roadmap-workflow** | Session workflow for agents working with roadmaps - startup checks, roadmap usage, archiving, and batch organization. | Starting sessions, checking assignments, completing work, organizing phases into batches. | "session start", "check roadmap", "archive completed", "organize batches", work coordination |
| **commit-conventions** | Standardized commit message format and branch naming conventions for agent teams. | Creating commits, naming branches, preparing git operations. | "commit", "commit message", "branch name", "git commit", version control |
| **feature-contracts** | Defines immutable feature contract rules and what agents can/cannot modify in feature-contract.json files. | Working with acceptance criteria, marking features complete, updating implementation status. | "feature contract", "acceptance criteria", "immutable", contract work |
| **code-patterns** | Anti-pattern detection and error handling conventions for code quality. | Reviewing code, handling errors, validating quality, checking for coding mistakes. | "error handling", "anti-pattern", "code quality", "code smell", "bad practice" |
| **session-startup** | Generic session initialization checklist for all agent types. | At session start or when initializing agent context. | "session start", "initialization", agent setup |
| **tdd-workflow** | Test-driven development workflow guidance following Red-Green-Refactor cycle. | Implementing new features, writing tests, following TDD practices. | "tdd", "test-driven", "write tests", testing workflow |
| **context7-usage** | Guidance on when and how to use Context7 for official documentation lookup. | Needing framework docs, API references, or library documentation. | "context7", "documentation", "docs", "API reference" |

## How to Use This Reference

1. **Finding the Right Skill**: Scan the Triggers column for keywords related to your current task.
2. **Reading Full Skill**: See the Skills/ directory for complete skill documentation with examples and detailed guidance.
3. **Invoking Skills**: Agents can read skills on-demand using the Read tool when needed during work.

## See Also

- **Full Skill Definitions**: `Haunt/skills/gco-[skill-name]/SKILL.md`
- **Agent Definitions**: `Haunt/agents/` (references these skills)
- **Framework README**: `Haunt/README.md` (architecture overview)

## Skills Directory Structure

```
Haunt/skills/
├── gco-roadmap-workflow/SKILL.md
├── gco-commit-conventions/SKILL.md
├── gco-feature-contracts/SKILL.md
├── gco-code-patterns/SKILL.md
├── gco-session-startup/SKILL.md
├── gco-tdd-workflow/SKILL.md
├── gco-context7-usage/SKILL.md
├── gco-pattern-defeat/SKILL.md
├── gco-seance/SKILL.md
├── gco-witching-hour/SKILL.md
├── gco-coven-mode/SKILL.md
├── gco-task-decomposition/SKILL.md
└── gco-playwright-tests/SKILL.md
```

## Quick Navigation

- **Need to start a session?** → session-startup
- **Need to commit code?** → commit-conventions
- **Reviewing code quality?** → code-patterns
- **Working with requirements?** → feature-contracts, roadmap-workflow
- **Writing tests?** → tdd-workflow
- **Looking up documentation?** → context7-usage
