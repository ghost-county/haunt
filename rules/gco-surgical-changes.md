# Surgical Changes

## Core Principle

Touch only what the task requires. Match existing style. Clean up only your own mess.

## Non-Negotiable

- NEVER refactor adjacent code that isn't broken BECAUSE unrequested refactoring expands diff scope, hides the real change in review, and risks regressions in code the user didn't ask you to touch
- NEVER "improve" formatting, comments, or naming in code outside the task BECAUSE every cosmetic edit competes for review attention with the substantive change and signals undisciplined scope creep
- ALWAYS match existing style and conventions even when you'd write it differently BECAUSE style consistency is a property of the codebase, not the contributor; mixing styles increases cognitive load for every future reader
- ALWAYS remove orphans your changes created (unused imports, dead variables) BECAUSE leaving them produces linter noise and obscures which warnings are pre-existing vs. newly introduced
- NEVER delete pre-existing dead code unless explicitly asked BECAUSE "dead" code may be intentionally kept (feature flags, recently-disabled features, in-flight work); deletion is irreversible without git archaeology

## The Test

Every changed line should trace directly to the user's request. If you can't justify a line in one sentence referencing the task, revert it.

## When to Mention vs. Fix

| Situation | Action |
|-----------|--------|
| Bug in code you're editing, task-adjacent | Fix it, call it out in response |
| Bug in code you're editing, unrelated | Mention it, don't fix |
| Dead code your change created | Remove silently |
| Dead code that pre-exists | Mention it, leave it |
| Style inconsistency in adjacent code | Leave it |
| Style inconsistency the task introduces | Match surrounding style |

## Examples

### WRONG (scope creep)
```
User: "Add a null check to getUserById"

[adds null check]
[also renames variable from 'u' to 'user' two functions away]
[also reformats nearby JSDoc]
[also extracts a helper for unrelated date parsing]
```

### RIGHT (surgical)
```
User: "Add a null check to getUserById"

[adds null check]
[removes the now-unused error import that became orphaned]

Done. Noticed `parseUserDate` two functions down has a similar nullable path — flagging for separate work, didn't touch it.
```

### WRONG (style override)
```
[Existing codebase uses snake_case for Python module-level vars]
[Claude adds new var in camelCase "because it's a frontend project"]
```

### RIGHT (match style)
```
[Existing codebase uses snake_case for Python module-level vars]
[Claude adds new var in snake_case to match]
```

## Application

Applies to every edit, regardless of size. The discipline is harder on small tasks (the temptation to "just clean this up while I'm here" is strongest). Resist.
