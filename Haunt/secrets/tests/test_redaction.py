"""Tests for secret redaction module.

This module tests comprehensive safeguards to prevent secret exposure
in logs, stdout, stderr, and any other output.
"""

import logging
import pytest
from io import StringIO

from haunt_secrets.redaction import (
    SecretRedactingFormatter,
    register_secret,
    redact,
    contains_secret,
    reset_secrets,  # For test cleanup
)


class TestPatternDetection:
    """Test automatic detection of common secret patterns."""

    def setup_method(self):
        """Reset registered secrets before each test."""
        reset_secrets()

    def test_detects_api_key_pattern(self):
        """Should detect long alphanumeric strings as potential API keys."""
        # 20+ character alphanumeric strings
        api_key = "abcd1234efgh5678ijkl9012mnop3456qrst"
        text = f"Using API key: {api_key}"

        assert contains_secret(text) is True
        redacted = redact(text)
        assert api_key not in redacted
        assert "***REDACTED***" in redacted

    def test_detects_oauth_token_patterns(self):
        """Should detect OAuth tokens by common prefixes."""
        test_cases = [
            "ops_1234567890abcdef",  # Ops token
            "ntn_abcdef1234567890",  # Notion token
            "secret_12345678901234567890",  # Generic secret
            "sk_live_abcdef1234567890",  # Stripe secret key
            "pk_test_1234567890abcdef",  # Stripe public key
        ]

        for token in test_cases:
            text = f"Token: {token}"
            assert contains_secret(text) is True, f"Failed to detect {token}"
            redacted = redact(text)
            assert token not in redacted
            assert "***REDACTED***" in redacted

    def test_detects_uuid_pattern(self):
        """Should detect UUIDs and GUIDs."""
        uuid = "550e8400-e29b-41d4-a716-446655440000"
        text = f"Session ID: {uuid}"

        assert contains_secret(text) is True
        redacted = redact(text)
        assert uuid not in redacted
        assert "***REDACTED***" in redacted

    def test_detects_base64_pattern(self):
        """Should detect long base64-encoded strings (32+ chars)."""
        b64_secret = "SGVsbG8gV29ybGQhIFRoaXMgaXMgYSBzZWNyZXQgbWVzc2FnZQ=="
        text = f"Encoded secret: {b64_secret}"

        assert contains_secret(text) is True
        redacted = redact(text)
        assert b64_secret not in redacted
        assert "***REDACTED***" in redacted

    def test_ignores_short_strings(self):
        """Should NOT detect short strings as secrets."""
        short_text = "Hello World"

        assert contains_secret(short_text) is False
        assert redact(short_text) == short_text

    def test_ignores_common_words(self):
        """Should NOT detect normal text as secrets."""
        normal_text = "The user logged in successfully"

        assert contains_secret(normal_text) is False
        assert redact(normal_text) == normal_text


class TestRegisteredSecrets:
    """Test redaction of explicitly registered secrets."""

    def setup_method(self):
        """Reset registered secrets before each test."""
        reset_secrets()

    def test_register_and_redact_secret(self):
        """Should redact explicitly registered secrets."""
        secret_value = "my-super-secret-api-key-12345"
        register_secret("API_KEY", secret_value)

        text = f"Connecting with API_KEY={secret_value}"

        assert contains_secret(text) is True
        redacted = redact(text)
        assert secret_value not in redacted
        assert "***REDACTED***" in redacted

    def test_register_multiple_secrets(self):
        """Should redact all registered secrets."""
        api_key = "api-key-12345"
        db_password = "db-password-67890"

        register_secret("API_KEY", api_key)
        register_secret("DB_PASSWORD", db_password)

        text = f"API: {api_key}, DB: {db_password}"

        assert contains_secret(text) is True
        redacted = redact(text)
        assert api_key not in redacted
        assert db_password not in redacted
        assert redacted.count("***REDACTED***") == 2

    def test_redact_partial_matches(self):
        """Should redact secrets even when embedded in larger strings."""
        secret = "secret123"
        register_secret("SECRET", secret)

        text = f"The value is: prefix-{secret}-suffix"
        redacted = redact(text)

        assert secret not in redacted
        assert "***REDACTED***" in redacted

    def test_case_sensitive_redaction(self):
        """Should perform case-sensitive redaction."""
        secret = "SecretValue123"
        register_secret("SECRET", secret)

        # Exact match should be redacted
        assert "SecretValue123" not in redact("Value: SecretValue123")

        # Different case should NOT be redacted (avoid false positives)
        assert "secretvalue123" in redact("Value: secretvalue123")


