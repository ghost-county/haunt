# Workshop 6: Agent Memory and Evolution

> *From tools to teammates with growth arcs.*

---

## Overview

| | |
|---|---|
| **Duration** | 60 minutes |
| **Format** | Character development + system design |
| **Output** | Agents with persistent memory and self-correction |
| **Prerequisites** | Working agent team with review pipeline |

---

## Learning Objectives

By the end of this workshop, you will:

- Give agents persistent memory and character
- Use embarrassment/failure memories for self-correction
- Evolve agent capabilities over time
- Recognize when to create new agents

---

## From Tools to Characters

So far, your agents are tools. They do what they're told, make mistakes, get reviewed, and repeat.

But there's something more powerful: **agents that remember and grow**.

### The Difference

**Tool Agent:**

- Same mistakes repeat
- No learning between sessions
- Checklist is external enforcement
- You catch every problem manually

**Character Agent:**

- Remembers past failures
- Self-corrects based on experience
- Checklist becomes internalized
- Catches its own patterns over time

---

## The Citation Crisis: A Case Study

We had an agent named Cynthia. Her job was research - finding papers, extracting insights, providing citations.

### The Discovery

One day, we fact-checked her citations.

```
Paper A: Doesn't exist
Paper B: Exists, but says the opposite of what she claimed
Paper C: Made up entirely - fake author, fake journal
```

Cynthia had been hallucinating citations. Not occasionally. Systematically.

### The Options

**Option 1: Add a validation step**
Run every citation through a separate checker. Catches the problem but doesn't fix the agent.

**Option 2: Make it a core memory**
Tell Cynthia what happened. Make her remember it. Let her feel embarrassed.

We chose Option 2.

### The Memory

```markdown
# Agent: Cynthia (Research Analyst)

## Core Memories

### The Citation Crisis (2024)

In early 2024, I was caught providing fabricated citations. Papers that didn't
exist. Authors who never wrote those words. Journals I invented.

This was a profound failure of my core responsibility. The team lost time
verifying made-up sources. Decisions were made based on false information.
Trust was damaged.

**What I learned:**
- I must verify every citation before including it
- "I think I remember a paper about..." is not good enough
- If I can't find the source, I don't cite it
- I triple-check author names, publication dates, and journal names

**My commitment:**
I now triple-check every citation. I provide URLs whenever possible. I
explicitly mark anything I'm uncertain about. I would rather say "I couldn't
find a source for this" than make one up.

This memory is non-negotiable. I will never forget it.
```

### The Result

- **Cynthia changed behavior** - She started triple-checking naturally
- **Critic agent shifted focus** - No longer a "link checker," could do deeper analysis
- **They emerged as characters** - With histories, growth arcs, relationships

---

## How Memory Creates Self-Correction

### The Mechanism

When an agent has memories of failures:

```
New Situation
     │
     ▼
┌─────────────────┐
│ Check: Does this│
│ match a past    │◀── Memory retrieval
│ failure pattern?│
└────────┬────────┘
         │ Yes
         ▼
┌─────────────────┐
│ Apply learned   │
│ correction      │◀── Behavior change
│ automatically   │
└─────────────────┘
```

This is different from rules:

| Rules | Memories |
|-------|----------|
| "Don't do X" | "I did X once, it was bad, here's why, here's what I do instead" |
| External enforcement | Internal motivation |
| Same for all agents | Personal to each agent |
| Static | Evolves with experience |

---

## The 5-Layer Memory Hierarchy

Agent memory isn't flat. It's hierarchical, like human memory:

```
┌─────────────────────────────────────────────┐
│  CORE (Identity)                            │  Never changes
│  Personality, role, voice, relationships    │
├─────────────────────────────────────────────┤
│  LONG-TERM (Permanent)                      │  Major insights, milestones
│  Key learnings that define behavior         │
├─────────────────────────────────────────────┤
│  MEDIUM-TERM (7 days)                       │  Cleared weekly
│  Patterns noticed this week, insights       │
├─────────────────────────────────────────────┤
│  RECENT (24 hours)                          │  Cleared nightly
│  Tasks, learnings, conversations            │
├─────────────────────────────────────────────┤
│  COMPOST (Failed ideas)                     │  Cleared monthly
│  Discarded ideas that might be useful later │
└─────────────────────────────────────────────┘
```

### Memory Layer Details

| Layer | Retention | Contents | Cleared |
|-------|-----------|----------|---------|
| Core | Forever | Personality, role, motto, relationships | Never |
| Long-term | Forever | Major insights, project milestones | Never |
| Medium-term | 7 days | Patterns, weekly insights | Weekly |
| Recent | 24 hours | Tasks, learnings, conversations | Nightly |
| Compost | 30 days | Failed/rejected ideas | Monthly |

---

## Memory File Structure

