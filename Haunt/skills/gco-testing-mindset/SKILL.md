---
name: gco-testing-mindset
description: Comprehensive testing guidance for complex features, teaching how to test from a user's perspective and professional accountability standards.
---

# Testing Mindset: Professional Quality and User-Centric Validation

## Purpose

This skill provides comprehensive testing guidance for M-sized and complex features, teaching agents how to think about testing from a user's perspective, not just technical validation. It emphasizes professional accountability and the "Would I demonstrate this to my boss?" standard.

## When to Invoke

- Implementing M-sized requirements (2-4 hours, 4-8 files)
- Complex features spanning multiple components or systems
- Features with critical business impact or user-facing behavior
- When unsure how comprehensive tests should be
- Before marking any requirement as 🟢 Complete
- When tests exist but feel incomplete or superficial

## The Professional Standard

### Testing from the CTO's Perspective

Before marking any work complete, ask yourself:

**"Would I confidently demonstrate this to my CTO/boss on Monday morning?"**

This question reframes testing from bureaucratic checkbox to professional accountability:

- **Not about compliance:** "Did I write tests?" (checkbox mentality)
- **About confidence:** "Would this hold up in a demo? In production? Under scrutiny?"

### The CTO's Questions

When you demo your work, they will ask:

1. **"What happens when the API is down?"** (Error handling)
2. **"What if the user enters garbage data?"** (Input validation)
3. **"Can this handle 1000 concurrent users?"** (Performance/scalability)
4. **"What if they click the button twice?"** (Race conditions)
5. **"How will we debug this in production?"** (Observability)

**If you can't answer these questions, your tests are incomplete.**

### Professional vs. Amateur Testing

| Amateur Mindset | Professional Mindset |
|-----------------|---------------------|
| "It works on my machine" | "It works for all users in all scenarios" |
| Tests only happy path | Tests happy path, errors, and edge cases |
| "I tested it manually" | Automated tests prove it works |
| "No bugs found" | Actively hunted for ways to break it |
| "Done when feature works" | Done when confident it won't break |

## User Journey Mapping for Testing

### Why User Journeys Matter

**Technical tests answer:** "Does the code work?"
**User journey tests answer:** "Does the user succeed?"

These are NOT the same thing. Code can work perfectly while the user experience is broken.

### The JTBD Framework for Test Design

**Jobs-To-Be-Done (JTBD):** What is the user trying to accomplish?

#### Example: Payment Feature

**WRONG (Technical Focus):**
- Test: "POST /api/payment returns 200"
- Test: "Payment object created in database"
- Test: "Payment processor API called"

**RIGHT (User Journey Focus):**
- Test: "User can purchase product with valid credit card"
- Test: "User sees clear error for invalid card number"
- Test: "User receives confirmation email after successful payment"
- Test: "User's cart is cleared after successful payment"

### Mapping Complete User Journeys

For every feature, map the COMPLETE journey:

1. **Entry Point:** Where does the user start? (homepage, email link, notification)
2. **Happy Path Steps:** What steps lead to success?
3. **Expected Outcomes:** What should the user see/receive at each step?
4. **Error Recovery:** What happens when things go wrong? Can the user fix it?
5. **Exit Points:** How does the journey end? (success, abandonment, error)

### User Journey Template

```gherkin
Feature: {Feature Name}

  Background: User Goal
    As a {user type}
    I want to {accomplish goal}
    So that {benefit/value}

  Scenario: Happy Path - User Succeeds
    Given {starting context}
    When {user action 1}
    And {user action 2}
    Then {expected outcome}
    And {confirmation/feedback}

  Scenario: Error Path - User Recovers from Mistake
    Given {starting context}
    When {user makes mistake}
    Then {clear error message appears}
    And {error explains how to fix it}
    When {user corrects mistake}
    Then {user succeeds}

  Scenario: Edge Case - Unusual but Valid Scenario
    Given {unusual starting context}
    When {user action}
    Then {system handles gracefully}
```

### Example: Login Journey Mapping

**Complete Journey:**

```gherkin
Feature: User Login

  Scenario: Happy Path - Successful Login
    Given the user is on the login page
    When they enter valid email "user@example.com"
    And they enter valid password "SecurePass123!"
    And they click "Log In"
    Then they are redirected to dashboard
    And they see welcome message "Welcome back, User"
    And their session is persisted (refresh doesn't log out)

  Scenario: Error Recovery - Wrong Password
    Given the user is on the login page
    When they enter valid email "user@example.com"
    And they enter wrong password "WrongPass"
    And they click "Log In"
    Then error message appears: "Invalid email or password"
    And the email field retains entered value
    And the password field is cleared
    When they enter correct password "SecurePass123!"
    And they click "Log In"
    Then they successfully log in

  Scenario: Edge Case - Account Locked After 5 Failed Attempts
    Given the user has failed login 4 times already
    When they enter wrong password again
    And they click "Log In"
    Then error message appears: "Account locked. Reset password to unlock."
    And "Reset Password" link is displayed
    And login button is disabled
```

