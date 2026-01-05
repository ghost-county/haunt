# Haunt

**Haunt** is a lightweight framework that transforms Claude Code's subagents into coordinated development teams through external memory patterns, structured workflows, and enforced invariants. By combining project management (roadmap-driven development), external memory (rules, skills, agents), and cognitive architecture (layered context management), Haunt enables developers to collaborate with AI agents that maintain context across sessions, follow consistent methodologies, and produce production-quality software.

## Quick Install

Run directly from the internet - no manual cloning required:

```bash

# 1. Find your Project Directory
cd ~/github_repos/my_directory

# 2. Install Haunt globally and cleanup source files (removes cloned repo after setup)
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --scope=global --cleanup --clean --quiet

# 3. Open Claude Code terminal with Bypass Permissions On
claude --dangerously-skip-permissions

# 4. Start the Haunt Project Requirements Planning, Scoping, and Development workflow with the /seance command
/seance 
```

### Installation Options

```bash
# Install globally (recommended - works in any project)
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --scope=global --cleanup --clean --quiet

# Install to current project only
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --scope=project --cleanup

# Verify existing installation
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --verify

# Install (clones repo temporarily, keeps it for reference)
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash

# Preview what would be installed (dry run)
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --dry-run

# Alternative: Use GitHub API to bypass CDN cache (if you need latest immediately)
curl -fsSL -H "Accept: application/vnd.github.v3.raw" \
  "https://api.github.com/repos/ghost-county/ghost-county/contents/Haunt/scripts/setup-haunt.sh" | bash
```

### Quick Uninstall

**Via Claude Code (recommended):**

```bash
/cleanse              # Interactive mode - guides you through removal
/cleanse --global     # Remove global ~/.claude artifacts only
/cleanse --project    # Remove project .claude/ and .haunt/ artifacts only
/cleanse --full       # Remove global AND project artifacts
/cleanse --backup     # Create backup before deletion
```

**Manual removal:**

```bash
# Remove project-level Haunt (run from your project directory)
rm -rf .claude .haunt

# Remove global Haunt artifacts
rm -rf ~/.claude/agents/gco-* ~/.claude/skills/gco-* ~/.claude/rules/gco-* ~/.claude/commands/gco-*
```

## What Gets Installed

| Component | Location | Description |
|-----------|----------|-------------|
| Agent Character Sheets | `~/.claude/agents/` | AI agent definitions (Project-Manager, Dev-Backend, etc.) |
| Haunt Skills | `~/.claude/skills/` | Methodology skills (TDD, code review, requirements, etc.) |
| Project Structure | `.haunt/` | Plans, progress tracking, tests (in your project) |
| Ritual Scripts | `.haunt/scripts/` | Daily/weekly operational workflows |

## What is Haunt?

Haunt is a framework that transforms Claude Code's subagents into coordinated development teams through external memory patterns, structured workflows, and enforced invariants. It provides:

- **Agent Character Sheets** - Lightweight definitions (30-100 lines) that give agents specific roles and responsibilities
- **Skills** - Reusable knowledge modules that agents invoke for specific tasks
- **Roadmap-Driven Development** - A single source of truth for all active work
- **Pattern Detection** - Automated identification and fixing of recurring issues

### Core Principles

1. **One-Feature-Per-Session** - Complete one feature/fix per session before starting another
2. **Feature Contract Immutability** - Acceptance criteria cannot be modified mid-implementation
3. **Tests Before Code** - Pattern Found → Test Written → Agent Trained → Pattern Defeated
4. **Atomic Requirements** - All work items sized S (1-4 hours) or M (4-8 hours) only

## Agent Types

| Type | Agents | Purpose |
|------|--------|---------|
| Coordinator | Project-Manager | Roadmap, prioritization, dispatch |
| Worker | Dev-Backend, Dev-Frontend, Dev-Infrastructure | Feature implementation |
| Researcher | Research-Analyst, Research-Critic | Investigation, validation |
| Quality | Code-Reviewer, Release-Manager | Code review, merge coordination |

## Usage

After installation, use agents with Claude Code:

