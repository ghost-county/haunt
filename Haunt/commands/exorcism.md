# Exorcism (Pattern Defeat Test Generation)

Exorcise anti-patterns from your codebase by generating defeat tests - "protective wards" that prevent cursed patterns from returning.

## Pattern Exorcism: $ARGUMENTS

### Usage

| Command | Description |
|---------|-------------|
| `/exorcism <pattern-name>` | Generate defeat test for a specific pattern |
| `/exorcism <pattern-name> --install` | Generate test AND install pre-commit hooks |
| `/exorcism --list` | Show all detected patterns that can be exorcised |

### Available Patterns

Common patterns you can exorcise:
- `silent-fallback` - Silent dictionary.get() with defaults
- `empty-catch` - Empty exception handlers
- `god-function` - Functions over 100 lines
- `magic-numbers` - Hardcoded numeric values
- `single-letter-vars` - Unclear variable names
- `deep-nesting` - Excessive indentation (4+ levels)
- `commented-code` - Commented-out code blocks
- `catch-all-exception` - Catching Exception without re-raising

### Execution

#### Basic Exorcism (`/exorcism <pattern-name>`)

Generate a defeat test for a specific pattern:

```bash
cd /Users/heckatron/github_repos/Claude
python3 Haunt/scripts/rituals/pattern-detector/generate_tests.py \
  --pattern-name "$ARGUMENTS" \
  --output-dir .haunt/tests/patterns/
```

This will:
1. Generate defeat test file: `.haunt/tests/patterns/test_<pattern>.py`
2. Validate test syntax
3. Show test location

#### Full Exorcism (`/exorcism <pattern-name> --install`)

Generate defeat test AND update pre-commit hooks:

```bash
cd /Users/heckatron/github_repos/Claude

# Generate defeat test
python3 Haunt/scripts/rituals/pattern-detector/generate_tests.py \
  --pattern-name "$PATTERN_NAME" \
  --output-dir .haunt/tests/patterns/

# Update pre-commit hooks to run defeat tests
python3 Haunt/scripts/rituals/pattern-detector/update_precommit.py --install
```

This will:
1. Generate defeat test
2. Add pattern defeat tests to `.pre-commit-config.yaml`
3. Install pre-commit hooks
4. Create protective ward against pattern recurrence

#### List Mode (`/exorcism --list`)

Show all patterns available for exorcism:

```bash
# If patterns JSON exists, read it
if [ -f ".haunt/progress/patterns-analysis.json" ]; then
  python3 -c "
import json
with open('.haunt/progress/patterns-analysis.json') as f:
    data = json.load(f)
    print('🕯️ PATTERNS READY FOR EXORCISM 🕯️\n')
    for i, pattern in enumerate(data.get('patterns', []), 1):
        print(f'{i}. {pattern[\"name\"]}')
        print(f'   Severity: {pattern.get(\"impact\", \"unknown\")}')
        print(f'   Frequency: {pattern.get(\"frequency\", \"unknown\")}')
        print()
"
else
  echo "No patterns detected yet. Run /seer first to detect patterns."
fi
```

### Output Format

Present results in a ritual narrative:

#### Success (Basic)
```
🕯️ EXORCISM RITUAL COMPLETE 🕯️

Pattern Exorcised: {pattern-name}

Protective Ward Created:
- .haunt/tests/patterns/test_{pattern_name}.py

The anti-pattern has been warded. Run these tests to verify:
  pytest .haunt/tests/patterns/test_{pattern_name}.py -v

Next Steps:
- Run defeat test: pytest .haunt/tests/patterns/ -v
- Install pre-commit protection: /exorcism {pattern-name} --install
- Or install manually: pre-commit install
```

#### Success (Full with --install)
```
🕯️ EXORCISM RITUAL COMPLETE 🕯️

Pattern Exorcised: {pattern-name}

Protective Wards Created:
- Defeat test: .haunt/tests/patterns/test_{pattern_name}.py
- Pre-commit hook: .pre-commit-config.yaml (updated)

Protection Activated:
✓ Pre-commit hooks installed
✓ Pattern will be detected before each commit

The anti-pattern has been exorcised. Your repository is now protected.

Verify protection:
  pre-commit run --all-files
```

#### Failure
```
⚠️ EXORCISM FAILED ⚠️

Pattern: {pattern-name}
Error: {error-message}

Troubleshooting:
- Run /seer first to detect patterns
- Check pattern name spelling
- Verify pattern-detector scripts are available
- See: Haunt/scripts/rituals/pattern-detector/CLI-USAGE.md
```

#### List Mode Output
```
🕯️ PATTERNS READY FOR EXORCISM 🕯️

1. silent-fallback
   Severity: high
   Frequency: weekly
   Description: Silent dictionary.get() with defaults

2. empty-catch
   Severity: medium
   Frequency: monthly
   Description: Empty exception handlers

...

To exorcise a pattern:
  /exorcism <pattern-name>

To protect against recurrence:
  /exorcism <pattern-name> --install
```

### Quick Actions

After exorcising a pattern:

- **Run defeat test**: `pytest .haunt/tests/patterns/test_{pattern}.py -v`
- **Run all wards**: `pytest .haunt/tests/patterns/ -v`
- **Install protection**: `/exorcism {pattern} --install`
- **Verify hooks**: `pre-commit run --all-files`

### Notes

- Exorcism generates Python defeat tests using AST analysis
- Tests are standalone and can be run individually
- Pre-commit hook runs ALL defeat tests before each commit
- Tests are "protective wards" - they prevent patterns from returning
- Failed defeat test means pattern was detected again (curse returned)
- Pattern must be detected by `/seer` before it can be exorcised

### Integration with Pattern Detection

Typical workflow:
1. `/seer` - Detect anti-patterns (divine curses)
2. Review `.haunt/progress/weekly-refactor-*.md` (understand curses)
3. `/exorcism <pattern>` - Generate defeat test (create ward)
4. `/exorcism <pattern> --install` - Activate protection (install ward)
5. `pytest .haunt/tests/patterns/ -v` - Verify all wards hold

### Advanced Usage

#### Custom Pattern Definitions

If the pattern isn't in the standard list, you can still exorcise it by providing a pattern definition:

```bash
# Create pattern definition JSON
cat > /tmp/custom-pattern.json <<EOF
{
  "patterns": [
    {
      "name": "custom-antipattern",
      "description": "Custom anti-pattern description",
      "evidence": ["Example code"],
      "frequency": "weekly",
      "impact": "high",
      "root_cause": "Root cause analysis"
    }
  ]
}
EOF

# Generate test from custom pattern
python3 Haunt/scripts/rituals/pattern-detector/generate_tests.py \
  --input /tmp/custom-pattern.json \
  --output-dir .haunt/tests/patterns/
```

#### Re-generating Tests

Defeat tests can be regenerated if the pattern definition changes:

```bash
# Tests are idempotent - running again overwrites
/exorcism {pattern-name}
```

### Troubleshooting

**Error: "Pattern not found"**
- Run `/seer` first to detect patterns
- Check `.haunt/progress/patterns-analysis.json` exists
- Verify pattern name matches detected pattern

**Error: "Test generation failed"**
- Check Python is available: `python3 --version`
- Verify pattern-detector scripts exist
- See detailed logs in script output

**Error: "Pre-commit install failed"**
- Install pre-commit: `pip install pre-commit`
- Verify git repository: `git status`
- Check `.pre-commit-config.yaml` is valid YAML