**What This Tests:**
- ✅ Happy path works
- ✅ Clear error messages
- ✅ Form state after error (email retained, password cleared)
- ✅ Error recovery path
- ✅ Security edge case (account locking)
- ✅ User can fix the problem

## The "Works for Me" vs "Works for Users" Problem

### Common Mistake: "Works for Me" Testing

**Scenario:** Agent implements feature, tests manually in their environment, marks complete.

**Problem:** Agent's environment is NOT production:
- Fresh database with clean test data
- Localhost with no network latency
- No concurrent users
- No browser extensions or ad blockers
- No slow connections or mobile devices
- No unusual edge cases in data

**Reality:** Production has ALL of these problems.

### "Works for Users" Validation

Before marking complete, verify:

#### 1. Data Validation
- [ ] Empty input (empty string, null, undefined)
- [ ] Boundary values (0, -1, max int, very large numbers)
- [ ] Special characters (emoji, quotes, SQL characters)
- [ ] Unexpected types (string instead of number, object instead of array)
- [ ] Missing required fields
- [ ] Malformed data (invalid email, bad phone format)

#### 2. Error Handling
- [ ] Network failures (API down, timeout, slow connection)
- [ ] Permission errors (unauthorized, forbidden)
- [ ] Race conditions (double submit, concurrent requests)
- [ ] State conflicts (resource already exists, deleted, modified)
- [ ] Third-party failures (payment gateway down, email service unavailable)

#### 3. User Experience
- [ ] Loading states visible (spinner, skeleton, progress)
- [ ] Error messages clear and actionable
- [ ] Success confirmation displayed
- [ ] Form state preserved on error (don't lose user's work)
- [ ] Keyboard navigation works
- [ ] Screen reader announces changes
- [ ] Mobile viewport tested (320px minimum)

