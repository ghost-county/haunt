# E2E Testing Reminder (Auto-Enforced)

## Trigger Conditions

This reminder activates when ALL of these are true:
1. You are working on **frontend/UI code** (components, pages, .tsx/.jsx/.vue files)
2. You are about to **mark work complete** (status → 🟢)

## The Reminder

**STOP.** Before marking this UI work complete, verify:

```
[ ] E2E tests exist for user-facing behavior
[ ] Tests are in correct location (tests/e2e/ or .haunt/tests/e2e/)
[ ] All E2E tests pass: npx playwright test
```

## Quick Check

Ask yourself: **"Did I run `npx playwright test` and see it pass?"**

- **YES** → Proceed to mark complete
- **NO** → Run tests first, fix failures, then mark complete
- **No E2E tests exist** → Write them before marking complete

## What Counts as UI Work

| UI Work (E2E Required) | NOT UI Work (E2E Optional) |
|------------------------|---------------------------|
| Components (`*/components/*`) | API routes (`*/api/*`) |
| Pages (`*/pages/*`, `*/app/*`) | Database models |
| Client-side state | Server-side services |
| Forms, modals, navigation | CLI tools, scripts |
| `.tsx`, `.jsx`, `.vue` files | Pure backend logic |

## Non-Negotiable

- **NEVER** mark UI work 🟢 without running E2E tests BECAUSE the completion-gate hook checks for verification evidence files; skipping tests will block the status change and waste a round-trip
- **NEVER** assume "it works" without `npx playwright test` output BECAUSE CSS can be defined but not applied, event handlers can bind but not fire, and responsive layouts can pass visual inspection at one breakpoint while breaking at another
- **NEVER** skip tests "because it's simple" BECAUSE simple UI bugs (broken links, missing focus states, wrong z-index) are the most embarrassing to ship and the cheapest to catch with a 30-second E2E run

## If E2E Tests Don't Exist

Create them. Location: `tests/e2e/{feature}.spec.ts`

Minimum coverage:
1. Happy path (user completes intended action)
2. Error path (user sees helpful error message)

## See Also

- `gco-ui-testing` skill - Detailed testing patterns
- `gco-playwright-tests` skill - Test generation examples
