---
name: gco-ralph-dev
description: Ralph Wiggum loop workflow for autonomous dev work. Invoke when using /ralph-req command or performing iterative development on XS/S/M requirements with clear completion criteria.
---

# Ralph Dev: Autonomous Iteration for Dev Work

## Purpose

This skill provides guidance for using the Ralph Wiggum iteration loop in dev work - a persistent autonomous workflow that keeps trying until completion criteria are met. Ralph is optimized for focused requirements (XS/S/M) with clear, testable completion criteria.

## When to Invoke

- Working in Ralph loop mode (triggered by `/ralph-req` command)
- Need guidance on completion promise protocol
- Unsure whether to continue iterating or signal blocked
- XS/S/M requirement with iterative refinement workflow

## When to Use Ralph Loops

### Good Use Cases (XS/S/M Requirements)

Ralph loops work best for:

- **Well-defined tasks with automated verification**
  - Tests provide clear pass/fail signal
  - Linters/formatters give immediate feedback
  - Completion criteria are testable and unambiguous

- **Greenfield implementations**
  - No legacy constraints or unclear dependencies
  - Clear starting point and end state
  - Files to create/modify are explicit

- **Iterative refinement work**
  - Test failures guide next iteration
  - Each iteration builds on previous work
  - Learning from git history improves approach

### Bad Use Cases (Avoid Ralph Loop)

Do NOT use Ralph loops for:

- **SPLIT-sized requirements**
  - Too many failure modes to iterate efficiently
  - Context loss across many iterations
  - Better served by manual TDD with human oversight
  - **Solution:** Decompose into XS/S/M requirements first

- **Judgment-heavy decisions**
  - Architectural choices requiring human approval
  - Trade-off analysis between multiple approaches
  - Security-sensitive code requiring review
  - **Solution:** Use `/summon dev` for manual work

- **Ambiguous or exploratory work**
  - Unclear objectives or success criteria
  - Research-oriented tasks
  - Spike code or prototypes
  - **Solution:** Manual exploration, then formalize as requirement

- **Tasks requiring external dependencies**
  - Waiting for API access or credentials
  - Missing external tools or services
  - Blocked by other requirements
  - **Solution:** Signal blocked, wait for resolution

## Completion Promise Protocol

### Promise Structure

The completion promise is derived from the requirement's `Completion:` field and formatted as XML:

```xml
<promise>
- {criterion_1_verified}
- {criterion_2_verified}
- {criterion_3_verified}
</promise>
```

### When to Output Promise

Output `<promise>ALL_CRITERIA_VERIFIED</promise>` ONLY when:

1. **All completion criteria are met** (not "probably works" or "looks done")
2. **Tests pass** (if applicable)
3. **Files exist at expected paths** (verified, not assumed)
4. **Output matches specification** (checked against requirement)

### When NOT to Output Promise

Do NOT output promise when:

- Tests are failing (even if implementation "looks right")
- Completion criteria partially met (all or nothing)
- Assuming work is done without verification
- Guessing that external dependencies work

### Example: Proper Promise Usage

**Requirement completion criteria:**
```markdown
**Completion:** Command file exists with proper YAML frontmatter, usage syntax documented, and workflow steps documented
```

**Agent verification before promise:**
```bash
# Verify file exists
ls -la Haunt/commands/ralph-req.md

# Verify YAML frontmatter present
head -n 5 Haunt/commands/ralph-req.md | grep "^name:"

# Verify usage syntax section exists
grep -A 5 "## Usage" Haunt/commands/ralph-req.md

# Verify workflow section exists
grep -A 10 "## Workflow" Haunt/commands/ralph-req.md
```

**Only after all checks pass:**
```xml
<promise>ALL_CRITERIA_VERIFIED</promise>
```

## Smart Exit vs Blocked Signaling

### Smart Exit (Completion Promise)

Use completion promise when work is genuinely complete:

```xml
<promise>ALL_CRITERIA_VERIFIED</promise>
```

**Triggers:**
- All tasks checked off
- All completion criteria verified
- Tests passing (if applicable)
- No outstanding issues

