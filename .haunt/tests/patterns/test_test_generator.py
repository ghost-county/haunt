#!/usr/bin/env python3
"""
Test suite for defeat test generator module.

Tests the pattern-detector/generate_tests.py functionality:
- Pattern slug generation
- Syntax validation
- Mock template generation
- File writing
"""

import ast
import sys
import tempfile
from pathlib import Path

# Add pattern-detector to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'Haunt' / 'scripts' / 'rituals' / 'pattern-detector'))

from generate_tests import TestGenerator


def test_pattern_slug_generation():
    """Test conversion of pattern names to valid Python identifiers."""
    generator = TestGenerator(mock=True)

    test_cases = [
        ("Silent Fallback Pattern", "silent_fallback_pattern"),
        ("Missing Error Context", "missing_error_context"),
        ("God Functions (>50 lines)", "god_functions_50_lines"),
        ("Inconsistent-File-Path-Handling", "inconsistent_file_path_handling"),
        ("UPPERCASE PATTERN", "uppercase_pattern"),
        ("Pattern   with   spaces", "pattern_with_spaces"),
    ]

    for input_name, expected_slug in test_cases:
        actual_slug = generator._generate_pattern_slug(input_name)
        assert actual_slug == expected_slug, f"Expected '{expected_slug}', got '{actual_slug}'"


def test_python_syntax_validation():
    """Test validation of generated Python code."""
    generator = TestGenerator(mock=True)

    # Valid Python code
    valid_code = '''
def test_example():
    """Test docstring"""
    assert True
'''
    is_valid, error = generator._validate_python_syntax(valid_code)
    assert is_valid, f"Valid code rejected: {error}"
    assert error is None

    # Invalid Python code
    invalid_code = '''
def test_example()
    """Missing colon"""
    assert True
'''
    is_valid, error = generator._validate_python_syntax(invalid_code)
    assert not is_valid, "Invalid code accepted"
    assert error is not None
    assert "Syntax error" in error or "Parse error" in error


def test_claude_response_cleaning():
    """Test cleaning of Claude's markdown-wrapped responses."""
    generator = TestGenerator(mock=True)

    # Response with markdown code blocks
    response_with_blocks = '''```python
def test_example():
    """Test"""
    pass
```'''

    cleaned = generator._clean_claude_response(response_with_blocks)
    assert not cleaned.startswith('```')
    assert not cleaned.endswith('```')
    assert 'def test_example' in cleaned

    # Response without markdown
    response_plain = '''def test_example():
    """Test"""
    pass'''

    cleaned = generator._clean_claude_response(response_plain)
    assert 'def test_example' in cleaned


def test_mock_template_generation():
    """Test generation of mock templates for common patterns."""
    generator = TestGenerator(mock=True)

    # Test silent fallback pattern
    pattern = {
        'name': 'Silent Fallback Pattern',
        'description': 'Using .get() with defaults',
        'evidence': ['file.py: modified 5 times'],
        'frequency': 'weekly',
        'impact': 'high',
        'root_cause': 'Convenience over safety'
    }

    result = generator.generate_test(pattern)

    assert result['pattern_name'] == 'Silent Fallback Pattern'
    assert result['pattern_slug'] == 'silent_fallback_pattern'
    assert result['filename'] == 'test_silent_fallback_pattern.py'
    assert result['validation']['is_valid'], f"Validation failed: {result['validation']['error']}"
    assert 'def test_no_silent_fallback' in result['test_code']
    assert '"""' in result['test_code']  # Has docstring


def test_generate_test_for_pattern():
    """Test generating a defeat test for a pattern."""
    generator = TestGenerator(mock=True)

    pattern = {
        'name': 'Missing Error Context',
        'description': 'Raising exceptions without context',
        'evidence': [
            'auth.py: 3 commits adding context',
            'api.py: modified 4 times'
        ],
        'frequency': 'per-feature',
        'impact': 'medium',
        'root_cause': 'Focus on happy path first'
    }

    result = generator.generate_test(pattern)

    # Check result structure
    assert 'pattern_name' in result
    assert 'pattern_slug' in result
    assert 'test_code' in result
    assert 'validation' in result
    assert 'filename' in result

    # Check validation
    assert result['validation']['is_valid'], f"Syntax error: {result['validation']['error']}"

    # Check test code content
    code = result['test_code']
    assert 'def test_' in code
    assert '"""' in code  # Has docstring
    assert 'import' in code  # Has imports
    assert 'assert' in code  # Has assertions

    # Verify it's actually valid Python
    try:
        ast.parse(code)
    except SyntaxError as e:
        assert False, f"Generated code has syntax error: {e}"


