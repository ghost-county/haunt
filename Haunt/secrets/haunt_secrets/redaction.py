"""Secret redaction module for preventing secret exposure.

This module provides comprehensive safeguards to prevent secret exposure
in logs, stdout, stderr, and any other output.
"""

import re
import logging
from typing import Optional, Set, Any


# Global registry of known secret values
_REGISTERED_SECRETS: Set[str] = set()

# Redaction placeholder
REDACTED_PLACEHOLDER = "***REDACTED***"


# Patterns for common secret formats
PATTERNS = {
    'api_key': re.compile(r'\b[a-zA-Z0-9]{20,}\b'),  # Long alphanumeric strings
    'oauth_token': re.compile(
        r'\b(?:ops|ntn|secret|sk|pk)_[a-zA-Z0-9_-]{10,}\b'
    ),  # OAuth tokens with common prefixes
    'uuid': re.compile(
        r'\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b',
        re.IGNORECASE
    ),  # UUID/GUID
    'base64': re.compile(
        r'\b[A-Za-z0-9+/]{32,}={0,2}\b'
    ),  # Base64 encoded strings (32+ chars)
}


def register_secret(name: str, value: Optional[str]) -> None:
    """Register a secret value for redaction.

    Args:
        name: Name/identifier of the secret (for logging purposes)
        value: The secret value to redact (None values are ignored)
    """
    if value is not None and isinstance(value, str) and value:
        _REGISTERED_SECRETS.add(value)


def reset_secrets() -> None:
    """Clear all registered secrets.

    Used primarily for testing to ensure clean state between tests.
    """
    _REGISTERED_SECRETS.clear()


def contains_secret(text: Any) -> bool:
    """Check if text contains any known or pattern-matched secrets.

    Args:
        text: Text to check (will be converted to string if not already)

    Returns:
        True if text contains a secret, False otherwise
    """
    # Handle non-string types
    if text is None:
        return False

    if not isinstance(text, str):
        # Handle numeric types
        if isinstance(text, (int, float)):
            return False
        # Convert to string for other types
        text = str(text)

    if not text:
        return False

    # Check registered secrets
    for secret in _REGISTERED_SECRETS:
        if secret in text:
            return True

    # Check pattern-based detection
    for pattern in PATTERNS.values():
        if pattern.search(text):
            return True

    return False


def redact(text: Any) -> Any:
    """Redact all known secrets and pattern-matched secrets from text.

    Args:
        text: Text to redact (will be converted to string if not already)

    Returns:
        Text with all secrets replaced by REDACTED_PLACEHOLDER
    """
    # Handle non-string types
    if text is None:
        return None

    if not isinstance(text, str):
        # Handle numeric types
        if isinstance(text, (int, float)):
            return text
        # Convert to string for other types
        text = str(text)

    if not text:
        return text

    redacted_text = text

    # Redact registered secrets (exact string replacement)
    for secret in _REGISTERED_SECRETS:
        if secret:
            # Escape special regex characters in secret value
            escaped_secret = re.escape(secret)
            redacted_text = re.sub(escaped_secret, REDACTED_PLACEHOLDER, redacted_text)

    # Redact pattern-matched secrets
    for pattern in PATTERNS.values():
        redacted_text = pattern.sub(REDACTED_PLACEHOLDER, redacted_text)

    return redacted_text


class SecretRedactingFormatter(logging.Formatter):
    """Logging formatter that automatically redacts secrets.

    This formatter wraps the standard logging.Formatter and redacts
    all known secrets from log messages before they are emitted.

    Usage:
        handler = logging.StreamHandler()
        handler.setFormatter(SecretRedactingFormatter())
        logger.addHandler(handler)
    """

    def __init__(self, fmt: Optional[str] = None, datefmt: Optional[str] = None, **kwargs):
        """Initialize the redacting formatter.

        Args:
            fmt: Log format string (same as logging.Formatter)
            datefmt: Date format string (same as logging.Formatter)
            **kwargs: Additional arguments for logging.Formatter
        """
        super().__init__(fmt=fmt, datefmt=datefmt, **kwargs)

    def format(self, record: logging.LogRecord) -> str:
        """Format the log record and redact any secrets.

        Args:
            record: The log record to format

        Returns:
            Formatted and redacted log message
        """
        # Format the record using parent formatter
        formatted = super().format(record)

        # Redact any secrets from the formatted message
        return redact(formatted)
