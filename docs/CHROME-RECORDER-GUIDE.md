# Chrome DevTools Recorder Integration Guide

## What is Chrome DevTools Recorder?

Chrome DevTools Recorder is a built-in Chrome feature (released 2021) that records and replays user interactions. It can export tests to multiple formats including Playwright, Puppeteer, Cypress, and more.

**Purpose in Haunt Framework:**
- Quick test skeleton generation
- Onboarding new team members to E2E testing
- Demonstrating user flows to stakeholders
- Bootstrapping tests before refinement

**NOT a replacement for Playwright** - use as a starting point only.

---

## Quick Start

### 1. Access Chrome Recorder

**Option A: Command Palette**
1. Open Chrome DevTools (F12 or Cmd+Opt+I)
2. Press `Cmd/Ctrl + Shift + P`
3. Type "Show Recorder"
4. Press Enter

**Option B: Menu Navigation**
1. Open Chrome DevTools
2. Click ⋮ (More Tools)
3. Select "Recorder"

---

### 2. Record User Interaction

1. **Start Recording:**
   - Click the red "Start new recording" button
   - Enter a recording name (e.g., "User Login Flow")

2. **Perform User Actions:**
   - Navigate to your application
   - Interact with UI elements (click, type, navigate)
   - Recorder captures every action automatically

3. **Stop Recording:**
   - Click the stop button
   - Recorder displays captured steps

4. **Replay (Optional):**
   - Click "Replay" to verify captured flow
   - Adjust timing or steps as needed

---

### 3. Export to Playwright

1. **Click Export:**
   - Click the "Export" button in Recorder panel
   - Select "Export as @playwright/test"

2. **Save File:**
   - Save exported file to `tests/e2e/` directory
   - Name descriptively: `{feature-name}.spec.ts`

3. **Verify Export:**
   - Open exported file
   - Review generated test structure
   - Note the selectors used (often brittle CSS)

---

### 4. Refine for Production

**Critical:** Chrome Recorder generates test skeletons that require refinement for production use.

#### **Refinement Checklist:**

- [ ] **Replace brittle selectors** with `data-testid` attributes
- [ ] **Add assertions** for expected outcomes (not just actions)
- [ ] **Add error case tests** (validation failures, network errors, empty states)
- [ ] **Extract Page Object Model** patterns for reusability
- [ ] **Add test data fixtures** for maintainability
- [ ] **Verify tests are independent** (no shared state, no order dependency)
- [ ] **Add descriptive test names** and comments
- [ ] **Run tests in CI/CD** to ensure stability across environments

#### **Example Refinement:**

**Before (Chrome Recorder generated):**
```typescript
import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('https://example.com/');
  await page.click('#story > section > div:nth-child(3) > button');
  await page.fill('#email', 'user@example.com');
  await page.fill('#password', 'password123');
  await page.click('button.submit');
});
```

**After (Refined for production):**
```typescript
import { test, expect } from '@playwright/test';

test('should successfully log in with valid credentials', async ({ page }) => {
  // Navigate to login page
  await page.goto('https://example.com/login');

  // Fill login form using stable selectors
  await page.fill('[data-testid="email-input"]', 'user@example.com');
  await page.fill('[data-testid="password-input"]', 'password123');

  // Submit login form
  await page.click('[data-testid="login-submit-button"]');

  // Verify successful login
  await expect(page).toHaveURL('https://example.com/dashboard');
  await expect(page.locator('[data-testid="user-name"]')).toContainText('user@example.com');
  await expect(page.locator('[data-testid="logout-button"]')).toBeVisible();
});

test('should show error message for invalid credentials', async ({ page }) => {
  // Navigate to login page
  await page.goto('https://example.com/login');

  // Fill login form with invalid credentials
  await page.fill('[data-testid="email-input"]', 'wrong@example.com');
  await page.fill('[data-testid="password-input"]', 'wrongpassword');

  // Submit login form
  await page.click('[data-testid="login-submit-button"]');

  // Verify error message
  await expect(page.locator('[data-testid="error-message"]')).toContainText('Invalid email or password');
  await expect(page).toHaveURL('https://example.com/login'); // Should stay on login page
});
```

