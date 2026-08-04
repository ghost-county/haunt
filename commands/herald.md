---
description: "Generate audience-tailored communication and documentation handoffs -- testing plans, technical documentation, and project updates -- for technical or stakeholder audiences, from current project state."
---

# Herald (Communication & Documentation Handoff)

Turn current project state into a concise, audience-tailored handoff artifact.

## Before Starting

Read the `gco-comms` skill for the full standards (audience model, handoff templates, diagramming, external workspace routing). This command is a thin entry point over that skill -- it does not duplicate the standards here.

## Usage

```bash
/herald testing-plan --audience=technical
/herald testing-plan --audience=stakeholder
/herald tech-doc
/herald project-update --audience=stakeholder
/herald project-update --audience=stakeholder --push=monday
```

## Arguments: $ARGUMENTS

### Step 1: Determine Handoff Type and Audience

- **Type**: `testing-plan` | `tech-doc` | `project-update` -- infer from $ARGUMENTS if not stated explicitly; ask if ambiguous.
- **Audience**: `technical` | `stakeholder` -- ask if not specified and the handoff type doesn't make it obvious. Never blend both into one artifact (see `gco-comms`).

### Step 2: Pull Source Material

- `testing-plan` → most recent `/haunt:qa` output, or derive from `git diff main..HEAD` if none exists
- `tech-doc` → code changes, existing ADRs, relevant roadmap items for the current branch/project
- `project-update` → `.haunt/plans/roadmap.md`, current `TaskList` state, recent entries in `.haunt/completed/`

### Step 3: Draft

Apply the matching template from the `gco-comms` skill for the chosen type and audience. No narration -- takeaways and action items only. Strip every internal-tooling reference per that skill's rule before the artifact is considered done.

### Step 4: Diagram (if applicable)

If the handoff documents a workflow, process, or architecture, include a Mermaid diagram inline per the skill's diagramming standard.

### Step 5: Push (optional -- `--push=monday`)

If requested:
1. Route to the correct workspace **category** per the `gco-comms` routing table.
2. Run whatever pre-write allowlist check the user's own Monday.com tooling defines.
3. Confirm the specific board/item/doc with the user before writing.
4. Write, then report the resulting link/id.

Without `--push`, the artifact is drafted only -- say so explicitly, don't imply it was published.

### Step 6: Report

Output the artifact itself. No meta-commentary about how it was generated, and no references to this command, haunt, or any internal working materials inside the artifact's content.

## Error Handling

| Condition | Action |
|---|---|
| No handoff type inferable and none given | Ask which of testing-plan / tech-doc / project-update |
| No audience given and type doesn't imply one | Ask technical or stakeholder |
| `--push=monday` with no workspace mapping for the content category | Stop and ask which workspace to target |
| `--push=monday` targets a workspace not on the user's write allowlist | Stop, report the workspace, ask to confirm/add or skip |
