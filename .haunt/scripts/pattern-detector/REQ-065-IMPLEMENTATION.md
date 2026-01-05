# REQ-065: Pre-commit Hook Auto-Update Implementation

## Overview

Implementation of automatic `.pre-commit-config.yaml` update functionality for pattern defeat tests.

**Status:** ✅ COMPLETE

**Date:** 2025-12-10

## Deliverables

### 1. Core Module: `update_precommit.py`
**Location:** `Agentic_SDLC/scripts/pattern-detector/update_precommit.py`

**Features:**
- ✅ Creates `.pre-commit-config.yaml` if missing
- ✅ Adds pattern defeat tests to existing config
- ✅ Preserves all existing hooks
- ✅ Idempotent (running twice produces same result)
- ✅ YAML validation before writing
- ✅ Dry run support
- ✅ CLI and programmatic usage
- ✅ Pre-commit installation support

**CLI Options:**
```bash
python update_precommit.py                    # Basic usage
python update_precommit.py --dry-run          # Preview changes
python update_precommit.py --install          # Update and install hooks
python update_precommit.py --check-only       # Check if update needed
python update_precommit.py --config PATH      # Custom config path
python update_precommit.py --test-dir DIR     # Custom test directory
```

### 2. Test Suite: `test_update_precommit.py`
**Location:** `tests/patterns/test_update_precommit.py`

**Coverage:**
- ✅ 26 unit tests
- ✅ All tests pass
- ✅ Tests initialization, config loading, updating, validation, writing
- ✅ Integration tests for new and existing repositories
- ✅ Idempotency tests
- ✅ Dry run tests

**Test Results:**
```
26 passed in 0.26s
```

### 3. Example Usage: `example_precommit_usage.py`
**Location:** `Agentic_SDLC/scripts/pattern-detector/example_precommit_usage.py`

**Demonstrates:**
- ✅ New repository workflow
- ✅ Existing repository workflow
- ✅ Idempotent updates
- ✅ Dry run mode
- ✅ Programmatic usage
- ✅ CLI examples
- ✅ Acceptance test verification

### 4. Documentation: README.md
**Location:** `Agentic_SDLC/scripts/pattern-detector/README.md`

**Added:**
- ✅ Complete module documentation
- ✅ Usage examples
- ✅ Command-line options
- ✅ Programmatic API
- ✅ Acceptance tests
- ✅ Error handling
- ✅ Integration examples

## Completion Criteria

### ✅ Creates pre-commit config if missing
**Test:** Run on repo without `.pre-commit-config.yaml`
**Result:** Creates valid config with pattern defeat tests
```yaml
repos:
  - repo: local
    hooks:
      - id: pattern-defeat-tests
        name: Pattern Defeat Tests
        entry: pytest .haunt/tests/patterns/ -v
        language: system
        types: [python]
        pass_filenames: false
```

### ✅ Adds new tests to existing config
**Test:** Run on repo with existing hooks (e.g., black formatter)
**Result:** Adds pattern tests without removing existing hooks
- Existing hooks preserved
- Pattern tests added to local repo
- YAML structure maintained

### ✅ Idempotent: running twice produces same result
**Test:** Run updater twice on same config
**Result:**
- First run: `success=True, changed=True`
- Second run: `success=True, changed=False`
- File content identical after both runs
- No unnecessary modifications

## Acceptance Tests

### Test 1: New Repository Without Config
**Setup:**
```bash
mkdir new-repo && cd new-repo
mkdir -p .haunt/tests/patterns
```

**Execute:**
```bash
python update_precommit.py --test-dir .haunt/tests/patterns
```

**Expected:**
- Creates `.pre-commit-config.yaml`
- Contains local repo with pattern-defeat-tests hook
- YAML is valid and parseable
- Hook command references correct test directory

**Result:** ✅ PASS

### Test 2: Existing Repository With Config
**Setup:**
```bash
# Create existing config with black formatter
cat > .pre-commit-config.yaml << EOF
repos:
  - repo: https://github.com/psf/black
    rev: 23.1.0
    hooks:
      - id: black
EOF
```

**Execute:**
```bash
python update_precommit.py
```

**Expected:**
- Preserves black formatter hook
- Adds local repo with pattern-defeat-tests hook
- File remains valid YAML
- Both hooks present in final config

**Result:** ✅ PASS

## Technical Implementation

### Architecture

**Class: PreCommitUpdater**
```python
class PreCommitUpdater:
    def __init__(config_path, test_dir)
    def check_precommit_installed() -> bool
    def load_config() -> Dict
    def update_config(config) -> (Dict, bool)
    def validate_config(config) -> (bool, str)
    def write_config(config) -> None
    def install_hooks() -> bool
    def update(dry_run, install) -> (bool, bool)
```

**Key Methods:**
1. `load_config()`: Loads existing config or returns default
2. `find_local_repo()`: Finds existing local repo in config
3. `find_pattern_hook()`: Finds existing pattern hook
4. `update_config()`: Adds/updates pattern hook idempotently
5. `validate_config()`: Validates YAML structure
6. `write_config()`: Writes formatted YAML to file

