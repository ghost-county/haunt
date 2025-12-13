---
name: gco-requirements-analysis
description: Strategic analysis of requirements using business frameworks (JTBD, Kano, Porter, VRIO, SWOT, RICE). Use after requirements-development to prioritize and assess strategic impact. Triggers on "analyze requirements", "prioritize features", "strategic analysis", or when the Project Manager begins Phase 2 of the idea-to-roadmap workflow.
---

# Requirements Analysis

Analyze requirements using strategic business frameworks to prioritize and assess impact.

## When to Use

- After Phase 1 (requirements-development) completes
- When prioritizing a backlog of requirements
- Assessing strategic fit of proposed features
- Phase 2 of the idea-to-roadmap workflow

## Input

`.haunt/plans/requirements-document.md` (from Phase 1)

## Output Location

`.haunt/plans/requirements-analysis.md`

## Process

### Step 1: Feature Clarification

Summarize the feature using foundational frameworks:

#### Jobs To Be Done (JTBD)
> "When [situation], I want to [motivation], so I can [expected outcome]."

Identify:
- **Functional job:** What task is being accomplished?
- **Emotional job:** How does the user want to feel?
- **Social job:** How does the user want to be perceived?

#### Kano Model Classification

| Category | Description | This Feature |
|----------|-------------|--------------|
| **Basic** | Expected, causes dissatisfaction if missing | [ ] |
| **Performance** | More is better, linear satisfaction | [ ] |
| **Delighter** | Unexpected, causes disproportionate satisfaction | [ ] |

### Step 2: Context Mapping

#### Business Model Canvas Impact

Assess which canvas elements this feature affects:

| Element | Impact | Notes |
|---------|--------|-------|
| **Value Proposition** | High/Medium/Low/None | |
| **Customer Segments** | High/Medium/Low/None | |
| **Channels** | High/Medium/Low/None | |
| **Customer Relationships** | High/Medium/Low/None | |
| **Revenue Streams** | High/Medium/Low/None | |
| **Key Resources** | High/Medium/Low/None | |
| **Key Activities** | High/Medium/Low/None | |
| **Key Partnerships** | High/Medium/Low/None | |
| **Cost Structure** | High/Medium/Low/None | |

### Step 3: Value Chain Mapping

#### Porter's Value Chain Analysis

**Primary Activities:**

| Activity | Impact | How |
|----------|--------|-----|
| Inbound Logistics | | |
| Operations | | |
| Outbound Logistics | | |
| Marketing & Sales | | |
| Service | | |

**Support Activities:**

| Activity | Impact | How |
|----------|--------|-----|
| Infrastructure | | |
| Human Resources | | |
| Technology Development | | |
| Procurement | | |

### Step 4: Strategic Analysis

#### VRIO Framework

| Criterion | Assessment | Evidence |
|-----------|------------|----------|
| **Valuable** | Yes/No | Does it reduce costs or increase revenue? |
| **Rare** | Yes/No | Do few competitors have this? |
| **Inimitable** | Yes/No | Is it hard to copy? |
| **Organized** | Yes/No | Can we exploit this effectively? |

**Competitive Implication:**
- [ ] Competitive Disadvantage (not valuable)
- [ ] Competitive Parity (valuable but not rare)
- [ ] Temporary Advantage (valuable, rare, but imitable)
- [ ] Sustained Advantage (all four criteria met)

#### SWOT Analysis

| | Helpful | Harmful |
|---|---------|---------|
| **Internal** | **Strengths:** | **Weaknesses:** |
| | - | - |
| **External** | **Opportunities:** | **Threats:** |
| | - | - |

#### PESTEL Considerations

Only include factors relevant to this feature:

| Factor | Relevance | Consideration |
|--------|-----------|---------------|
| **Political** | High/Medium/Low/None | |
| **Economic** | High/Medium/Low/None | |
| **Social** | High/Medium/Low/None | |
| **Technological** | High/Medium/Low/None | |
| **Environmental** | High/Medium/Low/None | |
| **Legal** | High/Medium/Low/None | |

### Step 5: Prioritization

#### RICE Scoring

For each requirement or requirement group:

| Requirement | Reach | Impact | Confidence | Effort | RICE Score |
|-------------|-------|--------|------------|--------|------------|
| REQ-XXX | | | | | |

**Scoring Guide:**
- **Reach:** How many users affected per quarter? (number)
- **Impact:** Minimal (0.25), Low (0.5), Medium (1), High (2), Massive (3)
- **Confidence:** Low (50%), Medium (80%), High (100%)
- **Effort:** Person-weeks (lower is better)

**Formula:** `RICE = (Reach × Impact × Confidence) / Effort`

#### Impact/Effort Matrix

```
                    HIGH IMPACT
                         │
         Quick Wins      │      Major Projects
         (Do First)      │      (Plan Carefully)
                         │
    LOW EFFORT ──────────┼────────── HIGH EFFORT
                         │
         Fill-ins        │      Thankless Tasks
         (Do Later)      │      (Avoid/Delegate)
                         │
                    LOW IMPACT
```

