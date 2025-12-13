# Pattern Detection System

Automated detection and defeat of recurring anti-patterns in agent behavior.

## Overview

The Pattern Detection System analyzes your repository's history to identify recurring issues, automatically generates defeat tests, and trains your agents to avoid these patterns in the future.

**Core Philosophy:** TDD for Agent Behavior
```
Pattern Found → Test Written → Agent Trained → Pattern Defeated
```

## Quick Start

### First Run (Preview Mode)

```bash
cd /path/to/your/repo
./Haunt/scripts/rituals/hunt-patterns --dry-run --auto hunt
```

### Interactive Mode (Recommended)

```bash
./Haunt/scripts/rituals/hunt-patterns hunt
```

### Automated Mode (CI/CD)

```bash
./Haunt/scripts/rituals/hunt-patterns --auto hunt
```

## How It Works

The system operates in 6 automated steps:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Collect   │────▶│   Analyze   │────▶│   Review    │
│  Signals    │     │  Patterns   │     │  (Human)    │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                        │
       │  Git commits, memory, churn            │  Approve patterns
       ▼                                        ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Generate   │────▶│   Propose   │────▶│    Apply    │
│   Tests     │     │  Updates    │     │  Changes    │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Step 1: Collect Signals

Gathers evidence from three sources:
- **Git History:** Fix commits, repeated modifications, reverts
- **Agent Memory:** Recurring learnings, repeated mistakes
- **Code Churn:** Hot files with frequent changes

### Step 2: Analyze Patterns

Uses Claude AI to identify patterns from signals:
- Groups related issues
- Determines frequency and impact
- Identifies root causes
- Ranks by severity

### Step 3: Review Patterns

Interactive review of identified patterns:
- Human approval for each pattern
- Filter low-value patterns
- Prioritize high-impact issues

### Step 4: Generate Defeat Tests

Automatically creates pytest tests:
- One test per pattern
- Fails when pattern detected
- Clear error messages with locations

### Step 5: Propose Updates

Generates agent training materials:
- Non-negotiable rules for agent prompts
- Memory entries with learnings
- Contextual examples

### Step 6: Apply Changes

Updates project files:
- Adds tests to `.pre-commit-config.yaml`
- Stores learnings in agent memory
- Ready for immediate enforcement

## Command Reference

### `hunt` - Full Workflow

Run the complete pattern detection workflow.

```bash
hunt-patterns hunt [OPTIONS]
```

**Options:**
- `--days N` - Days of history to analyze (default: 30)
- `--top-n N` - Max patterns to identify (default: 10)
- `--dry-run` - Preview without making changes
- `--auto` - Auto-approve all prompts

**Examples:**
```bash
# Interactive mode with defaults
./hunt-patterns hunt

# Last 60 days, find top 5 patterns
./hunt-patterns hunt --days 60 --top-n 5

# Preview mode (safe to run)
./hunt-patterns hunt --dry-run --auto

# Fully automated (CI/CD)
./hunt-patterns --auto hunt
```

### `collect` - Gather Signals

Collect pattern signals from git, memory, and code churn.

```bash
hunt-patterns collect [OPTIONS]
```

**Options:**
- `--days N` - Days of history (default: 30)
- `--output FILE` - Output file path (default: auto-generated)

**Example:**
```bash
./hunt-patterns collect --days 30 --output signals.json
```

**Output:** JSON file with git_signals, memory_signals, churn_signals arrays.

### `analyze` - Identify Patterns

Use AI to identify patterns from collected signals.

```bash
hunt-patterns analyze [OPTIONS]
```

**Options:**
- `--input FILE` - Input signals file (default: use last collection)
- `--output FILE` - Output patterns file (default: auto-generated)
- `--top-n N` - Max patterns to identify (default: 10)

**Example:**
```bash
./hunt-patterns analyze --input signals.json --output patterns.json --top-n 10
```

**Output:** JSON file with patterns array containing name, description, evidence, frequency, impact, root_cause.

### `generate` - Create Defeat Tests

Generate pytest defeat tests for identified patterns.

```bash
hunt-patterns generate [OPTIONS]
```

**Options:**
- `--input FILE` - Input patterns file (default: use last analysis)
- `--pattern NAME` - Filter by pattern name

**Example:**
```bash
./hunt-patterns generate --input patterns.json
./hunt-patterns generate --pattern "silent fallback"
```

**Output:** Test files in `.haunt/tests/patterns/test_*.py`

### `apply` - Apply Updates

Apply agent prompt updates and memory entries.

```bash
hunt-patterns apply --input FILE
```

**Required:**
- `--input FILE` - Proposals file from previous run

**Example:**
```bash
./hunt-patterns apply --input proposals.json
```

**Changes:**
- Updates `.pre-commit-config.yaml`
- Adds entries to agent memory
- Creates backup before changes

## Example Defeat Test

Here's what a generated defeat test looks like:

