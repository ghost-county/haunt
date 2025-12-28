# UI Testing Protocol

This rule enforces Playwright E2E test generation for frontend features to reduce manual verification overhead.

## When This Rule Applies

**REQUIRED:** Generate Playwright E2E tests when implementing ANY of the following:

### User-Facing Features (Always Test)
- User flows (login, signup, checkout, multi-step forms)
- Interactive UI components (modals, dropdowns, tabs, accordions, carousels)
- Page navigation (routing, redirects, history management)
- Form handling (input validation, submission, error states)
- Visual elements with behavior (responsive layouts, animations, dark mode)
- API integration in UI (data loading states, error handling, pagination)

### Edge Cases That Require Testing
- Authentication/authorization flows (protected routes, session handling)
- Error boundaries and fallback UI
- Loading and skeleton states
- Empty states and zero-data scenarios
- Client-side validation before server submission

## When E2E Tests Are Optional

Skip Playwright tests for:
- Pure backend/API work (use unit tests instead)
- Configuration changes with no UI impact
- Documentation-only changes
- Infrastructure/DevOps work
- Logic that doesn't touch the browser
- Spike code or prototypes (not production features)

## Test Location Requirements

### Standard Project Structure
Place E2E tests in project-appropriate locations:

| Project Type | Test Location | Naming Convention |
|--------------|---------------|-------------------|
| Next.js/React | `tests/e2e/` or `e2e/` | `*.spec.ts` |
| Vue | `tests/e2e/` | `*.spec.ts` |
| Generic Frontend | `tests/e2e/` | `*.spec.ts` |

### Haunt Framework Projects
For Ghost County or framework development:
- **Location:** `.haunt/tests/e2e/`
- **Naming:** `test_*.py` or `*.spec.ts`
- **Purpose:** Tests for framework tooling, setup scripts, agent behavior

### Naming Conventions
- Feature tests: `{feature-name}.spec.ts`
- Page tests: `{page-name}.spec.ts`
- Flow tests: `{flow-name}-flow.spec.ts`
- From requirements: `req-{XXX}.spec.ts`

## Integration with Existing Skills

This rule works with the `gco-playwright-tests` skill:

**Workflow:**
1. **Rule triggers** (automatic): When you identify UI work, this rule enforces E2E test requirement
2. **Skill provides guidance** (on-demand): Invoke `gco-playwright-tests` skill for test generation patterns
3. **Skill has examples**: The skill contains test templates, best practices, and common patterns

**Do NOT duplicate content from the skill.** Reference it instead:
- For test templates: See `gco-playwright-tests` skill
- For selector strategies: See `gco-playwright-tests` skill
- For common patterns: See `gco-playwright-tests` skill

## TDD Workflow for UI Features

Follow this sequence for all UI work:

### 1. Write Failing E2E Test FIRST
```typescript
// RED: Test describes expected behavior before implementation exists
test('should display user profile after login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('[data-testid="login-button"]');

  // These assertions will FAIL until feature is implemented
  await expect(page).toHaveURL('/profile');
  await expect(page.locator('[data-testid="user-name"]')).toBeVisible();
});
```

### 2. Implement Feature to Pass Test
```typescript
// GREEN: Implement minimal code to make test pass
// (Your React/Vue/etc. component implementation)
```

### 3. Refactor While Tests Stay Green
```typescript
// REFACTOR: Clean up implementation, tests verify nothing breaks
// (Optimize, extract helpers, improve naming, etc.)
```

## Verification Before Completion

Before marking ANY frontend requirement as 🟢 Complete, verify:

