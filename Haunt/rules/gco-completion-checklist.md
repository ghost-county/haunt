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
  - Frontend: `npm test` AND `npx playwright test` (E2E tests REQUIRED for UI work)
  - Infrastructure: Verify state
- All tests must pass
- No new test failures introduced
- **For UI work:** E2E tests MUST exist and pass before marking complete

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
### 7. Iterative Code Refinement

**CRITICAL:** All code must go through iterative refinement passes before marking complete.

**Refinement Requirements by Task Size:**
- **XS (<10 lines):** 1-pass acceptable for trivial changes
- **S (10-50 lines):** 2-pass minimum (Initial → Refinement)
- **M (50-300 lines):** 3-pass required (Initial → Refinement → Enhancement)
- **SPLIT (>300 lines):** Decompose first, then 3-4 passes per piece

**Verify appropriate passes completed:**

**Pass 1 - Initial Implementation:**
- [ ] Functional requirements met
- [ ] Happy path implemented
- [ ] Basic tests pass

**Pass 2 - Refinement (S/M required):**
- [ ] Error handling added for all I/O operations
- [ ] Magic numbers replaced with named constants
- [ ] Input validation explicit (no silent fallbacks)
- [ ] Variable/function names descriptive
- [ ] Functions <50 lines each
- [ ] No debugging code left

**Pass 3 - Enhancement (M required):**
- [ ] Edge case tests added
- [ ] Error case tests added
- [ ] Security checklist reviewed (if applicable)
- [ ] Anti-patterns checked (lessons-learned.md)
- [ ] Logging added for error conditions
- [ ] Test coverage >80%

**Pass 4 - Production Hardening (M/SPLIT optional):**
- [ ] Correlation IDs for request tracing
- [ ] Retry logic with exponential backoff
- [ ] Circuit breakers for external dependencies
- [ ] Performance verified under load
- [ ] Graceful degradation tested

**Why this matters:** Iterative refinement catches mistakes AI code typically has: missing error handling, magic numbers, poor naming, incomplete tests. Each pass systematically improves quality before handoff to Code Reviewer.

**See:** Dev agent "Iterative Code Refinement Protocol" section for detailed workflow and examples.

---

### 8. Self-Validation

**After completing refinement passes**, perform final self-validation:

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
  - **For UI work:** E2E tests use proper selectors (data-testid preferred, NOT CSS nth-child)
- **Run the code yourself** (if applicable):
  - Execute feature manually to verify behavior
  - Check error messages are user-friendly
  - Verify performance is acceptable
- **Double-check against anti-patterns** from `.haunt/docs/lessons-learned.md`:
  - No silent fallbacks on required data
  - Explicit error handling (no catch-all exceptions)
  - No hardcoded secrets or credentials

**Why this matters:** Catching your own mistakes before Code Reviewer saves time and reduces rework. Self-validation is the difference between "I'm done" and "This is ready for review."

### 8. Code Review (Hybrid Workflow - Depends on Effort Size)

**After self-validation, check requirement effort size to determine if automatic code review is needed.**

#### For XS/S Requirements:
- **Self-validation is sufficient** (no automatic code review)
- Proceed directly to "Completion Sequence" (step 9 below)
- Mark requirement 🟢 Complete after all verifications
- Manual code review always available via `/summon code-reviewer` if desired

#### For M/SPLIT Requirements:
- **Automatic code review is REQUIRED**
- Do NOT mark requirement 🟢 yet (keep status 🟡)
- Spawn Code Reviewer with handoff context
- Wait for review verdict before proceeding

**Code Review Handoff (for M/SPLIT only):**

Use `/summon code-reviewer` with this format:

```
/summon code-reviewer "Review REQ-XXX: [Requirement Title]

**Context:**
- Effort: M/SPLIT (automatic review required)
- Files changed: [count] files ([list file paths])
- Tests: [passing count] passing

**Changes Summary:**
[2-3 sentence summary of what was implemented]

**Self-Validation:**
- [x] All tasks checked off
- [x] Tests passing ([test command output summary])
- [x] Security review complete (or N/A)
- [x] Code review for obvious issues
- [x] Anti-patterns checked

**Request:**
Please review and update REQ-XXX status based on verdict (APPROVED → 🟢, CHANGES_REQUESTED → 🟡, BLOCKED → 🔴)"
```

