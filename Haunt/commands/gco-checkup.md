# Checkup (Haunt Health Verification)

Verify that Haunt framework is properly installed and the spirits are responding to Ghost County protocols.

## Usage

```bash
/checkup              # Full health check
/checkup --quick      # Quick verification (rules + agents only)
/checkup --verbose    # Detailed diagnostic output
```

## Health Check Sequence

The checkup performs six verification phases:

### 1. Rules Adherence Check

**What it checks:**
- Rules directory exists: `~/.claude/rules/`
- Expected GCO rules are present
- Rules are properly formatted

**Expected Rules:**
- `gco-assignment-lookup.md`
- `gco-commit-conventions.md`
- `gco-completion-checklist.md`
- `gco-file-conventions.md`
- `gco-framework-changes.md`
- `gco-roadmap-format.md`
- `gco-session-startup.md`
- `gco-status-updates.md`

**Verification:**
```bash
RULES_DIR="$HOME/.claude/rules"
EXPECTED_RULES=8

if [ -d "$RULES_DIR" ]; then
    FOUND_RULES=$(ls "$RULES_DIR"/gco-*.md 2>/dev/null | wc -l)
    if [ "$FOUND_RULES" -eq "$EXPECTED_RULES" ]; then
        echo "✅ Rules: $FOUND_RULES/$EXPECTED_RULES loaded"
    else
        echo "⚠️ Rules: $FOUND_RULES/$EXPECTED_RULES loaded (missing $(($EXPECTED_RULES - $FOUND_RULES)))"
    fi
else
    echo "❌ Rules: Directory not found"
fi
```

### 2. Skills Availability Check

**What it checks:**
- Skills directory exists: `~/.claude/skills/`
- Expected GCO skills are present
- SKILL.md files are properly formatted

**Expected Skills:**
- `gco-code-patterns/`
- `gco-commit-conventions/`
- `gco-context7-usage/`
- `gco-coven-mode/`
- `gco-feature-contracts/`
- `gco-pattern-defeat/`
- `gco-roadmap-workflow/`
- `gco-session-startup/`
- `gco-tdd-workflow/`
- `gco-witching-hour/`
- Plus any additional GCO skills

**Verification:**
```bash
SKILLS_DIR="$HOME/.claude/skills"

if [ -d "$SKILLS_DIR" ]; then
    FOUND_SKILLS=$(ls -d "$SKILLS_DIR"/gco-*/ 2>/dev/null | wc -l)
    VALID_SKILLS=0

    for skill_dir in "$SKILLS_DIR"/gco-*/; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            VALID_SKILLS=$((VALID_SKILLS + 1))
        fi
    done

    echo "✅ Skills: $VALID_SKILLS/$FOUND_SKILLS available"
else
    echo "❌ Skills: Directory not found"
fi
```

### 3. MCP Server Connectivity Check

**What it checks:**
- MCP configuration file exists: `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)
- Expected MCP servers are configured
- Servers are accessible (optional deep check)

**Expected MCP Servers:**
- `context7` - Library documentation lookup
- `agent_memory` - Agent memory persistence
- `playwright` - Browser automation (optional)

**Verification:**
```bash
# macOS path
MCP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# Linux path (alternative)
if [ ! -f "$MCP_CONFIG" ]; then
    MCP_CONFIG="$HOME/.config/Claude/claude_desktop_config.json"
fi

if [ -f "$MCP_CONFIG" ]; then
    # Check for MCP servers in config
    CONTEXT7=$(grep -c "context7" "$MCP_CONFIG" || echo 0)
    MEMORY=$(grep -c "agent_memory" "$MCP_CONFIG" || echo 0)
    PLAYWRIGHT=$(grep -c "playwright" "$MCP_CONFIG" || echo 0)

    CONNECTED=0
    SERVERS=""

    if [ "$CONTEXT7" -gt 0 ]; then
        CONNECTED=$((CONNECTED + 1))
        SERVERS="$SERVERS context7"
    fi

    if [ "$MEMORY" -gt 0 ]; then
        CONNECTED=$((CONNECTED + 1))
        SERVERS="$SERVERS agent_memory"
    fi

    if [ "$PLAYWRIGHT" -gt 0 ]; then
        CONNECTED=$((CONNECTED + 1))
        SERVERS="$SERVERS playwright"
    fi

    if [ "$CONNECTED" -ge 2 ]; then
        echo "✅ MCP:$SERVERS connected ($CONNECTED/3)"
    elif [ "$CONNECTED" -eq 1 ]; then
        echo "⚠️ MCP:$SERVERS connected ($CONNECTED/3 - some servers missing)"
    else
        echo "❌ MCP: No servers configured"
    fi
else
    echo "⚠️ MCP: Configuration file not found"
