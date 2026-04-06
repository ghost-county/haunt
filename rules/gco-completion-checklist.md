# Completion Checklist

## Before Marking Work Complete

**Quick Checklist:**
1. All tasks done
2. Tests passing:
   - Frontend: BOTH `npm test` AND `npx playwright test` pass
   - Backend: `npm test` or `pytest tests/` pass
3. Self-assessment: "Would I demo this to my CTO?" → YES with confidence

## Non-Negotiable

- NEVER mark work complete with failing tests BECAUSE the completion-gate hook will block the status change, and a premature green-mark misleads the orchestrator into spawning dependent work on a broken foundation
- NEVER mark work complete if you wouldn't confidently demo it to your CTO BECAUSE shipping work that needs immediate follow-up creates compounding technical debt and erodes trust in the entire seance workflow
