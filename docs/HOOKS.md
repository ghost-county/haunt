# Haunt Hooks System

Claude Code hooks provide deterministic enforcement of Haunt workflow rules. Unlike skill/rule instructions which Claude may occasionally ignore, hooks execute as shell scripts that can block tool calls.

## Overview

Hooks are deployed by `setup-haunt.sh` to:
- **Scripts:** `~/.claude/hooks/*.sh`
- **Configuration:** `~/.claude/settings.json`

## Available Hooks

### 1. Phase Enforcement (`phase-enforcement.sh`)

**Trigger:** `PreToolUse` on `Task` tool

**Purpose:** Ensures dev agents can only spawn during the SUMMONING phase of the Séance workflow.

**Behavior:**
- Allows: PM, Research, Code Reviewer agents (any phase)
- Allows: Dev agents when phase = SUMMONING
- Blocks: Dev agents when phase = SCRYING or BANISHING
- Allows: Dev agents when no phase file exists (not in séance)

**Phase file:** `.haunt/state/current-phase.txt`

### 2. File Location Enforcer (`file-location-enforcer.sh`)

**Trigger:** `PreToolUse` on `Write|Edit` tools

**Purpose:** Prevents Ghost County artifacts from being created outside `.haunt/`.

**Blocked patterns:**
- `roadmap`, `requirement`, `req-`
- `completed`, `progress`
- `pattern-test`, `defeat-test`
- `feature-contract`, `seance-`, `batch-`

**Example:**
- Blocked: `/project/roadmap.md`
- Allowed: `/project/.haunt/plans/roadmap.md`

### 3. Commit Validator (`commit-validator.sh`)

**Trigger:** `PreToolUse` on `Bash` tool

**Purpose:** Enforces `[REQ-XXX]` prefix on commit messages.

**Allowed exceptions:**
- Merge commits (start with `Merge`)
- Revert commits (start with `Revert`)
- WIP commits (start with `WIP`)
- Generated commits (contain `Generated`)

**Example:**
- Blocked: `git commit -m "Fix bug"`
- Allowed: `git commit -m "[REQ-123] Fix: Authentication bug"`

### 4. Completion Gate (`completion-gate.sh`)

**Trigger:** `PreToolUse` on `Edit` tool

**Purpose:** Prevents marking requirements complete (🟢) without test verification.

**Requirements:**
1. Run `verify-tests.sh REQ-XXX <type>` first
2. This creates `.haunt/progress/REQ-XXX-verified.txt`
3. Evidence file must be less than 1 hour old

**Workflow:**
```bash
# 1. Run tests
bash Haunt/scripts/verify-tests.sh REQ-123 frontend

# 2. Evidence created at .haunt/progress/REQ-123-verified.txt

# 3. Now you can mark complete
# Edit roadmap.md to change ⚪ → 🟢
```

## Configuration

Hooks are configured in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Task",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.claude/hooks/phase-enforcement.sh\"",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## Disabling Hooks

### Temporarily (single session)

```bash
HAUNT_HOOKS_DISABLED=1 claude
```

### Permanently

Remove or edit hook entries in `~/.claude/settings.json`.

### Per-hook disable

Not currently supported. Use global disable or edit settings.json.

## Troubleshooting

### "Phase violation" error

**Cause:** Attempting to spawn dev agent outside SUMMONING phase.

**Fix:**
1. Complete SCRYING (planning)
2. Present summoning prompt to user
3. Get approval, write "SUMMONING" to phase file
4. Then spawn dev agents

### "Location violation" error

**Cause:** Creating GCO artifact outside `.haunt/`.

**Fix:** Use correct paths:
- Roadmaps: `.haunt/plans/roadmap.md`
- Completed: `.haunt/completed/`
- Progress: `.haunt/progress/`

### "Commit convention violation" error

**Cause:** Commit message missing `[REQ-XXX]` prefix.

**Fix:** Use format: `[REQ-123] Action: Description`

### "Completion gate" error

**Cause:** Marking requirement 🟢 without test verification.

**Fix:**
```bash
bash Haunt/scripts/verify-tests.sh REQ-XXX frontend|backend|infrastructure
```

### Hook not running

**Check:**
1. Scripts executable: `ls -la ~/.claude/hooks/`
2. Configuration present: `cat ~/.claude/settings.json | jq .hooks`
3. jq installed: `which jq`

## Development

### Adding new hooks

1. Create script in `Haunt/hooks/new-hook.sh`
2. Add configuration to `Haunt/templates/settings.hooks.json`
3. Run `setup-haunt.sh` to deploy

### Hook script template

```bash
#!/bin/bash
set -euo pipefail

# Global disable check
if [[ "${HAUNT_HOOKS_DISABLED:-0}" == "1" ]]; then
    exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract tool input
PARAM=$(echo "$INPUT" | jq -r '.tool_input.param // ""')

# Your validation logic here
if [[ "$PARAM" == "invalid" ]]; then
    echo "Error message shown to Claude" >&2
    exit 2  # Blocking error
fi

exit 0  # Allow the tool call
```

### Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success - allow tool call |
| 2 | Blocking error - deny tool call, show stderr to Claude |
| Other | Non-blocking error - show to user only |

### Testing hooks locally

```bash
# Test with sample input
echo '{"tool_input":{"subagent_type":"gco-dev-backend"},"cwd":"/path/to/project"}' | \
  bash Haunt/hooks/phase-enforcement.sh
echo "Exit code: $?"
```

## See Also

- [Claude Code Hooks Documentation](https://docs.anthropic.com/claude-code/hooks)
- `gco-seance-enforcement.md` - Séance workflow rules
- `gco-file-conventions.md` - File location rules
- `gco-commit-conventions` - Commit format rules
- `gco-completion-checklist.md` - Completion requirements
