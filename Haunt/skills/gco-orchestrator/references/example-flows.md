# Example Flows: Complete Seance Workflows

## Mode 1 Example: With Prompt (New Project)

```
User: "/seance Build a task management app"

Agent:
🕯️ No .haunt/ detected. Beginning full séance ritual...

I'll guide you through the complete idea-to-roadmap workflow.
Would you like to:
- [A] Review each phase (requirements → analysis → roadmap)
- [B] Run through all phases and present the final roadmap

[User chooses A]

[Phase 1: Requirements Development proceeds...]
[Phase 2: Strategic Analysis proceeds...]
[Phase 3: Roadmap Creation proceeds...]

✅ Roadmap complete with 12 requirements across 4 batches.

[Random selection from summoning prompts]
"The spirits await your command. Give the word?"

[User: "yes"]

[Random response]
"🌙 The veil parts..."

[Spawn agents for Batch 1 items]
Summoning gco-dev-infrastructure for REQ-001...
Summoning gco-dev-backend for REQ-002...
Summoning gco-dev-backend for REQ-003...
```

---

## Mode 1 Example: With Prompt (Existing Project)

```
User: "/seance Add OAuth login support"

Agent:
🕯️ Existing project detected. Beginning incremental séance...

[PM creates requirements for OAuth feature]
[PM analyzes and breaks into 5 requirements]
[PM adds REQ-087 through REQ-091 to roadmap]

✅ Added 5 new requirements in Batch 8: OAuth Integration

[Random selection]
"Ready to summon the spirits?"

[User: "no"]

[Random response]
"🌑 The séance concludes. Your roadmap stands ready."

Your roadmap is ready at `.haunt/plans/roadmap.md`.
You can summon spirits later with `/summon gco-dev-backend REQ-087`
```

---

## Mode 2 Example: Choice Prompt - Add New

```
User: "/seance"

Agent:
🕯️ The spirits stir. What brings you to the veil?

[A] Add something new — I have an idea, feature, or bug to add
[B] Summon the spirits — The roadmap is ready. Let's work.

Your choice?

User: "A"

Agent:
What would you like to add?

User: "Add rate limiting to the API"

Agent:
🕯️ Existing project detected. Beginning incremental séance...

[PM creates requirements for rate limiting]
[PM adds REQ-092 through REQ-094 to roadmap]

✅ Added 3 new requirements in Batch 9: Rate Limiting

[Random selection]
"Shall we invoke the spirits for our dark intent?"

[User: "yes"]

[Random response]
"👻 The spirits rise..."

Summoning gco-dev-backend for REQ-092...
Summoning gco-dev-backend for REQ-093...
Summoning gco-dev-infrastructure for REQ-094...
```

---

## Mode 2 Example: Choice Prompt - Work Roadmap

```
User: "/seance"

Agent:
🕯️ The spirits stir. What brings you to the veil?

[A] Add something new — I have an idea, feature, or bug to add
[B] Summon the spirits — The roadmap is ready. Let's work.

Your choice?

User: "B"

Agent:
📋 Current roadmap shows these unstarted items:

Batch 3: Authentication
- ⚪ REQ-042: Implement JWT token generation
- ⚪ REQ-043: Add login endpoint
- ⚪ REQ-044: Add logout endpoint

Batch 4: User Management
- ⚪ REQ-045: Create user profile API
- ⚪ REQ-046: Add avatar upload

Which requirements should the spirits work on?
- Enter specific REQ numbers (e.g., "REQ-042, REQ-043")
- Or "all" for the next batch
- Or "batch 3" for all items in Batch 3

User: "batch 3"

Agent:
[Random response]
"👁️ They hear your call."

Summoning gco-dev-backend for REQ-042...
Summoning gco-dev-backend for REQ-043...
Summoning gco-dev-backend for REQ-044...

[Agents work in parallel...]

[After all agents complete:]

Agent:
🌙 The spirits have returned. Their work is done.

Verifying roadmap...
✅ All tasks checked off for REQ-042, REQ-043, REQ-044
✅ All requirements properly completed

Archiving to .haunt/completed/roadmap-archive.md...

Completed and Archived:
- 🟢 REQ-042: Implement JWT token generation
- 🟢 REQ-043: Add login endpoint
- 🟢 REQ-044: Add logout endpoint

Active roadmap cleaned. Batch 3: Authentication complete.
Ready for the next summoning.
```

