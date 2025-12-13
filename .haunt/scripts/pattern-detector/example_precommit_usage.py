#!/usr/bin/env python3
"""
Example: Pre-commit Configuration Update

Demonstrates updating .pre-commit-config.yaml with pattern defeat tests.

Usage:
    python example_precommit_usage.py
"""

import sys
import tempfile
from pathlib import Path

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

from update_precommit import PreCommitUpdater


def example_new_repository():
    """Example 1: Create config for new repository."""
    print("=" * 60)
    print("Example 1: New Repository (No Existing Config)")
    print("=" * 60)

    with tempfile.TemporaryDirectory() as tmpdir:
        repo_dir = Path(tmpdir) / 'new-repo'
        repo_dir.mkdir()

        config_path = repo_dir / '.pre-commit-config.yaml'
        test_dir = repo_dir / '.haunt' / 'tests' / 'patterns'
        test_dir.mkdir(parents=True)

        # Create some test files
        (test_dir / 'test_example.py').write_text('def test_example(): assert True')

        print(f"Repository: {repo_dir}")
        print(f"Config file: {config_path}")
        print(f"Test directory: {test_dir}")
        print(f"\nInitial state:")
        print(f"  Config exists: {config_path.exists()}")

        # Run updater
        updater = PreCommitUpdater(
            config_path=config_path,
            test_dir=test_dir
        )

        success, changed = updater.update(dry_run=False, install=False)

        print(f"\nUpdate result:")
        print(f"  Success: {success}")
        print(f"  Changed: {changed}")
        print(f"  Config exists: {config_path.exists()}")

        if config_path.exists():
            print(f"\nGenerated config:")
            print("-" * 60)
            print(config_path.read_text())
            print("-" * 60)


def example_existing_repository():
    """Example 2: Update existing repository with other hooks."""
    print("\n" + "=" * 60)
    print("Example 2: Existing Repository (With Other Hooks)")
    print("=" * 60)

    with tempfile.TemporaryDirectory() as tmpdir:
        repo_dir = Path(tmpdir) / 'existing-repo'
        repo_dir.mkdir()

        config_path = repo_dir / '.pre-commit-config.yaml'
        test_dir = repo_dir / '.haunt' / 'tests' / 'patterns'
        test_dir.mkdir(parents=True)

        # Create existing config
        existing_config = """repos:
  - repo: https://github.com/psf/black
    rev: 23.1.0
    hooks:
      - id: black
        name: black
        entry: black
        language: system
        types: [python]
"""
        config_path.write_text(existing_config)

        print(f"Repository: {repo_dir}")
        print(f"Test directory: {test_dir}")
        print(f"\nExisting config:")
        print("-" * 60)
        print(existing_config)
        print("-" * 60)

        # Run updater
        updater = PreCommitUpdater(
            config_path=config_path,
            test_dir=test_dir
        )

        success, changed = updater.update(dry_run=False, install=False)

        print(f"\nUpdate result:")
        print(f"  Success: {success}")
        print(f"  Changed: {changed}")

        if config_path.exists():
            print(f"\nUpdated config:")
            print("-" * 60)
            print(config_path.read_text())
            print("-" * 60)


def example_idempotent_updates():
    """Example 3: Running update twice produces same result."""
    print("\n" + "=" * 60)
    print("Example 3: Idempotent Updates")
    print("=" * 60)

    with tempfile.TemporaryDirectory() as tmpdir:
        repo_dir = Path(tmpdir)
        config_path = repo_dir / '.pre-commit-config.yaml'
        test_dir = repo_dir / 'tests'
        test_dir.mkdir()

        updater = PreCommitUpdater(
            config_path=config_path,
            test_dir=test_dir
        )

        # First update
        print("First update...")
        success1, changed1 = updater.update(dry_run=False, install=False)
        content1 = config_path.read_text()

        print(f"  Success: {success1}")
        print(f"  Changed: {changed1}")

        # Second update
        print("\nSecond update...")
        success2, changed2 = updater.update(dry_run=False, install=False)
        content2 = config_path.read_text()

        print(f"  Success: {success2}")
        print(f"  Changed: {changed2}")

        # Verify idempotent
        print(f"\nIdempotent: {content1 == content2}")
        print(f"Second update made changes: {changed2}")


def example_dry_run():
    """Example 4: Dry run to preview changes."""
    print("\n" + "=" * 60)
    print("Example 4: Dry Run (Preview Changes)")
    print("=" * 60)

    with tempfile.TemporaryDirectory() as tmpdir:
        repo_dir = Path(tmpdir)
        config_path = repo_dir / '.pre-commit-config.yaml'
        test_dir = repo_dir / 'tests'
        test_dir.mkdir()

        updater = PreCommitUpdater(
            config_path=config_path,
            test_dir=test_dir
        )

        print("Running dry run...")
        success, changed = updater.update(dry_run=True, install=False)

        print(f"\nDry run result:")
        print(f"  Success: {success}")
        print(f"  Changed: {changed}")
        print(f"  Config created: {config_path.exists()}")

        if not config_path.exists():
            print("\n✓ Dry run did not create file (as expected)")


