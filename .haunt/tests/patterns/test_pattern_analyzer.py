#!/usr/bin/env python3
"""
Pattern Defeat Test: REQ-061 AI-Powered Pattern Analysis

Tests that the pattern analyzer analyze.py module meets all acceptance criteria.

Pattern: AI analysis should identify concrete patterns with supporting evidence
Expected: Structured JSON output with ranked patterns including evidence and root causes
"""

import json
import subprocess
import sys
import tempfile
from pathlib import Path


# Sample signals data for testing
SAMPLE_SIGNALS = {
    "timestamp": "2025-12-10T10:00:00",
    "repo_path": "/test/repo",
    "collection_period_days": 30,
    "git_signals": [
        {
            "type": "fix_commit",
            "hash": "abc123",
            "date": "2025-12-01T10:00:00",
            "author": "Developer",
            "message": "fix: handle null values in validation",
            "files_changed": ["src/validation.py"],
            "stats": {"insertions": 5, "deletions": 2}
        },
        {
            "type": "fix_commit",
            "hash": "def456",
            "date": "2025-12-05T14:30:00",
            "author": "Developer",
            "message": "fix: add error context to exception",
            "files_changed": ["src/handlers.py"],
            "stats": {"insertions": 3, "deletions": 1}
        },
        {
            "type": "repeated_modification",
            "file": "src/api.py",
            "modification_count": 7,
            "modifications": [
                {"hash": "aaa111", "date": "2025-11-15T09:00:00", "message": "Add endpoint"},
                {"hash": "bbb222", "date": "2025-11-16T10:00:00", "message": "Fix validation"},
                {"hash": "ccc333", "date": "2025-11-20T11:00:00", "message": "Fix error handling"}
            ],
            "signal_strength": "high"
        }
    ],
    "memory_signals": [
        {
            "type": "repeated_learning",
            "pattern": "Multiple learnings in category: error-handling",
            "category": "error-handling",
            "occurrences": 4,
            "memories": [
                {"timestamp": "2025-11-10T10:00:00", "content": "Learned to add context to exceptions", "tags": ["best-practice"]},
                {"timestamp": "2025-11-20T14:00:00", "content": "Remember to validate inputs explicitly", "tags": ["validation"]}
            ],
            "signal_strength": "medium"
        }
    ],
    "churn_signals": [
        {
            "type": "hot_file",
            "file": "src/api.py",
            "churn_score": 1250,
            "commit_count": 7,
            "total_changes": 178,
            "insertions": 120,
            "deletions": 58,
            "recent_commits": [
                {"hash": "aaa111", "date": "2025-11-15T09:00:00", "message": "Add endpoint"}
            ],
            "signal_strength": "high"
        }
    ],
    "summary": {
        "total_signals": 6,
        "fix_commits": 2,
        "repeated_modifications": 1,
        "repeated_learnings": 1,
        "hot_files": 1
    }
}


