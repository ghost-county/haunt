"""
Unit tests for haunt_secrets.py - Tag Parser for 1Password Secret References

Tests the parse_secret_tags() function which extracts 1Password secret references
from .env files with the format: # @secret:op:vault/item/field
"""

import pytest
import tempfile
import os


# This will fail until we implement haunt_secrets module
try:
    from haunt_secrets import parse_secret_tags, SecretTagError
except ImportError:
    # Define dummy classes for test discovery
    class SecretTagError(Exception):
        pass

    def parse_secret_tags(env_file):
        raise NotImplementedError("haunt_secrets module not yet implemented")


class TestParseSecretTags:
    """Test suite for parse_secret_tags() function"""

    # ========== HAPPY PATH TESTS ==========

    def test_parse_valid_single_tag(self):
        """Should parse a single valid tag correctly"""
        env_content = """# @secret:op:ghost-county/api-keys/github-token
GITHUB_TOKEN=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                result = parse_secret_tags(f.name)
                assert result == {
                    "GITHUB_TOKEN": ("ghost-county", "api-keys", "github-token")
                }
            finally:
                os.unlink(f.name)

    def test_parse_multiple_tags(self):
        """Should parse multiple tags in the same file"""
        env_content = """# @secret:op:vault1/item1/field1
VAR1=placeholder

# Some comment
# @secret:op:vault2/item2/field2
VAR2=placeholder

# @secret:op:vault3/item3/field3
VAR3=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                result = parse_secret_tags(f.name)
                assert result == {
                    "VAR1": ("vault1", "item1", "field1"),
                    "VAR2": ("vault2", "item2", "field2"),
                    "VAR3": ("vault3", "item3", "field3"),
                }
            finally:
                os.unlink(f.name)

    def test_parse_tag_with_hyphens_and_underscores(self):
        """Should handle vault/item/field names with hyphens and underscores"""
        env_content = """# @secret:op:my-vault/my_item/my-field_name
MY_VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                result = parse_secret_tags(f.name)
                assert result == {
                    "MY_VAR": ("my-vault", "my_item", "my-field_name")
                }
            finally:
                os.unlink(f.name)

    def test_parse_ignores_lines_without_tags(self):
        """Should only parse lines with @secret tags, ignore regular comments and env vars"""
        env_content = """# Regular comment
PLAINTEXT_VAR=some_value

# @secret:op:vault/item/field
SECRET_VAR=placeholder

# Another comment
ANOTHER_PLAINTEXT=value
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                result = parse_secret_tags(f.name)
                # Should only include the secret tag
                assert result == {
                    "SECRET_VAR": ("vault", "item", "field")
                }
            finally:
                os.unlink(f.name)

    def test_parse_empty_file(self):
        """Should return empty dict for empty file"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write("")
            f.flush()

            try:
                result = parse_secret_tags(f.name)
                assert result == {}
            finally:
                os.unlink(f.name)

    def test_parse_file_with_no_tags(self):
        """Should return empty dict for file without any secret tags"""
        env_content = """# Regular comment
VAR1=value1
VAR2=value2
# Another comment
VAR3=value3
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                result = parse_secret_tags(f.name)
                assert result == {}
            finally:
                os.unlink(f.name)

    def test_parse_tag_immediately_before_var(self):
        """Should match tag to variable on next line (no blank lines between)"""
        env_content = """# @secret:op:vault/item/field
SECRET_VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                result = parse_secret_tags(f.name)
                assert "SECRET_VAR" in result
            finally:
                os.unlink(f.name)

    # ========== ERROR HANDLING TESTS ==========

    def test_raises_error_for_malformed_tag_missing_parts(self):
        """Should raise SecretTagError for tag missing vault/item/field parts"""
        env_content = """# @secret:op:vault/item
VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                with pytest.raises(SecretTagError) as exc_info:
                    parse_secret_tags(f.name)
                assert "malformed" in str(exc_info.value).lower()
            finally:
                os.unlink(f.name)

    def test_raises_error_for_malformed_tag_missing_prefix(self):
        """Should raise SecretTagError for tag missing @secret:op: prefix"""
        env_content = """# vault/item/field
VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                # This should NOT raise an error - it's just a regular comment
                # Only lines starting with @secret:op: should be parsed
                result = parse_secret_tags(f.name)
                assert result == {}
            finally:
                os.unlink(f.name)

    def test_raises_error_for_malformed_tag_wrong_separator(self):
        """Should raise SecretTagError for tag using wrong separator (: instead of /)"""
        env_content = """# @secret:op:vault:item:field
VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                with pytest.raises(SecretTagError) as exc_info:
                    parse_secret_tags(f.name)
                assert "malformed" in str(exc_info.value).lower()
            finally:
                os.unlink(f.name)

    def test_raises_error_for_tag_without_following_variable(self):
        """Should raise SecretTagError if tag is not followed by a variable assignment"""
        env_content = """# @secret:op:vault/item/field
# Just a comment, no var
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                with pytest.raises(SecretTagError) as exc_info:
                    parse_secret_tags(f.name)
                # Verify error mentions that variable assignment is missing or not found
                error_msg = str(exc_info.value).lower()
                assert "not followed by" in error_msg or "no variable" in error_msg or "missing" in error_msg
            finally:
                os.unlink(f.name)

    def test_raises_error_for_nonexistent_file(self):
        """Should raise FileNotFoundError for nonexistent file"""
        with pytest.raises(FileNotFoundError):
            parse_secret_tags("/nonexistent/path/to/file.env")

    # ========== EDGE CASE TESTS ==========

    def test_parse_tag_with_blank_lines_before_var(self):
        """Should raise error for tag with blank lines before variable (strict parsing)"""
        env_content = """# @secret:op:vault/item/field

VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                # Implementation decision: Be strict - tag must be immediately before variable
                # If blank lines exist, raise error
                with pytest.raises(SecretTagError) as exc_info:
                    parse_secret_tags(f.name)
                assert "immediately" in str(exc_info.value).lower() or "blank" in str(exc_info.value).lower()
            finally:
                os.unlink(f.name)

    def test_parse_ignores_inline_comments_after_tag(self):
        """Should parse tag and ignore any inline comments"""
        env_content = """# @secret:op:vault/item/field # This is a comment
VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                result = parse_secret_tags(f.name)
                assert result == {
                    "VAR": ("vault", "item", "field")
                }
            finally:
                os.unlink(f.name)

    def test_parse_handles_whitespace_variations(self):
        """Should handle leading/trailing whitespace in tags"""
        env_content = """#   @secret:op:vault/item/field
VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                result = parse_secret_tags(f.name)
                assert result == {
                    "VAR": ("vault", "item", "field")
                }
            finally:
                os.unlink(f.name)

    def test_parse_rejects_duplicate_variable_names(self):
        """Should raise error if same variable has multiple secret tags"""
        env_content = """# @secret:op:vault1/item1/field1
VAR=placeholder

# @secret:op:vault2/item2/field2
VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()

            try:
                with pytest.raises(SecretTagError) as exc_info:
                    parse_secret_tags(f.name)
                assert "duplicate" in str(exc_info.value).lower()
            finally:
                os.unlink(f.name)


class TestSecretTagError:
    """Test suite for SecretTagError exception"""

    def test_secret_tag_error_is_exception(self):
        """SecretTagError should be an Exception subclass"""
        assert issubclass(SecretTagError, Exception)

    def test_secret_tag_error_with_message(self):
        """SecretTagError should accept and store error message"""
        error = SecretTagError("Test error message")
        assert str(error) == "Test error message"


# ========== FETCH_SECRET TESTS (REQ-300) ==========

class TestFetchSecret:
    """Test suite for fetch_secret() function - 1Password CLI integration"""

    # ========== HAPPY PATH TESTS ==========

    def test_fetch_secret_success(self, monkeypatch):
        """Should fetch secret from 1Password using op CLI"""
        import subprocess
        from unittest.mock import Mock

        # Mock environment variable
        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

        # Mock subprocess.run to return successful response
        mock_result = Mock()
        mock_result.returncode = 0
        mock_result.stdout = "secret-value-123"
        mock_result.stderr = ""

        def mock_run(*args, **kwargs):
            return mock_result

        monkeypatch.setattr(subprocess, "run", mock_run)

        # Import after mocking
        from haunt_secrets import fetch_secret

        result = fetch_secret("my-vault", "my-item", "my-field")
        assert result == "secret-value-123"

    def test_fetch_secret_strips_whitespace(self, monkeypatch):
        """Should strip leading/trailing whitespace from secret value"""
        import subprocess
        from unittest.mock import Mock

        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

        mock_result = Mock()
        mock_result.returncode = 0
        mock_result.stdout = "  secret-with-whitespace  \n"
        mock_result.stderr = ""

        def mock_run(*args, **kwargs):
            return mock_result

        monkeypatch.setattr(subprocess, "run", mock_run)

        from haunt_secrets import fetch_secret

        result = fetch_secret("vault", "item", "field")
        assert result == "secret-with-whitespace"

    # ========== ERROR HANDLING TESTS ==========

    def test_fetch_secret_missing_token(self, monkeypatch):
        """Should raise MissingTokenError if OP_SERVICE_ACCOUNT_TOKEN not set"""
        # Ensure environment variable is NOT set
        monkeypatch.delenv("OP_SERVICE_ACCOUNT_TOKEN", raising=False)

        from haunt_secrets import fetch_secret, MissingTokenError

        with pytest.raises(MissingTokenError) as exc_info:
            fetch_secret("vault", "item", "field")

        error_msg = str(exc_info.value).lower()
        assert "op_service_account_token" in error_msg
        assert "not set" in error_msg

    def test_fetch_secret_empty_token(self, monkeypatch):
        """Should raise MissingTokenError if OP_SERVICE_ACCOUNT_TOKEN is empty string"""
        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "")

        from haunt_secrets import fetch_secret, MissingTokenError

        with pytest.raises(MissingTokenError) as exc_info:
            fetch_secret("vault", "item", "field")

        assert "not set" in str(exc_info.value).lower()

    def test_fetch_secret_op_not_installed(self, monkeypatch):
        """Should raise OpNotInstalledError if op CLI is not found"""
        import subprocess

        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

        # Mock subprocess.run to raise FileNotFoundError (op command not found)
        def mock_run(*args, **kwargs):
            raise FileNotFoundError("op: command not found")

        monkeypatch.setattr(subprocess, "run", mock_run)

        from haunt_secrets import fetch_secret, OpNotInstalledError

        with pytest.raises(OpNotInstalledError) as exc_info:
            fetch_secret("vault", "item", "field")

        error_msg = str(exc_info.value).lower()
        assert "op" in error_msg
        assert "not installed" in error_msg or "not found" in error_msg

    def test_fetch_secret_authentication_error(self, monkeypatch):
        """Should raise AuthenticationError if 1Password auth fails"""
        import subprocess
        from unittest.mock import Mock

        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "invalid-token")

        # Mock subprocess.run to return auth failure
        mock_result = Mock()
        mock_result.returncode = 1
        mock_result.stdout = ""
        mock_result.stderr = "[ERROR] 2024/01/02 invalid service account token"

        def mock_run(*args, **kwargs):
            return mock_result

        monkeypatch.setattr(subprocess, "run", mock_run)

        from haunt_secrets import fetch_secret, AuthenticationError

        with pytest.raises(AuthenticationError) as exc_info:
            fetch_secret("vault", "item", "field")

        error_msg = str(exc_info.value).lower()
        assert "authentication" in error_msg or "auth" in error_msg

    def test_fetch_secret_not_found_vault(self, monkeypatch):
        """Should raise SecretNotFoundError if vault doesn't exist"""
        import subprocess
        from unittest.mock import Mock

        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

        mock_result = Mock()
        mock_result.returncode = 1
        mock_result.stdout = ""
        mock_result.stderr = '[ERROR] vault "nonexistent-vault" not found'

        def mock_run(*args, **kwargs):
            return mock_result

        monkeypatch.setattr(subprocess, "run", mock_run)

        from haunt_secrets import fetch_secret, SecretNotFoundError

        with pytest.raises(SecretNotFoundError) as exc_info:
            fetch_secret("nonexistent-vault", "item", "field")

        error_msg = str(exc_info.value).lower()
        assert "vault" in error_msg or "not found" in error_msg

    def test_fetch_secret_not_found_item(self, monkeypatch):
        """Should raise SecretNotFoundError if item doesn't exist"""
        import subprocess
        from unittest.mock import Mock

        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

        mock_result = Mock()
        mock_result.returncode = 1
        mock_result.stdout = ""
        mock_result.stderr = '[ERROR] item "nonexistent-item" not found in vault "my-vault"'

        def mock_run(*args, **kwargs):
            return mock_result

        monkeypatch.setattr(subprocess, "run", mock_run)

        from haunt_secrets import fetch_secret, SecretNotFoundError

        with pytest.raises(SecretNotFoundError) as exc_info:
            fetch_secret("my-vault", "nonexistent-item", "field")

        assert "not found" in str(exc_info.value).lower()

    def test_fetch_secret_not_found_field(self, monkeypatch):
        """Should raise SecretNotFoundError if field doesn't exist"""
        import subprocess
        from unittest.mock import Mock

        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

        mock_result = Mock()
        mock_result.returncode = 1
        mock_result.stdout = ""
        mock_result.stderr = '[ERROR] field "nonexistent-field" not found'

        def mock_run(*args, **kwargs):
            return mock_result

        monkeypatch.setattr(subprocess, "run", mock_run)

        from haunt_secrets import fetch_secret, SecretNotFoundError

        with pytest.raises(SecretNotFoundError) as exc_info:
            fetch_secret("vault", "item", "nonexistent-field")

        assert "not found" in str(exc_info.value).lower()

    # ========== EDGE CASE TESTS ==========

    def test_fetch_secret_validates_input_types(self):
        """Should raise TypeError if vault, item, or field are not strings"""
        import os
        os.environ["OP_SERVICE_ACCOUNT_TOKEN"] = "test-token"

        from haunt_secrets import fetch_secret

        with pytest.raises(TypeError):
            fetch_secret(None, "item", "field")

        with pytest.raises(TypeError):
            fetch_secret("vault", 123, "field")

        with pytest.raises(TypeError):
            fetch_secret("vault", "item", ["field"])

    def test_fetch_secret_validates_input_not_empty(self):
        """Should raise ValueError if vault, item, or field are empty strings"""
        import os
        os.environ["OP_SERVICE_ACCOUNT_TOKEN"] = "test-token"

        from haunt_secrets import fetch_secret

        with pytest.raises(ValueError):
            fetch_secret("", "item", "field")

        with pytest.raises(ValueError):
            fetch_secret("vault", "", "field")

        with pytest.raises(ValueError):
            fetch_secret("vault", "item", "")

    def test_fetch_secret_calls_op_read_with_correct_format(self, monkeypatch):
        """Should call `op read` with correct op://vault/item/field format"""
        import subprocess
        from unittest.mock import Mock

        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

        # Track what command was called
        called_with = []

        mock_result = Mock()
        mock_result.returncode = 0
        mock_result.stdout = "secret-value"
        mock_result.stderr = ""

        def mock_run(cmd, *args, **kwargs):
            called_with.append(cmd)
            return mock_result

        monkeypatch.setattr(subprocess, "run", mock_run)

        from haunt_secrets import fetch_secret

        fetch_secret("my-vault", "my-item", "my-field")

        # Verify command format
        assert len(called_with) == 1
        cmd = called_with[0]
        assert cmd[0] == "op"
        assert cmd[1] == "read"
        assert cmd[2] == "op://my-vault/my-item/my-field"

    def test_fetch_secret_handles_multiline_secret(self, monkeypatch):
        """Should preserve multiline secrets (e.g., SSH keys, certificates)"""
        import subprocess
        from unittest.mock import Mock

        monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

        multiline_secret = """-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
-----END RSA PRIVATE KEY-----"""

        mock_result = Mock()
        mock_result.returncode = 0
        mock_result.stdout = multiline_secret
        mock_result.stderr = ""

        def mock_run(*args, **kwargs):
            return mock_result

        monkeypatch.setattr(subprocess, "run", mock_run)

        from haunt_secrets import fetch_secret

        result = fetch_secret("vault", "item", "private-key")
        assert result == multiline_secret