---

## Mode 3 Example: New Project Prompt

```
User: "/seance"

Agent:
🕯️ A fresh haunting ground. What would you like to build?

User: "A personal finance tracker"

Agent:
🕯️ No .haunt/ detected. Beginning full séance ritual...

[Full workflow proceeds as in Mode 1...]
```

---

## Mode 4 Example: Explicit Scrying

```
User: "/seance --scry Add OAuth login"

Agent:
🔮 Scrying the future...

[PM analyzes and creates requirements]
[PM breaks into 5 requirements]
[PM adds to roadmap]

✅ Roadmap created with 5 requirements in Batch 8: OAuth Integration

- REQ-087: Implement OAuth provider integration
- REQ-088: Add login redirect flow
- REQ-089: Secure token storage
- REQ-090: Add logout endpoint
- REQ-091: Add user session management

Ready to execute? Run `/seance --summon`
```

---

## Mode 5 Example: Explicit Summoning

```
User: "/seance --summon"

Agent:
Reading roadmap...
Found 8 open requirements (5 ⚪ Not Started, 3 🟡 In Progress)

Filtering blocked items...
2 requirements blocked by dependencies (will skip)

👻 The spirits rise...

Summoning gco-dev-backend for REQ-042...
Summoning gco-dev-backend for REQ-043...
Summoning gco-dev-frontend for REQ-044...

[Agents work autonomously...]

[Agent 1 completes REQ-042]
✅ REQ-042 complete - JWT token generation implemented

[Agent 2 completes REQ-043]
✅ REQ-043 complete - Login endpoint added

[Agent 3 completes REQ-044]
✅ REQ-044 complete - Logout endpoint added

[All agents complete...]

⚰️ Automatically banishing completed work...

Verifying completion...
✓ REQ-042: All 5 tasks checked
✓ REQ-043: All 3 tasks checked
✓ REQ-044: All 4 tasks checked

Archiving to .haunt/completed/roadmap-archive.md...

🌙 The spirits have returned. Their work is done.

Completed and Archived:
- 🟢 REQ-042: Implement JWT token generation
- 🟢 REQ-043: Add login endpoint
- 🟢 REQ-044: Add logout endpoint

Active roadmap cleaned. Ready for the next summoning.
```

---

## Mode 6 Example: Explicit Banishing

```
User: "/seance --banish"

Agent:
⚰️ Banishing completed work...

Reading roadmap...
Found 4 requirements marked 🟢 Complete

Verifying completion...
✓ REQ-087: All 5 tasks checked
✓ REQ-088: All 3 tasks checked
✓ REQ-089: All 4 tasks checked
⚠ REQ-090: 2/3 tasks unchecked - skipping archival

Archiving 3 requirements to .haunt/completed/roadmap-archive.md...

⚰️ The spirits rest.

Completed and Archived:
- 🟢 REQ-087: Implement OAuth provider integration
- 🟢 REQ-088: Add login redirect flow
- 🟢 REQ-089: Secure token storage

Needs Attention:
- 🟢 REQ-090: Add logout endpoint (incomplete tasks)
  Missing checkboxes:
  - [ ] Add logout route to API
  - [ ] Test logout with active sessions

Active roadmap cleaned. Please complete REQ-090 tasks and re-run banishing.
```

---

## Quick Planning Example

```
User: "/seance --quick Fix timeout in config.yaml"

Agent:
⚡ Quick scrying...

Created REQ-225: Fix timeout in config.yaml
- Type: Bug Fix
- Effort: XS (~30 min)
- Agent: Dev-Infrastructure
- Files: config.yaml

Completion:
- Timeout value updated to recommended 30s
- Config file validated with linter
- Changes tested in local environment

Ready to summon the spirits?

User: "yes"

Agent:
👻 The spirits rise...

Summoning gco-dev-infrastructure for REQ-225...

[Agent completes work in ~20 minutes]

✅ REQ-225 complete - Timeout value fixed

⚰️ Automatically banishing completed work...

🌙 The spirits have returned. Quick fix complete.
```