### Hook Configuration

**Structure:**
```yaml
repos:
  - repo: local
    hooks:
      - id: pattern-defeat-tests
        name: Pattern Defeat Tests
        entry: pytest .haunt/tests/patterns/ -v
        language: system
        types: [python]
        pass_filenames: false
```

**Properties:**
- `id`: Unique identifier for the hook
- `name`: Human-readable name
- `entry`: Command to execute
- `language`: `system` (uses system Python)
- `types`: Only runs on Python files
- `pass_filenames`: `false` (runs on entire test directory)

### Dependencies

**Required:**
- Python 3.11+
- PyYAML (`pip install pyyaml`)

**Optional:**
- pre-commit (`pip install pre-commit`) - only for `--install` flag

**Error Handling:**
- Missing PyYAML: Clear error message with installation instructions
- Missing pre-commit: Warning if `--install` flag used
- Invalid YAML: Validation catches errors before writing
- Missing files: Gracefully handles and provides defaults

## Integration

### With Pattern Detector Pipeline

```bash
# Generate tests
python generate_tests.py --input patterns.json

# Update pre-commit config
python update_precommit.py --install

# Now commits will run tests automatically
git commit -m "Add feature"
# → pytest .haunt/tests/patterns/ -v runs before commit
```

### Standalone Usage

```bash
# Initialize pre-commit in new project
python update_precommit.py --test-dir tests --install

# Update existing project
cd existing-project
python update_precommit.py --dry-run  # Preview
python update_precommit.py            # Apply
```

## Files Created/Modified

### Created
1. `Agentic_SDLC/scripts/pattern-detector/update_precommit.py` (522 lines)
2. `tests/patterns/test_update_precommit.py` (655 lines)
3. `Agentic_SDLC/scripts/pattern-detector/example_precommit_usage.py` (408 lines)
4. `Agentic_SDLC/scripts/pattern-detector/REQ-065-IMPLEMENTATION.md` (this file)

### Modified
1. `Agentic_SDLC/scripts/pattern-detector/README.md` (added documentation)

## Testing Summary

**Unit Tests:** 26/26 passed ✅
**Integration Tests:** 2/2 passed ✅
**Acceptance Tests:** 2/2 passed ✅

**Test Coverage:**
- Initialization and configuration
- Config loading (missing, empty, valid files)
- Finding repos and hooks
- Updating configs (empty, existing, idempotent)
- Validation (valid, invalid structures)
- Writing configs
- Dry run mode
- Complete workflows (new/existing repos)

## Usage Examples

### Basic Usage
```bash
# Update current directory
python update_precommit.py

# Dry run
python update_precommit.py --dry-run

# Custom paths
python update_precommit.py --config .pre-commit-config.yaml --test-dir tests
```

### Programmatic Usage
```python
from update_precommit import PreCommitUpdater

updater = PreCommitUpdater(
    config_path='.pre-commit-config.yaml',
    test_dir='.haunt/tests/patterns'
)

success, changed = updater.update(dry_run=False, install=False)
```

### Integration Example
```bash
# Complete pattern detection workflow
python collect.py --days 30 | \
  python analyze.py --mock | \
  python generate_tests.py --mock && \
  python update_precommit.py --install
```

## Verification

Run these commands to verify implementation:

```bash
# Run unit tests
python -m pytest tests/patterns/test_update_precommit.py -v

# Run examples
python Agentic_SDLC/scripts/pattern-detector/example_precommit_usage.py

# Test on this repo (dry run)
python Agentic_SDLC/scripts/pattern-detector/update_precommit.py \
  --test-dir tests/patterns --dry-run

# Check CLI help
python Agentic_SDLC/scripts/pattern-detector/update_precommit.py --help
```

## Implementation Notes

### Design Decisions

1. **YAML Library:** Used PyYAML (standard, widely available)
2. **Idempotency:** Checks existing hooks before modifying
3. **Validation:** Validates structure before writing to prevent corruption
4. **Error Handling:** Graceful fallbacks for missing files/invalid data
5. **CLI Design:** Unix-style flags with clear defaults

### Edge Cases Handled

- Empty config files
- Missing config files
- Invalid YAML syntax
- Existing local repo with other hooks
- Existing pattern hook with different command
- Missing test directory
- No pre-commit installed (when using --install)

### Future Enhancements

Could add:
- Support for multiple test directories
- Custom hook configuration (e.g., different pytest args)
- Auto-detection of test file changes for incremental updates
- Integration with MCP server for configuration management

## Conclusion

REQ-065 is fully implemented and tested. The module:

✅ Creates pre-commit config if missing
✅ Adds tests to existing config without breaking
✅ Is idempotent (running twice produces same result)
✅ Supports CLI and programmatic usage
✅ Includes comprehensive tests and documentation
✅ Integrates with pattern detector pipeline

**Ready for production use.**
