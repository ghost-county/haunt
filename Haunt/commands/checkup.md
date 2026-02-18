# Checkup (Health Verification)

Verify that dev guardrails are properly deployed.

## Usage

```bash
/checkup              # Full health check
/checkup --quick      # Quick verification (rules only)
```

## Health Check Sequence

### 1. Rules Check

Verify rules are deployed to `~/.claude/rules/`:

**Expected GCO rules (5):**
- `gco-communication.md`
- `gco-completion-checklist.md`
- `gco-decisions.md`
- `gco-ui-testing-reminder.md`
- `gco-visual-verification.md`

**Expected personal rules (3):**
- `familiar-adhd-patterns.md`
- `familiar-user-profile.md`
- `username-correction.md`

```bash
RULES_DIR="$HOME/.claude/rules"
GCO_COUNT=$(ls "$RULES_DIR"/gco-*.md 2>/dev/null | wc -l | tr -d ' ')
TOTAL_COUNT=$(ls "$RULES_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Rules: $GCO_COUNT gco rules, $TOTAL_COUNT total"
```

### 2. Skills Check

Verify skills are deployed to `~/.claude/skills/`:

**Expected GCO skills (~14):**
- `gco-code-review`, `gco-commit-conventions`, `gco-code-patterns`
- `gco-tdd-workflow`, `gco-playwright-tests`, `gco-ui-testing`, `gco-testing-mindset`
- `gco-secure-coding`, `gco-python-standards`, `gco-react-standards`, `gco-ui-design`
- `gco-task-decomposition`, `gco-requirements-development`, `gco-context7-usage`

```bash
SKILLS_DIR="$HOME/.claude/skills"
GCO_SKILLS=$(ls -d "$SKILLS_DIR"/gco-*/ 2>/dev/null | wc -l | tr -d ' ')
echo "Skills: $GCO_SKILLS gco skills deployed"
```

### 3. Commands Check

Verify commands are deployed to `~/.claude/commands/`:

**Expected commands (3):**
- `ship.md`
- `qa.md`
- `checkup.md`

```bash
COMMANDS_DIR="$HOME/.claude/commands"
CMD_COUNT=$(ls "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Commands: $CMD_COUNT deployed"
```

### 4. MCP Server Check

Verify MCP servers are configured:

```bash
# Check Claude Code settings for MCP
MCP_CONFIG="$HOME/.claude/settings.json"
if [ -f "$MCP_CONFIG" ]; then
    echo "MCP: Settings file found"
else
    echo "MCP: No settings file (check Claude Code config)"
fi
```

## Output Format

```
CHECKUP COMPLETE

Rules: 5/5 gco rules, 8/8 total
Skills: 14 gco skills deployed
Commands: 3/3 deployed
MCP: context7 configured

All systems operational.
```

## Quick Mode (`/checkup --quick`)

Only checks rules:
```
QUICK CHECKUP

Rules: 5/5 gco rules, 8/8 total
```

## If Issues Found

```
Setup required:
  cd /path/to/haunt
  bash Haunt/scripts/setup-haunt.sh
```