**Placement:**
| Requirement | Impact | Effort | Quadrant |
|-------------|--------|--------|----------|
| REQ-XXX | High/Low | High/Low | |

#### Cost-Benefit Summary

| Requirement | Estimated Cost | Expected Benefit | Ratio |
|-------------|----------------|------------------|-------|
| REQ-XXX | | | |

### Step 6: Strategic Impact Synthesis

#### Balanced Scorecard Mapping

| Perspective | Impact | Specific Effects |
|-------------|--------|------------------|
| **Financial** | High/Medium/Low | |
| **Customer** | High/Medium/Low | |
| **Internal Process** | High/Medium/Low | |
| **Learning & Growth** | High/Medium/Low | |

#### Critical Value Drivers

1. **Primary driver:** [Most important value this delivers]
2. **Secondary driver:** [Second most important]
3. **Tertiary driver:** [Third most important]

#### Strategic Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| [Risk 1] | Critical/High/Medium/Low | |
| [Risk 2] | Critical/High/Medium/Low | |

### Step 7: Implementation Recommendation

Based on the analysis:

```markdown
## Recommendation Summary

**Should this feature be prioritized?** Yes / Yes with modifications / Defer / No

**Rationale:** [2-3 sentences explaining the recommendation]

**Suggested Implementation Sequence:**
1. [First requirement/group - why first]
2. [Second requirement/group - why second]
3. [Third requirement/group - why third]

**Critical Dependencies:**
- [Dependency that must be resolved]

**Key Risks to Monitor:**
- [Risk requiring attention during implementation]
```

## Analysis Document Template

```markdown
# Requirements Analysis: [Feature Name]

**Created:** [Date]
**Author:** Project Manager Agent
**Input Document:** requirements-document.md
**Version:** 1.0

---

## 1. Feature Overview

### Summary
[Brief description of the feature]

### Jobs To Be Done
- **Functional:** [Job]
- **Emotional:** [Job]
- **Social:** [Job]

### Kano Classification
[Basic / Performance / Delighter] - [Rationale]

---

## 2. Business Context

### Business Model Canvas Impact
[Table from Step 2]

### Ecosystem Dependencies
- [Dependency 1]
- [Dependency 2]

---

## 3. Value Chain Analysis

### Primary Activities Impact
[Summary of Porter's primary activities]

### Support Activities Impact
[Summary of Porter's support activities]

---

## 4. Strategic Assessment

### VRIO Analysis
[Table and competitive implication]

### SWOT Analysis
[Matrix from Step 4]

### External Factors (PESTEL)
[Relevant factors only]

---

## 5. Prioritization

### RICE Scores
[Table with scores]

### Impact/Effort Placement
[Matrix placement for each requirement]

### Cost-Benefit Summary
[Table]

---

## 6. Strategic Impact

### Balanced Scorecard
[Table from Step 6]

### Value Drivers
1. [Primary]
2. [Secondary]
3. [Tertiary]

### Risk Assessment
[Table of risks]

---

## 7. Recommendation

**Prioritization Decision:** [Yes / Yes with modifications / Defer / No]

**Rationale:**
[Explanation]

**Implementation Sequence:**
1. [First]
2. [Second]
3. [Third]

**Watch Items:**
- [Item requiring monitoring]
```

## Framework Quick Reference

| Framework | Purpose | When Most Useful |
|-----------|---------|------------------|
| **JTBD** | Understand user motivation | Always - foundational |
| **Kano** | Set expectations | Feature classification |
| **Business Model Canvas** | Strategic alignment | New capabilities |
| **Porter's Value Chain** | Operational impact | Process changes |
| **VRIO** | Competitive advantage | Differentiating features |
| **SWOT** | Internal/external fit | Risk assessment |
| **PESTEL** | External factors | Regulatory/market features |
| **RICE** | Quantitative priority | Backlog ordering |
| **Impact/Effort** | Quick visual priority | Resource allocation |
| **Balanced Scorecard** | Holistic impact | Executive communication |

## Quality Checklist

Before completing Phase 2:

- [ ] JTBD clearly articulated
- [ ] Kano classification justified
- [ ] Business model impact assessed
- [ ] Value chain position mapped
- [ ] VRIO analysis complete
- [ ] SWOT analysis complete
- [ ] RICE scores calculated
- [ ] Impact/Effort placement determined
- [ ] Strategic risks identified
- [ ] Implementation sequence recommended

## Handoff to Phase 3

After creating `requirements-analysis.md`:

If user selected **review mode**:
> "I've completed the strategic analysis at `.haunt/plans/requirements-analysis.md`.
>
> **Key findings:**
> - RICE scores suggest [priority order]
> - Primary value driver: [driver]
> - Main risk: [risk]
>
> Please review and let me know if you'd like any changes before I create the roadmap."

If user selected **run-through mode**:
> Proceed directly to Phase 3 (roadmap-creation skill)
