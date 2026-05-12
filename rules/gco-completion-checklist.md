# Completion Checklist

## Before Starting Work

**Define verifiable success criteria up front.** Transform the task into a check you can run:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

Weak criteria ("make it work") force constant re-clarification. Strong criteria let you loop independently and know when you're done.

## Before Marking Work Complete

**Quick Checklist:**
1. All tasks done
2. Tests passing:
   - Frontend: BOTH `npm test` AND `npx playwright test` pass
   - Backend: `npm test` or `pytest tests/` pass
3. Self-assessment: "Would I demo this to my CTO?" → YES with confidence

## Non-Negotiable

- ALWAYS define a verifiable success criterion before starting non-trivial work BECAUSE work without a concrete done-condition either drifts in scope or terminates prematurely; a stated check forces the agent to look for evidence rather than vibes
- NEVER mark work complete with failing tests BECAUSE the completion-gate hook will block the status change, and a premature green-mark misleads the orchestrator into spawning dependent work on a broken foundation
- NEVER mark work complete if you wouldn't confidently demo it to your CTO BECAUSE shipping work that needs immediate follow-up creates compounding technical debt and erodes trust in the entire seance workflow
