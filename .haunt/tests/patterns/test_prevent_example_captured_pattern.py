#!/usr/bin/env python3
"""
Pattern Defeat Test: Example Captured Pattern (DEMONSTRATION)

Pattern Name: example-captured-pattern
Description: This is a demonstration of auto-generated skeleton test created via /pattern capture command
Discovered: 2025-12-18
Requirement: REQ-237 (Pattern Capture Automation)
Agent: Code-Reviewer
Severity: MEDIUM

Status: SKELETON - This is a demonstration example

TODO:
1. Add specific regex pattern or AST detection logic
2. Define file scope (*.py, *.js, specific directories)
3. Add example violations from actual code
4. Test the test to verify it catches the pattern
5. Update status from SKELETON to ACTIVE

This test demonstrates the structure of auto-generated pattern defeat tests
created when Code Reviewer identifies recurring anti-patterns during review.
"""

import re
from pathlib import Path


def test_prevent_example_captured_pattern():
    """
    Detect example-captured-pattern in codebase.

    Anti-Pattern: [Description of what the pattern is]
    Impact: [Why it's problematic]

    Example WRONG:
    # Code that demonstrates the anti-pattern

    Example RIGHT:
    # Code that shows the correct approach
    """
    project_root = Path(__file__).parent.parent.parent
    violations = []

    # TODO: Define which files to scan (adjust as needed)
    # Examples:
    # - project_root.rglob("*.py") for all Python files
    # - project_root.rglob("src/**/*.js") for JS files in src/
    # - (project_root / "specific_dir").rglob("*.py") for specific directory
    target_files = project_root.rglob("*.py")

    # TODO: Define the detection pattern (adjust regex or use AST)
    # Examples:
    # - r'\.get\([^,]+,\s*(0|None)\)' for silent fallbacks
    # - r'password\s*=\s*["\'].+["\']' for hardcoded secrets
    # - Use ast.parse() for more complex patterns
    pattern = r'PLACEHOLDER_PATTERN_REGEX'

    for file_path in target_files:
        # Skip test files themselves
        if 'test_' in file_path.name or 'tests/' in str(file_path):
            continue

        # Skip this demonstration file
        if file_path.name == 'test_prevent_example_captured_pattern.py':
            continue

        try:
            content = file_path.read_text()
            lines = content.split('\n')

            for line_num, line in enumerate(lines, 1):
                # TODO: Add detection logic
                # Basic regex example:
                if re.search(pattern, line):
                    # TODO: Add context analysis (is this actually problematic?)
                    # You may want to skip certain contexts:
                    # - Comments
                    # - Test fixtures
                    # - Configuration files
                    violations.append({
                        'file': str(file_path.relative_to(project_root)),
                        'line': line_num,
                        'content': line.strip()
                    })
        except Exception:
            # Skip files that can't be read
            continue

    # TODO: Adjust assertion message for clarity
    if violations:
        error_msg = "Example captured pattern detected:\n"
        for v in violations[:10]:  # Limit output to first 10 violations
            error_msg += f"  {v['file']}:{v['line']} - {v['content']}\n"
        error_msg += "\nFix: [Describe how to fix the pattern]"
        assert False, error_msg


def test_demonstration_metadata():
    """
    Verify this skeleton test has all required metadata.

    This meta-test validates the structure of auto-generated pattern tests.
    """
    # Read this file to verify metadata
    this_file = Path(__file__)
    content = this_file.read_text()

    # Check required metadata fields
    required_fields = [
        'Pattern Name:',
        'Description:',
        'Discovered:',
        'Requirement:',
        'Agent:',
        'Severity:',
        'Status:',
        'TODO:',
    ]

    for field in required_fields:
        assert field in content, f"Missing required metadata field: {field}"

    # Verify TODO checklist exists
    assert '1. Add specific regex pattern or AST detection logic' in content
    assert '2. Define file scope' in content
    assert '3. Add example violations' in content
    assert '4. Test the test' in content
    assert '5. Update status from SKELETON to ACTIVE' in content

    # Verify example sections exist
    assert 'Example WRONG:' in content
    assert 'Example RIGHT:' in content


if __name__ == "__main__":
    # Allow running test standalone for verification
    print("Running demonstration pattern defeat test: example-captured-pattern\n")

    # Test 1: Main pattern detection
    try:
        test_prevent_example_captured_pattern()
        print("✓ No violations detected (or pattern not yet defined)")
    except AssertionError as e:
        print(f"✗ Pattern detected:\n{e}")

    # Test 2: Metadata validation
    print("\n" + "="*60)
    try:
        test_demonstration_metadata()
        print("✓ Test skeleton has all required metadata")
    except AssertionError as e:
        print(f"✗ Metadata validation failed:\n{e}")

    print("\n" + "="*60)
    print("\nThis is a SKELETON test demonstrating pattern capture automation.")
    print("\nNext steps:")
    print("1. Replace PLACEHOLDER_PATTERN_REGEX with actual detection pattern")
    print("2. Define file scope (which files to scan)")
    print("3. Add example violations from actual code")
    print("4. Run: pytest .haunt/tests/patterns/test_prevent_example_captured_pattern.py")
    print("5. Update status from SKELETON to ACTIVE")
    print("6. Add to .pre-commit-config.yaml")
    print("\nSee: Haunt/commands/pattern.md for full documentation")
