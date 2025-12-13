# Contributing Skills to the Library

Guidelines for creating, reviewing, and maintaining high-quality skills in the Haunt framework.

## What is a Skill?

A skill is a self-contained, reusable workflow or knowledge module that agents can invoke on-demand. Skills reduce duplication across agent definitions and provide just-in-time guidance for specific tasks.

## Frontmatter Standards

Every skill MUST begin with YAML frontmatter:

```yaml
---
name: skill-name
description: When to trigger this skill and what it does. Include 3-5 trigger keywords.
---
```

**Requirements:**
- **name**: kebab-case, matches directory name (e.g., `roadmap-workflow`)
- **description**: 1-2 sentences covering: purpose, when to invoke, and trigger keywords

### Good Frontmatter Example

```yaml
---
name: commit-conventions
description: Standardized commit message format and branch naming conventions for Ghost County agent teams. Use when creating commits, naming branches, or preparing git operations. Triggers on "commit", "commit message", "branch name", "git commit", or version control questions.
---
```

### Bad Frontmatter Example

```yaml
---
name: CommitConventions
description: Commit stuff.
---
```

**Problems:** Name not kebab-case, description too vague, no trigger keywords, doesn't explain when to invoke.

## Trigger Keywords Best Practices

Include 3-5 action-oriented keywords that help agents discover skills.

**Good:** Action verbs ("commit", "review", "test"), task phrases ("create commit"), question patterns ("how do I")

**Bad:** Too generic ("code", "work"), overly specific ("update-line-42"), implementation details ("use pytest assert")

## Length Guidelines

**Target:** 40-120 lines (excluding frontmatter)

| Lines | Appropriate For | Example |
|-------|-----------------|---------|
| 40-60 | Single workflow or checklist | commit-conventions, context7-usage |
| 60-80 | Workflow with examples | feature-contracts, session-startup |
| 80-120 | Complex workflow or reference table | roadmap-workflow, code-review, tdd-workflow |

**Exceptions:** Skills may exceed 120 lines for essential reference tables, multi-language examples, or safety-critical topics. Add comment explaining why.

## Skill Structure Standards

**Required Sections:**
1. Title (H1): Descriptive name matching the skill purpose
2. Purpose: 2-3 sentences explaining the skill
3. Core Content: Workflows, checklists, examples, or reference tables

**Optional Sections:** "When to Invoke", "When NOT to Use", "Anti-Patterns", "Examples", "Success Criteria"

## Self-Contained Requirement

Skills must be independently readable without external context.

**Good:** Shows the complete format inline
**Bad:** References external documents ("see agent handbook section 4.2")

## Examples and Code Blocks

Include concrete examples showing correct usage.

**Good:** Complete, executable examples with context
**Bad:** Vague instructions that tell instead of show

## Skill Review Checklist

Use this checklist when reviewing new skill submissions:

- [ ] Frontmatter present with `name` and `description`
- [ ] Name is kebab-case and matches directory name
- [ ] Description includes 3-5 trigger keywords
- [ ] Length is 40-120 lines (or exception justified)
- [ ] Content is self-contained (no external dependencies)
- [ ] At least one concrete example included
- [ ] Uses imperative language ("Use this format") not agent-specific ("You must")
- [ ] No references to specific agent names (generic phrasing)
- [ ] Markdown formatting is correct (headers, code blocks, tables)
- [ ] Grammar and spelling are correct

## Quality Standards: Good vs Bad Skills

### Good Skill Example (Abbreviated)

```markdown
---
name: session-startup
description: Session workflow for agents - startup checks, memory restoration, and assignment verification. Use when starting sessions or initializing work. Triggers on "session start", "initialize", or "check assignment".
---

# Session Startup Checklist

Execute in order, every session, before ANY work:

1. [ ] `pwd` - Verify correct project directory
2. [ ] Check memory/context - Load previous session context
3. [ ] `git status` - Check recent changes
4. [ ] Run tests - Verify baseline before changes
5. [ ] Read roadmap - Find current assignment
6. [ ] If no assignment: STOP and ask for work

## When to Skip Steps

- Skip memory restoration if first session on new project
- Skip test verification for documentation-only changes
```

**Why this is good:**
- Clear frontmatter with triggers
- Self-contained checklist
- Concrete steps with examples
- Addresses edge cases

### Bad Skill Example

```markdown
---
name: DoStuff
---

# How to Work

You should do your work properly. Make sure to follow the guidelines that were discussed earlier. Always check with the Project Manager agent if you're unsure.
```

**Why this is bad:**
- Name not kebab-case
- No description or triggers in frontmatter
- Vague, non-actionable content
- References external context ("discussed earlier")
- References specific agent names

## Governance Principles

1. One skill, one purpose - Don't combine unrelated workflows
2. Skills are immutable during sessions - Version changes, don't modify mid-use
3. Prefer examples over explanations - Show, don't just tell
4. Action-oriented - Skills enable doing, not just knowing
5. No duplication - Check existing skills before creating new ones

## Submission Process

1. Create `Skills/your-skill-name/SKILL.md`
2. Add reference materials (optional): `Skills/your-skill-name/references/`
3. Run validation (if available): `bash Haunt/scripts/validation/validate-skills.sh`
4. Submit PR with skill file, rationale, and checklist confirmation

When in doubt, study existing skills in `Skills/` directory and prioritize clarity over brevity.
