#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///

"""
Write Tool Damage Control Hook

Prevents Claude Code from writing to sensitive directories containing secrets and credentials.

Exit Codes:
  0 = ALLOW (file_path is safe to write)
  2 = BLOCK (file_path matches zeroAccessPaths)

Input: JSON on stdin with tool_name and tool_input
Output: Exit code 0 (allow) or 2 (block)

Pattern File: patterns.yaml (same directory as this script)
"""

import json
import sys
from pathlib import Path
import yaml


def load_patterns(script_path: Path) -> dict:
    """Load patterns.yaml from the same directory as this script."""
    patterns_file = script_path.parent / "patterns.yaml"

    if not patterns_file.exists():
        print(f"ERROR: patterns.yaml not found at {patterns_file}", file=sys.stderr)
        sys.exit(1)

    with open(patterns_file, "r") as f:
        return yaml.safe_load(f)


def expand_path(path: str) -> Path:
    """Expand ~ and convert to absolute Path."""
    return Path(path).expanduser().resolve()


def matches_zero_access_paths(file_path: Path, zero_access_paths: list[str]) -> bool:
    """
    Check if file_path starts with any zero access path.

    Returns:
        True if file_path matches a zero access path (should be BLOCKED)
        False if file_path is safe to write
    """
    for zero_path in zero_access_paths:
        expanded_zero_path = expand_path(zero_path)

        # Check if file_path is inside or equal to zero access path
        try:
            file_path.relative_to(expanded_zero_path)
            return True  # Match found - BLOCK
        except ValueError:
            continue  # Not a match, keep checking

    return False  # No match - ALLOW


def main():
    """
    Main hook logic:
    1. Read JSON input from stdin
    2. Extract file_path from tool_input
    3. Load patterns.yaml
    4. Check if file_path matches zeroAccessPaths
    5. Exit 2 (BLOCK) if match, exit 0 (ALLOW) otherwise
    """
    # Read JSON input from stdin
    try:
        hook_input = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    # Extract file_path from tool_input
    tool_input = hook_input.get("tool_input", {})
    file_path_str = tool_input.get("file_path")

    if not file_path_str:
        print("ERROR: No file_path in tool_input", file=sys.stderr)
        sys.exit(1)

    # Expand and resolve file path
    file_path = expand_path(file_path_str)

    # Load patterns from patterns.yaml
    script_path = Path(__file__)
    patterns = load_patterns(script_path)

    # Get zeroAccessPaths from patterns
    zero_access_paths = patterns.get("zeroAccessPaths", [])

    # Check if file_path matches any zero access path
    if matches_zero_access_paths(file_path, zero_access_paths):
        # BLOCK: File is in zero access path
        print(f"BLOCKED: Cannot write to {file_path} (zero access path)", file=sys.stderr)
        sys.exit(2)

    # ALLOW: File is safe to write
    sys.exit(0)


if __name__ == "__main__":
    main()
