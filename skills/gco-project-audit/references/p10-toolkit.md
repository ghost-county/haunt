# P10: The Toolkit Principle

> "Knowledge without automation decays. Encode your principles into tools that enforce them automatically."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/toolkit/)

## Audit Criteria

### What to Check

1. **Principles encoded in tools** — Are key practices automated (not relying on memory/discipline)?
2. **Skills follow architecture** — Vocabulary first, anti-patterns second, instructions middle, retrieval anchors last?
3. **Skill descriptions are triggers** — Do descriptions say "Use when..." (not summarize workflow)?
4. **Expert vocabulary** — Do skills use 15-30 precise domain terms (15-year practitioner test)?
5. **Dual-register descriptions** — Expert terminology + natural language in each skill description?
6. **Anti-patterns per skill** — 5-10 named anti-patterns with detection signals and resolutions?
7. **Progressive disclosure** — SKILL.md under 500 lines, heavy content in `references/`?
8. **No flattery** — Are agent identities defined through knowledge, not superlatives?
9. **Context loading managed** — Are tools/plugins selectively loaded per session type?

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | Principles automated in tools; skills follow architecture; selective loading; no manual discipline required |
| Partial | Some tooling but gaps; skills exist but don't follow architecture standard |
| Weak | Knowledge in docs but not encoded in tools; manual discipline required |
| Missing | No toolkit; all practices depend on developer memory |

### Common Violations

- Practices stored in memory/docs but not automated
- Skills with generic consultant-speak instead of expert vocabulary
- Skill descriptions that summarize workflow (Claude follows description, skips content)
- Over-prompted skills (>19 requirements drops accuracy below 5 requirements)
- Flattery-based personas ("world's best" routes to motivational content)
- Positive-only instructions (no anti-patterns = model gravitates to distribution center)
- All tools loaded in every session (kitchen-sink context)
- Overlapping skill sets (ambiguous triggering)

### Skill Architecture Standard

```
skill-name/
  SKILL.md (<500 lines)
    YAML frontmatter (name + dual-register description)
    Expert Vocabulary Payload     (FIRST - highest attention)
    Anti-Pattern Watchlist        (SECOND - primes avoidance)
    Behavioral Instructions       (MIDDLE - structured steps)
    Questions This Skill Answers  (LAST - retrieval anchors)
  references/
    detailed-content.md           (loaded on demand)
```

### Key Question

> "If I forget about this practice for a month, does the tool still enforce it? If not, it needs hardening."

### Science

- Vocabulary determines which knowledge region activates (Ranjan et al., 2024)
- At n=19 requirements, accuracy drops below n=5 (right-altitude prompting)
- U-shaped attention: beginning and end get disproportionate weight (Liu et al., 2024)
