# Planning Depth Modifiers: Quick, Standard, Deep

All planning modes (1, 2, 3, 4) support three depth levels that control how thoroughly requirements are analyzed.

---

## Planning Depth: Quick (--quick)

**Triggered by:** `/seance --quick` or `/seance --quick <idea>`

**Purpose:** Fast-track simple tasks through minimal planning - skip strategic analysis, create basic requirement.

**Flow:**
1. Check if idea provided in command args
2. If no idea: Ask "What needs fixing?" and wait for user input
3. Create single requirement with minimal ceremony:
   - Parse idea to extract title
   - Infer affected files if obvious
   - Auto-assign to appropriate agent type
   - Set effort to XS or S based on description
   - Basic completion criteria (2-3 bullets)
4. **Skip Phase 2 entirely** - no JTBD, Kano, RICE, SWOT, VRIO analysis
5. Add requirement to roadmap immediately
6. Prompt to summon agent (same as other modes)

**Output:**
- Single requirement added to `.haunt/plans/roadmap.md`
- Minimal analysis overhead (<60 seconds total)
- Ready for immediate execution

**When to Use:**
- XS-S sized tasks only (typos, config changes, simple bug fixes)
- Obvious changes with clear scope
- Low-risk modifications
- Time-sensitive fixes

**When NOT to Use:**
- M-sized or larger features
- Changes with unclear scope
- Features requiring strategic analysis
- Cross-cutting changes affecting multiple systems

**Example:**
```
User: /seance --quick "Fix timeout value in config"
Agent:
⚡ Quick scrying...

Created REQ-225: Fix timeout value in config
- Type: Enhancement
- Effort: XS (~30 min)
- Agent: Dev-Infrastructure
- Files: config.yaml

Completion:
- Timeout value updated to recommended 30s
- Config file validated
- Changes tested

Ready to summon the spirits?
```

---

### Template for Quick Requirements

```markdown
### ⚪ REQ-XXX: [Title from user input]

**Type:** [Enhancement|Bug Fix]
**Reported:** [Today's date]
**Source:** Quick séance

**Description:**
[User's original input, lightly cleaned]

**Tasks:**
- [ ] [Inferred task 1]
- [ ] [Inferred task 2]
- [ ] [Inferred task 3]

**Files:**
- [Inferred file paths if obvious, otherwise "TBD - determine during implementation"]

**Effort:** [XS or S based on description keywords]
**Complexity:** SIMPLE
**Agent:** [Auto-assigned based on file types or description]
**Completion:** [2-3 basic acceptance criteria]
**Blocked by:** None
```

---

### Auto-Assignment Logic

Based on keywords in description:
- "config", "setup", "script" → Dev-Infrastructure
- "API", "endpoint", "database", "backend" → Dev-Backend
- "UI", "component", "page", "frontend" → Dev-Frontend
- "documentation", "README", "docs" → Dev-Infrastructure
- "test" only → Dev (whichever type matches file)

---

### Effort Detection

Based on keywords:
- "typo", "fix typo", "update config" → XS
- "add simple", "quick fix", "small change" → XS
- "add", "create simple", "update" → S
- Default: S (conservative)

---

### Error Handling

- If description is too vague: Ask clarifying question
- If scope appears too large: Warn and suggest standard mode instead
- If `.haunt/` missing: Create it with minimal setup

---

### Quick Planning Implementation Code

When `planning_depth == "quick"`, create requirements directly without PM:

```python
# Parse user input (from args or prompt)
idea = user_input.strip()

# Detect type
bug_keywords = ["fix", "bug", "error", "broken", "issue"]
is_bug = any(kw in idea.lower() for kw in bug_keywords)
req_type = "Bug Fix" if is_bug else "Enhancement"

# Auto-assign agent
if any(kw in idea.lower() for kw in ["config", "setup", "script", "doc"]):
    agent = "Dev-Infrastructure"
elif any(kw in idea.lower() for kw in ["api", "endpoint", "database", "backend"]):
    agent = "Dev-Backend"
elif any(kw in idea.lower() for kw in ["ui", "component", "page", "frontend"]):
    agent = "Dev-Frontend"
else:
    agent = "Dev-Infrastructure"  # Default

# Infer effort
xs_keywords = ["typo", "config", "small", "quick"]
effort = "XS" if any(kw in idea.lower() for kw in xs_keywords) else "S"

# Generate requirement
req_number = get_next_req_number()  # Parse roadmap for highest REQ-XXX
requirement = create_quick_requirement(
    number=req_number,
    title=idea,
    type=req_type,
    agent=agent,
    effort=effort
)

# Add to roadmap
append_to_roadmap(requirement)

# Display summary
print(f"✅ Created REQ-{req_number}: {title}")
print(f"   Agent: {agent}")
print(f"   Effort: {effort} (~30 min)" if effort == "XS" else f"   Effort: {effort} (~2 hours)")
```

---

## Planning Depth: Standard (default)

**Triggered by:** No depth modifier, or explicitly `/seance <idea>` (no `--quick` or `--deep`)

**Purpose:** Balanced analysis for most features - full workflow with strategic frameworks and critical review.

**Flow:**
1. Phase 1: Requirements Development (14-dimension rubric, understanding confirmation)
2. Phase 2: Requirements Analysis (JTBD, Kano, RICE scoring)
3. **Phase 2.5: Critical Review** (spawn gco-research-critic to challenge assumptions, identify gaps)
4. Phase 3: Roadmap Creation (batching, sizing, agent assignment with critic findings)

