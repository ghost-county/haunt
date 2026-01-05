#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///

"""
Edit Tool Damage Control Hook

PreToolUse hook that intercepts Edit tool calls and blocks modifications to sensitive paths.

Input: JSON on stdin with format:
  {
    "tool_name": "Edit",
    "tool_input": {
      "file_path": "/path/to/file.txt",
      "old_string": "...",
      "new_string": "..."
    }
  }

Output:
  - Exit code 0 = ALLOW (edit is safe)
  - Exit code 2 = BLOCK (edit targets protected path)

Protected Paths:
  - zeroAccessPaths: No access whatsoever (currently: ~/.ssh/, ~/.aws/, ~/.gnupg/)
  - readOnlyPaths: Read allowed, modifications blocked (currently empty)
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Any

import yaml


def load_patterns() -> Dict[str, Any]:
    """Load protection patterns from patterns.yaml in same directory as script."""
    script_dir = Path(__file__).parent
    patterns_file = script_dir / "patterns.yaml"

    if not patterns_file.exists():
        print(f"ERROR: patterns.yaml not found at {patterns_file}", file=sys.stderr)
        sys.exit(1)

    with open(patterns_file, 'r') as f:
        return yaml.safe_load(f)


def expand_path(path_str: str) -> Path:
    """Expand ~ and environment variables in path, return resolved Path object."""
    return Path(path_str).expanduser().resolve()


def is_protected(file_path: str, protected_paths: List[str]) -> bool:
    """
    Check if file_path starts with any protected path.

    Args:
        file_path: Path to check
        protected_paths: List of protected path prefixes

    Returns:
        True if file_path is under any protected path, False otherwise
    """
    expanded_file = expand_path(file_path)

    for protected in protected_paths:
        expanded_protected = expand_path(protected)

        # Check if file_path is under protected directory
        try:
            expanded_file.relative_to(expanded_protected)
            return True
        except ValueError:
            # Not a subpath, continue checking
            continue

    return False


def main():
    """Main hook logic: parse input, check protections, return exit code."""
    # Read JSON input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    # Extract file_path from tool_input
    tool_name = input_data.get("tool_name")
    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path")

    if not file_path:
        print("ERROR: No file_path in tool_input", file=sys.stderr)
        sys.exit(1)

    # Load protection patterns
    patterns = load_patterns()
    zero_access = patterns.get("zeroAccessPaths", [])
    read_only = patterns.get("readOnlyPaths", [])

    # Check zeroAccessPaths (absolute no-access)
    if is_protected(file_path, zero_access):
        print(f"BLOCKED: Edit to {file_path} targets zero-access path (secrets/credentials)", file=sys.stderr)
        print(f"REASON: File is under protected directory containing sensitive data", file=sys.stderr)
        sys.exit(2)

    # Check readOnlyPaths (currently empty, but implement for future-proofing)
    if is_protected(file_path, read_only):
        print(f"BLOCKED: Edit to {file_path} targets read-only path", file=sys.stderr)
        print(f"REASON: Path is marked read-only in patterns.yaml", file=sys.stderr)
        sys.exit(2)

    # If no protection matched, allow the edit
    sys.exit(0)


if __name__ == "__main__":
    main()
