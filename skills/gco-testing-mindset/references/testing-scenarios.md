# Testing Scenarios: Common Mistakes and Examples

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

---

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

---

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

---

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

---

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

---

## User Journey Scenario Examples

### Example 1: Login Journey Mapping

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

---

### Example 2: Payment Feature Journey

**Technical Focus (WRONG):**
- Test: "POST /api/payment returns 200"
- Test: "Payment object created in database"
- Test: "Payment processor API called"

**User Journey Focus (RIGHT):**
- Test: "User can purchase product with valid credit card"
- Test: "User sees clear error for invalid card number"
- Test: "User receives confirmation email after successful payment"
- Test: "User's cart is cleared after successful payment"

---

## TDD Workflow with User Journey

### Example: Purchase Flow

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

---

## User Journey Template

Use this template when mapping user journeys:

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

---

## "Works for Me" vs "Works for Users" Problem

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

### Mapping Complete User Journeys

For every feature, map the COMPLETE journey:

1. **Entry Point:** Where does the user start? (homepage, email link, notification)
2. **Happy Path Steps:** What steps lead to success?
3. **Expected Outcomes:** What should the user see/receive at each step?
4. **Error Recovery:** What happens when things go wrong? Can the user fix it?
5. **Exit Points:** How does the journey end? (success, abandonment, error)
