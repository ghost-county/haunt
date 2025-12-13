# Haunt Status (Framework Overview)

Display the current status of the Haunt framework - active work, agent assignments, recent completions, and available spirits.

**Alias**: `/haunt status`

## Show Framework Status

Read and present the current state from `.haunt/plans/roadmap.md`:

### Status Report Format

**The spirits report from the realm...**

#### 1. Current Focus
- Display the "Current Focus:" section goal
- Show the active batch/phase name

#### 2. Active Hauntings (🟡 In Progress)
For each 🟡 requirement:
```
🟡 REQ-XXX: [Title]
   Agent: [Agent type]
   Effort: [S/M]
   Blocked by: [Dependencies or "None"]
```

#### 3. Recently Manifested (🟢 Complete)
For each 🟢 in "Recently Completed" section:
```
🟢 REQ-XXX: [Title]
   Completed: [Date if present]
   Agent: [Agent type]
```

#### 4. Available Spirits
List all agent types available for summoning:
```
The following spirits await your call:
- gco-dev (Backend, Frontend, Infrastructure modes)
- gco-project-manager (Roadmap coordination)
- gco-research (Investigation and analysis)
- gco-code-reviewer (Code quality)
- gco-release-manager (Merge and deploy)
```

### Quick Actions

After viewing status:
- `/summon <agent> <task>` - Summon a specific spirit for work
- `/seance` - Begin orchestrated workflow
- `/haunting` - View full roadmap overview
- `/banish --all-complete` - Archive completed work

### Ghost County Theming

Use mystical language for status reports:

**Opening:**
"The spirits gather in the ethereal realm to report..."
"From beyond the veil, the hauntings reveal themselves..."

**Active Work:**
"Current hauntings in progress..."
"Spirits actively manifesting..."

**Completions:**
"Recently banished to the archives..."
"Spirits that have completed their task..."

**No Active Work:**
"The realm is quiet. No active hauntings detected."
"All spirits rest. Awaiting new summons."

Read the roadmap and present the framework status.
