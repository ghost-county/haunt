"""
Unit tests for haunt_secrets.py - Tag Parser for 1Password Secret References

Tests the parse_secret_tags() function which extracts 1Password secret references
from .env files with the format: # @secret:op:vault/item/field
"""

import pytest
import tempfile
import os
from pathlib import Path


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
