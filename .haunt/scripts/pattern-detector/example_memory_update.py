#!/usr/bin/env python3
"""
Example: Agent Memory Auto-Update Workflow

Demonstrates how to use update_memory.py to automatically add pattern learnings
to agent memory.

Usage:
    python3 example_memory_update.py
"""

import json
import sys
from pathlib import Path

# Add pattern-detector to path
sys.path.insert(0, str(Path(__file__).parent))

from update_memory import MemoryUpdater


def example_basic_usage():
    """Example 1: Basic usage with sample proposals."""
    print("=== Example 1: Basic Usage ===\n")

    # Sample proposals from propose_updates.py
    proposals = [
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

    # Use temporary memory file for demo
    temp_memory = Path('/tmp/example-memories.json')

    # Initialize updater
    updater = MemoryUpdater(memory_path=str(temp_memory))

    # Add learnings
    print("Adding 2 pattern learnings...\n")
    result = updater.add_learnings(proposals)

    # Print summary
    updater.print_summary(result)

    # Show what was written
    print(f"\nMemory file created at: {temp_memory}")
    print(f"File size: {temp_memory.stat().st_size} bytes")
    print(f"\nFirst entry content:")
    memories = json.loads(temp_memory.read_text())
    print(json.dumps(memories[0], indent=2))

    # Cleanup
    temp_memory.unlink()
    print("\n(Temporary file cleaned up)")


def example_duplicate_prevention():
    """Example 2: Duplicate prevention."""
    print("\n\n=== Example 2: Duplicate Prevention ===\n")

    proposal = {
        'agent': 'Dev',
        'pattern_name': 'Test Pattern',
        'memory': 'Learned: This is a test pattern',
        'memory_tags': ['test']
    }

    temp_memory = Path('/tmp/example-memories-2.json')
    updater = MemoryUpdater(memory_path=str(temp_memory))

    # Add first time
    print("First addition:")
    result1 = updater.add_learnings([proposal])
    print(f"  Added: {len(result1['added'])}, Skipped: {len(result1['skipped'])}")

    # Add second time (should be skipped)
    print("\nSecond addition (duplicate):")
    result2 = updater.add_learnings([proposal])
    print(f"  Added: {len(result2['added'])}, Skipped: {len(result2['skipped'])}")

    if result2['skipped']:
        print(f"  Reason: {result2['skipped'][0]['reason']}")

    # Cleanup
    temp_memory.unlink()
    print("\n(Temporary file cleaned up)")


def example_dry_run():
    """Example 3: Dry run mode."""
    print("\n\n=== Example 3: Dry Run Mode ===\n")

    proposal = {
        'agent': 'Dev',
        'pattern_name': 'Dry Run Test',
        'memory': 'Learned: This should not be saved',
        'memory_tags': ['test']
    }

    temp_memory = Path('/tmp/example-memories-3.json')

    # Dry run mode
    updater = MemoryUpdater(memory_path=str(temp_memory), dry_run=True)

    print("Running in dry-run mode...")
    result = updater.add_learnings([proposal])

    print(f"\nResult: {len(result['added'])} would be added")
    print(f"File exists: {temp_memory.exists()}")
    print("(No file was created because of --dry-run)")


def example_from_json_file():
    """Example 4: Reading from JSON file."""
    print("\n\n=== Example 4: Reading from JSON File ===\n")

    # Create sample JSON file
    input_file = Path('/tmp/example-proposals.json')
    data = {
        'timestamp': '2025-12-10T14:00:00',
        'total_proposals': 2,
        'proposals': [
            {
                'agent': 'Dev',
                'pattern_name': 'From File Pattern',
                'memory': 'Learned: Reading proposals from JSON files',
                'memory_tags': ['example', 'json-file']
            }
        ]
    }
    input_file.write_text(json.dumps(data, indent=2))

    temp_memory = Path('/tmp/example-memories-4.json')
    updater = MemoryUpdater(memory_path=str(temp_memory))

    print(f"Reading proposals from: {input_file}")

    # Read from file
    with open(input_file, 'r') as f:
        proposals_data = json.load(f)

    proposals = proposals_data.get('proposals', [])
    print(f"Found {len(proposals)} proposals\n")

    # Add learnings
    result = updater.add_learnings(proposals)
    updater.print_summary(result)

    # Cleanup
    input_file.unlink()
    temp_memory.unlink()
    print("\n(Temporary files cleaned up)")


def example_error_handling():
    """Example 5: Error handling."""
    print("\n\n=== Example 5: Error Handling ===\n")

    temp_memory = Path('/tmp/example-memories-5.json')

    # Create invalid JSON file
    temp_memory.write_text('{ invalid json }')

    updater = MemoryUpdater(memory_path=str(temp_memory))

    print("Attempting to load invalid JSON file...")
    try:
        memories = updater._load_existing_memories()
        print("ERROR: Should have raised JSONDecodeError")
    except json.JSONDecodeError as e:
        print(f"✓ Correctly caught error: {type(e).__name__}")
        print(f"  Message: Invalid JSON in memory file")

    # Cleanup
    temp_memory.unlink()
    print("\n(Temporary file cleaned up)")


def main():
    """Run all examples."""
    print("Agent Memory Auto-Update Examples")
    print("=" * 60)

    try:
        example_basic_usage()
        example_duplicate_prevention()
        example_dry_run()
        example_from_json_file()
        example_error_handling()

        print("\n" + "=" * 60)
        print("All examples completed successfully!")
        print("\nFor production use:")
        print("  python3 update_memory.py --input proposals.json")
        print("  python3 update_memory.py --input proposals.json --dry-run")

    except Exception as e:
        print(f"\nError running examples: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
