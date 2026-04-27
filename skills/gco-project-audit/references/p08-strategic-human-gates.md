# P8: The Strategic Human Gate Principle

> "Build explicit, low-friction human approval points at critical moments."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/strategic-human-gate/)

## Audit Criteria

### What to Check

1. **Gates exist** — Are there 2-3 human approval points at irreversible/high-blast-radius decisions?
2. **Strategic placement** — Are gates at commitment moments (plan approval, pre-hardening, pre-deploy)?
3. **Low friction** — Are gates quick to approve (~5 min routine)? Not toll booths.
4. **Structured gate output** — Do gates present summary, risks, confidence, and approve/reject option?
5. **Evidence-based** — Do both agents and humans cite specific evidence for approval/rejection?
6. **Cascade validation** — Is there human confirmation before escalating from single-agent to multi-agent?
7. **Rejection rate tracked** — Is the monthly rejection rate between 5-20%?

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | 2-3 strategic gates at irreversible decisions; structured output; healthy rejection rate |
| Partial | Some gates but poorly placed (reversible decisions) or too many (bottleneck) |
| Weak | One gate or none; no structured output; no rejection tracking |
| Missing | Fully automated pipeline with no human oversight at critical points |

### Common Violations

- No human gates at all (trusting pipeline on faith)
- Too many gates (every step needs approval = developer becomes bottleneck)
- Gates on reversible decisions (wastes human attention budget)
- Rubber-stamp gates (human approves without reading — 0% rejection rate)
- No structured output (human must read full context instead of summary)
- Missing cascade validation (jumping to multi-agent without single-agent evidence)

### Gate Output Format

```
GATE: [Gate Name]
Feature: [What's being approved]
Files affected: [Count and list]
Approach: [Brief description]
Identified risks: [What could go wrong]
Confidence: [High/Medium/Low with reasoning]
[approve / reject with reason]
```

### Key Metric

> Monthly rejection rate. Target: 5-20%. Below 5% = gates at wrong decisions. Above 30% = upstream quality problem.

### Science

- FM-3.1 (Rubber-Stamp Approval) is most common quality failure in multi-agent systems (MAST)
- Alignment-accuracy tradeoff: stronger personas = more obedient but less truthful (PRISM)
- Self-evaluation fails: generator shares evaluator's biases (Anthropic, Mar 2026)
