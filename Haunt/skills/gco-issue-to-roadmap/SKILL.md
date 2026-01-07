---
name: gco-issue-to-roadmap
description: Automatically triggered when user reports issues, bugs, ideas, or feature requests. Triggers on phrases like "I found a bug", "there's an issue", "this is broken", "X doesn't work", "I want to add", "we should build", "new feature", "log this", "track this", "add to roadmap", "we need to". Runs the full idea-to-roadmap workflow automatically.
---

# Issue to Roadmap Workflow

This skill activates automatically when you detect the user is reporting an issue, bug, idea, or feature request. It orchestrates the complete workflow from initial report to roadmap item.

## Trigger Phrases

Activate this workflow when the user says anything like:

**Problem/Bug Reports:**
- "I found a bug..."
- "There's an issue with..."
- "This is broken..."
- "X doesn't work..."
- "X is failing..."
- "Getting an error when..."
- "Something's wrong with..."

**Ideas/Feature Requests:**
- "I want to add..."
- "We should build..."
- "New feature:..."
- "What if we..."
- "Can we add..."
- "It would be nice if..."
- "We need..."

**Explicit Logging:**
- "Log this..."
- "Track this..."
- "Add to roadmap..."
- "Create a ticket for..."
- "We need to fix..."
- "Put this on the backlog..."

## Workflow Execution

**Quick Mode Flow:** Steps 1 → 2 → 2.5 (Sanity Check) → 3 → 4 → 4.5 (Project Detection) → 5 → 6
**Full Mode Flow:** Steps 1 → 2 → Escalate to detailed skills

### Step 1: Acknowledge and Confirm Understanding

Immediately respond with:

```
I'll log this to the roadmap. Let me confirm I understand:

**Issue/Request:** [One-line summary of what you heard]
**Type:** [Bug | Feature | Enhancement | Refactor]
**Affected Area:** [Component/file/system affected, if mentioned]

[If anything is unclear, ask 1-2 specific questions]
[If clear enough to proceed, say "Processing..." and continue]
```

### Step 2: Context Check

Before proceeding, verify you have enough context:

**Required (must have or ask):**
- What is the problem/request?
- Where does it occur? (file, feature, workflow)

**Optional (proceed without, note as TBD):**
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Priority/urgency

If critical context is missing, ask ONE focused question. Do not ask multiple questions - get the minimum needed to proceed.

### Step 2.5: Sanity Check (Quick Mode Only)

**Quick Mode requires this check before Step 3:**

Ask yourself: "Is this the simplest solution? Could we solve this by modifying existing code instead of adding new?"

Answer YES/NO + 1 sentence. If the check reveals significant complexity or need for a new system, escalate to Full Mode instead.

**Time budget:** 30 seconds.

### Step 3: Generate Requirement (Silent)

Create the requirement internally using this format:

```markdown
## REQ-[next number]: [Clear, action-oriented title]

**Type:** Bug | Feature | Enhancement | Refactor
**Reported:** [Date]
**Source:** User report

### Description
[2-3 sentences describing the issue/request]

### Acceptance Criteria
- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Verification: how to confirm it's fixed/done]

### Technical Notes
- Affected files: [if known, else "TBD - investigation needed"]
- Dependencies: [if any]
- Risks: [if any]
```

### Step 4: Size and Assign

Determine effort and assignment:

| Size | Criteria | Action |
|------|----------|--------|
| **S** | Single file, clear fix, <2 hours | Assign directly |
| **M** | Multiple files, 2-8 hours | Assign directly |
| **L+** | >8 hours or unclear scope | Break down first |

**Agent Assignment:**
- Bug in backend/API → Dev-Backend
- Bug in UI/frontend → Dev-Frontend
- Infrastructure/CI/CD → Dev-Infrastructure
- Needs investigation → Research-Analyst
- Unclear ownership → Flag for triage

### Step 4.5: Project Detection

Determine which project section to add the requirement under.

**Detection Order (check in sequence):**

1. **Explicit mention:** User said "for TrueSight", "in Familiar", "Haunt framework" → Use that project
2. **File path context:** Issue mentions `truesight/src/...` or `familiar/...` → Infer project
3. **Current working directory:** If running from a project subdir → Use that project
4. **Ask user:** If ambiguous, ask: "Which project? [Haunt/TrueSight/Familiar/Cross-Project]"