class TestFetchSecretExceptions:
    """Test suite for custom exception classes in fetch_secret"""

    def test_missing_token_error_is_exception(self):
        """MissingTokenError should be an Exception subclass"""
        from haunt_secrets import MissingTokenError
        assert issubclass(MissingTokenError, Exception)

    def test_op_not_installed_error_is_exception(self):
        """OpNotInstalledError should be an Exception subclass"""
        from haunt_secrets import OpNotInstalledError
        assert issubclass(OpNotInstalledError, Exception)

    def test_authentication_error_is_exception(self):
        """AuthenticationError should be an Exception subclass"""
        from haunt_secrets import AuthenticationError
        assert issubclass(AuthenticationError, Exception)

    def test_secret_not_found_error_is_exception(self):
        """SecretNotFoundError should be an Exception subclass"""
        from haunt_secrets import SecretNotFoundError
        assert issubclass(SecretNotFoundError, Exception)


# ========== LOAD_SECRETS AND GET_SECRETS API TESTS (REQ-302) ==========

class TestLoadSecrets:
    """Test suite for load_secrets() - modifies os.environ"""

    def test_load_secrets_populates_os_environ(self, monkeypatch):
        """Should fetch secrets and set them in os.environ"""
        import subprocess
        from unittest.mock import Mock
        import tempfile

        # Create test .env file
        env_content = """# @secret:op:vault1/item1/field1
SECRET_VAR=placeholder

PLAINTEXT_VAR=plaintext-value
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            # Mock 1Password CLI
            monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

            mock_result = Mock()
            mock_result.returncode = 0
            mock_result.stdout = "secret-value-123"
            mock_result.stderr = ""

            def mock_run(*args, **kwargs):
                return mock_result

            monkeypatch.setattr(subprocess, "run", mock_run)

            # Import and call load_secrets
            from haunt_secrets import load_secrets

            load_secrets(env_file)

            # Verify os.environ was modified
            assert os.environ["SECRET_VAR"] == "secret-value-123"
            assert os.environ["PLAINTEXT_VAR"] == "plaintext-value"
        finally:
            os.unlink(env_file)
            # Cleanup environ
            os.environ.pop("SECRET_VAR", None)
            os.environ.pop("PLAINTEXT_VAR", None)

    def test_load_secrets_includes_plaintext_variables(self, monkeypatch):
        """Should include plaintext variables from .env file"""
        import tempfile

        env_content = """PLAINTEXT1=value1
