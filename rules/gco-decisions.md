# Decision Framework

Engineering decision protocol for evaluating complexity, timing, and reversibility.

## The Four-Question Filter

Before implementing any solution or adding complexity, ask these questions in order:

### 1. Will users notice?

**If NO → Defer the decision.**

Examples:
- Internal code architecture users never see
- Optimization for scale you don't have yet
- Premature abstraction "in case we need it"
- Theoretical edge cases with no user impact

**Why it matters:** User-invisible work consumes time that could deliver visible value.

**Guideline:** Focus on user-facing impact first. Internal improvements can wait until they solve real problems.

---

### 2. Can we validate cheaper?

**If YES → Manual first, automate later.**

Examples:
- Test with manual workflow before building automation
- Deploy feature flag instead of full rollout
- Use spreadsheet before building dashboard
- Prototype on paper before coding

**Why it matters:** Validation proves demand. Don't build until you know it's needed.

**Guideline:** Start with simplest validation method. Invest in automation only after proving value.

---

### 3. Is this reversible?

**If YES → Prefer undoable choices.**

Examples:
- Feature flags (can disable without deploy)
- Database columns (can drop safely)
- Config changes (can revert instantly)
- External services (can swap providers)

**If NO → Slow down and think harder:**
- Database schema changes (breaking migrations)
- API contract changes (affects consumers)
- Data deletion (permanent loss)
- Architecture rewrites (high switching cost)

**Why it matters:** Reversible decisions let you move fast. Irreversible decisions demand caution.

**Guideline:** Default to reversible. Only choose irreversible when benefit clearly justifies risk.

---

### 4. YAGNI - You Aren't Gonna Need It

**Don't build for scale you don't have** BECAUSE every abstraction is a bet on future needs, and premature complexity makes code harder to change when real needs emerge.

Examples of premature optimization:
- Microservices for 100 users/month
- Caching before measuring performance
- Sharding before hitting database limits
- Load balancing before traffic justifies it

**Exceptions (when to ignore YAGNI):**
- Security (always protect data)
- Data integrity (always validate)
- Error handling (always catch failures)
- Logging (always track critical events)

**Why it matters:** Complexity has a cost. Every abstraction is a bet on future needs.

**Guideline:** Build for current scale. Refactor when you actually hit limits.

---

## Decision Matrix

| Question | Answer | Action |
|----------|--------|--------|
| 1. Will users notice? | NO | Defer decision |
| 1. Will users notice? | YES | Continue to Q2 |
| 2. Can we validate cheaper? | YES | Start manual, automate later |
| 2. Can we validate cheaper? | NO | Continue to Q3 |
| 3. Is this reversible? | YES | Proceed with confidence |
| 3. Is this reversible? | NO | Slow down, consider carefully |
| 4. YAGNI? | YES | Don't build it yet |
| 4. YAGNI? | NO (real need) | Proceed |

## Example Scenarios

### Scenario 1: Caching Layer

**Context:** API response times averaging 200ms. Product owner suggests adding Redis caching.

**Evaluation:**
1. **Will users notice?** Currently 200ms is acceptable (< 300ms threshold). Users NOT complaining. → **DEFER**
2. (Skip remaining questions - already deferred)

**Decision:** Monitor response times. Add caching when users complain or metrics show degradation.

---

### Scenario 2: Feature Flag System

**Context:** Need to deploy new checkout flow gradually.

**Evaluation:**
1. **Will users notice?** YES - affects checkout experience directly
2. **Can we validate cheaper?** NO - checkout is critical, can't test manually at scale
3. **Is this reversible?** YES - feature flags let us toggle without deploy
4. **YAGNI?** NO - we have real need (gradual rollout for risk mitigation)

**Decision:** Implement feature flag system. Reversibility and real need justify investment.

---

### Scenario 3: Database Sharding

**Context:** Database at 30% capacity. Engineer proposes sharding "to prepare for growth."

**Evaluation:**
1. **Will users notice?** NO - current performance is fine
2. **Can we validate cheaper?** YES - monitor metrics, optimize queries first
3. **Is this reversible?** NO - sharding is complex and hard to undo
4. **YAGNI?** YES - don't have scale problem yet

**Decision:** DEFER. Monitor growth rate. Revisit when at 70% capacity or performance degrades.

---

### Scenario 4: Input Validation

**Context:** Adding user registration form. Should we validate email format?

**Evaluation:**
1. **Will users notice?** YES - affects registration experience
2. **Can we validate cheaper?** NO - validation is already cheap
3. **Is this reversible?** YES - can adjust validation rules easily
4. **YAGNI?** NO - validation is security/data integrity (exception to YAGNI)

**Decision:** Implement validation. Security and data integrity are non-negotiable.

---

## Anti-Patterns to Avoid

### Premature Abstraction

**WRONG:**
```typescript
// Adding abstraction "in case we switch databases"
class DatabaseAbstractionLayer {
  // 500 lines of code for hypothetical future need
}
```

**RIGHT:**
```typescript
// Use database directly until switching becomes real need
import { db } from './db';
```

**Why:** Abstraction has cost. Don't pay it until you have real requirement.

---

### Speculative Complexity

**WRONG:**
```python
# "We might need to support multiple payment providers someday"
class PaymentProviderFactory:
    # Complex factory pattern for single provider
```

**RIGHT:**
```python
# Use Stripe directly until second provider is needed
from stripe import Payment
```

**Why:** Complexity for hypothetical futures wastes time and makes code harder to maintain.

---

### Premature Optimization

**WRONG:**
```javascript
// Optimizing before measuring
const memoizedResult = useMemo(() => expensiveCalc(), [deps]);
// (But expensiveCalc() takes 2ms - negligible)
```

**RIGHT:**
```javascript
// Measure first, optimize if needed
const result = expensiveCalc();
// Profile shows this is NOT bottleneck
```

**Why:** Optimization without measurement optimizes wrong things.

---

## When to Ignore This Framework

**Ignore YAGNI for:**
- **Security:** Always validate input, encrypt secrets, enforce permissions BECAUSE security retrofits are 10x more expensive than building it in, and breaches are irreversible
- **Data Integrity:** Always use constraints, validate foreign keys, prevent corruption BECAUSE data corruption compounds silently and may be unrecoverable by the time it's detected
- **Error Handling:** Always catch exceptions, log errors, handle edge cases BECAUSE silent failures in production create debugging nightmares and erode user trust
- **Legal/Compliance:** Always meet regulatory requirements (GDPR, HIPAA, etc.) BECAUSE compliance violations carry financial penalties and legal liability that dwarf dev costs

---

## Success Criteria

You're using this framework correctly when:

- [ ] Most work directly improves user experience
- [ ] Manual workflows validate demand before automation
- [ ] Reversible choices let you move fast and adjust
- [ ] Complexity is justified by real needs, not hypothetical futures
- [ ] Code stays simple until scale demands complexity

**Remember:** The best code is code you don't write. Solve real problems, not imaginary ones.
