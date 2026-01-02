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

⛔ **CONSULTATION GATE:** For complete user journey examples including login flow, payment flow, and purchase flow with TDD workflow integration, READ `references/testing-scenarios.md`.

## Reference Index

| When You Need | Read This |
|---------------|-----------|
| **Detailed user journey examples** (login, payment, purchase flows) | `references/testing-scenarios.md` |
| **Testing mistake examples** (5 common mistakes with WRONG/RIGHT code) | `references/testing-scenarios.md` |
| **Comprehensive validation checklists** (data, error, UX, performance) | `references/validation-checklists.md` |
| **Professional standards checklist** (CTO demo test, confidence questions) | `references/validation-checklists.md` |

## Consultation Gates

⛔ **CONSULTATION GATE:** When encountering common testing mistakes (testing implementation, ignoring errors, brittle tests, insufficient edge cases, manual-only testing), READ `references/testing-scenarios.md` for detailed examples and corrections.

⛔ **CONSULTATION GATE:** Before marking M-sized requirements complete, READ `references/validation-checklists.md` for comprehensive testing checklist (happy path, error path, edge cases, UX, production readiness).

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

Before marking complete, verify 5 categories:

1. **Data Validation** - Empty, boundary, special chars, malformed
2. **Error Handling** - Network, permissions, race conditions, conflicts
3. **User Experience** - Loading states, error messages, keyboard nav, mobile
4. **Business Logic** - Calculations, permissions, state transitions, integrity
5. **Performance** - Large datasets, concurrent users, memory, queries

⛔ **CONSULTATION GATE:** For complete validation checklist with all items, READ `references/validation-checklists.md`.

## Quick Testing Checklist (M-Sized Features)

Use this abbreviated checklist during implementation:

### Happy Path Testing
- [ ] User can complete intended task start-to-finish
- [ ] User receives success confirmation
- [ ] Data persisted to database
- [ ] Navigation redirects correctly
- [ ] Automated E2E test exists

### Error Path Testing
- [ ] Network errors handled gracefully
- [ ] Validation errors show clear messages
- [ ] Permission errors handled
- [ ] Resource conflicts handled (duplicate, not found)
- [ ] Form state preserved on error
- [ ] Automated error tests exist

### Edge Case Testing
- [ ] Empty input handled (null, undefined, empty string)
- [ ] Boundary values tested (0, -1, max int)
- [ ] Special characters supported (emoji, quotes)
- [ ] Type mismatches caught
- [ ] Concurrent actions safe (double submit)
- [ ] Automated edge case tests exist

### UX Validation
- [ ] Loading states visible
- [ ] Error states clear
- [ ] Success states confirmed
- [ ] Keyboard navigation works
- [ ] Screen reader accessible
- [ ] Mobile responsive (320px min)
- [ ] Contrast ratios meet WCAG AA (4.5:1)

### Production Readiness
- [ ] Logging added for errors
- [ ] Metrics emitted (latency, error rate)
- [ ] Performance acceptable under load
- [ ] Security reviewed (input sanitized, permissions enforced)
- [ ] Rollback plan exists
- [ ] Documentation updated

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

⛔ **CONSULTATION GATE:** For complete TDD workflow with user journey example (purchase flow with RED/GREEN/REFACTOR steps), READ `references/testing-scenarios.md`.

## Professional Standards Checklist (Quick Reference)

Before marking any requirement 🟢 Complete, answer:

### The CTO Demo Test
- [ ] **Would I confidently demo this to my CTO on Monday?**

### Confidence Questions
- [ ] **Works in production?** (not just "works on my machine")
- [ ] **Handles errors gracefully?** (no crashes or generic errors)
- [ ] **Won't break under load?** (concurrent users, large datasets)
- [ ] **Can debug in production?** (logging, metrics in place)

### Professional Quality Gates
- [ ] **Automated tests exist and pass**
- [ ] **Tests cover happy path, errors, and edge cases**
- [ ] **Error messages are user-friendly**
- [ ] **Performance is acceptable**
- [ ] **Security reviewed**

### User Perspective Validation
- [ ] **User can accomplish their goal** (JTBD achievable)
- [ ] **User receives clear feedback** (loading, success, error states)
- [ ] **User can recover from mistakes** (errors explain how to fix)
- [ ] **Accessibility works** (keyboard, screen reader, contrast)

⛔ **CONSULTATION GATE:** For complete professional standards checklist with detailed questions and quality gates, READ `references/validation-checklists.md`.

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
