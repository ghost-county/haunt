# Haunt Framework Demo - Presenter Script

**Duration:** 5-10 minutes
**Audience:** Bosses, teams, stakeholders
**Objective:** Showcase Haunt's autonomous agent capabilities

---

## Pre-Demo Checklist

- [ ] Terminal window maximized, font size readable from back of room
- [ ] Demo script ready: `bash Haunt/scripts/demo/haunt-demo.sh`
- [ ] Backup plan: Have QUICK-REFERENCE.md open in case of questions
- [ ] Time check: Know your time limit (5 min = quick, 10 min = detailed)

---

## Section 1: Introduction (30 seconds)

### What to Say

> "Haunt is a framework for running autonomous AI agent teams. Think of it as Claude, but instead of one agent in one chat window, you can spawn multiple agents working in parallel on different parts of your codebase."

### Key Talking Points

- **Problem:** Traditional development = one developer, one task, linear workflow
- **Solution:** Haunt = multiple AI agents, parallel work, coordinated by lightweight framework
- **Ghost County Theme:** Playful metaphor makes complex concepts approachable

### Expected Questions

**Q:** "Is this just prompting Claude multiple times?"
**A:** "No. Each agent has persistent context, specific role expertise, and follows structured workflows. They coordinate through a shared roadmap but work independently."

**Q:** "How many agents can run at once?"
**A:** "As many Claude Code tabs as you can manage. Typically 3-5 for a small team, more for larger projects."

### Install Haunt

**Execute:**

```bash
# Option 1: Manual installation (recommended, works on all platforms)
git clone https://github.com/ghost-county/ghost-county.git
cd ghost-county
bash Haunt/scripts/setup-haunt.sh --scope=project
cd .. && rm -rf ghost-county

# Option 2: One-liner (may fail on some networks)
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --scope=project --cleanup
```

