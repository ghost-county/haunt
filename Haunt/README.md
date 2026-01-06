# Haunt

> Transform AI language models into coordinated development teams with persistent memory, structured workflows, and enforced quality standards.

[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/ghost-county/haunt)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## What Is Haunt?

**Haunt** is a lightweight framework that gives AI agents **persistent memory**, **specialized roles**, and **enforced best practices**—transforming one-off code generation into coordinated team development.

While traditional AI coding assistants forget everything between sessions, Haunt creates AI teammates that:

- ✅ **Remember your project conventions** across sessions
- ✅ **Coordinate parallel workstreams** without conflicts
- ✅ **Enforce quality standards** automatically
- ✅ **Track progress** through structured roadmaps
- ✅ **Maintain context** about architectural decisions

**The difference:** You're not just getting code suggestions—you're building with a team that has institutional knowledge.

---

## Quick Start

### Installation (3 Commands)

```bash
# 1. Clone repository
git clone https://github.com/ghost-county/haunt.git
cd ghost-county

# 2. Run setup
bash Haunt/scripts/setup-haunt.sh

# 3. Verify installation
bash Haunt/scripts/setup-haunt.sh --verify
```

**What setup does:**

- Copies agent character sheets to `~/.claude/agents/`
- Installs rules to `~/.claude/rules/` (auto-loaded every session)
- Deploys skills to `~/.claude/skills/` (on-demand)

### Set Up the Haunt Alias (Recommended)