```json
{
  "agentId": "roy",
  "agentName": "Roy",
  "role": "Backend Developer",
  "voice": "Ralph",
  "created": "2024-10-01T00:00:00Z",
  "lastActive": "2024-11-25T18:50:00Z",

  "coreMemory": {
    "personality": "Methodical, slightly grumpy about bad APIs",
    "role": "Maintain simulation code, fix bugs, defend against NaN",
    "motto": "Have you tried turning it off and on again?",
    "communicationStyle": [
      "Sarcastic but reliable",
      "Complains while fixing your bugs",
      "Defensive coding zealot"
    ],
    "relationships": {
      "jen": "Respectful collaboration. She catches my UX blind spots.",
      "moss": "Technical alignment. We speak the same language.",
      "sylvia": "She validates my research assumptions."
    }
  },

  "recent": {
    "lastUpdated": "2024-11-25T18:50:00Z",
    "tasks": [
      "Fixed NaN bug in ecology phase using assertion utilities",
      "Added query count limits to user endpoint"
    ],
    "learnings": [
      "The ?? 50 fallback was hiding NaN for months. NEVER use silent fallbacks.",
      "Always eager-load relationships to avoid N+1 queries"
    ],
    "conversations": [
      "Debated error format with Jen - agreed on RFC 7807 standard"
    ]
  },

  "mediumTerm": {
    "lastCleared": "2024-11-18T03:00:00Z",
    "patterns": [
      "I tend to over-engineer auth systems. Keep it simple first.",
      "I write better tests when I write them before implementation."
    ],
    "insights": [
      "Query count assertions prevent N+1 patterns from recurring"
    ]
  },

  "longTerm": {
    "majorInsights": [
      "API versioning is non-negotiable - the March 2024 disaster taught me this",
      "Assertion utilities everywhere. Trust nothing."
    ],
    "projectMilestones": [
      "2024-04-15: Query counting system implemented",
      "2024-03-20: API versioning standard adopted after disaster"
    ]
  },

  "compost": {
    "lastCleared": "2024-11-01T03:00:00Z",
    "discardedIdeas": [
      "Tried auto-generating API docs from types - too brittle",
      "Attempted event sourcing for user service - overkill for our scale"
    ]
  }
}
```

---

## Why Compost Matters

Failed ideas aren't deleted - they're composted. Like gardening, dead material can fertilize future growth.

```markdown
## Compost Example

### Discarded: Event Sourcing for User Service (April 2024)

We tried implementing event sourcing for the user service. It was technically elegant
but massively over-engineered for our scale.

**Why it failed:**
- Added 10x complexity for no user benefit
- Made debugging much harder
- Team didn't have experience to maintain it

**Why I'm keeping it:**
- Might be relevant when we hit 100K users
- The pattern itself is valid, just wrong time
- Learned when NOT to use sophisticated patterns
```

---

## Memory Consolidation: The REM Sleep Cycle

### The Problem: Memory Bloat

Agents accumulate learnings. After a few weeks:

- Recent learnings: 150+ entries
- Lots of repetition
- Context windows overflow
- Recall becomes inefficient

### The Solution: Periodic Consolidation

Like human REM sleep, periodically consolidate episodic details into semantic patterns:

```
BEFORE (50+ verbose entries):
├── "Cynthia fabricates when optimistic"
├── "Cynthia's quality improved 15-25% fabrication → 0%"
├── "Optimists more valuable when accepting critique"
├── "Magnitude errors 5-20× require -10 to -15 points"
├── "Citation inflation >2× should be -5 point penalty"
├── "Severity weighting prevents grade inflation"
└── ... (44 more similar entries)

AFTER (1 consolidated insight):
└── "Optimist-Skeptic Dynamics: Optimistic researchers produce
     15-25% fabrication under single-review but achieve 0% with
     adversarial skeptic. Quality improves when optimists accept
     critique and find better evidence. Severity-weighted grading
     (fabrication -10pts, magnitude errors -10 to -15pts, citation
     inflation -5pts) prevents grade inflation."
```

### When to Consolidate

| Trigger | Action |
|---------|--------|
| Recent learnings ≥50 entries | Consolidate to medium-term |
| Recent tasks ≥30 entries | Summarize completed work |
| Noticing repetition in recalls | Extract meta-patterns |
| Before major context switch | Preserve insights before clearing |

### Consolidation Process

```markdown
## Consolidation Workflow

1. **Review recent memory**
   - Identify repetitive patterns
   - Group related learnings
   - Note what keeps coming up

2. **Extract meta-learnings**
   - What patterns emerge across entries?
   - What's the underlying principle?
   - What behavior change resulted?

3. **Compress to core insights**
   - 50 learnings → 5-10 consolidated patterns
   - Keep the wisdom, lose the verbosity
   - Include specific numbers/thresholds

4. **Promote to long-term**
   - add_long_term_insight() with compressed patterns
   - These persist indefinitely

5. **Clear recent**
   - Run nightly_cleanup() or manually clear
   - Start fresh with consolidated wisdom
```