def test_analyzer_basic_execution():
    """Test that analyze.py runs without errors."""
    result = subprocess.run(
        ['python3', 'Haunt/scripts/rituals/pattern-detector/analyze.py', '--help'],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "analyze.py should execute successfully"
    assert 'pattern detection signals' in result.stdout.lower(), "Help text should describe purpose"


def test_analyzer_mock_mode():
    """Test that analyze.py works in mock mode without API calls."""
    # Create temporary input file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(SAMPLE_SIGNALS, f)
        temp_input = f.name

    try:
        result = subprocess.run(
            [
                'python3', 'Haunt/scripts/rituals/pattern-detector/analyze.py',
                '--input', temp_input,
                '--mock'
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode == 0, f"analyze.py should execute successfully: {result.stderr}"

        # Parse JSON
        try:
            data = json.loads(result.stdout)
        except json.JSONDecodeError as e:
            assert False, f"Output should be valid JSON: {e}\nOutput: {result.stdout}"

        # Verify structure
        assert 'timestamp' in data, "Output should contain timestamp"
        assert 'patterns' in data, "Output should contain patterns"
        assert 'metadata' in data, "Output should contain metadata"

        # Verify data types
        assert isinstance(data['patterns'], list), "patterns should be a list"
        assert isinstance(data['metadata'], dict), "metadata should be a dict"

        # Verify metadata
        assert data['metadata']['api_method'] == 'mock', "Should indicate mock mode"
        assert 'total_patterns_found' in data['metadata'], "Should have total count"

    finally:
        Path(temp_input).unlink()


def test_analyzer_pattern_structure():
    """Test that each pattern has required fields."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(SAMPLE_SIGNALS, f)
        temp_input = f.name

    try:
        result = subprocess.run(
            [
                'python3', 'Haunt/scripts/rituals/pattern-detector/analyze.py',
                '--input', temp_input,
                '--mock'
            ],
            capture_output=True,
            text=True
        )

        data = json.loads(result.stdout)

        assert len(data['patterns']) > 0, "Should return at least one pattern in mock mode"

        # Check pattern structure
        for pattern in data['patterns']:
            assert 'name' in pattern, "Pattern should have name"
            assert 'description' in pattern, "Pattern should have description"
            assert 'evidence' in pattern, "Pattern should have evidence"
            assert 'frequency' in pattern, "Pattern should have frequency"
            assert 'impact' in pattern, "Pattern should have impact"
            assert 'root_cause' in pattern, "Pattern should have root_cause"
            assert 'score' in pattern, "Pattern should have score"

            # Verify field types
            assert isinstance(pattern['name'], str), "name should be string"
            assert isinstance(pattern['description'], str), "description should be string"
            assert isinstance(pattern['evidence'], list), "evidence should be list"
            assert isinstance(pattern['root_cause'], str), "root_cause should be string"
            assert isinstance(pattern['score'], (int, float)), "score should be numeric"

            # Verify enum values
            assert pattern['frequency'] in ['daily', 'weekly', 'per-feature', 'monthly'], \
                f"frequency should be valid enum value: {pattern['frequency']}"
            assert pattern['impact'] in ['high', 'medium', 'low'], \
                f"impact should be valid enum value: {pattern['impact']}"

    finally:
        Path(temp_input).unlink()


def test_analyzer_evidence_specificity():
    """Test that evidence references specific files/commits."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(SAMPLE_SIGNALS, f)
        temp_input = f.name

    try:
        result = subprocess.run(
            [
                'python3', 'Haunt/scripts/rituals/pattern-detector/analyze.py',
                '--input', temp_input,
                '--mock'
            ],
            capture_output=True,
            text=True
        )

        data = json.loads(result.stdout)

        for pattern in data['patterns']:
            assert len(pattern['evidence']) > 0, f"Pattern '{pattern['name']}' should have evidence"

            # Check that evidence contains specific references
            has_specifics = False
            for evidence_item in pattern['evidence']:
                # Evidence should mention files, commits, or specific occurrences
                if any(keyword in evidence_item.lower() for keyword in [
                    '.py', '.md', '.js', '.ts',  # File extensions
                    'commit', 'modified', 'times',  # Change indicators
                    'appears', 'memory', 'learning'  # Memory indicators
                ]):
                    has_specifics = True
                    break

            assert has_specifics, \
                f"Pattern '{pattern['name']}' should have specific evidence (files/commits/counts)"

    finally:
        Path(temp_input).unlink()


def test_analyzer_pattern_ranking():
    """Test that patterns are ranked by impact × frequency."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(SAMPLE_SIGNALS, f)
        temp_input = f.name

    try:
        result = subprocess.run(
            [
                'python3', 'Haunt/scripts/rituals/pattern-detector/analyze.py',
                '--input', temp_input,
                '--mock'
            ],
            capture_output=True,
            text=True
        )

        data = json.loads(result.stdout)

        if len(data['patterns']) > 1:
            # Verify patterns are sorted by score (descending)
            scores = [p['score'] for p in data['patterns']]
            assert scores == sorted(scores, reverse=True), \
                "Patterns should be sorted by score (highest first)"

            # Verify score calculation matches impact × frequency
            impact_scores = {'high': 3.0, 'medium': 2.0, 'low': 1.0}
            frequency_scores = {'daily': 4.0, 'weekly': 3.0, 'per-feature': 2.0, 'monthly': 1.0}

            for pattern in data['patterns']:
                expected_score = (
                    impact_scores[pattern['impact']] *
                    frequency_scores[pattern['frequency']]
                )
                assert abs(pattern['score'] - expected_score) < 0.01, \
                    f"Pattern score should match impact × frequency: {pattern['score']} != {expected_score}"

    finally:
        Path(temp_input).unlink()


def test_analyzer_top_n_limit():
    """Test that --top-n limits output correctly."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(SAMPLE_SIGNALS, f)
        temp_input = f.name

    try:
        result = subprocess.run(
            [
                'python3', 'Haunt/scripts/rituals/pattern-detector/analyze.py',
                '--input', temp_input,
                '--mock',
                '--top-n', '2'
            ],
            capture_output=True,
            text=True
        )

        data = json.loads(result.stdout)

        assert len(data['patterns']) <= 2, "Should return at most 2 patterns with --top-n 2"
        assert data['metadata']['patterns_returned'] == len(data['patterns']), \
            "metadata should reflect actual count returned"

    finally:
        Path(temp_input).unlink()


def test_analyzer_stdin_input():
    """Test that analyze.py can read from stdin."""
    input_json = json.dumps(SAMPLE_SIGNALS)

    result = subprocess.run(
        [
            'python3', 'Haunt/scripts/rituals/pattern-detector/analyze.py',
            '--mock'
        ],
        input=input_json,
        capture_output=True,
        text=True
    )

    assert result.returncode == 0, "Should read from stdin successfully"

    data = json.loads(result.stdout)
    assert 'patterns' in data, "Should return patterns when reading from stdin"


def test_analyzer_handles_empty_signals():
    """Test that analyze.py handles empty signal input gracefully."""
    empty_signals = {
        "timestamp": "2025-12-10T10:00:00",
        "repo_path": "/test/repo",
        "collection_period_days": 30,
        "git_signals": [],
        "memory_signals": [],
        "churn_signals": [],
        "summary": {
            "total_signals": 0,
            "fix_commits": 0,
            "repeated_modifications": 0,
            "repeated_learnings": 0,
            "hot_files": 0
        }
    }

    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(empty_signals, f)
        temp_input = f.name

    try:
        result = subprocess.run(
            [
                'python3', 'Haunt/scripts/rituals/pattern-detector/analyze.py',
                '--input', temp_input,
                '--mock'
            ],
            capture_output=True,
            text=True
        )

        # Should not crash
        assert result.returncode == 0, "Should handle empty signals without crashing"

        data = json.loads(result.stdout)
        assert 'patterns' in data, "Should still return patterns structure"
        assert isinstance(data['patterns'], list), "patterns should be a list"

    finally:
        Path(temp_input).unlink()


def test_analyzer_coherent_patterns():
    """Test that patterns are coherent and actionable (not vague)."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(SAMPLE_SIGNALS, f)
        temp_input = f.name

    try:
        result = subprocess.run(
            [
                'python3', 'Haunt/scripts/rituals/pattern-detector/analyze.py',
                '--input', temp_input,
                '--mock'
            ],
            capture_output=True,
            text=True
        )

        data = json.loads(result.stdout)

        for pattern in data['patterns']:
            # Name should be descriptive (not just "Pattern 1")
            assert len(pattern['name']) > 5, \
                f"Pattern name should be descriptive: '{pattern['name']}'"
            assert not pattern['name'].lower().startswith('pattern '), \
                f"Pattern name should not be generic: '{pattern['name']}'"

            # Description should be substantial
            assert len(pattern['description']) > 20, \
                f"Pattern description should be detailed: '{pattern['description']}'"

            # Root cause should be substantial
            assert len(pattern['root_cause']) > 20, \
                f"Root cause should be detailed: '{pattern['root_cause']}'"

    finally:
        Path(temp_input).unlink()


def run_tests():
    """Run all tests and report results."""
    tests = [
        test_analyzer_basic_execution,
        test_analyzer_mock_mode,
        test_analyzer_pattern_structure,
        test_analyzer_evidence_specificity,
        test_analyzer_pattern_ranking,
        test_analyzer_top_n_limit,
        test_analyzer_stdin_input,
        test_analyzer_handles_empty_signals,
        test_analyzer_coherent_patterns,
    ]

    print("\n=== Testing Pattern Analysis Module (REQ-061) ===\n")

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
            import traceback
            traceback.print_exc()
            failed += 1

    print(f"\n=== Results: {passed} passed, {failed} failed ===\n")

    return 0 if failed == 0 else 1


if __name__ == '__main__':
    sys.exit(run_tests())
