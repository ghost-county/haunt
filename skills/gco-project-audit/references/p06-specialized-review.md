# P6: The Specialized Review Principle

> "A generalist reviewer trends toward the median. Specialists find what generalists can't."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/specialized-review/)

## Audit Criteria

### What to Check

1. **Specialist agents exist** — Are there domain-specific review agents (security, performance, accessibility)?
2. **Vocabulary routing** — Do reviewers use 15-30 precise domain terms? (15-year practitioner test)
3. **Brief identities** — Are agent identities under 50 tokens? Real job titles, no flattery?
4. **Named anti-patterns** — Does each specialist have 5-10 named anti-patterns with detection signals?
5. **Generation/evaluation separation** — Is the agent writing code different from the agent reviewing it?
6. **Deterministic checks first** — Do build/lint/test run before LLM review?
7. **Evidence-backed verdicts** — Do reviews cite specific file:line references? No bare "LGTM"?
8. **No flattery** — Are personas defined through vocabulary, not superlatives?

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | Domain specialists with vocabulary routing; brief identities; evidence-backed reviews; deterministic first |
| Partial | Some specialization but identities too long; missing vocabulary; no anti-patterns |
| Weak | Single generalist reviewer; elaborate personas with flattery |
| Missing | No code review agents or review process |

### Common Violations

- Single generalist agent reviewing everything (trends to median)
- "You are the world's best security expert" — flattery routes to motivational content, not expertise
- 150+ token personas (PRISM: accuracy degrades with persona length)
- Same agent generates and reviews code (self-evaluation fails)
- Reviews that say "LGTM" without citing specific evidence
- LLM review without running build/lint/test first
- Role stacking — one agent as simultaneous security + performance + accessibility expert

### Key Metric

> Domain-specific issue detection rate — percentage of real issues caught before production.

### Science

- Vocabulary acts as routing signal in embedding space (Ranjan et al., 2024)
- Accuracy damage scales with persona length; <50 tokens optimal (PRISM)
- Generator and evaluator share identical biases (Anthropic Harness Design, Mar 2026)
- Security detection: ~40% (generalist) vs ~95% (specialist)
