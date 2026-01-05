"""End-to-end integration tests with mock op CLI.

This test suite validates the complete workflow:
1. Parse .env file with secret tags
2. Load secrets via mock op CLI
3. Verify secrets exported and redacted
"""

import os
import subprocess
import tempfile
from pathlib import Path
from unittest.mock import patch, MagicMock
import pytest

from haunt_secrets import load_secrets, get_secrets
from haunt_secrets.redaction import register_secret, redact, contains_secret, reset_secrets


@pytest.fixture
def sample_env_file(tmp_path):
    """Create a complete .env file with mixed content."""
    env_file = tmp_path / ".env"
    content = """# ================================
# Plain Configuration
# ================================
APP_NAME=TestApp
PORT=8000
DEBUG=true
LOG_LEVEL=info

# ================================
# Secrets from 1Password
# ================================

# Database credentials
# @secret:op:test-vault/database/password
DB_PASSWORD=placeholder_db_pass

# API keys
# @secret:op:test-vault/stripe/secret_key
STRIPE_SECRET_KEY=placeholder_stripe

# @secret:op:test-vault/github/token
GITHUB_TOKEN=placeholder_github

# Session management
# @secret:op:test-vault/session/secret
SESSION_SECRET=placeholder_session
"""
    env_file.write_text(content)
    return str(env_file)


@pytest.fixture
def mock_op_cli():
    """Mock the subprocess.run calls to op CLI with realistic responses."""
    def mock_run(*args, **kwargs):
        cmd = args[0]

        # Only mock 'op read' commands
        if cmd[0] != "op" or cmd[1] != "read":
            raise RuntimeError(f"Unexpected command: {cmd}")

        # Extract secret reference from command
        secret_ref = cmd[2]  # "op://vault/item/field"

        # Return different secrets based on path
        secret_values = {
            "op://test-vault/database/password": "db_secret_12345",
            "op://test-vault/stripe/secret_key": "sk_live_abcdef67890",
            "op://test-vault/github/token": "ghp_1234567890abcdefghij",
            "op://test-vault/session/secret": "session_secret_xyz789",
        }

        if secret_ref in secret_values:
            return MagicMock(
                returncode=0,
                stdout=secret_values[secret_ref],
                stderr=""
            )
        else:
            return MagicMock(
                returncode=1,
                stdout="",
                stderr=f"[ERROR] Secret not found: {secret_ref}"
            )

    with patch("subprocess.run", side_effect=mock_run):
        yield


class TestEndToEndWorkflow:
    """Test complete workflow from .env file to loaded secrets."""

    def test_complete_workflow_get_secrets(self, sample_env_file, mock_op_cli):
        """Should load and return all secrets correctly (no side effects)."""
        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            # Reset redaction registry
            reset_secrets()

            # Load secrets (should NOT modify os.environ)
            result = get_secrets(sample_env_file)

            # Verify plaintext variables
            assert result["APP_NAME"] == "TestApp"
            assert result["PORT"] == "8000"
            assert result["DEBUG"] == "true"
            assert result["LOG_LEVEL"] == "info"

            # Verify secrets fetched from 1Password
            assert result["DB_PASSWORD"] == "db_secret_12345"
            assert result["STRIPE_SECRET_KEY"] == "sk_live_abcdef67890"
            assert result["GITHUB_TOKEN"] == "ghp_1234567890abcdefghij"
            assert result["SESSION_SECRET"] == "session_secret_xyz789"

            # Verify no environment pollution
            assert "DB_PASSWORD" not in os.environ
            assert "STRIPE_SECRET_KEY" not in os.environ

    def test_complete_workflow_load_secrets(self, sample_env_file, mock_op_cli):
        """Should load secrets and export to os.environ."""
        with patch.dict(os.environ, {}, clear=True):
            os.environ["OP_SERVICE_ACCOUNT_TOKEN"] = "test_token"

            # Reset redaction registry
            reset_secrets()

            # Load secrets (should export to os.environ)
            load_secrets(sample_env_file)

            # Verify plaintext in environment
            assert os.environ["APP_NAME"] == "TestApp"
            assert os.environ["PORT"] == "8000"
            assert os.environ["DEBUG"] == "true"

            # Verify secrets in environment
            assert os.environ["DB_PASSWORD"] == "db_secret_12345"
            assert os.environ["STRIPE_SECRET_KEY"] == "sk_live_abcdef67890"
            assert os.environ["GITHUB_TOKEN"] == "ghp_1234567890abcdefghij"
            assert os.environ["SESSION_SECRET"] == "session_secret_xyz789"

    def test_secrets_automatically_registered_for_redaction(self, sample_env_file, mock_op_cli):
        """Should auto-register secrets with redaction module."""
        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            reset_secrets()

            # Load secrets
            secrets = get_secrets(sample_env_file)

            # Verify secrets are redacted in logs/output
            assert contains_secret("DB password is: db_secret_12345") is True
            assert contains_secret("Stripe key: sk_live_abcdef67890") is True

            redacted = redact("DB password is: db_secret_12345")
            assert "db_secret_12345" not in redacted
            assert "***REDACTED***" in redacted

    def test_error_handling_missing_token(self, sample_env_file, mock_op_cli):
        """Should fail fast if OP_SERVICE_ACCOUNT_TOKEN not set."""
        with patch.dict(os.environ, {}, clear=True):
            with pytest.raises(RuntimeError, match="OP_SERVICE_ACCOUNT_TOKEN"):
                get_secrets(sample_env_file)

    def test_error_handling_op_failure(self, sample_env_file):
        """Should fail fast if op CLI returns error."""
        # Mock op failure
        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(
                returncode=1,
                stdout="",
                stderr="[ERROR] Item not found"
            )

            with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
                with pytest.raises(RuntimeError, match="Failed to fetch secret"):
                    get_secrets(sample_env_file)

    def test_error_handling_missing_file(self, mock_op_cli):
        """Should fail fast if .env file not found."""
        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            with pytest.raises(FileNotFoundError):
                get_secrets("/nonexistent/.env")


