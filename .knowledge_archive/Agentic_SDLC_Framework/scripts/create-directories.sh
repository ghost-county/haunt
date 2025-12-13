#!/bin/bash
# scripts/create-directories.sh
# Create the required directory structure for Agentic SDLC

echo "=== Creating Agentic SDLC Directory Structure ==="

# Agent directories
mkdir -p .claude/agents
mkdir -p .claude/commands

# Planning directories
mkdir -p plans
mkdir -p completed
mkdir -p progress

# Test directories
mkdir -p tests/patterns
mkdir -p tests/behavior
mkdir -p tests/e2e

# Scripts directory
mkdir -p scripts

# Memory directory (global)
mkdir -p ~/.agent-memory

echo "✓ Created .claude/agents/"
echo "✓ Created .claude/commands/"
echo "✓ Created plans/"
echo "✓ Created completed/"
echo "✓ Created progress/"
echo "✓ Created tests/patterns/"
echo "✓ Created tests/behavior/"
echo "✓ Created tests/e2e/"
echo "✓ Created scripts/"
echo "✓ Created ~/.agent-memory/"

echo ""
echo "=== Directory structure created! ==="
