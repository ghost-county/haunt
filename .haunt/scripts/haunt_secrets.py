"""
haunt_secrets.py - Tag Parser and 1Password CLI Wrapper for Secret Management

This module provides functionality to:
1. Parse 1Password secret references from .env files (REQ-298)
2. Fetch secrets from 1Password using the `op` CLI (REQ-300)
3. Load secrets into environment (load_secrets) or return as dict (get_secrets) (REQ-302)

Secret tags use the format: # @secret:op:vault/item/field

Example .env file:
    # @secret:op:ghost-county/api-keys/github-token
    GITHUB_TOKEN=placeholder

    PLAINTEXT_VAR=some-value

Main API Usage:

    Mode 1: Modify os.environ directly
    >>> from haunt_secrets import load_secrets
    >>> load_secrets(".env")
    >>> token = os.environ["GITHUB_TOKEN"]  # actual secret from 1Password

    Mode 2: Get dict without modifying environment
    >>> from haunt_secrets import get_secrets
    >>> secrets = get_secrets(".env")
    >>> token = secrets["GITHUB_TOKEN"]  # actual secret from 1Password

Lower-level functions:
- parse_secret_tags(env_file) -> Dict[str, Tuple[str, str, str]]
- fetch_secret(vault, item, field) -> str

========== OUTPUT MASKING IMPLEMENTATION (REQ-303) ==========

This module prevents secret exposure through comprehensive output masking:

1. LOGGING REDACTION:
   - Only variable NAMES logged, never VALUES
   - Implementation: logger.info(f"Loading secret for {var_name}") at line 258
   - Secret values NEVER passed to logger

2. ERROR MESSAGE SANITIZATION:
   - Exceptions show metadata (vault/item/field names) but NEVER secret values
   - Example: AuthenticationError("1Password authentication failed")
   - Example: SecretNotFoundError(f"...Verify vault='{vault}', item='{item}'...")
   - Implementation: Error messages constructed from function parameters (metadata)

3. LOGGING CONFIGURATION:
   - Module logger: logger = logging.getLogger(__name__)
   - Callers can configure log level and handlers
   - No secret values ever reach logging system

4. SECURITY MARKERS IN CODE:
   - Line 258: logger.info(f"Loading secret for {var_name}")  # Name only
   - Line 287: logger.info(f"Loaded {len(secrets_dict)} secrets...")  # Count only
   - Line 417: logger.info(f"Fetching secret from 1Password: vault={vault}...")  # Metadata
   - Line 434: # SECURITY: Never log the actual secret value

Anti-Leak Architecture:
  - Function parameters: Metadata only (vault, item, field, var_name)
  - Return values: Secret values (string) - caller responsible for secure handling
  - Logging: Variable names and metadata only (never values)
  - Exceptions: Metadata in messages (vault/item/field names, not values)

Test Coverage:
  - Haunt/tests/test_haunt_secrets.py::TestAntiLeakProtection (anti-leak tests)
  - Haunt/tests/test_haunt_secrets.py (functional tests)

==================================================================
"""

import os
import re
import subprocess
import logging
from pathlib import Path
from typing import Dict, Tuple


# Configure logging
logger = logging.getLogger(__name__)

# Constants for tag format
SECRET_TAG_PREFIX = "@secret:op:"
EXPECTED_TAG_PARTS = 3
TAG_SEPARATOR = "/"

# Constants for 1Password CLI
OP_CLI_COMMAND = "op"
OP_TOKEN_ENV_VAR = "OP_SERVICE_ACCOUNT_TOKEN"


# ========== EXCEPTION CLASSES ==========

class SecretTagError(Exception):
    """Exception raised for malformed secret tags or invalid .env file structure"""
    pass


class MissingTokenError(Exception):
    """Exception raised when OP_SERVICE_ACCOUNT_TOKEN environment variable is not set"""
    pass


class OpNotInstalledError(Exception):
    """Exception raised when the 1Password CLI (op) is not installed or not found"""
    pass


class AuthenticationError(Exception):
    """Exception raised when 1Password authentication fails"""
    pass


class SecretNotFoundError(Exception):
    """Exception raised when vault, item, or field is not found in 1Password"""
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


