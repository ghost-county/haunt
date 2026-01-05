# Haunt - Elevator Pitch

## The One-Liner

**Haunt turns Claude Code into a coordinated AI dev team that plans before it codes.**

---

## The 30-Second Pitch

Most people use AI coding assistants like a magic typewriter - paste code, get code back. But real software needs planning, not just typing.

**Haunt** gives Claude Code:
- **Specialized agents** (PM, developers, researchers, reviewers)
- **A structured workflow** (requirements → roadmap → implementation)
- **Memory across sessions** (it remembers your project context)

One curl command to install. Run `/seance` to start. The spirits do the rest.

---

## The Tweet

> Stop using AI as a fancy autocomplete. Haunt turns Claude Code into a dev team that plans before it codes. One curl, restart, `/seance`. Done.

---

## For Different Audiences

### For Developers
"Haunt is an agent framework for Claude Code. It adds Project Managers, Developers, and Code Reviewers that coordinate through a shared roadmap. Think of it as giving Claude Code the structure of a real dev team."

### For Tech Leads
"Haunt enforces software engineering discipline on AI agents - atomic requirements, TDD, code review gates, commit conventions. Your AI assistants finally follow the same process your human team does."

### For The Curious
"You know how AI coding tools just... write code when you ask? Haunt makes them stop and think first. Plan the work, size it, break it down, THEN build it. Like having a tiny dev team in your terminal."

---

## Key Differentiators

| Without Haunt | With Haunt |
|---------------|------------|
| AI writes code immediately | AI plans, then writes code |
| No memory between sessions | Remembers project context |
| One generic assistant | Specialized agents (PM, Dev, Reviewer) |
| You manage the work | Roadmap manages the work |
| Hope it works | Tests before shipping |

---

## The Install (Yes, It's This Easy)

```bash
# 1. Install
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --scope=global --cleanup --clean --quiet

# 2. Restart Claude Code

# 3. Start building
/seance
```
