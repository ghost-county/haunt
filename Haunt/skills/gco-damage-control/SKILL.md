---
name: gco-damage-control
description: Deletion protection via Claude Code PreToolUse hooks. Invoke when discussing hook configuration, patterns.yaml customization, or troubleshooting damage control.
---

# Damage Control Hooks

Protection against destructive operations through PreToolUse hooks that intercept Bash, Edit, and Write tool calls.

## Purpose

Prevent catastrophic accidents by blocking dangerous operations BEFORE they execute:
- Root/home directory deletion (`rm -rf /`, `rm -rf ~`)
- Wildcard deletion (`rm -rf *`)
- Access to secrets directories (`~/.ssh/`, `~/.aws/`, `~/.gnupg/`)
- Deletion of critical project paths (`.git/`, `.haunt/plans/`, `src/`)
- Insecure permission changes (`chmod 777`)
- Unguarded SQL operations (`DELETE FROM table;`)

**Design Philosophy:** Deletion protection, not access control. User explicitly wants full read/write/edit access to project files (including `.env`, `credentials.json`). Hooks only protect against accidental destruction of critical paths.

## When to Invoke

- Configuring hook behavior for new projects
- Customizing patterns.yaml for project-specific needs
- Troubleshooting blocked commands
- Understanding why a command was blocked
- Adding new protection patterns
- Debugging hook failures

## Architecture

### PreToolUse Hooks

Claude Code supports PreToolUse hooks that intercept tool calls before execution. Three hooks protect against destructive operations:

| Hook | Tool | Purpose |
|------|------|---------|
| `bash-tool-damage-control.py` | Bash | Block dangerous bash commands |
| `edit-tool-damage-control.py` | Edit | Prevent editing protected paths |
| `write-tool-damage-control.py` | Write | Prevent writing to protected paths |

### Exit Codes

Hooks communicate via exit codes:

| Exit Code | Meaning | Action |
|-----------|---------|--------|
| `0` | ALLOW | Tool executes normally |
| `2` | BLOCK | Tool execution prevented, error shown |
| JSON output | ASK | User prompted for confirmation |

### Hook Execution Flow

```
User/Agent Issues Command
         |
         v
Claude Code Intercepts
         |
         v
PreToolUse Hook Runs
         |
    +----+----+
    |         |
   EXIT 0    EXIT 2
  (ALLOW)   (BLOCK)
    |         |
    v         v
Execute    Show Error
Command    & Cancel
```

**ASK Flow:**
```
PreToolUse Hook Runs
         |
         v
Prints JSON to stdout:
{
  "decision": "ask",
  "message": "Reason..."
}
         |
         v
Claude Code Prompts User
         |
    +----+----+
    |         |
   YES       NO
    |         |
    v         v
Execute    Cancel
Command
```

## patterns.yaml Reference

Single source of truth for all protection rules. Located at `Haunt/hooks/damage-control/patterns.yaml`.

### Structure

```yaml
# Dangerous bash command patterns
bashToolPatterns:
  - pattern: 'regex'        # Python regex pattern
    reason: 'explanation'   # Why it's dangerous
    ask: true|false         # Prompt vs block

# No access whatsoever (secrets/credentials)
zeroAccessPaths:
  - ~/.ssh/
  - ~/.aws/
  - ~/.gnupg/

# Read allowed, modifications blocked (currently empty)
readOnlyPaths: []

# Read/write/edit allowed, delete blocked
noDeletePaths:
  - .git/
  - .haunt/plans/
  - src/
```

### bashToolPatterns

Regex patterns matched against bash commands. Supports BLOCK or ASK actions.

**Examples:**

