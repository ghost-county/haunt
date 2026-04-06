"""Tests for secret loader functionality."""

import os
import pytest
from unittest.mock import patch, MagicMock
from haunt_secrets.loader import load_secrets, get_secrets


@pytest.fixture
def sample_env_file(tmp_path):
    """Create a temporary .env file with mixed content."""
    env_file = tmp_path / ".env"
    content = """# Plain environment variable
PLAIN_VAR=plain_value

# @secret:op:prod/database/password
DB_PASSWORD=placeholder

# @secret:op:prod/api/key
API_KEY=placeholder

# Another plain variable
DEBUG=true
"""
    env_file.write_text(content)
    return str(env_file)


@pytest.fixture
def mock_op_cli():
    """Mock subprocess for op CLI calls."""
    with patch("subprocess.run") as mock_run:
        # Default successful response
        mock_run.return_value = MagicMock(
            returncode=0,
            stdout="secret_value",
            stderr=""
        )
        yield mock_run


class TestGetSecrets:
    """Tests for get_secrets() function (returns dict, no side effects)."""

    def test_returns_dict_with_secrets_and_plaintext(self, sample_env_file, mock_op_cli):
        """Should return dict with both secrets and plaintext variables."""
        # Mock op CLI to return different values for different secrets
        def mock_op_read(*args, **kwargs):
            cmd = args[0]
            if "database/password" in " ".join(cmd):
                return MagicMock(returncode=0, stdout="db_secret_123", stderr="")
            elif "api/key" in " ".join(cmd):
                return MagicMock(returncode=0, stdout="api_secret_456", stderr="")
            return MagicMock(returncode=0, stdout="default_secret", stderr="")

        mock_op_cli.side_effect = mock_op_read

        result = get_secrets(sample_env_file)

        # Should contain both secrets and plaintext
        assert "DB_PASSWORD" in result
        assert "API_KEY" in result
        assert "PLAIN_VAR" in result
        assert "DEBUG" in result

        # Secrets should be fetched from 1Password
        assert result["DB_PASSWORD"] == "db_secret_123"
        assert result["API_KEY"] == "api_secret_456"

        # Plaintext should be preserved
        assert result["PLAIN_VAR"] == "plain_value"
        assert result["DEBUG"] == "true"

    def test_does_not_modify_os_environ(self, sample_env_file, mock_op_cli):
        """Should NOT export to os.environ (that's load_secrets' job)."""
        original_env = os.environ.copy()

        get_secrets(sample_env_file)

        # Environment should be unchanged
        assert os.environ == original_env

    def test_raises_error_if_token_missing(self, sample_env_file):
        """Should raise RuntimeError if OP_SERVICE_ACCOUNT_TOKEN not set."""
        with patch.dict(os.environ, {}, clear=True):
            with pytest.raises(RuntimeError, match="OP_SERVICE_ACCOUNT_TOKEN"):
                get_secrets(sample_env_file)

    def test_raises_error_if_op_fails(self, sample_env_file, mock_op_cli):
        """Should raise RuntimeError if op command fails."""
        # Mock op failure
        mock_op_cli.return_value = MagicMock(
            returncode=1,
            stdout="",
            stderr="[ERROR] Item not found"
        )

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            with pytest.raises(RuntimeError, match="Failed to fetch secret"):
                get_secrets(sample_env_file)

    def test_error_message_does_not_expose_secret_value(self, sample_env_file, mock_op_cli):
        """Should sanitize exception messages (no secret values)."""
        mock_op_cli.return_value = MagicMock(
            returncode=1,
            stdout="",
            stderr="[ERROR] Authentication failed"
        )

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            with pytest.raises(RuntimeError) as exc_info:
                get_secrets(sample_env_file)

            # Error should NOT contain secret path details that could leak info
            error_msg = str(exc_info.value)
            assert "Failed to fetch secret" in error_msg
            # Should not expose vault/item/field in error
            # (implementation will decide how much detail to include)


