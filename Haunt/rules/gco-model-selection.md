# Model Selection Guidelines (Slim Reference)

## Core Principle

**High-leverage activities require high-capability models.** The cost difference is negligible compared to wasted time from poor decisions.

## Model Assignments

| Agent | Model | Rationale |
|-------|-------|-----------|
| **Project Manager** | Sonnet/Opus | Strategic analysis (JTBD, Kano, RICE) determines all downstream work |
| **Research/Research Analyst** | Sonnet | Deep investigation, architecture recommendations |
| **Dev (all types)** | Sonnet | TDD, patterns, edge cases, architecture require reasoning |
| **Code Reviewer** | Sonnet | Quality gates and pattern detection require deep reasoning |
| **Release Manager** | Sonnet | Risk assessment and coordination |

## Quick Decision Tree

**Use Sonnet (default):** Requirements analysis, research, code implementation, code review, architecture decisions

**Use Opus:** Strategic planning, complex multi-requirement decomposition, high-stakes architecture

**Use Haiku:** Read-only exploration ONLY (file searches, structured data extraction)

## When to Invoke Full Skill

For detailed ROI analysis, task tool usage patterns, anti-patterns, and monitoring guidance:

**Invoke:** `/gco-model-selection` skill

The skill contains:
- When to use each model (Opus/Sonnet/Haiku)
- ROI analysis examples
- Task tool usage with model specifications
- Anti-patterns to avoid
- Guidelines for model override
- Cost monitoring strategies

## Non-Negotiable

- NEVER use Haiku for strategic analysis or research
- NEVER use Haiku for implementation (bugs, technical debt result)
- NEVER override agent model specs without valid reason
- When in doubt → Use Sonnet (cost of being wrong >> model cost difference)
