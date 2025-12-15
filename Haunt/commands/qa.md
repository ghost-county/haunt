# QA (Test Scenario Generation)

Generate test scenarios from requirements - the quality assurance ritual that transforms acceptance criteria into executable test plans.

## Test Divination: $ARGUMENTS

### Usage

| Command | Output Format | Description |
|---------|---------------|-------------|
| `/qa REQ-XXX` | Markdown checklist | Manual QA checklist (default) |
| `/qa REQ-XXX --format=checklist` | Markdown checklist | Manual QA checklist with setup/scenarios/edge cases |
| `/qa REQ-XXX --format=gherkin` | Gherkin/BDD | Given-When-Then scenarios for BDD frameworks |
| `/qa REQ-XXX --format=playwright` | TypeScript/JavaScript | Playwright test skeleton ready for implementation |
| `/qa REQ-XXX --charter` | Exploratory charter | Structured exploratory testing session charter |
| `/qa REQ-XXX --charter --timebox=60` | Exploratory charter | Charter with specific time box (minutes) |
| `/qa REQ-XXX --charter --focus=risks` | Exploratory charter | Charter focusing on risk areas |

### Execution Workflow

#### Step 1: Parse Arguments

Extract requirement ID and format from command:

```python
import re

args = "$ARGUMENTS".strip()

# Extract REQ-XXX
req_match = re.search(r'REQ-\d+', args)
if not req_match:
    print("❌ No requirement ID found. Usage: /qa REQ-XXX [--format=<format>|--charter]")
    exit(1)

req_id = req_match.group(0)

# Check for charter mode first (takes precedence)
if '--charter' in args:
    output_format = 'charter'

    # Extract time box (default: 60 minutes)
    timebox_match = re.search(r'--timebox=(\d+)', args)
    timebox = int(timebox_match.group(1)) if timebox_match else 60

    # Extract focus area (default: all)
    if '--focus=risks' in args:
        focus = 'risks'
    elif '--focus=edges' in args:
        focus = 'edges'
    else:
        focus = 'all'
# Standard format selection
elif '--format=gherkin' in args:
    output_format = 'gherkin'
elif '--format=playwright' in args:
    output_format = 'playwright'
else:
    output_format = 'checklist'  # Default
```

#### Step 2: Read Requirement from Roadmap

```python
roadmap_path = ".haunt/plans/roadmap.md"

# Read roadmap
with open(roadmap_path, 'r') as f:
    content = f.read()

# Find requirement section
req_pattern = f"### [^#]* {req_id}: (.+?)\\n"
match = re.search(req_pattern, content)
if not match:
    print(f"❌ Requirement {req_id} not found in roadmap.")
    exit(1)

req_title = match.group(1)

# Extract requirement details
req_section_start = content.find(f"### {req_id}:")
req_section_end = content.find("\n### ", req_section_start + 1)
if req_section_end == -1:
    req_section_end = len(content)

req_section = content[req_section_start:req_section_end]

# Parse fields
description = extract_field(req_section, "**Description:**")
tasks = extract_tasks(req_section)
completion = extract_field(req_section, "**Completion:**")
files = extract_files(req_section)
```

#### Step 3: Generate Test Scenarios

Based on:
- **Tasks** (`- [ ]` items) - Each task becomes a test scenario
- **Completion criteria** - Testable acceptance criteria
- **Files** - Context for what needs testing
- **Description** - Overall feature understanding

#### Step 4: Output in Requested Format

See output examples below.

### Output Format: Checklist (Default)

```markdown
## QA Checklist for {req_id}: {req_title}

**Requirement:** {req_id}
**Type:** {type}
**Agent:** {agent}

### Setup Prerequisites

- [ ] {prerequisite-1}
- [ ] {prerequisite-2}

### Test Scenarios

#### Positive Path Tests

- [ ] **Scenario 1:** {derived-from-task-1}
  - **Action:** {what-to-do}
  - **Expected:** {outcome}

- [ ] **Scenario 2:** {derived-from-task-2}
  - **Action:** {what-to-do}
  - **Expected:** {outcome}

#### Edge Cases

- [ ] **Edge Case 1:** {identified-edge-case}
  - **Action:** {what-to-do}
  - **Expected:** {outcome}

#### Negative Tests

- [ ] **Error Handling 1:** {error-scenario}
  - **Action:** {trigger-error}
  - **Expected:** {graceful-handling}

### Completion Verification

- [ ] All tasks from requirement completed
- [ ] {completion-criterion-1}
- [ ] {completion-criterion-2}

### Notes

{any-additional-context}
```

### Output Format: Gherkin/BDD

```gherkin
Feature: {req_title}

  Background:
    Given {common-setup}

  Scenario: {test-scenario-1-name}
    Given {precondition}
    When {action}
    Then {expected-outcome}
    And {additional-verification}

  Scenario: {test-scenario-2-name}
    Given {precondition}
    When {action}
    Then {expected-outcome}

  Scenario Outline: {parameterized-test-name}
    Given {context}
    When I {action} with "<parameter>"
    Then the result should be "<expected>"

    Examples:
      | parameter | expected |
      | value1    | result1  |
      | value2    | result2  |

  Scenario: Error handling - {error-case}
    Given {precondition}
    When {trigger-error}
    Then {expected-error-handling}
```

