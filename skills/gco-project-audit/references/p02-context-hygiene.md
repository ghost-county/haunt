# P2: The Context Hygiene Principle

> "Context is your scarcest resource. Treat it like memory in an embedded system, not disk space on a server."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/context-hygiene/)

## Audit Criteria

### What to Check

1. **CLAUDE.md size** — Is it under 500 lines? Every token competes for attention on every interaction.
2. **Information positioning** — Are critical constraints front-loaded? Instructions back-loaded? (U-shaped attention curve: 30%+ accuracy drop for middle content — Liu et al., 2024)
3. **Progressive disclosure** — Is context layered (L1: identity/vocab always loaded, L2: task-triggered SOPs, L3: on-demand docs, L4: compressed summaries)?
4. **Session isolation** — Are workflows designed for single-session completeness? No cross-conversation assumptions?
5. **State externalization** — Are plans, decisions, and artifacts saved to files (not just conversation)?
6. **Plugin/MCP audit** — Are unused plugins and MCP servers disabled? Each injects tool definitions into system prompt.
7. **Context poisoning** — Are there stale instructions, outdated conventions, or resolved workarounds still in context files?

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | Lean CLAUDE.md, proper positioning, progressive disclosure, aggressive `/clear` discipline |
| Partial | CLAUDE.md exists but bloated; some externalization; plugins not audited |
| Weak | Monolithic CLAUDE.md; no session boundaries; everything loaded always |
| Missing | No context management strategy |

### Common Violations

- CLAUDE.md over 500 lines with linter-enforced rules duplicated
- Critical constraints buried in middle of long documents
- 15+ MCP servers loaded when 3 are needed for current task
- Plans and state kept in conversation instead of files
- Old workarounds and deprecated instructions still in context files
- No `/clear` between distinct units of work

### Key Metrics

- **Context utilization zone**: Optimal is 15-40% of window. Below 10% = hallucination risk. Above 60% = attention dilution.
- **Messages per session before quality degrades**: Should be "never" if clearing properly.