fi
```

### 4. Agent Deployment Verification

**What it checks:**
- Agents directory exists: `~/.claude/agents/`
- Expected GCO agents are present
- Agents have valid YAML frontmatter

**Expected Core Agents:**
- `gco-dev.md`
- `gco-research.md`
- `gco-code-reviewer.md`
- `gco-project-manager.md`
- `gco-release-manager.md`
- Plus variant agents (gco-research-analyst.md, gco-code-reviewer-readonly.md, etc.)

**Verification:**
```bash
AGENTS_DIR="$HOME/.claude/agents"

if [ -d "$AGENTS_DIR" ]; then
    FOUND_AGENTS=$(ls "$AGENTS_DIR"/gco-*.md 2>/dev/null | wc -l)
    VALID_AGENTS=0

    for agent_file in "$AGENTS_DIR"/gco-*.md; do
        # Check for valid YAML frontmatter
        if head -n 5 "$agent_file" | grep -q "^---$"; then
            VALID_AGENTS=$((VALID_AGENTS + 1))
        fi
    done

    if [ "$VALID_AGENTS" -ge 5 ]; then
        echo "✅ Agents: $VALID_AGENTS/$FOUND_AGENTS deployed"
    else
        echo "⚠️ Agents: $VALID_AGENTS/$FOUND_AGENTS deployed (expected at least 5 core agents)"
    fi
else
    echo "❌ Agents: Directory not found"
fi
```

### 5. Directory Structure Validation

**What it checks:**
- `.haunt/` project directory exists
- Required subdirectories are present
- Roadmap file exists

**Expected Directories:**
- `.haunt/plans/` - Roadmap and requirements
- `.haunt/completed/` - Archived work
- `.haunt/progress/` - Session tracking
- `.haunt/tests/` - SDLC tests
- `.haunt/docs/` - Documentation

**Verification:**
```bash
HAUNT_DIR=".haunt"

if [ -d "$HAUNT_DIR" ]; then
    MISSING_DIRS=""

    [ ! -d "$HAUNT_DIR/plans" ] && MISSING_DIRS="$MISSING_DIRS plans"
    [ ! -d "$HAUNT_DIR/completed" ] && MISSING_DIRS="$MISSING_DIRS completed"
    [ ! -d "$HAUNT_DIR/progress" ] && MISSING_DIRS="$MISSING_DIRS progress"
    [ ! -d "$HAUNT_DIR/tests" ] && MISSING_DIRS="$MISSING_DIRS tests"
    [ ! -d "$HAUNT_DIR/docs" ] && MISSING_DIRS="$MISSING_DIRS docs"

    if [ -z "$MISSING_DIRS" ]; then
        if [ -f "$HAUNT_DIR/plans/roadmap.md" ]; then
            echo "✅ Directories: .haunt/ structure valid"
        else
            echo "⚠️ Directories: Structure exists, roadmap.md missing"
        fi
    else
        echo "⚠️ Directories: Missing subdirectories:$MISSING_DIRS"
    fi
else
    echo "⚠️ Directories: .haunt/ not found (run in project root or initialize with /seance)"
fi
```

### 6. Commands Availability Check

**What it checks:**
- Commands directory exists: `~/.claude/commands/`
- Expected GCO commands are present
- Commands are properly formatted

**Expected Commands:**
- `gco-seance.md`
- `gco-summon.md`
- `gco-haunt.md`
- `gco-haunting.md`
- `gco-seer.md`
- `gco-exorcism.md`
- `gco-banish.md`
- `gco-ritual.md`
- `gco-cleanse.md`
- `gco-apparition.md`
- `gco-haunt-update.md`
- `gco-witching-hour.md`
- `gco-coven.md`
- `gco-checkup.md` (this command!)

**Verification:**
```bash
COMMANDS_DIR="$HOME/.claude/commands"

if [ -d "$COMMANDS_DIR" ]; then
    FOUND_COMMANDS=$(ls "$COMMANDS_DIR"/gco-*.md 2>/dev/null | wc -l)

    if [ "$FOUND_COMMANDS" -ge 13 ]; then
        echo "✅ Commands: $FOUND_COMMANDS slash commands available"
    else
        echo "⚠️ Commands: $FOUND_COMMANDS slash commands found (expected at least 13)"
    fi
else
    echo "❌ Commands: Directory not found"
fi
```

## Output Formats

### All Systems Operational

```
🏚️  HAUNT CHECKUP COMPLETE  🏚️

✅ Rules: 8/8 loaded
✅ Skills: 10/10 available
✅ MCP: context7 agent_memory connected (2/3)
✅ Agents: 7/7 deployed
✅ Directories: .haunt/ structure valid
✅ Commands: 14 slash commands available

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌙 The spirits are strong and responsive.
   Haunt is properly installed and operational.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
  /seance          # Start a new haunting
  /haunt           # View current status
  /summon dev      # Call forth a specific spirit
```

### Partial Issues Detected

```
🏚️  HAUNT CHECKUP COMPLETE  🏚️