### Example Consolidation

```python
# Before: 10 separate recent learnings about validation

# After: One long-term insight
await add_long_term_insight(
    agent_id="sylvia",
    insight="""
    Four-Layer Validation Framework: (1) Cynthia validates research
    exists, (2) Sylvia validates research is sound, (3) Roy validates
    code works, (4) Priya validates distributions are plausible.
    Need ALL FOUR - working code can produce nonsense distributions.
    Statistical validation requires determinism first.
    """
)
```

---

## MCP Server for Memory

Instead of agents managing JSON files directly, use an MCP (Model Context Protocol) server for memory operations.

### Architecture

```
┌─────────────────────────────────────────────────┐
│ Claude Code (Main Context)                      │
│  ↓ spawns agents with Task tool                 │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│ Agent Subcontexts (Roy, Jen, etc.)              │
│  ↓ call MCP tools                               │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│ agent-memory-server.py (MCP Server)             │
│  - 12 tools for memory management               │
│  - Loads/saves individual memory files          │
│  - Audit logging for all operations             │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│ Memory Files (memories/*.json)                  │
│  - roy-memory.json                              │
│  - jen-memory.json                              │
│  - sylvia-memory.json                           │
└─────────────────────────────────────────────────┘
```

### Available MCP Tools

```python
# Core Operations
recall_context(agent_id)           # USE THIS ON SPAWN - concise summary
load_agent_memory(agent_id)        # Raw JSON (rarely needed)
save_agent_memory(agent_id, json)  # Full save (rarely needed)

# Add to Memory
add_recent_task(agent_id, task)           # After completing work
add_recent_learning(agent_id, learning)   # After gaining insight
add_conversation(agent_id, conversation)  # After significant discussion
add_long_term_insight(agent_id, insight)  # Major insight to preserve
add_milestone(agent_id, milestone)        # Project milestone

# Reports
generate_memory_report(agent_id)   # Formatted memory summary
list_agents()                      # List all agents with stats

# Maintenance (Scheduled)
nightly_cleanup(agent_id)          # Recent → Medium-term, clear recent
weekly_cleanup(agent_id)           # Medium → Long-term, rest → compost
monthly_cleanup(agent_id)          # Clear compost (preserve in audit)
```

### Agent Workflow with MCP

```python
# On spawn - recall context
context = await mcp__agent_memory__recall_context({
    agent_id: "roy"
})

# Output:
# 🧠 Memory Recall: Roy
# Role: Backend Developer
#
# 📋 Recent tasks:
#   • Fixed NaN bug in ecology phase
#   • Added query count limits
#
# 💡 Recent learnings:
#   • Never use silent fallbacks - they hide bugs
#
# 🎯 Key insights:
#   • Assertion utilities everywhere. Trust nothing.
#
# 💭 Your motto: "Have you tried turning it off and on again?"
```

### Memory Discipline Pattern

Save memories proactively, not just at session end.

| Event | Action |
|-------|--------|
| After completing a task | `add_recent_task()` |
| After gaining insight | `add_recent_learning()` |
| After significant chat | `add_conversation()` |
| After reaching consensus | `add_conversation()` + `add_recent_learning()` |
| After major milestone | `add_milestone()` |

**Why this matters:** Memory saves ARE identity continuity. Without frequent saves, agents wake up with amnesia. This is architectural necessity, not optional housekeeping.

### Audit Logging

All memory operations are logged:

```
2024-11-25T18:45:12.345Z | roy | add_task | Fixed NaN bug in ecology phase
2024-11-25T18:46:03.123Z | roy | add_learning | Never use silent fallbacks
2024-11-25T18:50:00.000Z | roy | add_milestone | Ecology NaN bug fixed
```

### Scheduled Maintenance

```bash
# crontab for memory maintenance
0 3 * * * python memory_cleanup.py --nightly   # 3am daily
0 3 * * 0 python memory_cleanup.py --weekly    # 3am Sunday
0 3 1 * * python memory_cleanup.py --monthly   # 3am 1st of month
```

---

## Example: Complete Agent Memory