def example_programmatic_usage():
    """Example 5: Using the module programmatically."""
    print("\n" + "=" * 60)
    print("Example 5: Programmatic Usage")
    print("=" * 60)

    with tempfile.TemporaryDirectory() as tmpdir:
        repo_dir = Path(tmpdir)
        config_path = repo_dir / '.pre-commit-config.yaml'
        test_dir = repo_dir / 'tests'
        test_dir.mkdir()

        # Initialize updater
        updater = PreCommitUpdater(
            config_path=config_path,
            test_dir=test_dir
        )

        # Load (or create) config
        config = updater.load_config()
        print(f"Initial config has {len(config.get('repos', []))} repos")

        # Update config
        updated_config, changed = updater.update_config(config)
        print(f"After update: {len(updated_config.get('repos', []))} repos")
        print(f"Changed: {changed}")

        # Validate
        is_valid, error = updater.validate_config(updated_config)
        print(f"Valid: {is_valid}")
        if error:
            print(f"Error: {error}")

        # Write
        if is_valid:
            updater.write_config(updated_config)
            print(f"✓ Wrote config to {config_path}")


def example_cli_usage():
    """Example 6: CLI command examples."""
    print("\n" + "=" * 60)
    print("Example 6: CLI Usage")
    print("=" * 60)

    commands = [
        ("Basic usage (default paths)",
         "python update_precommit.py"),

        ("Dry run to preview",
         "python update_precommit.py --dry-run"),

        ("Custom paths",
         "python update_precommit.py --config /path/to/.pre-commit-config.yaml --test-dir .haunt/tests/patterns"),

        ("Update and install hooks",
         "python update_precommit.py --install"),

        ("Check if update needed",
         "python update_precommit.py --check-only"),
    ]

    print("\nCLI commands you can run:\n")
    for description, command in commands:
        print(f"  {description}:")
        print(f"    $ {command}\n")


def example_acceptance_tests():
    """Example 7: Acceptance tests from requirements."""
    print("\n" + "=" * 60)
    print("Example 7: Acceptance Tests")
    print("=" * 60)

    # Acceptance Test 1: Repo without pre-commit config
    print("\n1. Repository without pre-commit config")
    print("-" * 60)
    with tempfile.TemporaryDirectory() as tmpdir:
        repo_dir = Path(tmpdir)
        config_path = repo_dir / '.pre-commit-config.yaml'
        test_dir = repo_dir / 'tests'
        test_dir.mkdir()

        print(f"  Before: config exists = {config_path.exists()}")

        updater = PreCommitUpdater(config_path=config_path, test_dir=test_dir)
        success, changed = updater.update(dry_run=False, install=False)

        print(f"  After:  config exists = {config_path.exists()}")
        print(f"  Success: {success}")
        print(f"  Changed: {changed}")

        # Validate structure
        import yaml
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)

        has_local_repo = any(r.get('repo') == 'local' for r in config['repos'])
        has_pattern_hook = False
        if has_local_repo:
            for repo in config['repos']:
                if repo.get('repo') == 'local':
                    has_pattern_hook = any(h.get('id') == 'pattern-defeat-tests' for h in repo.get('hooks', []))

        print(f"  Has local repo: {has_local_repo}")
        print(f"  Has pattern hook: {has_pattern_hook}")
        print(f"  ✓ Test passed" if (success and has_local_repo and has_pattern_hook) else "  ✗ Test failed")

    # Acceptance Test 2: Repo with existing config
    print("\n2. Repository with existing config")
    print("-" * 60)
    with tempfile.TemporaryDirectory() as tmpdir:
        repo_dir = Path(tmpdir)
        config_path = repo_dir / '.pre-commit-config.yaml'
        test_dir = repo_dir / 'tests'
        test_dir.mkdir()

        # Create existing config with other hooks
        existing_config = {
            'repos': [
                {
                    'repo': 'https://github.com/psf/black',
                    'rev': '23.1.0',
                    'hooks': [{'id': 'black', 'name': 'black', 'entry': 'black', 'language': 'system'}]
                }
            ]
        }

        import yaml
        with open(config_path, 'w') as f:
            yaml.safe_dump(existing_config, f)

        print(f"  Before: 1 repo (black)")

        updater = PreCommitUpdater(config_path=config_path, test_dir=test_dir)
        success, changed = updater.update(dry_run=False, install=False)

        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)

        print(f"  After:  {len(config['repos'])} repos")
        print(f"  Success: {success}")
        print(f"  Changed: {changed}")

        # Verify black hook preserved
        black_preserved = any(r.get('repo') == 'https://github.com/psf/black' for r in config['repos'])

        # Verify pattern hook added
        pattern_added = False
        for repo in config['repos']:
            if repo.get('repo') == 'local':
                pattern_added = any(h.get('id') == 'pattern-defeat-tests' for h in repo.get('hooks', []))

        print(f"  Black hook preserved: {black_preserved}")
        print(f"  Pattern hook added: {pattern_added}")
        print(f"  ✓ Test passed" if (success and black_preserved and pattern_added) else "  ✗ Test failed")


def main():
    """Run all examples."""
    print("Pre-commit Configuration Update Examples")
    print("=" * 60)

    examples = [
        example_new_repository,
        example_existing_repository,
        example_idempotent_updates,
        example_dry_run,
        example_programmatic_usage,
        example_cli_usage,
        example_acceptance_tests,
    ]

    for example_func in examples:
        try:
            example_func()
        except Exception as e:
            print(f"\nError in {example_func.__name__}: {e}")
            import traceback
            traceback.print_exc()

    print("\n" + "=" * 60)
    print("Examples complete!")
    print("=" * 60)


if __name__ == '__main__':
    main()
