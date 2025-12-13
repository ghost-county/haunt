---
name: gco-witching-hour
description: Intensive debugging workflow for hard-to-find issues. Invoke when bugs are elusive, production errors are mysterious, or standard debugging fails. Provides enhanced logging, pattern correlation, and systematic bug hunting techniques.
---

# Witching Hour: Intensive Debug Mode

## Purpose

The "witching hour" is that dark time when bugs reveal themselves - usually late at night, in production, or when everything *should* work but doesn't. This skill provides a structured approach to hunting down elusive issues through enhanced logging, systematic investigation, and pattern correlation.

## When to Invoke

- Production bugs that cannot be reproduced locally
- Intermittent failures with no clear pattern
- Performance issues with unclear root cause
- Race conditions or timing-dependent bugs
- Issues that only appear under specific conditions
- Standard debugging techniques have failed
- User reports: "It works sometimes" or "I can't explain what's wrong"

## The Witching Hour Protocol

A systematic five-phase approach to intensive debugging:

### Phase 1: Shadow Gathering (Evidence Collection)

Before touching any code, gather ALL available evidence.

**What to collect:**
- Error messages (full stack traces, not summaries)
- Logs from time of failure (application, system, infrastructure)
- User reproduction steps (exact sequence, environment details)
- System state at time of failure (memory, CPU, network, database connections)
- Recent changes (git log for relevant files/systems)
- Similar past issues (search codebase, tickets, agent memory)

**Commands:**
```bash
# Recent git history for relevant files
git log --since="7 days ago" --oneline -- path/to/relevant/files

# Search for similar error patterns
grep -r "error message" logs/

# Check agent memory for related issues
# Use /apparition recall [agent-name] if available

# Review recent changes that might correlate
git diff HEAD~10..HEAD path/to/suspect/area
```

**Output:** Create `.haunt/progress/witching-hour-YYYY-MM-DD-DESCRIPTION.md` with evidence log.

### Phase 2: Spectral Analysis (Pattern Correlation)

Analyze collected evidence for patterns and correlations.

**Look for:**
- **Temporal patterns**: Does it happen at specific times? Load conditions?
- **Environmental patterns**: Specific servers, regions, user types?
- **Code patterns**: Recent changes, similar bugs in related code
- **Data patterns**: Specific input types, edge cases, boundary conditions
- **System patterns**: Resource exhaustion, network issues, third-party service failures

**Questions to answer:**
1. What changed? (code, config, infrastructure, data, dependencies)
2. What's common? (all failures share what characteristics?)
3. What's different? (successful vs failed cases)
4. What's missing? (expected data, logs, resources)
5. What's unexpected? (anomalies, surprises, violations of assumptions)

**Document correlations** in witching-hour report with confidence levels:
- **High confidence**: Strong correlation with evidence
- **Medium confidence**: Plausible but needs verification
- **Low confidence**: Speculation worth investigating

### Phase 3: Illumination (Enhanced Instrumentation)

Add targeted logging and tracing to illuminate the bug's hiding place.

**Logging strategy:**

```python
# WRONG: Generic logging
logger.info("Processing user")

# RIGHT: Witching hour logging with context
logger.info(
    "Witching hour trace: Processing user",
    extra={
        "user_id": user.id,
        "operation": "checkout",
        "session_id": session.id,
        "timestamp": datetime.utcnow().isoformat(),
        "trace_id": trace_id,  # Unique identifier for this debugging session
        "state": {
            "cart_items": len(cart.items),
            "user_authenticated": user.is_authenticated,
            "payment_method": payment.method
        }
    }
)
```

**Add instrumentation at:**
- Entry points (where data enters the system)
- Exit points (where data leaves or errors surface)
- State transitions (where things change)
- Decision points (conditionals that affect flow)
- Integration boundaries (API calls, database queries, external services)

**Use trace IDs** to correlate logs across services:
- Generate unique trace_id at start of request
- Pass trace_id through all function calls
- Log trace_id in every witching hour log entry
- Grep logs by trace_id to see full execution path

### Phase 4: The Hunt (Systematic Elimination)

Test hypotheses systematically, eliminating possibilities.

**Hypothesis testing framework:**

For each theory from Phase 2:
1. **State hypothesis clearly**: "The bug occurs when X condition is true"
2. **Define test**: How can I prove/disprove this?
3. **Predict outcome**: If hypothesis is correct, I expect to see Y
4. **Run test**: Execute in controlled environment
5. **Compare results**: Does outcome match prediction?
6. **Document findings**: Update witching-hour report

**Testing techniques:**

| Technique | When to Use | How to Apply |
|-----------|-------------|--------------|
| Binary search | Large codebase changes | Bisect commits with `git bisect` |
| Isolation | Multi-component system | Test each component separately |
| Simplification | Complex inputs | Reduce to minimal reproduction case |
| Amplification | Intermittent issues | Run repeatedly, stress test, increase frequency |
| Substitution | Third-party dependencies | Mock/stub external services |
| Comparison | Works in one env, not another | Diff configurations, dependencies, data |

