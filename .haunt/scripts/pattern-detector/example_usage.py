#!/usr/bin/env python3
"""
Example Usage of Pattern Detection System

Demonstrates how to use the pattern detection system programmatically.
"""

import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from collect import collect_all_signals
from analyze import PatternAnalyzer


def main():
    """Example: Collect signals and analyze patterns."""

    print("=== Pattern Detection Example ===\n")

    # Step 1: Collect signals from repository
    print("Step 1: Collecting signals...")
    signals = collect_all_signals(
        repo_path='../../..',  # Root of Claude repository
        days=30,
        top_n_hot_files=10
    )

    print(f"  Found {signals['summary']['total_signals']} total signals")
    print(f"    - {signals['summary']['fix_commits']} fix commits")
    print(f"    - {signals['summary']['repeated_modifications']} repeated modifications")
    print(f"    - {signals['summary']['hot_files']} hot files")
    print(f"    - {signals['summary']['repeated_learnings']} repeated learnings\n")

    # Step 2: Analyze patterns using Claude (mock mode for example)
    print("Step 2: Analyzing patterns...")
    analyzer = PatternAnalyzer(mock=True)  # Use mock=False for real API calls
    results = analyzer.analyze(signals)

    print(f"  Found {results['metadata']['total_patterns_found']} patterns\n")

    # Step 3: Display results
    print("Step 3: Top Patterns Found:")
    print("-" * 80)

    for i, pattern in enumerate(results['patterns'][:5], 1):
        print(f"\n{i}. {pattern['name']}")
        print(f"   Impact: {pattern['impact'].upper()} | Frequency: {pattern['frequency']}")
        print(f"   Score: {pattern['score']:.1f}")
        print(f"\n   Description:")
        print(f"   {pattern['description']}")
        print(f"\n   Evidence:")
        for evidence_item in pattern['evidence'][:3]:
            print(f"   - {evidence_item}")
        print(f"\n   Root Cause:")
        print(f"   {pattern['root_cause']}")
        print("-" * 80)

    print(f"\n=== Example Complete ===")
    print(f"\nTo use with real Claude API:")
    print("  1. Set ANTHROPIC_API_KEY environment variable")
    print("  2. Change mock=True to mock=False")
    print("  3. Run: python example_usage.py")


if __name__ == '__main__':
    main()
