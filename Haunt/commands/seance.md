# Conduct Séance (Workflow Orchestration)

Hold a séance to guide ideas through the complete Ghost County workflow: the three-part ritual of scrying (planning), summoning (execution), and reaping (archival).

## The Three-Part Ritual

```
🔮 Phase 1: Scrying   (Planning)   → /seance --scry    or --plan
👻 Phase 2: Summoning (Execution)  → /seance --summon  or --execute
🌾 Phase 3: Reaping   (Archival)   → /seance --reap    or --archive
```

**Mystical vs Normie:**
- **Mystical:** `--scry`, `--summon`, `--reap` (embrace the occult vibes)
- **Normie:** `--plan`, `--execute`, `--archive` (keep it practical)

## Usage Modes

### Mode 1: With Prompt
```bash
/seance "Add OAuth login support"
/seance Build a task management app
/seance Fix the authentication bug and add tests
```
Starts idea-to-roadmap workflow immediately with the provided prompt.

### Mode 2: Interactive (No Arguments + Existing Project)
```bash
/seance
```
In a repository with `.haunt/`:
- **[A] Add something new** — Run scrying for new idea/feature/bug
- **[B] Summon the spirits** — Run summoning for existing roadmap
- **Tell Claude what to do** — Custom input

### Mode 3: Interactive (No Arguments + New Project)
```bash
/seance
```
In a repository without `.haunt/`:
- Prompt: "What would you like to build?"
- Run full scrying workflow for new project

### Mode 4: Explicit Scrying (Planning)
```bash
/seance --scry "Add rate limiting to API"
/seance --plan "Implement caching layer"
```
**Purpose:** Transform raw idea into formal roadmap
**Output:** `.haunt/plans/roadmap.md` with sized, assigned requirements

### Mode 5: Explicit Summoning (Execution)
```bash
/seance --summon
/seance --execute
```
**Purpose:** Spawn agents for all ⚪ and 🟡 roadmap items
**Output:** Parallel agent execution working until 🟢 Complete

### Mode 6: Explicit Reaping (Archival)
```bash
/seance --reap
/seance --archive
```
**Purpose:** Archive completed work and clean roadmap
**Output:** Clean roadmap + archived history in `.haunt/completed/`

## Task: $ARGUMENTS

**Step 1: Parse Arguments and Detect Mode**

```python
import os

args = "$ARGUMENTS".strip()
has_haunt = os.path.exists(".haunt/")

# Check for explicit phase flags
if args in ["--scry", "--plan"]:
    mode = 4  # Explicit scrying
    prompt = ""  # Will prompt user for idea
elif args.startswith("--scry ") or args.startswith("--plan "):
    mode = 4  # Explicit scrying with idea
    prompt = args.split(None, 1)[1] if len(args.split(None, 1)) > 1 else ""
elif args in ["--summon", "--execute"]:
    mode = 5  # Explicit summoning
elif args in ["--reap", "--archive"]:
    mode = 6  # Explicit reaping
elif args:
    mode = 1  # With prompt - immediate workflow
elif has_haunt:
    mode = 2  # No args + existing - choice prompt
else:
    mode = 3  # No args + new - new project prompt
```

**Step 2: Execute Mode-Specific Flow**

Invoke the `gco-seance` skill with detected mode and arguments:

```
MODE: {mode}
ARGUMENTS: $ARGUMENTS
HAS_HAUNT: {has_haunt}
```

The skill will handle the appropriate flow based on mode.

## Complete Workflow Examples

### Full Ritual (Interactive)
```bash
$ /seance
> 🕯️ The spirits stir. What brings you to the veil?
> [A] Add something new
> [B] Summon the spirits

$ [Choose A]
> What would you like to add?

$ "Add OAuth login"
> 🔮 Scrying the future...
> [Planning happens...]
> Ready to summon the spirits? [yes/no]

$ yes
> 👻 The spirits rise...
> [Execution happens...]
> 🌾 Reaping the harvest...
> [Archival happens automatically...]
> ✅ OAuth login complete
```

### Partial Ritual (Explicit Phases)
```bash
# Just planning
$ /seance --scry "Add dark mode"
> 🔮 Scrying the future...
> ✅ Roadmap created at .haunt/plans/roadmap.md

# Later: Just execution
$ /seance --summon
> 👻 The spirits rise...
> [Agents work...]
> ✅ All requirements complete

# Later: Just cleanup
$ /seance --reap
> 🌾 Reaping the harvest...
> ✅ 5 requirements archived
```

### Quick Full Ritual (With Prompt)
```bash
$ /seance "Fix login bug and add tests"
> 🔮 Scrying the future...
> ✅ Requirements developed
> Ready to summon? [yes]
> 👻 The spirits rise...
> [Work happens...]
> 🌾 Reaping the harvest...
> ✅ Complete
```

## See Also

- **`Haunt/docs/SEANCE-EXPLAINED.md`** - Complete documentation and philosophy
- **`Haunt/docs/assets/seance-infographic.html`** - Visual guide
- **`/summon <agent>`** - Directly spawn a specific agent
- **`/banish --all`** - Quick archive (alias for `/seance --reap`)
- **`/haunting`** - View current active work
