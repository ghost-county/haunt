#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///

"""
Bash Tool Damage Control Hook (PreToolUse)

Intercepts Bash tool calls to prevent destructive operations:
- Block dangerous patterns (rm -rf /, rm -rf ~, wildcards)
- Ask confirmation for specific path deletion
- Protect critical paths from deletion
- Block access to secrets directories

Exit Codes:
  0 = ALLOW (continue with tool execution)
  2 = BLOCK (prevent tool execution)

Output:
  JSON to stdout = ASK (prompt user for confirmation)
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML not installed. Run: uv pip install pyyaml", file=sys.stderr)
    sys.exit(2)


def load_patterns() -> dict[str, Any]:
    """Load patterns.yaml from same directory as this script."""
    script_dir = Path(__file__).parent
    patterns_file = script_dir / "patterns.yaml"

    if not patterns_file.exists():
        print(f"ERROR: patterns.yaml not found at {patterns_file}", file=sys.stderr)
        sys.exit(2)

    with open(patterns_file) as f:
        return yaml.safe_load(f)


def expand_path(path: str) -> str:
    """Expand ~ and environment variables in paths."""
    expanded = os.path.expanduser(path)
    expanded = os.path.expandvars(expanded)
    return str(Path(expanded).resolve())


def extract_paths_from_command(command: str) -> list[str]:
    """
    Extract file paths from bash command.

    Handles:
    - Simple paths: rm -rf /path/to/dir
    - Paths with spaces: rm -rf "/path with spaces"
    - Multiple paths: rm -rf path1 path2
    """
    paths = []

    # Remove command and flags, keep arguments
    # Match quoted strings or unquoted tokens
    pattern = r'"([^"]+)"|\'([^\']+)\'|(\S+)'
    tokens = re.findall(pattern, command)

    # Flatten matched groups and skip flags
    for match in tokens:
        token = next((g for g in match if g), '')
        if not token.startswith('-') and token not in ['rm', 'mv', 'chmod', 'chown']:
            paths.append(token)

    return paths


def matches_protected_path(path: str, protected_paths: list[str]) -> tuple[bool, str | None]:
    """
    Check if path matches any protected path.
    Returns: (is_protected, matched_pattern)
    """
    expanded = expand_path(path)

    for protected in protected_paths:
        protected_expanded = expand_path(protected)

        # Check if target path is inside protected path
        if expanded.startswith(protected_expanded):
            return True, protected

    return False, None


def check_bash_patterns(command: str, patterns: list[dict]) -> tuple[str, str | None]:
    """
    Check command against bash tool patterns.

    Returns: (action, reason)
      action: 'allow', 'block', 'ask'
      reason: explanation (if block or ask)
    """
    for pattern_def in patterns:
        pattern = pattern_def['pattern']
        reason = pattern_def['reason']
        ask = pattern_def.get('ask', False)

        if re.search(pattern, command, re.IGNORECASE):
            if ask:
                return 'ask', reason
            else:
                return 'block', reason

    return 'allow', None


def check_zero_access_paths(command: str, zero_access_paths: list[str]) -> tuple[bool, str | None]:
    """
    Check if command accesses zero-access paths.
    Returns: (is_blocked, reason)
    """
    paths = extract_paths_from_command(command)

    for path in paths:
        is_protected, matched = matches_protected_path(path, zero_access_paths)
        if is_protected:
            return True, f"Access to {matched} is forbidden (contains secrets/credentials)"

    return False, None


def check_no_delete_paths(command: str, no_delete_paths: list[str]) -> tuple[bool, str | None]:
    """
    Check if command attempts to delete protected paths.
    Returns: (is_blocked, reason)
    """
    # Only check for delete operations
    if not re.search(r'\brm\b|\bmv\b.*?/dev/null\b', command):
        return False, None

    paths = extract_paths_from_command(command)

    for path in paths:
        is_protected, matched = matches_protected_path(path, no_delete_paths)
        if is_protected:
            return True, f"Deletion of {matched} is forbidden (critical project path)"

    return False, None


def main():
    """Main hook entry point."""
    try:
        # Read hook input from stdin
        input_data = json.load(sys.stdin)

        # Extract command from tool input
        tool_input = input_data.get('tool_input', {})
        command = tool_input.get('command', '')

        if not command:
            # No command to check, allow
            sys.exit(0)

        # Load patterns
        patterns = load_patterns()
        bash_patterns = patterns.get('bashToolPatterns', [])
        zero_access_paths = patterns.get('zeroAccessPaths', [])
        no_delete_paths = patterns.get('noDeletePaths', [])

        # Check 1: Zero-access paths (BLOCK immediately)
        is_blocked, reason = check_zero_access_paths(command, zero_access_paths)
        if is_blocked:
            print(f"BLOCKED: {reason}", file=sys.stderr)
            sys.exit(2)

        # Check 2: No-delete paths (BLOCK if deletion detected)
        is_blocked, reason = check_no_delete_paths(command, no_delete_paths)
        if is_blocked:
            print(f"BLOCKED: {reason}", file=sys.stderr)
            sys.exit(2)

        # Check 3: Bash tool patterns (BLOCK or ASK)
        action, reason = check_bash_patterns(command, bash_patterns)

        if action == 'block':
            print(f"BLOCKED: {reason}", file=sys.stderr)
            sys.exit(2)
        elif action == 'ask':
            # Return JSON ask prompt
            ask_response = {
                "decision": "ask",
                "message": reason
            }
            print(json.dumps(ask_response, indent=2))
            sys.exit(0)

        # All checks passed, allow command
        sys.exit(0)

    except Exception as e:
        print(f"ERROR in damage control hook: {e}", file=sys.stderr)
        # On error, BLOCK to be safe
        sys.exit(2)


if __name__ == '__main__':
    main()