**Commands:**
```bash
# Binary search through commits
git bisect start
git bisect bad HEAD
git bisect good <known-good-commit>
# Test each commit git presents, mark good/bad

# Run test repeatedly to catch intermittent failures
for i in {1..100}; do
    pytest tests/test_suspect.py -v || echo "FAILURE $i" >> failures.log
done

# Compare environments
diff <(pip freeze) <(pip freeze -r production-requirements.txt)
```

### Phase 5: Banishment (Fix & Prevent)

Fix the root cause and add safeguards against recurrence.

**Fix checklist:**
- [ ] Root cause identified and understood
- [ ] Fix addresses root cause (not just symptoms)
- [ ] Test written that fails before fix, passes after
- [ ] Fix tested in environment where bug occurred
- [ ] Related code audited for same pattern
- [ ] Documentation updated (if design assumption was wrong)

**Prevention measures:**
- Add test to prevent regression (unit, integration, or E2E)
- Add defensive code (input validation, error handling, timeouts)
- Add monitoring/alerting (if production issue)
- Update agent memory with pattern and solution
- Document in witching-hour report lessons learned

**Document the Insight:**

After successful banishment, record the lesson learned for future reference:

```python
add_long_term_insight(
    "Root cause: PostgreSQL connection pool exhaustion caused by unclosed cursors in async handlers. "
    "Solution: Added explicit cursor.close() calls in finally blocks and reduced pool size from 50 to 20. "
    "Prevention: Added connection pool monitoring alerts and defensive timeout on all DB operations."
)
```

This builds institutional knowledge across debugging sessions. The insight should include:
- **Root cause**: The fundamental technical issue (not symptoms)
- **Solution**: What actually fixed it (specific changes made)
- **Prevention**: How to avoid this in the future (safeguards, patterns, alerts)

**Memory pattern template:**
```
Pattern: [What pattern was this bug an instance of?]
Root Cause: [What was the fundamental issue?]
Fix: [How was it resolved?]
Prevention: [What safeguards were added?]
Lesson: [What did we learn?]
```

## Enhanced Debugging Techniques

### Trace-Driven Debugging

Add comprehensive tracing for execution flow visibility:

```python
import functools
import logging

def witching_hour_trace(logger):
    """Decorator for tracing function calls during intensive debugging."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # Log entry
            logger.debug(
                f"TRACE ENTER: {func.__name__}",
                extra={
                    "args": args,
                    "kwargs": kwargs,
                    "caller": inspect.stack()[1].function
                }
            )

            try:
                result = func(*args, **kwargs)

                # Log success exit
                logger.debug(
                    f"TRACE EXIT: {func.__name__}",
                    extra={"result": result}
                )

                return result
            except Exception as e:
                # Log error exit
                logger.error(
                    f"TRACE ERROR: {func.__name__}",
                    extra={
                        "exception_type": type(e).__name__,
                        "exception_message": str(e)
                    },
                    exc_info=True
                )
                raise

        return wrapper
    return decorator

# Usage
@witching_hour_trace(logger)
def suspect_function(user_id, action):
    # Function being debugged
    pass
```

### State Snapshots

Capture system state at critical moments:

```python
def capture_witching_hour_snapshot(context: str, **state):
    """Capture detailed state snapshot for debugging."""
    snapshot = {
        "timestamp": datetime.utcnow().isoformat(),
        "context": context,
        "system": {
            "memory_mb": psutil.virtual_memory().used / 1024 / 1024,
            "cpu_percent": psutil.cpu_percent(),
            "active_threads": threading.active_count(),
        },
        "application": state
    }

    logger.info(
        "WITCHING HOUR SNAPSHOT",
        extra={"snapshot": snapshot}
    )

    # Also write to file for later analysis
    with open(f".haunt/progress/snapshot-{context}.json", "w") as f:
        json.dump(snapshot, f, indent=2)
```

### Assertion-Based Debugging

Add assertions for invariants that should never be violated:

```python
def debug_assert(condition: bool, message: str, **context):
    """Enhanced assertion for witching hour debugging."""
    if not condition:
        logger.critical(
            f"ASSERTION FAILED: {message}",
            extra={"context": context},
            exc_info=True
        )

        # In production, log but don't crash
        if os.getenv("ENV") == "production":
            # Send alert, create ticket, etc.
            pass
        else:
            # In dev/staging, fail fast
            raise AssertionError(f"{message}: {context}")

# Usage
debug_assert(
    user.balance >= 0,
    "User balance went negative",
    user_id=user.id,
    balance=user.balance,
    transaction_id=transaction.id
)
```

## Pattern Correlation for Bugs

### Common Bug Patterns