```yaml
bashToolPatterns:
  # BLOCK: Root filesystem deletion (catastrophic)
  - pattern: 'rm\s+-rf\s+/$'
    reason: 'Attempting to delete root filesystem - BLOCKED'
    ask: false

  # BLOCK: Wildcard deletion (dangerous)
  - pattern: 'rm\s+-rf\s+\*'
    reason: 'Wildcard deletion can destroy entire directory - BLOCKED'
    ask: false

  # ASK: Specific path deletion (might be intentional)
  - pattern: 'rm\s+-rf\s+[^\s*~/$]'
    reason: 'Recursive deletion of specific path - confirm before proceeding'
    ask: true

  # BLOCK: Insecure permissions
  - pattern: 'chmod\s+(777|666)'
    reason: 'Setting insecure permissions (world-writable) - BLOCKED'
    ask: false

  # BLOCK: Unguarded SQL DELETE
  - pattern: 'DELETE\s+FROM\s+\w+\s*;'
    reason: 'SQL DELETE without WHERE clause will delete all rows - BLOCKED'
    ask: false
```

### zeroAccessPaths

Absolute no-access paths containing secrets. ALL operations blocked (Bash, Edit, Write).

**Current defaults:**

```yaml
zeroAccessPaths:
  - ~/.ssh/              # SSH private keys
  - ~/.aws/              # AWS credentials
  - ~/.gnupg/            # GPG private keys
```

**User explicitly excluded:**
- `.env` files (project-specific configuration)
- `credentials.json` (service account keys)

### readOnlyPaths

Read allowed, modifications blocked. Currently EMPTY - user explicitly wants full edit access.

**Future use cases:**
```yaml
readOnlyPaths:
  - /etc/hosts           # System files
  - Haunt/docs/          # Framework docs (if read-only desired)
```

### noDeletePaths

Critical project paths that should never be deleted. Read/write/edit operations allowed.

**Current defaults:**

```yaml
noDeletePaths:
  # Version control
  - .git/

  # Project SDLC artifacts
  - .haunt/plans/
  - .haunt/completed/

  # Common source directories
  - src/
  - lib/
  - app/
  - packages/

  # Haunt framework source
  - Haunt/agents/
  - Haunt/rules/
  - Haunt/skills/
  - Haunt/scripts/
  - Haunt/docs/
  - Haunt/hooks/

  # Deployed global artifacts
  - ~/.claude/rules/
  - ~/.claude/agents/
  - ~/.claude/skills/
  - ~/.claude/commands/
  - ~/.claude/hooks/
```

## Customization

### Adding Bash Command Patterns

Edit `patterns.yaml` and add to `bashToolPatterns`:

```yaml
bashToolPatterns:
  # Your new pattern
  - pattern: 'git\s+push\s+--force'
    reason: 'Force push can destroy remote history - confirm first'
    ask: true
```

**Pattern syntax:**
- Python regex (not bash glob)
- Case-insensitive matching
- Matches anywhere in command string

### Adding Protected Paths

**For secrets (zero access):**
```yaml
zeroAccessPaths:
  - ~/.kube/config       # Kubernetes credentials
  - ~/.docker/config.json  # Docker registry auth
```

**For no-delete protection:**
```yaml
noDeletePaths:
  - tests/               # Test directory
  - docs/                # Documentation
  - .github/             # CI/CD workflows
```

### Project-Specific Customization

When using hooks in a project:

1. Copy `patterns.yaml` to project: `cp Haunt/hooks/damage-control/patterns.yaml .haunt/hooks/patterns.yaml`
2. Customize project-specific patterns
3. Update hook scripts to load project patterns first (fallback to global)

**Future enhancement:** Hook scripts could check for project-local `patterns.yaml` before falling back to global.

## Installation

### Via Setup Script (Recommended)

```bash
# Install Haunt with damage control hooks
bash Haunt/scripts/setup-haunt.sh --with-hooks

# Install hooks only (skip if already installed)
bash Haunt/scripts/setup-haunt.sh --with-hooks --agents-only
```

**What it does:**
1. Copies hook scripts to `~/.claude/hooks/damage-control/`
2. Copies `patterns.yaml` to `~/.claude/hooks/damage-control/`
3. Merges hook configuration into `~/.claude/settings.json`
4. Verifies UV installation (required for hooks)

### Manual Installation

**Step 1: Copy hooks to global location**

```bash
mkdir -p ~/.claude/hooks/
cp -r Haunt/hooks/damage-control ~/.claude/hooks/
```

**Step 2: Merge settings**

Edit `~/.claude/settings.json` and add:

```json
{
  "preToolUseHooks": {
    "Bash": [
      {
        "command": "~/.claude/hooks/damage-control/bash-tool-damage-control.py",
        "timeout": 2000
      }
    ],
    "Edit": [
      {
        "command": "~/.claude/hooks/damage-control/edit-tool-damage-control.py",
        "timeout": 2000
      }
    ],
    "Write": [
      {
        "command": "~/.claude/hooks/damage-control/write-tool-damage-control.py",
        "timeout": 2000
      }
    ]
  }
}
```

**Step 3: Verify UV installed**

Hooks use UV for Python dependency management:

```bash
uv --version
# If not found, install:
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Verification

### Test Bash Hook

**Test BLOCK (should exit 2):**

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | \
  uv run ~/.claude/hooks/damage-control/bash-tool-damage-control.py
echo "Exit code: $?"
# Expected: Exit code 2, stderr message about blocking
```

**Test ASK (should print JSON):**

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/specific-path"}}' | \
  uv run ~/.claude/hooks/damage-control/bash-tool-damage-control.py
echo "Exit code: $?"
# Expected: Exit code 0, JSON with "decision": "ask"
```

**Test ALLOW (should exit 0):**

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' | \
  uv run ~/.claude/hooks/damage-control/bash-tool-damage-control.py
echo "Exit code: $?"
# Expected: Exit code 0, no output
```

### Test Edit Hook

**Test BLOCK (zero-access path):**

```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"~/.ssh/id_rsa"}}' | \
  uv run ~/.claude/hooks/damage-control/edit-tool-damage-control.py
echo "Exit code: $?"
# Expected: Exit code 2, stderr about zero-access path
```

**Test ALLOW (normal project file):**

```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"./README.md"}}' | \
  uv run ~/.claude/hooks/damage-control/edit-tool-damage-control.py
echo "Exit code: $?"
# Expected: Exit code 0, no output
```

### Test Write Hook

**Test BLOCK (zero-access path):**

```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"~/.aws/credentials"}}' | \
  uv run ~/.claude/hooks/damage-control/write-tool-damage-control.py
echo "Exit code: $?"
# Expected: Exit code 2, stderr about zero-access path
```

**Test ALLOW (normal project file):**

```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"./test.txt"}}' | \
  uv run ~/.claude/hooks/damage-control/write-tool-damage-control.py
echo "Exit code: $?"
# Expected: Exit code 0, no output
```

## Troubleshooting

### Hook Not Firing

**Symptom:** Dangerous commands execute without being blocked.

**Diagnosis:**

1. Check settings.json:
   ```bash
   cat ~/.claude/settings.json | grep -A 10 preToolUseHooks
   ```

2. Verify hooks exist:
   ```bash
   ls -la ~/.claude/hooks/damage-control/
   ```

3. Test hook manually (see Verification section above)

**Solutions:**
- Reinstall: `bash Haunt/scripts/setup-haunt.sh --with-hooks`
- Check JSON syntax in settings.json (no trailing commas)
- Restart Claude Code (settings reload)

### UV Not Found

**Symptom:** Hook fails with "uv: command not found"

**Diagnosis:**
```bash
uv --version
# If error: UV not installed
```

**Solution:**
```bash
# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add to PATH (if not automatic)
export PATH="$HOME/.cargo/bin:$PATH"

# Verify
uv --version
```

### Permission Denied

**Symptom:** Hook fails with "Permission denied"

**Diagnosis:**
```bash
ls -la ~/.claude/hooks/damage-control/*.py
# Check if executable bit set
```

**Solution:**
```bash
chmod +x ~/.claude/hooks/damage-control/*.py
```

### Hook Timeout

**Symptom:** Hook takes too long, command times out

**Diagnosis:** Default timeout is 2000ms. Complex pattern matching might exceed this.

**Solution:** Increase timeout in settings.json:
```json
{
  "preToolUseHooks": {
    "Bash": [
      {
        "command": "~/.claude/hooks/damage-control/bash-tool-damage-control.py",
        "timeout": 5000
      }
    ]
  }
}
```

### patterns.yaml Not Found

**Symptom:** Hook fails with "ERROR: patterns.yaml not found"