**Available Projects:**
| Project | Section Header | Description |
|---------|---------------|-------------|
| Cross-Project | `## Cross-Project Work` | Affects multiple projects |
| Haunt | `## Haunt Framework` | Agent framework and SDLC tooling |
| TrueSight | `## TrueSight` | ADHD productivity dashboard |
| Familiar | `## Familiar` | Personal command center |

### Step 5: Add to Roadmap

Append to `.haunt/plans/roadmap.md` **under the appropriate project section**:

```markdown
### ⚪ REQ-XXX: [Title]

**Type:** Bug | Feature | Enhancement | Refactor
**Reported:** [Date]
**Source:** User report
**Description:** [Brief description]

**Tasks:**
- [ ] [Task 1]
- [ ] [Task 2]

**Files:**
- `path/to/file.ext` (modify)

**Effort:** S | M
**Complexity:** SIMPLE | MODERATE
**Agent:** [Assigned agent]
**Completion:** [How to verify done]
**Blocked by:** None
```

**If starting immediately (status 🟡):** Also add to CLAUDE.md Active Work section:
```markdown
🟡 REQ-XXX: [Title]
   Agent: [Assigned agent]
   Brief: [One-line description]
   Status: Started
```

### Step 6: Confirm to User

Respond with:

```
Added to roadmap:

**REQ-XXX:** [Title]
**Project:** [Project name]
**Effort:** S/M
**Assigned to:** [Agent]
**Status:** ⚪ Not Started

[If L+ and broken down]: This was split into X smaller items.
[If needs investigation]: Flagged for investigation first.
```

## Quick Mode vs Full Mode

### Quick Mode (Default)

Use for clear, well-defined issues. Follows Steps 1-6 above with one mandatory sanity check:

**XS Sanity Check (before Step 3):**

Before generating the requirement, ask yourself:

> **"Is this the simplest solution? Could we solve this by modifying existing code instead of adding new?"**

Answer with YES/NO + 1 sentence explanation. This check ensures Quick mode doesn't skip critique entirely.

**Examples:**
- Bug fix: "YES - Fixing validation logic in existing login handler."
- Feature request: "NO - Dark mode requires new theme system and state management."
- Enhancement: "YES - Adding field to existing form component."

**Time budget:** 30 seconds for sanity check. Total Quick mode: ~90 seconds.

### Full Mode

When the request is complex or strategic:
1. Invoke `requirements-development` skill for formal requirements
2. Invoke `requirements-analysis` skill for strategic analysis
3. Invoke `roadmap-creation` skill for breakdown and planning

Trigger Full Mode when:
- User explicitly asks for detailed planning
- Request affects multiple systems
- Request has significant business impact
- Request is ambiguous and needs exploration
- Sanity check reveals significant complexity or new system needed

## Examples

### Example 1: Simple Bug

**User:** "The login button doesn't work on mobile"

**Response:**
```
I'll log this to the roadmap. Let me confirm I understand:

**Issue:** Login button non-functional on mobile devices
**Type:** Bug
**Affected Area:** Authentication/Login UI

Processing...

Added to roadmap:

**REQ-042:** Fix mobile login button
**Effort:** S
**Assigned to:** Dev-Frontend
**Status:** ⚪ Not Started
```

### Example 2: Feature Request

**User:** "We should add dark mode"

**Response:**
```
I'll log this to the roadmap. Let me confirm I understand:

**Request:** Add dark mode theme support
**Type:** Feature
**Affected Area:** UI/Theming system

This is a larger feature. Should I:
1. **Quick add** - Create a single roadmap item for investigation
2. **Full planning** - Run detailed requirements analysis and break into tasks

[User chooses, then proceed accordingly]
```

### Example 3: Vague Report

**User:** "Something's broken in the dashboard"

**Response:**
```
I'll log this to the roadmap. Let me confirm I understand:

**Issue:** Dashboard malfunction
**Type:** Bug
**Affected Area:** Dashboard

I need one clarification: What specifically isn't working? (e.g., not loading, wrong data, visual glitch, error message)
```

## Integration with Existing Skills

This skill coordinates with:
- **requirements-development** - For complex features needing formal specs
- **requirements-analysis** - For strategic/business impact analysis
- **roadmap-creation** - For breaking down large items
- **roadmap-workflow** - For status tracking and archiving

## Do NOT Trigger When

- User is asking a question, not reporting an issue
- User is discussing existing roadmap items
- User explicitly says "don't log this" or "just thinking out loud"
- The issue is already on the roadmap (check first)