| Pattern | Indicators | Investigation Approach |
|---------|-----------|------------------------|
| Race Condition | Intermittent failures, timing-dependent, multi-threaded environment | Add sleep statements to alter timing, use thread-safe debugging, check locks/mutexes |
| Resource Exhaustion | Failures after uptime, memory/file descriptor leaks, slow degradation | Monitor resource usage over time, check for unclosed resources, profile memory |
| Null/Undefined Reference | Crashes on specific code paths, "cannot read property" errors | Check data validation, defensive programming, guard clauses |
| Off-by-One | Boundary condition failures, edge cases | Test with min/max values, empty collections, single-item collections |
| Configuration Drift | Works in one environment, not another | Diff configurations, environment variables, dependency versions |
| External Dependency Failure | Timeouts, network errors, intermittent issues | Mock external services, check retry logic, verify timeout settings |

### Bug Pattern Checklist

Run through this checklist for systematic investigation:

- [ ] **Reproduction**: Can I reproduce it? Under what conditions?
- [ ] **Timing**: Does it happen immediately, after delay, or intermittently?
- [ ] **Environment**: Dev? Staging? Production? All or specific?
- [ ] **Data**: Specific inputs, edge cases, or all data?
- [ ] **Load**: Happens under load, idle, or doesn't matter?
- [ ] **Recent changes**: What changed in last deploy? Last week?
- [ ] **Similar bugs**: Have we seen this pattern before?
- [ ] **External factors**: Third-party services, network, infrastructure?

## Witching Hour Report Template

Create `.haunt/progress/witching-hour-YYYY-MM-DD-[bug-description].md`:

```markdown
# Witching Hour Investigation: [Bug Description]

**Started:** YYYY-MM-DD HH:MM
**Completed:** YYYY-MM-DD HH:MM
**Investigator:** [Agent Name]

## Phase 1: Shadow Gathering

### Evidence Collected
- Error messages: [paste full errors]
- User reports: [reproduction steps]
- System state: [logs, metrics]
- Recent changes: [git commits]

## Phase 2: Spectral Analysis

### Patterns Identified
1. **[Pattern name]** - [Confidence: High/Medium/Low]
   - Evidence: [what supports this theory]
   - Correlation: [what's common/different]

### Hypotheses
1. [Hypothesis statement]
   - Supporting evidence
   - Prediction if true
   - Test strategy

## Phase 3: Illumination

### Instrumentation Added
- [File/function]: [What logging added]
- Trace ID: [How to grep logs]

### Key Observations from Logs
- [Finding 1]
- [Finding 2]

## Phase 4: The Hunt

### Hypothesis Testing

#### Test 1: [Hypothesis]
- **Test method**: [How tested]
- **Predicted outcome**: [What I expected]
- **Actual outcome**: [What happened]
- **Conclusion**: ✓ Confirmed / ✗ Rejected / ~ Inconclusive

#### Test 2: [Hypothesis]
[Same structure]

### Root Cause Identified
[Clear statement of what the bug was and why it occurred]

## Phase 5: Banishment

### Fix Applied
- **Files changed**: [list]
- **Changes made**: [description]
- **Test added**: [test file and what it verifies]

### Prevention Measures
- [ ] Regression test added
- [ ] Defensive code added
- [ ] Monitoring/alerting updated
- [ ] Documentation updated
- [ ] Agent memory updated
- [ ] Related code audited

### Lessons Learned
[What did we learn from this investigation?]

### Agent Memory Entry

Record the insight for future debugging sessions:

```python
add_long_term_insight(
    "Root cause: [fundamental issue]. "
    "Solution: [how resolved]. "
    "Prevention: [safeguards added]"
)
```

Template for manual documentation:
```
Pattern: [pattern name]
Root Cause: [fundamental issue]
Fix: [how resolved]
Prevention: [safeguards added]
Lesson: [key insight]
```
```

## Exit Criteria

You can exit witching hour mode when ALL of these are true:

- [ ] Root cause identified and understood
- [ ] Fix implemented and tested
- [ ] Regression test added
- [ ] Witching hour report completed
- [ ] Agent memory updated
- [ ] Prevention measures in place
- [ ] Related code audited for same pattern

## Anti-Patterns to Avoid

- **Shotgun debugging**: Random changes hoping something works
- **Symptom fixing**: Addressing symptoms without finding root cause
- **Premature optimization**: Assuming performance issue before measuring
- **Confirmation bias**: Only looking for evidence that supports your theory
- **Over-instrumentation**: Adding so much logging it obscures the issue
- **Giving up too early**: Switching to workarounds before exhausting options

## Success Criteria

A successful witching hour investigation:
- Documents the entire investigation process
- Identifies root cause, not just symptoms
- Implements fix with regression test
- Adds prevention measures
- Updates agent memory for future reference
- Provides clear lessons learned
