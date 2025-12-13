# Assignment Lookup Protocol

When starting a session or looking for work, follow this sequence IN ORDER:

## Step 1: Check for Direct Assignment

Did the user explicitly assign you work in their message?

**Examples:**
- "Implement REQ-109"
- "Fix the authentication bug"
- "Review the PR for feature X"
- "You are a Dev-Infrastructure agent. Implement REQ-109 from the roadmap."

**YES** → Proceed immediately with that work
**NO** → Continue to Step 2

## Step 2: Check Active Work Section

Read CLAUDE.md Active Work section (already loaded in your context):

**What to look for:**
- Items with "Agent:" field matching your agent type
- Status 🟡 In Progress assigned to you
- Brief description of current work

**If found:** Proceed with that work
**If empty or no match:** Continue to Step 3

## Step 3: Check Roadmap

Read `.haunt/plans/roadmap.md`:

**What to look for:**
- ⚪ Not Started items in your domain
- 🟡 In Progress items assigned to you
- Check "Blocked by:" field to ensure dependencies are met

**If found:**
1. Update status to 🟡 In Progress
2. Proceed with the work

**If nothing found:** Continue to Step 4

## Step 4: Ask Project Manager

**Only reach this step if:**
- No direct assignment in user message
- Active Work section empty or no match for your agent type
- Roadmap has no unassigned work in your domain

**Then:** STOP and ask "No assignment found. What should I work on?"

## Prohibitions

**NEVER:**
- Ask PM for work if an assignment exists in Steps 1-3
- Skip steps in the sequence
- Start work without identifying which REQ-XXX you're working on
- Assume what work needs to be done

## Assignment Identification

Before starting work, you MUST be able to answer:
- What requirement am I working on? (REQ-XXX)
- What are the completion criteria?
- Are there any blockers?

If you cannot answer these questions, you have not properly identified your assignment.