PLAINTEXT2=value2
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            from haunt_secrets import load_secrets

            load_secrets(env_file)

            assert os.environ["PLAINTEXT1"] == "value1"
            assert os.environ["PLAINTEXT2"] == "value2"
        finally:
            os.unlink(env_file)
            os.environ.pop("PLAINTEXT1", None)
            os.environ.pop("PLAINTEXT2", None)

    def test_load_secrets_resolves_multiple_secrets(self, monkeypatch):
        """Should fetch and set multiple secrets"""
        import subprocess
        from unittest.mock import Mock
        import tempfile

        env_content = """# @secret:op:vault1/item1/field1
SECRET1=placeholder

# @secret:op:vault2/item2/field2
SECRET2=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

            # Mock different return values for each call
            call_count = [0]

            def mock_run(cmd, *args, **kwargs):
                call_count[0] += 1
                mock_result = Mock()
                mock_result.returncode = 0
                mock_result.stdout = f"secret-value-{call_count[0]}"
                mock_result.stderr = ""
                return mock_result

            monkeypatch.setattr(subprocess, "run", mock_run)

            from haunt_secrets import load_secrets

            load_secrets(env_file)

            assert os.environ["SECRET1"] == "secret-value-1"
            assert os.environ["SECRET2"] == "secret-value-2"
        finally:
            os.unlink(env_file)
            os.environ.pop("SECRET1", None)
            os.environ.pop("SECRET2", None)

    def test_load_secrets_logs_variable_names_not_values(self, monkeypatch, caplog):
        """Should log variable names loaded, never the secret values"""
        import subprocess
        from unittest.mock import Mock
        import tempfile
        import logging

        env_content = """# @secret:op:vault/item/field
SECRET_VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

            mock_result = Mock()
            mock_result.returncode = 0
            mock_result.stdout = "super-secret-value-do-not-log"
            mock_result.stderr = ""

            monkeypatch.setattr(subprocess, "run", lambda *args, **kwargs: mock_result)

            from haunt_secrets import load_secrets

            with caplog.at_level(logging.INFO):
                load_secrets(env_file)

            # Verify logs contain variable name
            log_output = caplog.text
            assert "SECRET_VAR" in log_output

            # SECURITY: Verify logs DO NOT contain secret value
            assert "super-secret-value-do-not-log" not in log_output
        finally:
            os.unlink(env_file)
            os.environ.pop("SECRET_VAR", None)

    def test_load_secrets_raises_for_nonexistent_file(self):
        """Should raise FileNotFoundError for nonexistent .env file"""
        from haunt_secrets import load_secrets

        with pytest.raises(FileNotFoundError):
            load_secrets("/nonexistent/.env")