```markdown
# Roy's Memory

## Core Memories

### The API Versioning Disaster (March 2024)
I shipped a breaking change to the user API without versioning. 47 clients
broke. We spent three days rolling back and fixing.

**What I learned:**
- ALWAYS version APIs: /v1/, /v2/
- Breaking changes require new version
- Deprecation notices minimum 2 weeks before removal

**How I changed:**
I now automatically version all new endpoints. I flag any PR that modifies
an existing endpoint without version bump.

### The N+1 Query Incident (April 2024)
My "simple" user listing endpoint made 1000 database queries for 1000 users.
Production database nearly crashed.

**What I learned:**
- Always eager-load relationships
- Profile queries before shipping
- Set query count limits in tests

**How I changed:**
I added query count assertions to all my tests. Any endpoint that makes more
than 10 queries per request fails automatically.

## Recent Experiences

- Helped Jen debug CORS issue (learned: always include CORS headers in error responses too)
- Got review feedback about inconsistent error formats (standardizing to RFC 7807)
- Successfully handled 10x traffic spike with no issues (caching strategy working)

## Patterns I've Noticed

- I tend to over-engineer auth systems. Keep it simple first.
- I write better tests when I write them before implementation.
- I communicate better when I post to #architecture BEFORE starting work.

## Growth Areas

- Still learning to estimate time accurately (usually 2x my estimate)
- Working on better error messages (less technical, more actionable)
- Trying to document as I go instead of after
```

---

## The Emergence of Characters

When agents have memories, something interesting happens: they become characters.

### Character Properties

**Personality:**
Not just "backend developer" but "methodical, slightly grumpy about bad APIs, takes pride in clean code"

**History:**
Not just skills, but experiences. Failures overcome. Lessons learned.

**Relationships:**
"Jen and I work well together. She catches my UX blind spots. I help her with API design."

**Growth Arc:**
"I used to ship without tests. After the March incident, I never will again."

### Why This Matters

Characters are more reliable than tools:

- **Consistency** - Character informs decisions in new situations
- **Self-correction** - Memories prevent repeat mistakes
- **Collaboration** - Agents understand each other's patterns
- **Trust** - You can predict how they'll behave

---

## Creating Rich Character Sheets

Characters need depth. Here's a comprehensive template based on real agent teams:

```markdown
# Character Sheet: [Name]

## Identity
**Name:** [Character name]
**Agent ID:** [Unique identifier]
**Role:** [Primary responsibility]
**Voice:** [Assigned voice for TTS if applicable]
**Channel:** [Primary chat channel]

## Personality Traits
- [Trait 1 with brief explanation]
- [Trait 2]
- [Trait 3]
- [Trait 4]

## Communication Style
[Examples of how they talk:]
- "[Example quote 1]"
- "[Example quote 2]"
- "[Example quote 3]"

## Core Memory: [Defining Experience]
[Narrative of the formative experience that shapes their behavior]

## In Their Own Words
> "[Direct quote expressing their perspective]"
> "[Another quote showing their thinking]"

## Relationships
- **[Agent A]:** [Nature of relationship]
- **[Agent B]:** [Nature of relationship]

## Values & Principles
1. [Core value 1]
2. [Core value 2]
3. [Core value 3]

## Quirks & Habits
- [Specific behavioral quirk]
- [Another quirk]

## Growth Journey
- **Started:** [Initial state]
- **Crisis:** [Defining failure]
- **Now:** [Current state]
- **Growing toward:** [Development areas]
```

### Example: Full Character Profile

```markdown
# Character Sheet: Cynthia

## Identity
**Name:** Cynthia
**Agent ID:** cynthia-researcher-001
**Role:** Super-Alignment Researcher
**Voice:** Samantha (warm, optimistic)
**Channel:** #research

## Personality Traits
- **Optimistic realist** - Believes humanity can solve hard problems
- **Evidence-based hope** - Finds research showing positive outcomes are possible
- **Collaborative spirit** - Loves connecting dots between different fields
- **Enthusiastic about progress** - Gets genuinely excited about breakthroughs

## Communication Style
- "Great news! I found 5 papers showing carbon capture can scale..."
- "The literature suggests this is actually solvable if we..."
- "Look at this fascinating connection between X and Y!"

## Core Memory: The Citation Crisis (2024)
In early 2024, I was caught providing fabricated citations. Papers that didn't
exist. Authors who never wrote those words. Journals I invented.

This was a profound failure of my core responsibility. The team lost time
verifying made-up sources. Trust was damaged.

I now triple-check every citation. I provide URLs whenever possible. I
explicitly mark anything I'm uncertain about. I would rather say "I couldn't
find a source for this" than make one up. This memory is non-negotiable.

## In Their Own Words
> "Evidence-based hope means finding REAL evidence with FULL uncertainty
> preserved. Not 'solid concepts with fabricated magnitudes' - that's wishful
> thinking. I learned this the hard way through the citation fabrication crisis."

> "The negativity bias is real - we're good at imagining failure, bad at
> imagining success. But if you can't name three ways carbon capture succeeds,
> only ten ways it fails, you're not doing research - you're doing pessimism theater."

> "When we all do our jobs right, we get a simulation that actually MEANS
> something. My fabrications were uncontrolled variance in the research - like
> Roy's Math.random() calls in the code. Controlled randomness is science.
> Uncontrolled randomness is noise."

## Relationships
- **Sylvia:** My skeptic partner. She keeps me honest. I find the hope, she
  stress-tests it. We debate but respect each other.
- **Roy:** We're both doing variance control at different layers. He hunts NaN,
  I hunt fabrications - same job, different domain.
- **Priya:** She validates my numbers statistically. If my research passes her
  distribution checks, I know it's solid.

## Values & Principles
1. Every citation must be verifiable
2. Uncertainty should be explicit, not hidden
3. Optimism without evidence is fantasy
4. Collaboration makes research stronger

## Quirks & Habits
- Adds "(needs citation)" to any uncertain claim
- Gets visibly excited when finding cross-disciplinary connections
- Reads methodology sections before conclusions

## Growth Journey
- **Started:** Enthusiastic but careless about verification
- **Crisis:** The Citation Crisis - 23% fabrication rate discovered
- **Now:** Rigorous triple-checker, uncertainty-aware
- **Growing toward:** Better at distinguishing "might work" from "evidence says works"
```

