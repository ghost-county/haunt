#!/usr/bin/env python3
"""
Example: Test Generation from Pattern Analysis

Demonstrates the complete workflow:
1. Load pattern analysis results
2. Generate defeat tests
3. Validate and write to files
4. Run tests with pytest
"""

import json
import subprocess
import sys
from pathlib import Path

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

from generate_tests import TestGenerator


def example_basic_usage():
    """Example 1: Basic test generation from a single pattern."""
    print("=" * 60)
    print("Example 1: Basic Test Generation")
    print("=" * 60)

    # Sample pattern from analysis
    pattern = {
        'name': 'Silent Fallback Pattern',
        'description': 'Using .get() with default values instead of explicit validation',
        'evidence': [
            'auth.py: modified 5 times with validation fixes',
            'api.py: 3 commits adding error handling'
        ],
        'frequency': 'weekly',
        'impact': 'high',
        'root_cause': 'Developers default to .get() for convenience without considering edge cases'
    }

    # Initialize generator with mock mode
    generator = TestGenerator(mock=True)

    # Generate test
    result = generator.generate_test(pattern)

    print(f"Pattern: {result['pattern_name']}")
    print(f"Slug: {result['pattern_slug']}")
    print(f"Filename: {result['filename']}")
    print(f"Valid: {result['validation']['is_valid']}")

    if result['validation']['is_valid']:
        print("\nGenerated test (first 15 lines):")
        print("-" * 60)
        for i, line in enumerate(result['test_code'].split('\n')[:15], 1):
            print(f"{i:3}: {line}")
        print("-" * 60)
    else:
        print(f"Validation error: {result['validation']['error']}")


def example_multiple_patterns():
    """Example 2: Generate tests for multiple patterns."""
    print("\n" + "=" * 60)
    print("Example 2: Multiple Pattern Test Generation")
    print("=" * 60)

    patterns = [
        {
            'name': 'Silent Fallback',
            'description': 'Using .get() with defaults',
            'evidence': ['file1.py'],
            'frequency': 'weekly',
            'impact': 'high',
            'root_cause': 'Convenience'
        },
        {
            'name': 'Missing Error Context',
            'description': 'Exceptions without context',
            'evidence': ['file2.py'],
            'frequency': 'per-feature',
            'impact': 'medium',
            'root_cause': 'Focus on happy path'
        }
    ]

    generator = TestGenerator(mock=True)
    results = generator.generate_all_tests(patterns)

    print(f"\nGenerated {len(results)} tests:")
    for i, result in enumerate(results, 1):
        status = "✓" if result['validation']['is_valid'] else "✗"
        print(f"  {status} {i}. {result['filename']}")


def example_from_json_file():
    """Example 3: Generate tests from analysis JSON file."""
    print("\n" + "=" * 60)
    print("Example 3: Generate from JSON File")
    print("=" * 60)

    # Create sample analysis output
    analysis_data = {
        'timestamp': '2025-12-10T10:00:00',
        'patterns': [
            {
                'name': 'God Functions',
                'description': 'Functions exceeding 50 lines',
                'evidence': ['utils.py: 3 functions over 100 lines'],
                'frequency': 'per-feature',
                'impact': 'medium',
                'root_cause': 'Lack of decomposition',
                'score': 6.0
            }
        ],
        'metadata': {
            'total_patterns_found': 1,
            'api_method': 'mock'
        }
    }

    # Save to temporary file
    import tempfile
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(analysis_data, f, indent=2)
        json_file = f.name

    print(f"Created analysis file: {json_file}")

    # Generate tests
    generator = TestGenerator(mock=True)

    # Read patterns from file
    with open(json_file, 'r') as f:
        data = json.load(f)

    results = generator.generate_all_tests(data['patterns'])

    print(f"\nGenerated {len(results)} test(s):")
    for result in results:
        print(f"  - {result['filename']}")
        print(f"    Valid: {result['validation']['is_valid']}")
        print(f"    Code length: {len(result['test_code'])} characters")

    # Cleanup
    Path(json_file).unlink()


def example_write_to_files():
    """Example 4: Write generated tests to files."""
    print("\n" + "=" * 60)
    print("Example 4: Write Tests to Files")
    print("=" * 60)

    pattern = {
        'name': 'Bare Except',
        'description': 'Using bare except clauses',
        'evidence': ['error_handler.py: 4 occurrences'],
        'frequency': 'monthly',
        'impact': 'medium',
        'root_cause': 'Quick error suppression'
    }

    generator = TestGenerator(mock=True)
    result = generator.generate_test(pattern)

    # Write to temporary directory
    import tempfile
    with tempfile.TemporaryDirectory() as tmpdir:
        output_dir = Path(tmpdir) / 'tests'

        written_files = generator.write_test_files([result], output_dir)

        print(f"Wrote {len(written_files)} file(s) to {output_dir}")

        for filepath in written_files:
            print(f"\n  {filepath.name}:")
            print(f"    Size: {filepath.stat().st_size} bytes")
            print(f"    Executable: {bool(filepath.stat().st_mode & 0o111)}")

            # Try to run with pytest
            pytest_result = subprocess.run(
                ['python3', '-m', 'pytest', str(filepath), '--collect-only'],
                capture_output=True,
                text=True
            )

            if pytest_result.returncode == 0:
                print("    ✓ Pytest collection successful")
            else:
                print("    ✗ Pytest collection failed")


def example_validation():
    """Example 5: Validate generated test syntax."""
    print("\n" + "=" * 60)
    print("Example 5: Test Validation")
    print("=" * 60)

    generator = TestGenerator(mock=True)

    # Valid Python code
    valid_code = '''
def test_example():
    """Test docstring"""
    assert True
'''

    is_valid, error = generator._validate_python_syntax(valid_code)
    print(f"Valid code: is_valid={is_valid}, error={error}")

    # Invalid Python code
    invalid_code = '''
def test_example()
    """Missing colon"""
    assert True
'''

    is_valid, error = generator._validate_python_syntax(invalid_code)
    print(f"Invalid code: is_valid={is_valid}, error={error}")


def example_cli_usage():
    """Example 6: Using the CLI interface."""
    print("\n" + "=" * 60)
    print("Example 6: CLI Usage")
    print("=" * 60)

    print("CLI commands you can run:\n")

    commands = [
        ("Generate from file", "python3 generate_tests.py --input patterns.json --mock"),
        ("Validate existing tests", "python3 generate_tests.py --output-dir .haunt/tests/patterns --validate-only"),
        ("Dry run", "python3 generate_tests.py --input patterns.json --mock --dry-run"),
        ("Pipeline from analyze", "python3 analyze.py --input signals.json --mock | python3 generate_tests.py --mock"),
    ]

    for description, command in commands:
        print(f"  {description}:")
        print(f"    $ {command}\n")


def main():
    """Run all examples."""
    print("Pattern Detection: Test Generation Examples")
    print("=" * 60)

    examples = [
        example_basic_usage,
        example_multiple_patterns,
        example_from_json_file,
        example_write_to_files,
        example_validation,
        example_cli_usage,
    ]

    for example_func in examples:
        try:
            example_func()
        except Exception as e:
            print(f"\nError in {example_func.__name__}: {e}")
            import traceback
            traceback.print_exc()

    print("\n" + "=" * 60)
    print("Examples complete!")
    print("=" * 60)


if __name__ == '__main__':
    main()
