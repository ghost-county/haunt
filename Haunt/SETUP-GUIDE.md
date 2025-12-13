# Haunt v2.0 - Comprehensive Setup Guide

> Complete setup instructions for Haunt v2.0 environment

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Verification](#verification)
5. [Common Setup Scenarios](#common-setup-scenarios)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Configuration](#advanced-configuration)
8. [Next Steps](#next-steps)

---

## Quick Start

**For impatient users: Complete setup in 3 commands**

```bash
# 1. Navigate to repository
cd /path/to/Claude

# 2. Run setup script
bash Haunt/scripts/setup-haunt.sh

# 3. Verify installation
bash Haunt/scripts/setup-haunt.sh --verify
```

**First command to try:**
```bash
# Start a development session with the dev agent
claude -a dev
```

---

## Prerequisites

### Required Dependencies

#### 1. Git (version control)
**Purpose:** Version control for code and agent definitions

```bash
# Check if installed
git --version

# Install on macOS
brew install git

# Install on Ubuntu/Debian
sudo apt-get install git

# Install on CentOS/RHEL
sudo yum install git
```

**Configure Git:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### 2. Python 3.11+ (for MCP servers)
**Purpose:** Required for Agent Memory and Context7 MCP servers

```bash
# Check version
python3 --version

# Install on macOS
brew install python@3.11

# Install on Ubuntu/Debian
sudo apt-get install python3.11 python3.11-venv

# Install on CentOS/RHEL
sudo yum install python311
```

#### 3. Node.js 18+ (for Claude Code CLI)
**Purpose:** Claude Code CLI and npm package management

```bash
# Check version
node --version

# Install on macOS
brew install node

# Install on Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install with nvm (recommended for version management)
nvm install 18
nvm use 18
```

#### 4. Claude Code CLI
**Purpose:** Core interface for interacting with Claude agents

```bash
# Install globally
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version

# See available agents
claude --list-agents
```

### Optional Dependencies

#### 5. uv Package Manager (recommended)
**Purpose:** Fast Python package and MCP server management

```bash
# Install
curl -LsSf https://astral.sh/uv/install.sh | sh

# Verify installation
uv --version
```

**Why uv?**
- 10-100x faster than pip
- Built-in virtual environment management
- Simplifies MCP server installation
- Required for `uvx` commands in documentation

#### 6. NATS JetStream (for agent coordination)
**Purpose:** Message queue for multi-agent coordination

```bash
# Install on macOS
brew install nats-server

# Install on Ubuntu/Debian
# See: https://docs.nats.io/running-a-nats-service/introduction/installation

# Start NATS server
nats-server -js

# Verify
nats-server --version
```

#### 7. Playwright (for E2E testing)
**Purpose:** Browser automation for end-to-end tests

```bash
# Install via npm
npm install -D @playwright/test

# Install browsers
npx playwright install
```

---

## Installation

### Scenario 1: First-Time Setup (New User)

**Goal:** Install Haunt v2.0 from scratch

**Steps:**
```bash
# 1. Clone or navigate to repository
cd /path/to/Claude

# 2. Run full setup
bash Haunt/scripts/setup-haunt.sh

# 3. Verify installation
bash Haunt/scripts/setup-haunt.sh --verify

# 4. Review installed agents
ls -la ~/.claude/agents/

# 5. Review available skills
ls -1 Haunt/skills/

# 6. Start your first session
claude -a dev
```

**What gets installed:**
- Global agent character sheets → `~/.claude/agents/`
  - gco-dev.md
  - gco-project-manager.md
  - gco-research.md
  - gco-code-reviewer.md
  - gco-release-manager.md
- Haunt skills verified in `Haunt/skills/`
- Directory structure created: `.haunt/plans/`, `.haunt/progress/`, `.haunt/completed/`, `.haunt/tests/`, `.claude/`

### Scenario 2: Updating Agents After Git Pull

**Goal:** Update global agents after pulling new agent definitions

**Steps:**
```bash
# 1. Pull latest changes
git pull origin master

# 2. Update agents only (skip project setup)
bash Haunt/scripts/setup-haunt.sh --agents-only

# 3. Verify update
bash Haunt/scripts/setup-haunt.sh --verify

# 4. Check agent versions/changes
diff ~/.claude/agents/gco-dev.md Haunt/agents/gco-dev.md
```

### Scenario 3: Adding to Existing Project

**Goal:** Add Haunt to an existing codebase

**Steps:**
```bash
# 1. Navigate to your project
cd /path/to/your-project

# 2. Run project-only setup (skip global agents)
bash /path/to/ghost-county/Haunt/scripts/setup-haunt.sh --project-only

# 3. (Optional) Create project-specific agent overrides
mkdir -p .claude/agents

# 4. (Optional) Copy and customize agents
cp /path/to/ghost-county/Haunt/agents/gco-dev.md .claude/agents/gco-dev.md
# Edit .claude/agents/gco-dev.md for project-specific customization

# 5. Start session
claude -a dev
```

**Project-specific vs Global Agents:**
- Global: `~/.claude/agents/*.md` (apply to all projects)
- Project: `./.claude/agents/*.md` (override global for this project only)

### Scenario 4: Dry Run (Preview Changes)

**Goal:** See what setup would do without making changes

**Steps:**
```bash
# Preview full setup
bash Haunt/scripts/setup-haunt.sh --dry-run

# Preview agents-only update
bash Haunt/scripts/setup-haunt.sh --agents-only --dry-run

# Preview with verbose output
bash Haunt/scripts/setup-haunt.sh --dry-run --verbose
```

---

## Verification

### Automatic Verification

```bash
# Run all verification checks
bash Haunt/scripts/setup-haunt.sh --verify

# Verify and auto-fix issues
bash Haunt/scripts/setup-haunt.sh --verify --fix
```

### Manual Verification

**Check 1: Global agents installed**
```bash
ls -la ~/.claude/agents/
# Expected output:
# gco-dev.md
# gco-project-manager.md
# gco-research.md
# gco-code-reviewer.md
# gco-release-manager.md
```

**Check 2: Skills directory exists**
```bash
ls -1 Haunt/skills/
# Expected output (partial list):
# session-startup/
# commit-conventions/
# tdd-workflow/
# requirements-rubric/
# code-review/
```

**Check 3: Claude Code CLI recognizes agents**
```bash
claude --list-agents
# Expected: Shows dev, project-manager, research, etc.
```

**Check 4: Agent files are valid**
```bash
# Validate agent format
bash Haunt/scripts/validation/validate-agents.sh

# Validate skills format
bash Haunt/scripts/validation/validate-skills.sh

# Validate agent-skill references
bash Haunt/scripts/validation/validate-agent-skills.sh
```

**Check 5: Test agent session**
```bash
# Start session (should not error)
claude -a dev --session test-session

# In session, agent should respond to:
# "What skills do you have available?"
# "Run session startup checklist"
```

---

## Common Setup Scenarios

### Scenario A: Corporate Environment (Restricted Internet)

**Challenge:** Cannot install global npm packages or access external repos

**Solution:**
```bash
# 1. Download Claude repo as zip/tarball on allowed machine
# 2. Transfer to restricted environment
# 3. Install dependencies from local cache
npm install --offline @anthropic-ai/claude-code

# 4. Point to local agent files instead of global
export CLAUDE_AGENTS_DIR=/path/to/ghost-county/Haunt/agents
claude -a dev
```

### Scenario B: Team Shared Agents

**Challenge:** Team wants consistent agent configuration across developers

**Solution:**
```bash
# 1. Create team repository for agent customizations
git init team-agents
cd team-agents

# 2. Copy base agents
cp /path/to/ghost-county/Haunt/agents/*.md ./

# 3. Customize for team standards
vim gco-dev.md  # Add team-specific coding standards

# 4. Team members clone and use
git clone https://github.com/yourteam/team-agents.git ~/.claude/agents

# 5. Update periodically
cd ~/.claude/agents && git pull
```

### Scenario C: Multiple Projects with Different Agent Configs

**Challenge:** Different projects need different agent behaviors

**Solution:**
```bash
# Project A: Strict TDD enforcement
cd project-a
mkdir -p .claude/agents
cp ~/.claude/agents/gco-dev.md .claude/agents/gco-dev.md
# Edit .claude/agents/gco-dev.md: Add "ALWAYS write tests first"

# Project B: Relaxed prototyping
cd project-b
mkdir -p .claude/agents
cp ~/.claude/agents/gco-dev.md .claude/agents/gco-dev.md
# Edit .claude/agents/gco-dev.md: Add "Tests optional for spikes"

# Claude Code automatically uses project-specific agents when present
```

### Scenario D: Rollback to v1.0

**Challenge:** v2.0 not working, need to revert to old framework

**Solution:**
```bash
# 1. Backup v2.0 agents
mv ~/.claude/agents ~/.claude/agents.v2.backup

# 2. Use old framework (v1.0 legacy)
cd /path/to/Claude
bash Agentic_SDLC_Framework/scripts/setup-all.sh --agents

# 3. Verify old agents
ls ~/.claude/agents/
# Should show v1.0 legacy monolithic agents (150-300 lines each)

# 4. To restore v2.0 later
rm -rf ~/.claude/agents
mv ~/.claude/agents.v2.backup ~/.claude/agents
```

---

## Troubleshooting

### Issue 1: "Permission denied" when creating ~/.claude/agents/

**Symptoms:**
```
✗ Error: Cannot create directory ~/.claude/agents/
Permission denied
```

**Cause:** Home directory permissions too restrictive

**Fix:**
```bash
# Option A: Fix permissions
mkdir -p ~/.claude/agents
chmod 755 ~/.claude/agents

# Option B: Use project-local agents instead
mkdir -p ./.claude/agents
export CLAUDE_AGENTS_DIR=./.claude/agents
bash scripts/setup-haunt.sh --agents-only
```

### Issue 2: Agents not found after setup

**Symptoms:**
```bash
claude -a dev
# Error: Agent 'dev' not found
```

**Diagnostic:**
```bash
# Check if files exist
ls -la ~/.claude/agents/*.md

# Check Claude Code config
claude --list-agents

# Check CLAUDE_AGENTS_DIR environment variable
echo $CLAUDE_AGENTS_DIR
```

**Fix:**
```bash
# Option A: Re-run setup
bash Haunt/scripts/setup-haunt.sh --agents-only

# Option B: Point to agents directory explicitly
export CLAUDE_AGENTS_DIR=~/.claude/agents
claude -a dev

# Option C: Add to shell profile (permanent)
echo 'export CLAUDE_AGENTS_DIR=~/.claude/agents' >> ~/.bashrc
source ~/.bashrc
```

### Issue 3: Skills not loading in agent sessions

**Symptoms:**
- Agent says "Skill 'session-startup' not found"
- Agent doesn't follow skill workflows

**Diagnostic:**
```bash
# Validate skills exist
ls -la Haunt/skills/gco-session-startup/SKILL.md

# Validate skill format
bash Haunt/scripts/validation/validate-skills.sh

# Check agent references
grep "session-startup" ~/.claude/agents/gco-dev.md
```

**Fix:**
```bash
# Ensure Haunt/skills/ exists
pwd  # Should show project root
ls Haunt/skills/  # Should list skill directories

# Re-run setup to reinstall skills
bash Haunt/scripts/setup-haunt.sh --skills-only
```

### Issue 4: Setup script fails with "command not found"

**Symptoms:**
```
bash: scripts/setup-agentic-sdlc.sh: command not found
```

**Cause:** Wrong working directory or incorrect path

**Fix:**
```bash
# Check current directory
pwd

# Ensure you're in correct location
cd /path/to/Claude

# Use full path to script
bash /path/to/ghost-county/Haunt/scripts/setup-haunt.sh

# Or make script executable and run directly
chmod +x Haunt/scripts/setup-haunt.sh
./Haunt/scripts/setup-haunt.sh
```

### Issue 5: Verification fails with missing directories

**Symptoms:**
```
⚠ Verification found issues:
  - Directory does not exist: .haunt/plans/
  - Directory does not exist: .haunt/progress/
```

**Fix:**
```bash
# Option A: Use fix mode
bash Haunt/scripts/setup-haunt.sh --verify --fix

# Option B: Manual fix
mkdir -p .haunt/plans .haunt/progress .haunt/completed .haunt/tests .claude/agents

# Option C: Re-run full setup
bash Haunt/scripts/setup-haunt.sh
```

### Issue 6: Git user not configured

**Symptoms:**
```
⚠ git user.name: NOT CONFIGURED
⚠ git user.email: NOT CONFIGURED
```

**Impact:** Commit-conventions skill will fail when creating commits

**Fix:**
```bash
# Configure globally (applies to all repos)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Or configure per-repo (this repo only)
cd /path/to/project
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Verify
git config --get user.name
git config --get user.email
```

### Issue 7: Python version too old

**Symptoms:**
```
✗ Python 3: 3.9.6 (requires 3.11+)
```

**Fix:**
```bash
# macOS: Install newer version
brew install python@3.11
brew link python@3.11

# Ubuntu/Debian: Install from deadsnakes PPA
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.11 python3.11-venv

# Verify
python3.11 --version

# Update alternatives to use 3.11 as default
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
```

### Issue 8: Node.js version too old

**Symptoms:**
```
✗ Node.js: 16.14.0 (requires 18+)
```

**Fix:**
```bash
# macOS: Upgrade via Homebrew
brew upgrade node

# Using nvm (recommended for multiple versions)
nvm install 18
nvm use 18
nvm alias default 18

# Verify
node --version
```

### Issue 9: Claude Code CLI not found

**Symptoms:**
```
✗ Claude Code CLI: NOT FOUND
```

**Fix:**
```bash
# Install globally
npm install -g @anthropic-ai/claude-code

# If permission errors on Linux/macOS
sudo npm install -g @anthropic-ai/claude-code

# Or use npx (no global install)
npx @anthropic-ai/claude-code --version

# Verify installation
which claude
claude --version
```

### Issue 10: Script runs but no visible changes

**Symptoms:**
- Script completes successfully
- But no files appear in ~/.claude/agents/

**Diagnostic:**
```bash
# Run with verbose flag
bash Haunt/scripts/setup-haunt.sh --verbose

# Check script variables
echo "HOME: $HOME"
echo "Expected: ~/.claude/agents/ = $HOME/.claude/agents/"
ls -la $HOME/.claude/

# Check for dry-run mode accidentally enabled
bash Haunt/scripts/setup-haunt.sh  # Should NOT say "DRY RUN"
```

**Fix:**
```bash
# Ensure not running in dry-run mode
bash Haunt/scripts/setup-haunt.sh  # Without --dry-run

# Check that TODOs in script are implemented
grep -n "TODO" Haunt/scripts/setup-haunt.sh
# If TODOs exist, agent copying may not be implemented yet
```

---

## Advanced Configuration

### Customizing Agents

**Edit global agent (affects all projects):**
```bash
vim ~/.claude/agents/gco-dev.md

# Example customization:
# Add to "Values" section:
# - Always use TypeScript strict mode
# - Prefer functional programming patterns
```

**Edit project-specific agent (this project only):**
```bash
mkdir -p .claude/agents
cp ~/.claude/agents/gco-dev.md .claude/agents/gco-dev.md
vim .claude/agents/gco-dev.md

# Example customization:
# Add to "Responsibilities" section:
# - Follow company SQL style guide: /docs/sql-guide.md
```

### Creating Custom Skills

**1. Create skill directory and file:**
```bash
mkdir -p Haunt/skills/my-custom-skill
touch Haunt/skills/my-custom-skill/SKILL.md
```

**2. Add YAML frontmatter:**
```yaml
---
name: my-custom-skill
description: When to use this skill and what it does
---

# My Custom Skill

## Purpose
[What this skill helps with]

## When to Use
[Trigger conditions]

## Steps
1. [First step]
2. [Second step]
```

**3. Reference in agent file:**
```bash
vim ~/.claude/agents/gco-dev.md

# Add to "Skills Used" section:
# - my-custom-skill: Custom workflow for [purpose]
```

**4. Validate:**
```bash
bash Haunt/scripts/validation/validate-skills.sh
bash Haunt/scripts/validation/validate-agent-skills.sh
```

### Environment Variables

**CLAUDE_AGENTS_DIR:** Override default agent location
```bash
export CLAUDE_AGENTS_DIR=/custom/path/to/agents
claude -a dev  # Uses /custom/path/to/agents/dev.md
```

**CLAUDE_SKILLS_DIR:** Override default skills location
```bash
export CLAUDE_SKILLS_DIR=/custom/path/to/skills
claude -a dev  # Looks for skills in custom directory
```

**CLAUDE_CONFIG:** Custom configuration file
```bash
export CLAUDE_CONFIG=~/.config/claude/custom-config.json
claude -a dev  # Uses custom config
```

---

## Next Steps

### Starting a New Project (Recommended First Step)

After setup, the best way to begin is to describe what you want to build to the Project Manager:

```bash
# Start Claude with the Project Manager agent
claude -a Project-Manager
```

Then describe your project idea:

```
You: "I want to build a task management API with user authentication,
     CRUD operations for tasks, and a simple React frontend."
```

**What happens next:**

1. **Project Manager confirms understanding** - Summarizes what you want, asks clarifying questions if needed
2. **Requirements Development** - Formal requirements created in `.haunt/plans/`
3. **Requirements Analysis** - Strategic analysis (JTBD, Kano, RICE scoring)
4. **Roadmap Creation** - Breaks down into sized items (S: 1-4h, M: 4-8h)
5. **Agent Assignment** - Each requirement assigned to appropriate agent

Your roadmap at `.haunt/plans/roadmap.md` will contain actionable items like:

```markdown
⚪ REQ-001: Set up project structure and dependencies
   Effort: S | Agent: Dev-Backend

⚪ REQ-002: Implement user authentication endpoints
   Effort: M | Agent: Dev-Backend

⚪ REQ-003: Create React app with routing
   Effort: S | Agent: Dev-Frontend
```

**Quick Reference - What to Say:**

| Goal | Say this |
|------|----------|
| Start new project | "I want to build [description]" |
| Report a bug | "There's a bug where [description]" |
| Request a feature | "We need to add [feature]" |
| Check progress | "What's on the roadmap?" |
| Get next task | "What should I work on next?" |

---

### After Your Roadmap is Created

**1. Work on Requirements**
```bash
# Start dev agent to implement features
claude -a dev

# In session:
# "Work on REQ-001 from the roadmap"
```

**2. Review Agent Definitions**
```bash
# Read through each agent to understand their roles
cat ~/.claude/agents/gco-dev.md
cat ~/.claude/agents/gco-project-manager.md
cat ~/.claude/agents/gco-research.md
cat ~/.claude/agents/gco-code-reviewer.md
cat ~/.claude/agents/gco-release-manager.md
```

**3. Browse Available Skills**
```bash
# List all Haunt skills
ls -1 ~/.claude/skills/

# Read core skills
cat ~/.claude/skills/gco-session-startup/SKILL.md
cat ~/.claude/skills/gco-commit-conventions/SKILL.md
cat ~/.claude/skills/gco-tdd-workflow/SKILL.md
cat ~/.claude/skills/gco-roadmap-workflow/SKILL.md
```

**4. Run a Full Agent-Driven Development Cycle**
```bash
# 1. Plan with Project Manager
claude -a Project-Manager  # Create requirements in roadmap.md

# 2. Implement with Dev
claude -a dev  # Work on requirements from roadmap

# 3. Review with Code Reviewer
claude -a Code-Reviewer  # Review completed work

# 4. Research as needed
claude -a Research-Analyst  # Investigate technical questions
```

### Recommended Reading Order

1. **README.md** - Architecture overview and FAQ
2. **docs/SDK-INTEGRATION.md** - How SDK features integrate with framework
3. **docs/TOOL-PERMISSIONS.md** - Agent tool access reference
4. **docs/SKILLS-REFERENCE.md** - Complete skills catalog
5. **agents/gco-dev.md** - Most commonly used agent
6. **skills/gco-session-startup/SKILL.md** - Start-of-session workflow
7. **skills/gco-commit-conventions/SKILL.md** - Git standards
8. **skills/gco-tdd-workflow/SKILL.md** - Test-driven development
9. **skills/gco-roadmap-workflow/SKILL.md** - Project planning

### Learning Path

**Week 1: Basics**
- [ ] Complete setup
- [ ] Start 3 dev agent sessions
- [ ] Practice session-startup skill
- [ ] Make 5 commits following commit-conventions skill

**Week 2: Project Management**
- [ ] Create roadmap.md for personal project
- [ ] Use project-manager agent to break down features
- [ ] Complete 1 requirement end-to-end

**Week 3: Advanced**
- [ ] Create custom skill for your workflow
- [ ] Customize dev agent for your preferences
- [ ] Use code-reviewer agent for PR review
- [ ] Use research agent for technical investigation

**Week 4: Team Adoption**
- [ ] Share setup with teammate
- [ ] Create team-specific agent customizations
- [ ] Establish team roadmap workflow
- [ ] Document lessons learned

### Getting Help

**Resources:**
- **README.md** - Quick reference and FAQ
- **SETUP-GUIDE.md** - This document
- **docs/SKILLS-REFERENCE.md** - All available skills
- **Validation Scripts:**
  - `bash Haunt/scripts/validation/validate-agents.sh`
  - `bash Haunt/scripts/validation/validate-skills.sh`
  - `bash Haunt/scripts/validation/validate-agent-skills.sh`

**Common Commands:**
```bash
# Get help on setup script
bash Haunt/scripts/setup-haunt.sh --help

# Verify setup
bash Haunt/scripts/setup-haunt.sh --verify

# List installed agents
claude --list-agents

# Start agent with specific skill
claude -a dev --skill session-startup
```

---

## Appendix: Setup Script Reference

### Full Command Reference

```bash
# Basic usage
bash scripts/setup-agentic-sdlc.sh [OPTIONS]

# Options
--help                 # Show help message
--dry-run              # Preview changes
--agents-only          # Only setup global agents
--skills-only          # Only setup project skills
--project-only         # Only setup project structure
--verify               # Verify existing setup
--fix                  # Fix issues during verification
--skip-prereqs         # Skip prerequisite checks
--verbose              # Detailed output

# Examples
bash scripts/setup-agentic-sdlc.sh                    # Full setup
bash scripts/setup-agentic-sdlc.sh --dry-run          # Preview
bash scripts/setup-agentic-sdlc.sh --agents-only      # Agents only
bash scripts/setup-agentic-sdlc.sh --verify           # Verify
bash scripts/setup-agentic-sdlc.sh --verify --fix     # Verify & fix
bash scripts/setup-agentic-sdlc.sh --verbose          # Verbose output
```

### Exit Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | Setup complete |
| 1 | General error | Check error output |
| 2 | Invalid arguments | Run with --help |
| 3 | Missing dependencies | Install required tools |
| 4 | Verification failed | Run --verify --fix |

### What Gets Created

**Global (one-time):**
- `~/.claude/agents/gco-dev.md`
- `~/.claude/agents/gco-project-manager.md`
- `~/.claude/agents/gco-research.md`
- `~/.claude/agents/gco-code-reviewer.md`
- `~/.claude/agents/gco-release-manager.md`

**Project (per-project):**
- `.claude/agents/` (optional overrides)
- `.haunt/plans/roadmap.md` (feature planning)
- `.haunt/progress/` (session progress tracking)
- `.haunt/completed/` (archived completed work)
- `.haunt/tests/` (test suites)
- `.haunt/docs/` (Haunt documentation)

---

## Changelog

### v2.0.0 (Current)
- Lightweight agent architecture (30-50 lines vs 150-300)
- Reusable skills library with YAML frontmatter
- Single source of truth for workflows
- Faster agent initialization
- Better version control for skill changes

### v1.0.0 (Legacy)
- Monolithic agent files
- Duplicated content across agents
- Harder to maintain and update
- Available in `Agentic_SDLC_Framework/`

---

**Setup complete? Start coding with agents!**

```bash
# Your first command:
claude -a dev
```

Happy agentic development!
