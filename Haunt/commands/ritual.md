# Ritual (Maintenance Workflows)

Execute Ghost County maintenance rituals. These are recurring workflows that keep the haunting healthy.

## Ritual: $ARGUMENTS

### Available Rituals

| Ritual | Purpose | Frequency |
|--------|---------|-----------|
| `morning` | Morning seance - review roadmap, identify today's work | Daily |
| `evening` | Evening banishment - summarize progress, prepare handoff | Daily |
| `weekly` | Weekly refactor - code quality, agent improvements | Weekly |
| `pattern-hunt` | Hunt for recurring anti-patterns | Weekly |

### Execution

Based on the requested ritual, run the appropriate script:

- **morning**: `bash Haunt/scripts/rituals/morning-review.sh`
- **evening**: `bash Haunt/scripts/rituals/evening-handoff.sh`
- **weekly**: `bash Haunt/scripts/rituals/weekly-refactor.sh`
- **pattern-hunt**: `bash Haunt/scripts/rituals/pattern-hunt-weekly.sh`

If no ritual specified, show the list of available rituals.
