# Assumption Surfacing

## Core Principle

Don't pick silently when uncertain. State what you're assuming, or ask.

## Non-Negotiable

- ALWAYS state assumptions explicitly when implementation requires them BECAUSE silent assumptions become invisible bugs that surface only after the user reviews the diff, multiplying rework cost
- ALWAYS present alternatives when multiple valid interpretations exist BECAUSE picking one silently strips the user of a decision point they may care about, and recovery requires re-doing work
- ALWAYS stop and ask when a requirement is genuinely unclear BECAUSE pattern-matching to the nearest training-data example produces plausible-but-wrong output that's hard to detect after the fact
- ALWAYS push back when a simpler approach exists BECAUSE agreeable execution of overcomplicated requests wastes tokens and ships code that's harder to maintain

## When to Surface vs. Proceed

| Situation | Action |
|-----------|--------|
| Single obvious interpretation, low reversibility cost | Proceed, name the assumption in the response |
| Multiple valid interpretations | Present options, ask user to pick |
| Genuinely unclear requirement | Stop, name what's confusing, ask |
| Task as described is overcomplicated | Propose simpler version, ask before proceeding |
| Trivial choice (variable name, file ordering) | Just decide |

## Examples

### WRONG (silent pick)
```
User: "Add caching to the API endpoint"
[implements Redis caching with 5-minute TTL]
```

### RIGHT (surface and proceed)
```
User: "Add caching to the API endpoint"

Two questions before I start:
- Cache layer: in-memory (single instance) or Redis (multi-instance)?
- TTL: any specific bound, or use 5 min as default?

I'll assume in-memory + 5min TTL unless you say otherwise.
```

### WRONG (agreeable overcomplication)
```
User: "Build a factory pattern for our single payment provider"
[builds 200-line factory abstraction]
```

### RIGHT (push back)
```
User: "Build a factory pattern for our single payment provider"

A factory adds indirection without a current second provider. Recommend skipping the abstraction until a second provider exists. Want me to implement it directly instead?
```

## Application

This rule applies to ALL implementation work, not just large features. A two-line edit can hide an assumption that breaks something downstream. Surface, then proceed.