#### 4. Business Logic
- [ ] Calculations correct (no rounding errors, overflow)
- [ ] Permissions enforced (can't access others' data)
- [ ] State transitions valid (can't skip steps in flow)
- [ ] Data integrity maintained (no orphaned records)

#### 5. Performance
- [ ] Large datasets handled (1000+ items)
- [ ] Concurrent users don't conflict
- [ ] No memory leaks (repeated actions don't degrade)
- [ ] Database queries optimized (no N+1 queries)

## Comprehensive Testing Checklist

Use this checklist for EVERY M-sized feature before marking complete:

### Happy Path Testing
- [ ] **Primary flow works:** User can complete intended task start-to-finish
- [ ] **Success confirmation:** User receives clear feedback on success
- [ ] **Data persisted:** Changes saved correctly to database
- [ ] **Navigation correct:** User redirected to appropriate next page
- [ ] **Automated test exists:** E2E or integration test covers happy path

### Error Path Testing
- [ ] **Network errors handled:** API down, timeout, slow connection
- [ ] **Validation errors clear:** Error messages explain what's wrong and how to fix
- [ ] **Permission errors graceful:** Clear message if user lacks access
- [ ] **Resource conflicts handled:** Duplicate, not found, already deleted
- [ ] **Form state preserved:** User doesn't lose work on error
- [ ] **Automated test exists:** Tests verify error handling

### Edge Case Testing
- [ ] **Empty input handled:** Null, undefined, empty string, empty array
- [ ] **Boundary values tested:** 0, -1, max int, very large numbers
- [ ] **Special characters supported:** Emoji, quotes, apostrophes, SQL characters
- [ ] **Type mismatches caught:** Wrong type validation before use
- [ ] **Concurrent actions safe:** Double submit, simultaneous edits
- [ ] **Automated test exists:** Tests cover edge cases

### UX Validation
- [ ] **Loading states visible:** Spinner, skeleton, or progress indicator
- [ ] **Error states clear:** User understands what went wrong
- [ ] **Success states confirmed:** User knows action succeeded
- [ ] **Keyboard navigation works:** Tab, Enter, Esc function correctly
- [ ] **Screen reader accessible:** ARIA labels, semantic HTML
- [ ] **Mobile responsive:** Tested at 320px minimum width
- [ ] **Contrast ratios meet WCAG AA:** 4.5:1 minimum for text

### Production Readiness
- [ ] **Logging added:** Error conditions logged with context
- [ ] **Metrics emitted:** Key operations tracked (latency, error rate)
- [ ] **Performance acceptable:** Handles expected load without degradation
- [ ] **Security reviewed:** Input sanitized, permissions enforced, secrets not exposed
- [ ] **Rollback plan:** Can revert changes if issues found
- [ ] **Documentation updated:** README, API docs, or comments explain feature

## Common Testing Mistakes

### Mistake 1: Testing Only Implementation

**WRONG:**
```typescript
test('login function calls API', async () => {
  const mockApi = jest.fn();
  login(mockApi, 'user@example.com', 'password');
  expect(mockApi).toHaveBeenCalled();
});
```

**Why Wrong:** Tests internal implementation (API call), not user outcome.

**RIGHT:**
```typescript
test('user can log in with valid credentials', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'SecurePass123!');
  await page.click('[data-testid="login-button"]');

  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
});
```

**Why Right:** Tests user-visible outcome (dashboard loaded, welcome message shown).

### Mistake 2: Ignoring Error Cases

**WRONG:**
```typescript
test('user submits form', async () => {
  const result = await submitForm({ name: 'John', email: 'john@example.com' });
  expect(result.success).toBe(true);
});
```

**Why Wrong:** Only tests happy path. What about validation errors? Network failures?

**RIGHT:**
```typescript
test('user submits valid form', async () => {
  const result = await submitForm({ name: 'John', email: 'john@example.com' });
  expect(result.success).toBe(true);
});

test('user sees error for missing name', async () => {
  const result = await submitForm({ name: '', email: 'john@example.com' });
  expect(result.error).toBe('Name is required');
});

test('user sees error for invalid email', async () => {
  const result = await submitForm({ name: 'John', email: 'not-an-email' });
  expect(result.error).toBe('Email must be valid');
});

test('user sees error when network fails', async () => {
  mockNetworkFailure();
  const result = await submitForm({ name: 'John', email: 'john@example.com' });
  expect(result.error).toBe('Unable to submit form. Please try again.');
});
```

**Why Right:** Tests validation, network errors, and error messages.

### Mistake 3: Brittle Tests (Test Implementation Details)

**WRONG:**
```typescript
test('form state updates on change', () => {
  const { getByTestId } = render(<LoginForm />);
  fireEvent.change(getByTestId('email'), { target: { value: 'test@example.com' } });

  // Tests internal React state - breaks on refactoring
  expect(component.state.email).toBe('test@example.com');
});
```

**Why Wrong:** Tests internal component state, which is implementation detail.

**RIGHT:**
```typescript
test('user can enter email and see it in the field', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'test@example.com');

  // Tests user-visible behavior
  await expect(page.locator('[data-testid="email"]')).toHaveValue('test@example.com');
});
```

**Why Right:** Tests user-visible behavior (field value), not internal state.

### Mistake 4: Insufficient Edge Case Coverage

**WRONG:**
```typescript
test('calculates total', () => {
  expect(calculateTotal([10, 20, 30])).toBe(60);
});
```

**Why Wrong:** Only tests typical input. What about edge cases?

**RIGHT:**
```typescript
test('calculates total for normal input', () => {
  expect(calculateTotal([10, 20, 30])).toBe(60);
});

test('calculates total for empty input', () => {
  expect(calculateTotal([])).toBe(0);
});

test('calculates total for single item', () => {
  expect(calculateTotal([42])).toBe(42);
});

test('calculates total for negative numbers', () => {
  expect(calculateTotal([-10, -20])).toBe(-30);
});

test('calculates total for mixed positive and negative', () => {
  expect(calculateTotal([10, -5, 20])).toBe(25);
});

test('throws error for invalid input', () => {
  expect(() => calculateTotal(null)).toThrow('Input must be array');
  expect(() => calculateTotal([1, 'two', 3])).toThrow('All items must be numbers');
});
```

**Why Right:** Tests edge cases (empty, single item, negatives, mixed, invalid input).

### Mistake 5: Manual Testing Only

**WRONG:**
- Agent implements feature
- Manually tests in browser
- Marks requirement complete
- No automated tests

**Why Wrong:** Manual tests don't scale, aren't repeatable, and provide no regression protection.

**RIGHT:**
- Agent implements feature
- Writes automated E2E or integration tests FIRST (TDD)
- Tests include happy path, errors, and edge cases
- Manually verifies test coverage is comprehensive
- Marks requirement complete with high confidence

**Why Right:** Automated tests are repeatable, catch regressions, and prove functionality.

## Integration with TDD Workflow

Use this skill alongside `gco-tdd-workflow` for systematic test development:

### TDD + Testing Mindset

**Step 1: RED - Write Comprehensive Failing Tests**

Using user journey mapping, write tests for:
- Happy path (primary user flow)
- Error recovery (user fixes mistakes)
- Edge cases (unusual but valid scenarios)

**Step 2: GREEN - Implement to Pass All Tests**

Implement feature with:
- Error handling (try/catch, validation)
- Edge case handling (null checks, boundary validation)
- User feedback (loading states, error messages, success confirmation)

**Step 3: REFACTOR - Improve While Tests Stay Green**

Refactor for:
- Code clarity (descriptive names, focused functions)
- Performance (optimize queries, reduce redundancy)
- Maintainability (extract helpers, add comments)

### Example TDD Workflow with User Journey

**1. Map User Journey:**
```
User Goal: Purchase product
Steps: Add to cart → View cart → Enter shipping → Enter payment → Confirm
Expected Outcome: Order placed, confirmation email sent, inventory updated
```

**2. Write Failing Tests (RED):**
```typescript
test('user can complete purchase flow', async ({ page }) => {
  // Add to cart
  await page.goto('/products/wireless-mouse');
  await page.click('[data-testid="add-to-cart"]');

  // View cart
  await page.click('[data-testid="cart-icon"]');
  await expect(page.locator('[data-testid="cart-item"]')).toHaveCount(1);

  // Checkout
  await page.click('[data-testid="checkout-button"]');

  // Enter shipping
  await page.fill('[data-testid="shipping-address"]', '123 Main St');
  await page.fill('[data-testid="shipping-city"]', 'San Francisco');
  await page.click('[data-testid="continue-to-payment"]');

  // Enter payment
  await page.fill('[data-testid="card-number"]', '4111111111111111');
  await page.fill('[data-testid="card-expiry"]', '12/25');
  await page.fill('[data-testid="card-cvv"]', '123');
  await page.click('[data-testid="place-order"]');

  // Confirm order placed
  await expect(page.locator('[data-testid="order-confirmation"]')).toBeVisible();
  await expect(page.locator('[data-testid="order-number"]')).toContainText(/^ORDER-\d{8}$/);
});

test('user sees error for invalid card', async ({ page }) => {
  // ... navigate to payment step ...
  await page.fill('[data-testid="card-number"]', '1234'); // Invalid
  await page.click('[data-testid="place-order"]');

  await expect(page.locator('[data-testid="error-message"]')).toContainText('Invalid card number');
  await expect(page.locator('[data-testid="order-confirmation"]')).not.toBeVisible();
});
```

**3. Implement Feature (GREEN):**
- Build each step of journey
- Add validation and error handling
- Make tests pass

**4. Refactor (Keep Tests Green):**
- Extract Page Object Model patterns
- Optimize database queries
- Improve error messages

## Professional Standards Checklist

Before marking any requirement 🟢 Complete, answer these questions:

### The CTO Demo Test

- [ ] **Would I confidently demo this to my CTO on Monday?**
  - If NO: What's missing? Add tests/fixes until the answer is YES.

### Confidence Questions

- [ ] **Am I confident this works in production?**
  - Not just "works on my machine" - works for real users with real data

- [ ] **Am I confident this handles errors gracefully?**
  - User won't see generic "Something went wrong" or crash

- [ ] **Am I confident this won't break under load?**
  - Handles concurrent users, large datasets, slow networks

- [ ] **Am I confident I can debug this in production?**
  - Logging, metrics, error tracking are in place

### Professional Quality Gates

- [ ] **Automated tests exist and pass**
  - Not just manual verification - repeatable automated tests

- [ ] **Tests cover happy path, errors, and edge cases**
  - Not just "it works once" - comprehensive coverage

- [ ] **Error messages are user-friendly**
  - Clear, actionable, don't expose internals

- [ ] **Performance is acceptable**
  - Tested with realistic data volumes

- [ ] **Security reviewed**
  - Input sanitized, permissions enforced, secrets protected

### User Perspective Validation

- [ ] **User can accomplish their goal**
  - The JTBD (Job To Be Done) is achievable start-to-finish

- [ ] **User receives clear feedback**
  - Loading, success, and error states are visible

- [ ] **User can recover from mistakes**
  - Error messages explain how to fix problems

- [ ] **Accessibility works**
  - Keyboard navigation, screen readers, contrast ratios

## Success Criteria

You've achieved the professional testing standard when:

1. **You can confidently demo the feature** without fear of it breaking
2. **Tests cover realistic scenarios**, not just happy path
3. **Error handling is comprehensive**, user never sees crashes
4. **You've actively tried to break it** and fixed what you found
5. **You can explain how it will behave** in production under load

**Remember:** Testing isn't a bureaucratic checkbox. It's professional accountability. Would you put your name on this work?

## See Also

- `gco-tdd-workflow` - Test-driven development cycle
- `gco-playwright-tests` - E2E test generation patterns
- `gco-ui-testing` - UI testing protocol and enforcement
- `gco-code-patterns` - Error handling and anti-patterns
- `.claude/rules/gco-completion-checklist.md` - Completion requirements
