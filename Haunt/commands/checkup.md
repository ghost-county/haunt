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

**Expected GCO rules (6):**
- `gco-communication.md`
- `gco-completion-checklist.md`
- `gco-decisions.md`
- `gco-team-coordination.md`
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

**Expected GCO skills (~16):**
- `gco-code-review`, `gco-commit-conventions`, `gco-code-patterns`
- `gco-tdd-workflow`, `gco-playwright-tests`, `gco-ui-testing`, `gco-testing-mindset`
- `gco-secure-coding`, `gco-python-standards`, `gco-react-standards`, `gco-ui-design`
- `gco-task-decomposition`, `gco-requirements-development`, `gco-context7-usage`
- `gco-team-protocol`, `gco-seance-orchestration`

```bash
SKILLS_DIR="$HOME/.claude/skills"
GCO_SKILLS=$(ls -d "$SKILLS_DIR"/gco-*/ 2>/dev/null | wc -l | tr -d ' ')
echo "Skills: $GCO_SKILLS gco skills deployed"
```

### 3. Commands Check

Verify commands are deployed to `~/.claude/commands/`:

**Expected commands (4):**
- `seance.md`
- `ship.md`
- `qa.md`
- `checkup.md`

```bash
COMMANDS_DIR="$HOME/.claude/commands"
CMD_COUNT=$(ls "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Commands: $CMD_COUNT deployed"
```

### 4. Agents Check

Verify agents are deployed to `~/.claude/agents/`:

**Expected agents (4):**
- `gco-project-manager.md`
- `gco-dev.md`
- `gco-research.md`
- `gco-code-reviewer.md`

```bash
AGENTS_DIR="$HOME/.claude/agents"
AGENT_COUNT=$(ls "$AGENTS_DIR"/gco-*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Agents: $AGENT_COUNT gco agents deployed"
```

### 5. MCP Server Check

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

Rules: 6/6 gco rules, 9/9 total
Skills: 16 gco skills deployed
Commands: 4/4 deployed
Agents: 4/4 gco agents deployed
MCP: context7 configured

All systems operational.
```

## Quick Mode (`/checkup --quick`)

Only checks rules:
```
QUICK CHECKUP

Rules: 6/6 gco rules, 9/9 total
```

## If Issues Found

```
Setup required:
  cd /path/to/haunt
  bash Haunt/scripts/setup-haunt.sh
```
