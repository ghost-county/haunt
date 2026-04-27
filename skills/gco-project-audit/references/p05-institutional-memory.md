# P5: The Institutional Memory Principle

> "When an agent makes a mistake, don't just correct it — codify it forever."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/institutional-memory/)

## Audit Criteria

### What to Check

1. **Always/Never section exists** — Does CLAUDE.md have structured always/never rules?
2. **BECAUSE clauses** — Does every rule include reasoning? (Rules without reasons can't generalize.)
3. **Named anti-patterns** — Are recurring failures given names from the domain? (Names activate knowledge clusters.)
4. **Codification discipline** — When agents are corrected, is the correction added to the handbook?
5. **No contradictions** — Do rules conflict with each other? (Agents can't resolve contradictions.)
6. **Quarterly pruning** — Is there evidence of stale rules being removed?
7. **Team-shared** — Is the handbook in version control, accessible to all developers?

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | Structured always/never with BECAUSE clauses; named anti-patterns; evidence of pruning; team-shared |
| Partial | Some rules exist but missing BECAUSE clauses; no pruning; some contradictions |
| Weak | Informal corrections in conversation; no codification to files |
| Missing | No institutional memory mechanism; same mistakes repeat across sessions |

### Common Violations

- Rules without BECAUSE clauses (cover one case, can't generalize)
- Contradictory rules added over time without updating originals
- Session-only corrections never codified to CLAUDE.md
- Handbook never pruned (80 rules, many obsolete)
- Generic descriptions instead of named anti-patterns
- Knowledge lives in developers' heads, not in files

### Rule Format

```
Always [action] BECAUSE [reason that enables generalization]
Never [action] BECAUSE [reason that enables generalization]
```

### Dead Rule vs Living Principle

- **Dead**: "Never use `Array<T>`" — covers one case, no reasoning, cannot generalize
- **Living**: "Always use `T[]` BECAUSE our ESLint config enforces it" — generalizable to all style questions

### Science

- Combined positive + negative + reason outperforms any single format (Zamfirescu-Pereira et al., CHI 2023)
- Principles with explanations generalize; bare rules cover only listed cases (Anthropic skill-creator docs)
