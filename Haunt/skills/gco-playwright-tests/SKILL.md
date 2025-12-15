---
name: gco-playwright-tests
description: Generate Playwright E2E tests for UI features. Invoke when implementing frontend features, user flows, or interactive components that need browser-based testing.
---

# Playwright Test Generation

## Purpose

This skill guides Dev agents in generating Playwright E2E tests for UI features. Use this when implementing frontend features that involve user interactions, page navigation, or visual elements that require browser-based testing.

## When to Invoke

Generate Playwright tests when implementing:

- **User flows**: Login, signup, checkout, multi-step forms
- **Interactive UI components**: Modals, dropdowns, tabs, accordions, carousels
- **Page navigation**: Routing, redirects, history management
- **Form handling**: Input validation, submission, error states
- **Visual elements**: Responsive layouts, animations, dark mode
- **API integration in UI**: Data loading states, error handling, pagination

## When NOT to Generate Playwright Tests

Skip Playwright tests for:

- Pure backend/API work (use unit tests instead)
- Configuration changes with no UI impact
- Documentation-only changes
- Infrastructure/DevOps work
- Logic that doesn't touch the browser

## Playwright MCP Integration

When Playwright MCP is available (`mcp__playwright__*` tools), you can:

1. **Verify tests locally** before committing
2. **Debug failing tests** with headed browser mode
3. **Take screenshots** for visual regression testing
4. **Record interactions** for test generation

### Available MCP Tools

| Tool | Description |
|------|-------------|
| `mcp__playwright__navigate` | Navigate to URLs |
| `mcp__playwright__click` | Click elements |
| `mcp__playwright__fill` | Fill form fields |
| `mcp__playwright__screenshot` | Capture screenshots |
| `mcp__playwright__get_content` | Extract page content |

## Test Output Locations

Place generated tests in the appropriate directory based on project structure:

| Project Type | Test Location | Convention |
|--------------|---------------|------------|
| **Next.js/React** | `tests/e2e/` or `e2e/` | `*.spec.ts` |
| **Vue** | `tests/e2e/` | `*.spec.ts` |
| **Generic Frontend** | `tests/e2e/` | `*.spec.ts` |
| **Haunt Framework** | `.haunt/tests/e2e/` | `test_*.py` or `*.spec.ts` |

**Naming Convention:**
- Feature tests: `{feature-name}.spec.ts`
- Page tests: `{page-name}.spec.ts`
- Flow tests: `{flow-name}-flow.spec.ts`
- From requirements: `req-{XXX}.spec.ts`

## Test Generation Workflow

### Step 1: Analyze the Feature

Before writing tests, understand:

1. **User journey**: What steps does the user take?
2. **Assertions**: What should be true at each step?
3. **Edge cases**: What could go wrong?
4. **Dependencies**: What needs to be set up first?

### Step 2: Generate Test Skeleton

```typescript
import { test, expect } from '@playwright/test';

/**
 * E2E Tests for: {Feature Name}
 *
 * User Story:
 * As a {user type}
 * I want to {action}
 * So that {benefit}
 *
 * Scenarios:
 * 1. Happy path: {description}
 * 2. Edge case: {description}
 * 3. Error handling: {description}
 */

test.describe('{Feature Name}', () => {
  test.beforeEach(async ({ page }) => {
    // Setup: Navigate to starting page
    await page.goto('/path-to-feature');
  });

  test('should {expected behavior}', async ({ page }) => {
    // Arrange: Set up test data

    // Act: Perform user action

    // Assert: Verify expected outcome
  });
});
```

### Step 3: Write Specific Test Cases

#### Happy Path Test
```typescript
test('should successfully complete {action}', async ({ page }) => {
  // Arrange
  await page.goto('/feature');

  // Act
  await page.fill('[data-testid="input-field"]', 'test value');
  await page.click('[data-testid="submit-button"]');

  // Assert
  await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
  await expect(page).toHaveURL('/success');
});
```

