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

## Completion Sequence

1. Verify all 5 items above
2. Update requirement status: 🟡 → 🟢
3. Update "Completion:" field with verification note
4. Notify PM (if present) for archival

## Prohibitions

- NEVER mark 🟢 without checking all tasks
- NEVER mark 🟢 with failing tests
- NEVER mark 🟢 without verifying completion criteria
- NEVER skip the checklist "because it's a small change"
