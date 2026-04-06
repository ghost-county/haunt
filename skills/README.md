# Ghost County Skills

This directory contains skills specific to the **Ghost County** (Haunt) methodology for building and operating autonomous AI agent teams.

## Skills Overview

| Skill | Purpose | Triggers |
|-------|---------|----------|
| **requirements-development** | Transform ideas into formal requirements (Phase 1) | "new feature", "I want to build", "requirements for" |
| **requirements-analysis** | Strategic analysis with business frameworks (Phase 2) | "analyze requirements", "prioritize features", "RICE score" |
| **roadmap-creation** | Atomic breakdown and roadmap integration (Phase 3) | "create roadmap", "add to roadmap", "plan implementation" |
| **session-startup** | Session initialization checklist for all agent types | "session start", "initialization" |
| **roadmap-planning** | Structured roadmap format with batches and dependencies | "create roadmap", "plan sprint", "batch planning" |
| **roadmap-workflow** | Session workflow for agents working with roadmaps | "check roadmap", "archive completed" |
| **requirements-rubric** | Framework for atomic, actionable requirements (REQ-XXX) | "write requirement", "create task", "user story" |
| **feature-contracts** | Immutable feature contract rules and acceptance criteria | "feature contract", "acceptance criteria" |
| **tdd-workflow** | Test-driven development with Red-Green-Refactor | "tdd", "test-driven", "write tests" |
| **code-patterns** | Anti-pattern detection and error handling conventions | "anti-pattern", "code quality", "code smell" |
| **code-review** | Structured code review checklist with quality gates | "review this code", "PR review", "code review" |
| **commit-conventions** | Standardized commit messages and branch naming | "commit", "commit message", "branch name" |
| **pattern-defeat** | TDD framework for defeating recurring patterns | "pattern", "recurring issue", "defeat test" |
| **weekly-refactor** | 2-3 hour weekly ritual for continuous improvement | "weekly refactor", "maintenance ritual" |
| **context7-usage** | When and how to use Context7 for documentation lookup | "context7", "documentation", "docs", "API reference" |

## Skill Categories

### Idea-to-Roadmap Workflow (Project Manager)
The 3-phase workflow for transforming ideas into actionable work:

1. `requirements-development` - **Phase 1:** 14-dimension rubric, formal REQ-XXX format
2. `requirements-analysis` - **Phase 2:** JTBD, Kano, Porter, VRIO, SWOT, RICE scoring
3. `roadmap-creation` - **Phase 3:** Break down L/XL, batch by dependency, assign agents

### Workflow & Planning
- `session-startup` - Start every session right
- `roadmap-planning` - Structure work for agent teams
- `roadmap-workflow` - Daily roadmap operations

### Requirements & Contracts
- `requirements-rubric` - Write clear, testable requirements
- `feature-contracts` - Lock acceptance criteria

### Development Practices
- `tdd-workflow` - Test-first development
- `code-patterns` - Quality conventions
- `code-review` - Review checklist
- `commit-conventions` - Git standards
- `context7-usage` - Look up library documentation

### Continuous Improvement
- `pattern-defeat` - Eliminate recurring issues
- `weekly-refactor` - Regular maintenance ritual

## Usage

Skills are invoked automatically by Claude Code when their trigger phrases are detected, or can be invoked manually:

```
/skill requirements-development
/skill requirements-analysis
/skill roadmap-creation
```

## Project Manager Workflow

When you give the Project Manager an idea:

```
User: "I want to add user authentication"
         │
         ▼
┌─────────────────────────────────────┐
│  CHECKPOINT: Understanding          │
│  PM explains back what it heard,    │
│  asks: Review each step or run      │
│  through to roadmap?                │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  PHASE 1: requirements-development  │
│  Output: requirements-document.md   │
│  [If review mode: pause]            │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  PHASE 2: requirements-analysis     │
│  Output: requirements-analysis.md   │
│  [If review mode: pause]            │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  PHASE 3: roadmap-creation          │
│  Output: roadmap.md (appended)      │
│  [Always: present summary]          │
└─────────────────────────────────────┘
```

## Related Documentation

- [Ghost County README](../../Haunt/README.md) - Architecture overview
- [Skills Reference](../../Haunt/docs/SKILLS-REFERENCE.md) - Quick reference table
- [Setup Guide](../../Haunt/SETUP-GUIDE.md) - Complete setup instructions
