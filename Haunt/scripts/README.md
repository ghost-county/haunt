# Haunt Scripts Directory

Automation scripts for the Haunt v2.0 setup and operations.

## Directory Structure

```
scripts/
├── setup-haunt.sh      # Main setup script (run from project root)
├── README.md                   # This file
├── README-MIGRATION.md         # Migration guide from v1.0
│
├── rituals/                    # Daily and weekly operational scripts
│   ├── morning-review.sh       # Daily morning ritual
│   ├── evening-handoff.sh      # Daily evening ritual
│   ├── weekly-refactor.sh      # Weekly maintenance ritual
│   ├── hunt-patterns           # Pattern detection CLI wrapper
│   ├── pattern-hunt-weekly.sh  # Weekly pattern hunting workflow
│   └── pattern-detector/       # Python pattern detection module
│       ├── cli.py              # Main CLI entry point
│       ├── collect.py          # Signal collection
│       ├── analyze.py          # Pattern analysis
│       ├── generate_tests.py   # Defeat test generation
│       └── ...
│
├── validation/                 # Setup and content validation
│   ├── validate-agents.sh      # Agent format validation
│   ├── validate-skills.sh      # Skill frontmatter validation
│   ├── validate-agent-skills.sh # Agent-skill reference validation
│   ├── validate-installed-skills.sh # Installed skills validation
│   └── verify-precommit-setup.sh # Pre-commit hook verification
│
└── utils/                      # Utility scripts
    ├── agent-memory-server.py  # MCP memory server
    ├── post-setup-message.sh   # Post-setup guidance display
    ├── migrate-to-sdlc.sh      # Migration helper
    └── setup-precommit-hooks-addon.sh # Pre-commit hooks setup
```

## Quick Start

### Remote Installation (Recommended)

Install directly from GitHub without cloning the repository:

```bash
# Quick install (clones repo temporarily, keeps it for reference)
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash

# Install and cleanup (removes cloned repo after setup)
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --cleanup

# Install with options
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --scope=project --cleanup
```

### Local Installation

If you've already cloned the repository:

```bash
# Full setup (from project root)
bash /Users/heckatron/github_repos/ghost-county/Haunt/scripts/setup-haunt.sh

# Preview changes
bash /Users/heckatron/github_repos/ghost-county/Haunt/scripts/setup-haunt.sh --dry-run

# Verify setup
bash /Users/heckatron/github_repos/ghost-county/Haunt/scripts/setup-haunt.sh --verify
```

## Main Setup Script

### setup-haunt.sh

The primary script for setting up the Haunt environment.

**Common Options:**
```bash
--help              # Show comprehensive help
--dry-run           # Preview without making changes
--scope=<value>     # global (default), project, or both
--agents-only       # Only setup agent character sheets
--verify            # Verify existing setup
--fix               # Fix issues during verification
```

**Example Workflows:**
```bash
# First-time setup
bash scripts/setup-haunt.sh

# Update agents after git pull
bash scripts/setup-haunt.sh --agents-only

# Setup for current project only
bash scripts/setup-haunt.sh --scope=project

# Verify and fix issues
bash scripts/setup-haunt.sh --verify --fix
```

## Ritual Scripts

Located in `scripts/rituals/`. These are copied to `.haunt/scripts/` during setup.

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `morning-review.sh` | Start-of-day context loading | Daily, start of work |
| `evening-handoff.sh` | End-of-day documentation | Daily, end of work |
| `weekly-refactor.sh` | Maintenance and cleanup | Weekly (Fridays) |
| `hunt-patterns` | Interactive pattern detection | As needed |

**Usage (after setup):**
```bash
bash .haunt/scripts/morning-review.sh
bash .haunt/scripts/evening-handoff.sh
bash .haunt/scripts/weekly-refactor.sh
bash .haunt/scripts/hunt-patterns hunt
```

## Validation Scripts

Located in `scripts/validation/`. Used by setup script and for CI/CD.

| Script | Purpose |
|--------|---------|
| `validate-agents.sh` | Check agent format (<= 100 lines, required sections) |
| `validate-skills.sh` | Check skill YAML frontmatter |
| `validate-agent-skills.sh` | Verify agent-skill references exist |
| `validate-installed-skills.sh` | Check installed skills are valid |
| `validate-plan-sizes.sh` | Check plan files don't exceed 1000 lines |
| `verify-precommit-setup.sh` | Verify pre-commit hooks |

**Usage:**
```bash
bash scripts/validation/validate-agents.sh
bash scripts/validation/validate-skills.sh
```

## Utility Scripts

Located in `scripts/utils/`. Supporting utilities.

| Script | Purpose |
|--------|---------|
| `agent-memory-server.py` | MCP server for agent memory (reference implementation) |
| `post-setup-message.sh` | Display post-setup guidance |
| `migrate-to-sdlc.sh` | Migrate existing projects to SDLC |
| `setup-precommit-hooks-addon.sh` | Add pre-commit hooks |

### Agent Memory Server

The `agent-memory-server.py` is a **reference implementation** demonstrating the 5-layer memory hierarchy concept. It is suitable for learning and simple projects, but has limitations:

**Limitations:**
- No semantic search (exact text matching only)
- No embeddings support
- Simple consolidation only (no sophisticated RAG)
- Single-user design (no multi-tenancy)

**For production use** with advanced features like semantic search, embeddings, and team collaboration, see:
- **Documentation:** `.haunt/docs/research/agent-memory-mcp-research.md`
- **Alternatives:** MCP Memory Keeper, MCP Memory Service, Memento MCP

**Usage:**
```bash
# Start the reference server
python ~/.claude/mcp-servers/agent-memory-server.py
```

## Related Documentation

- [SETUP-GUIDE.md](../SETUP-GUIDE.md) - Complete setup instructions
- [QUICK-REFERENCE.md](../QUICK-REFERENCE.md) - Quick reference card
- [README.md](../README.md) - Architecture overview
- [README-MIGRATION.md](README-MIGRATION.md) - Migration guide
