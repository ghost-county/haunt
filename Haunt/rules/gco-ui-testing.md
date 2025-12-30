# UI Testing Protocol (Slim Reference)

## Core Requirement

**All user-facing UI changes REQUIRE Playwright E2E tests. No exceptions.**

## When E2E Tests Are REQUIRED

Generate Playwright tests for:
- User flows (login, signup, checkout, multi-step forms)
- Interactive components (modals, dropdowns, tabs, accordions)
- Page navigation (routing, redirects)
- Form handling (validation, submission, error states)
- Visual behavior (responsive layouts, animations, dark mode)

## TDD Workflow (Required)

1. **RED:** Write failing E2E test first (describes expected behavior)
2. **GREEN:** Implement feature to pass test
3. **REFACTOR:** Clean up while tests stay green

## Before Marking Complete

Verify:
- [ ] E2E tests exist for all user-facing behavior
- [ ] Tests in correct location (tests/e2e/ or .haunt/tests/e2e/)
- [ ] All E2E tests pass: `npx playwright test`
- [ ] Tests cover happy path AND error cases
- [ ] Tests are independent (no shared state)

## When to Invoke Full Skill

For comprehensive guidance on UI testing including user journey mapping, test location conventions, CI/CD integration, and common mistakes:

**Invoke:** `/gco-ui-testing` skill

The skill contains:
- User journey mapping for E2E tests (JTBD framework)
- Test location requirements and naming conventions
- TDD workflow with detailed examples
- Completion checklist integration
- Common mistakes to avoid
- Agent workflow by type (Frontend, Backend, Code Reviewer)

## Non-Negotiable

- NEVER mark frontend requirement 🟢 without E2E tests
- NEVER skip E2E tests "because it's simple"
- NEVER commit failing E2E tests
- ALWAYS test user behavior, not implementation details