---

## When to Use Chrome Recorder in Haunt Workflow

### ✅ Use Chrome Recorder When:

1. **Generating test skeleton for complex user flows**
   - Multi-step checkout process
   - Registration flows with multiple pages
   - Admin workflows with many interactions

2. **Onboarding new team members**
   - Demonstrates E2E testing visually
   - Low learning curve for non-technical stakeholders
   - Shows expected user behavior

3. **Demonstrating user flows to stakeholders**
   - Record flow during requirement discussions
   - Export and share as test
   - Becomes living documentation

4. **Exploring application behavior**
   - Understand existing flows before writing tests
   - Capture unexpected interactions
   - Identify edge cases

### ❌ Don't Use Chrome Recorder When:

1. **Need production-ready tests immediately**
   - Generated tests require significant refinement
   - Selectors are brittle and unreliable
   - No assertions for expected outcomes

2. **Working with dynamic content**
   - Generated selectors assume stable DOM structure
   - Dynamic IDs or classes will cause test failures
   - Better to write tests manually with stable selectors

3. **Tests need to handle edge cases**
   - Recorder only captures happy path
   - Error cases must be added manually
   - Validation failures not captured

---

## Integration with Haunt TDD Workflow

Chrome Recorder fits into the TDD workflow as a **skeleton generator**:

### Standard TDD Workflow (without Chrome Recorder):
1. **RED:** Write failing E2E test
2. **GREEN:** Implement feature to pass test
3. **REFACTOR:** Clean up code while keeping test green

### Enhanced TDD Workflow (with Chrome Recorder):
1. **CAPTURE:** Use Chrome Recorder to capture expected user flow
2. **EXPORT:** Export to Playwright and refine selectors
3. **RED:** Verify test fails (feature not yet implemented)
4. **GREEN:** Implement feature to pass test
5. **REFACTOR:** Clean up code while keeping test green

**Time savings:** Chrome Recorder can reduce initial test skeleton creation by 50% for complex flows.

---

## Troubleshooting

### Issue: Exported test fails immediately

**Cause:** Generated selectors are brittle (CSS nth-child, deep CSS paths)

**Solution:** Replace with stable selectors:
```typescript
// ❌ Brittle (from Chrome Recorder)
await page.click('#app > div:nth-child(2) > button');

// ✅ Stable (refactored)
await page.click('[data-testid="submit-button"]');
```

### Issue: Test passes locally but fails in CI/CD

**Cause:** Different viewport sizes, timing issues, or environment differences

**Solution:**
1. Set explicit viewport size: `await page.setViewportSize({ width: 1280, height: 720 });`
2. Add explicit waits: `await page.waitForSelector('[data-testid="element"]');`
3. Use Playwright's auto-waiting features (built-in for most actions)

### Issue: Test is flaky (passes sometimes, fails others)

**Cause:** Race conditions, network delays, or timing issues

**Solution:**
1. Use Playwright's built-in waiting mechanisms (already auto-waits for most actions)
2. Add explicit waits for dynamic content: `await page.waitForLoadState('networkidle');`
3. Increase timeout for slow operations: `await page.click('[data-testid="button"]', { timeout: 10000 });`

---

## Best Practices Summary

1. **Use Chrome Recorder for skeleton generation only** - NOT production-ready tests
2. **Always refine exported tests** - Replace selectors, add assertions, add error cases
3. **Prefer `data-testid` selectors** - More stable than CSS paths
4. **Add error case tests manually** - Chrome Recorder only captures happy path
5. **Run tests in CI/CD** - Ensure stability across environments
6. **Don't commit unrefined tests** - Always refine before committing

---

## Next Steps

After generating and refining tests with Chrome Recorder:
1. Run tests locally: `npx playwright test`
2. Verify tests pass: `npx playwright test --ui` (interactive mode)
3. Add tests to CI/CD (see `Haunt/skills/gco-ui-testing/SKILL.md` for GitHub Actions config)
4. Commit refined tests to version control

**Remember:** Chrome Recorder is a tool to accelerate test creation, not replace careful test design.