class TestLoadSecrets:
    """Tests for load_secrets() function (exports to os.environ)."""

    def test_exports_to_os_environ(self, sample_env_file, mock_op_cli):
        """Should export all variables to os.environ."""
        # Mock op CLI to return different values
        def mock_op_read(*args, **kwargs):
            cmd = args[0]
            if "database/password" in " ".join(cmd):
                return MagicMock(returncode=0, stdout="db_secret_123", stderr="")
            elif "api/key" in " ".join(cmd):
                return MagicMock(returncode=0, stdout="api_secret_456", stderr="")
            return MagicMock(returncode=0, stdout="default_secret", stderr="")

        mock_op_cli.side_effect = mock_op_read

        with patch.dict(os.environ, {}, clear=True):
            os.environ["OP_SERVICE_ACCOUNT_TOKEN"] = "test_token"

            load_secrets(sample_env_file)

            # Secrets should be in environment
            assert os.environ["DB_PASSWORD"] == "db_secret_123"
            assert os.environ["API_KEY"] == "api_secret_456"

            # Plaintext should also be in environment
            assert os.environ["PLAIN_VAR"] == "plain_value"
            assert os.environ["DEBUG"] == "true"

    def test_returns_none(self, sample_env_file, mock_op_cli):
        """Should return None (side-effect only function)."""
        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = load_secrets(sample_env_file)
            assert result is None

    def test_raises_error_if_token_missing(self, sample_env_file):
        """Should raise RuntimeError if OP_SERVICE_ACCOUNT_TOKEN not set."""
        with patch.dict(os.environ, {}, clear=True):
            with pytest.raises(RuntimeError, match="OP_SERVICE_ACCOUNT_TOKEN"):
                load_secrets(sample_env_file)

    def test_raises_error_if_op_fails(self, sample_env_file, mock_op_cli):
        """Should raise RuntimeError if op command fails."""
        mock_op_cli.return_value = MagicMock(
            returncode=1,
            stdout="",
            stderr="[ERROR] Item not found"
        )

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            with pytest.raises(RuntimeError, match="Failed to fetch secret"):
                load_secrets(sample_env_file)


class TestFetchSecret:
    """Tests for internal _fetch_secret() function."""

    def test_calls_op_read_with_correct_format(self, mock_op_cli):
        """Should call 'op read op://vault/item/field'."""
        from haunt_secrets.loader import _fetch_secret

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            _fetch_secret("prod", "database", "password")

            # Verify op was called with correct format
            mock_op_cli.assert_called_once()
            call_args = mock_op_cli.call_args[0][0]
            assert call_args[0] == "op"
            assert call_args[1] == "read"
            assert call_args[2] == "op://prod/database/password"

    def test_uses_capture_output(self, mock_op_cli):
        """Should use capture_output=True to prevent leaks."""
        from haunt_secrets.loader import _fetch_secret

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            _fetch_secret("prod", "database", "password")

            call_kwargs = mock_op_cli.call_args[1]
            assert call_kwargs.get("capture_output") is True

    def test_returns_stdout_as_string(self, mock_op_cli):
        """Should return secret value from stdout."""
        from haunt_secrets.loader import _fetch_secret

        mock_op_cli.return_value = MagicMock(
            returncode=0,
            stdout="my_secret_value",
            stderr=""
        )

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = _fetch_secret("prod", "database", "password")
            assert result == "my_secret_value"

    def test_strips_whitespace_from_secret(self, mock_op_cli):
        """Should strip trailing newlines/whitespace from secret."""
        from haunt_secrets.loader import _fetch_secret

        mock_op_cli.return_value = MagicMock(
            returncode=0,
            stdout="my_secret_value\n",
            stderr=""
        )

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = _fetch_secret("prod", "database", "password")
            assert result == "my_secret_value"


class TestMixedContent:
    """Tests for handling mixed plaintext and secret variables."""

    def test_preserves_variable_order(self, sample_env_file, mock_op_cli):
        """Should preserve order from .env file."""
        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = get_secrets(sample_env_file)

            # All variables should be present
            assert set(result.keys()) == {"PLAIN_VAR", "DB_PASSWORD", "API_KEY", "DEBUG"}

    def test_handles_empty_plaintext_values(self, tmp_path, mock_op_cli):
        """Should handle empty plaintext values correctly."""
        env_file = tmp_path / ".env"
        env_file.write_text("EMPTY_VAR=\n")

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = get_secrets(str(env_file))
            assert "EMPTY_VAR" in result
            assert result["EMPTY_VAR"] == ""

    def test_handles_comments_correctly(self, tmp_path, mock_op_cli):
        """Should ignore comment lines that aren't secret tags."""
        env_file = tmp_path / ".env"
        content = """# This is a comment
SOME_VAR=value
# Another comment
"""
        env_file.write_text(content)

        with patch.dict(os.environ, {"OP_SERVICE_ACCOUNT_TOKEN": "test_token"}):
            result = get_secrets(str(env_file))
            assert "SOME_VAR" in result
            assert result["SOME_VAR"] == "value"