### Required Checks
- [ ] E2E tests exist for all user-facing behavior
- [ ] Tests are in correct location (tests/e2e/ or .haunt/tests/e2e/)
- [ ] Tests follow naming conventions
- [ ] All E2E tests pass: `npx playwright test`
- [ ] Tests cover happy path AND error cases
- [ ] Tests are independent (don't rely on order or shared state)

### Running E2E Tests
```bash
# Run all Playwright tests
npx playwright test

# Run specific test file
npx playwright test tests/e2e/feature-name.spec.ts

# Run in headed mode (visible browser, useful for debugging)
npx playwright test --headed

# Debug failing tests
npx playwright test --debug
```

### CI/CD Integration
If project has CI/CD pipeline, E2E tests MUST pass in CI before merge:
- GitHub Actions: Check workflow includes `npx playwright test`
- GitLab CI: Check `.gitlab-ci.yml` includes Playwright step
- Other CI: Verify E2E tests run automatically on PR/MR

## Completion Checklist Integration

This rule extends `gco-completion-checklist.md` for frontend work:

**Standard completion checklist items:**
1. All Tasks Checked Off
2. Completion Criteria Met
3. Tests Passing ← **This rule adds E2E test requirement here**
4. Files Updated
5. Documentation Updated

**E2E-specific additions:**
- Tests Passing MUST include: `npx playwright test` (not just unit tests)
- Files Updated MUST include: E2E test file(s) in tests/e2e/
- If E2E tests don't exist, requirement CANNOT be marked 🟢

## Common Mistakes to Avoid

### WRONG: Skipping E2E Tests
```markdown
### REQ-XXX: Add user login form

Tasks:
- [x] Created login component
- [x] Added form validation
- [x] Integrated with auth API
- [ ] ~~Write E2E tests~~ (skipped - will test manually)

Status: 🟢 Complete  ← VIOLATION: Cannot mark complete without E2E tests
```

### RIGHT: E2E Tests Included
```markdown
### REQ-XXX: Add user login form

Tasks:
- [x] Created login component
- [x] Added form validation
- [x] Integrated with auth API
- [x] Created tests/e2e/login.spec.ts with full flow coverage
- [x] Verified all Playwright tests pass

Status: 🟢 Complete  ← CORRECT: E2E tests exist and pass
```

### WRONG: Testing Implementation Details
```typescript
// Bad: Tests internal state instead of user-visible behavior
test('should set isLoading to true', async ({ page }) => {
  // Cannot test React state directly in E2E test
});
```

### RIGHT: Testing User-Visible Behavior
```typescript
// Good: Tests what users see and experience
test('should show loading spinner during login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('[data-testid="login-button"]');

  // Verify loading spinner appears
  await expect(page.locator('[data-testid="loading-spinner"]')).toBeVisible();

  // Verify loading spinner disappears after request completes
  await expect(page.locator('[data-testid="loading-spinner"]')).not.toBeVisible();
});
```

## Agent Workflow

### Dev-Frontend Agent
When assigned UI work:
1. Read requirement and identify user-facing behavior
2. **BEFORE implementation**: Write failing E2E test(s)
3. Run `npx playwright test` to verify test fails (RED)
4. Implement feature to make test pass (GREEN)
5. Run `npx playwright test` to verify test passes
6. Refactor if needed, keeping tests green
7. **BEFORE marking 🟢**: Verify all Playwright tests pass

### Dev-Backend Agent
When work includes UI integration:
1. Coordinate with Dev-Frontend for E2E test coverage
2. Ensure API endpoints support E2E test scenarios
3. If implementing API for frontend feature, wait for E2E tests to exist before marking complete

### Code-Reviewer Agent
When reviewing frontend PRs:
1. Verify E2E tests exist for all UI changes
2. Check tests are in correct location
3. Verify tests pass in CI/CD
4. Reject PR if E2E tests missing for user-facing changes

## Non-Negotiable Rules

1. **NEVER mark frontend requirement 🟢 without E2E tests**
   - If tests don't exist, requirement is incomplete
   - Manual testing is NOT a substitute for automated E2E tests

2. **NEVER skip E2E tests "because it's simple"**
   - Simple features still need tests
   - "Simple" bugs are the most embarrassing in production

3. **NEVER commit failing E2E tests**
   - All Playwright tests must pass before commit
   - Use `npx playwright test` to verify before committing

4. **ALWAYS write tests before implementation (TDD)**
   - Write failing test first (RED)
   - Implement to make it pass (GREEN)
   - Refactor while keeping tests green

5. **ALWAYS test user behavior, not implementation**
   - Test what users see and do
   - Don't test internal state or component props
   - Focus on user flows and interactions

## Consequences of Bypassing E2E Tests

**If you mark a UI requirement 🟢 Complete without E2E tests:**

### Immediate Consequences
1. **Requirement marked incomplete** - Status reverted to 🟡 In Progress
2. **Work flagged for review** - Code Reviewer notified of violation
3. **Commit rejected** - If verification script runs in pre-commit/CI
4. **PR blocked** - If E2E tests missing in pull request

### Professional Consequences
- **Reputation damage** - Pattern of bypassing tests damages professional credibility
- **Loss of autonomy** - Repeated violations trigger mandatory code review for all work
- **Quality metrics** - Tracked as quality incident in project metrics
- **Team impact** - Untested code causes bugs for other developers

### Project Consequences
- **Production bugs** - Untested UI ships broken features to users
- **Manual testing burden** - QA team must catch what automated tests should have
- **Regression risk** - No protection against future changes breaking the feature
- **Technical debt** - Missing tests accumulate, harder to add later

### Verification Script Enforcement

Use the verification script before marking complete:

```bash
# Check if E2E tests exist for your requirement
bash Haunt/scripts/verify-e2e-tests.sh REQ-XXX frontend

# Exit code 0 = Tests exist (safe to mark 🟢)
# Exit code 1 = Tests missing (CANNOT mark 🟢)
```

### What Happens When You Bypass

**Scenario: Dev marks REQ-XXX 🟢 without E2E tests**

1. **Code Reviewer runs verification:**
   ```bash
   $ bash Haunt/scripts/verify-e2e-tests.sh REQ-XXX frontend
   ERROR: No E2E tests found for UI requirement REQ-XXX
   ERROR: Requirement CANNOT be marked 🟢 Complete without E2E tests
   ```

2. **Code Reviewer verdict: CHANGES_REQUESTED**
   - Status reverted to 🟡
   - Blocked from merge
   - Must write tests before re-submitting

3. **Pattern tracked:**
   - First violation: Warning + requirement to fix
   - Second violation: Automatic code review for next 3 requirements
   - Third violation: Escalation to PM for process review

### Professional Standard

**From the CTO:**
> "If you wouldn't demo untested UI to your boss, don't mark it complete."

E2E tests are not optional. They are **professional accountability**. Untested UI is **incomplete work**, not "done except for tests."

## See Also

- `Haunt/skills/gco-playwright-tests/SKILL.md` - Detailed test patterns and examples
- `Haunt/skills/gco-tdd-workflow/SKILL.md` - General TDD guidance
- `Haunt/commands/qa.md` - Generate test scenarios from requirements
- `.claude/rules/gco-completion-checklist.md` - General completion requirements
- `Haunt/docs/BROWSER-MCP-SETUP.md` - Browser MCP installation guide
