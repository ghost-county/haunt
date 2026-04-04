---
last-verified: 2026-04-03
version: "1.0"
name: gco-playwright-tests
description: Generate Playwright E2E tests for UI features. Invoke when implementing frontend features, user flows, or interactive components that need browser-based testing.
---

# Playwright Test Generation

## When to Invoke

**Generate tests for:**
- User flows (login, signup, checkout, multi-step forms)
- Interactive UI (modals, dropdowns, tabs, accordions)
- Navigation (routing, redirects, history)
- Forms (validation, submission, error states)
- Visual elements (responsive layouts, animations, dark mode)
- API integration (loading states, error handling, pagination)

**Skip tests for:**
- Pure backend/API work (use unit tests)
- Configuration/documentation/infrastructure changes

## Selector Strategies (Priority Order)

| Selector | Example | When to Use |
|----------|---------|-------------|
| Test IDs | `[data-testid="submit-button"]` | Most reliable, preferred |
| ARIA roles | `[role="button"]`, `[role="dialog"]` | Semantic elements |
| Accessible names | `page.getByRole('button', { name: 'Submit' })` | User-visible text |
| Text content | `page.getByText('Welcome')` | Unique text |
| CSS selectors | `.button-primary` | Last resort |

## Test Structure Template

```typescript
import { test, expect } from '@playwright/test';

test.describe('{Feature Name}', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/path-to-feature');
  });

  test('should complete happy path', async ({ page }) => {
    // Arrange: Set up test data
    // Act: Perform user action
    // Assert: Verify expected outcome
  });

  test('should handle errors', async ({ page }) => {
    // Test error states and validation
  });

  test('should show loading states', async ({ page }) => {
    // Test async behavior
  });
});
```

## Essential Test Patterns

### Happy Path
```typescript
await page.fill('[data-testid="input"]', 'value');
await page.click('[data-testid="submit"]');
await expect(page.locator('[data-testid="success"]')).toBeVisible();
await expect(page).toHaveURL('/success');
```

### Error Handling
```typescript
await page.fill('[data-testid="email"]', 'invalid');
await page.click('[data-testid="submit"]');
await expect(page.locator('[data-testid="error"]'))
  .toContainText('Please enter a valid email');
```

### Loading States
```typescript
await page.click('[data-testid="submit"]');
await expect(page.locator('[data-testid="spinner"]')).toBeVisible();
await expect(page.locator('[data-testid="spinner"]')).not.toBeVisible();
```

### Modal Interaction
```typescript
await page.click('[data-testid="open-modal"]');
await expect(page.locator('[role="dialog"]')).toBeVisible();
await page.click('[data-testid="close-modal"]');
await expect(page.locator('[role="dialog"]')).not.toBeVisible();
```

## Completion Checklist

Before marking frontend work complete:

- [ ] E2E tests exist for all user-facing behavior
- [ ] Tests in correct location (`tests/e2e/` or `.haunt/tests/e2e/`)
- [ ] Tests cover happy path, errors, and edge cases
- [ ] Tests are independent (no shared state)
- [ ] All tests pass: `npx playwright test`

## Commands

```bash
npx playwright test                      # Run all tests
npx playwright test path/to/file.spec.ts # Run specific file
npx playwright test --headed             # Debug with visible browser
npx playwright test --debug              # Step-through debugger
```

## See Also

- `gco-ui-testing` - UI testing enforcement rule
- `gco-tdd-workflow` - Test-driven development cycle
- [Playwright Docs](https://playwright.dev/docs/intro)
