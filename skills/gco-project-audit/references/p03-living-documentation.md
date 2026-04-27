# P3: The Living Documentation Principle

> "Documentation is context. Stale documentation is poisoned context."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/living-documentation/)

## Audit Criteria

### What to Check

1. **Freshness tracking** — Do convention docs have `last-verified` dates?
2. **Automated freshness checks** — Is there CI/cron flagging docs older than 30 days?
3. **Structured format** — Are conventions in structured Markdown (heading + rule + example), not prose paragraphs?
4. **Machine-readable** — Can an agent extract every convention unambiguously?
5. **Canonical examples** — Does each convention include 2-3 code examples (do this / not this)?
6. **ADRs** — Are Architecture Decision Records capturing rationale for significant decisions?
7. **Versioned with code** — Do documentation changes ship in the same PR as code changes?
8. **No over-documentation** — Are linter-enforced rules excluded? (Agents self-correct from linters.)

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | Freshness dates, automated checks, structured format, canonical examples, ADRs |
| Partial | Docs exist but no freshness tracking; some structure; no automation |
| Weak | Prose-heavy docs; no examples; no freshness mechanism |
| Missing | No convention documentation or stale docs with no maintenance plan |

### Common Violations

- Convention docs without `last-verified` dates
- Three-paragraph prose explanations instead of heading + rule + example
- Docs contradicting linter/toolchain configuration
- Conventions in wikis/Notion/Google Docs instead of repo (drift within weeks)
- Over-documenting linter-enforced rules (wastes attention budget)
- No ADRs — decisions lost when people leave

### Key Metric

> Number of agent-generated code corrections caused by stale or ambiguous documentation. Target: zero.

### Science

- 3 well-chosen examples match 9 in effectiveness (LangChain, 2024)
- Prompt structure accounts for up to 40% performance variation (He et al., 2025)
- LLMs weight final examples more heavily (recency bias — Liu et al., 2024)