class TestLoggingIntegration:
    """Test SecretRedactingFormatter for automatic log redaction."""

    def setup_method(self):
        """Reset registered secrets and setup test logger."""
        reset_secrets()

        # Create test logger with redacting formatter
        self.logger = logging.getLogger("test_logger")
        self.logger.setLevel(logging.INFO)
        self.logger.handlers = []  # Clear existing handlers

        # Add handler with redacting formatter
        self.log_stream = StringIO()
        handler = logging.StreamHandler(self.log_stream)
        handler.setFormatter(SecretRedactingFormatter())
        self.logger.addHandler(handler)

    def test_formatter_redacts_registered_secrets(self):
        """Should auto-redact registered secrets in log messages."""
        api_key = "api-key-12345"
        register_secret("API_KEY", api_key)

        self.logger.info(f"Using API key: {api_key}")

        log_output = self.log_stream.getvalue()
        assert api_key not in log_output
        assert "***REDACTED***" in log_output

    def test_formatter_redacts_pattern_secrets(self):
        """Should auto-redact pattern-detected secrets in logs."""
        oauth_token = "ops_1234567890abcdefghij"

        self.logger.info(f"OAuth token: {oauth_token}")

        log_output = self.log_stream.getvalue()
        assert oauth_token not in log_output
        assert "***REDACTED***" in log_output

    def test_formatter_preserves_normal_logs(self):
        """Should NOT redact normal log messages."""
        normal_message = "User login successful"

        self.logger.info(normal_message)

        log_output = self.log_stream.getvalue()
        assert normal_message in log_output
        assert "***REDACTED***" not in log_output

    def test_formatter_redacts_in_exception_messages(self):
        """Should redact secrets in exception tracebacks."""
        secret = "secret-password-12345"
        register_secret("PASSWORD", secret)

        try:
            raise ValueError(f"Invalid password: {secret}")
        except ValueError:
            self.logger.exception("Authentication failed")

        log_output = self.log_stream.getvalue()
        assert secret not in log_output
        assert "***REDACTED***" in log_output

    def test_formatter_with_custom_format(self):
        """Should work with custom log formats."""
        # Create handler with custom format
        handler = logging.StreamHandler(self.log_stream)
        custom_formatter = SecretRedactingFormatter(
            fmt='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        handler.setFormatter(custom_formatter)

        logger = logging.getLogger("custom_logger")
        logger.handlers = []
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)

        api_key = "custom-api-key-67890"
        register_secret("CUSTOM_KEY", api_key)

        logger.info(f"Using key: {api_key}")

        log_output = self.log_stream.getvalue()
        assert api_key not in log_output
        assert "***REDACTED***" in log_output


