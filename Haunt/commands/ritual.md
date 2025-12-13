# Ritual (Daily Scripts Command)

Execute Ghost County daily ritual scripts. These recurring workflows maintain project health and momentum.

## Ritual: $ARGUMENTS

### Available Rituals

| Ritual | Purpose | Frequency | Script |
|--------|---------|-----------|--------|
| `morning` | Morning review - roadmap status, test health, work focus | Daily | `morning-review.sh` |
| `evening` | Evening handoff - session summary, progress report | Daily | `evening-handoff.sh` |
| `weekly` | Midnight hour - deep weekly reflection and planning | Weekly | `midnight-hour.sh` |

### Execution

**Beginning the ritual...**

Based on the requested ritual type, execute the appropriate script from `Haunt/scripts/rituals/`:

#### Morning Ritual
```bash
bash Haunt/scripts/rituals/morning-review.sh
```

Provides:
- Git activity (last 24h)
- Roadmap progress tracking
- Test suite status
- Project health score
- Infrastructure checks
- Recommendations for the day

#### Evening Ritual
```bash
bash Haunt/scripts/rituals/evening-handoff.sh
```

Provides:
- Session summary (commits, files changed)
- Completed work overview
- Infrastructure status
- Next session preparation

#### Weekly Ritual
```bash
bash Haunt/scripts/rituals/midnight-hour.sh
```

Provides:
- Deep weekly reflection
- Commit pattern analysis
- Agent memory consolidation
- Strategic planning insights

### Usage

- `/ritual morning` - Run morning review
- `/ritual evening` - Run evening handoff
- `/ritual weekly` - Run midnight hour weekly reflection
- `/ritual` (no argument) - Show available rituals

### Output

After execution completes, display:

**The ritual is complete.**

Include a summary of the key findings from the script output.