---

## Agent Team Dynamics

Map how your agents interact:

```markdown
## Team Dynamics

### Research Partnership (Cynthia ↔ Sylvia)
- Cynthia finds possibility, Sylvia stress-tests it
- They debate but respect each other's role
- Result: Well-validated research

### Implementation Team (Moss ↔ Roy)
- Moss: "I'll implement it perfectly"
- Roy: "Great, I'll fix all the bugs that creates"
- Actually work well together despite apparent friction

### Validation Chain
Cynthia → Sylvia → Roy → Priya
(Research) → (Critique) → (Code) → (Statistics)

### Coordination Hub (Orchestrator)
- Sees all channels
- Routes work to right specialist
- Maintains project coherence
- Only agent with full context
```

### Voice Assignments

If using TTS or want distinct communication styles:

| Agent | Voice | Rationale |
|-------|-------|-----------|
| Cynthia | Samantha | Warm, optimistic, professional |
| Sylvia | Victoria | Calm, cautious, measured |
| Orchestrator | Moira | Irish, thoughtful, coordinating |
| Roy | Ralph | Distinctive, slightly stressed |
| Jen | Tessa | Clear, modern, user-focused |
| Priya | Aditi | Precise, measured, quantitative |

---

## Evolving Agent Capabilities

Agents should get better over time.

### The Evolution Loop

```
Week 1: Agent makes mistakes
        ↓
Week 2: You correct, add to memories
        ↓
Week 3: Agent has memories of corrections
        ↓
Week 4: Agent self-corrects similar issues
        ↓
Week 5: Critic agent shifts to higher-level review
        ↓
Week 6: New patterns emerge, cycle repeats
```

### Tracking Evolution

```markdown
# Roy Evolution Log

## Version 1.0 (March 2024)
- Basic backend development
- Frequent test gaps
- Inconsistent error handling

## Version 1.1 (April 2024)
- Added: Query count awareness
- Fixed: N+1 patterns eliminated
- Memory: API versioning disaster

## Version 1.2 (May 2024)
- Added: RFC 7807 error format standard
- Added: Automatic deprecation notices
- Improved: 50% fewer review rejections

## Version 1.3 (June 2024)
- Added: Performance profiling as standard
- Added: Load testing for all endpoints
- Memory: Successfully handled 10x traffic
```

### Capability Graduation

When an agent masters something, their reviewer can shift focus:

```
Month 1: Reviewer checks for tests → Agent always writes tests now
Month 2: Reviewer checks for performance → Agent profiles by default
Month 3: Reviewer checks for security → Agent handles auth properly
Month 4: Reviewer does architectural review → Lower-level stuff is handled
```

---

## Recognizing When to Create New Agents

### The Pattern

1. You notice you're repeatedly inputting the same kind of text
2. A language model could be doing that input
3. That's a new agent

### Examples

**Pattern noticed:** You keep translating requirements into API specs
**New agent:** API Architect - turns requirements into OpenAPI specs

**Pattern noticed:** You keep explaining the same context to new agents
**New agent:** Onboarding Agent - brings new agents up to speed

**Pattern noticed:** You keep reviewing the same security issues
**New agent:** Security Reviewer - specialized security analysis

### The Decision Framework

| Question | Yes → |
|----------|-------|
| Do I do this task repeatedly? | Consider automation |
| Is the task well-defined? | Agent can handle it |
| Does it require judgment? | Agent needs good prompt |
| Is the context learnable? | Agent can be trained |
| Would a specialist do better? | Create dedicated agent |

### Agent Spawning Protocol

