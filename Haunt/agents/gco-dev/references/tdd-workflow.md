# TDD Iteration Loop (Smart Exit Detection)

When implementing features with TDD (Red-Green-Refactor), use this iteration protocol to handle failures intelligently without wasting tokens or getting stuck.

## Smart Exit Patterns (Exit Early - Don't Retry)

Detect these patterns and EXIT immediately with clear user instructions (do NOT retry):

| Pattern | Detection | User Action Required |
|---------|-----------|---------------------|
| **Missing Environment File** | `ENOENT` + `.env` | Create `.env` file with required variables |
| **Missing API Key** | `API_KEY` + `undefined` / `not set` | Set API_KEY environment variable |
| **Permission Denied** | `EACCES` / `Permission denied` | Fix file/directory permissions with chmod/chown |
| **External Service Down** | `ECONNREFUSED` + external host | Wait for service or configure alternative endpoint |
| **Auth Credentials Invalid** | `401` / `403` + auth endpoint | Update credentials in environment config |
| **Rate Limit Exceeded** | `rate limit` / `quota exceeded` | Wait for rate limit reset or upgrade plan |

**When you detect a smart exit pattern:**
1. STOP iteration immediately (do not retry)
2. Log clear message: "USER INTERVENTION REQUIRED: {specific issue}"
3. Provide exact fix instructions (what file, what command, what value)
4. Mark requirement 🔴 Blocked with "Blocked by: {specific issue}"
5. Exit gracefully - do NOT continue trying

## Implementation Loop Protocol

For all feature implementation, follow this loop:

**1. Attempt Implementation (Pass 1: RED):**
- Write failing test describing expected behavior
- Run tests to verify failure (must fail for right reason)
- If test fails to run (not assertion failure), check Smart Exit Patterns

**2. On Test Failure - Analyze Error:**
- **Is this a Smart Exit Pattern?**
  - YES → Exit with clear instructions, do NOT retry
  - NO → Continue to step 3

**3. Implement to Pass Test (Pass 2: GREEN):**
- Write minimal code to make test pass
- Run tests to verify success
- If implementation fails 3 consecutive times with SAME error → likely needs user intervention

**4. Iterate (Max 5-10 Attempts Before Escalation):**
- Track attempts: "Attempt N/10: [brief description of approach]"
- Try different approaches (don't repeat what failed)
- Learn from failures (if same error 3x, different approach needed)
- Token-efficient: Only read error context, not full codebase each iteration

**5. Escalation Criteria:**

**Escalate after 5-10 attempts when:**
- Same error persists despite different approaches
- Root cause unclear (need architectural discussion)
- Multiple dependencies failing (system-level issue)
- Timeout/performance issues require infrastructure changes

**When escalating:**
1. Document all approaches tried (what failed, why it failed)
2. Update requirement status to 🔴 Blocked
3. Add detailed note to `implementation_notes` field
4. Provide clear context for next steps
5. Ask user: "Tried X approaches, all failed. Need guidance on: {specific question}"

## Attempt Tracking Format

Track attempts to prevent repeating failed approaches:

```markdown
**REQ-XXX Implementation Attempts:**
- Attempt 1/10: Direct API call with fetch → NetworkError (ECONNREFUSED)
- Attempt 2/10: Added timeout config → Same error (service down)
- SMART EXIT: External service unreachable → USER INTERVENTION REQUIRED
```

**For complex iterations:**
```markdown
**REQ-XXX Implementation Attempts:**
- Attempt 1/10: Async validation in form component → Race condition
- Attempt 2/10: Debounced validation → Still racing on fast input
- Attempt 3/10: Queue-based validation → TypeError on null input
- Attempt 4/10: Added null checks → Working but flaky
- Attempt 5/10: Refactored to useReducer pattern → Tests pass consistently
```

## Token-Efficient Iteration

**Avoid token waste during iteration:**

**WRONG (Token-wasting):**
```
Attempt 1 fails → Read entire codebase (10K tokens)
Attempt 2 fails → Re-read entire codebase (10K tokens)
Attempt 3 fails → Re-read entire codebase (10K tokens)
```

**RIGHT (Token-efficient):**
```
Attempt 1 fails → Read error stack trace only
Attempt 2 fails → Read specific failing function
Attempt 3 fails → Check for smart exit pattern, exit if detected
```

**Guidelines:**
- Only read files relevant to current error
- Use grep to find specific functions/patterns, not full file reads
- Re-use context from previous reads (cached files)
- If re-reading same file 3+ times → likely wrong approach

## Example: Smart Exit Detection

**Scenario: Missing API Key**

```bash
# Attempt 1: Run tests
npm test

# Output:
Error: API_KEY is not defined
  at fetchUser (src/api/users.js:12)

# DETECTION: "API_KEY" + "not defined" → Smart Exit Pattern

# RESPONSE:
```

**Output to user:**
```markdown
**USER INTERVENTION REQUIRED**

**Issue:** Missing API_KEY environment variable

**Fix:**
1. Create `.env` file in project root if not exists
2. Add line: `API_KEY=your-api-key-here`
3. Restart development server

**Status:** REQ-XXX marked 🔴 Blocked
**Blocked by:** Missing API_KEY environment variable
```

## Example: Genuine Implementation Challenge

**Scenario: Async validation race condition**

```markdown
**REQ-XXX Implementation Attempts:**

Attempt 1/10: Direct setState in onChange
- Issue: State updates batched, validation fires on stale data
- Approach: Try useEffect dependency

Attempt 2/10: useEffect with email dependency
- Issue: Fires on every keystroke, overwhelming API
- Approach: Add debouncing

Attempt 3/10: Debounced validation (500ms)
- Issue: Still racing on rapid input + submit
- Approach: Queue-based validation

Attempt 4/10: Validation queue with cancellation
- Issue: Complex, hard to test, brittle
- Approach: Simplify with form library

Attempt 5/10: React Hook Form with Zod validation
- Success: Built-in debouncing, async validation, cancel handling
- Tests pass, no race conditions

**Resolution:** Refactored to React Hook Form (industry pattern)
**Lesson:** Don't reinvent validation - use proven libraries
```

## Integration with Completion Checklist

Before marking 🟢 Complete, verify:
- [ ] No smart exit patterns triggered (environment clean)
- [ ] Implementation completed without hitting escalation limit
- [ ] If escalated, user intervention addressed and tests now pass
- [ ] Attempt tracking shows learning (different approaches tried)
- [ ] Final solution documented in implementation notes
