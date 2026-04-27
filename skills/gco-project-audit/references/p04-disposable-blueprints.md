# P4: The Disposable Blueprint Principle

> "Never implement without a saved, versioned plan artifact. And never fall in love with one."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/disposable-blueprint/)

## Audit Criteria

### What to Check

1. **Plan artifacts exist** — Are plans saved as files before implementation begins?
2. **Plans versioned in git** — Are plans committed, reviewable, diffable?
3. **Structured format** — Do plans have Goal, Constraints, Approach, File Changes, Test Strategy sections?
4. **Session separation** — Is `/clear` used between planning and implementation?
5. **Kill discipline** — Are failed approaches restarted from revised plans (not patched)?
6. **Plan review** — Are plans reviewed by humans before implementation begins?
7. **Plans are disposable** — Is there evidence of plans being revised/discarded when approaches fail?

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | Versioned plan files, structured format, clear planning/implementation separation, evidence of restarts |
| Partial | Plans exist but informal; some versioning; patching preferred over restarts |
| Weak | Plans in conversation only; no versioning; sunk-cost attachment evident |
| Missing | Implementation starts without plans |

### Common Violations

- Jumping straight to code without a plan artifact
- Plans that live only in conversation (lost on session end)
- Patching failed approaches for hours instead of restarting from revised plan
- Treating plans as sacred commitments instead of disposable tools
- No `/clear` between planning and implementation phases
- Plans without structure (prose blob instead of Goal/Constraints/Approach)

### Key Metric

> Time from "this approach is wrong" to "clean restart with better plan." Target: under 5 minutes.

### Science

- Structured artifacts produce ~40% fewer errors than free-form dialogue (Hong et al., 2023 — MetaGPT)
- Prompt format alone accounts for up to 40% performance variation (He et al., 2025)
