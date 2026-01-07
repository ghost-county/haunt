# Ralph-Req (Requirement-Driven Ralph Wiggum Loop)

Start persistent dev work on a requirement using the Ralph Wiggum iteration loop - the persistent agent that keeps trying until completion criteria are met.

## Usage

```
/ralph-req REQ-XXX [--max-iterations N]
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `REQ-XXX` | Yes | - | Requirement ID from roadmap |
| `--max-iterations` | No | 10 | Maximum iterations before requiring human intervention |

### Examples

```bash
# Start Ralph loop for specific requirement
/ralph-req REQ-408

# Limit iterations
/ralph-req REQ-408 --max-iterations 5

# Run with default settings
/ralph-req REQ-150
```

## Workflow

### 1. Extract Requirement from Roadmap

Read requirement details from `.haunt/plans/roadmap.md`:
- Title and description
- Tasks checklist
- Completion criteria
- Files to modify/create
- Agent assignment
- Effort size

### 2. Validate Requirement Size

**Supported sizes:** XS, S, M

**Blocked sizes:** SPLIT

Ralph Wiggum loop supports XS, S, and M requirements. SPLIT-sized work should be decomposed into smaller requirements first.

**Size validation:**
```
if effort == "SPLIT":
    error("Ralph loop only supports XS/S/M requirements. Decompose {req_id} first.")
```

### 3. Derive Completion Promise

Extract all completion criteria from requirement and format as promise:

**From requirement:**
```markdown
**Completion:** Command file exists with proper YAML frontmatter, usage syntax, and workflow documentation
```

**Derived promise:**
```
<promise>
- Command file exists at Haunt/commands/ralph-req.md
- YAML frontmatter includes name and description
- Usage syntax documented with examples
- Workflow steps documented
</promise>
```

### 4. Initialize Ralph Loop

Invoke the Ralph Wiggum iteration loop with:

**Prompt structure:**
```
You are gco-dev implementing {req_id}: {title}

Requirements:
{description}

Tasks:
{tasks_checklist}

Files:
{files_list}

Completion Criteria:
{completion_promise}

Work iteratively until ALL completion criteria are met. After each iteration:
1. Verify criteria against actual state
2. If ALL met, output: <promise>ALL_CRITERIA_VERIFIED</promise>
3. If any unmet, continue next iteration
4. If genuinely blocked, output: <blocked>REASON</blocked>
```

**Completion promise protocol:**
- Agent outputs `<promise>ALL_CRITERIA_VERIFIED</promise>` ONLY when all criteria are truly met
- NOT when "looks done" or "probably works" - when VERIFIED complete
- Loop terminates on promise output

**Blocked protocol:**
- Agent outputs `<blocked>REASON</blocked>` when genuinely stuck (missing access, conflicting requirements, unclear spec)
- Pauses loop and prompts user for guidance
- Loop resumes after user clarifies

**Iteration awareness:**
- Agent should check git log and file state each iteration
- Avoid repeating failed approaches
- Learn from previous iteration errors

### 5. Monitor Progress

Track iterations and provide feedback:

```
🎯 Starting Ralph loop for {req_id}...

Iteration 1: {action_summary}
Iteration 2: {action_summary}
...
Iteration N: ALL_CRITERIA_VERIFIED ✓

🟢 Requirement complete: {req_id}
```

### 6. Handle Termination Conditions

**Success termination:**
- Agent outputs `<promise>ALL_CRITERIA_VERIFIED</promise>`
- Update roadmap: Mark requirement 🟢 Complete
- Report completion to user

**Blocked termination:**
- Agent outputs `<blocked>REASON</blocked>`
- Pause loop, present reason to user
- Await user guidance, then resume or cancel

**Max iterations termination:**
- Reached `--max-iterations` without completion
- Report progress and ask user:
  - Continue with more iterations?
  - Provide guidance to unblock?
  - Cancel and mark incomplete?

## Size Support and Iteration Limits

| Size | Supported | Max Iterations | Rationale |
|------|-----------|----------------|-----------|
| XS | ✓ Yes | 30 | Perfect fit - simple, focused work |
| S | ✓ Yes | 50 | Good fit - small but multi-step |
| M | ✓ Yes | 75 | Moderate complexity - more iterations allowed |
| SPLIT | ✗ No | - | Too large - decompose first |

**M-sized considerations:**
- More iterations expected (30-50 typical)
- Signal blocked earlier if stuck
- Document progress in commits
- Consider decomposing if work becomes unclear

**Recommendation for SPLIT-sized work:**
```
/decompose REQ-XXX  # Split into XS/S/M requirements
/ralph-req REQ-XXX-1  # Run loop on each sub-requirement
/ralph-req REQ-XXX-2
```

## Output Messages

### Success
```
🎯 RALPH LOOP COMPLETE 🎯