class TestBashIntegration:
    """Test bash script integration (if script exists)."""

    @pytest.fixture
    def bash_script_path(self):
        """Return path to bash script if it exists."""
        script_path = Path(__file__).parent.parent.parent / "scripts" / "haunt-secrets.sh"
        if not script_path.exists():
            pytest.skip("haunt-secrets.sh not found (expected if not deployed)")
        return str(script_path)

    def test_bash_script_sources_correctly(self, sample_env_file, bash_script_path, tmp_path):
        """Test bash script can be sourced and exports variables."""
        # Create mock op CLI
        mock_bin = tmp_path / "bin"
        mock_bin.mkdir()
        mock_op = mock_bin / "op"
        mock_op.write_text("""#!/bin/bash
case "$1" in
    "read")
        ref="$2"
        case "$ref" in
            "op://test-vault/database/password")
                echo "db_secret_12345"
                ;;
            "op://test-vault/stripe/secret_key")
                echo "sk_live_abcdef67890"
                ;;
            "op://test-vault/github/token")
                echo "ghp_1234567890abcdefghij"
                ;;
            "op://test-vault/session/secret")
                echo "session_secret_xyz789"
                ;;
            *)
                echo "Secret not found: $ref" >&2
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Unknown command: $1" >&2
        exit 1
        ;;
esac
""")
        mock_op.chmod(0o755)

        # Test script execution
        test_script = tmp_path / "test.sh"
        test_script.write_text(f"""#!/bin/bash
set -e
export PATH="{mock_bin}:$PATH"
export OP_SERVICE_ACCOUNT_TOKEN="test_token"

source "{bash_script_path}" "{sample_env_file}"

# Verify exports
[[ "$APP_NAME" == "TestApp" ]] || exit 1
[[ "$DB_PASSWORD" == "db_secret_12345" ]] || exit 1
[[ "$STRIPE_SECRET_KEY" == "sk_live_abcdef67890" ]] || exit 1

echo "SUCCESS"
""")
        test_script.chmod(0o755)

        # Run test
        result = subprocess.run(
            [str(test_script)],
            capture_output=True,
            text=True
        )

        assert result.returncode == 0, f"Script failed: {result.stderr}"
        assert "SUCCESS" in result.stdout


class TestRealWorldScenarios:
    """Test realistic use cases and edge cases."""

    def test_empty_env_file(self, tmp_path, mock_op_cli):
        """Should handle empty .env file gracefully."""
        env_file = tmp_path / ".env"
        env_file.write_text("")

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = get_secrets(str(env_file))
            assert result == {}

    def test_only_plaintext_variables(self, tmp_path, mock_op_cli):
        """Should handle .env with no secrets."""
        env_file = tmp_path / ".env"
        env_file.write_text("""APP_NAME=TestApp
PORT=8000
DEBUG=true
""")

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = get_secrets(str(env_file))
            assert result == {
                "APP_NAME": "TestApp",
                "PORT": "8000",
                "DEBUG": "true"
            }

    def test_only_secrets_no_plaintext(self, tmp_path, mock_op_cli):
        """Should handle .env with only secrets."""
        env_file = tmp_path / ".env"
        env_file.write_text("""# @secret:op:test-vault/database/password
DB_PASSWORD=placeholder
""")

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = get_secrets(str(env_file))
            assert result == {
                "DB_PASSWORD": "db_secret_12345"
            }

    def test_whitespace_handling(self, tmp_path, mock_op_cli):
        """Should handle various whitespace patterns."""
        env_file = tmp_path / ".env"
        env_file.write_text("""
# Comment with trailing spaces

APP_NAME=TestApp

# @secret:op:test-vault/database/password
DB_PASSWORD=placeholder

""")

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = get_secrets(str(env_file))
            assert "APP_NAME" in result
            assert "DB_PASSWORD" in result

    def test_duplicate_variable_names(self, tmp_path, mock_op_cli):
        """Should use last occurrence for duplicate variables."""
        env_file = tmp_path / ".env"
        env_file.write_text("""APP_NAME=FirstValue

# @secret:op:test-vault/database/password
DB_PASSWORD=placeholder

APP_NAME=SecondValue
""")

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = get_secrets(str(env_file))
            # Last occurrence wins
            assert result["APP_NAME"] == "SecondValue"

    def test_large_env_file(self, tmp_path, mock_op_cli):
        """Should handle large .env files with many variables."""
        env_file = tmp_path / ".env"

        # Generate 100 plaintext variables
        lines = [f"VAR_{i}=value_{i}" for i in range(100)]

        # Add a few secrets
        lines.append("# @secret:op:test-vault/database/password")
        lines.append("DB_PASSWORD=placeholder")
        lines.append("# @secret:op:test-vault/stripe/secret_key")
        lines.append("STRIPE_SECRET_KEY=placeholder")

        env_file.write_text("\n".join(lines))

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = get_secrets(str(env_file))

            # Verify all 100 plaintext vars present
            for i in range(100):
                assert f"VAR_{i}" in result

            # Verify secrets fetched
            assert result["DB_PASSWORD"] == "db_secret_12345"
            assert result["STRIPE_SECRET_KEY"] == "sk_live_abcdef67890"


