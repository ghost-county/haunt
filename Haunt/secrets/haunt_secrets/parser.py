"""Parse .env files to identify secrets using tag-based comments."""

import sys
from pathlib import Path
from typing import Dict, Union

# Tag format constants
SECRET_TAG_PREFIX = "# @secret:op:"
REQUIRED_TAG_PARTS = 3  # vault/item/field


def parse_env_content(content: str) -> Dict[str, Dict[str, str]]:
    """
    Parse .env file content and extract tagged secrets.

    Tag format: # @secret:op:vault/item/field

    Args:
        content: String content of .env file

    Returns:
        Dict mapping variable names to secret metadata:
        {
            "VAR_NAME": {
                "vault": "vault_name",
                "item": "item_name",
                "field": "field_name"
            }
        }

    Examples:
        >>> content = '''# @secret:op:prod/database/password
        ... DB_PASSWORD=placeholder
        ... '''
        >>> result = parse_env_content(content)
        >>> result["DB_PASSWORD"]["vault"]
        'prod'
    """
    secrets = {}
    lines = content.splitlines()

    # Track the last seen tag
    last_tag = None

    for line in lines:
        line = line.strip()

        if _is_secret_tag(line):
            last_tag = _parse_secret_tag(line)
        elif _is_variable_assignment(line):
            if last_tag is not None:
                var_name = _extract_variable_name(line)
                secrets[var_name] = last_tag
                last_tag = None

    return secrets


def _is_secret_tag(line: str) -> bool:
    """Check if line is a secret tag comment."""
    return line.startswith(SECRET_TAG_PREFIX)


def _is_variable_assignment(line: str) -> bool:
    """Check if line is a variable assignment (not a comment)."""
    return "=" in line and not line.startswith("#")


def _extract_variable_name(line: str) -> str:
    """Extract variable name from assignment line."""
    return line.split("=")[0].strip()


def _parse_secret_tag(line: str) -> Dict[str, str] | None:
    """
    Parse secret tag and return metadata dict or None if malformed.

    Args:
        line: Line containing secret tag (e.g., "# @secret:op:vault/item/field")

    Returns:
        Dict with vault/item/field keys, or None if malformed
    """
    tag_content = line[len(SECRET_TAG_PREFIX):].strip()
    parts = tag_content.split("/")

    if len(parts) == REQUIRED_TAG_PARTS:
        vault, item, field = parts
        return {
            "vault": vault,
            "item": item,
            "field": field
        }
    else:
        print(
            f"WARNING: Malformed secret tag (expected {REQUIRED_TAG_PARTS} parts, got {len(parts)}): {line}",
            file=sys.stderr
        )
        return None


def parse_env_file(path: Union[str, Path]) -> Dict[str, Dict[str, str]]:
    """
    Parse .env file from filesystem and extract tagged secrets.

    Args:
        path: Path to .env file (string or Path object)

    Returns:
        Dict mapping variable names to secret metadata (same as parse_env_content)

    Raises:
        FileNotFoundError: If file does not exist

    Examples:
        >>> result = parse_env_file(".env")
        >>> "API_KEY" in result
        True
    """
    path_obj = Path(path)

    if not path_obj.exists():
        raise FileNotFoundError(f"File not found: {path}")

    content = path_obj.read_text()
    return parse_env_content(content)
