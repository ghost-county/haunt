# Completion Checklist (Slim Reference)

## Before Marking ANY Requirement 🟢

Run through this checklist:

1. **All Tasks Checked Off** - Every `- [ ]` is now `- [x]`
2. **Completion Criteria Met** - For EACH criterion in "Completion:" field:
   - Check the criterion is satisfied
   - Output: "✓ [criterion text] - VERIFIED"
   - If ANY criterion unclear or unmet → NOT complete
3. **Tests Passing (NON-NEGOTIABLE):**
   - **Option 1 (Recommended):** Run `bash Haunt/scripts/haunt-run.sh test` for structured JSON output
   - **Option 2:** Run `bash Haunt/scripts/verify-tests.sh REQ-XXX <frontend|backend|infrastructure>`
   - Paste verification output in completion notes
   - Frontend: BOTH `npm test` AND `npx playwright test` must pass (0 failures)
   - Backend: `npm test` or `pytest tests/` must pass (0 failures)
   - **Structured output available:** Use `haunt-run test` for consistent pass/fail/coverage JSON
4. **Files Updated** - All files in "Files:" section modified/created
5. **Documentation Updated** - README, comments, type annotations (if applicable)
6. **Security Reviewed** - If code touches user input, auth, DB, APIs, or secrets (see security checklist)
7. **Iterative Refinement Complete:**
   - XS: 1-pass acceptable
   - S: 2-pass minimum (Initial → Refinement)
   - M: 3-pass required (Initial → Refinement → Enhancement)
8. **Self-Assessment Questions** (answer before marking 🟢):
   - Did I run the tests and see them pass? (not assumed - actually ran)
   - Did I verify EACH completion criterion? (not skimmed - verified)
   - Did I check for obvious issues? (security, edge cases, error handling)
   - Would I mass-produce this for production use?
   - If ANY answer is NO or uncertain → NOT complete
9. **Code Review Decision:**
   - XS/S: Self-validation sufficient, mark 🟢 directly
   - M/SPLIT: Spawn Code Reviewer, wait for verdict before marking 🟢
10. **UI/UX Validation (if Frontend)** - 10 standards verified (8px grid, contrast, states, etc.)
11. **Professional Standards Gate: "Would I demo this to my CTO?"**
    - If NO or "maybe with caveats" → NOT complete, fix it
    - If YES with confidence → mark 🟢

## When to Invoke Full Skill

For detailed requirements, checklists for each step, examples, and anti-patterns to avoid:

**Invoke:** `/gco-completion` skill

The skill contains:
- Detailed verification requirements for each step
- Testing requirements by agent type (Frontend/Backend/Infrastructure)
- Iterative refinement checklist by pass (Pass 1/2/3/4)
- Code review workflow (hybrid XS/S vs M/SPLIT)
- UI/UX validation checklist (10 standards)
- Professional standards reflection questions

## Non-Negotiable

- NEVER mark 🟢 with failing tests
- NEVER skip verification script for Frontend/Backend work
- NEVER mark M/SPLIT 🟢 without Code Reviewer approval
- NEVER mark 🟢 if you wouldn't confidently demo it to your CTO
- NEVER mark 🟢 without explicit criterion-by-criterion verification (Step 2)