**When to Use:**
- S-M sized features
- Standard features with clear-ish scope
- When depth needs are unknown (default choice)
- Most day-to-day development work

**Output:**
- `.haunt/plans/requirements-document.md` (new projects)
- `.haunt/plans/requirements-analysis.md` (new projects)
- `.haunt/plans/roadmap.md` (updated)

---

## Planning Depth: Deep (--deep)

**Triggered by:** `/seance --deep <idea>`

**Purpose:** Extended strategic analysis for high-impact, high-risk features.

**Flow:**
1. Phase 1: Requirements Development (standard)
2. **Phase 2 Extended:** Requirements Analysis PLUS:
   - Expanded SWOT matrix
   - VRIO competitive analysis
   - Risk assessment matrix
   - Stakeholder impact analysis
   - Architectural implications document
3. **Phase 2.5: Critical Review** (spawn gco-research-critic to review both requirements AND strategic analysis)
4. Phase 3: Roadmap Creation (standard, incorporating critic findings)

**When to Use:**
- M-SPLIT sized features
- High strategic impact features
- Features with significant architectural decisions
- Features affecting multiple systems or stakeholders
- When risk assessment is critical

**Output:**
- Standard outputs (requirements-document.md, requirements-analysis.md, roadmap.md)
- **PLUS:** `.haunt/plans/REQ-XXX-strategic-analysis.md` (extended analysis)

**Example Deep Analysis Document:**
```markdown
# REQ-XXX Strategic Analysis

## Expanded SWOT Matrix
[Detailed strengths, weaknesses, opportunities, threats]

## VRIO Competitive Analysis
[Value, Rarity, Imitability, Organization assessment]

## Risk Assessment Matrix
[Likelihood x Impact grid with mitigation strategies]

## Stakeholder Impact Analysis
[User segments, internal teams, external partners]

## Architectural Implications
[System dependencies, migration paths, rollback strategies]
```

---

## Phase 2.5: Critical Review (Detailed)

**Applies to:** Standard and Deep planning modes only (Quick mode skips this phase)

**Purpose:** Adversarial review of requirements and analysis to identify gaps, unstated assumptions, edge cases, and risks before roadmap creation.

**Workflow:**

1. **After Phase 2 Completes:**
   - Requirements document exists
   - Analysis complete (JTBD, Kano, RICE for Standard; plus strategic analysis for Deep)
   - Before roadmap creation begins

2. **Spawn gco-research-critic Agent:**
   ```
   Spawn gco-research-critic with context:
   - Requirements document path
   - Analysis document path(s)
   - Planning depth (Standard or Deep)

   Prompt: "Review the requirements and analysis for [feature name]. Challenge assumptions, identify gaps, and flag risks before roadmap creation."
   ```

3. **Critic Review Focus:**
   - **Unstated assumptions:** What's assumed but not written?
   - **Missing edge cases:** What boundary conditions aren't covered?
   - **Scope creep:** Are estimates realistic? Is requirement trying to do too much?
   - **Error handling gaps:** What failure modes aren't addressed?
   - **Unstated risks:** What could block this work?
   - **Problem-solution alignment:** Does the requirement actually solve the stated problem?

4. **Critic Output Format:**
   ```
   🔴 Critical Issues (must fix before roadmap):
   - [Specific finding with requirement reference]

   🟡 Warnings (should address):
   - [Potential problem or missing detail]

   🟢 Strengths (well-defined):
   - [What's done well - positive reinforcement]

   💡 Suggestions (consider):
   - [Alternative approaches or improvements]
   ```

5. **Integrate Findings into Phase 3:**
   - PM receives critic findings
   - Critical issues addressed before roadmap creation
   - Warnings incorporated into task lists or completion criteria
   - Suggestions noted for implementation consideration
   - Strengths reinforce confidence in approach

**Example Flow:**

```
[Phase 2 completes: JTBD, Kano, RICE analysis done]

> 🔍 Summoning the Research Critic for adversarial review...

[gco-research-critic spawned, reviews requirements + analysis]

Critic Findings:

🔴 Critical Issues:
- Requirements assume database migration is zero-downtime but no rollback strategy defined
- Completion criteria don't specify what happens if external API is unavailable

🟡 Warnings:
- Effort estimate (M, 3 hours) seems optimistic for 8 file changes across auth layer
- Edge case not addressed: What if user has existing session during migration?

🟢 Strengths:
- Clear problem statement with user impact quantified
- Error handling paths well-defined for primary flow

💡 Suggestions:
- Consider phased rollout instead of big-bang deployment
- Add feature flag for gradual migration

> 📋 Incorporating critic findings into roadmap...

[Phase 3: Roadmap creation with findings integrated]

REQ-XXX Tasks now include:
- [ ] Define database migration rollback strategy
- [ ] Add fallback handling for external API unavailability
- [ ] Implement feature flag for gradual rollout
- [ ] Test migration with existing user sessions
```

**When Critic Review Adds Value:**

- **Standard mode (most features):** Catches common oversights before implementation
- **Deep mode (strategic features):** Reviews both requirements AND strategic analysis for alignment
- **M-sized work:** Complex features benefit most from adversarial review
- **High-risk changes:** Auth, data integrity, breaking changes deserve extra scrutiny

**When to Skip (Quick mode):**

- XS-S tasks with obvious scope
- Typos, config changes, simple fixes
- Time-sensitive hotfixes
- Low-risk documentation updates