✅ Rules: 8/8 loaded
✅ Skills: 10/10 available
⚠️ MCP: context7 connected (1/3 - some servers missing)
✅ Agents: 7/7 deployed
⚠️ Directories: .haunt/ not found (run in project root)
✅ Commands: 14 slash commands available

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ The spirits are present but weakened.
   Some components need attention.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Issues detected:
1. MCP servers partially configured
   → Install agent_memory and playwright MCP servers
   → See: Haunt/docs/BROWSER-MCP-SETUP.md

2. .haunt/ directory not found
   → Run this command from project root
   → Or initialize with: /seance

Troubleshooting:
  bash Haunt/scripts/setup-haunt.sh --verify
  cat Haunt/SETUP-GUIDE.md
```

### Critical Failures

```
🏚️  HAUNT CHECKUP COMPLETE  🏚️

❌ Rules: Directory not found
❌ Skills: Directory not found
⚠️ MCP: Configuration file not found
❌ Agents: Directory not found
⚠️ Directories: .haunt/ not found
❌ Commands: Directory not found

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💀 The spirits are silent. Haunt is not installed.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Installation required:
  cd /path/to/ghost-county
  bash Haunt/scripts/setup-haunt.sh

Documentation:
  cat Haunt/SETUP-GUIDE.md
  cat Haunt/QUICK-REFERENCE.md
```

## Mode-Specific Behavior

### Quick Mode (`/checkup --quick`)

Only checks critical components:
1. Rules (8 files)
2. Agents (5+ files)

Output is condensed:
```
🏚️  QUICK CHECKUP  🏚️

✅ Rules: 8/8 loaded
✅ Agents: 7/7 deployed

The core spirits are present.
```

### Verbose Mode (`/checkup --verbose`)

Includes detailed diagnostics:
- List of missing files by category
- File paths for all checked components
- MCP server configuration details
- Recommendations for each issue

Example verbose output addition:
```
VERBOSE DIAGNOSTICS:

Rules found:
  ~/.claude/rules/gco-assignment-lookup.md
  ~/.claude/rules/gco-commit-conventions.md
  ~/.claude/rules/gco-completion-checklist.md
  ... (5 more)

Agents found:
  ~/.claude/agents/gco-dev.md
  ~/.claude/agents/gco-research.md
  ... (5 more)

MCP Configuration:
  Config file: ~/Library/Application Support/Claude/claude_desktop_config.json
  Servers configured: context7, agent_memory
  Missing servers: playwright (optional)
```

## Implementation Notes

### Bash Script Approach

Create a helper script `Haunt/scripts/checkup.sh` that performs the actual checks:

```bash
#!/bin/bash
# Haunt framework health check
# Usage: bash Haunt/scripts/checkup.sh [--quick|--verbose]

set -e

MODE="${1:-normal}"
VERBOSE=false
QUICK=false

case "$MODE" in
    --quick)
        QUICK=true
        ;;
    --verbose)
        VERBOSE=true
        ;;
esac

# [Implementation of all 6 check phases above]
# Output results in Ghost County themed format
```

### Claude Code Integration

The `/checkup` command invokes the bash script:

```bash
bash Haunt/scripts/checkup.sh "$@"
```

## Exit Codes

The checkup script returns meaningful exit codes:

- **0** - All systems operational (all checks ✅)
- **1** - Partial issues detected (some ⚠️ warnings)
- **2** - Critical failures (any ❌ errors)

## Troubleshooting

### Rules/Skills/Agents/Commands Not Found

**Cause:** Haunt not installed or setup script not run

**Fix:**
```bash
cd /path/to/ghost-county
bash Haunt/scripts/setup-haunt.sh
```

### MCP Servers Not Configured

**Cause:** MCP servers not installed or not added to Claude Code config

**Fix:**
```bash
# Install MCP servers
npm install -g @modelcontextprotocol/server-context7
npm install -g @modelcontextprotocol/server-memory

# Configure in Claude Code settings
# See: Haunt/docs/BROWSER-MCP-SETUP.md
```

### .haunt/ Directory Not Found

**Cause:** Command run outside project root or project not initialized

**Fix:**
```bash
# Run from project root
cd /path/to/your/project

# Or initialize with seance
/seance "Build a task management app"
```

### Partial File Counts

**Cause:** Some files missing from deployment

**Fix:**
```bash
# Re-run setup script
bash Haunt/scripts/setup-haunt.sh

# Or check for manual modifications
ls -la ~/.claude/rules/gco-*
ls -la ~/.claude/agents/gco-*
ls -la ~/.claude/skills/gco-*
ls -la ~/.claude/commands/gco-*
```

## See Also

- `/haunt-update` - Check for Haunt framework updates
- `bash Haunt/scripts/setup-haunt.sh --verify` - Verify installation
- `Haunt/SETUP-GUIDE.md` - Complete setup documentation
- `Haunt/QUICK-REFERENCE.md` - Framework quick reference
