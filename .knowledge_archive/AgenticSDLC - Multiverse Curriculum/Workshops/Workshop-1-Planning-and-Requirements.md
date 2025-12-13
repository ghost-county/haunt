# Workshop 1: Planning and Requirements

> *From brain dump to phased roadmap in 60 minutes.*

---

## Overview

| | |
|---|---|
| **Duration** | 60 minutes |
| **Format** | Guided exercise with persona prompts |
| **Output** | Numbered requirements + phased roadmap |
| **Prerequisites** | A project idea (any stage of clarity) |

---

## Learning Objectives

By the end of this workshop, you will:

- Generate comprehensive feature lists through structured brain dumps
- Transform unstructured ideas into numbered requirements
- Evaluate features through business value analysis
- Create phased implementation roadmaps suitable for autonomous agents

---

## Why This Matters

Most autonomous agent failures happen before any code is written. They happen because:

- Requirements were vague ("make it good")
- Dependencies weren't mapped
- Phases weren't planned
- Value wasn't understood

An agent working from a clear roadmap with numbered requirements will outperform a human working from a napkin sketch. But an agent working from a napkin sketch will produce expensive garbage.

**Time invested here saves 10x in debugging later.**

---

## The Four-Step Process

### Step 1: The Brain Dump (15 minutes)

This is the fun part. No filtering. No judgment. Just excitement.

#### What to Include

- Features you'd love to have
- Things that would be "cool"
- User requests you've heard
- Technical challenges that interest you
- Competitive features you've seen elsewhere
- Wild ideas that might not work
- Small quality-of-life improvements
- Infrastructure you know you'll need

#### The Prompt

```
I'm going to brain dump everything I want in my project. Don't organize it yet,
just help me get it all out. Ask me follow-up questions to pull out more ideas.
I want to capture EVERYTHING, even stuff that's probably out of scope.

Here's my project: [describe your project]

Let me start dumping...
```

#### Tips