**Result:**
- Loop terminates
- Requirement marked 🟢 Complete
- Roadmap updated automatically

### Blocked Signaling

Use blocked signal when genuinely stuck:

```xml
<blocked>REASON</blocked>
```

**Valid block reasons:**
- Missing access/credentials: `<blocked>Missing API credentials for service X</blocked>`
- Conflicting requirements: `<blocked>Completion criteria conflict: X requires Y but Y requires not-X</blocked>`
- Unclear specification: `<blocked>Requirement unclear: what should happen when input is empty?</blocked>`
- External dependency: `<blocked>Waiting for external service deployment</blocked>`

**Invalid block reasons (keep iterating instead):**
- Test failures: Fix the test, don't block
- First attempt didn't work: Try different approach
- Bug in code: Debug and fix, don't block
- Implementation is hard: Harder ≠ impossible

**Result:**
- Loop pauses
- User prompted for guidance
- Loop resumes after clarification

### Decision Tree

```
Am I truly unable to proceed?
├─ Yes → <blocked>REASON</blocked>
│   ├─ Missing information from user?
│   ├─ External dependency unavailable?
│   └─ Conflicting/impossible requirements?
└─ No → Continue iterating
    ├─ Tests failing? → Debug and fix
    ├─ Bug in code? → Fix the bug
    ├─ Approach not working? → Try different approach
    └─ Hard but possible? → Keep trying
```

## Iteration Best Practices

### Check Previous Work Each Iteration

Before starting next iteration, review:

1. **Git log** - What did I change last iteration?
   ```bash
   git log --oneline -5
   git show HEAD
   ```

2. **File state** - What's the current state?
   ```bash
   cat {file_being_worked_on}
   ```

3. **Test output** - What's still failing?
   ```bash
   npm test  # or pytest, or go test, etc.
   ```

### Avoid Repeating Failed Approaches

**WRONG (Iteration Loop):**
```
Iteration 1: Try approach A → Test fails
Iteration 2: Try approach A again → Test fails
Iteration 3: Try approach A with minor tweak → Test fails
```

**RIGHT (Learning Iteration):**
```
Iteration 1: Try approach A → Test fails (error: X)
Iteration 2: Fix error X, try approach A → Test fails (error: Y)
Iteration 3: Fix error Y, try approach A → Test passes ✓
```

### Learn from Error Messages

Extract signal from failures:

**Test failure example:**
```
AssertionError: Expected 5, got 3
  File "test_calculator.py", line 42
    assert result == 5
```

**What to extract:**
- Expected: 5
- Actual: 3
- Location: test_calculator.py:42
- **Next step:** Find where result is calculated, debug why it's 3 instead of 5

### Incremental Progress

Make small, verifiable changes:

**WRONG (Big Bang):**
- Iteration 1: Implement entire feature → Multiple test failures, unclear which change broke what

**RIGHT (Incremental):**
- Iteration 1: Implement function stub → Tests fail as expected
- Iteration 2: Add basic logic → Some tests pass
- Iteration 3: Add error handling → More tests pass
- Iteration 4: Fix edge cases → All tests pass ✓

## Size Support and Iteration Limits

### Supported Sizes

| Size | Supported | Max Iterations | Rationale |
|------|-----------|----------------|-----------|
| **XS** | ✓ Yes | 30 | Perfect fit - simple, focused, 1-2 files |
| **S** | ✓ Yes | 50 | Good fit - small but multi-step, 2-4 files |
| **M** | ✓ Yes | 75 | Moderate complexity - needs more iterations but manageable |
| **SPLIT** | ✗ No | - | Too large - needs decomposition first |

