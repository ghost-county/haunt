# Haunt Skill Architecture Standard

How to structure skills for optimal LLM performance, based on transformer attention research.

## Why Layout Matters

LLMs exhibit a U-shaped attention curve (Liu et al. 2024, Wu et al. 2025): content at the **beginning** and **end** of context receives disproportionately high attention weight, while **middle** content suffers 30%+ accuracy degradation. Skill layout must account for this.

## Frontmatter Requirements

```yaml
---
name: kebab-case-identifier
description: >-
  [Keyword-dense trigger sentence with expert vocabulary].
  [Natural language sentence for human disambiguation].
last-verified: YYYY-MM-DD
---
```

**Dual-register description:** First sentence uses domain-specific keywords that route the model to expert knowledge regions (Ranjan et al. 2024). Second sentence uses natural language for human readability and disambiguation. Both are required — expert-only undertriggers; casual-only produces generic output.

**Example:**
```yaml
description: >-
  OWASP Top 10 audit, STRIDE threat modeling, CWE classification, and agent security patterns for code review.
  Use when reviewing code for security vulnerabilities before merge or deployment.
```

## Body Layout (Attention-Optimized Order)

### Position 1: Vocabulary Payload (FIRST — highest attention)

15-30 precise domain terms the agent must use. Placed first BECAUSE first-position content has highest attention weight and vocabulary routes the model to correct knowledge regions.

**Format:**

| Term | Definition | Use When |
|------|-----------|----------|
| [expert term] | [precise definition] | [trigger context] |

**The 15-Year Practitioner Test:** Would a senior expert with 15+ years of domain experience use this exact term when talking with a peer? If not, find the precise term. "Nice colors" → "OKLCH tinted neutrals." "Check security" → "OWASP Top 10 audit."

### Position 2: Anti-Patterns / What NOT to Do (EARLY)

5-10 named failure modes with detection signals and resolutions. Placed before instructions BECAUSE agents default to instruction-following — seeing failures first primes the avoidance circuit.

**Format:**

| Anti-Pattern | Detection Signal | Resolution |
|-------------|-----------------|------------|
| [Named pattern (citation)] | [How to spot it] | [What to do instead] |

### Position 3: Instructions / Workflow (MIDDLE)

Step-by-step process using numbered imperative steps with explicit IF/THEN conditions. Acceptable in middle position BECAUSE procedural content is reinforced by the anti-patterns above and retrieval anchors below. Use numbered steps, not prose — structure survives degraded attention.

### Position 4: Questions This Skill Answers (LAST — second-highest attention)

8-15 natural language queries that should trigger this skill. Placed last BECAUSE end-position has second-highest attention weight and these serve as retrieval anchors.

**Format:**
```
## Questions This Skill Answers
- Should I approve this code?
- What anti-patterns are present?
- Is this secure enough to merge?
```

## Size Constraints

- **SKILL.md body:** 150-300 lines max (~2-4K tokens). Keeps the skill within optimal context budget.
- **References subdirectory:** Unlimited. Loaded on-demand via consultation gates ("READ `references/details.md` for full examples").
- **Frontmatter description:** 2 sentences, <50 words total.

## Skill File Structure

```
skill-name/
├── SKILL.md              # Router (≤300 lines)
│   ├── YAML frontmatter
│   ├── Vocabulary Payload    (FIRST)
│   ├── Anti-Pattern Watchlist (SECOND)
│   ├── Instructions/Workflow  (MIDDLE)
│   └── Questions This Skill Answers (LAST)
└── references/
    ├── detailed-examples.md
    ├── anti-patterns-full.md
    └── evaluation-criteria.md
```

## Research Citations

- **Liu et al. 2024** — "Lost in the Middle": 30%+ accuracy drop for mid-context information
- **Wu et al. 2025 (MIT)** — U-shaped attention from RoPE + causal masking (architectural, not fixable by prompting)
- **Ranjan et al. 2024** — "One Word Is Not Enough": prompt vocabulary routes to knowledge clusters in embedding space
- **PRISM 2024** — Brief personas (<50 tokens) outperform elaborate ones; accuracy damage scales with persona length
- **LangChain 2024** — 3 well-chosen examples match 9 in effectiveness
- **Zamfirescu-Pereira et al. CHI 2023** — "Positive + negative + reason" outperforms any single format