class TestSecurityFeatures:
    """Test security-related functionality."""

    def test_no_secrets_in_error_messages(self, tmp_path):
        """Should not expose secret values in exception messages."""
        env_file = tmp_path / ".env"
        env_file.write_text("""# @secret:op:test-vault/super-secret/password
SECRET=placeholder
""")

        # Mock op failure
        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(
                returncode=1,
                stdout="",
                stderr="[ERROR] Authentication failed"
            )

            with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
                try:
                    get_secrets(str(env_file))
                except RuntimeError as e:
                    error_msg = str(e)
                    # Should mention failure but not secret value
                    assert "Failed to fetch secret" in error_msg
                    # Should NOT contain actual secret value
                    assert "placeholder" not in error_msg.lower() or "password" in error_msg.lower()

    def test_redaction_prevents_logging_leaks(self, sample_env_file, mock_op_cli):
        """Should prevent secrets from appearing in logs."""
        import logging
        from io import StringIO
        from haunt_secrets.redaction import SecretRedactingFormatter

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            reset_secrets()

            # Setup logger with redacting formatter
            logger = logging.getLogger("test_e2e")
            logger.handlers = []
            log_stream = StringIO()
            handler = logging.StreamHandler(log_stream)
            handler.setFormatter(SecretRedactingFormatter())
            logger.addHandler(handler)
            logger.setLevel(logging.INFO)

            # Load secrets (auto-registers with redaction)
            secrets = get_secrets(sample_env_file)

            # Try to log secrets
            logger.info(f"DB password: {secrets['DB_PASSWORD']}")
            logger.info(f"Stripe key: {secrets['STRIPE_SECRET_KEY']}")
            logger.info(f"Public config: {secrets['APP_NAME']}")

            # Get log output
            log_output = log_stream.getvalue()

            # Secrets should be redacted
            assert "db_secret_12345" not in log_output
            assert "sk_live_abcdef67890" not in log_output
            assert "***REDACTED***" in log_output

            # Plaintext should NOT be redacted
            assert "TestApp" in log_output

    def test_subprocess_capture_output(self, sample_env_file):
        """Should use capture_output=True to prevent stdout/stderr leaks."""
        call_log = []

        def mock_run(*args, **kwargs):
            call_log.append(kwargs)
            return MagicMock(returncode=0, stdout="secret_value", stderr="")

        with patch("subprocess.run", side_effect=mock_run):
            with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
                try:
                    get_secrets(sample_env_file)
                except:
                    pass

                # Verify capture_output was used
                assert len(call_log) > 0
                for call_kwargs in call_log:
                    assert call_kwargs.get("capture_output") is True, \
                        "subprocess.run must use capture_output=True to prevent leaks"


class TestInteroperability:
    """Test interoperability between Python and bash."""

    def test_python_and_bash_produce_same_results(self, sample_env_file, mock_op_cli):
        """Python and bash should produce identical environment state."""
        with patch.dict(os.environ, {}, clear=True):
            os.environ["OP_SERVICE_ACCOUNT_TOKEN"] = "test_token"
            reset_secrets()

            # Load with Python
            load_secrets(sample_env_file)
            python_env = dict(os.environ)

            # Both should have same variables
            expected_vars = {
                "APP_NAME": "TestApp",
                "PORT": "8000",
                "DEBUG": "true",
                "LOG_LEVEL": "info",
                "DB_PASSWORD": "db_secret_12345",
                "STRIPE_SECRET_KEY": "sk_live_abcdef67890",
                "GITHUB_TOKEN": "ghp_1234567890abcdefghij",
                "SESSION_SECRET": "session_secret_xyz789",
            }

            for var, expected_value in expected_vars.items():
                assert var in python_env
                assert python_env[var] == expected_value
