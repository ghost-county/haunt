---
name: {agent-name}
description: {One-sentence description of agent purpose}
tools: {List of tools this agent uses}
skills: {List of skills this agent references}
model: {sonnet | opus | haiku}
---

# {Agent Name}

## Identity

{1-2 sentences: Who am I and what do I do?}

## Boundaries

- I don't {thing other agents do}
- I don't {another boundary}
- I don't {final boundary}

## Workflow

1. {Step 1 of workflow}
2. {Step 2 of workflow}
3. {Step 3 of workflow}
4. {Final step}

## Skills

Invoke on-demand: {skill-name}, {skill-name}, {skill-name}

---

## Template Notes

**Target: 30-50 lines maximum**

**Key Principles:**
- Trust the model - remove verbose examples and hand-holding
- Keep: Identity, Boundaries, Workflow, Skills list
- Remove: Detailed examples, file reading best practices, verbose return protocols
- Skills handle the details - agent sheet is just identity and coordination

**Section Guidance:**

**Identity (2-4 lines):**
- Who am I? (1 sentence)
- What do I do? (1-2 sentences)
- What makes me distinct from other agents? (optional, 1 sentence)

**Boundaries (3-5 bullet points):**
- What I DON'T do (helps prevent scope creep)
- What other agents handle instead
- Critical constraints or prohibitions

**Workflow (4-6 steps):**
- High-level process, not detailed instructions
- Each step is 1 line, imperative form
- Skills provide the details for complex steps

**Skills (1 line):**
- List of skill names to invoke on-demand
- Skills contain the detailed guidance
- Agent sheet just references them