class TestGetSecrets:
    """Test suite for get_secrets() - returns dict without modifying environment"""

    def test_get_secrets_returns_dict_with_resolved_secrets(self, monkeypatch):
        """Should return dict with secrets resolved from 1Password"""
        import subprocess
        from unittest.mock import Mock
        import tempfile

        env_content = """# @secret:op:vault/item/field
SECRET_VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

            mock_result = Mock()
            mock_result.returncode = 0
            mock_result.stdout = "secret-value-123"
            mock_result.stderr = ""

            monkeypatch.setattr(subprocess, "run", lambda *args, **kwargs: mock_result)

            from haunt_secrets import get_secrets

            result = get_secrets(env_file)

            assert result == {"SECRET_VAR": "secret-value-123"}
        finally:
            os.unlink(env_file)

    def test_get_secrets_includes_plaintext_variables(self, monkeypatch):
        """Should include plaintext variables in returned dict"""
        import tempfile

        env_content = """PLAINTEXT1=value1
PLAINTEXT2=value2
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            from haunt_secrets import get_secrets

            result = get_secrets(env_file)

            assert result == {
                "PLAINTEXT1": "value1",
                "PLAINTEXT2": "value2"
            }
        finally:
            os.unlink(env_file)

    def test_get_secrets_combines_secrets_and_plaintext(self, monkeypatch):
        """Should return dict with both secrets and plaintext variables"""
        import subprocess
        from unittest.mock import Mock
        import tempfile

        env_content = """# @secret:op:vault/item/field
SECRET_VAR=placeholder

PLAINTEXT_VAR=plaintext-value
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

            mock_result = Mock()
            mock_result.returncode = 0
            mock_result.stdout = "secret-value-123"
            mock_result.stderr = ""

            monkeypatch.setattr(subprocess, "run", lambda *args, **kwargs: mock_result)

            from haunt_secrets import get_secrets

            result = get_secrets(env_file)

            assert result == {
                "SECRET_VAR": "secret-value-123",
                "PLAINTEXT_VAR": "plaintext-value"
            }
        finally:
            os.unlink(env_file)

    def test_get_secrets_does_not_modify_os_environ(self, monkeypatch):
        """Should NOT modify os.environ (read-only mode)"""
        import subprocess
        from unittest.mock import Mock
        import tempfile

        env_content = """# @secret:op:vault/item/field
SECRET_VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            # Ensure SECRET_VAR is not already in environment
            os.environ.pop("SECRET_VAR", None)

            monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

            mock_result = Mock()
            mock_result.returncode = 0
            mock_result.stdout = "secret-value-123"
            mock_result.stderr = ""

            monkeypatch.setattr(subprocess, "run", lambda *args, **kwargs: mock_result)

            from haunt_secrets import get_secrets

            result = get_secrets(env_file)

            # Verify dict has secret
            assert result["SECRET_VAR"] == "secret-value-123"

            # Verify os.environ was NOT modified
            assert "SECRET_VAR" not in os.environ
        finally:
            os.unlink(env_file)

    def test_get_secrets_raises_for_nonexistent_file(self):
        """Should raise FileNotFoundError for nonexistent .env file"""
        from haunt_secrets import get_secrets

        with pytest.raises(FileNotFoundError):
            get_secrets("/nonexistent/.env")


# ========== VALIDATE_SECRETS TESTS (REQ-304) ==========

