---
name: gco-model-selection
description: Model selection guidelines by agent type and task complexity. Invoke when spawning agents or selecting models for work items. Contains model assignments, ROI analysis, task tool usage, and anti-patterns to avoid.
---

This rule provides guidance on selecting appropriate models for different agent types and tasks.

## Principle

**High-leverage activities require high-capability models.** The cost difference between models is negligible compared to the cost of poor decisions, wasted implementation time, or missed edge cases.

## Model Assignments by Agent Type

| Agent | Model | Rationale |
|-------|-------|-----------|
| **Project Manager** | Sonnet/Opus | Strategic analysis (JTBD, Kano, RICE, SWOT, VRIO) requires deep reasoning; requirements quality determines all downstream work |
| **Research** | Sonnet | Technical investigation, architecture recommendations, risk assessment |
| **Research Analyst** | Sonnet | Investigation and validation require thorough analysis |
| **Dev** | Sonnet | Implementation requires reasoning for TDD, patterns, edge cases, architecture |
| **Code Reviewer** | Sonnet | Quality gates and pattern detection require deep reasoning |
| **Release Manager** | Sonnet | Risk assessment, merge sequencing, coordination requires reasoning |
| **Code Reviewer (readonly)** | Haiku | Read-only review for style/lint checks is straightforward |

## When to Use Each Model

### Use Opus (Highest Capability)
- **Strategic planning sessions** - JTBD, Kano analysis, RICE prioritization
- **Complex multi-requirement decomposition** - Breaking down SPLIT-sized work
- **High-stakes architecture decisions** - Choices that affect entire system
- **Cross-cutting refactoring planning** - Large-scale code changes

**Cost**: ~$15 per 1M input tokens, ~$75 per 1M output tokens
**When**: Initial planning phases, critical decisions

### Use Sonnet (Default for Most Work)
- **Requirements analysis** - Analyzing user needs and creating specs
- **Technical investigation** - Researching libraries, frameworks, approaches
- **Code implementation** - Writing features, tests, fixes
- **Code review** - Quality checks, pattern detection
- **Architecture decisions** - Component design, API design

**Cost**: ~$3 per 1M input tokens, ~$15 per 1M output tokens
**When**: Default for all research, analysis, implementation, and review tasks

### Use Haiku (Fast & Cheap)
- **Read-only codebase exploration** - Finding files, searching for patterns
- **Simple file searches** - "Find all .tsx files in src/"
- **Structured data extraction** - Parsing logs, extracting specific values
- **Quick lookups** - "What's the current value of X?"
- **Style/lint checks** - Simple code quality rules

**Cost**: ~$0.25 per 1M input tokens, ~$1.25 per 1M output tokens
**When**: Fast, straightforward tasks with clear answers and no analysis needed

## ROI Analysis

**Example: Requirements Analysis**

Using Haiku (wrong choice):
- Saves: $0.30 on analysis
- Risk: Shallow analysis misses critical requirement
- Result: 5 hours of dev time building wrong thing
- Cost: $500+ in wasted time
- **Net: -$499.70**

Using Sonnet/Opus (correct choice):
- Cost: $2.00 for deep analysis
- Result: Identifies high-impact feature correctly
- Benefit: No wasted dev time, correct architecture
- **Net: $498+ saved (plus quality improvement)**

**The multiplier effect:**
- Bad requirements → wasted implementation → wasted testing → wasted deployment → wasted maintenance
- Good requirements → efficient implementation → comprehensive tests → smooth deployment → maintainable code

## Task Tool Usage

When using the Task tool, the agent character sheet's model specification takes precedence:

```markdown
# Spawning Research agent (uses sonnet per agent definition)
Task(subagent_type="gco-research", prompt="Evaluate PostgreSQL vs MongoDB")

# Spawning Dev agent (uses sonnet per agent definition)
Task(subagent_type="gco-dev", prompt="Implement JWT authentication")

# Spawning Explore agent (can use haiku for read-only exploration)
Task(subagent_type="Explore", model="haiku", prompt="Find all React components")
```

**Built-in agents** (Explore, Plan) can have model explicitly specified:
- Explore with `model="haiku"` for quick searches
- Plan with `model="sonnet"` for strategic breakdowns

**Haunt agents** (gco-*) use the model specified in their character sheet and should NOT have model overridden unless there's a specific reason.

## Anti-Patterns to Avoid

❌ **Using Haiku for strategic analysis** - "It's just requirements, keep it cheap"
- Requirements quality determines all downstream work
- Cheap requirements = expensive mistakes

❌ **Using Haiku for research** - "It's just looking things up"
- Research requires connecting information, identifying implications, evaluating tradeoffs
- Shallow research = wrong architecture choices

❌ **Using Haiku for implementation** - "Save money on coding"
- Implementation requires reasoning about edge cases, patterns, TDD
- Cheap coding = bugs, technical debt, refactoring later

❌ **Model mixing within agent type** - "Use Haiku for small tasks, Sonnet for big ones"
- Inconsistent quality across work items
- "Small" tasks often have hidden complexity
- Better: Size work correctly, use appropriate model consistently

## Guidelines for Model Override

**Rarely override agent model specifications.** Agent definitions include carefully chosen models for their work type.

**Valid reasons to override:**
- Using built-in Explore agent for quick read-only searches (specify `model="haiku"`)
- Emergency cost reduction during debugging (temporary, document why)
- Experimental evaluation of model capabilities (research context only)

**Invalid reasons to override:**
- "Saving money" on requirements/research/analysis (false economy)
- "It's a small task" (small tasks can have big implications)
- "We'll review it anyway" (review can't fix flawed analysis)

## Monitoring Costs

**Track model usage by agent type:**
```bash
# Example: Check API costs by agent (if logging enabled)
grep "model=" .haunt/integration.log | sort | uniq -c
```

**If costs are concerning:**
1. First, verify agents aren't doing redundant work
2. Second, optimize prompts and reduce token usage
3. Third, improve requirement sizing to avoid rework
4. **Last resort**, consider model changes (document impact)

## Summary

**The rule of thumb:**
- If the work output affects decisions, architecture, or future work → **Sonnet or Opus**
- If the work is read-only exploration or extraction → **Haiku is acceptable**
- When in doubt → **Use Sonnet** (the cost of being wrong is always higher than the model difference)

**Remember:**
- PM and Research agents define WHAT gets built → highest leverage
- Dev agents turn requirements into reality → high leverage
- Code Reviewers prevent defects from spreading → high leverage
- Only read-only exploration is low-leverage enough for Haiku
