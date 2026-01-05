#!/usr/bin/env python3
"""
Acceptance Tests for update_memory.py

Tests the requirements:
1. Adds learning to correct agent's memory
2. Doesn't duplicate existing learnings
3. Works with or without MCP server running

Usage:
    pytest tests/patterns/test_update_memory.py -v
"""

import json
import shutil
import sys
from pathlib import Path
from datetime import datetime

import pytest

# Add pattern-detector to path
pattern_detector_path = Path(__file__).parent.parent.parent / 'Haunt' / 'scripts' / 'rituals' / 'pattern-detector'
sys.path.insert(0, str(pattern_detector_path))

from update_memory import MemoryUpdater


@pytest.fixture
def temp_memory_dir(tmp_path):
    """Create temporary memory directory."""
    memory_dir = tmp_path / 'agent-memory'
    memory_dir.mkdir()
    return memory_dir


@pytest.fixture
def memory_path(temp_memory_dir):
    """Create temporary memory file path."""
    return temp_memory_dir / 'memories.json'


@pytest.fixture
def sample_proposals():
    """Sample proposals from propose_updates.py."""
    return [
        {
            'agent': 'Dev',
            'pattern_name': 'Silent Fallback Pattern',
            'memory': 'Learned: Silent fallbacks hide bugs by masking missing data. Always validate required fields explicitly before use.',
            'memory_tags': ['anti-patterns', 'defeat-test', 'silent-fallback']
        },
        {
            'agent': 'Dev',
            'pattern_name': 'Missing Error Context',
            'memory': 'Learned: Generic error messages make debugging difficult. Include specific context about what failed and why.',
            'memory_tags': ['anti-patterns', 'defeat-test', 'error-context']
        }
    ]


@pytest.fixture
def existing_memories():
    """Sample existing memories."""
    return [
        {
            'id': 1,
            'content': 'Some existing learning',
            'category': 'general',
            'tags': ['test'],
            'metadata': {},
            'created_at': '2025-12-09T10:00:00',
            'updated_at': '2025-12-09T10:00:00'
        }
    ]


class TestMemoryUpdater:
    """Test MemoryUpdater class."""

    def test_initialization_default_path(self):
        """Test initialization with default memory path."""
        updater = MemoryUpdater()
        expected_path = Path.home() / '.agent-memory' / 'memories.json'
        assert updater.memory_path == expected_path
        assert not updater.use_mcp
        assert not updater.dry_run

    def test_initialization_custom_path(self, memory_path):
        """Test initialization with custom memory path."""
        updater = MemoryUpdater(memory_path=str(memory_path))
        assert updater.memory_path == memory_path

    def test_initialization_flags(self, memory_path):
        """Test initialization with various flags."""
        updater = MemoryUpdater(
            memory_path=str(memory_path),
            use_mcp=True,
            dry_run=True
        )
        assert updater.use_mcp
        assert updater.dry_run

    def test_generate_pattern_slug(self, memory_path):
        """Test pattern name to slug conversion."""
        updater = MemoryUpdater(memory_path=str(memory_path))

        assert updater._generate_pattern_slug('Silent Fallback Pattern') == 'silent_fallback_pattern'
        assert updater._generate_pattern_slug('Missing Error Context') == 'missing_error_context'
        assert updater._generate_pattern_slug('God Functions (>50 lines)') == 'god_functions_50_lines'
        assert updater._generate_pattern_slug('Multiple__Spaces___Here') == 'multiple_spaces_here'

    def test_load_existing_memories_empty(self, memory_path):
        """Test loading when memory file doesn't exist."""
        updater = MemoryUpdater(memory_path=str(memory_path))
        memories = updater._load_existing_memories()
        assert memories == []
        assert memory_path.exists()  # Should create empty file

    def test_load_existing_memories(self, memory_path, existing_memories):
        """Test loading existing memories."""
        memory_path.write_text(json.dumps(existing_memories))

        updater = MemoryUpdater(memory_path=str(memory_path))
        memories = updater._load_existing_memories()

        assert len(memories) == 1
        assert memories[0]['id'] == 1
        assert memories[0]['content'] == 'Some existing learning'

    def test_load_existing_memories_invalid_json(self, memory_path):
        """Test loading invalid JSON."""
        memory_path.write_text('not valid json')

        updater = MemoryUpdater(memory_path=str(memory_path))

        with pytest.raises(json.JSONDecodeError):
            updater._load_existing_memories()

    def test_check_duplicate_found(self, memory_path):
        """Test duplicate detection when entry exists."""
        memories = [
            {
                'id': 1,
                'content': 'Existing learning',
                'metadata': {
                    'pattern_id': 'silent_fallback_pattern'
                }
            }
        ]

        updater = MemoryUpdater(memory_path=str(memory_path))
        duplicate = updater._check_duplicate(memories, 'silent_fallback_pattern')

        assert duplicate is not None
        assert duplicate['id'] == 1

    def test_check_duplicate_not_found(self, memory_path):
        """Test duplicate detection when entry doesn't exist."""
        memories = [
            {
                'id': 1,
                'content': 'Existing learning',
                'metadata': {
                    'pattern_id': 'other_pattern'
                }
            }
        ]

        updater = MemoryUpdater(memory_path=str(memory_path))
        duplicate = updater._check_duplicate(memories, 'silent_fallback_pattern')

        assert duplicate is None

    def test_create_memory_entry(self, memory_path, sample_proposals):
        """Test creating a memory entry from proposal."""
        updater = MemoryUpdater(memory_path=str(memory_path))
        entry = updater._create_memory_entry(sample_proposals[0], next_id=42)

        assert entry['id'] == 42
        assert entry['content'] == sample_proposals[0]['memory']
        assert entry['category'] == 'anti-patterns'
        assert entry['tags'] == sample_proposals[0]['memory_tags']
        assert entry['metadata']['pattern_id'] == 'silent_fallback_pattern'
        assert entry['metadata']['defeat_test'] == 'test_silent_fallback_pattern.py'
        assert entry['metadata']['added_by'] == 'pattern-detector'
        assert entry['metadata']['agent'] == 'Dev'
        assert 'created_at' in entry
        assert 'updated_at' in entry