---

## Deep Planning Example

```
User: "/seance --deep Implement multi-tenant architecture"

Agent:
🔮 Deep scrying the future...

[Phase 1: Requirements Development]
Understanding multi-tenant requirements...
Tenant isolation needs: Data, schema, compute
Scaling requirements: 100+ tenants

[Phase 2 Extended: Strategic Analysis]
Running JTBD, Kano, RICE analysis...
Creating SWOT matrix...
Performing VRIO competitive analysis...
Building risk assessment matrix...
Analyzing stakeholder impact...
Documenting architectural implications...

[Phase 2.5: Critical Review]
🔍 Summoning the Research Critic for adversarial review...

Critic Findings:

🔴 Critical Issues:
- No rollback strategy defined for tenant migration
- Data isolation verification not in completion criteria

🟡 Warnings:
- Effort estimate optimistic for database schema changes
- Performance testing plan not detailed

🟢 Strengths:
- Clear tenant isolation strategy
- Well-defined scaling thresholds

💡 Suggestions:
- Consider schema-per-tenant vs shared schema
- Add feature flag for gradual tenant migration

[Phase 3: Roadmap Creation]
Incorporating critic findings...

✅ Roadmap created with 15 requirements across 5 batches

Strategic analysis saved to:
.haunt/plans/REQ-226-strategic-analysis.md

Ready to summon the spirits?

[User: "yes"]

Agent:
🌙 The veil parts...

Summoning gco-dev-backend for REQ-226...
Summoning gco-dev-infrastructure for REQ-227...
Summoning gco-research-analyst for REQ-228 (architecture doc)...
```

---

## Error Handling Examples

### No Roadmap for Summoning

```
User: "/seance --summon"

Agent:
Reading roadmap...
⚠️ Error: No roadmap found at .haunt/plans/roadmap.md

The spirits have nothing to work on. Create a roadmap first:
Run `/seance --scry "your feature idea"`
```

---

### All Requirements Blocked

```
User: "/seance --summon"

Agent:
Reading roadmap...
Found 5 open requirements (all blocked by dependencies)

⚠️ All requirements blocked by unmet dependencies:
- REQ-042: Blocked by REQ-041
- REQ-043: Blocked by REQ-041
- REQ-044: Blocked by REQ-042
- REQ-045: Blocked by REQ-043
- REQ-046: Blocked by REQ-045

Resolve blocking requirements first before summoning.
Start with: /summon gco-dev-backend REQ-041
```

---

### Partial Completion After Summoning

```
[Agents finish work, some incomplete]

Agent:
🌙 The spirits have returned. Some work remains.

Completed and Archived:
- 🟢 REQ-042: Implement JWT token generation

Still In Progress:
- 🟡 REQ-043: Add login endpoint (2/5 tasks complete)
  Remaining:
  - [ ] Add password validation
  - [ ] Implement rate limiting
  - [ ] Add E2E tests

- 🔴 REQ-044: Add logout endpoint (blocked - waiting on REQ-043)

Continue work with: /summon gco-dev-backend REQ-043
```

---

### Version Check with Reinstall

```
User: "/seance"

Agent:
🔮 Haunt framework has new features available.

   Installed: a1b2c3d4
   Available: e5f6g7h8

Reinstall to get latest features? (Y/n):

User: "y"

Agent:
📦 Reinstalling Haunt framework...

[Setup script runs]

✅ Haunt framework reinstalled!

⚠️  To use new features, restart Claude Code:
   1. Type 'exit' or close this chat session
   2. Start a new session
   3. New agents, skills, and commands will be available

Continue with current session? (y/N):

User: "n"

Agent:
👻 The spirits rest. Restart Claude Code when ready.
```