```bash
# Start Claude with a specific agent
claude -a Project-Manager

# Or invoke agents within a session
# "Use the Dev-Backend agent to implement this feature"
```

## Starting a New Project

After running setup in a new project directory, kick off the Haunt workflow:

```bash
# 1. Navigate to your new project
cd /path/to/your/project
git init  # if not already a git repo

# 2. Run the Haunt setup
curl -fsSL https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.sh | bash -s -- --cleanup

# 3. Start Claude 
claude 
```

Then tell the Project Manager what you want to build, using the Seance slash-command:

```
You: "/seance I want to build a task management API with user authentication,
     CRUD operations for tasks, and a simple React frontend."
```

The Project Manager will:
1. Confirm understanding of your requirements
2. Run the idea-to-roadmap workflow (requirements → analysis → roadmap)
3. Break down your idea into sized requirements (S/M)
4. Populate `.haunt/plans/roadmap.md` with actionable items
5. Assign work to appropriate agents (Dev-Backend, Dev-Frontend, etc.)
6. Summon an agen swarm to work all open requirements or issues

**Quick Start Commands:**

| What you want | What to say |
|---------------|-------------|
| Start a new project | "I want to build [description]" |
| Report a bug | "There's a bug where [description]" |
| Add a feature | "We need to add [feature]" |
| Check status | "What's on the roadmap?" |
| Start work | "What should I work on next?" |

## Repository Structure

```
ghost-county/
├── Haunt/                    # v2.0 Framework (recommended)
│   ├── agents/               # Agent character sheets
│   ├── skills/               # Haunt methodology skills
│   ├── scripts/              # Setup and automation
│   ├── docs/                 # Detailed documentation
│   │   ├── WHITE-PAPER.md              # Framework design philosophy
│   │   ├── SDK-INTEGRATION.md          # SDK integration details
│   │   ├── TOOL-PERMISSIONS.md         # Agent tool access
│   │   ├── SKILLS-REFERENCE.md         # Skills catalog
│   │   ├── PATTERN-DETECTION.md        # Pattern detection methodology
│   │   └── HAUNT-DIRECTORY-SPEC.md     # Directory structure
│   ├── README.md             # Architecture overview
│   ├── SETUP-GUIDE.md        # Detailed setup instructions
│   └── QUICK-REFERENCE.md    # Quick reference card
├── Skills/                   # Domain-specific skills (optional)
├── Knowledge/                # Educational materials
└── Agentic_SDLC_Framework/   # v1.0 Legacy framework
```

## Documentation

**Getting Started:**
- [Setup Guide](Haunt/SETUP-GUIDE.md) - Complete setup instructions
- [Quick Reference](Haunt/QUICK-REFERENCE.md) - Command cheat sheet
- [Architecture Overview](Haunt/README.md) - How agents and skills work together

**Deep Dive:**
- [White Paper](Haunt/docs/WHITE-PAPER.md) - **Start here** - Comprehensive overview of Haunt's design and philosophy
- [SDK Integration](Haunt/docs/SDK-INTEGRATION.md) - SDK integration details
- [Tool Permissions](Haunt/docs/TOOL-PERMISSIONS.md) - Agent tool access reference
- [Skills Reference](Haunt/docs/SKILLS-REFERENCE.md) - Complete skills catalog
- [Pattern Detection](Haunt/docs/PATTERN-DETECTION.md) - Pattern detection methodology
- [Directory Specification](Haunt/docs/HAUNT-DIRECTORY-SPEC.md) - Directory structure

**Scripts:**
- [Scripts Reference](Haunt/scripts/README.md) - All available scripts

## Local Development

If you've cloned this repository:

```bash
# Full setup
bash Haunt/scripts/setup-haunt.sh

# Preview changes
bash Haunt/scripts/setup-haunt.sh --dry-run

# Verify installation
bash Haunt/scripts/setup-haunt.sh --verify

# Update agents only
bash Haunt/scripts/setup-haunt.sh --agents-only
```

## Requirements

- **Claude Code CLI** - The Claude Code command-line interface
- **Git** - Required for remote installation
- **Bash** - Unix shell (macOS, Linux, WSL)

## License

MIT