#### Error Handling Test
```typescript
test('should show error for invalid input', async ({ page }) => {
  // Arrange
  await page.goto('/feature');

  // Act - Submit invalid data
  await page.fill('[data-testid="email-field"]', 'invalid-email');
  await page.click('[data-testid="submit-button"]');

  // Assert
  await expect(page.locator('[data-testid="error-message"]'))
    .toContainText('Please enter a valid email');
});
```

#### Loading State Test
```typescript
test('should show loading state during submission', async ({ page }) => {
  // Arrange
  await page.goto('/feature');
  await page.fill('[data-testid="input"]', 'value');

  // Act
  await page.click('[data-testid="submit-button"]');

  // Assert loading state appears
  await expect(page.locator('[data-testid="loading-spinner"]')).toBeVisible();

  // Assert loading state resolves
  await expect(page.locator('[data-testid="loading-spinner"]')).not.toBeVisible();
});
```

### Step 4: Add Test Data and Fixtures

```typescript
// fixtures/test-data.ts
export const testUsers = {
  validUser: {
    email: 'test@example.com',
    password: 'SecurePass123!',
  },
  invalidUser: {
    email: 'invalid',
    password: '',
  },
};

// In test file
import { testUsers } from './fixtures/test-data';

test('should login with valid credentials', async ({ page }) => {
  await page.fill('[data-testid="email"]', testUsers.validUser.email);
  await page.fill('[data-testid="password"]', testUsers.validUser.password);
  await page.click('[data-testid="login-button"]');

  await expect(page).toHaveURL('/dashboard');
});
```

## Common Test Patterns

### Form Submission
```typescript
test('should submit form successfully', async ({ page }) => {
  await page.goto('/form');

  // Fill all fields
  await page.fill('[name="firstName"]', 'John');
  await page.fill('[name="lastName"]', 'Doe');
  await page.fill('[name="email"]', 'john@example.com');
  await page.selectOption('[name="country"]', 'US');
  await page.check('[name="terms"]');

  // Submit
  await page.click('[type="submit"]');

  // Verify success
  await expect(page.locator('.success-message')).toBeVisible();
});
```

### Modal Interaction
```typescript
test('should open and close modal', async ({ page }) => {
  await page.goto('/page-with-modal');

  // Open modal
  await page.click('[data-testid="open-modal-button"]');
  await expect(page.locator('[role="dialog"]')).toBeVisible();

  // Close modal
  await page.click('[data-testid="close-modal-button"]');
  await expect(page.locator('[role="dialog"]')).not.toBeVisible();
});
```

### Navigation and Routing
```typescript
test('should navigate between pages', async ({ page }) => {
  await page.goto('/');

  // Click navigation link
  await page.click('a[href="/about"]');

  // Verify navigation
  await expect(page).toHaveURL('/about');
  await expect(page.locator('h1')).toContainText('About');
});
```

### API Response Handling
```typescript
test('should display data from API', async ({ page }) => {
  await page.goto('/data-page');

  // Wait for data to load
  await page.waitForResponse('**/api/data');

  // Verify data displayed
  await expect(page.locator('[data-testid="data-list"]')).toBeVisible();
  await expect(page.locator('[data-testid="data-item"]')).toHaveCount(5);
});
```

### Authentication Flow
```typescript
test('should redirect unauthenticated user to login', async ({ page }) => {
  await page.goto('/protected-page');

  // Should redirect to login
  await expect(page).toHaveURL('/login?redirect=/protected-page');
});

test('should redirect to requested page after login', async ({ page }) => {
  await page.goto('/login?redirect=/protected-page');

  // Login
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('[data-testid="login-button"]');

  // Should redirect to originally requested page
  await expect(page).toHaveURL('/protected-page');
});
```

