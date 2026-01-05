"""Tests for .env secret tag parser."""

import pytest
from pathlib import Path
from haunt_secrets.parser import parse_env_file, parse_env_content


class TestParseEnvContent:
    """Test parse_env_content function."""

    def test_valid_tag_parsing(self):
        """Should parse valid secret tags correctly."""
        content = """# @secret:op:vault1/item1/field1
SECRET_KEY=placeholder_value
"""
        result = parse_env_content(content)

        assert "SECRET_KEY" in result
        assert result["SECRET_KEY"]["vault"] == "vault1"
        assert result["SECRET_KEY"]["item"] == "item1"
        assert result["SECRET_KEY"]["field"] == "field1"

    def test_multiple_secrets(self):
        """Should parse multiple secrets correctly."""
        content = """# @secret:op:vault1/item1/field1
SECRET_KEY=placeholder1

# @secret:op:vault2/item2/field2
API_TOKEN=placeholder2
"""
        result = parse_env_content(content)

        assert len(result) == 2
        assert "SECRET_KEY" in result
        assert "API_TOKEN" in result
        assert result["SECRET_KEY"]["vault"] == "vault1"
        assert result["API_TOKEN"]["vault"] == "vault2"

    def test_skip_non_secret_variables(self):
        """Should skip variables without @secret tag."""
        content = """# Regular comment
PUBLIC_VAR=value

# @secret:op:vault1/item1/field1
SECRET_VAR=placeholder
"""
        result = parse_env_content(content)

        assert len(result) == 1
        assert "SECRET_VAR" in result
        assert "PUBLIC_VAR" not in result

    def test_malformed_tag_missing_parts(self):
        """Should handle malformed tags with missing parts gracefully."""
        content = """# @secret:op:vault1/item1
INCOMPLETE_TAG=placeholder
"""
        # Should not crash, but should not include malformed entry
        result = parse_env_content(content)

        assert "INCOMPLETE_TAG" not in result

    def test_malformed_tag_wrong_prefix(self):
        """Should skip tags with wrong prefix."""
        content = """# @notsecret:op:vault1/item1/field1
WRONG_PREFIX=placeholder
"""
        result = parse_env_content(content)

        assert "WRONG_PREFIX" not in result

    def test_malformed_tag_missing_colon(self):
        """Should skip tags with incorrect format (missing colons)."""
        content = """# @secret op vault1/item1/field1
MALFORMED=placeholder
"""
        result = parse_env_content(content)

        assert "MALFORMED" not in result

    def test_empty_file(self):
        """Should return empty dict for empty file."""
        content = ""
        result = parse_env_content(content)

        assert result == {}

    def test_comment_only_file(self):
        """Should return empty dict for comment-only file."""
        content = """# Just comments
# No secrets here
# More comments
"""
        result = parse_env_content(content)

        assert result == {}

    def test_duplicate_variable_names(self):
        """Should use last occurrence for duplicate variable names."""
        content = """# @secret:op:vault1/item1/field1
DUPLICATE_VAR=placeholder1

# @secret:op:vault2/item2/field2
DUPLICATE_VAR=placeholder2
"""
        result = parse_env_content(content)

        # Last one wins
        assert len(result) == 1
        assert result["DUPLICATE_VAR"]["vault"] == "vault2"
        assert result["DUPLICATE_VAR"]["item"] == "item2"

    def test_preserve_whitespace_in_paths(self):
        """Should handle paths with whitespace correctly."""
        content = """# @secret:op:vault name/item name/field name
VAR_WITH_SPACES=placeholder
"""
        result = parse_env_content(content)

        # Should parse even with spaces (valid in 1Password)
        assert "VAR_WITH_SPACES" in result
        assert result["VAR_WITH_SPACES"]["vault"] == "vault name"
        assert result["VAR_WITH_SPACES"]["item"] == "item name"
        assert result["VAR_WITH_SPACES"]["field"] == "field name"

    def test_mixed_content(self):
        """Should handle mixed secrets and plaintext variables."""
        content = """# Standard config
PUBLIC_API_URL=https://api.example.com
LOG_LEVEL=debug

# @secret:op:prod/database/password
DB_PASSWORD=placeholder_pwd

# Another public var
APP_NAME=MyApp

# @secret:op:prod/api/key
API_KEY=placeholder_key
"""
        result = parse_env_content(content)

        assert len(result) == 2
        assert "DB_PASSWORD" in result
        assert "API_KEY" in result
        assert "PUBLIC_API_URL" not in result
        assert "LOG_LEVEL" not in result
        assert "APP_NAME" not in result

    def test_variable_without_value(self):
        """Should skip variables without value even if tagged."""
        content = """# @secret:op:vault1/item1/field1
SECRET_VAR
"""
        result = parse_env_content(content)

        # Should skip because no = sign
        assert "SECRET_VAR" not in result

    def test_tag_with_trailing_whitespace(self):
        """Should handle tags with trailing whitespace."""
        content = """# @secret:op:vault1/item1/field1
SECRET_VAR=placeholder
"""
        result = parse_env_content(content)

        assert "SECRET_VAR" in result
        assert result["SECRET_VAR"]["vault"] == "vault1"


class TestParseEnvFile:
    """Test parse_env_file function."""

    def test_parse_existing_file(self, tmp_path):
        """Should parse file from filesystem."""
        env_file = tmp_path / ".env"
        env_file.write_text("""# @secret:op:vault1/item1/field1
SECRET_KEY=placeholder
""")

        result = parse_env_file(str(env_file))

        assert "SECRET_KEY" in result
        assert result["SECRET_KEY"]["vault"] == "vault1"

    def test_parse_nonexistent_file(self):
        """Should raise FileNotFoundError for missing file."""
        with pytest.raises(FileNotFoundError):
            parse_env_file("/nonexistent/path/.env")

    def test_parse_file_with_path_object(self, tmp_path):
        """Should accept Path object as well as string."""
        env_file = tmp_path / ".env"
        env_file.write_text("""# @secret:op:vault1/item1/field1
SECRET_KEY=placeholder
""")

        result = parse_env_file(env_file)

        assert "SECRET_KEY" in result