**M-sized considerations:**
- More iterations expected (30-50 range typical)
- Signal blocked earlier if stuck (don't burn through 75 iterations)
- Consider decomposing if work becomes unclear mid-loop
- Larger context to track - document progress in commits

**Recommendation for SPLIT-sized work:**
1. Use `/decompose REQ-XXX` to split into XS/S/M requirements
2. Run `/ralph-req` on each sub-requirement
3. Coordinate results manually if dependencies exist

### Size Validation

Ralph loop enforces size restriction:

```
if requirement.effort == "SPLIT":
    error("Ralph loop only supports XS/S/M requirements. Decompose first.")
```

**User sees (for SPLIT):**
```
❌ REQUIREMENT TOO LARGE FOR RALPH LOOP

Requirement: REQ-XXX (Effort: SPLIT)
Ralph loop supports: XS, S, M only

SPLIT-sized requirements should be decomposed first:
  /decompose REQ-XXX
```

## Iteration Awareness Protocol

### What to Check Each Iteration

```bash
# 1. What changed last iteration?
git log -1 --stat

# 2. What's the current state?
ls -la {files_from_requirement}

# 3. Are tests passing?
npm test  # or appropriate test command

# 4. What completion criteria remain?
grep "^- \[ \]" .haunt/plans/roadmap.md | grep REQ-XXX
```

### When to Stop Iterating

**Stop and output promise when:**
- All tests pass
- All completion criteria verified
- No outstanding tasks
- Files exist and contain expected content

**Stop and signal blocked when:**
- Genuinely stuck (missing info, conflicting requirements)
- External dependency unavailable
- Unclear specification prevents progress

**Keep iterating when:**
- Tests are failing (fix them)
- Code has bugs (debug them)
- Approach didn't work (try different approach)
- Progress is slow but possible

### Max Iterations Behavior

Default: 10 iterations

**What happens when max reached:**
1. Loop pauses
2. User sees progress report:
   - Completed criteria
   - Incomplete criteria
   - Iteration count

3. User chooses:
   - Continue (+5 more iterations)
   - Provide guidance to unblock
   - Cancel and mark incomplete

**How to avoid hitting max:**
- Check previous work each iteration (don't repeat failures)
- Make incremental progress (small, verifiable changes)
- Signal blocked early if genuinely stuck (don't burn iterations)

## Examples

### Example 1: Successful XS Requirement

**Requirement:** REQ-408 Create /ralph-req command definition

**Completion criteria:**
- Command file exists with proper YAML frontmatter
- Usage syntax documented
- Workflow steps documented

**Ralph loop iterations:**

**Iteration 1:**
```bash
# Create file structure
cat > Haunt/commands/ralph-req.md << 'EOF'
---
name: ralph-req
description: Start persistent dev work using Ralph Wiggum loop
---
# Ralph-Req
...
EOF
```

**Iteration 2:**
```bash
# Verify file exists
ls -la Haunt/commands/ralph-req.md  # ✓ Exists

# Verify YAML frontmatter
head -n 5 Haunt/commands/ralph-req.md | grep "^name:"  # ✓ Present

# Verify usage section
grep -A 5 "## Usage" Haunt/commands/ralph-req.md  # ✓ Documented

# Verify workflow section
grep -A 10 "## Workflow" Haunt/commands/ralph-req.md  # ✓ Documented

# All criteria met!
```

**Output:**
```xml
<promise>ALL_CRITERIA_VERIFIED</promise>
```

**Result:** Requirement marked 🟢 Complete after 2 iterations

---

### Example 2: Blocked on Unclear Specification

**Requirement:** REQ-XXX Add user validation

**Completion criteria:**
- User input validated before saving

**Problem:** Requirement doesn't specify WHAT validation (email format? password strength? age restrictions?)

**Ralph loop iterations:**

**Iteration 1:**
```typescript
// Implement basic validation (guessing at requirements)
function validateUser(user: User): boolean {
  return user.email.includes('@');  // Is this enough?
}
```

**Iteration 2:**
```bash
# Review requirement - still unclear what "validated" means
# Tried basic validation, but completion criteria don't specify requirements
# Cannot verify completion without knowing exact validation rules
```

**Output:**
```xml
<blocked>Requirement unclear: what specific validation rules should be applied? (email format? password strength? required fields?)</blocked>
```

**Result:** Loop pauses, user clarifies validation requirements, loop resumes

---

### Example 3: Test Failure - Keep Iterating (Don't Block)

**Requirement:** REQ-XXX Add calculator function

**Completion criteria:**
- Function adds two numbers correctly
- Tests pass

**Ralph loop iterations:**

**Iteration 1:**
```typescript
function add(a: number, b: number): number {
  return a - b;  // Bug: using subtraction instead of addition
}
```

**Test output:**
```
FAIL: Expected 5, got -1
```

**Iteration 2:**
```bash
# Review test failure - expected 5, got -1
# Check implementation - found bug: using subtraction instead of addition
# Fix: Change - to +
```

```typescript
function add(a: number, b: number): number {
  return a + b;  // Fixed
}
```

**Test output:**
```
PASS: All tests passing ✓
```

**Output:**
```xml
<promise>ALL_CRITERIA_VERIFIED</promise>
```

**Result:** Requirement marked 🟢 Complete after 2 iterations

**Key lesson:** Test failures are NOT blocking reasons - they're signals to fix code!

## Integration with Workflow

### Ralph Loop vs Manual Dev

| Scenario | Use Ralph Loop | Use Manual Dev |
|----------|----------------|----------------|
| XS/S requirement, clear criteria | `/ralph-req REQ-XXX` | - |
| M-sized requirement | - | `/summon dev` + TDD |
| Ad-hoc task (not in roadmap) | - | `/summon dev` |
| Exploratory/research work | - | `/summon research` |
| Iterative refinement needed | `/ralph-req REQ-XXX` | - |
| One-shot implementation | - | `/summon dev` |

### Workflow Integration Example

```
/seance Add validation helper
  └─> PM creates REQ-408 (XS, clear criteria)
  └─> /ralph-req REQ-408
      ├─> Agent iterates (check previous work, fix issues)
      ├─> Agent verifies completion criteria
      └─> Agent outputs: <promise>ALL_CRITERIA_VERIFIED</promise>
  └─> Roadmap auto-updated to 🟢
  └─> User notified: "REQ-408 complete"
```

## Troubleshooting

### Problem: Loop Repeats Same Failed Action

**Symptom:** Agent keeps trying same approach that fails

**Diagnosis:** Not checking git log/file state each iteration

**Solution:**
1. Add explicit git log check at start of each iteration
2. Review error messages for signal
3. If stuck after 3 attempts, try completely different approach
4. If still stuck, consider signaling blocked

### Problem: Loop Completes But Work Is Incomplete

**Symptom:** Agent outputs promise but tests fail or criteria unmet

**Diagnosis:** Completion criteria too vague or agent misinterpreting

**Solution:**
1. Review completion criteria in requirement
2. Tighten criteria to be more specific and testable
3. Add test verification to completion criteria
4. Update requirement, restart loop

### Problem: Loop Gets Blocked Immediately

**Symptom:** Agent signals blocked on iteration 1

**Diagnosis:** Missing context, access, or prerequisite

**Solution:**
1. Review block reason
2. Provide necessary context/access
3. If blocker is external, wait for resolution
4. If requirement is unclear, clarify and resume

### Problem: Max Iterations Without Progress

**Symptom:** Hit max iterations (10+) with no completion

**Diagnosis:** Requirement too large or underspecified

**Solution:**
1. Review progress - what's blocking?
2. Check if requirement is M-sized (should be decomposed)
3. Check if completion criteria are testable
4. Consider switching to manual TDD with human oversight

## Non-Negotiable Rules

1. **Only XS/S requirements** - M/SPLIT must be decomposed first
2. **Output promise ONLY when verified** - Not "probably works" or "looks done"
3. **Check previous work each iteration** - Don't repeat failed approaches
4. **Block only when genuinely stuck** - Test failures ≠ blocked
5. **Make incremental progress** - Small, verifiable changes each iteration

## See Also

- `Haunt/commands/ralph-req.md` - Ralph loop command definition
- `gco-tdd-workflow` - Test-driven development workflow
- `gco-completion-checklist` - Verification before marking complete
- `.haunt/docs/research/ralph-wiggum-analysis.md` - Full analysis and rationale
