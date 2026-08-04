---
description: "Generate test scenarios for a feature or the current branch's changes. Produces checklists, gherkin specs, playwright tests, and exploratory charters."
---

# QA (Test Scenario Generation)

Generate test scenarios for a feature or the current branch's changes.

## Usage

```bash
/qa "user authentication flow"          # Generate scenarios for a described feature
/qa --format=checklist                  # Manual QA checklist (default)
/qa --format=gherkin                    # Given-When-Then BDD scenarios
/qa --format=playwright                 # Playwright test skeleton
/qa --charter                           # Exploratory test charter
/qa --charter --timebox=60              # Charter with specific time box (minutes)
```

## Arguments: $ARGUMENTS

### Step 1: Determine Feature Context

**If arguments contain a feature description:**
- Use the description as the basis for test scenarios

**If no feature description provided:**
- Analyze the current branch's changes vs main: `git diff main..HEAD`
- Derive test scenarios from the actual code changes

### Step 2: Identify Test Scenarios

From the feature context, identify:
- **Positive paths**: Each capability becomes a test scenario
- **Edge cases**: Boundary conditions, empty states, large inputs
- **Error handling**: Invalid inputs, network failures, permission errors
- **Integration points**: Where components interact

### Step 3: Output in Requested Format

Parse format from arguments:
- `--format=checklist` or no format flag → Markdown checklist (default)
- `--format=gherkin` → Gherkin/BDD scenarios
- `--format=playwright` → Playwright TypeScript test skeleton
- `--charter` → Exploratory test charter

### Output Format: Checklist (Default)

```markdown
## QA Checklist: [Feature Name]

### Setup Prerequisites
- [ ] [prerequisite-1]
- [ ] [prerequisite-2]

### Positive Path Tests
- [ ] **Scenario 1:** [description]
  - **Action:** [what to do]
  - **Expected:** [outcome]

### Edge Cases
- [ ] **Edge Case 1:** [description]
  - **Action:** [what to do]
  - **Expected:** [outcome]

### Error Handling
- [ ] **Error 1:** [scenario]
  - **Action:** [trigger error]
  - **Expected:** [graceful handling]
```

### Output Format: Gherkin/BDD

```gherkin
Feature: [Feature Name]

  Background:
    Given [common setup]

  Scenario: [test scenario name]
    Given [precondition]
    When [action]
    Then [expected outcome]

  Scenario: Error handling - [error case]
    Given [precondition]
    When [trigger error]
    Then [expected error handling]
```

### Output Format: Playwright

```typescript
import { test, expect } from '@playwright/test';

test.describe('[Feature Name]', () => {
  test.beforeEach(async ({ page }) => {
    // Setup
  });

  test('should [scenario]', async ({ page }) => {
    // Arrange → Act → Assert
  });

  test('should handle [edge case]', async ({ page }) => {
    // Edge case test
  });
});
```

### Output Format: Exploratory Charter

```markdown
# Exploratory Test Charter: [Feature Name]

## Mission
**Explore** [feature]
**With** [tools and data]
**To discover** [bugs, edge cases, unexpected behaviors]

## Time Box
| Duration | Focus |
|----------|-------|
| Total | [timebox] minutes |
| Setup | 15% |
| Exploration | 70% |
| Debrief | 15% |

## Areas to Explore
[Generated from feature context]

## Session Log Template
| Time | Action | Observation | Severity |
|------|--------|-------------|----------|
```

## Test Scenario Derivation Rules

1. **Positive Path**: Each feature capability → test scenario
2. **Edge Cases**: Identify boundary conditions (empty, max, special chars)
3. **Error Handling**: Generate negative tests for each failure mode
4. **Integration**: Test interactions between components

## Handing Off This Output

This command produces the test artifact itself, not a handoff communication. To turn this output into an audience-tailored testing plan handoff (technical or stakeholder), run `/haunt:herald testing-plan --audience=<technical|stakeholder>` -- see the `gco-comms` skill for the handoff standards.