**After Code Review (M/SPLIT only):**
- Code Reviewer updates requirement status based on verdict
- APPROVED → Requirement marked 🟢, work complete
- CHANGES_REQUESTED → Status remains 🟡, fix issues and re-submit
- BLOCKED → Status changed to 🔴, resolve blocking issues

**Rationale:** XS/S changes (1-2 files, 1-2 hours) have low risk and benefit from faster iteration with self-validation. M/SPLIT changes (4+ files, 2+ hours) have higher complexity and risk, warranting mandatory code review for quality assurance.

### 9. UI/UX Validation (REQUIRED for Frontend Work)

**Applies to:** All UI generation, component creation, or visual design changes.

**Checklist items (see `.claude/rules/gco-ui-design-standards.md` for details):**

- [ ] **8px Grid Spacing** - All spacing uses 8px increments (16px, 24px, 32px, etc.)
  - Verify: Inspect CSS/styles - all margin/padding/gap values divisible by 8
  - Fine-tuning: 4px allowed ONLY for optical alignment
- [ ] **4.5:1 Contrast Minimum** - All text meets WCAG AA contrast standards
  - Verify: Use WebAIM Contrast Checker or browser DevTools
  - Test: Light mode AND dark mode (if applicable)
- [ ] **5 Interactive States** - All buttons/links define: default, hover, active, focus, disabled
  - Verify: Manually test each state or inspect CSS for all 5 state definitions
- [ ] **44×44px Touch Targets** - All clickable elements meet minimum size
  - Verify: Measure button/link dimensions (48×48px preferred)
- [ ] **Keyboard Navigation** - All interactive elements accessible via keyboard
  - Test: Tab through page, verify focus order and Enter/Space activation
- [ ] **Skip Links** - Page includes skip-to-content link
  - Test: Tab on page load, first focusable element should be skip link
- [ ] **Semantic HTML** - Proper element usage (button, nav, main, etc.)
  - Verify: No `<div onclick>`, use `<button>` instead
- [ ] **Focus Indicators** - Visible 3px minimum outline on focus
  - Test: Tab through page, verify all focusable elements show outline
- [ ] **Color Blindness** - UI works in grayscale/protanopia/deuteranopia
  - Test: Use browser DevTools vision deficiency emulation
- [ ] **Mobile Responsive** - Layout tested at 320px width minimum
  - Test: Browser DevTools responsive mode, verify no horizontal scroll

**Quick validation commands:**
```bash
# Check contrast (manual - use online tool)
# https://webaim.org/resources/contrastchecker/

# Test responsive (Chrome DevTools)
# Cmd+Opt+I → Toggle device toolbar → Test 320px, 768px, 1024px widths

# Test color blindness (Chrome DevTools)
# Cmd+Opt+I → Rendering → Emulate vision deficiencies
```

**Failure modes to reject:**
- Light gray text on white background (common AI mistake - fails contrast)
- Buttons without hover states (incomplete state management)
- Arbitrary spacing (15px, 20px, 25px instead of 8px grid)
- Touch targets <44px (mobile usability failure)
- Missing focus indicators (keyboard accessibility failure)

**Why this matters:** UI/UX validation prevents common AI-generated UI failures: poor contrast, inconsistent spacing, missing interactive states, and accessibility gaps. These issues are expensive to fix later and frustrate users.

## Completion Sequence

1. Verify all applicable items above (steps 1-7 for all work, +step 8 for M/SPLIT, +step 9 for frontend work)
2. Update requirement status: 🟡 → 🟢 (or wait for Code Reviewer verdict for M/SPLIT)
3. Update "Completion:" field with verification note
4. Notify PM (if present) for archival

## Prohibitions

- NEVER mark 🟢 without checking all tasks
- NEVER mark 🟢 with failing tests
- NEVER mark 🟢 without verifying completion criteria
- NEVER skip the checklist "because it's a small change"
- NEVER skip self-validation before requesting code review
- NEVER mark M/SPLIT requirements 🟢 without automatic code review (wait for Code Reviewer verdict)
- NEVER skip code review for M/SPLIT requirements (automatic review is mandatory)