class TestAcceptanceCriteria:
    """Test acceptance criteria from requirements."""

    def test_acceptance_add_learning_appears_in_memories(
        self,
        memory_path,
        sample_proposals
    ):
        """
        Acceptance Test 1: Add learning, verify appears in memories.json

        This is the primary acceptance criterion.
        """
        # Initialize with empty memory
        updater = MemoryUpdater(memory_path=str(memory_path))

        # Add learnings
        result = updater.add_learnings([sample_proposals[0]])

        # Verify result
        assert len(result['added']) == 1
        assert result['added'][0]['pattern_name'] == 'Silent Fallback Pattern'
        assert len(result['skipped']) == 0
        assert len(result['errors']) == 0

        # Verify file was created and contains the learning
        assert memory_path.exists()
        memories = json.loads(memory_path.read_text())

        assert len(memories) == 1
        assert memories[0]['content'] == sample_proposals[0]['memory']
        assert memories[0]['category'] == 'anti-patterns'
        assert memories[0]['tags'] == sample_proposals[0]['memory_tags']
        assert memories[0]['metadata']['pattern_id'] == 'silent_fallback_pattern'
        assert memories[0]['metadata']['agent'] == 'Dev'

    def test_acceptance_duplicate_only_one_entry(
        self,
        memory_path,
        sample_proposals
    ):
        """
        Acceptance Test 2: Add same learning twice, only one entry exists

        This is the critical duplicate prevention test.
        """
        # Initialize updater
        updater = MemoryUpdater(memory_path=str(memory_path))

        # Add learning first time
        result1 = updater.add_learnings([sample_proposals[0]])
        assert len(result1['added']) == 1
        assert len(result1['skipped']) == 0

        # Add same learning second time
        result2 = updater.add_learnings([sample_proposals[0]])
        assert len(result2['added']) == 0
        assert len(result2['skipped']) == 1
        assert result2['skipped'][0]['pattern_name'] == 'Silent Fallback Pattern'
        assert result2['skipped'][0]['reason'] == 'Already exists in memory'

        # Verify only one entry exists in file
        memories = json.loads(memory_path.read_text())
        assert len(memories) == 1

    def test_works_without_mcp_server(self, memory_path, sample_proposals):
        """
        Test that it works in direct file mode (without MCP server).

        This is part of acceptance criterion 3.
        """
        # Initialize without MCP
        updater = MemoryUpdater(memory_path=str(memory_path), use_mcp=False)

        # Add learnings
        result = updater.add_learnings(sample_proposals)

        # Should succeed
        assert len(result['added']) == 2
        assert len(result['errors']) == 0

        # Verify file was written
        assert memory_path.exists()
        memories = json.loads(memory_path.read_text())
        assert len(memories) == 2

    def test_works_with_mcp_fallback(self, memory_path, sample_proposals):
        """
        Test that it falls back to direct mode when MCP isn't available.

        This is part of acceptance criterion 3.
        """
        # Initialize with MCP but it's not actually available
        updater = MemoryUpdater(memory_path=str(memory_path), use_mcp=True)

        # MCP should not be available in test environment
        assert not updater.mcp_available or updater.use_mcp

        # Add learnings - should fall back to direct mode
        result = updater.add_learnings(sample_proposals)

        # Should still succeed via fallback
        assert len(result['added']) == 2
        assert len(result['errors']) == 0

        # Verify file was written
        assert memory_path.exists()
        memories = json.loads(memory_path.read_text())
        assert len(memories) == 2


