#!/usr/bin/env python3
"""
Sample Pattern Detection Test

Pattern: Example Anti-Pattern Detection
Description: This is a sample test demonstrating how to detect code anti-patterns.
Created: 2025-12-10
Status: Example/Template
"""

import os
import re
from pathlib import Path


def test_no_hardcoded_secrets():
    """
    Detect hardcoded secrets in code files.

    This test scans Python files for common patterns that indicate
    hardcoded secrets such as API keys, passwords, or tokens.

    Pattern Defeated: Hardcoded secrets in source code
    """
    project_root = Path(__file__).parent.parent.parent
    python_files = list(project_root.rglob("*.py"))

    # Patterns that might indicate hardcoded secrets
    secret_patterns = [
        r'password\s*=\s*["\'](?!<|{|\$).{8,}["\']',  # password = "actual_password"
        r'api_key\s*=\s*["\'](?!<|{|\$).{20,}["\']',   # api_key = "actual_key"
        r'secret\s*=\s*["\'](?!<|{|\$).{10,}["\']',    # secret = "actual_secret"
        r'token\s*=\s*["\'](?!<|{|\$).{20,}["\']',     # token = "actual_token"
    ]

    violations = []

    for py_file in python_files:
        # Skip test files themselves
        if 'test_' in py_file.name or py_file.parent.name == 'tests':
            continue

        try:
            content = py_file.read_text()
            for pattern in secret_patterns:
                matches = re.finditer(pattern, content, re.IGNORECASE)
                for match in matches:
                    line_num = content[:match.start()].count('\n') + 1
                    violations.append({
                        'file': str(py_file.relative_to(project_root)),
                        'line': line_num,
                        'pattern': pattern,
                        'match': match.group()
                    })
        except Exception as e:
            # Skip files that can't be read
            continue

    # Assert no violations found
    if violations:
        error_msg = "Hardcoded secrets detected:\n"
        for v in violations:
            error_msg += f"  {v['file']}:{v['line']} - {v['match']}\n"
        error_msg += "\nUse environment variables or secrets management instead."
        assert False, error_msg


def test_no_print_statements_in_production():
    """
    Detect print() statements in production code.

    Print statements should be replaced with proper logging in production code.
    This test allows print() in scripts, tests, and examples.

    Pattern Defeated: Using print() instead of logging
    """
    project_root = Path(__file__).parent.parent.parent
    python_files = list(project_root.rglob("*.py"))

    violations = []

    for py_file in python_files:
        # Allow print statements in:
        # - test files
        # - scripts directory
        # - examples directory
        # - __main__ blocks
        if any(x in str(py_file) for x in ['test_', 'tests/', 'scripts/', 'examples/']):
            continue

        try:
            content = py_file.read_text()
            lines = content.split('\n')

            for i, line in enumerate(lines, 1):
                # Skip comments
                if line.strip().startswith('#'):
                    continue

                # Detect print() statements
                if re.search(r'\bprint\s*\(', line):
                    # Allow in if __name__ == "__main__" blocks
                    # This is a simple heuristic
                    context_start = max(0, i - 10)
                    context = '\n'.join(lines[context_start:i])
                    if '__name__' not in context and '__main__' not in context:
                        violations.append({
                            'file': str(py_file.relative_to(project_root)),
                            'line': i,
                            'content': line.strip()
                        })
        except Exception:
            continue

    if violations:
        error_msg = "print() statements found in production code:\n"
        for v in violations:
            error_msg += f"  {v['file']}:{v['line']} - {v['content']}\n"
        error_msg += "\nUse logging module instead of print() in production code."
        assert False, error_msg


if __name__ == "__main__":
    # Run tests if executed directly
    print("Running sample pattern detection tests...\n")

    try:
        test_no_hardcoded_secrets()
        print("✓ No hardcoded secrets detected")
    except AssertionError as e:
        print(f"✗ Hardcoded secrets test failed:\n{e}")

    try:
        test_no_print_statements_in_production()
        print("✓ No print statements in production code")
    except AssertionError as e:
        print(f"✗ Print statements test failed:\n{e}")

    print("\nPattern detection tests complete.")