Requirement: {req_id}: {title}
Iterations: {count}
Status: ALL_CRITERIA_VERIFIED ✓

Completion criteria met:
  ✓ {criterion_1}
  ✓ {criterion_2}
  ✓ {criterion_3}

Roadmap updated: {req_id} → 🟢 Complete
```

### Blocked
```
🚧 RALPH LOOP BLOCKED 🚧

Requirement: {req_id}: {title}
Iteration: {count}
Reason: {block_reason}

Agent needs guidance:
  {detailed_block_description}

How to proceed?
  [1] Provide clarification
  [2] Modify requirement
  [3] Cancel loop
```

### Max Iterations Reached
```
⏱️ RALPH LOOP TIMEOUT ⏱️

Requirement: {req_id}: {title}
Iterations: {max_iterations} (max reached)
Status: Incomplete

Progress:
  ✓ {completed_criteria}
  ✗ {incomplete_criteria}

Options:
  [1] Continue (+5 iterations)
  [2] Review progress and provide guidance
  [3] Cancel and mark incomplete
```

### Size Validation Error
```
❌ REQUIREMENT TOO LARGE FOR RALPH LOOP

Requirement: {req_id} (Effort: SPLIT)
Ralph loop supports: XS, S, M only

SPLIT-sized requirements should be decomposed first:
  /decompose {req_id}

This splits the work into smaller requirements that Ralph can iterate on effectively.
```

### Requirement Not Found
```
❌ REQUIREMENT NOT FOUND

Could not locate {req_id} in .haunt/plans/roadmap.md

Verify requirement exists:
  cat .haunt/plans/roadmap.md | grep {req_id}

Or view all requirements:
  /haunting
```

## Integration with Workflow

**When to use /ralph-req:**

| Use /ralph-req when: | Use /summon dev when: |
|---------------------|----------------------|
| XS/S/M focused requirements | Ad-hoc tasks not in roadmap |
| Clear completion criteria | Exploratory work |
| Iterative refinement needed | One-shot implementation |
| Want persistent retry | Single attempt sufficient |

**Workflow example:**

```
/seance Add validation helper
  └─> PM creates REQ-408 (XS, clear criteria)
  └─> /ralph-req REQ-408
  └─> Agent iterates until complete
  └─> Roadmap auto-updated to 🟢
```

## Troubleshooting

### Loop repeats same failed action
**Problem:** Agent not learning from previous iterations

**Solution:**
- Check if agent is reviewing git log/file state each iteration
- May need to provide guidance: "Previous approach failed because X, try Y instead"
- Consider if requirement is too vague (needs clearer completion criteria)

### Loop completes but work is incomplete
**Problem:** Completion criteria too loose or agent misinterpreting

**Solution:**
- Review completion criteria in requirement
- Tighten criteria to be more specific and testable
- Update requirement and restart loop

### Loop gets blocked immediately
**Problem:** Missing context or access

**Solution:**
- Review block reason
- Provide necessary context or access
- Resume loop with guidance

### Max iterations reached with no progress
**Problem:** Requirement may be too large or underspecified

**Solution:**
- Review progress - what's blocking?
- Consider decomposing requirement into smaller pieces
- Or switch to manual TDD workflow with human oversight

## See Also

- `/summon dev` - Spawn single dev agent for ad-hoc work
- `/decompose` - Split large requirements into smaller ones
- `/haunting` - View all active requirements
- `Haunt/skills/gco-ralph-dev/SKILL.md` - Ralph loop behavior guidance
- `Haunt/agents/gco-dev.md` - Dev agent character sheet with Ralph mode