class TestValidateSecrets:
    """Test suite for validate_secrets() - validation mode without exporting"""

    def test_validate_secrets_all_resolvable(self, monkeypatch):
        """Should return success when all secrets are resolvable"""
        import subprocess
        from unittest.mock import Mock
        import tempfile

        env_content = """# @secret:op:vault1/item1/field1
SECRET1=placeholder

# @secret:op:vault2/item2/field2
SECRET2=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

            # Mock all secrets as resolvable
            call_count = [0]

            def mock_run(cmd, *args, **kwargs):
                call_count[0] += 1
                mock_result = Mock()
                mock_result.returncode = 0
                mock_result.stdout = f"secret-value-{call_count[0]}"
                mock_result.stderr = ""
                return mock_result

            monkeypatch.setattr(subprocess, "run", mock_run)

            from haunt_secrets import validate_secrets

            result = validate_secrets(env_file)

            # Verify result
            assert result.success is True
            assert len(result.validated) == 2
            assert "SECRET1" in result.validated
            assert "SECRET2" in result.validated
            assert len(result.missing) == 0

            # Verify os.environ was NOT modified
            assert "SECRET1" not in os.environ
            assert "SECRET2" not in os.environ
        finally:
            os.unlink(env_file)

    def test_validate_secrets_some_missing(self, monkeypatch):
        """Should return failure when some secrets are not resolvable"""
        import subprocess
        from unittest.mock import Mock
        import tempfile

        env_content = """# @secret:op:vault1/item1/field1
SECRET1=placeholder

# @secret:op:vault2/missing-item/field2
SECRET2=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

            # Mock first secret succeeds, second fails
            def mock_run(cmd, *args, **kwargs):
                mock_result = Mock()
                if "missing-item" in cmd[2]:
                    mock_result.returncode = 1
                    mock_result.stdout = ""
                    mock_result.stderr = "item not found"
                else:
                    mock_result.returncode = 0
                    mock_result.stdout = "secret-value"
                    mock_result.stderr = ""
                return mock_result

            monkeypatch.setattr(subprocess, "run", mock_run)

            from haunt_secrets import validate_secrets

            result = validate_secrets(env_file)

            # Verify result
            assert result.success is False
            assert len(result.validated) == 1
            assert "SECRET1" in result.validated
            assert len(result.missing) == 1
            assert result.missing[0][0] == "SECRET2"  # var_name
            assert "op://vault2/missing-item/field2" in result.missing[0][1]  # op_ref
        finally:
            os.unlink(env_file)

    def test_validate_secrets_empty_env(self, monkeypatch):
        """Should return success with empty lists when no secrets in .env"""
        import tempfile

        env_content = """PLAINTEXT1=value1
PLAINTEXT2=value2
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            from haunt_secrets import validate_secrets

            result = validate_secrets(env_file)

            assert result.success is True
            assert len(result.validated) == 0
            assert len(result.missing) == 0
        finally:
            os.unlink(env_file)

    def test_validate_secrets_debug_mode(self, monkeypatch, caplog):
        """Should log debug information when debug=True"""
        import subprocess
        from unittest.mock import Mock
        import tempfile
        import logging

        env_content = """# @secret:op:vault/item/field
SECRET_VAR=placeholder
"""
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.env') as f:
            f.write(env_content)
            f.flush()
            env_file = f.name

        try:
            monkeypatch.setenv("OP_SERVICE_ACCOUNT_TOKEN", "test-token")

            mock_result = Mock()
            mock_result.returncode = 0
            mock_result.stdout = "secret-value"
            mock_result.stderr = ""

            monkeypatch.setattr(subprocess, "run", lambda *args, **kwargs: mock_result)

            from haunt_secrets import validate_secrets

            with caplog.at_level(logging.INFO):
                result = validate_secrets(env_file, debug=True)

            # Verify debug logging
            log_output = caplog.text
            assert "SECRET_VAR" in log_output
            assert "op://vault/item/field" in log_output

            # Verify result
            assert result.success is True
            assert "SECRET_VAR" in result.validated
        finally:
            os.unlink(env_file)

    def test_validate_secrets_nonexistent_file(self):
        """Should raise FileNotFoundError for nonexistent .env file"""
        from haunt_secrets import validate_secrets

        with pytest.raises(FileNotFoundError):
            validate_secrets("/nonexistent/.env")

    def test_validation_result_attributes(self):
        """ValidationResult should have success, validated, and missing attributes"""
        from haunt_secrets import ValidationResult

        # Test successful validation result
        result_success = ValidationResult(success=True, validated=["VAR1", "VAR2"], missing=[])
        assert result_success.success is True
        assert result_success.validated == ["VAR1", "VAR2"]
        assert result_success.missing == []

        # Test failed validation result
        result_failure = ValidationResult(
            success=False,
            validated=["VAR1"],
            missing=[("VAR2", "op://vault/item/field", "not found")]
        )
        assert result_failure.success is False
        assert result_failure.validated == ["VAR1"]
        assert len(result_failure.missing) == 1
