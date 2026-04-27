# P1: The Hardening Principle

> "Every fuzzy LLM step that must behave identically every time must eventually be replaced by a deterministic tool."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/hardening/)

## Audit Criteria

### What to Check

1. **Workflow step inventory** — Are all LLM-powered steps mapped?
2. **Step classification** — Is each step classified as fuzzy (reasoning) or mechanical (deterministic)?
3. **Hardened tools exist** — Are mechanical steps implemented as deterministic code (scripts, CLI tools, MCP servers)?
4. **LLM role scoped** — Is the LLM restricted to orchestration + fuzzy reasoning, not mechanical execution?
5. **Independent testability** — Can hardened tools run and be tested outside any LLM context?
6. **Logging** — Does every hardened tool produce structured logs (inputs, outputs, duration)?
7. **Silent failure detection** — Are failures loud with clear error messages, not silent/plausible-but-wrong?

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | Mechanical steps are hardened tools; LLM only orchestrates + reasons; tools tested independently |
| Partial | Some hardening done but LLM still executes mechanical steps in places |
| Weak | LLM orchestrates entire workflows including file I/O, format generation, etc. |
| Missing | No separation between fuzzy and mechanical steps |

### Common Violations

- LLM generating file paths, filenames, or directory structures instead of deterministic code
- LLM constructing shell commands with flag combinations instead of a wrapper script
- LLM formatting structured output (YAML, JSON) instead of a template/serializer
- Hooks that should be deterministic but depend on LLM judgment
- No logging on hardened tools, making failures invisible

### Key Question

> "If I run this 50 times with identical input, do I get identical output every time? If not, should I?"
