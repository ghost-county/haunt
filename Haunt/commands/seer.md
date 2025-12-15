# Seer (Pattern Detection)

Divine recurring anti-patterns in your codebase - the hidden patterns that a seer reveals through their vision.

## Pattern Vision: $ARGUMENTS

### Available Modes

| Mode | Description | When to Use |
|------|-------------|-------------|
| `default` | Quick pattern scan (last 30 days, top 10 patterns) | Weekly check-ins |
| `--divine` | Deep pattern analysis (configurable depth) | Investigating persistent issues |

### Execution

Based on the requested mode:

#### Default Mode (`/seer`)

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

#### Divine Mode (`/seer --divine`)

Run an intensive pattern divination with custom parameters. Ask the user for:

- **Days to analyze** (default: 60)
- **Top N patterns** (default: 15)
- **Auto-approve?** (default: interactive)

Then execute:

```bash
bash Haunt/scripts/rituals/pattern-hunt-weekly.sh --days <N> --top-n <M> [--auto]
```

### Output Format

Present findings in a mystical narrative:

```
🔮 SEER'S VISION REVEALED 🔮

Patterns Seen: <count>
Most Prominent: <pattern-name>

📜 PATTERNS DIVINED:
1. <Pattern Name> - <Severity>
   Occurrences: <count>
   Last Seen: <date>

2. <Pattern Name> - <Severity>
   Occurrences: <count>
   Last Seen: <date>

⚗️ PROTECTIVE WARDS PREPARED:
- <test-file-1>
- <test-file-2>

📊 Full Vision: .haunt/progress/weekly-refactor-YYYY-MM-DD.md

Next: Run `/exorcism <pattern-name>` to ward against a specific pattern
```

### Quick Actions

After pattern detection:

- **Review findings**: Read the generated report
- **Test patterns**: `pytest .haunt/tests/patterns/ -v`
- **Ward against pattern**: `/exorcism <pattern-name>`
- **Verify hooks**: `pre-commit run --all-files`

### Notes

- Pattern divination is most effective when run weekly
- The `--divine` mode is resource-intensive - reserve for deep investigations
- All divined patterns are logged to agent memory automatically
- Defeat tests are added to pre-commit hooks to prevent pattern recurrence