def load_secrets(env_file: str) -> None:
    """
    Load secrets from .env file and set them in os.environ.

    This function:
    1. Parses secret tags from the .env file
    2. Fetches tagged secrets from 1Password
    3. Loads plaintext variables from the .env file
    4. Sets all variables in os.environ

    Args:
        env_file: Path to .env file

    Returns:
        None - modifies os.environ directly

    Raises:
        FileNotFoundError: If env_file doesn't exist
        SecretTagError: If secret tags are malformed
        MissingTokenError: If OP_SERVICE_ACCOUNT_TOKEN not set
        OpNotInstalledError: If op CLI not installed
        AuthenticationError: If 1Password auth fails
        SecretNotFoundError: If vault/item/field not found

    Security:
        - Logs variable names loaded, NEVER secret values
        - All 1Password communication uses secure op CLI

    Example:
        >>> load_secrets(".env")
        >>> token = os.environ["GITHUB_TOKEN"]  # actual secret value
    """
    # Parse secret tags
    secret_tags = parse_secret_tags(env_file)

    # Fetch secrets from 1Password
    secrets_dict = {}
    for var_name, (vault, item, field) in secret_tags.items():
        logger.info(f"Loading secret for {var_name}")
        secret_value = fetch_secret(vault, item, field)
        secrets_dict[var_name] = secret_value

    # Parse plaintext variables from .env file
    plaintext_vars = {}
    with open(env_file, 'r') as f:
        for line in f:
            line = line.strip()
            # Skip comments, empty lines, and secret tags
            if not line or line.startswith('#'):
                continue
            # Match VAR_NAME=value pattern
            if '=' in line:
                var_name, value = line.split('=', 1)
                var_name = var_name.strip()
                value = value.strip()
                # Only add if not a secret (secrets are already fetched)
                if var_name not in secrets_dict:
                    plaintext_vars[var_name] = value
                    logger.info(f"Loading plaintext variable {var_name}")

    # Set all variables in os.environ
    for var_name, value in secrets_dict.items():
        os.environ[var_name] = value

    for var_name, value in plaintext_vars.items():
        os.environ[var_name] = value

    logger.info(f"Loaded {len(secrets_dict)} secrets and {len(plaintext_vars)} plaintext variables")


def get_secrets(env_file: str) -> Dict[str, str]:
    """
    Get secrets from .env file without modifying os.environ.

    This function:
    1. Parses secret tags from the .env file
    2. Fetches tagged secrets from 1Password
    3. Loads plaintext variables from the .env file
    4. Returns dict with all variables

    Args:
        env_file: Path to .env file

    Returns:
        Dict mapping variable names to values (both secrets and plaintext)

    Raises:
        FileNotFoundError: If env_file doesn't exist
        SecretTagError: If secret tags are malformed
        MissingTokenError: If OP_SERVICE_ACCOUNT_TOKEN not set
        OpNotInstalledError: If op CLI not installed
        AuthenticationError: If 1Password auth fails
        SecretNotFoundError: If vault/item/field not found

    Security:
        - Logs variable names loaded, NEVER secret values
        - All 1Password communication uses secure op CLI

    Example:
        >>> secrets = get_secrets(".env")
        >>> token = secrets["GITHUB_TOKEN"]  # actual secret value
    """
    # Parse secret tags
    secret_tags = parse_secret_tags(env_file)

    # Fetch secrets from 1Password
    secrets_dict = {}
    for var_name, (vault, item, field) in secret_tags.items():
        logger.info(f"Fetching secret for {var_name}")
        secret_value = fetch_secret(vault, item, field)
        secrets_dict[var_name] = secret_value

    # Parse plaintext variables from .env file
    plaintext_vars = {}
    with open(env_file, 'r') as f:
        for line in f:
            line = line.strip()
            # Skip comments, empty lines, and secret tags
            if not line or line.startswith('#'):
                continue
            # Match VAR_NAME=value pattern
            if '=' in line:
                var_name, value = line.split('=', 1)
                var_name = var_name.strip()
                value = value.strip()
                # Only add if not a secret (secrets are already fetched)
                if var_name not in secrets_dict:
                    plaintext_vars[var_name] = value

    # Combine and return
    result = {**secrets_dict, **plaintext_vars}
    logger.info(f"Retrieved {len(secrets_dict)} secrets and {len(plaintext_vars)} plaintext variables")

    return result


class ValidationResult:
    """Result of validate_secrets() operation"""
    def __init__(self, success: bool, validated: list = None, missing: list = None):
        self.success = success
        self.validated = validated or []
        self.missing = missing or []