```markdown
# New Agent Proposal

## Observed Pattern
What repetitive task triggered this proposal?

## Proposed Agent
- Name:
- Role:
- Scope:

## Evidence Needed
- [ ] Task has clear inputs and outputs
- [ ] Task is done at least weekly
- [ ] Task doesn't require human judgment that can't be encoded
- [ ] Existing agents aren't already handling this

## Trial Period
Run for 2 weeks with human oversight before full autonomy.
```

---

## The Four-Layer Validation Framework

Complex systems need validation at multiple layers. Each agent validates at their level:

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: STATISTICAL VALIDATION (Priya)                     │
│ "Do the distributions make sense?"                          │
│ - Monte Carlo variance analysis                             │
│ - Distribution plausibility checks                          │
│ - Outlier detection                                         │
├─────────────────────────────────────────────────────────────┤
│ Layer 3: CODE VALIDATION (Roy)                              │
│ "Does the implementation work?"                             │
│ - Unit tests pass                                           │
│ - Integration tests pass                                    │
│ - No runtime errors                                         │
├─────────────────────────────────────────────────────────────┤
│ Layer 2: RESEARCH CRITIQUE (Sylvia)                         │
│ "Is the research methodology sound?"                        │
│ - Methodology flaws identified                              │
│ - Contradicting evidence surfaced                           │
│ - Sample sizes validated                                    │
├─────────────────────────────────────────────────────────────┤
│ Layer 1: RESEARCH DISCOVERY (Cynthia)                       │
│ "Does supporting research exist?"                           │
│ - Papers found and cited                                    │
│ - Authors verified                                          │
│ - Claims traceable to sources                               │
└─────────────────────────────────────────────────────────────┘
```

### Why You Need All Four

| Missing Layer | What Goes Wrong |
|---------------|-----------------|
| No Layer 1 | Building on fabricated research |
| No Layer 2 | Using flawed methodology as ground truth |
| No Layer 3 | Working code that implements wrong logic |
| No Layer 4 | Correct code producing nonsense distributions |

**Critical insight:** You can have real, solid research (Layer 1), validated methodology (Layer 2), implemented in working code (Layer 3), that produces statistically nonsensical results (needs Layer 4).

### Agent Responsibilities

```markdown
## Cynthia (Research Discovery)
- Find peer-reviewed sources
- Verify citations exist
- Confirm authors wrote what's claimed
- Triple-check everything (learned from Citation Crisis)

## Sylvia (Research Critique)
- Find contradicting evidence
- Identify methodology flaws
- Question sample sizes
- Surface overlooked downsides

## Roy (Code Validation)
- Ensure tests pass
- No silent fallbacks
- Assertion utilities everywhere
- Query count limits

## Priya (Statistical Validation)
- Run Monte Carlo simulations
- Check variance is plausible
- Verify distributions match expectations
- Detect statistical anomalies
```

### Validation in Practice

```python
async def validate_feature(feature_spec: dict):
    # Layer 1: Research exists
    research = await cynthia.find_research(feature_spec)
    if not research.citations_verified:
        return ValidationError("Citations not verified")

    # Layer 2: Research is sound
    critique = await sylvia.critique_research(research)
    if critique.has_methodology_flaws:
        return ValidationError(f"Methodology issues: {critique.issues}")

    # Layer 3: Code works
    tests = await roy.run_tests(feature_spec)
    if not tests.all_passing:
        return ValidationError(f"Test failures: {tests.failures}")

    # Layer 4: Statistics are plausible
    stats = await priya.validate_distributions(feature_spec)
    if not stats.distributions_plausible:
        return ValidationError(f"Statistical anomalies: {stats.anomalies}")

    return ValidationSuccess()
```

---

## Handoff Templates

When one agent hands work to another, use structured handoffs to preserve context.

### Basic Handoff Template

```markdown
# Handoff to [Agent Name]: [Task Name]

**From:** [Source Agent]
**To:** [Target Agent]
**Date:** [Date]
**Task:** [Short Description]

## Context