def test_generate_multiple_tests():
    """Test generating tests for multiple patterns."""
    generator = TestGenerator(mock=True)

    patterns = [
        {
            'name': 'Pattern One',
            'description': 'First pattern',
            'evidence': ['file1.py'],
            'frequency': 'daily',
            'impact': 'high',
            'root_cause': 'Reason 1'
        },
        {
            'name': 'Pattern Two',
            'description': 'Second pattern',
            'evidence': ['file2.py'],
            'frequency': 'weekly',
            'impact': 'medium',
            'root_cause': 'Reason 2'
        }
    ]

    results = generator.generate_all_tests(patterns)

    assert len(results) == 2
    assert results[0]['pattern_name'] == 'Pattern One'
    assert results[1]['pattern_name'] == 'Pattern Two'
    assert all(r['validation']['is_valid'] for r in results)


def test_write_test_files():
    """Test writing generated tests to files."""
    generator = TestGenerator(mock=True)

    pattern = {
        'name': 'Test Pattern',
        'description': 'Test description',
        'evidence': ['test.py'],
        'frequency': 'weekly',
        'impact': 'medium',
        'root_cause': 'Test reason'
    }

    result = generator.generate_test(pattern)

    # Write to temporary directory
    with tempfile.TemporaryDirectory() as tmpdir:
        output_dir = Path(tmpdir) / 'tests'
        written_files = generator.write_test_files([result], output_dir)

        assert len(written_files) == 1
        assert written_files[0].exists()
        assert written_files[0].name == 'test_test_pattern.py'

        # Verify content
        content = written_files[0].read_text()
        assert 'def test_' in content

        # Verify file is executable
        assert written_files[0].stat().st_mode & 0o111  # Has execute bit


def test_skip_invalid_tests():
    """Test that invalid tests are not written to files."""
    generator = TestGenerator(mock=True)

    # Create a result with invalid syntax
    invalid_result = {
        'pattern_name': 'Invalid Pattern',
        'pattern_slug': 'invalid_pattern',
        'test_code': 'def test_invalid(\n    # Missing colon',
        'validation': {
            'is_valid': False,
            'error': 'Syntax error'
        },
        'filename': 'test_invalid_pattern.py'
    }

    with tempfile.TemporaryDirectory() as tmpdir:
        output_dir = Path(tmpdir) / 'tests'
        written_files = generator.write_test_files([invalid_result], output_dir)

        # Should not write invalid test
        assert len(written_files) == 0


def test_generated_test_can_run():
    """Test that generated tests can actually be executed with pytest."""
    generator = TestGenerator(mock=True)

    pattern = {
        'name': 'Silent Fallback',
        'description': 'Using .get() with defaults',
        'evidence': ['test.py'],
        'frequency': 'weekly',
        'impact': 'high',
        'root_cause': 'Convenience'
    }

    result = generator.generate_test(pattern)

    # Write to temporary file and try to import it
    with tempfile.TemporaryDirectory() as tmpdir:
        test_file = Path(tmpdir) / 'test_generated.py'
        test_file.write_text(result['test_code'])

        # Try to compile and execute the test
        try:
            code = compile(result['test_code'], str(test_file), 'exec')
            namespace = {}
            exec(code, namespace)

            # Verify test function exists
            test_funcs = [k for k in namespace.keys() if k.startswith('test_')]
            assert len(test_funcs) > 0, "No test functions found in generated code"

        except Exception as e:
            assert False, f"Generated test failed to execute: {e}"


if __name__ == '__main__':
    # Run tests manually
    print("Running test generator tests...\n")

    tests = [
        ("Pattern slug generation", test_pattern_slug_generation),
        ("Python syntax validation", test_python_syntax_validation),
        ("Claude response cleaning", test_claude_response_cleaning),
        ("Mock template generation", test_mock_template_generation),
        ("Generate test for pattern", test_generate_test_for_pattern),
        ("Generate multiple tests", test_generate_multiple_tests),
        ("Write test files", test_write_test_files),
        ("Skip invalid tests", test_skip_invalid_tests),
        ("Generated test can run", test_generated_test_can_run),
    ]

    passed = 0
    failed = 0

    for name, test_func in tests:
        try:
            test_func()
            print(f"✓ {name}")
            passed += 1
        except AssertionError as e:
            print(f"✗ {name}: {e}")
            failed += 1
        except Exception as e:
            print(f"✗ {name}: Unexpected error: {e}")
            failed += 1

    print(f"\n{passed} passed, {failed} failed")
    sys.exit(0 if failed == 0 else 1)
