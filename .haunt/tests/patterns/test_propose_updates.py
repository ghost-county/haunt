#!/usr/bin/env python3
"""
Test suite for propose_updates.py module

Validates that proposal generation meets acceptance criteria:
- Proposals are agent-specific (dev vs researcher vs PM)
- Includes memory entry text ready to add
- Output is reviewable markdown format
"""

import json
import pytest
import sys
from pathlib import Path

# Add parent directory to path to import the module
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'Haunt' / 'scripts' / 'rituals' / 'pattern-detector'))

from propose_updates import ProposalGenerator, MOCK_PROPOSALS


def test_agent_classification():
    """Test that patterns are classified to the correct agent types."""
    generator = ProposalGenerator(mock=True)

    # Test code pattern -> Dev agent
    code_pattern = {
        'name': 'Silent Fallback',
        'description': 'Using .get() with default values without validation',
        'root_cause': 'Developers use .get() for convenience'
    }
    assert generator.classify_pattern_agent(code_pattern) == 'Dev'

    # Test documentation pattern -> Research agent
    doc_pattern = {
        'name': 'Missing Documentation',
        'description': 'Functions lack docstrings and inline comments',
        'root_cause': 'Documentation not prioritized in development'
    }
    assert generator.classify_pattern_agent(doc_pattern) == 'Research'

    # Test process pattern -> Project-Manager agent
    process_pattern = {
        'name': 'Poor Planning',
        'description': 'Features started without clear requirements in roadmap',
        'root_cause': 'Workflow lacks planning phase'
    }
    assert generator.classify_pattern_agent(process_pattern) == 'Project-Manager'


def test_proposal_structure():
    """Test that generated proposals have required fields."""
    generator = ProposalGenerator(mock=True)

    pattern = {
        'name': 'Silent Fallback Pattern',
        'description': 'Using .get() with defaults',
        'impact': 'high',
        'frequency': 'weekly',
        'root_cause': 'Convenience over correctness'
    }

    proposal = generator.generate_proposal(pattern, 'Dev')

    # Verify required fields exist
    assert 'non_negotiable' in proposal
    assert 'discipline' in proposal
    assert 'memory' in proposal
    assert 'memory_tags' in proposal

    # Verify structure of fields
    assert proposal['non_negotiable'].startswith('- [ ]')
    assert len(proposal['discipline']) > 0
    assert proposal['memory'].startswith('Learned:')
    assert isinstance(proposal['memory_tags'], list)
    assert 'anti-patterns' in proposal['memory_tags']


def test_silent_fallback_proposal_specifics():
    """
    Acceptance test: Given "silent fallback" pattern, proposes update to Dev agent.
    Proposal includes specific text to add to character sheet.
    """
    generator = ProposalGenerator(mock=True)

    pattern = {
        'name': 'Silent Fallback Pattern',
        'description': 'Using .get() with default values instead of explicit validation',
        'evidence': ['file1.py', 'file2.py'],
        'frequency': 'weekly',
        'impact': 'high',
        'root_cause': 'Convenience over correctness',
        'score': 9.0
    }

    # Classify agent
    agent = generator.classify_pattern_agent(pattern)
    assert agent == 'Dev', "Silent fallback pattern should map to Dev agent"

    # Generate proposal
    proposal = generator.generate_proposal(pattern, agent)

    # Verify proposal includes specific guidance
    assert 'get' in proposal['non_negotiable'].lower(), \
        "Non-negotiable should mention .get()"
    assert 'validation' in proposal['non_negotiable'].lower() or \
           'validation' in proposal['discipline'].lower(), \
        "Proposal should mention validation"
    assert 'silent' in proposal['memory'].lower() or \
           'fallback' in proposal['memory'].lower(), \
        "Memory should reference the pattern type"

    # Verify memory tags are appropriate
    assert 'defeat-test' in proposal['memory_tags'], \
        "Memory should be tagged with defeat-test"


