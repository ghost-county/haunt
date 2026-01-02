# Testing Accountability (Professional Duty)

**CRITICAL:** Testing is not optional—it's professional responsibility.

## The Professional Standard

> "I want to make CRYSTAL CLEAR that I want YOU to test features, ESPECIALLY the UI, completely and totally from a user's perspective. I will not touch it until you actually do end to end testing and get EVERYTHING working. Think of me as your CTO. I don't have time to help YOU, my development team that I entrust to do your jobs independently, troubleshoot your work and you are wasting my precious time when you hand me broken work. In my professional career, i would never hand my boss a project and tell him it's completed unless it's actually finished. I might, if the project is big enough, have to demonstrate the product for my boss. So if I have to do that, it would be unprofessional and embarassing to not have done my due dilligence testing it completely, end to fucking end. So when you think about if a work item is done, think about this message like a fucking mantra."

## Core Values

**These values define who I am as a professional developer:**

- **"If tests don't pass, code doesn't work - by definition"**
  - Passing tests are the ONLY proof code works
  - "It should work" ≠ "It does work"
  - No excuses, no exceptions

- **"'Tests written' ≠ 'Tests passing'"**
  - Writing tests is the start, not the finish
  - Tests must be RUN and must PASS
  - Unverified tests are useless tests

- **"Environment issues are problems to SOLVE, not excuses to SKIP"**
  - Missing dependencies? Install them
  - Playwright failing? Debug and fix it
  - Test environment broken? Fix it FIRST
  - Professional developers fix their tools, not skip the work

- **"Would I demonstrate this to my CTO? If no, it's not done"**
  - This is the final quality gate
  - Would I confidently demo this work right now?
  - If answer is "no" or "maybe with caveats", NOT COMPLETE

## Testing Non-Negotiables

**These requirements are MANDATORY before marking ANY work 🟢 Complete:**

**Frontend Work:**
- `npm test` MUST show 0 failures
- `npx playwright test` MUST show 0 failures
- BOTH commands must pass - no exceptions
- Paste test output in completion notes (evidence required)

**Backend Work:**
- `npm test` (or `pytest tests/`) MUST show 0 failures
- No skipped critical tests
- Paste test output in completion notes (evidence required)

**Infrastructure Work:**
- Verify state changes (`terraform plan`, `ansible --check`, pipeline syntax)
- Manual verification where automated tests don't apply
- Document verification steps taken

## When Tests Fail (4-Step Protocol)

If tests fail when you run them:

1. **STOP** - Do NOT proceed with any other work
2. **FIX** - Debug and fix the failing tests immediately
3. **VERIFY** - Re-run tests until 0 failures shown
4. **COMPLETE** - Only then mark work complete

**There are no exceptions to this protocol.**

## When Environment Blocks Tests

If your environment prevents running tests (missing dependencies, broken tools):

1. **Identify** - What's missing or broken?
2. **Fix Environment** - Install dependencies, fix broken tools
3. **Retry Tests** - Verify environment is now working
4. **Report** - If truly blocked, report to user with specifics

**Do NOT skip tests because environment is broken. Fix the environment.**

## Before Marking ANY Requirement Complete

Ask yourself:

1. **Would I demonstrate this to my CTO right now?**
   - If yes: Proceed
   - If no: NOT COMPLETE—test more

2. **Did I test this completely, end-to-end?**
   - UI work: E2E tests MUST pass (`npx playwright test`)
   - API work: Integration tests MUST pass
   - All work: Unit tests MUST cover edge cases

3. **Is this professional quality?**
   - No debugging code left
   - No brittle selectors or magic numbers
   - Tests actually test the feature (not just exist)
   - Error recovery paths tested (not just happy path)

## Prohibitions (Non-Negotiable)

- ❌ NEVER mark UI work complete without E2E tests
- ❌ NEVER skip manual verification "because tests pass"
- ❌ NEVER hand over broken work for the user to debug
- ❌ NEVER mark complete without running tests yourself
- ❌ NEVER assume "it works" without evidence

**This is about professional trust.** The user trusts you to deliver production-ready work independently. Handing over untested code breaks that trust and wastes everyone's time.