### Output Format: Playwright

```typescript
import { test, expect } from '@playwright/test';

/**
 * Test Suite: {req_id}: {req_title}
 *
 * Requirements:
 * - {task-1}
 * - {task-2}
 * - {task-3}
 *
 * Completion Criteria:
 * - {completion-criterion-1}
 * - {completion-criterion-2}
 */

test.describe('{req_id}: {req_title}', () => {
  test.beforeEach(async ({ page }) => {
    // Setup: Navigate to relevant page
    // TODO: Add prerequisite steps
  });

  test('should {test-scenario-1-name}', async ({ page }) => {
    // Arrange: Set up test data
    // TODO: Add test data setup

    // Act: Perform action
    // TODO: Implement action (click, fill, navigate)

    // Assert: Verify expected outcome
    // TODO: Add assertions
    // expect(...).toBe(...);
  });

  test('should {test-scenario-2-name}', async ({ page }) => {
    // Arrange
    // TODO: Add setup

    // Act
    // TODO: Implement action

    // Assert
    // TODO: Add assertions
  });

  test('should handle {edge-case-name}', async ({ page }) => {
    // Edge case test
    // TODO: Implement edge case scenario
  });

  test('should {error-handling-scenario}', async ({ page }) => {
    // Negative test
    // TODO: Implement error scenario
    // expect(...).toContain('error message');
  });
});
```

### Output Format: Exploratory Charter

```markdown
# Exploratory Test Charter: Testing {req_title}

**Charter ID:** CHARTER-{req_id}-{date}
**Requirement:** {req_id} - {req_title}
**Date:** {date}
**Tester:** {tester_name}

---

## Mission Statement

**Explore** {feature_or_component}
**With** {available_tools_and_data}
**To discover** {bugs_edge_cases_unexpected_behaviors}

---

## Scope

### In Scope
{areas_derived_from_tasks}

### Out of Scope
- Areas not mentioned in requirement
- Unrelated functionality

---

## Time Box

| Duration | Focus |
|----------|-------|
| **Total Time:** | {timebox} minutes |
| **Setup:** | {timebox * 0.15} minutes |
| **Exploration:** | {timebox * 0.70} minutes |
| **Debrief:** | {timebox * 0.15} minutes |

---

## Areas to Explore

### Primary Areas (Derived from Tasks)

{for_each_task_generate_exploration_area}

### Risk Areas

| Risk | Priority | Exploration Focus |
|------|----------|-------------------|
| {risk_from_complexity} | High | {test_focus} |
| {risk_from_integration} | Medium | {test_focus} |
| {risk_from_data} | Medium | {test_focus} |

### Edge Cases to Investigate

- **Boundaries:** {boundary_conditions_from_completion_criteria}
- **Empty/Null States:** {empty_state_scenarios}
- **Error Conditions:** {error_scenarios_from_tasks}
- **Performance:** {performance_considerations}
- **Concurrency:** {concurrent_access_scenarios}

---

## Test Ideas

{generated_from_tasks_and_completion_criteria}

---

## Session Log Template

### Observations

| Time | Action | Observation | Severity |
|------|--------|-------------|----------|
| | | | |

### Bugs Found

| ID | Summary | Steps | Severity | Status |
|----|---------|-------|----------|--------|
| | | | | |

---

## Debrief Summary

(Complete after session)
```

### Example Usage

**Checklist format (default):**
```
/qa REQ-196
```

**Gherkin format:**
```
/qa REQ-196 --format=gherkin
```

**Playwright format:**
```
/qa REQ-196 --format=playwright > tests/e2e/req-196.spec.ts
```

**Exploratory charter (standard 60-min session):**
```
/qa REQ-196 --charter
```

**Exploratory charter (30-min quick session):**
```
/qa REQ-196 --charter --timebox=30
```

**Exploratory charter (focused on risks):**
```
/qa REQ-196 --charter --focus=risks
```

### Output Messages

**Success (Checklist):**
```
📋 TEST CHECKLIST GENERATED 📋

Requirement: {req_id}: {req_title}
Format: Markdown Checklist

Scenarios Generated:
- Setup Prerequisites: {count}
- Positive Tests: {count}
- Edge Cases: {count}
- Error Handling: {count}

✓ Checklist ready for manual QA

Save to file:
  Copy the output above to .haunt/docs/qa-{req_id}.md

Execute tests:
  Follow checklist and mark items as [x] when verified
```

**Success (Gherkin):**
```
🥒 GHERKIN SCENARIOS GENERATED 🥒

Requirement: {req_id}: {req_title}
Format: Gherkin/BDD

Feature: {feature-name}
Scenarios: {count}

✓ BDD scenarios ready for Cucumber/Behave

Save and execute:
  1. Save to tests/features/{req_id}.feature
  2. Implement step definitions
  3. Run: cucumber tests/features/{req_id}.feature
```