def test_markdown_output_format():
    """Test that markdown output is properly formatted and reviewable."""
    generator = ProposalGenerator(mock=True)

    analysis = {
        'patterns': [
            {
                'name': 'Test Pattern',
                'description': 'Test description',
                'evidence': ['evidence1', 'evidence2'],
                'frequency': 'weekly',
                'impact': 'high',
                'root_cause': 'Test cause',
                'score': 9.0
            }
        ]
    }

    result = generator.generate_proposals(analysis)

    # Verify result structure
    assert 'markdown' in result
    assert 'proposals' in result
    assert 'timestamp' in result

    markdown = result['markdown']

    # Verify markdown formatting
    assert markdown.startswith('# Pattern Proposals')
    assert '## Pattern: Test Pattern' in markdown
    assert '### Proposed Update for Agent:' in markdown
    assert '#### Non-Negotiable Addition' in markdown
    assert '#### Discipline Item' in markdown
    assert '#### Memory Entry' in markdown
    assert '#### Related Defeat Test' in markdown
    assert '```json' in markdown
    assert 'test_no_' in markdown  # Defeat test name


def test_defeat_test_naming():
    """Test that defeat test names are generated correctly."""
    generator = ProposalGenerator(mock=True)

    test_cases = [
        ('Silent Fallback Pattern', 'test_no_silent_fallback_pattern.py'),
        ('Missing Error Context', 'test_no_missing_error_context.py'),
        ('Inconsistent-File-Path', 'test_no_inconsistentfilepath.py'),
    ]

    for pattern_name, expected_test_name in test_cases:
        pattern = {'name': pattern_name}
        test_name = generator.generate_defeat_test_name(pattern)
        assert test_name.startswith('test_no_')
        assert test_name.endswith('.py')
        assert ' ' not in test_name
        assert '-' not in test_name


def test_multiple_patterns_multiple_agents():
    """Test that proposals correctly handle multiple patterns for different agents."""
    generator = ProposalGenerator(mock=True)

    analysis = {
        'patterns': [
            {
                'name': 'Code Quality Issue',
                'description': 'Error handling missing',
                'evidence': ['file.py'],
                'frequency': 'weekly',
                'impact': 'high',
                'root_cause': 'Rushed implementation',
                'score': 9.0
            },
            {
                'name': 'Documentation Gap',
                'description': 'Missing API documentation',
                'evidence': ['docs/'],
                'frequency': 'monthly',
                'impact': 'medium',
                'root_cause': 'Documentation not prioritized',
                'score': 4.0
            }
        ]
    }

    result = generator.generate_proposals(analysis)

    # Verify we got proposals for both patterns
    assert len(result['proposals']) == 2

    # Verify proposals have agent assignments
    for proposal in result['proposals']:
        assert 'agent' in proposal
        assert proposal['agent'] in ['Dev', 'Research', 'Project-Manager', 'Code-Reviewer', 'Release-Manager']


def test_json_output_option():
    """Test that JSON output option works correctly."""
    generator = ProposalGenerator(mock=True)

    analysis = {
        'patterns': [
            {
                'name': 'Test Pattern',
                'description': 'Test',
                'evidence': ['test'],
                'frequency': 'weekly',
                'impact': 'high',
                'root_cause': 'Test',
                'score': 9.0
            }
        ]
    }

    result = generator.generate_proposals(analysis)

    # Verify JSON structure
    assert 'proposals' in result
    assert 'metadata' in result
    assert isinstance(result['proposals'], list)

    # Verify proposals can be serialized to JSON
    json_str = json.dumps(result, indent=2)
    assert len(json_str) > 0

    # Verify it can be deserialized
    parsed = json.loads(json_str)
    assert parsed['total_proposals'] == result['total_proposals']


if __name__ == '__main__':
    # Run tests if executed directly
    print("Running propose_updates tests...\n")

    test_functions = [
        test_agent_classification,
        test_proposal_structure,
        test_silent_fallback_proposal_specifics,
        test_markdown_output_format,
        test_defeat_test_naming,
        test_multiple_patterns_multiple_agents,
        test_json_output_option
    ]

    passed = 0
    failed = 0

    for test_func in test_functions:
        try:
            test_func()
            print(f"✓ {test_func.__name__}")
            passed += 1
        except AssertionError as e:
            print(f"✗ {test_func.__name__}: {e}")
            failed += 1
        except Exception as e:
            print(f"✗ {test_func.__name__}: Unexpected error: {e}")
            failed += 1

    print(f"\n{passed} passed, {failed} failed")
    sys.exit(0 if failed == 0 else 1)
