---
last-verified: 2026-08-03
version: "1.0"
name: gco-comms
description: Standards for audience-tailored communication and documentation handoffs -- testing plans, technical documentation, and project updates to technical and stakeholder groups, plus workspace routing for Monday.com and Mermaid-first diagramming in place of Lucid.
---

# Comms & Documentation Standards

Turns project state (roadmap, requirements, QA artifacts, code changes) into audience-appropriate output. Default to minimal narration -- lead with takeaways and action items, not a walkthrough of how the doc was assembled.

## General Rules

- **No narration.** Skip "here's what I did" preambles and "in summary" closers. State the takeaway, then the action items.
- **Concise over complete.** Cut anything the reader doesn't need to act or decide.
- **One audience per artifact.** If a handoff needs both technical and stakeholder readers, produce two clearly separated artifacts, not one blended one.
- **No internal-tooling references.** A personal knowledge vault (e.g. an Obsidian vault), `.haunt/` plans, roadmaps, and any local notes/project directory that lives outside the repo being developed are the user's personal working materials -- never cite, link, or mention them (or Claude/haunt/agent mechanics generally) in anything that leaves this workspace. These are legitimate sources to *pull from* while drafting, but the artifact itself must read as if the user wrote it directly, with no trace of the tooling used to produce it. When an artifact needs to point somewhere for more detail, point to a shared system of record instead: e.g. Monday.com, SharePoint, Atlassian (Jira/Confluence), MS365, or whatever shared systems the org actually uses. If no such shared reference exists yet, say what needs to be created/published there rather than linking the internal/local path.

## Audience Model

| Audience | Content | Hard boundary |
|---|---|---|
| **Technical** (engineers, technical counterparts at partner orgs) | Our side's technical specifics, our requirements, explicit asks for clarification or requirements from their side | Never dictate what their solution should look like -- state our constraints/requirements and ask, don't prescribe their implementation |
| **Stakeholder** (business partners) | Business-impact framing only: workflow changes, known weaknesses/bugs, what to expect from their end of the experience | No technical detail, no jargon, no implementation discussion |

## Handoff Types

### 1. Testing Plan Handoff

Source: `/haunt:qa` output (checklist, gherkin, playwright, or charter).

- **Technical**: the QA artifact as-is, plus what's explicitly out of scope. Include a Mermaid diagram of the flow under test when the feature involves multiple steps/systems (see Diagramming below).
- **Stakeholder**: what's being tested and what could still go wrong, framed as business risk -- no test syntax, no file paths.

### 2. Technical Documentation Handoff

Source: code changes, architecture decisions, `.haunt/plans/` roadmap items.

- Context / Decision / Consequences shape (reuse ADR structure).
- Link actual files changed (`path:line`) instead of restating code in prose.
- Include a Mermaid diagram whenever documenting a workflow, process, or architecture -- this is the default reference, not an optional add-on.
- If this supersedes prior documentation, say so and link it.

### 3. Project Update Handoff

Source: `.haunt/plans/roadmap.md`, `TaskList` state, `.haunt/completed/`.

- **Technical**: REQ status, blockers, merged vs in review.
- **Stakeholder**: default format --

```markdown
## Project Update: [Project Name] -- [Date]

**Status:** on track | at risk | blocked

### Shipped
- [bullet]

### In progress
- [bullet]

### Needs your input
- [decision needed, or "none"]
```

## Diagramming: Mermaid First

Standard practice, not a Lucid substitute of convenience: include the Mermaid diagram source directly in the doc for any workflow, process, or architecture being documented (technical docs, testing handoffs). This keeps the diagram version-controlled next to the doc and gives the reader an inline reference without leaving the artifact.

- Put the ` ```mermaid ` block inline near the relevant section, not as an appendix.
- If a diagram already exists in `.haunt/plans/<project>/` or `wiki/`, update it in place rather than duplicating.

## Monday.com Workspace Routing

Route by content category, not by habit. The concrete mapping of categories to actual workspace names/IDs is user- and org-specific -- it belongs in the user's own Monday.com tooling config (e.g. a personal skill with a write allowlist), not hardcoded here. If that config exists, read it before any write and follow its pre-write allowlist check exactly; never bypass an allowlist because this skill names a target category. If a category isn't mapped to a workspace yet, stop and ask rather than guessing or defaulting to whichever workspace happens to already be writable.

| Content category | Typical target | Notes |
|---|---|---|
| Day-to-day dev work: tasks, REQ tracking, sprint/board activity | The team's primary work-tracking workspace | Default for `/haunt:seance` roadmap items and routine project work. |
| Stakeholder-facing support material: product guides, anything meant for partners to consume as a resource | A documentation-oriented workspace separate from task tracking | Not task management -- confirm this workspace is writable before writing. |
| Team-internal-only matters: team calendar, goals, performance reviews, onboarding | The team's internal-only workspace | Confirm this workspace is writable before writing. |
| Complex multi-department efforts | Workspace set up by that project's PM for the effort | Exception to the defaults above -- ask which workspace if not already specified. |

If the target workspace for a given piece of content isn't obvious from this table, ask rather than guessing.

## Workflow

1. Identify handoff type (testing plan / tech doc / project update) and audience (technical / stakeholder -- pick one).
2. Pull from the existing `.haunt/` artifact (roadmap, QA output, ADR) rather than regenerating from scratch.
3. Draft using the matching template above. No narration, lead with takeaways/action items.
4. Add a Mermaid diagram if a workflow/process/architecture is involved.
5. If the handoff targets Monday.com, route to the correct workspace category per the table, run whatever pre-write allowlist check the user's Monday.com tooling defines, and confirm before writing.

## Related

- Whatever local Monday.com API skill/config the user maintains -- auth, mutation mechanics, allowlist mechanism (org- and user-specific, lives outside this repo)
- `gco-requirements-development` -- requirements this skill communicates about
- `gco-seance-orchestration` -- roadmap/task state this skill reads from
- `gco-team-protocol` -- SendMessage conventions when a comms handoff is itself a teammate deliverable
