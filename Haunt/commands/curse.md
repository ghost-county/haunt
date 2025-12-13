# Curse Detection (Pattern Hunt)

Detect recurring anti-patterns haunting your codebase - the "curses" that keep appearing despite your best efforts.

## Pattern Hunt: $ARGUMENTS

### Available Modes

| Mode | Description | When to Use |
|------|-------------|-------------|
| `default` | Quick pattern scan (last 30 days, top 10 patterns) | Weekly check-ins |
| `--hunt` | Deep pattern analysis (configurable depth) | Investigating persistent issues |

### Execution

Based on the requested mode:

#### Default Mode (`/curse`)

Run a quick pattern detection scan with standard parameters:

```bash
bash Haunt/scripts/rituals/pattern-hunt-weekly.sh --interactive
```

This will:
1. Collect signals from git history (last 30 days)
2. Analyze patterns using AI
3. Prompt for approval before generating tests
4. Generate defeat tests for approved patterns
5. Update pre-commit hooks and agent memory
6. Create comprehensive report in `.haunt/progress/`

#### Hunt Mode (`/curse --hunt`)

Run an intensive pattern hunt with custom parameters. Ask the user for:

- **Days to analyze** (default: 60)
- **Top N patterns** (default: 15)
- **Auto-approve?** (default: interactive)

Then execute:

```bash
bash Haunt/scripts/rituals/pattern-hunt-weekly.sh --days <N> --top-n <M> [--auto]
```

### Output Format

Present findings in a haunting narrative:

```
🌑 CURSE DETECTION RESULTS 🌑

Patterns Found: <count>
Most Haunting: <pattern-name>

📜 CURSES IDENTIFIED:
1. <Pattern Name> - <Severity>
   Occurrences: <count>
   Last Seen: <date>

2. <Pattern Name> - <Severity>
   Occurrences: <count>
   Last Seen: <date>

⚗️ EXORCISM RITUALS PREPARED:
- <test-file-1>
- <test-file-2>

📊 Full Report: .haunt/progress/weekly-refactor-YYYY-MM-DD.md

Next: Run `/exorcise <pattern-name>` to banish a specific curse
```

### Quick Actions

After pattern detection:

- **Review findings**: Read the generated report
- **Test patterns**: `pytest .haunt/tests/patterns/ -v`
- **Exorcise specific curse**: `/exorcise <pattern-name>`
- **Verify hooks**: `pre-commit run --all-files`

### Notes

- Pattern detection is most effective when run weekly
- The `--hunt` mode is resource-intensive - reserve for deep investigations
- All detected patterns are logged to agent memory automatically
- Defeat tests are added to pre-commit hooks to prevent pattern recurrence
