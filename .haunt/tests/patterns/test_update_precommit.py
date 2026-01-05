#!/usr/bin/env python3
"""
Unit tests for update_precommit.py module.

Tests the pre-commit configuration update functionality.
"""

import sys
import tempfile
from pathlib import Path

# Add pattern-detector directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'Haunt' / 'scripts' / 'rituals' / 'pattern-detector'))

import pytest
import yaml

from update_precommit import (
    DEFAULT_CONFIG,
    PreCommitUpdater
)


class TestPreCommitUpdater:
    """Test PreCommitUpdater class."""

    def test_initialization_defaults(self):
        """Test default initialization."""
        updater = PreCommitUpdater()

        assert updater.config_path == Path('.pre-commit-config.yaml')
        assert updater.test_dir == Path('.haunt/tests/patterns')

    def test_initialization_custom_paths(self):
        """Test initialization with custom paths."""
        config_path = Path('/tmp/custom-config.yaml')
        test_dir = Path('/tmp/custom-tests')

        updater = PreCommitUpdater(
            config_path=config_path,
            test_dir=test_dir
        )

        assert updater.config_path == config_path
        assert updater.test_dir == test_dir

    def test_check_precommit_installed(self):
        """Test pre-commit installation check."""
        updater = PreCommitUpdater()

        # This will return True or False depending on system
        # Just verify it doesn't crash
        result = updater.check_precommit_installed()
        assert isinstance(result, bool)

    def test_load_config_missing_file(self):
        """Test loading config when file doesn't exist."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config_path = Path(tmpdir) / '.pre-commit-config.yaml'
            updater = PreCommitUpdater(config_path=config_path)

            config = updater.load_config()

            assert config == DEFAULT_CONFIG
            assert 'repos' in config
            assert config['repos'] == []

    def test_load_config_empty_file(self):
        """Test loading empty config file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config_path = Path(tmpdir) / '.pre-commit-config.yaml'
            config_path.write_text('')

            updater = PreCommitUpdater(config_path=config_path)
            config = updater.load_config()

            assert config == DEFAULT_CONFIG

    def test_load_config_valid_file(self):
        """Test loading valid config file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config_path = Path(tmpdir) / '.pre-commit-config.yaml'

            sample_config = {
                'repos': [
                    {
                        'repo': 'https://github.com/example/hooks',
                        'hooks': [
                            {
                                'id': 'example-hook',
                                'name': 'Example Hook',
                                'entry': 'example',
                                'language': 'system'
                            }
                        ]
                    }
                ]
            }

            with open(config_path, 'w') as f:
                yaml.safe_dump(sample_config, f)

            updater = PreCommitUpdater(config_path=config_path)
            config = updater.load_config()

            assert config['repos'] == sample_config['repos']

    def test_find_local_repo_exists(self):
        """Test finding existing local repo."""
        updater = PreCommitUpdater()

        config = {
            'repos': [
                {'repo': 'https://github.com/example/hooks', 'hooks': []},
                {'repo': 'local', 'hooks': []},
            ]
        }

        local_repo = updater.find_local_repo(config)

        assert local_repo is not None
        assert local_repo['repo'] == 'local'

    def test_find_local_repo_missing(self):
        """Test finding local repo when it doesn't exist."""
        updater = PreCommitUpdater()

        config = {
            'repos': [
                {'repo': 'https://github.com/example/hooks', 'hooks': []},
            ]
        }

        local_repo = updater.find_local_repo(config)

        assert local_repo is None

    def test_find_pattern_hook_exists(self):
        """Test finding existing pattern hook."""
        updater = PreCommitUpdater()

        local_repo = {
            'repo': 'local',
            'hooks': [
                {'id': 'other-hook', 'name': 'Other', 'entry': 'other', 'language': 'system'},
                {'id': 'pattern-defeat-tests', 'name': 'Pattern Tests', 'entry': 'pytest', 'language': 'system'},
            ]
        }

        pattern_hook = updater.find_pattern_hook(local_repo)

        assert pattern_hook is not None
        assert pattern_hook['id'] == 'pattern-defeat-tests'

    def test_find_pattern_hook_missing(self):
        """Test finding pattern hook when it doesn't exist."""
        updater = PreCommitUpdater()

        local_repo = {
            'repo': 'local',
            'hooks': [
                {'id': 'other-hook', 'name': 'Other', 'entry': 'other', 'language': 'system'},
            ]
        }

        pattern_hook = updater.find_pattern_hook(local_repo)

        assert pattern_hook is None

    def test_get_test_command(self):
        """Test getting pytest command."""
        test_dir = Path('.haunt/tests/patterns')
        updater = PreCommitUpdater(test_dir=test_dir)

        command = updater.get_test_command()

        assert 'pytest' in command
        assert '.haunt/tests/patterns' in command
        assert '-v' in command

    def test_update_config_empty(self):
        """Test updating empty config."""
        with tempfile.TemporaryDirectory() as tmpdir:
            test_dir = Path(tmpdir) / 'tests'
            test_dir.mkdir()

            updater = PreCommitUpdater(test_dir=test_dir)

            config = DEFAULT_CONFIG.copy()
            updated_config, changed = updater.update_config(config)

            assert changed is True
            assert 'repos' in updated_config
            assert len(updated_config['repos']) == 1

            local_repo = updated_config['repos'][0]
            assert local_repo['repo'] == 'local'
            assert len(local_repo['hooks']) == 1

            pattern_hook = local_repo['hooks'][0]
            assert pattern_hook['id'] == 'pattern-defeat-tests'
            assert 'pytest' in pattern_hook['entry']

    def test_update_config_existing_local_repo(self):
        """Test updating config with existing local repo."""
        with tempfile.TemporaryDirectory() as tmpdir:
            test_dir = Path(tmpdir) / 'tests'
            test_dir.mkdir()

            updater = PreCommitUpdater(test_dir=test_dir)

            config = {
                'repos': [
                    {
                        'repo': 'local',
                        'hooks': [
                            {'id': 'existing-hook', 'name': 'Existing', 'entry': 'existing', 'language': 'system'}
                        ]
                    }
                ]
            }

            updated_config, changed = updater.update_config(config)

            assert changed is True

            local_repo = updated_config['repos'][0]
            assert len(local_repo['hooks']) == 2

            # Existing hook should be preserved
            assert local_repo['hooks'][0]['id'] == 'existing-hook'

            # Pattern hook should be added
            assert local_repo['hooks'][1]['id'] == 'pattern-defeat-tests'

    def test_update_config_idempotent(self):
        """Test that updating twice produces same result."""
        with tempfile.TemporaryDirectory() as tmpdir:
            test_dir = Path(tmpdir) / 'tests'
            test_dir.mkdir()

            updater = PreCommitUpdater(test_dir=test_dir)

            # First update
            config = DEFAULT_CONFIG.copy()
            config1, changed1 = updater.update_config(config)

            assert changed1 is True

            # Second update
            config2, changed2 = updater.update_config(config1)

            assert changed2 is False
            assert config1 == config2

    def test_update_config_command_change(self):
        """Test updating when command changes."""
        with tempfile.TemporaryDirectory() as tmpdir:
            test_dir = Path(tmpdir) / 'tests'
            test_dir.mkdir()

            updater = PreCommitUpdater(test_dir=test_dir)

            # Config with old command
            config = {
                'repos': [
                    {
                        'repo': 'local',
                        'hooks': [
                            {
                                'id': 'pattern-defeat-tests',
                                'name': 'Pattern Tests',
                                'entry': 'pytest old-path -v',
                                'language': 'system',
                                'types': ['python'],
                                'pass_filenames': False
                            }
                        ]
                    }
                ]
            }

            updated_config, changed = updater.update_config(config)

            assert changed is True

            pattern_hook = updated_config['repos'][0]['hooks'][0]
            assert str(test_dir) in pattern_hook['entry']

    def test_validate_config_valid(self):
        """Test validating valid config."""
        updater = PreCommitUpdater()

        config = {
            'repos': [
                {
                    'repo': 'local',
                    'hooks': [
                        {
                            'id': 'test-hook',
                            'name': 'Test',
                            'entry': 'test',
                            'language': 'system'
                        }
                    ]
                }
            ]
        }

        is_valid, error = updater.validate_config(config)

        assert is_valid is True
        assert error is None

    def test_validate_config_missing_repos(self):
        """Test validating config without repos key."""
        updater = PreCommitUpdater()

        config = {}

        is_valid, error = updater.validate_config(config)

        assert is_valid is False
        assert 'repos' in error

    def test_validate_config_invalid_repo(self):
        """Test validating config with invalid repo."""
        updater = PreCommitUpdater()

        config = {
            'repos': [
                {
                    # Missing 'repo' key
                    'hooks': []
                }
            ]
        }

        is_valid, error = updater.validate_config(config)

        assert is_valid is False
        assert 'repo' in error.lower()

    def test_validate_config_invalid_hook(self):
        """Test validating config with invalid hook."""
        updater = PreCommitUpdater()

        config = {
            'repos': [
                {
                    'repo': 'local',
                    'hooks': [
                        {
                            'id': 'test-hook',
                            # Missing 'name', 'entry', 'language'
                        }
                    ]
                }
            ]
        }

        is_valid, error = updater.validate_config(config)

        assert is_valid is False

    def test_write_config(self):
        """Test writing config to file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config_path = Path(tmpdir) / '.pre-commit-config.yaml'
            updater = PreCommitUpdater(config_path=config_path)

            config = {
                'repos': [
                    {
                        'repo': 'local',
                        'hooks': [
                            {
                                'id': 'test-hook',
                                'name': 'Test',
                                'entry': 'test',
                                'language': 'system'
                            }
                        ]
                    }
                ]
            }

            updater.write_config(config)

            assert config_path.exists()

            # Read back and verify
            with open(config_path, 'r') as f:
                loaded_config = yaml.safe_load(f)

            assert loaded_config == config

    def test_update_creates_missing_config(self):
        """Test that update creates config if missing."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config_path = Path(tmpdir) / '.pre-commit-config.yaml'
            test_dir = Path(tmpdir) / 'tests'
            test_dir.mkdir()

            updater = PreCommitUpdater(
                config_path=config_path,
                test_dir=test_dir
            )

            success, changed = updater.update(dry_run=False, install=False)

            assert success is True
            assert changed is True
            assert config_path.exists()

            # Verify content
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)

            assert 'repos' in config
            assert len(config['repos']) == 1
            assert config['repos'][0]['repo'] == 'local'

    def test_update_preserves_existing_hooks(self):
        """Test that update preserves existing hooks."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config_path = Path(tmpdir) / '.pre-commit-config.yaml'
            test_dir = Path(tmpdir) / 'tests'
            test_dir.mkdir()

            # Create existing config
            existing_config = {
                'repos': [
                    {
                        'repo': 'https://github.com/example/hooks',
                        'hooks': [
                            {
                                'id': 'example-hook',
                                'name': 'Example',
                                'entry': 'example',
                                'language': 'system'
                            }
                        ]
                    },
                    {
                        'repo': 'local',
                        'hooks': [
                            {
                                'id': 'custom-hook',
                                'name': 'Custom',
                                'entry': 'custom',
                                'language': 'system'
                            }
                        ]
                    }
                ]
            }

            with open(config_path, 'w') as f:
                yaml.safe_dump(existing_config, f)

            updater = PreCommitUpdater(
                config_path=config_path,
                test_dir=test_dir
            )

            success, changed = updater.update(dry_run=False, install=False)

            assert success is True
            assert changed is True

            # Verify content
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)

            # Should have 2 repos
            assert len(config['repos']) == 2

            # First repo should be unchanged
            assert config['repos'][0]['repo'] == 'https://github.com/example/hooks'
            assert len(config['repos'][0]['hooks']) == 1

            # Local repo should have both hooks
            assert config['repos'][1]['repo'] == 'local'
            assert len(config['repos'][1]['hooks']) == 2
            assert config['repos'][1]['hooks'][0]['id'] == 'custom-hook'
            assert config['repos'][1]['hooks'][1]['id'] == 'pattern-defeat-tests'

    def test_update_dry_run(self):
        """Test dry run mode."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config_path = Path(tmpdir) / '.pre-commit-config.yaml'
            test_dir = Path(tmpdir) / 'tests'
            test_dir.mkdir()

            updater = PreCommitUpdater(
                config_path=config_path,
                test_dir=test_dir
            )

            success, changed = updater.update(dry_run=True, install=False)

            assert success is True
            assert changed is True

            # Config file should NOT be created in dry run
            assert not config_path.exists()

    def test_update_idempotent_file_writes(self):
        """Test that running update twice doesn't modify file second time."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config_path = Path(tmpdir) / '.pre-commit-config.yaml'
            test_dir = Path(tmpdir) / 'tests'
            test_dir.mkdir()

            updater = PreCommitUpdater(
                config_path=config_path,
                test_dir=test_dir
            )

            # First update
            success1, changed1 = updater.update(dry_run=False, install=False)

            assert success1 is True
            assert changed1 is True

            # Get modification time
            mtime1 = config_path.stat().st_mtime

            # Small delay to ensure different mtime if file is modified
            import time
            time.sleep(0.1)

            # Second update
            success2, changed2 = updater.update(dry_run=False, install=False)

            assert success2 is True
            assert changed2 is False

            # File should not be modified
            mtime2 = config_path.stat().st_mtime
            assert mtime1 == mtime2


class TestIntegration:
    """Integration tests for complete workflows."""

    def test_new_repository_workflow(self):
        """Test workflow for a new repository without pre-commit config."""
        with tempfile.TemporaryDirectory() as tmpdir:
            repo_dir = Path(tmpdir) / 'new-repo'
            repo_dir.mkdir()

            config_path = repo_dir / '.pre-commit-config.yaml'
            test_dir = repo_dir / '.haunt' / 'tests' / 'patterns'
            test_dir.mkdir(parents=True)

            # Create a sample test file
            test_file = test_dir / 'test_example.py'
            test_file.write_text('''
def test_example():
    """Example test."""
    assert True
''')

            # Run updater
            updater = PreCommitUpdater(
                config_path=config_path,
                test_dir=test_dir
            )

            success, changed = updater.update(dry_run=False, install=False)

            assert success is True
            assert changed is True
            assert config_path.exists()

            # Verify config structure
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)

            assert config['repos'][0]['repo'] == 'local'
            assert config['repos'][0]['hooks'][0]['id'] == 'pattern-defeat-tests'

            # Verify test command includes correct path
            entry = config['repos'][0]['hooks'][0]['entry']
            assert str(test_dir) in entry

    def test_existing_repository_workflow(self):
        """Test workflow for existing repository with pre-commit config."""
        with tempfile.TemporaryDirectory() as tmpdir:
            repo_dir = Path(tmpdir) / 'existing-repo'
            repo_dir.mkdir()

            config_path = repo_dir / '.pre-commit-config.yaml'
            test_dir = repo_dir / '.haunt' / 'tests' / 'patterns'
            test_dir.mkdir(parents=True)

            # Create existing config with other hooks
            existing_config = {
                'repos': [
                    {
                        'repo': 'https://github.com/psf/black',
                        'rev': '23.1.0',
                        'hooks': [
                            {
                                'id': 'black',
                                'name': 'black',
                                'entry': 'black',
                                'language': 'system'
                            }
                        ]
                    }
                ]
            }

            with open(config_path, 'w') as f:
                yaml.safe_dump(existing_config, f)

            # Run updater
            updater = PreCommitUpdater(
                config_path=config_path,
                test_dir=test_dir
            )

            success, changed = updater.update(dry_run=False, install=False)

            assert success is True
            assert changed is True

            # Verify config structure
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)

            # Should have 2 repos now
            assert len(config['repos']) == 2

            # First repo should be unchanged (black)
            assert config['repos'][0]['repo'] == 'https://github.com/psf/black'

            # Second repo should be local with pattern tests
            assert config['repos'][1]['repo'] == 'local'
            assert config['repos'][1]['hooks'][0]['id'] == 'pattern-defeat-tests'


def run_tests():
    """Run all tests."""
    pytest_args = [
        __file__,
        '-v',
        '--tb=short',
        '-x'  # Stop on first failure
    ]

    return pytest.main(pytest_args)


if __name__ == '__main__':
    sys.exit(run_tests())
