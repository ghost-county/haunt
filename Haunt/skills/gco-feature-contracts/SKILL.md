---
name: gco-feature-contracts
description: Defines immutable feature contract rules and what agents can/cannot modify in feature-contract.json files. Invoke when working with acceptance criteria, feature contracts, or marking features complete.
---

# Feature Contracts: Immutability and Agent Boundaries

## Purpose

Feature contracts (`.haunt/plans/feature-contract.json`) establish IMMUTABLE requirements that define what must be delivered. This skill defines exactly what agents can and cannot modify in feature contract files, ensuring acceptance criteria remain stable throughout implementation.

## Core Principle

**Feature Contract Immutability** - Acceptance criteria cannot be modified mid-implementation. This prevents scope creep and ensures agents deliver what was originally specified, not what became easier during implementation.

## When to Invoke

- Working with feature contract files
- Marking features as complete
- Updating implementation status
- Tempted to modify acceptance criteria
- Unsure what fields can be changed

## Feature Contract JSON Structure

```json
{
  "id": "FEAT-XXX",
  "title": "Feature title",
  "description": "Detailed description",
  "priority": 1,
  "status": "pending",
  "acceptance_criteria": [
    {
      "criterion": "Specific, testable criterion",
      "test_method": "How to verify"
    }
  ],
  "requirements": ["REQ-001", "REQ-002"],
  "created_at": "2025-12-09",
  "completed_at": null,
  "implementation_notes": []
}
```

## What Agents CAN Modify

**Allowed Changes:**
- `status` - Update to reflect progress ("pending" → "in_progress" → "complete")
- `implementation_notes` - Add technical details, decisions, gotchas
- `completed_at` - Set timestamp when ALL acceptance criteria pass

## What Agents CANNOT Modify

**Forbidden Changes:**
- `acceptance_criteria` - IMMUTABLE. Cannot add, remove, or change criteria
- `description` - IMMUTABLE. Cannot rewrite or clarify
- `priority` - IMMUTABLE. Cannot reprioritize
- `title` - IMMUTABLE. Cannot rename
- `requirements` - IMMUTABLE. Cannot change requirement list
- Removing features from the contract entirely

## Critical Rules

1. **No Partial Completion** - Cannot declare "complete" without ALL acceptance tests passing
2. **No Criteria Skipping** - Cannot skip acceptance criteria "because they're hard"
3. **No Scope Negotiation** - Cannot modify criteria to match what was built instead of what was specified

## Violation Consequences

**If you need to modify forbidden fields:**
1. STOP implementation
2. Document why the change is needed
3. Request human approval explicitly
4. Do NOT proceed until approval granted

**Common violation scenarios:**
- "This criterion is too hard, let me simplify it" → VIOLATION
- "I built something different but better" → VIOLATION
- "Let me just tweak the wording to match reality" → VIOLATION

## Escalation Path

When acceptance criteria are impossible or inappropriate:
1. Add detailed note to `implementation_notes` explaining the issue
2. Set `status` to "blocked"
3. Ask human: "Acceptance criterion X cannot be met because [reason]. How should we proceed?"
4. Wait for human decision before continuing

## Success Criteria

An agent correctly using this skill will:
1. Know exactly which JSON fields are mutable vs immutable
2. Never modify `acceptance_criteria` under any circumstances
3. Seek human approval when tempted to change forbidden fields
4. Only mark features complete when ALL criteria genuinely pass