class TestEdgeCases:
    """Test edge cases and error handling."""

    def test_add_multiple_learnings(self, memory_path, sample_proposals):
        """Test adding multiple learnings at once."""
        updater = MemoryUpdater(memory_path=str(memory_path))
        result = updater.add_learnings(sample_proposals)

        assert len(result['added']) == 2
        assert len(result['errors']) == 0

        memories = json.loads(memory_path.read_text())
        assert len(memories) == 2
        assert memories[0]['id'] == 1
        assert memories[1]['id'] == 2

    def test_incremental_id_assignment(self, memory_path, existing_memories):
        """Test that IDs are assigned incrementally."""
        # Write existing memories
        memory_path.write_text(json.dumps(existing_memories))

        updater = MemoryUpdater(memory_path=str(memory_path))

        proposal = {
            'agent': 'Dev',
            'pattern_name': 'New Pattern',
            'memory': 'Learned: Something new',
            'memory_tags': ['anti-patterns']
        }

        result = updater.add_learnings([proposal])

        assert len(result['added']) == 1
        assert result['added'][0]['memory_id'] == 2  # Should be next ID after 1

        memories = json.loads(memory_path.read_text())
        assert len(memories) == 2
        assert memories[1]['id'] == 2

    def test_dry_run_mode(self, memory_path, sample_proposals):
        """Test that dry-run doesn't modify file."""
        updater = MemoryUpdater(memory_path=str(memory_path), dry_run=True)
        result = updater.add_learnings(sample_proposals)

        # Should report what would be added
        assert len(result['added']) == 2

        # But file should not be modified
        assert not memory_path.exists()

    def test_empty_proposals(self, memory_path):
        """Test handling empty proposals list."""
        updater = MemoryUpdater(memory_path=str(memory_path))
        result = updater.add_learnings([])

        assert result['total_proposals'] == 0
        assert len(result['added']) == 0
        assert len(result['skipped']) == 0

    def test_missing_fields_in_proposal(self, memory_path):
        """Test handling proposals with missing fields."""
        updater = MemoryUpdater(memory_path=str(memory_path))

        incomplete_proposal = {
            # Missing most fields
            'pattern_name': 'Test Pattern'
        }

        result = updater.add_learnings([incomplete_proposal])

        # Should still work with defaults
        assert len(result['added']) == 1

        memories = json.loads(memory_path.read_text())
        assert len(memories) == 1
        assert 'Learned: Test Pattern' in memories[0]['content']

    def test_preserves_existing_memories(self, memory_path, existing_memories, sample_proposals):
        """Test that existing memories are preserved when adding new ones."""
        # Write existing memories
        memory_path.write_text(json.dumps(existing_memories))

        updater = MemoryUpdater(memory_path=str(memory_path))
        result = updater.add_learnings([sample_proposals[0]])

        assert len(result['added']) == 1

        # Load and verify both old and new are present
        memories = json.loads(memory_path.read_text())
        assert len(memories) == 2
        assert memories[0]['content'] == 'Some existing learning'
        assert memories[1]['content'] == sample_proposals[0]['memory']

    def test_unicode_in_content(self, memory_path):
        """Test handling Unicode characters in memory content."""
        updater = MemoryUpdater(memory_path=str(memory_path))

        proposal = {
            'agent': 'Dev',
            'pattern_name': 'Unicode Test',
            'memory': 'Learned: Use proper encoding → UTF-8 for safety ✓',
            'memory_tags': ['unicode', 'encoding']
        }

        result = updater.add_learnings([proposal])
        assert len(result['added']) == 1

        # Verify Unicode is preserved
        memories = json.loads(memory_path.read_text())
        assert '→' in memories[0]['content']
        assert '✓' in memories[0]['content']


class TestCLI:
    """Test CLI interface."""

    def test_cli_help(self):
        """Test that CLI help works."""
        import subprocess

        result = subprocess.run(
            [sys.executable, str(pattern_detector_path / 'update_memory.py'), '--help'],
            capture_output=True,
            text=True
        )

        assert result.returncode == 0
        assert 'Add pattern learnings to agent memory' in result.stdout

    def test_cli_with_file_input(self, memory_path, sample_proposals, tmp_path):
        """Test CLI with file input."""
        import subprocess

        # Create input file
        input_file = tmp_path / 'proposals.json'
        input_data = {'proposals': sample_proposals}
        input_file.write_text(json.dumps(input_data))

        # Run CLI
        result = subprocess.run(
            [
                sys.executable,
                str(pattern_detector_path / 'update_memory.py'),
                '--input', str(input_file),
                '--memory-path', str(memory_path)
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode == 0
        assert 'Added: Silent Fallback Pattern' in result.stderr
        assert 'Added: Missing Error Context' in result.stderr

        # Verify file was written
        assert memory_path.exists()
        memories = json.loads(memory_path.read_text())
        assert len(memories) == 2

    def test_cli_dry_run(self, memory_path, sample_proposals, tmp_path):
        """Test CLI with --dry-run flag."""
        import subprocess

        # Create input file
        input_file = tmp_path / 'proposals.json'
        input_data = {'proposals': sample_proposals}
        input_file.write_text(json.dumps(input_data))

        # Run CLI with dry-run
        result = subprocess.run(
            [
                sys.executable,
                str(pattern_detector_path / 'update_memory.py'),
                '--input', str(input_file),
                '--memory-path', str(memory_path),
                '--dry-run'
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode == 0
        assert '[DRY RUN]' in result.stderr

        # Verify file was NOT written
        assert not memory_path.exists()


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