- Use voice input - it's faster and more natural
- Don't stop to evaluate ideas
- Quantity over quality at this stage
- Include contradictory ideas (you'll resolve later)
- Mention feelings ("I hate when apps do X" = requirement)

---

### Step 2: Requirements Engine (15 minutes)

Now we structure the chaos. The Requirements Engine persona transforms your brain dump into formal requirements.

> **See also:** [Agents/Requirements Reviewer](../Agents/) - Use this agent to validate your requirements after generation.

#### The Prompt

```
You are a Requirements Engineer with 20 years of experience turning stakeholder
conversations into actionable specifications.

Take my brain dump and transform it into:

1. **Numbered Requirements** (REQ-001, REQ-002, etc.)
   - Each requirement should be a single, testable statement
   - Use "The system shall..." format

2. **Acceptance Criteria** for each requirement
   - How do we know when it's done?
   - What are the edge cases?

3. **Dependencies** between requirements
   - Which requirements must be completed before others?
   - Which can be done in parallel?

4. **Complexity Estimate** (S/M/L/XL)
   - S = Less than a day
   - M = 1-3 days
   - L = 1-2 weeks
   - XL = Needs to be broken down further

Here's my brain dump:
[paste your brain dump]
```

#### What Good Requirements Look Like

**Bad:**
- "User authentication"
- "Make it fast"
- "Good UI"

**Good:**
- REQ-001: The system shall authenticate users via email/password with bcrypt hashing
- REQ-002: The system shall respond to API requests within 200ms for 95th percentile
- REQ-003: The system shall display loading states for any operation exceeding 100ms

---

### Step 3: Business Value Analyst (15 minutes)

Even side projects have value. Understanding that value helps prioritize.

> **See also:** [Agents/Value Chain Expert](../Agents/) - Advanced strategic analysis using Porter's Value Chain, RICE scoring, and Business Model Canvas.

#### The Prompt

```
You are a Business Value Analyst. Your job is to understand the VALUE delivered
by each feature, not just the technical implementation.

For each requirement, analyze:

1. **Who Benefits**
   - Primary beneficiary
   - Secondary beneficiaries
   - Who might be harmed or inconvenienced?

2. **Problem Solved**
   - What pain point does this address?
   - How severe is that pain currently?
   - What's the current workaround?

3. **Value Priority** (Critical / High / Medium / Low)
   - Critical = Product doesn't work without it
   - High = Significant competitive advantage or user value
   - Medium = Nice to have, improves experience
   - Low = Polish, could ship without it

4. **Cost of Not Building**
   - What happens if we never build this?
   - Can users work around it?
   - Will it block other valuable features?

Requirements to analyze:
[paste your numbered requirements]
```

#### Why This Matters for Agents

When you have 50 requirements and limited time, agents need to know what to work on first. Value analysis creates that priority stack.

It also catches features that sound cool but deliver no value - before you spend agent-hours building them.

---

### Step 4: Phased Roadmap (15 minutes)

Group requirements into phases that deliver working software at each milestone.

> **See also:** [Agents/Project Manager](../Agents/Project-Manager.md) - Use this agent to maintain your roadmap throughout development and coordinate agent work.

#### The Prompt

```
You are a Technical Program Manager creating a phased roadmap for autonomous
AI agents to execute.

Given these prioritized requirements, create a phased implementation plan:

**Phase Criteria:**
- Each phase must deliver WORKING software (not half-built features)
- Each phase should be 1-2 weeks of agent work
- Dependencies must be respected (earlier phases enable later ones)
- Higher value items should generally come earlier
- Each phase needs a clear "demo sentence" (what can you show?)

**Output Format:**

## Phase 1: [Name] (Week 1)
**Demo:** "Users can [specific capability]"
**Requirements:** REQ-001, REQ-003, REQ-007
**Success Criteria:** [How do we know phase is complete]

## Phase 2: [Name] (Week 2-3)
...

**Additional Output:**
- Identify any requirements that should be CUT (low value, high complexity)
- Flag any requirements that need human decision before agents can proceed
- Note any requirements that are underspecified

Requirements with value analysis:
[paste your requirements with value analysis]
```

---

### Step 5: Parallelization Analysis (15 minutes)

This is where planning meets execution. You need to identify what can run in parallel and design the interfaces that let agents work independently.

#### The Dependency Graph

Every requirement has dependencies. Map them:

```
REQ-001: Database schema
    ↓
REQ-002: User model ←─────────────┐
    ↓                             │
REQ-003: Auth endpoints           │
    ↓                             │
REQ-004: Login UI ────────────────┤
                                  │
REQ-005: Product model ←──────────┘
    ↓
REQ-006: Product API
    ↓
REQ-007: Product listing UI
```

#### The Prompt: Dependency Analyzer

```
You are a Dependency Analyzer. Given these requirements, create:

1. **Dependency Graph**
   - Which requirements block which others?
   - What's the critical path (longest chain)?
   - What can be done in parallel?

2. **Parallelization Groups**
   - Group requirements that can be worked on simultaneously
   - Identify the interfaces between groups
   - Flag any hidden dependencies

3. **Work Streams**
   - Backend stream: Which requirements?
   - Frontend stream: Which requirements?
   - Infrastructure stream: Which requirements?
   - What handoffs happen between streams?

Requirements:
[paste your requirements]
```

#### Identifying Parallel Tracks

Look for requirements that:

- Don't share files
- Don't share database tables
- Have clear interface boundaries
- Can be tested independently

**Parallel:**

```
Track A: REQ-002, REQ-003 (User/Auth backend)
Track B: REQ-005, REQ-006 (Product backend)
Track C: REQ-010, REQ-011 (Infrastructure/CI)

These can ALL run simultaneously - different files, different tables.
```

**Sequential:**

```
REQ-003 (Auth API) → REQ-004 (Login UI)

The UI needs the API to exist. Sequential within the track.
```

#### Designing Interfaces Upfront

This is critical. If you define the interfaces before agents start working, they can build against contracts instead of waiting for implementations.

#### The Interface Contract Prompt

```
You are an API Architect. Before any implementation begins, define the contracts
between components:

For each interaction between frontend and backend:
1. Endpoint path and method
2. Request payload schema (with examples)
3. Response payload schema (with examples)
4. Error response format
5. Authentication requirements

For each interaction between services:
1. Function/method signatures
2. Input/output types
3. Error handling approach

Output as OpenAPI spec or TypeScript interfaces.

Requirements that need interfaces:
[paste requirements with their dependencies]
```

#### Example Interface Contract

```typescript
// Defined BEFORE either agent starts working
// Both backend and frontend agents receive this

interface AuthAPI {
  // POST /api/v1/auth/login
  login(credentials: {
    email: string;
    password: string;
  }): Promise<{
    token: string;
    user: {
      id: string;
      email: string;
      name: string;
    };
    expiresAt: string;
  }>;

  // POST /api/v1/auth/logout
  logout(token: string): Promise<{ success: boolean }>;

  // GET /api/v1/auth/me
  getCurrentUser(token: string): Promise<User | null>;
}

// Error format (all endpoints)
interface APIError {
  code: string;
  message: string;
  details?: Record<string, string>;
}
```

Now:
- Roy (backend) can implement POST /api/v1/auth/login
- Jen (frontend) can build the login form against this contract
- They work in parallel, merge later, it works

#### Creating Work Items for the Queue

Each requirement becomes one or more work items in NATS:

```python
# transform_roadmap_to_work_items.py

def create_work_items(requirements: list, interfaces: dict) -> list:
    work_items = []

    for req in requirements:
        # Determine which agent handles this
        agent = assign_agent(req)

        # Include interface contracts this requirement implements
        relevant_interfaces = get_interfaces_for_requirement(req, interfaces)

        work_item = {
            'id': f"WORK-{req['id']}",
            'requirement': req['id'],
            'statement': req['statement'],
            'acceptance_criteria': req['acceptance_criteria'],
            'dependencies': req['dependencies'],
            'interfaces': relevant_interfaces,  # The contracts to implement
            'agent': agent,
            'priority': calculate_priority(req),
            'files_likely_touched': estimate_files(req),
        }
        work_items.append(work_item)

    return work_items
```

#### Publishing to NATS Streams

```python
# publish_work_items.py
import nats
import json

async def publish_roadmap(work_items: list):
    nc = await nats.connect()
    js = nc.jetstream()

    for item in work_items:
        # Route to appropriate stream based on agent
        if item['agent'] == 'backend':
            subject = f"work.requirements.backend.{item['id']}"
        elif item['agent'] == 'frontend':
            subject = f"work.requirements.frontend.{item['id']}"
        else:
            subject = f"work.requirements.infra.{item['id']}"

        await js.publish(subject, json.dumps(item).encode())
        print(f"Published {item['id']} to {subject}")

    await nc.close()
```

#### The Parallelization Decision Matrix

| Situation | Strategy |
|-----------|----------|
| 5 features, no shared files | 5 agents in parallel |
| 5 features, all touch user.py | 1 agent, sequential |
| 3 backend + 2 frontend, clear API | 2 tracks in parallel |
| Feature needs API that doesn't exist | Define interface → parallel |
| Unclear dependencies | Ask Claude to analyze → then decide |

#### What Goes in the Roadmap Documentation

Your roadmap document should include:

1. **Requirements** (numbered, with acceptance criteria)
2. **Dependency graph** (what blocks what)
3. **Interface contracts** (API specs, type definitions)
4. **Parallelization plan** (which tracks run simultaneously)
5. **Phase boundaries** (what must be done before next phase)

This document goes into your repo. Agents reference it. When Roy needs to know what API Jen is expecting, he checks the interface contract in the roadmap.

---

## Exercise 1.1: Full Requirements Workshop

**Time:** 60 minutes
**Output:** Complete roadmap with parallelization plan, ready for NATS queues

### Part A: Brain Dump (10 min)

Pick a project. Can be:
- Something you've been meaning to build
- A feature for an existing project
- A tool that would make your life easier
- A clone of something you like with your own twist

Brain dump everything. Use voice. Don't filter.

### Part B: Requirements Engine (10 min)

1. Run your brain dump through the Requirements Engine prompt.
2. Review the output:
   - Do the requirement numbers make sense?
   - Are there obvious gaps?
   - Are any requirements actually multiple requirements?

### Part C: Value Analysis (5 min)

1. Run requirements through Business Value Analyst.
2. Look for surprises:
   - Features you thought were critical that are actually low value
   - Simple features that deliver outsized value
   - Things you can cut without losing much

### Part D: Phased Roadmap (10 min)

1. Create your phased plan.
2. Validate:
   - Does each phase deliver something demo-able?
   - Are dependencies respected?
   - Is Phase 1 achievable in a week?

### Part E: Parallelization Analysis (15 min)

This is the key step for agent execution.

1. Run through the Dependency Analyzer prompt
2. Identify parallel tracks (backend, frontend, infra)
3. Find the interfaces between tracks
4. Use the API Architect prompt to define contracts

Output should include:
- Dependency graph showing what blocks what
- At least 2 parallel tracks identified
- Interface contracts for cross-track dependencies

### Part F: Create Work Items (5 min)

Transform your requirements into queue-ready work items:

```
For each requirement, create:
- Work item ID
- Assigned agent (backend/frontend/infra)
- Interface contracts it implements or depends on
- Files it will likely touch
- Priority based on dependency order
```

### Part G: Review (5 min)

Ask Claude to critique the roadmap:

```
Review this roadmap for an autonomous AI agent team.
Flag any issues that would cause agents to:
- Get stuck waiting for unclear decisions
- Build something that can't be tested
- Create merge conflicts with parallel work
- Miss critical dependencies
- Work against interfaces that aren't defined
```

---

## Common Mistakes

### Mistake 1: Skipping Brain Dump

"I already know what I want to build."

No, you know the summary. The brain dump surfaces the details that become requirements.

### Mistake 2: Vague Requirements

"REQ-005: Good error handling"

Good error handling WHERE? For WHAT errors? Shown HOW? An agent will interpret this however it wants.

### Mistake 3: No Acceptance Criteria

Requirements without acceptance criteria can't be tested. Untested requirements can't be verified. Agents will mark them "done" with no way to check.

### Mistake 4: Ignoring Dependencies

If REQ-007 depends on REQ-003, and an agent tries to build REQ-007 first, you'll get code that compiles but doesn't work.

### Mistake 5: Front-Loading Complexity

Putting all the hard stuff in Phase 1 means you won't have working software for weeks. Put a simple working version in Phase 1, then enhance.

---

## Templates

### Requirement Template

```markdown
### REQ-[NUMBER]: [Short Name]

**Statement:** The system shall [specific, testable behavior]

**Acceptance Criteria:**
- [ ] [Specific condition that must be true]
- [ ] [Another condition]
- [ ] [Edge case handled]

**Dependencies:** REQ-XXX, REQ-YYY

**Complexity:** [S/M/L/XL]

**Value:** [Critical/High/Medium/Low]

**Notes:** [Any clarifications or decisions needed]
```

### Phase Template

```markdown
## Phase [N]: [Name]

**Duration:** [Estimated time]

**Demo Sentence:** Users can [specific capability]

**Requirements Included:**
- REQ-XXX: [name]
- REQ-YYY: [name]

**Success Criteria:**
- [ ] [Measurable outcome]
- [ ] [Another outcome]
- [ ] All tests passing

**Risks/Blockers:**
- [Anything that might slow this down]

**Handoff to Phase [N+1]:**
- [What must be true for next phase to start]
```

---

## What You'll Have After This Workshop

1. **Brain Dump Document** - Raw ideas, unfiltered
2. **Requirements Spec** - Numbered, with acceptance criteria
3. **Value Analysis** - Priority and justification for each requirement
4. **Phased Roadmap** - Ready for autonomous agent execution

This becomes the source of truth for your agent team. Every agent references these documents. Every ticket traces back to a requirement number.

---

## Maintaining Your Roadmap: The Project Manager Agent

> **Critical practice:** Now that you have a roadmap, you need discipline to stick to it.

The biggest threat to your roadmap isn't bad planning - it's "one more thing."

### Never "One More Thing"

When you're coding and get a brilliant idea for a new feature, don't implement it immediately. Add it to the roadmap.

**The rule:**

1. Idea arrives → Capture it in the roadmap
2. Don't execute → Stay focused on current work
3. Review later → In your next planning session

### Use a Project Manager Agent

Set up a PM agent whose job is to:

- Capture new ideas as requirements
- Evaluate them for priority
- Update the roadmap
- Keep you from derailing your current work

When ideas overflow, talk to the PM agent instead of your dev agent.

**Example:**

```
You: "I just thought of 5 new features!"

PM Agent: "Great! Let's capture them. Tell me about each one."

[After capturing]

PM Agent: "I've added REQ-047 through REQ-051 to the backlog.
Based on current sprint goals, these are Phase 3 priorities.
Your current focus is REQ-023. Estimated 2 hours remaining."

You: [Returns to work on REQ-023]
```

**The three agents for roadmap discipline:**

| Agent | Role |
|-------|------|
| **Project Manager Agent** | Prioritizes and manages backlog |
| **Business Analyst Agent** | Evaluates ideas for value |
| **Product Manager Agent** | Shapes features and user stories |

Agent definitions: [AI Agent Personas Directory](../Agents/)

### Why In-Repo Roadmaps

Keep your roadmap in your repo, not in GitHub Issues.

**Reasons:**

- Issues are easy to poison - Comments and threads add noise
- Agents need structure - Markdown files in repo are easy to parse
- You control the signal - No external confusion
- Version controlled - Track how priorities change
- Directly interactable - Agents can read and update

GitHub Projects and PRs are great. But your backlog should live in the repo as structured markdown.

### The Roadmap as Your Anchor

Your roadmap is your external brain. When you feel the urge to "just quickly add this feature":

1. Check the roadmap - What are you supposed to be working on?
2. Add the idea to backlog - Capture it properly
3. Return to current work - Stay focused

For more on staying disciplined: [Handling A Project-Driven Manic Episode](../3.%20Handling-A-Project-Driven-Manic-Episode.md) - Essential if you tend to overflow with ideas when unblocked.

---

## Next Steps

With your roadmap complete, you're ready to:

- [Workshop 2 - Autonomous Workers](Workshop-2-Autonomous-Workers.md) - Set up your first autonomous agent
- Start Phase 1 execution

> **Key Insight:** The time you spend here is the highest-leverage time in the entire project. A clear roadmap makes everything else easier. A vague roadmap makes everything else harder.

---

**Next:** [Workshop 2 - Autonomous Workers](Workshop-2-Autonomous-Workers.md)