Add to your shell config (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# Haunt alias - starts Claude Code with full tool access
alias haunt='claude --dangerously-skip-permissions'
```

Then reload: `source ~/.bashrc` (or `~/.zshrc`)

### Your First Séance

The fastest way to start a project:

```bash
haunt
/seance "I want to build a REST API for book reviews"
```

The séance workflow will:

1. 🔮 **Scry** - Create requirements and roadmap
2. 👻 **Summon** - Spawn agents to implement features
3. ⚰️ **Banish** - Archive completed work

**Alternative: Direct Agent Access**

```bash
# Start with Project Manager
claude -a project-manager

# Start with Dev agent
claude -a dev
```

---

## Core Features

### 🧠 External Memory System

LLMs are stateless, but Haunt provides **5 layers of persistent memory**:

| Layer | Purpose | Example |
|-------|---------|---------|
| **Rules** | Auto-loaded invariants | "Always verify tests pass before starting work" |
| **Agents** | Character sheets | "I am a Dev agent who follows TDD" |
| **Skills** | On-demand workflows | "How to write a commit message" |
| **CLAUDE.md** | Project context | "This is a REST API using FastAPI" |
| **Roadmap** | Working memory | "REQ-042: Implement JWT auth (In Progress)" |

**Result:** Agents remember your standards, patterns, and decisions across sessions.

### 👥 Specialized Agent Teams

Instead of one "do everything" assistant, Haunt provides **5 specialized agents**:

| Agent | Role | Capabilities |
|-------|------|--------------|
| **Project Manager** | Coordinator | Requirements analysis, roadmap planning, batch coordination |
| **Dev** | Implementation | Backend/Frontend/Infrastructure modes, TDD workflow |
| **Research** | Investigation | Technical research, library evaluation, documentation validation |
| **Code Reviewer** | Quality Gate | Pattern detection, PR review, merge coordination |
| **Release Manager** | Deployment | Release coordination, changelog generation |

**Coordination:** Agents communicate through the **roadmap** (status updates, blockers, dependencies)—no direct agent-to-agent communication needed.

### 📋 Roadmap-Driven Development

**Single source of truth:** `.haunt/plans/roadmap.md`

```markdown
## Batch 1: Foundation (parallel execution)

### 🟡 REQ-001: Database schema for tasks
**Agent:** Dev-Backend | **Effort:** S (1-2hr) | **Complexity:** SIMPLE
- [x] Create User model
- [x] Create Task model
- [ ] Write migration

### ⚪ REQ-002: React app structure
**Agent:** Dev-Frontend | **Effort:** S (1-2hr)
**Blocked by:** None
```

**Features:**

- Visual status tracking (⚪ Not Started, 🟡 In Progress, 🟢 Complete, 🔴 Blocked)
- Dependency chains prevent premature work
- Batch organization enables parallel execution
- Automatic archival when complete

### ⚡ Quality Enforcement

**No shortcuts allowed.** Before marking work complete, agents verify:

1. ✅ All task checkboxes marked `[x]`
2. ✅ Completion criteria met
3. ✅ **Tests passing** (pytest/npm test)
4. ✅ Files modified as specified
5. ✅ Documentation updated
6. ✅ Security review completed (if code involves user input, auth, databases, APIs)
7. ✅ Self-validation performed

**Standardized commits:**

```
[REQ-042] Add: JWT authentication endpoints

What was done:
- Created POST /auth/login endpoint with JWT generation
- Added token refresh endpoint
- Implemented rate limiting (10 req/min)

🤖 Generated with Claude Code
```

### 🔧 Wrapper Scripts: Structured Execution

Haunt provides **structured wrapper scripts** that return JSON for programmatic verification:

```bash
# Get specific requirement as JSON (saves 98% tokens vs reading full roadmap)
bash Haunt/scripts/haunt-roadmap.sh get REQ-042

# Run tests with structured output
bash Haunt/scripts/haunt-run.sh test

# Verify completion criteria programmatically
bash Haunt/scripts/haunt-verify.sh REQ-042 backend
```

**Result:** 60-98% token reduction for common operations, zero manual file parsing.

### 🔐 Secrets Management: 1Password Integration

Keep your `.env` files versionable while securing secrets in 1Password:

```bash
# .env file (safe to commit)
# @secret:op:my-vault/api-keys/github-token
GITHUB_TOKEN=placeholder

# Load secrets from 1Password
source Haunt/scripts/haunt-secrets.sh
load_secrets .env

# Secret is now available
echo $GITHUB_TOKEN  # Actual value from 1Password
```

**Key Features:**

- ✅ Tag secrets with `# @secret:op:vault/item/field` format
- ✅ Keep `.env` files in version control (only placeholders)
- ✅ Automatic secret fetching via 1Password CLI
- ✅ Zero secret exposure in logs or error messages
- ✅ Validation mode to check resolvability without loading

**See:** [Haunt/docs/SECRETS-MANAGEMENT.md](docs/SECRETS-MANAGEMENT.md) for complete setup guide.

---

## The Séance Workflow

Haunt's complete idea-to-shipped workflow:

```bash
# Set up the alias first (see Quick Start)
haunt
/seance "Add OAuth login support"

🔮 Scrying... (creates requirements, strategic analysis, roadmap)
👻 Summoning... (spawns agents, implements features, runs tests)
⚰️ Banishing... (archives completed work, cleans roadmap)

✅ OAuth login shipped, tested, committed, documented, archived
```

**Key Features:**

- **Planning depth modes**: `--quick` (basic), default (standard), `--deep` (comprehensive analysis)
- **Parallel execution**: Agents work simultaneously on independent requirements
- **Automatic archival**: Completed work archived automatically
- **Phase gates**: Deterministic workflow with explicit pass/fail criteria

**See:** [Haunt/docs/SEANCE-EXPLAINED.md](docs/SEANCE-EXPLAINED.md) for complete Séance guide.

---

## Architecture Overview

### The Four-Layer System

```
┌──────────────────────────────────────────────┐
│ AGENTS (WHO you are)                         │ ← 30-50 lines each
│   Character sheets, tool permissions         │   Loaded on spawn
├──────────────────────────────────────────────┤
│ RULES (You MUST do this)                     │ ← 50-100 lines each
│   Invariant enforcement, auto-loaded         │   Always enforced
├──────────────────────────────────────────────┤
│ SKILLS (HOW to do this)                      │ ← 100-500 lines each
│   Reusable workflows, on-demand              │   Loaded when invoked
├──────────────────────────────────────────────┤
│ COMMANDS (Shortcuts)                         │ ← User-invoked
│   Common task automation                     │   Slash commands
└──────────────────────────────────────────────┘
```

**Why This Layering Matters:**

- **Agents are lightweight** (30-50 lines) because they reference skills rather than duplicating workflows
- **Rules are always on** because they enforce invariants that must never be violated
- **Skills are on-demand** because they're detailed guidance only needed in specific contexts
- **Commands are shortcuts** for tasks users would otherwise type manually

### v2.0 vs v1.0

| Aspect | v1.0 (Monolithic) | v2.0 (Lightweight) |
|--------|-------------------|-------------------|
| Agent file size | 200+ lines | 30-50 lines |
| Workflow duplication | Duplicated in every agent | Shared via skills |
| Maintenance | Update 5 agents for one change | Update 1 skill |
| Loading speed | Slower (large files) | 85% faster |
| Token efficiency | Rules + skills bloat | Slim references + on-demand |

---

## What Makes Haunt Unique

### 1. External Memory for Stateless LLMs

Rules, skills, and roadmap provide **persistent institutional knowledge** that survives across sessions.

### 2. Roadmap as Communication Layer

Agents coordinate through **status updates** in the roadmap—no direct agent-to-agent communication needed.

### 3. One-Feature-Per-Session Rule

Everything sized to complete in **one sitting** (max 4 hours)—prevents context sprawl and ensures atomic commits.

### 4. TDD for Agent Behavior

**Pattern detection tests** ensure agents learn from mistakes:

- Pattern Found → Test Written → Agent Trained → Pattern Defeated

### 5. Metrics Framework: Zero Agent Overhead

Wrapper scripts emit metrics automatically—agents remain unaware of instrumentation.

### 6. Skill Refactoring Pattern

Slim reference files (rules) with consultation gates to comprehensive skills (on-demand) prevent token bloat.

---

## File Organization

### Project Structure

```
.haunt/
├── plans/
│   └── roadmap.md                # Single source of truth
├── completed/                    # Archived requirements
├── progress/                     # Session notes
├── tests/
│   ├── patterns/                 # Pattern defeat tests
│   ├── behavior/                 # Agent behavior tests
│   └── e2e/                      # End-to-end tests
└── docs/
    ├── research/                 # Investigation findings
    └── validation/               # Review reports
```

### Framework Structure

```
Haunt/
├── agents/                       # Character sheets (source)
│   ├── gco-dev.md
│   ├── gco-project-manager.md
│   └── ...
├── rules/                        # Invariant enforcement (source)
│   ├── gco-session-startup.md
│   ├── gco-commit-conventions.md
│   └── ...
├── skills/                       # Reusable workflows (source)
│   ├── gco-tdd-workflow/
│   ├── gco-roadmap-planning/
│   └── ...
├── scripts/                      # Wrapper scripts
│   ├── haunt-roadmap.sh          # Structured roadmap lookup
│   ├── haunt-run.sh              # Build/test/lint execution
│   ├── haunt-verify.sh           # Completion verification
│   └── setup-haunt.sh            # Installation script
└── docs/
    ├── WHITE-PAPER.md            # Framework design philosophy
    ├── SEANCE-EXPLAINED.md       # Complete Séance guide
    ├── SETUP-GUIDE.md            # Installation instructions
    └── ...
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| **README.md** | This file - overview and quick start |
| **[SETUP-GUIDE.md](SETUP-GUIDE.md)** | Complete installation instructions |
| **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** | Cheat sheet for commands, agents, skills |
| **[docs/WHITE-PAPER.md](docs/WHITE-PAPER.md)** | Framework design philosophy and architecture |
| **[docs/SEANCE-EXPLAINED.md](docs/SEANCE-EXPLAINED.md)** | Complete Séance workflow guide |
| **[docs/SECRETS-MANAGEMENT.md](docs/SECRETS-MANAGEMENT.md)** | 1Password secrets integration guide |
| **[docs/SDK-INTEGRATION.md](docs/SDK-INTEGRATION.md)** | How SDK features integrate |
| **[docs/SKILLS-REFERENCE.md](docs/SKILLS-REFERENCE.md)** | Complete skills catalog |
| **[docs/PATTERN-DETECTION.md](docs/PATTERN-DETECTION.md)** | Pattern detection methodology |

---

## FAQ

### Do I need to install MCP servers?

**Optional.** Haunt works without MCP, but Context7 (docs lookup) and Playwright (E2E tests) enhance capabilities.

### How do I customize an agent?

Edit the agent file in `~/.claude/agents/`. Changes apply to all projects using that agent.

### What if I want to remove Haunt?

```bash
rm -rf ~/.claude/agents/gco-* ~/.claude/rules/gco-* ~/.claude/skills/gco-*
```

### Can I use both v1.0 and v2.0?

**Not recommended.** Choose one architecture per project to avoid conflicting instructions.

### How much does this cost?

Haunt is **MIT licensed** and free. You pay only for Claude API usage.

### Does this work with other LLMs?

Currently designed for **Claude** via Claude Code CLI.

---

## Contributing

We welcome contributions! Here's how:

1. **Report bugs/patterns:** Use `/issue-to-roadmap` to log issues
2. **Submit skills:** Create `Haunt/skills/your-skill/SKILL.md` with YAML frontmatter
3. **Improve agents:** Suggest character sheet refinements
4. **Share workflows:** Document your team's Haunt usage patterns

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Getting Help

- **Quick questions:** Check [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
- **Setup issues:** Read [SETUP-GUIDE.md](SETUP-GUIDE.md)
- **Deep dives:** Explore [docs/WHITE-PAPER.md](docs/WHITE-PAPER.md)
- **Bug reports:** Use `claude /haunt-report` for automatic diagnostics

---

**Ready to build with AI teammates who actually remember your project?**

```bash
# Set up the haunt alias
echo "alias haunt='claude --dangerously-skip-permissions'" >> ~/.bashrc
source ~/.bashrc

# Run setup
bash Haunt/scripts/setup-haunt.sh

# Start your first séance
haunt
/seance "Build a task management API"
```

Let's haunt some code. 👻