**Success (Playwright):**
```
🎭 PLAYWRIGHT TEST SKELETON GENERATED 🎭

Requirement: {req_id}: {req_title}
Format: TypeScript/Playwright

Test Suite: {req_id}: {req_title}
Test Cases: {count}

✓ Test skeleton ready for implementation

Next steps:
  1. Save output to: tests/e2e/{req_id}.spec.ts
  2. Replace TODO comments with actual test code
  3. Run: npx playwright test {req_id}
```

**Success (Exploratory Charter):**
```
🔮 EXPLORATORY CHARTER GENERATED 🔮

Requirement: {req_id}: {req_title}
Format: Exploratory Test Charter

Session Parameters:
- Time Box: {timebox} minutes
- Focus: {focus}

Charter Contents:
- Mission Statement: Defined
- Scope: {task_count} areas to explore
- Risk Areas: {risk_count} identified
- Edge Cases: {edge_count} scenarios
- Session Log: Template included

✓ Charter ready for exploratory testing

Next steps:
  1. Save charter to: .haunt/docs/qa/charter-{req_id}-{date}.md
  2. Schedule {timebox}-minute testing session
  3. Follow charter structure during exploration
  4. Record findings in Session Log section
  5. Complete Debrief Summary after session
  6. Log significant patterns: /apparition remember "..."

Template reference:
  See Haunt/templates/exploratory-charter.md for full template details
```

**Error (Requirement not found):**
```
❌ REQUIREMENT NOT FOUND

Could not locate {req_id} in .haunt/plans/roadmap.md

Verify requirement exists:
  cat .haunt/plans/roadmap.md | grep {req_id}

Or view all requirements:
  /haunting
```

**Error (Invalid format):**
```
❌ INVALID FORMAT

Unknown format: {format}

Supported formats:
  --format=checklist   (manual QA checklist)
  --format=gherkin     (BDD scenarios)
  --format=playwright  (Playwright test skeleton)
  --charter            (exploratory test charter)

Examples:
  /qa REQ-XXX --format=gherkin
  /qa REQ-XXX --charter --timebox=60
```

### Test Scenario Derivation Rules

When generating test scenarios from requirement tasks:

1. **Positive Path**: Each task becomes a test scenario
   - Task: "Create Haunt/commands/gco-qa.md"
   - Scenario: "should create command file with correct format"

2. **Edge Cases**: Identify boundary conditions
   - Task: "Support Playwright test skeleton format"
   - Edge Case: "should handle missing file paths gracefully"

3. **Error Handling**: Generate negative tests
   - Task: "Implement requirement parsing"
   - Negative: "should return error when REQ-XXX not found"

4. **Integration**: Test interactions between components
   - Task 1: "Parse REQ-XXX"
   - Task 2: "Generate scenarios"
   - Integration: "should parse requirement AND generate valid scenarios"

### Notes

- Test scenarios are derived from acceptance criteria, not implementation details
- Checklist format is best for manual QA and scripted testing
- Gherkin format integrates with Cucumber, Behave, or SpecFlow
- Playwright format requires completion of TODO comments before execution
- **Charter format** is best for exploratory testing sessions - guided but flexible
- All formats should be saved to appropriate test directories for version control
- Consider running `/qa` during requirement refinement (before implementation) to validate completeness
- Exploratory charters capture human intuition and can feed pattern detection via `/seer`

### Integration with Workflow

**When to use /qa:**

1. **During Planning**: Validate requirements are testable
2. **Before Implementation**: Generate test skeletons for TDD
3. **After Implementation**: Create QA checklist for verification
4. **For Reviews**: Provide test guidance to reviewers
5. **For Exploration**: Generate charter for structured exploratory sessions

**Workflow integration:**

```
/seance Add user authentication
  └─> PM creates REQ-XXX
  └─> /qa REQ-XXX --format=playwright  # Generate test skeleton
  └─> /summon dev Implement REQ-XXX    # Dev writes tests + code
  └─> /qa REQ-XXX                      # Generate QA checklist for review
  └─> /qa REQ-XXX --charter            # Generate charter for exploratory testing
```

**Exploratory testing workflow:**

```
/qa REQ-XXX --charter --timebox=60     # Generate 60-min charter
  └─> Tester follows charter structure
  └─> Records findings in Session Log
  └─> Completes Debrief Summary
  └─> /apparition remember "..."        # Log significant patterns
  └─> /seer --hunt                      # Check for recurring issues
```

### See Also

- `/summon dev` - Spawn agent to implement requirement
- `/haunting` - View active requirements and status
- `/exorcism <pattern>` - Generate pattern defeat tests
- `/seer` - Pattern detection for recurring issues
- `/apparition` - Agent memory interface for logging findings
- `Haunt/templates/exploratory-charter.md` - Full charter template with detailed guidance
- `Haunt/skills/gco-tdd-workflow/SKILL.md` - Test-driven development guidance
