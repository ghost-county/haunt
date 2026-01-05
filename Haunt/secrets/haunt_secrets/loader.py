"""Load secrets from 1Password via subprocess and expose as environment variables or dict."""

import os
import subprocess
from pathlib import Path
from typing import Dict, Union

from .parser import parse_env_file
from .redaction import register_secret


def load_secrets(path: Union[str, Path]) -> None:
    """
    Load secrets from .env file and export to os.environ.

    This function:
    1. Parses .env file to identify secrets (using @secret:op: tags)
    2. Fetches secrets from 1Password using op CLI
    3. Exports ALL variables (secrets + plaintext) to os.environ

    Args:
        path: Path to .env file (string or Path object)

    Returns:
        None (side-effect only - exports to os.environ)

    Raises:
        RuntimeError: If OP_SERVICE_ACCOUNT_TOKEN not set
        RuntimeError: If op command fails to fetch secret
        FileNotFoundError: If .env file not found

    Example:
        >>> load_secrets('.env')
        >>> import os
        >>> print(os.environ['DB_PASSWORD'])
        secret_value_from_1password
    """
    secrets_dict = get_secrets(path)

    # Export to environment
    for key, value in secrets_dict.items():
        os.environ[key] = value


def get_secrets(path: Union[str, Path]) -> Dict[str, str]:
    """
    Load secrets from .env file and return as dict (no side effects).

    This function:
    1. Parses .env file to identify secrets (using @secret:op: tags)
    2. Fetches secrets from 1Password using op CLI
    3. Returns dict with ALL variables (secrets + plaintext)

    Args:
        path: Path to .env file (string or Path object)

    Returns:
        Dict mapping variable names to values (both secrets and plaintext)

    Raises:
        RuntimeError: If OP_SERVICE_ACCOUNT_TOKEN not set
        RuntimeError: If op command fails to fetch secret
        FileNotFoundError: If .env file not found

    Example:
        >>> secrets = get_secrets('.env')
        >>> print(secrets['DB_PASSWORD'])
        secret_value_from_1password
        >>> print(secrets['PLAIN_VAR'])
        plaintext_value
    """
    # Validate token exists before proceeding
    if "OP_SERVICE_ACCOUNT_TOKEN" not in os.environ:
        raise RuntimeError(
            "OP_SERVICE_ACCOUNT_TOKEN environment variable must be set. "
            "This token is required to authenticate with 1Password CLI."
        )

    # Parse .env file to identify secrets
    path_obj = Path(path)
    secrets_metadata = parse_env_file(path_obj)

    # Read all variables from .env (both secrets and plaintext)
    all_vars = _read_all_env_vars(path_obj)

    # Fetch secrets from 1Password and replace placeholders
    result = {}
    for var_name, value in all_vars.items():
        if var_name in secrets_metadata:
            # This is a secret - fetch from 1Password
            metadata = secrets_metadata[var_name]
            secret_value = _fetch_secret(
                metadata["vault"],
                metadata["item"],
                metadata["field"]
            )
            result[var_name] = secret_value

            # Register secret with redaction module to prevent leaks
            register_secret(var_name, secret_value)
        else:
            # This is plaintext - use as-is
            result[var_name] = value

    return result


def _fetch_secret(vault: str, item: str, field: str) -> str:
    """
    Fetch secret from 1Password using op CLI.

    Args:
        vault: Vault name
        item: Item name
        field: Field name

    Returns:
        Secret value from 1Password (whitespace stripped)

    Raises:
        RuntimeError: If op command fails
    """
    # Construct op read command: op read op://vault/item/field
    secret_ref = f"op://{vault}/{item}/{field}"
    cmd = ["op", "read", secret_ref]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,  # Prevent leaks to stdout/stderr
            text=True,
            check=False  # We'll handle errors manually
        )

        if result.returncode != 0:
            # Sanitize error - don't expose secret path details in error message
            raise RuntimeError(
                f"Failed to fetch secret from 1Password. "
                f"Vault/item/field: {vault}/{item}/{field}. "
                f"Error: {result.stderr.strip()}"
            )

        # Return secret value, stripping trailing whitespace/newlines
        return result.stdout.strip()

    except FileNotFoundError:
        raise RuntimeError(
            "1Password CLI (op) not found. "
            "Install it from: https://developer.1password.com/docs/cli/get-started/"
        )


def _read_all_env_vars(path: Path) -> Dict[str, str]:
    """
    Read all variable assignments from .env file.

    This includes both secrets (which will be replaced) and plaintext variables.

    Args:
        path: Path to .env file

    Returns:
        Dict mapping variable names to their values from .env file
    """
    result = {}
    content = path.read_text()

    for line in content.splitlines():
        line = line.strip()

        # Skip comments and empty lines
        if not line or line.startswith("#"):
            continue

        # Check for variable assignment
        if "=" in line:
            var_name, var_value = line.split("=", 1)
            result[var_name.strip()] = var_value.strip()

    return result
