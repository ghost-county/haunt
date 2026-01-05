# End-to-End Tests

This directory contains end-to-end workflow tests for complete agent team operations.

## Purpose

E2E tests verify that entire workflows complete successfully from start to finish:

- Feature request → Planning → Implementation → Review → Merge
- Multi-agent coordination scenarios
- Cross-system integration tests
- Full session workflows

## Test Structure

E2E tests typically:

1. Set up initial state
2. Execute a complete workflow
3. Verify final state matches expectations
4. Clean up test artifacts

## Example E2E Test

```python
# test_feature_completion_workflow.py
"""
E2E Test: Feature Completion Workflow

Scenario:
1. Human provides feature request
2. Project-Manager creates roadmap entry
3. Dev agent implements feature
4. Code-Reviewer reviews changes
5. Release-Manager merges to main
6. Work is archived

Verifies: Complete feature lifecycle
"""

def test_complete_feature_workflow():
    """Test full feature implementation lifecycle."""
    # Test implementation
    pass
```

## For This Repository

Since this is a **documentation repository** (not an application with UI), E2E tests might verify:

### Documentation Workflows

```python
def test_complete_skill_creation_workflow():
    """
    Workflow:
    1. Request new skill
    2. Create skill with YAML frontmatter
    3. Add references/
    4. Update CLAUDE.md if needed
    5. Commit with standard format
    """
    pass

def test_framework_update_workflow():
    """
    Workflow:
    1. Update framework documentation
    2. Update corresponding scripts
    3. Verify examples still work
    4. Update changelog
    """
    pass
```

### Agent Coordination Tests

```python
def test_multi_agent_documentation_update():
    """
    Test coordination between:
    - Project-Manager (coordinates)
    - Doc-Editor (updates docs)
    - Content-Reviewer (reviews)
    - Release-Manager (merges)
    """
    pass
```

## Playwright Integration

For repositories with web UIs, this directory would contain Playwright browser automation tests. For this documentation repository, Playwright is not needed unless we build a documentation website.

## Resources

- See `Agentic_SDLC_Framework/06-Patterns-and-Defeats.md` for testing methodology
- See `Agentic_SDLC_Framework/01-Prerequisites.md` for Playwright setup (if needed)
