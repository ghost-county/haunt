# Ritual (Daily Scripts Command)

Run Ghost County daily ritual scripts to maintain project health and development momentum.

## Ritual Type: $ARGUMENTS

### Available Rituals

| Ritual | Purpose | Frequency | Script |
|--------|---------|-----------|--------|
| `morning` | Morning review - roadmap status, test health, work focus | Daily | `morning-review.sh` |
| `evening` | Evening handoff - session summary, progress report | Daily | `evening-handoff.sh` |
| `weekly` | Midnight hour - deep weekly reflection and planning | Weekly | `midnight-hour.sh` |

### Execution

Parse the ritual type from arguments and execute the corresponding script.

**Expected format:** `<ritual-type>`

**Example usage:**
- `/ritual morning` - Run morning review
- `/ritual evening` - Run evening handoff
- `/ritual weekly` - Run midnight hour weekly reflection
- `/ritual` (no argument) - Show available rituals

### Ritual Logic

1. **Parse ritual type** from first argument (case-insensitive)
2. **Validate ritual type** against available rituals
3. **Display opening message:** "Beginning the [morning/evening/weekly] ritual..."
4. **Execute script** from `Haunt/scripts/rituals/`:
   - `morning` → `bash Haunt/scripts/rituals/morning-review.sh`
   - `evening` → `bash Haunt/scripts/rituals/evening-handoff.sh`
   - `weekly` → `bash Haunt/scripts/rituals/midnight-hour.sh`
5. **Capture and summarize output**
6. **Display closing message:** "The ritual is complete."
7. **Show summary** of key findings

### Morning Ritual Output

The morning-review.sh script provides:
- Git activity (last 24 hours)
- Roadmap progress tracking (⚪ ⚫ 🟢 🔴 status)
- Current work focus (active and blocked items)
- Test suite status
- Agent memory recall (recent learnings)
- Infrastructure health (NATS, memory server, git status)
- Skill usage statistics
- Project health score (0-100%)
- Recommendations for the day

**Use this ritual** at session startup to understand project state before beginning work.

### Evening Ritual Output

The evening-handoff.sh script provides:
- Session summary (commits, files changed)
- Work completed today
- Infrastructure status check
- Preparation notes for next session
- Optional: Save handoff report to `.haunt/progress/handoff-{date}.md`

**Use this ritual** at session end to document progress and prepare for handoff.

### Weekly Ritual Output

The midnight-hour.sh script provides:
- Deep weekly reflection
- Commit pattern analysis (last 7 days)
- Roadmap progress overview
- Agent memory consolidation
- Strategic planning insights
- Pattern detection across sessions
- Memory archival and cleanup

**Use this ritual** weekly (typically Friday evening or Sunday) for strategic review and planning.

### Error Handling

**Unknown ritual type:**
```
🌫️ Unknown ritual: <input>

Available rituals:
- morning  - Daily morning review
- evening  - Daily evening handoff
- weekly   - Weekly reflection (midnight hour)

Example: /ritual morning
```

**No ritual specified:**
Display available rituals table and usage examples.

**Script execution failure:**
```
⚠️ Ritual interrupted: <error-message>

The spirits are restless... check script status:
<script-path>
```

### Example Invocation

If user types: `/ritual morning`

**Parsing:**
- Ritual type: `morning`
- Script: `Haunt/scripts/rituals/morning-review.sh`

**Output:**
```
Beginning the morning ritual...

[Execute morning-review.sh and capture output]

═══════════════════════════════════════════════════════════
Key Findings:
- 3 commits in last 24 hours
- Project health: 85% (Excellent)
- 2 items in progress, 5 not started
- All tests passing ✓
- Recommendation: Address 1 blocked item

The ritual is complete.
```

### Integration Notes

**Ghost County Context:**
- Rituals use themed language (séance, banishment, midnight hour)
- Scripts are designed for Ghost County workflow patterns
- Output includes GCO-specific metrics (roadmap status, agent memory)

**Script Dependencies:**
- All scripts located in `Haunt/scripts/rituals/`
- Scripts use bash and standard Unix tools
- Some features require Python 3 (agent memory parsing)
- NATS and MCP servers optional but recommended

**When to Use:**
- **Morning ritual:** Every session startup (part of session-startup protocol)
- **Evening ritual:** Every session end (document progress)
- **Weekly ritual:** End of week (strategic review and planning)

### See Also

- `/haunting` - View current active work
- `/spirits` - List available GCO agents
- `/seance <feature>` - Guided workflow from idea to implementation