**Diagnosis:**
```bash
ls -la ~/.claude/hooks/damage-control/patterns.yaml
# If missing: patterns.yaml not deployed
```

**Solution:**
```bash
cp Haunt/hooks/damage-control/patterns.yaml ~/.claude/hooks/damage-control/
```

### Command Blocked Incorrectly

**Symptom:** Safe command blocked by hook

**Diagnosis:**
1. Check which pattern matched:
   ```bash
   echo '{"tool_name":"Bash","tool_input":{"command":"YOUR_COMMAND"}}' | \
     uv run ~/.claude/hooks/damage-control/bash-tool-damage-control.py
   ```
2. Review stderr for reason

**Solution:**
- Edit `patterns.yaml` to refine regex pattern
- Add exclusion pattern if needed
- Report issue if pattern is overly broad

### Bypassing Hooks (Emergency)

**For development/testing only:**

1. Temporarily disable in settings.json:
   ```json
   {
     "preToolUseHooks": {}
   }
   ```

2. Restart Claude Code

3. **CRITICAL:** Re-enable hooks after debugging

**Never bypass in production.**

## Examples

### Example 1: Blocking Root Deletion

**Command:**
```bash
rm -rf /
```

**Hook Action:**
- Pattern matched: `rm\s+-rf\s+/$`
- Action: BLOCK (exit 2)
- Reason: "Attempting to delete root filesystem - BLOCKED"

**Result:** Command does not execute, user sees error message.

### Example 2: Asking for Confirmation

**Command:**
```bash
rm -rf ./old-backups/
```

**Hook Action:**
- Pattern matched: `rm\s+-rf\s+[^\s*~/$]`
- Action: ASK (JSON output)
- Reason: "Recursive deletion of specific path - confirm before proceeding"

**Result:** User prompted: "This command will recursively delete ./old-backups/. Proceed? [yes/no]"

### Example 3: Blocking Secret Access

**Command (Edit tool):**
```
Edit file_path="~/.ssh/id_rsa" old_string="..." new_string="..."
```

**Hook Action:**
- Path matched: `~/.ssh/`
- Action: BLOCK (exit 2)
- Reason: "Edit to ~/.ssh/id_rsa targets zero-access path (secrets/credentials)"

**Result:** Edit does not execute, user sees error about protected path.

### Example 4: Allowing Safe Commands

**Command:**
```bash
ls -la ~/.ssh/
```

**Hook Action:**
- No pattern matched (ls is safe, read-only operation)
- Action: ALLOW (exit 0)

**Result:** Command executes normally.

## Integration with Haunt Workflow

### Session Startup

Damage control hooks are transparent - agents don't need to check for them. Hooks intercept automatically.

### Error Handling

When hook blocks command:
1. Agent receives error message with reason
2. Agent should explain to user why blocked
3. Agent suggests alternative approach (if available)

**Example:**
```
User: "Delete all files in src/"
Agent: "Cannot execute `rm -rf src/` - this is a protected directory.
       Did you mean to delete a specific subdirectory? I can help with:
       - Removing specific files: rm src/deprecated-file.ts
       - Emptying directory: rm src/*.tmp
       - Creating backup first: mv src src.backup"
```

### Pattern Improvement

When hook blocks incorrectly:
1. Agent explains limitation
2. Agent suggests patterns.yaml edit
3. Agent can help refine regex pattern

**Example:**
```
User: "Why was my command blocked?"
Agent: "The hook matched pattern `rm\s+-rf\s+[^\s*~/$]` which blocks
       recursive deletion. This is a safety feature, but may be overly
       broad for your use case.

       To allow deletion of temp directories, edit patterns.yaml:

       - pattern: 'rm\s+-rf\s+(?!.*temp).*'
         reason: 'Allow temp directory deletion'
         ask: false
       "
```

## See Also

- `Haunt/hooks/damage-control/patterns.yaml` - Pattern definitions (source)
- `~/.claude/hooks/damage-control/` - Deployed hooks (global)
- `~/.claude/settings.json` - Hook configuration
- `Haunt/scripts/setup-haunt.sh` - Installation script
- Claude Code Docs: [PreToolUse Hooks](https://claude.ai/code/docs/hooks)