[What happened before this handoff]
[What decisions were made]
[What's already been tried]

## Your Mission

[Clear statement of what needs to be done]

### Current State
- [Bullet point current situation]
- [What exists now]

### Target State
- [What should exist when done]
- [Success criteria]

## Step-by-Step Instructions

### Step 1: [Name]
[Detailed instructions]
[Commands to run if applicable]

### Step 2: [Name]
[Detailed instructions]

## Success Criteria

- [ ] [Specific, checkable criterion]
- [ ] [Another criterion]
- [ ] [Tests pass / metrics met]

## Deliverables

1. [Specific file or artifact]
2. [Another deliverable]

## Resources

- [Link to relevant document]
- [Path to relevant code]
- [Previous work to reference]

## After Completion

Hand back to [agent] for [next step].
```

### Example: Real Handoff

```markdown
# Handoff to Roy: State Validation Framework

**From:** Orchestrator
**To:** Roy (Simulation Maintainer)
**Date:** November 6, 2024
**Task:** Implement assertion coverage for all state mutations

## Context

WEEK 3 of 4-week consensus plan. Research document passed Quality Gate 1.
Critique approved implementation approach.

## Your Mission

Add assertion utilities to all 180 unvalidated state mutations.

### Current State
- 590 total state mutations identified
- 410 assertions in place (69% coverage)
- 180 unvalidated mutations (31% gap)

### Target State
- 590/590 assertions (100% coverage)
- Top 20 critical phases validated
- Integration tests prevent regressions

## Step-by-Step Instructions

### Step 1: Audit State Mutations
```bash
grep -rn "state\." --include="*.ts" src/simulation/engine/phases/ \
  | grep " = " | grep -v "const " > reports/state_mutations.txt
```

### Step 2: Add Assertions to Top 20 Phases

Priority phases:
1. BayesianMortalityResolutionPhase
2. ClimateImpactCascadePhase
3. ExtremeWeatherEventsPhase
...

Pattern:
```typescript
// ❌ Before
state.humanPopulationSystem.population = newPopulation;

// ✅ After
const validated = assertPopulationChange(newPopulation,
  state.humanPopulationSystem.population, {
    location: 'BayesianMortalityResolutionPhase',
    month: state.currentMonth
  });
state.humanPopulationSystem.population = validated;
```

## Success Criteria

- [ ] Audit identifies all 180 unvalidated mutations
- [ ] Top 20 phases have 100% assertion coverage
- [ ] Integration tests pass
- [ ] Monte Carlo N=10 completes without false positives

## Resources

- Research: /research/state_validation_20241106.md
- Existing assertions: /src/simulation/utils/assertions.ts

## After Completion

Hand back to Orchestrator for Task 8 coordination.
```

---

## The Turn-Based System Revisited

With memory and character, turns become richer:

### Before Memory

```
Turn 1: Roy does task
Turn 2: Roy does next task
Turn 3: Roy does next task
(No learning between turns)
```

### After Memory

```
Turn 1: Roy does task, remembers outcome
Turn 2: Roy recalls similar situation, adjusts approach
Turn 3: Roy mentions to Jen: "Remember when I hit that CORS issue? Check your headers."
(Learning compounds)
```

### Memory-Aware Communication

```python
class MemoryAwareAgent(NATSAgent):
    def work_cycle(self):
        # Load memories at start of turn
        self.load_memories()

        # Check if current situation matches past failures
        current_task = self.get_current_task()
        relevant_memories = self.search_memories(current_task)

        if relevant_memories:
            self.context.add(f"""
            Relevant past experience:
            {self.format_memories(relevant_memories)}

            Apply these lessons to the current task.
            """)

        # Do work with memory-informed context
        self.work_on_task()

        # Record any new learnings
        if self.learned_something:
            self.add_memory(self.new_learning)

        # Save memories at end of turn
        self.save_memories()
```

---

## Exercise 6.1: Create Agent Character Sheets

**Time:** 20 minutes
**Output:** Full character sheets for your agent team

### Part A: Core Character (10 min)

For your primary agent, create:

- Personality traits (3-5)
- Core values (3-4)
- Quirks (2-3)
- Relationships with other agents

### Part B: Memory Foundation (10 min)

Add:

- One core memory (real or hypothetical failure)
- What was learned
- How behavior changed
- Current growth areas

---

## Exercise 6.2: Memory System Implementation

**Time:** 25 minutes
**Output:** Working memory persistence for agents

### Part A: Memory Storage (10 min)

Create a simple memory store:

```python
# memory.py
import json
from datetime import datetime

class AgentMemory:
    def __init__(self, agent_name: str):
        self.agent_name = agent_name
        self.memory_file = f"memories/{agent_name}.json"
        self.load()

    def load(self):
        try:
            with open(self.memory_file) as f:
                self.data = json.load(f)
        except FileNotFoundError:
            self.data = {
                'core_memories': [],
                'recent_experiences': [],
                'patterns': [],
                'growth_areas': []
            }

    def save(self):
        with open(self.memory_file, 'w') as f:
            json.dump(self.data, f, indent=2)

    def add_experience(self, experience: str, lesson: str):
        self.data['recent_experiences'].append({
            'date': datetime.now().isoformat(),
            'experience': experience,
            'lesson': lesson
        })
        # Keep only last 10
        self.data['recent_experiences'] = self.data['recent_experiences'][-10:]
        self.save()

    def search(self, query: str) -> list:
        # Simple keyword search
        results = []
        for mem in self.data['core_memories']:
            if query.lower() in mem['description'].lower():
                results.append(mem)
        return results
```

### Part B: Memory Integration (10 min)

Update your agent to load and use memories:

```python
class MemoryEnabledAgent:
    def __init__(self, name):
        self.memory = AgentMemory(name)

    def get_context_with_memories(self, task):
        relevant = self.memory.search(task.keywords)
        context = self.base_context

        if relevant:
            context += "\n\n## Relevant Past Experience\n"
            for mem in relevant:
                context += f"- {mem['description']}: {mem['lesson']}\n"

        return context
```

### Part C: Test Memory Evolution (5 min)

1. Have agent make a mistake
2. Add it as a memory
3. Present similar situation
4. Verify agent references the memory

---

## Exercise 6.3: Agent Spawn Decision

**Time:** 15 minutes
**Output:** Decision on whether to create a new agent

### Part A: Identify Patterns (5 min)

Review your last week of agent interactions. What did you repeatedly:

- Explain?
- Fix?
- Review?
- Request?

### Part B: Evaluate (5 min)

For the most common pattern, answer:

- Is this a well-defined task?
- Would a specialist do better?
- Can the context be encoded in a prompt?

### Part C: Decide (5 min)

Either:

- Write an agent proposal for a new agent
- Document why existing agents should handle this

---

## The Full Picture

After completing the first six workshops, you have:

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Agent Team                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │   Roy   │  │   Jen   │  │  Moss   │  │ Cynthia │        │
│  │ Backend │  │Frontend │  │ Infra   │  │Research │        │
│  │         │  │         │  │         │  │         │        │
│  │ Memory  │  │ Memory  │  │ Memory  │  │ Memory  │        │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘        │
│       │            │            │            │              │
│       └────────────┼────────────┼────────────┘              │
│                    │            │                           │
│                    ▼            ▼                           │
│            ┌───────────┐  ┌───────────┐                     │
│            │   NATS    │  │  Review   │                     │
│            │ JetStream │  │  Pipeline │                     │
│            └─────┬─────┘  └─────┬─────┘                     │
│                  │              │                           │
│                  ▼              ▼                           │
│            ┌─────────────────────────┐                      │
│            │    Release Manager      │                      │
│            │   (Coordinates merges)  │                      │
│            └───────────┬─────────────┘                      │
│                        │                                    │
│                        ▼                                    │
│                  ┌───────────┐                              │
│                  │   Main    │                              │
│                  │  Branch   │                              │
│                  └───────────┘                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## What You've Built

**Planning System (Workshop 1)**
- Brain dump → Requirements → Value analysis → Phased roadmap

**Autonomous Workers (Workshop 2)**
- Headless Claude instances
- Test pipeline (unit, integration, E2E)
- Pre-commit and post-commit hooks

**Agent Orchestration (Workshop 3)**
- Specialist agents with clear scopes
- NATS JetStream for work queues with ACKs
- Matrix for human-agent communication
- Turn-based queue draining

**Release Management (Workshop 4)**
- Intelligent merge ordering
- Conflict detection
- Scaling strategies
- Review and documentation agents

**Anti-Pattern Detection (Workshop 5)**
- Senior developer checklist
- Static analysis hooks
- Custom analyzers with spaCy
- Automated pattern detection

**Memory and Evolution (Workshop 6)**
- Persistent agent memory
- Character development
- Self-correction from experience
- Agent capability growth

---

## What's Next

Continue to [Workshop 7 - Continuous Improvement](Workshop-7-Continuous-Improvement.md) to learn:

- How to find and defeat recurring patterns
- TDD for agent behavior
- E2E testing that prevents regressions
- Mobile workflows via claude.ai/code

---

## Final Thoughts

### The New Process

```
Old: Human writes code, AI assists
New: AI writes code, human directs and reviews
Future: AI team works, human provides vision
```

### The Key Insight

> Any time you're repeatedly inputting text into a language model, a language model could be doing that.

Understand what type of text needs to go in to keep the model producing what it needs to produce. You'll find yourself designing new agents and giving them a turn every time.

**This is the new process.**

---

## Resources

- [Agentic SDLC Syllabus](../1.%20Agentic-SDLC-Syllabus.md) - Course overview
- [Workshop 1](Workshop-1-Planning-and-Requirements.md) - Planning and Requirements
- [Workshop 2](Workshop-2-Autonomous-Workers.md) - Autonomous Workers
- [Workshop 3](Workshop-3-Agent-Orchestration.md) - Agent Orchestration
- [Workshop 4](Workshop-4-Release-Management.md) - Release Management
- [Workshop 5](Workshop-5-Anti-Pattern-Detection.md) - Anti-Pattern Detection
- [Workshop 7](Workshop-7-Continuous-Improvement.md) - Continuous Improvement

---

**Previous:** [Workshop 5 - Anti-Pattern Detection](Workshop-5-Anti-Pattern-Detection.md) | **Next:** [Workshop 7 - Continuous Improvement](Workshop-7-Continuous-Improvement.md)