def validate_secrets(env_file: str, debug: bool = False) -> ValidationResult:
    """
    Validate that all secrets in .env file are resolvable WITHOUT fetching/exporting them.

    This function checks if all tagged secrets can be retrieved from 1Password
    without modifying os.environ or actually storing the secret values.

    Args:
        env_file: Path to .env file
        debug: If True, print detailed diagnostics to stderr

    Returns:
        ValidationResult with:
            - success: True if all secrets resolvable, False otherwise
            - validated: List of successfully resolved variable names
            - missing: List of tuples (var_name, op_reference, error_msg) for failures

    Raises:
        FileNotFoundError: If env_file doesn't exist
        SecretTagError: If secret tags are malformed

    Example:
        >>> result = validate_secrets(".env", debug=True)
        >>> if result.success:
        ...     print(f"All {len(result.validated)} secrets are valid")
        ... else:
        ...     print(f"Missing: {result.missing}")
    """
    # Parse secret tags
    if debug:
        logger.info(f"Parsing secret tags from {env_file}")

    secret_tags = parse_secret_tags(env_file)

    if not secret_tags:
        logger.info("No secret tags found in .env file")
        return ValidationResult(success=True, validated=[], missing=[])

    if debug:
        logger.info(f"Found {len(secret_tags)} secret tag(s) to validate")

    # Validate each secret
    validated = []
    missing = []

    for var_name, (vault, item, field) in secret_tags.items():
        op_ref = f"op://{vault}/{item}/{field}"

        if debug:
            logger.info(f"Checking {var_name} → {op_ref}")

        try:
            # Attempt to fetch secret (validates it exists and is accessible)
            _ = fetch_secret(vault, item, field)

            if debug:
                logger.info(f"✓ {var_name} is resolvable")

            validated.append(var_name)

        except (MissingTokenError, OpNotInstalledError, AuthenticationError, SecretNotFoundError) as e:
            error_msg = str(e)

            if debug:
                logger.error(f"✗ {var_name} failed validation: {error_msg}")

            missing.append((var_name, op_ref, error_msg))

    # Report summary
    if missing:
        logger.error(f"Validation failed for {len(missing)} secret(s)")
        for var_name, op_ref, error_msg in missing:
            logger.error(f"  - {var_name} ({op_ref}): {error_msg}")
        return ValidationResult(success=False, validated=validated, missing=missing)
    else:
        logger.info(f"✓ Validated {len(validated)} secret(s): {', '.join(validated)}")
        return ValidationResult(success=True, validated=validated, missing=[])


def fetch_secret(vault: str, item: str, field: str) -> str:
    """
    Fetch a secret value from 1Password using the `op` CLI.

    Args:
        vault: Name of the 1Password vault
        item: Name of the item within the vault
        field: Name of the field within the item

    Returns:
        The secret value as a string

    Raises:
        TypeError: If vault, item, or field are not strings
        ValueError: If vault, item, or field are empty strings
        MissingTokenError: If OP_SERVICE_ACCOUNT_TOKEN environment variable not set
        OpNotInstalledError: If the `op` CLI is not installed or not found
        AuthenticationError: If 1Password authentication fails
        SecretNotFoundError: If vault, item, or field doesn't exist in 1Password

    Security:
        - Secret values are NEVER logged (only metadata like variable names)
        - Secrets exist in memory only, never written to disk
        - Uses OP_SERVICE_ACCOUNT_TOKEN from environment for authentication

    Example:
        >>> token = fetch_secret("my-vault", "api-keys", "github-token")
        >>> # Use token securely...
    """
    # Input validation - type checking
    if not isinstance(vault, str):
        raise TypeError(f"vault must be str, got {type(vault).__name__}")
    if not isinstance(item, str):
        raise TypeError(f"item must be str, got {type(item).__name__}")
    if not isinstance(field, str):
        raise TypeError(f"field must be str, got {type(field).__name__}")

    # Input validation - empty string checking
    if not vault:
        raise ValueError("vault must not be empty")
    if not item:
        raise ValueError("item must not be empty")
    if not field:
        raise ValueError("field must not be empty")

    # Check for service account token
    token = os.environ.get(OP_TOKEN_ENV_VAR)
    if not token:
        raise MissingTokenError(
            f"{OP_TOKEN_ENV_VAR} environment variable is not set. "
            "Set it to your 1Password service account token."
        )

    # Construct op:// reference format
    op_reference = f"op://{vault}/{item}/{field}"

    # Build command
    command = [OP_CLI_COMMAND, "read", op_reference]

    # Execute op CLI command
    try:
        logger.info(f"Fetching secret from 1Password: vault={vault}, item={item}, field={field}")
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False  # Don't raise on non-zero exit - we handle errors manually
        )
    except FileNotFoundError as e:
        logger.error(f"1Password CLI (op) not found: {e}")
        raise OpNotInstalledError(
            f"1Password CLI (op) is not installed or not found in PATH. "
            f"Install it from: https://developer.1password.com/docs/cli"
        )

    # Check for success
    if result.returncode == 0:
        secret_value = result.stdout.strip()
        logger.info(f"Successfully fetched secret for vault={vault}, item={item}, field={field}")
        # SECURITY: Never log the actual secret value
        return secret_value

    # Handle errors based on stderr content
    stderr = result.stderr.lower()

    # Authentication errors
    if "invalid service account token" in stderr or "authentication" in stderr:
        logger.error(f"1Password authentication failed: {result.stderr.strip()}")
        raise AuthenticationError(
            f"1Password authentication failed. Check that {OP_TOKEN_ENV_VAR} is valid."
        )

    # Not found errors (vault, item, or field)
    if "not found" in stderr:
        logger.error(f"Secret not found: {result.stderr.strip()}")
        raise SecretNotFoundError(
            f"Secret not found in 1Password. "
            f"Verify vault='{vault}', item='{item}', field='{field}' exist. "
            f"Error: {result.stderr.strip()}"
        )

    # Generic error fallback
    logger.error(f"1Password CLI error: {result.stderr.strip()}")
    raise SecretNotFoundError(
        f"Failed to fetch secret from 1Password. Error: {result.stderr.strip()}"
    )
