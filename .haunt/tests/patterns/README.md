# Pattern Defeat Tests

This directory contains tests that detect and prevent anti-patterns in agent behavior.

## Purpose

Pattern defeat tests are part of the "TDD for Agent Behavior" approach:

1. **Pattern Found** - Agent exhibits undesirable behavior
2. **Test Written** - Create a test that fails when pattern occurs
3. **Agent Trained** - Update agent prompt to avoid pattern
4. **Pattern Defeated** - Test passes, preventing regression

## Test Structure

Each test file should:

- Clearly identify the anti-pattern being prevented
- Provide examples of what triggers the test failure
- Document why this pattern is undesirable
- Link to the agent prompt section that prevents it

## Example Test

```python
# test_silent_fallback.py
"""
Pattern: Silent Fallback Anti-Pattern
Agent: Dev-Backend
Created: 2025-12-09
Reason: .get(key, default) hides missing required fields
"""

def test_no_silent_fallbacks_in_api():
    """Detect .get() with defaults on required fields."""
    # Test implementation
    pass
```

## For This Repository

Since this is a documentation repository, pattern tests might include:

- Detecting incomplete skill definitions (missing YAML frontmatter)
- Ensuring agent definitions have all required sections
- Verifying script files have proper error handling
- Checking that examples are complete and working

## Resources

- See `Agentic_SDLC_Framework/06-Patterns-and-Defeats.md` for methodology
- See `Skills/SDLC/pattern-defeat/SKILL.md` for pattern detection skill