class TestAntiLeakProtection:
    """Test anti-leak protection - intentionally try to leak secrets."""

    def setup_method(self):
        """Reset registered secrets before each test."""
        reset_secrets()

    def test_prevent_print_leak(self):
        """Should detect if secret appears in stdout."""
        secret = "super-secret-value-12345"
        register_secret("SECRET", secret)

        # Simulate printing (would normally go to stdout)
        output = f"Debug: {secret}"

        # Verify contains_secret catches it
        assert contains_secret(output) is True

        # Verify redact removes it
        safe_output = redact(output)
        assert secret not in safe_output

    def test_prevent_error_message_leak(self):
        """Should detect secrets in error messages."""
        password = "my-database-password-999"
        register_secret("DB_PASSWORD", password)

        error_msg = f"Database connection failed with password: {password}"

        assert contains_secret(error_msg) is True
        safe_error = redact(error_msg)
        assert password not in safe_error
        assert "Database connection failed" in safe_error

    def test_prevent_json_leak(self):
        """Should detect secrets in JSON output."""
        import json

        api_token = "token-abcdefghijklmnop"
        register_secret("API_TOKEN", api_token)

        data = {"status": "success", "token": api_token}
        json_output = json.dumps(data)

        assert contains_secret(json_output) is True
        safe_json = redact(json_output)
        assert api_token not in safe_json

    def test_prevent_url_parameter_leak(self):
        """Should detect secrets in URL query parameters."""
        api_key = "url-api-key-12345678"
        register_secret("URL_KEY", api_key)

        url = f"https://api.example.com/data?key={api_key}&format=json"

        assert contains_secret(url) is True
        safe_url = redact(url)
        assert api_key not in safe_url
        assert "https://api.example.com/data" in safe_url

    def test_prevent_multiline_leak(self):
        """Should detect secrets across multiple lines."""
        secret = "multiline-secret-12345"
        register_secret("SECRET", secret)

        multiline_text = f"""
        Configuration loaded:
        API_KEY: {secret}
        Environment: production
        """

        assert contains_secret(multiline_text) is True
        safe_text = redact(multiline_text)
        assert secret not in safe_text

    def test_prevent_dict_repr_leak(self):
        """Should detect secrets in dict/object representations."""
        token = "repr-token-67890abcdef"
        register_secret("TOKEN", token)

        config = {"api_token": token, "region": "us-east-1"}
        repr_output = repr(config)

        assert contains_secret(repr_output) is True
        safe_repr = redact(repr_output)
        assert token not in safe_repr


class TestEdgeCases:
    """Test edge cases and boundary conditions."""

    def setup_method(self):
        """Reset registered secrets before each test."""
        reset_secrets()

    def test_empty_string(self):
        """Should handle empty strings safely."""
        assert contains_secret("") is False
        assert redact("") == ""

    def test_none_value(self):
        """Should handle None values safely."""
        assert contains_secret(None) is False
        assert redact(None) is None

    def test_numeric_values(self):
        """Should handle numeric values safely."""
        assert contains_secret(12345) is False
        assert redact(12345) == 12345

    def test_redact_secret_that_is_none(self):
        """Should handle registering None as a secret value."""
        register_secret("NULL_SECRET", None)

        text = "Some normal text"
        assert redact(text) == text

    def test_redact_very_long_text(self):
        """Should handle very long text efficiently."""
        secret = "long-text-secret-12345"
        register_secret("SECRET", secret)

        # Generate 10KB of text
        long_text = ("Normal text. " * 1000) + f"Secret: {secret}" + (" More text." * 1000)

        redacted = redact(long_text)
        assert secret not in redacted
        assert "***REDACTED***" in redacted

    def test_overlapping_patterns(self):
        """Should handle overlapping secret patterns."""
        # UUID contains characters that might match other patterns
        uuid = "550e8400-e29b-41d4-a716-446655440000"
        api_key = "550e8400e29b41d4a716"  # Substring of UUID

        register_secret("UUID", uuid)
        register_secret("API_KEY", api_key)

        text = f"Values: {uuid} and {api_key}"
        redacted = redact(text)

        assert uuid not in redacted
        assert api_key not in redacted

    def test_special_regex_characters(self):
        """Should handle secrets containing regex special characters."""
        secret = "secret[with]special.chars+and*more"
        register_secret("REGEX_SECRET", secret)

        text = f"Value: {secret}"
        redacted = redact(text)

        assert secret not in redacted
        assert "***REDACTED***" in redacted
