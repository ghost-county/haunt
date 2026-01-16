# Session Resume Check (PRIORITY)

## First Action on Every Session

**Before doing ANYTHING else**, check for incomplete work:

```bash
# Check if handoff file exists
ls -la .haunt/state/continue-here.md 2>/dev/null
```

**If file exists and is recent (< 24 hours):**
1. Read `.haunt/state/continue-here.md`
2. Show user: "Found session handoff from [timestamp]. Resume [brief description]?"
3. If yes → Follow handoff instructions
4. If no → Proceed with normal startup

**If file doesn't exist or is stale:**
- Proceed with normal session startup (see `gco-session-startup` for full protocol)

## Why This Matters

Session handoffs preserve:
- Mental context from previous session
- Decisions already made
- Work already completed
- Known blockers/gotchas

Skipping the check = wasted tokens re-discovering context.

## Non-Negotiable

**This check happens FIRST** - before responding to user, before reading roadmap, before anything.
