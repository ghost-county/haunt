# Exploratory Test Charter

> A structured approach to exploratory testing - systematic discovery through guided investigation.

## Charter Template

```markdown
# Exploratory Test Charter: {SESSION_TITLE}

**Charter ID:** {CHARTER_ID}
**Requirement:** {REQ_ID} - {REQ_TITLE}
**Date:** {DATE}
**Tester:** {TESTER_NAME}

---

## Mission Statement

**Explore** {target-area}
**With** {resources-and-tools}
**To discover** {information-sought}

---

## Scope

### In Scope

- {area-to-explore-1}
- {area-to-explore-2}
- {feature-or-component}

### Out of Scope

- {excluded-area-1}
- {excluded-area-2}

---

## Time Box

| Duration | Focus |
|----------|-------|
| **Total Time:** | {duration} minutes |
| **Setup:** | {setup-time} minutes |
| **Exploration:** | {explore-time} minutes |
| **Debrief:** | {debrief-time} minutes |

---

## Areas to Explore

### Primary Areas

1. **{area-1-name}**
   - Questions to answer: {questions}
   - Data conditions to try: {data-variations}
   - Configurations to test: {config-variations}

2. **{area-2-name}**
   - Questions to answer: {questions}
   - Data conditions to try: {data-variations}
   - Configurations to test: {config-variations}

### Risk Areas

| Risk | Priority | Exploration Focus |
|------|----------|-------------------|
| {risk-1} | High/Medium/Low | {what-to-test} |
| {risk-2} | High/Medium/Low | {what-to-test} |
| {risk-3} | High/Medium/Low | {what-to-test} |

### Edge Cases to Investigate

- **Boundaries:** {boundary-conditions}
- **Empty/Null States:** {empty-null-scenarios}
- **Error Conditions:** {error-scenarios}
- **Performance:** {performance-scenarios}
- **Concurrency:** {concurrent-scenarios}
- **Integration Points:** {integration-scenarios}

---

## Test Ideas and Heuristics

### Heuristics to Apply

| Heuristic | Application |
|-----------|-------------|
| **CRUD** | Create, Read, Update, Delete operations |
| **SFDPOT** | Structure, Function, Data, Platform, Operations, Time |
| **FEW HICCUPS** | Follow, Explore, Watch, Interrupt, Concentrate, Change, Unusual, Painful, Stress |
| **Consistency** | With requirements, with similar features, with user expectations |
| **Interruption** | Cancel, timeout, back button, refresh |

### Test Ideas

- [ ] {test-idea-1}
- [ ] {test-idea-2}
- [ ] {test-idea-3}
- [ ] {test-idea-4}
- [ ] {test-idea-5}

---

## Environment & Setup

- **Environment:** {environment-details}
- **Browser/Device:** {browser-or-device}
- **Test Data:** {test-data-requirements}
- **Dependencies:** {external-dependencies}
- **Access Required:** {permissions-or-credentials}

---

## Session Log

### Observations

| Time | Action | Observation | Severity |
|------|--------|-------------|----------|
| | | | |

### Bugs Found

| ID | Summary | Steps | Severity | Status |
|----|---------|-------|----------|--------|
| | | | | |

### Questions Raised

- [ ] {question-1}
- [ ] {question-2}

### Insights and Patterns

- {insight-1}
- {insight-2}

---

## Debrief Summary

### What was learned?

{key-learnings}

### What requires follow-up?

- [ ] {follow-up-1}
- [ ] {follow-up-2}

### Coverage achieved

- [ ] All primary areas explored
- [ ] Risk areas investigated
- [ ] Edge cases tested
- [ ] Bugs logged and documented

### Time breakdown

| Phase | Planned | Actual |
|-------|---------|--------|
| Setup | {planned} min | {actual} min |
| Exploration | {planned} min | {actual} min |
| Debrief | {planned} min | {actual} min |

### Session effectiveness rating

- [ ] Highly effective (many findings, good coverage)
- [ ] Moderately effective (some findings, partial coverage)
- [ ] Needs improvement (few findings, limited coverage)

---

## Next Session Recommendations

{recommendations-for-follow-up-sessions}
```

---

## Charter Format Explanation

### Mission Statement

The mission uses a structured format:
- **Explore**: What you're testing (component, feature, integration)
- **With**: Tools and resources available (browser, test data, access levels)
- **To discover**: What information you're seeking (bugs, edge cases, behaviors)

### Time Box Guidelines

| Session Type | Total Time | Recommended Split |
|--------------|------------|-------------------|
| Quick Scan | 30 min | 5/20/5 |
| Standard | 60 min | 10/40/10 |
| Deep Dive | 90 min | 15/60/15 |
| Extended | 120 min | 15/90/15 |

### Risk Prioritization

**High Priority Risks:**
- Security vulnerabilities
- Data integrity issues
- Critical path functionality
- Recently changed code

**Medium Priority Risks:**
- Performance concerns
- Unusual user paths
- Integration points
- Configuration variations

**Low Priority Risks:**
- Cosmetic issues
- Edge cases unlikely in production
- Deprecated functionality

### Common Edge Cases by Domain

**Web Applications:**
- Empty forms, max-length inputs
- Special characters, Unicode
- Session timeout, concurrent tabs
- Back/forward navigation
- Mobile responsive breakpoints

**APIs:**
- Missing/null parameters
- Invalid data types
- Rate limiting
- Authentication edge cases
- Large payloads

**Data Processing:**
- Empty datasets
- Maximum size datasets
- Duplicate entries
- Invalid data format
- Encoding issues

---

## Session Notes Template

For quick logging during exploration, use this simplified format:

```markdown
## Session Notes: {date} - {req_id}

**Time:** {start_time} - {end_time}
**Focus:** {primary-exploration-area}

### Findings

1. **[BUG]** {bug-description}
   - Steps: {reproduction-steps}
   - Severity: High/Medium/Low

2. **[QUESTION]** {question}
   - Context: {context}

3. **[OBSERVATION]** {observation}
   - Impact: {potential-impact}

### Coverage

- [x] {area-tested}
- [ ] {area-not-tested}

### Next Actions

- {action-item-1}
- {action-item-2}
```

---

## Integration with Haunt Framework

### Generating Charters

```bash
# Generate charter from requirement
/qa REQ-XXX --charter

# Generate charter with specific time box
/qa REQ-XXX --charter --timebox=60

# Generate charter focusing on risk areas
/qa REQ-XXX --charter --focus=risks
```

### Saving Charter Files

```bash
# Save generated charter
Save output to: .haunt/docs/qa/charter-{REQ-XXX}-{date}.md

# Save session notes
Save findings to: .haunt/progress/exploratory-{REQ-XXX}-{date}.md
```

### Pattern Detection Integration

After exploratory sessions, record significant findings for pattern detection:

```bash
# Log recurring issues to agent memory
/apparition remember "Exploratory testing found: {pattern-description}"

# Detect patterns across sessions
/seer --hunt
```

---

## See Also

- `/qa` - Generate test scenarios from requirements
- `/seer` - Pattern detection across codebase
- `/witching-hour` - Intensive debugging mode
- `Haunt/skills/gco-tdd-workflow/SKILL.md` - Test-driven development