```python
# .haunt/tests/patterns/test_no_silent_fallbacks.py
"""
Pattern: Silent Fallback Anti-Pattern
Severity: High
Generated: 2025-12-10
Agent(s): Dev-Backend, Dev-Frontend
Impact: Hides missing data, causes silent failures
"""

import re
from pathlib import Path

def test_no_silent_fallbacks():
    """Detect .get(key, default) patterns that hide missing data."""
    project_root = Path(__file__).parent.parent.parent
    violations = []

    for py_file in project_root.rglob("*.py"):
        if 'test_' in py_file.name:
            continue
        try:
            content = py_file.read_text()
            for i, line in enumerate(content.split('\n'), 1):
                if re.search(r'\.get\([^,]+,\s*(0|None|\'\'|""|\\[\\]|\\{\\})\)', line):
                    violations.append(f"{py_file}:{i} - {line.strip()}")
        except Exception:
            pass

    assert not violations, (
        f"Found {len(violations)} silent fallback patterns:\n" +
        "\n".join(violations[:10])
    )
```

## Integration with Weekly Refactor

Pattern detection is designed for weekly execution during refactor sessions:

### Monday Morning Ritual

```bash
# 1. Run pattern detection
./hunt-patterns hunt --days 7

# 2. Review generated tests
pytest .haunt/tests/patterns/ -v

# 3. Commit new patterns
git add .haunt/tests/patterns/ .pre-commit-config.yaml
git commit -m "Add defeat tests for [pattern names]"

# 4. Install hooks (if not already)
pre-commit install
```

### Continuous Improvement Cycle

```
Week 1: Identify 3 patterns → Generate 3 tests → Train agents
Week 2: Patterns defeated → Identify 2 new patterns → Generate tests
Week 3: Continue cycle → Agents get smarter → Fewer patterns found
```

## Troubleshooting

### "API key not found"

Pattern analysis requires Claude API access.

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

Add to `~/.bashrc` or `~/.zshrc` for persistence.

### "Pre-commit update failed"

Initialize pre-commit config if missing:

```bash
touch .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: local
    hooks: []
EOF
```

### "Memory directory not found"

Create agent memory structure:

```bash
mkdir -p ~/.agent-memory
echo '{"memories": []}' > ~/.agent-memory/memories.json
```

### "No patterns identified"

This is good! It means:
- No obvious anti-patterns in recent history
- Agents are performing well
- Previous defeats are working

Try expanding the time window:
```bash
./hunt-patterns hunt --days 60
```

### Tests Failing After Generation

This is expected! Defeat tests fail when patterns exist in code:

```bash
# 1. Review failures
pytest .haunt/tests/patterns/ -v

# 2. Fix the actual pattern in code
# (This is the goal - pattern detection → pattern elimination)

# 3. Re-run tests
pytest .haunt/tests/patterns/
```

## Best Practices

### 1. Start Conservative

```bash
# First time: Preview mode
./hunt-patterns --dry-run --auto hunt

# Second time: Interactive review
./hunt-patterns hunt

# Later: Automated (once comfortable)
./hunt-patterns --auto hunt
```

### 2. Weekly Cadence

Run pattern detection weekly, not daily:
- Patterns need time to emerge
- Avoid false positives from single incidents
- Focus on recurring issues

### 3. Review All Patterns

Don't blindly trust `--auto` mode:
- Some patterns may be false positives
- Context matters for severity assessment
- Human judgment improves accuracy

### 4. One Pattern Per Commit

```bash
# Generate tests for one pattern
./hunt-patterns generate --pattern "silent fallback"

# Commit separately
git add .haunt/tests/patterns/test_silent_fallback.py
git commit -m "Add defeat test for silent fallback pattern"
```

### 5. Test Your Defeat Tests

```bash
# After generation, verify tests work
pytest .haunt/tests/patterns/ -v

# Fix any syntax errors in generated tests
# Adjust detection logic if needed
```

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/pattern-detection.yml
name: Weekly Pattern Detection

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM
  workflow_dispatch:      # Allow manual trigger

jobs:
  detect-patterns:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for analysis

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Run Pattern Detection
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          ./Haunt/scripts/rituals/hunt-patterns --auto --no-color hunt

      - name: Create Pull Request
        if: success()
        uses: peter-evans/create-pull-request@v5
        with:
          title: "Weekly Pattern Detection"
          body: "Automated pattern detection and defeat test generation"
          branch: pattern-detection-${{ github.run_number }}
```

## Additional Resources

- **[QUICKSTART.md](scripts/rituals/pattern-detector/QUICKSTART.md)** - 2-minute getting started guide
- **[06-Patterns-and-Defeats.md](../Ghost_County_Framework/06-Patterns-and-Defeats.md)** - Pattern defeat methodology
- **[05-Operations.md](../Ghost_County_Framework/05-Operations.md)** - Weekly refactor ritual

## Support

For issues or questions:

1. Check troubleshooting section above
2. Review generated files in `.haunt/pattern-hunter/`
3. Run with `--dry-run` to debug without changes
4. Examine individual commands (`collect`, `analyze`, etc.)

```bash
# Get help for any command
./hunt-patterns --help
./hunt-patterns hunt --help
./hunt-patterns collect --help
```