### Responsive Testing
```typescript
test.describe('Mobile view', () => {
  test.use({ viewport: { width: 375, height: 667 } });

  test('should show mobile navigation', async ({ page }) => {
    await page.goto('/');

    // Desktop nav should be hidden
    await expect(page.locator('[data-testid="desktop-nav"]')).not.toBeVisible();

    // Mobile menu button should be visible
    await expect(page.locator('[data-testid="mobile-menu-button"]')).toBeVisible();
  });
});
```

## Best Practices

### Selectors

Use these selector strategies (in order of preference):

1. **Test IDs** (most reliable): `[data-testid="submit-button"]`
2. **ARIA roles**: `[role="button"]`, `[role="dialog"]`
3. **Accessible names**: `page.getByRole('button', { name: 'Submit' })`
4. **Text content**: `page.getByText('Welcome')`
5. **CSS selectors** (least preferred): `.button-primary`

### Assertions

Use explicit waits and assertions:

```typescript
// Good: Explicit assertion
await expect(page.locator('.success')).toBeVisible();

// Bad: Implicit timing
await page.waitForTimeout(1000);
expect(await page.isVisible('.success')).toBe(true);
```

### Test Independence

Each test should be independent:

```typescript
// Good: Each test sets up its own state
test('should delete item', async ({ page }) => {
  // Setup: Create item first
  await createTestItem(page);

  // Act: Delete it
  await page.click('[data-testid="delete-button"]');

  // Assert
  await expect(page.locator('[data-testid="item"]')).not.toBeVisible();
});

// Bad: Depends on previous test
test('should delete item', async ({ page }) => {
  // Assumes item from previous test exists
  await page.click('[data-testid="delete-button"]');
});
```

## Running Tests

### Command Reference

```bash
# Run all Playwright tests
npx playwright test

# Run specific test file
npx playwright test tests/e2e/login.spec.ts

# Run tests in headed mode (visible browser)
npx playwright test --headed

# Run tests for specific browser
npx playwright test --project=chromium

# Debug failing tests
npx playwright test --debug

# Generate report
npx playwright show-report
```

### CI/CD Integration

Add to GitHub Actions:

```yaml
- name: Run Playwright tests
  run: npx playwright test

- name: Upload test results
  uses: actions/upload-artifact@v3
  if: always()
  with:
    name: playwright-report
    path: playwright-report/
```

## Integration with /qa Command

Use the `/qa` command to generate test scenarios from requirements:

```bash
# Generate Playwright test skeleton
/qa REQ-XXX --format=playwright

# Save and implement
/qa REQ-XXX --format=playwright > tests/e2e/req-xxx.spec.ts
```

## Workflow Integration

### When to Generate Tests

1. **During feature implementation**: Write tests as you build
2. **Before PR/merge**: Ensure tests exist for all UI changes
3. **From requirements**: Use `/qa --format=playwright` during planning
4. **Bug fixes**: Add regression test before fixing

### TDD with Playwright

Follow Red-Green-Refactor for E2E tests:

1. **Red**: Write failing E2E test describing expected behavior
2. **Green**: Implement feature to make test pass
3. **Refactor**: Clean up implementation while keeping tests green

```typescript
// 1. RED: Test describes what we want
test('should show user profile after login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'password');
  await page.click('[data-testid="login-button"]');

  // This will fail until feature is implemented
  await expect(page.locator('[data-testid="user-profile"]')).toBeVisible();
  await expect(page.locator('[data-testid="user-name"]')).toContainText('User');
});

// 2. GREEN: Implement feature
// 3. REFACTOR: Clean up code
```

## See Also

- `Haunt/docs/BROWSER-MCP-SETUP.md` - Browser MCP installation guide
- `Haunt/commands/gco-qa.md` - Test scenario generation from requirements
- `Haunt/skills/gco-tdd-workflow/SKILL.md` - General TDD guidance
- [Playwright Documentation](https://playwright.dev/docs/intro)
