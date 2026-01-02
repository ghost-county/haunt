"""
haunt_secrets.py - Tag Parser for 1Password Secret References

This module provides functionality to parse 1Password secret references from .env files.
Secret tags use the format: # @secret:op:vault/item/field

Example:
    # @secret:op:ghost-county/api-keys/github-token
    GITHUB_TOKEN=placeholder

Returns dict mapping variable names to (vault, item, field) tuples.
"""

import re
from pathlib import Path
from typing import Dict, Tuple


# Constants for tag format
SECRET_TAG_PREFIX = "@secret:op:"
EXPECTED_TAG_PARTS = 3
TAG_SEPARATOR = "/"


class SecretTagError(Exception):
    """Exception raised for malformed secret tags or invalid .env file structure"""
    pass


def _validate_tag_format(tag_content: str, line_num: int, full_line: str) -> None:
    """
    Validate tag format and raise SecretTagError with specific error message.

    Args:
        tag_content: The content after @secret:op:
        line_num: Line number for error message (1-indexed)
        full_line: Full line content for error message

    Raises:
        SecretTagError: Always raises with specific validation error
    """
    parts = tag_content.split(TAG_SEPARATOR)

    if len(parts) != EXPECTED_TAG_PARTS:
        raise SecretTagError(
            f"Malformed secret tag on line {line_num}: '{full_line}'. "
            f"Expected format: # {SECRET_TAG_PREFIX}vault/item/field "
            f"(exactly {EXPECTED_TAG_PARTS} parts separated by '{TAG_SEPARATOR}')"
        )

    # Check if using : instead of /
    if ':' in tag_content:
        raise SecretTagError(
            f"Malformed secret tag on line {line_num}: '{full_line}'. "
            f"Use '{TAG_SEPARATOR}' to separate vault/item/field, not ':'"
        )

    # Generic malformed error
    raise SecretTagError(
        f"Malformed secret tag on line {line_num}: '{full_line}'. "
        f"Expected format: # {SECRET_TAG_PREFIX}vault/item/field"
    )


def parse_secret_tags(env_file: str) -> Dict[str, Tuple[str, str, str]]:
    """
    Parse 1Password secret tags from an .env file.

    Args:
        env_file: Path to .env file containing secret tags

    Returns:
        Dictionary mapping variable names to (vault, item, field) tuples.
        Example: {"GITHUB_TOKEN": ("ghost-county", "api-keys", "github-token")}

    Raises:
        FileNotFoundError: If env_file does not exist
        SecretTagError: If secret tags are malformed or invalid

    Tag Format:
        # @secret:op:vault/item/field
        VAR_NAME=placeholder

    The tag must be immediately followed by a variable assignment on the next line.
    """
    file_path = Path(env_file)

    # Check file exists
    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {env_file}")

    # Read file content
    with open(file_path, 'r') as f:
        lines = f.readlines()

    # Regex patterns for parsing
    tag_prefix_pattern = re.compile(rf'^\s*#\s*{re.escape(SECRET_TAG_PREFIX)}')
    tag_pattern = re.compile(
        rf'^\s*#\s*{re.escape(SECRET_TAG_PREFIX)}'
        r'([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)(?:\s|#|$)'
    )
    var_pattern = re.compile(r'^([A-Z_][A-Z0-9_]*)=')

    result: Dict[str, Tuple[str, str, str]] = {}
    i = 0

    while i < len(lines):
        line = lines[i].strip()

        # Check if line contains a secret tag
        if tag_prefix_pattern.match(lines[i]):
            # Extract tag content and remove inline comments
            tag_content = lines[i].split(SECRET_TAG_PREFIX)[1].split('#')[0].strip()

            # Validate full tag format
            tag_match = tag_pattern.match(lines[i])

            if not tag_match:
                # Tag has prefix but invalid format - provide specific error
                _validate_tag_format(tag_content, i + 1, lines[i].strip())

            vault = tag_match.group(1)
            item = tag_match.group(2)
            field = tag_match.group(3)

            # Next line must contain a variable assignment
            if i + 1 >= len(lines):
                raise SecretTagError(
                    f"Secret tag on line {i+1} has no variable assignment following it"
                )

            next_line_idx = i + 1
            next_line = lines[next_line_idx].strip()

            # Skip blank lines is NOT allowed - tag must be immediately before variable
            if not next_line:
                raise SecretTagError(
                    f"Secret tag on line {i+1} must be immediately followed by variable assignment (no blank lines)"
                )

            # Check if next line is a variable assignment
            var_match = var_pattern.match(next_line)
            if not var_match:
                raise SecretTagError(
                    f"Secret tag on line {i+1} is not followed by a variable assignment. "
                    f"Found: '{next_line}'"
                )

            var_name = var_match.group(1)

            # Check for duplicate variable names
            if var_name in result:
                raise SecretTagError(
                    f"Duplicate secret tag for variable '{var_name}' (line {i+1})"
                )

            result[var_name] = (vault, item, field)

            # Skip the variable line since we processed it
            i += 2
            continue

        i += 1

    return result
