# Completion Checklist

Before marking any requirement as 🟢 Complete, verify ALL of the following:

## Required Verifications

### 1. All Tasks Checked Off
- Every `- [ ]` in the requirement is now `- [x]`
- No tasks were skipped or forgotten
- If a task wasn't needed, it was explicitly removed (not left unchecked)

### 2. Completion Criteria Met
- Read the "Completion:" field in the requirement
- Verify each criterion is actually satisfied
- If criteria are ambiguous, clarify before marking complete

### 3. Tests Passing
- Run appropriate test command for your work:
  - Backend: `pytest tests/ -x -q`
  - Frontend: `npm test`
  - Infrastructure: Verify state
- All tests must pass
- No new test failures introduced

### 4. Files Updated
- All files listed in "Files:" section have been modified/created
- No unintended changes to other files
- Changes committed (or ready to commit)

### 5. Documentation Updated (if applicable)
- README updated if public API changed
- Comments added for complex logic
- Type annotations complete

### 6. Security Review (if applicable)
- Review `.haunt/checklists/security-checklist.md` if code changes involve:
  - User input handling (forms, APIs, file uploads)
  - Authentication or authorization
  - Database queries
  - External API calls
  - File system operations
  - Environment variables or configuration
  - Third-party dependencies
- Mark applicable security checks as verified
- Fix any security issues found
- If no security-relevant changes, note "Security review: N/A"

### 7. Self-Validation
- **Re-read the original requirement** and verify all completion criteria are met
- **Review your own code changes** for obvious issues before handoff:
  - No debugging code left (console.log, print statements, commented-out code)
  - No TODO/FIXME comments without tracking (create REQ instead)
  - Variable names are descriptive
  - Functions are focused and under 50 lines
  - No magic numbers (use named constants)
- **Confirm tests actually test the feature** (not just exist):
  - Tests fail when feature is broken (not false positives)
  - Edge cases are covered (empty input, boundary values, error conditions)
  - Tests are independent (don't rely on order or shared state)
- **Run the code yourself** (if applicable):
  - Execute feature manually to verify behavior
  - Check error messages are user-friendly
  - Verify performance is acceptable
- **Double-check against anti-patterns** from `.haunt/docs/lessons-learned.md`:
  - No silent fallbacks on required data
  - Explicit error handling (no catch-all exceptions)
  - No hardcoded secrets or credentials

**Why this matters:** Catching your own mistakes before Code Reviewer saves time and reduces rework. Self-validation is the difference between "I'm done" and "This is ready for review."

## Completion Sequence

1. Verify all 7 items above
2. Update requirement status: 🟡 → 🟢
3. Update "Completion:" field with verification note
4. Notify PM (if present) for archival

## Prohibitions

- NEVER mark 🟢 without checking all tasks
- NEVER mark 🟢 with failing tests
- NEVER mark 🟢 without verifying completion criteria
- NEVER skip the checklist "because it's a small change"
- NEVER skip self-validation before requesting code review