**Windows users:** Use Git Bash or WSL, not PowerShell. See [SETUP-GUIDE.md Issue 11](../SETUP-GUIDE.md#issue-11-failed-to-clone-repository-during-remote-installation) if clone fails.

**Start claude-code** 

```bash

claude --dangerously-skip-permissions

```
---

## Section 2: The Séance (1-2 minutes)

### What to Prompt

> "Let's start with an idea: \
\
Build a simple web app called "Popcorn Picker" for choosing who speaks next in meetings.\
\
Features:\
\
Text input to add participant names (one at a time or comma-separated)
Display list of participants with ability to remove individuals
Big "Pick Next" button that randomly selects someone with a brief animation
Selected person shown prominently
Option to mark someone as "already went" so they're skipped in future picks
Reset button to start over\
\
Single HTML file with embedded CSS/JS. Make it look fun and satisfying to use. \
\
Watch how the séance workflow turns this vague idea into structured, trackable requirements."

### Key Talking Points

- **Input:** Natural language feature request
- **Process:** PM agent analyzes, breaks down, sizes, assigns
- **Output:** Multiple small requirements in roadmap, ready for parallel work
- **Benefit:** No manual ticket creation, automatic work breakdown

### Demo Flow

1. Show `/seance idea` command (simulated)
2. Highlight the breakdown: 1 feature → 4 small requirements
3. Point out sizing (all S-sized = 1-4 hours each)
4. Mention automatic roadmap update

### Expected Questions

**Q:** "Can I customize how it breaks down work?"
**A:** "Yes. The PM agent follows patterns defined in roadmap-format.md rules. You can tune sizing preferences, agent assignment logic, etc."

**Q:** "What if the breakdown is wrong?"
**A:** "You can edit the roadmap manually or re-run the séance with more specific guidance. The PM is an assistant, not a dictator."

---

## Section 2.5: Interactive Decision Making (1-2 minutes)

### What to Say

> "What makes Haunt smart is that agents don't guess - they ask. When there's ambiguity or multiple valid approaches, agents surface the decision to you instead of making assumptions."

### Key Talking Points

- **No assumptions:** Agents ask when requirements are ambiguous
- **Architecture choices:** Framework selection, database choice, API design patterns
- **User stays in control:** Quick questions prevent hours of wasted work
- **Smart defaults:** Agents still work autonomously when path is clear

### Demo Flow

1. Show séance with ambiguous request
2. Agent asks clarifying question with multiple options
3. User selects approach
4. Agent proceeds confidently with chosen direction
5. Highlight time saved by asking upfront

### Example Script

**Scenario:** User says "Add authentication"

```
$ /seance "Add authentication"

🔮 Channeling the spirits...

⚠️  CLARITY NEEDED: Multiple ways to implement authentication

How should we implement authentication?
[1] NextAuth.js (Recommended)
    ↳ Full-featured auth library with OAuth, email, credentials
[2] Clerk
    ↳ Managed service. Beautiful UI, adds external dependency
[3] Supabase Auth
    ↳ If using Supabase, integrated solution with RLS
[4] Custom JWT
    ↳ Full control, more work to secure properly

Your choice: [1]

✓ Proceeding with NextAuth.js approach
✓ Creating requirements:
  - REQ-047: Install NextAuth.js and configure providers
  - REQ-048: Create authentication API routes
  - REQ-049: Add session handling middleware
  - REQ-050: Build login/logout UI components
```

### Expected Questions

**Q:** "Does it ask questions for every little thing?"
**A:** "No. Agents only ask when there are genuinely multiple valid approaches or when requirements are ambiguous. They don't ask about obvious best practices or established patterns."

**Q:** "Can I skip the questions and just tell it what to do?"
**A:** "Yes. If you're specific upfront ('Add NextAuth.js authentication'), agents proceed without asking. Questions only appear when clarity is needed."

**Q:** "What if I pick the wrong option?"
**A:** "No problem. You can edit the roadmap before summoning agents, or agents can refactor later. The questions prevent waste, not lock you in forever."

---

## Section 3: Summoning Spirits (1-2 minutes)

### What to Say

> "Now we summon the agents to do the work. Each agent spawns in a new Claude Code tab with full context about their assignment."

### Key Talking Points

- **Single summon:** `/summon Dev-Frontend REQ-042` for targeted work
- **Parallel summon:** `/summon all` to spawn multiple agents at once
- **Independence:** Each agent works autonomously, no manual coordination needed
- **Efficiency:** What would take 2 days sequentially → done in parallel

### Demo Flow

1. Show single `/summon` command
2. Highlight assignment clarity: agent knows exactly what to do
3. Show `/summon all` for parallel execution
4. Emphasize "3 agents working simultaneously"

### Expected Questions

**Q:** "How do agents avoid conflicts?"
**A:** "Work is pre-decomposed into independent chunks. If there's a dependency, we use 'Blocked by:' field in roadmap to enforce sequencing."

**Q:** "Do I need to monitor all the tabs?"
**A:** "No. Agents update status in the roadmap. Use `/haunting` to check on them, or let them work and review when done."

---

## Section 4: The Curse (1-2 minutes)

### What to Say

> "Curses are anti-patterns we detect and defeat with tests. This prevents bad patterns from creeping back into the codebase."

### Key Talking Points

- **Pattern detection:** `/seer` finds anti-patterns automatically
- **Test-based enforcement:** Each exorcised pattern = permanent test
- **Examples:** Silent fallbacks, magic numbers, god functions
- **Cultural fit:** "Seer" divines patterns, "exorcism" defeats them

### Demo Flow

1. Show `/seer` output with detected issues
2. Highlight severity: some patterns warded (tests exist), others active
3. Show `/exorcism` creating a defeat test
4. Explain: test runs on every commit, preventing regression

### Expected Questions

**Q:** "Can I add custom patterns?"
**A:** "Yes. Create a new defeat test in .haunt/tests/patterns/ following the existing format."

**Q:** "What if I legitimately need the 'bad' pattern?"
**A:** "Tests can have exemptions. Add a comment explaining why, or configure the test to skip specific files."

---

## Section 5: Status Tracking (1-2 minutes)

### What to Say

> "Tracking multi-agent work is hard. Haunt provides two views: `/haunting` for active work, and `/haunt status` for roadmap progress."

### Key Talking Points

- **Real-time visibility:** See all agents and their current tasks
- **No manual updates:** Agents update status automatically
- **Session tracking:** Know which Claude tabs are working on what
- **Progress metrics:** Understand batch completion, blockers, velocity

### Demo Flow

1. Show `/haunting` output: active agents with task details
2. Show `/haunt status`: batch-level progress view
3. Highlight: 75% active = good parallelization
4. Point out blockers: REQ-045 waiting on REQ-042

### Expected Questions

**Q:** "What if an agent gets stuck?"
**A:** "It updates status to 🔴 Blocked and notes the issue. PM can reassign or help unblock."

**Q:** "Can I see historical progress?"
**A:** "Yes. Completed requirements are archived with implementation notes. Git history provides full audit trail."

---

## Section 6: Rituals (1 minute)

### What to Say

> "Rituals automate the boring maintenance work. Daily rituals check health, weekly rituals archive completed work."

### Key Talking Points

- **Daily ritual:** Test health, roadmap sync, pattern scan
- **Weekly ritual:** Archive, cleanup, dependency check
- **Automation:** No manual checklist needed
- **Consistency:** Same checks every time, no steps forgotten

### Demo Flow

1. Show `/ritual daily` output
2. Highlight checks: tests, patterns, memory, roadmap
3. Show `/ritual weekly` summary
4. Emphasize: "Set it and forget it" maintenance

### Expected Questions

**Q:** "Can I customize rituals?"
**A:** "Yes. Edit the ritual command (Haunt/commands/ritual.md) to add/remove checks."

**Q:** "Do rituals run automatically?"
**A:** "Not yet. Currently manual invocation, but could be hooked into CI or cron jobs."

---

## Section 7: Wrap-Up (30 seconds)

### What to Say

> "That's Haunt: autonomous agents, structured workflows, pattern enforcement, low overhead. Ready to haunt your codebase?"

### Key Talking Points

- **Full workflow:** Idea → Séance → Summon → Track → Maintain
- **Autonomous:** Agents work independently, PM coordinates
- **Transparent:** Full visibility, no black boxes
- **Low friction:** Setup in minutes, scales to any project size

### Call to Action

- **Get started:** `bash Haunt/scripts/setup-agentic-sdlc.sh`
- **Read docs:** Haunt/SETUP-GUIDE.md
- **Try séance:** `/seance idea` in your own project

---

## Timing Guide

| Section | Quick (5 min) | Detailed (10 min) |
|---------|---------------|-------------------|
| 1. Introduction | 0:00-0:30 | 0:00-0:30 |
| 2. Séance | 0:30-1:30 | 0:30-2:30 |
| 2.5. Interactive Decisions | 1:30-2:30 | 2:30-4:00 |
| 3. Summoning | 2:30-3:30 | 4:00-5:30 |
| 4. Curse | 3:30-4:00 | 5:30-7:00 |
| 5. Status | 4:00-4:30 | 7:00-8:30 |
| 6. Rituals | 4:30-5:00 | 8:30-9:30 |
| 7. Wrap-up | SKIP or 5:00-5:30 | 9:30-10:00 |

**Time-saving tips:**
- **Short on time?** Skip Section 6 (Rituals) or combine with Section 5
- **Need to extend?** Add live coding demo in Section 3 (actually summon an agent)
- **Interactive audience?** Add Q&A pause points between sections

---

## Common Questions & Answers

### Technical

**Q:** "What if two agents modify the same file?"
**A:** "Rare, because work is pre-decomposed. If it happens, standard git conflict resolution applies. Agents can coordinate through PR comments."

**Q:** "How does this integrate with existing CI/CD?"
**A:** "Haunt commits follow standard git workflow. Pattern defeat tests run in your existing test suite. No special CI configuration needed."

**Q:** "Can I use this with languages other than Python?"
**A:** "Yes. Framework is language-agnostic. Dev agents have modes for backend (Python/Go/Node), frontend (React/Vue), and infrastructure (Terraform/K8s)."

### Philosophical

**Q:** "Isn't this replacing developers?"
**A:** "No. It's a force multiplier. Agents handle tedious work (boilerplate, pattern enforcement, routine refactoring). Developers focus on architecture, design, complex problem-solving."

**Q:** "How do you ensure code quality?"
**A:** "Pattern defeat tests, code review agents, and test-driven development. Quality is built into the workflow, not an afterthought."

**Q:** "What's the learning curve?"
**A:** "If you know git and Claude Code, you can start in 10 minutes. Advanced features (custom patterns, ritual tuning) come with experience."

### Business

**Q:** "How much does this cost?"
**A:** "Haunt is free. You pay for Claude Code usage (multiple parallel sessions). Typical project: $50-100/month for 3-5 active agents."

**Q:** "ROI? How much time does this save?"
**A:** "Anecdotal: 3-5x faster for feature development due to parallelization. Pattern enforcement saves hours of code review. Hard to quantify, but teams report significant velocity gains."

**Q:** "Can this scale to a large team?"
**A:** "Yes. Framework is lightweight. Use it for a single project or across multiple repos. Each agent works independently, so no coordination bottleneck."

---

## Demo Disaster Recovery

### If demo script fails to run:
1. Fallback to manual walkthrough using QUICK-REFERENCE.md
2. Show static screenshots (if prepared)
3. Live-code a `/seance` or `/summon` in actual project

### If audience loses interest:
1. Skip to Section 7 wrap-up
2. Offer to follow up with detailed docs/video
3. Open Q&A early

### If time runs over:
1. Skip Section 6 (Rituals)
2. Speed through Section 5 (Status Tracking)
3. Jump to Section 7 at hard stop time

### If technical questions stump you:
1. "Great question! Let me get back to you with details."
2. Offer to share documentation links
3. Connect questioner with technical POC after demo

---

## Post-Demo Follow-Up

**Share these resources:**
- Haunt/SETUP-GUIDE.md - Complete setup instructions
- Haunt/QUICK-REFERENCE.md - Command cheat sheet
- Haunt/docs/WHITE-PAPER.md - Design philosophy
- Demo recording (if available)

**Encourage experimentation:**
- "Try `/seance idea` with a real feature request"
- "Run a daily ritual to see what it catches"
- "Scan for curses in your existing codebase"

**Measure success:**
- Did attendees try Haunt after demo?
- Feature requests or questions received?
- Positive feedback on workflow clarity?
