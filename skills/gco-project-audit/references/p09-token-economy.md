# P9: The Token Economy Principle

> "Tokens are money. Measure before scaling, optimize before adding agents."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/token-economy/)

## Audit Criteria

### What to Check

1. **Token tracking** — Is token consumption measured per workflow step?
2. **Single-agent baseline** — Has each multi-agent task been tested with a single well-prompted agent first?
3. **45% threshold applied** — If single agent achieves >45% optimal, is it improved rather than expanded?
4. **Team size capped** — Are teams limited to 3-5 agents with justification?
5. **Cascade pattern** — Does escalation follow Level 0 (single) -> Level 1 (+ tools) -> Level 2 (worker + reviewer) -> Level 3 (3-5 team)?
6. **Adaptive composition** — Are teams composed per-task, not static rosters?
7. **Context loading managed** — Are unused plugins/MCP servers disabled per session?

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | Token tracking; cascade escalation with evidence; adaptive teams; context loading managed |
| Partial | Some awareness but no tracking; static teams; unused tools loaded |
| Weak | Multi-agent by default; no single-agent baseline; no cost awareness |
| Missing | No token economy awareness; agents added without measurement |

### Common Violations

- Default 5-agent teams for everything (7x cost for 3.1x output)
- Never testing single-agent approach first
- Static team rosters regardless of task complexity
- 15+ plugins loaded when 3 are needed (silent token cost)
- Jumping from Level 0 to Level 3 based on intuition, not data
- No token/cost logging per workflow step

### DeepMind Scaling Data (2025)

| Team Size | Token Cost | Output | Efficiency |
|-----------|-----------|--------|-----------|
| 1 agent | 1.0x | 1.0x | 1.00 |
| 3 agents | 3.5x | 2.3x | 0.66 |
| 5 agents | 7.0x | 3.1x | 0.44 |
| 7+ agents | 12.0x+ | 3.0x | <0.25 |

### Cascade Levels

- **Level 0**: Single well-prompted agent (always start here)
- **Level 1**: Single agent with tools
- **Level 2**: Worker + reviewer (2 agents)
- **Level 3**: Small team, 3-5 agents with defined roles
- **Level 4**: Multi-team with coordinator (rarely justified)

### Key Metric

> Cost per unit of useful output — should decrease over time.

### Science

- Sequential reasoning degrades 39-70% with multi-agent vs single (DeepMind, 2025)
- Coordination overhead grows superlinearly with team size
- Adaptive teams outperform static teams by 15-25% (Captain Agent, 2024)
