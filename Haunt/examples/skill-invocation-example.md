# Skill Invocation Example

## Scenario: Dev Agent Needs Commit Format

This example demonstrates how an agent dynamically invokes a skill mid-session when needed, rather than having all skills loaded at session start.

---

## Before: Agent Doesn't Know Format

**User Request:**
> "Finish implementing REQ-042 authentication endpoints and commit your work"

**Agent Internal State:**
```
Context: Working on authentication feature
Knowledge: Has technical implementation knowledge
Missing: Doesn't know project commit message format
```

**Agent Response (Without Skill):**
```bash
# Agent makes generic commit
git commit -m "Add authentication endpoints"
```

**Problem:** Commit doesn't follow project conventions - no REQ reference, no structure, no status indicator.

---

## Agent Recognizes Need

**Agent Decision Process:**
```
1. Detects: Need to create commit
2. Checks: Do I know commit format for this project?
3. Result: No - need to consult commit-conventions skill
4. Action: Invoke skill dynamically
```

---

## After: Agent Invokes Skill

**Agent Action:**
```
Reading: Skills/SDLC/commit-conventions/SKILL.md
Loading: Commit message format rules
```

**Agent Now Knows:**
- Required structure: [REQ-XXX] Action: Description
- Need "What was done" section with bullets
- Need Status: COMPLETE | IN_PROGRESS | BLOCKED
- Need footer with Claude Code attribution

**Agent Response (With Skill):**
```bash
git commit -m "[REQ-042] Add: User authentication API endpoints

What was done:
- Created /api/auth/login and /api/auth/logout routes
- Added JWT token generation in auth service
- Wrote integration tests for both endpoints

Status: COMPLETE

🤖 Generated with Claude Code"
```

---

## Context Efficiency Benefits

### Traditional Approach (All Skills Always Loaded)
- **Session Start Context:** 15,000 tokens
- **Includes:** Every skill definition (commit, testing, architecture, code patterns, etc.)
- **Problem:** Agent loaded with information it might never use this session
- **Cost:** High context consumption from start

### Dynamic Invocation Approach (Load When Needed)
- **Session Start Context:** 3,000 tokens (just agent definition + current task)
- **When Needed:** +2,000 tokens (commit-conventions skill only)
- **Total:** 5,000 tokens (67% reduction)
- **Benefit:** Context reserved for actual code and implementation details

### Real-World Impact

**Scenario: Backend Feature Development**
- Agent works on database schema changes
- Agent implements API endpoints
- Agent writes unit tests
- **Skills Actually Used:** commit-conventions (at end)
- **Skills NOT Needed:** frontend-patterns, deployment-procedures, documentation-templates

**Context Savings:** Only loaded 1 of 7 available skills = 85% context efficiency gain

---

## Commentary

**Why This Matters:**

1. **Context Window Optimization:** Agents have limited context windows. Loading only relevant skills means more room for code, dependencies, and implementation details.

2. **Reduced Cognitive Load:** Agent focuses on task-specific knowledge rather than maintaining awareness of all possible skills.

3. **Scalability:** As skill library grows (10, 20, 50 skills), dynamic invocation becomes essential. Can't load everything at session start.

4. **Just-In-Time Learning:** Agent learns what it needs, when it needs it - mirrors human workflow efficiency.

**Best Practice:** Agent definitions should reference skill locations, not embed full skill content. Agent invokes skills when specific triggers occur (git commit, test writing, code review, etc.).
