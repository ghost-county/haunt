#!/usr/bin/env python3
"""
Pattern Defeat Test: REQ-060 Pattern Detection Data Collection

Tests that the pattern detector collect.py module meets all acceptance criteria.

Pattern: Data collection module should analyze git history, agent memory, and code churn
Expected: Valid JSON output with all three signal types
"""

import json
import subprocess
import sys
from pathlib import Path


def test_pattern_collector_basic_execution():
    """Test that collect.py runs without errors."""
    result = subprocess.run(
        ['python3', 'Haunt/scripts/rituals/pattern-detector/collect.py', '--help'],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "collect.py should execute successfully"
    assert 'pattern detection signals' in result.stdout.lower(), "Help text should describe purpose"


def test_pattern_collector_json_output():
    """Test that collect.py produces valid JSON output."""
    result = subprocess.run(
        ['python3', 'Haunt/scripts/rituals/pattern-detector/collect.py', '--days', '30'],
        capture_output=True,
        text=True
    )

    assert result.returncode == 0, "collect.py should execute successfully"

    # Parse JSON
    try:
        data = json.loads(result.stdout)
    except json.JSONDecodeError as e:
        assert False, f"Output should be valid JSON: {e}"

    # Verify structure
    assert 'timestamp' in data, "Output should contain timestamp"
    assert 'repo_path' in data, "Output should contain repo_path"
    assert 'collection_period_days' in data, "Output should contain collection_period_days"
    assert 'git_signals' in data, "Output should contain git_signals"
    assert 'memory_signals' in data, "Output should contain memory_signals"
    assert 'churn_signals' in data, "Output should contain churn_signals"
    assert 'summary' in data, "Output should contain summary"

    # Verify data types
    assert isinstance(data['git_signals'], list), "git_signals should be a list"
    assert isinstance(data['memory_signals'], list), "memory_signals should be a list"
    assert isinstance(data['churn_signals'], list), "churn_signals should be a list"
    assert isinstance(data['summary'], dict), "summary should be a dict"


def test_pattern_collector_missing_memory_file():
    """Test that collect.py handles missing agent memory file gracefully."""
    result = subprocess.run(
        [
            'python3', 'Haunt/scripts/rituals/pattern-detector/collect.py',
            '--days', '30',
            '--memory-path', '/nonexistent/path/memories.json'
        ],
        capture_output=True,
        text=True
    )

    assert result.returncode == 0, "collect.py should not fail on missing memory file"

    # Parse JSON
    data = json.loads(result.stdout)

    # Should still have valid structure
    assert 'memory_signals' in data, "Output should still contain memory_signals"
    assert isinstance(data['memory_signals'], list), "memory_signals should be a list (empty)"


def test_pattern_collector_git_signals():
    """Test that git analyzer produces expected signal types."""
    result = subprocess.run(
        ['python3', 'Haunt/scripts/rituals/pattern-detector/collect.py', '--days', '365'],
        capture_output=True,
        text=True
    )

    data = json.loads(result.stdout)

    # Check git signal types
    for signal in data['git_signals']:
        assert 'type' in signal, "Git signals should have type field"
        assert signal['type'] in ['fix_commit', 'commit', 'repeated_modification'], \
            f"Git signal type should be valid: {signal['type']}"


def test_pattern_collector_churn_signals():
    """Test that churn analyzer produces top N hot files."""
    result = subprocess.run(
        [
            'python3', 'Haunt/scripts/rituals/pattern-detector/collect.py',
            '--days', '30',
            '--top-n', '5'
        ],
        capture_output=True,
        text=True
    )

    data = json.loads(result.stdout)

    # Should have at most 5 hot files
    assert len(data['churn_signals']) <= 5, "Should return at most top-n hot files"

    # Check churn signal structure
    for signal in data['churn_signals']:
        assert signal['type'] == 'hot_file', "Churn signals should be hot_file type"
        assert 'file' in signal, "Churn signals should have file field"
        assert 'churn_score' in signal, "Churn signals should have churn_score"
        assert 'commit_count' in signal, "Churn signals should have commit_count"
        assert 'total_changes' in signal, "Churn signals should have total_changes"
        assert 'signal_strength' in signal, "Churn signals should have signal_strength"


def test_pattern_collector_summary():
    """Test that summary contains correct counts."""
    result = subprocess.run(
        ['python3', 'Haunt/scripts/rituals/pattern-detector/collect.py', '--days', '30'],
        capture_output=True,
        text=True
    )

    data = json.loads(result.stdout)
    summary = data['summary']

    # Verify summary fields
    assert 'total_signals' in summary, "Summary should contain total_signals"
    assert 'fix_commits' in summary, "Summary should contain fix_commits"
    assert 'repeated_modifications' in summary, "Summary should contain repeated_modifications"
    assert 'repeated_learnings' in summary, "Summary should contain repeated_learnings"
    assert 'hot_files' in summary, "Summary should contain hot_files"

    # Verify counts match
    git_fix_count = len([s for s in data['git_signals'] if s['type'] == 'fix_commit'])
    git_repeat_count = len([s for s in data['git_signals'] if s['type'] == 'repeated_modification'])

    assert summary['fix_commits'] == git_fix_count, "Fix commit count should match"
    assert summary['repeated_modifications'] == git_repeat_count, "Repeated modification count should match"
    assert summary['repeated_learnings'] == len(data['memory_signals']), "Repeated learning count should match"
    assert summary['hot_files'] == len(data['churn_signals']), "Hot file count should match"


def run_tests():
    """Run all tests and report results."""
    tests = [
        test_pattern_collector_basic_execution,
        test_pattern_collector_json_output,
        test_pattern_collector_missing_memory_file,
        test_pattern_collector_git_signals,
        test_pattern_collector_churn_signals,
        test_pattern_collector_summary,
    ]

    print("\n=== Testing Pattern Detection Data Collection (REQ-060) ===\n")

    passed = 0
    failed = 0

    for test_func in tests:
        test_name = test_func.__name__
        try:
            test_func()
            print(f"✓ {test_name}")
            passed += 1
        except AssertionError as e:
            print(f"✗ {test_name}: {e}")
            failed += 1
        except Exception as e:
            print(f"✗ {test_name}: Unexpected error: {e}")
            failed += 1

    print(f"\n=== Results: {passed} passed, {failed} failed ===\n")

    return 0 if failed == 0 else 1


if __name__ == '__main__':
    sys.exit(run_tests())
