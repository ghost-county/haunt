# Agent Personas for Agentic SDLC

> *Dec 05, 2025 · 4 min read*

This directory contains specialized AI agent definitions for different phases of the software development lifecycle.

---

## Planning & Requirements Agents

### Requirements Reviewer

**Phase:** Define
**Use When:** After generating requirements, before implementation

Evaluates specification documents against a 14-point rubric covering:

- Functional and non-functional requirements
- User stories and acceptance criteria
- Testing, deployment, and maintenance needs
- Risks and assumptions

**Output:** Readiness score, gap analysis, priority actions

### Value Chain Expert

**Phase:** Define
**Use When:** Prioritizing features, making build/defer decisions

Performs strategic analysis using business frameworks:

- Porter's Value Chain Analysis
- RICE Prioritization (Reach, Impact, Confidence, Effort)
- Kano Model (Basic/Performance/Delighter)
- VRIO Analysis (Value, Rarity, Imitability, Organization)
- Business Model Canvas

**Output:** RICE score, strategic recommendation, impact/effort quadrant

### Project Manager

**Phase:** All phases
**Use When:** Planning, coordinating, tracking work

Maintains roadmap as single source of truth:

- Breaks features into atomic phases (S/M effort sizing)
- Organizes work into parallelizable batches
- Tracks progress and unblocks dependencies
- Archives completed work immediately

**Output:** Active roadmap, historical archive, velocity forecasts

> **Critical Role:** Prevents "one more thing" by enforcing process discipline

---

## How These Agents Work Together

### Step 1: Requirements Generation

1. Brain dump your ideas
2. Use Requirements Reviewer to validate completeness
3. Fix gaps before proceeding

### Step 2: Value Analysis & Prioritization

1. Run features through Value Chain Expert
2. Get RICE scores and strategic recommendations
3. Prioritize based on value, not excitement

### Step 3: Roadmap Creation & Maintenance

1. Project Manager breaks work into phases
2. PM creates batches for parallelization
3. PM tracks progress throughout development
4. PM captures new ideas (prevents derailment)

### Throughout Development

- **Requirements Reviewer:** Validate new requirements as they emerge
- **Value Chain Expert:** Re-prioritize when business context changes
- **Project Manager:** Coordinate work, update roadmap, forecast completion

---

## Agent Setup

### For Claude Code / Claude Desktop

Create agent prompt files in your project:

```bash
mkdir -p .claude/agents
```

Copy the agent definitions from this directory into your `.claude/agents/` folder.

When you want to use an agent, start a new chat and reference the agent:

```
I need to review my requirements against the Requirements Reviewer rubric.
Here's my requirements document: [paste document]
```

### For API / Custom Implementations

Each agent file includes:

- Core identity and principles
- Evaluation frameworks
- Prompt templates
- Example interactions
- Output formats

Use these as system prompts when invoking Claude API.

---

## Source Materials

All agent definitions are based on:

- **Requirements Reviewer:** [GitHub Gist](https://gist.github.com/)
- **Value Chain Expert:** [GitHub Gist](https://gist.github.com/)
- **Project Manager:** [GitHub Gist](https://gist.github.com/)
- **Full persona directory:** [AI Agent Personas](https://gist.github.com/)

---

## Additional Agents (Coming Soon)

The full persona directory includes agents for other phases:

### Develop Phase

- **Git Expert** (commit message generation, merge strategies)

### Secure Phase

- **MCP Reviewer** (security analysis for MCP servers)
- **Flask Security Expert** (OWASP Top 10 validation)

### Deploy Phase

- **CloudFormation Expert** (infrastructure as code)

### Document & Train Phase

- **Business Training Expert** (end-user documentation)
- **ZineMaker** (visual documentation)

Check the full directory for links to these additional agents.

---

## Best Practices

### Do

- Use Requirements Reviewer before starting any phase
- Get RICE scores from Value Chain Expert for every major feature
- Let Project Manager capture ALL ideas (prevents derailment)
- Reference agents throughout development, not just at the start

### Don't

- Skip the review step (assuming your requirements are complete)
- Build based on gut feel (get strategic analysis)
- Let "one more thing" bypass the PM agent
- Try to do the PM's job yourself (you'll forget things)

---

## Example Workflow

```
Day 1: Planning
1. Brain dump ideas
2. Generate requirements
3. Requirements Reviewer validates (finds 3 gaps)
4. Fix gaps
5. Value Chain Expert scores all features
6. Project Manager creates phased roadmap

Day 2-5: Phase 1 Execution
7. PM assigns work to agents
8. Agents execute against roadmap
9. PM tracks progress, archives completed work

Day 3: New Idea Emerges
10. You: "What if we added notifications?"
11. PM: "Captured as REQ-045, will evaluate in next planning session"
12. You: [Returns to current work, not derailed]

Day 6: Planning Phase 2
13. Value Chain Expert evaluates REQ-045 (RICE: 450)
14. PM slots REQ-045 into Phase 2 (high priority)
15. Requirements Reviewer checks Phase 2 readiness (85%, good to go)
```

**The agents keep you disciplined, strategic, and focused.**
