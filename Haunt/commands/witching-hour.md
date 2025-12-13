# Witching Hour (Intensive Debug Mode)

Enter the witching hour - when elusive bugs reveal themselves in the darkness. This command activates intensive debugging mode with enhanced logging, systematic investigation, and pattern correlation.

## Witching Hour Protocol: $ARGUMENTS

### When to Invoke

The witching hour is for those bugs that defy normal debugging:
- Production failures that can't be reproduced locally
- Intermittent issues with no clear pattern
- "It works sometimes" user reports
- Performance degradation with unclear cause
- Race conditions or timing-dependent bugs
- Standard debugging has failed

### Activation Sequence

When you invoke `/witching-hour [bug-description]`, the following protocol activates:

#### 1. Investigation Initialization

Create a witching hour investigation report:

```bash
# Generate investigation file
REPORT_FILE=".haunt/progress/witching-hour-$(date +%Y-%m-%d)-${BUG_DESC}.md"
```

Use the template from `gco-witching-hour` skill to structure the investigation.

#### 2. Load Debugging Skill

Invoke the `gco-witching-hour` skill for the complete investigation protocol:

```
The witching hour investigation skill provides a five-phase approach:
1. Shadow Gathering - Collect all available evidence
2. Spectral Analysis - Identify patterns and correlations
3. Illumination - Add enhanced instrumentation
4. The Hunt - Systematically test hypotheses
5. Banishment - Fix root cause and prevent recurrence
```

#### 3. Shadow Gathering Phase

Systematically collect evidence:

```bash
# Gather recent changes
echo "## Recent Changes" >> "$REPORT_FILE"
git log --since="7 days ago" --oneline >> "$REPORT_FILE"

# Collect error logs if available
echo "## Error Logs" >> "$REPORT_FILE"
# User should provide logs or point to log location

# Check for similar past issues
echo "## Similar Past Issues" >> "$REPORT_FILE"
git log --all --grep="$BUG_DESC" --oneline >> "$REPORT_FILE"
```

**Ask the user for:**
- Full error messages and stack traces
- Exact reproduction steps
- Environment details (OS, versions, config)
- When did it start happening?
- What changed recently?

#### 4. Spectral Analysis Phase

Guide the user through pattern analysis with these questions:

**Temporal Patterns:**
- Does it happen at specific times?
- Under specific load conditions?
- After certain uptime duration?

**Environmental Patterns:**
- Specific servers, regions, or environments?
- Specific user types or accounts?
- Specific data conditions?

**Code Patterns:**
- Recent code changes in related areas?
- Similar bugs in similar code?
- Common anti-patterns present?

**System Patterns:**
- Resource constraints (memory, CPU, connections)?
- Third-party service issues?
- Network or infrastructure problems?

Document each correlation with confidence level (High/Medium/Low).

#### 5. Illumination Phase

Guide instrumentation strategy:

```
Enhanced logging should be added at:
1. Entry points (where data enters)
2. Exit points (where errors surface)
3. State transitions (where things change)
4. Decision points (conditionals affecting flow)
5. Integration boundaries (APIs, databases, external services)

Every log entry should include:
- Unique trace_id for this investigation
- Timestamp
- Full context (user_id, request_id, relevant state)
- Operation being performed
```

Provide code examples from the skill for trace decorators and state snapshots.

#### 6. The Hunt Phase

Guide systematic hypothesis testing:

```
For each hypothesis:
1. State it clearly: "Bug occurs when X"
2. Define test: "I will verify by doing Y"
3. Predict outcome: "If true, I expect Z"
4. Run test and document results
5. Mark: ✓ Confirmed / ✗ Rejected / ~ Inconclusive
```

**Testing techniques available:**
- Binary search (git bisect for commit range)
- Isolation (test components separately)
- Simplification (minimal reproduction case)
- Amplification (run repeatedly to catch intermittent failures)
- Substitution (mock external dependencies)
- Comparison (diff working vs broken environments)

#### 7. Banishment Phase

Once root cause is identified, guide the fix:

**Fix checklist:**
- [ ] Root cause understood
- [ ] Fix addresses root cause (not symptoms)
- [ ] Test written (fails before fix, passes after)
- [ ] Fix tested in original failure environment
- [ ] Related code audited for same pattern
- [ ] Documentation updated if needed

**Prevention checklist:**
- [ ] Regression test added
- [ ] Defensive code added (validation, error handling, timeouts)
- [ ] Monitoring/alerting updated (if production issue)
- [ ] Agent memory updated with pattern and solution
- [ ] Witching hour report completed

### Output Format

Throughout the investigation, maintain the witching hour report with this structure:

```
🌙 WITCHING HOUR INVESTIGATION 🌙
Bug: [description]
Started: [timestamp]

=== PHASE 1: SHADOW GATHERING ===
Evidence collected:
- [Evidence item 1]
- [Evidence item 2]

=== PHASE 2: SPECTRAL ANALYSIS ===
Patterns identified:
1. [Pattern name] - Confidence: High/Medium/Low
   Evidence: [supporting facts]

Hypotheses to test:
1. [Hypothesis statement]

=== PHASE 3: ILLUMINATION ===
Instrumentation added:
- [Location]: [What was added]

Key observations:
- [Finding 1]
- [Finding 2]

=== PHASE 4: THE HUNT ===
Hypothesis testing:
✓ [Confirmed hypothesis]
✗ [Rejected hypothesis]

Root cause identified: [Clear statement]

=== PHASE 5: BANISHMENT ===
Fix: [Description of fix]
Prevention: [Safeguards added]
Test: [Regression test location]

Lessons learned: [Key insights]
```

### Exit Criteria

The witching hour ends when:
- [ ] Root cause identified and documented
- [ ] Fix implemented with test
- [ ] Prevention measures in place
- [ ] Agent memory updated
- [ ] Witching hour report complete
- [ ] Related code audited

### Quick Reference Commands

```bash
# Start investigation
/witching-hour [bug-description]

# During investigation:
git log --since="7 days ago" --oneline -- path/to/suspect/file
git bisect start  # Binary search through commits
pytest tests/ -v -k test_suspect  # Run specific tests
grep -r "trace_id=XXXX" logs/  # Follow trace through logs

# Complete investigation:
# 1. Update .haunt/progress/witching-hour-YYYY-MM-DD-bug.md
# 2. Commit fix with test
# 3. Use /apparition remember to log pattern
```

### Agent Memory Integration

After successful investigation, update agent memory:

```
Pattern: [Bug pattern name]
Root Cause: [Fundamental issue]
Fix: [How it was resolved]
Prevention: [Safeguards added]
Investigation Date: [YYYY-MM-DD]
Lesson: [Key insight for future debugging]
```

Use `/apparition remember` to store this for future reference.

### Notes

- The witching hour is intensive - reserve for truly difficult bugs
- Document thoroughly - the investigation process is as valuable as the fix
- Pattern correlation helps prevent future occurrences
- Enhanced logging should be removed or disabled after investigation
- Share lessons learned with team via agent memory

### Example Usage

```
User: /witching-hour checkout-fails-intermittently