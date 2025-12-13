# Haunt v2.0 - Quick Reference Card

> Print this and keep it near your terminal!

---

## First-Time Setup

```bash
cd /path/to/ghost-county
bash /Users/heckatron/github_repos/ghost-county/Haunt/scripts/setup-haunt.sh
bash /Users/heckatron/github_repos/ghost-county/Haunt/scripts/setup-haunt.sh --verify
```

## Your First Command

```bash
claude -a dev
```

---

## Available Agents

| Agent | Command | Purpose |
|-------|---------|---------|
| Dev | `claude -a dev` | Development (backend/frontend/infra) |
| Project Manager | `claude -a project-manager` | Roadmap and planning |
| Research | `claude -a research` | Technical investigation |
| Code Reviewer | `claude -a code-reviewer` | Code quality review |
| Release Manager | `claude -a release-manager` | Deployment coordination |

---

## Core Skills (Ask agent to use these)

- `session-startup` - Start-of-session checklist
- `commit-conventions` - Git commit standards
- `tdd-workflow` - Test-driven development
- `roadmap-workflow` - Feature planning
- `feature-contracts` - Acceptance criteria
- `code-patterns` - Code pattern recognition
- `pattern-defeat` - Pattern defeat methodology
- `weekly-refactor` - Weekly maintenance
- `roadmap-planning` - Roadmap creation

All skills located in: `Haunt/skills/`

---

## Rules (Auto-Enforced Protocols)

Rules auto-load from `.claude/rules/` and enforce invariants:

| Rule | Enforces |
|------|----------|
| `session-startup.md` | 5-step startup checklist |
| `file-conventions.md` | Haunt artifact locations |
| `commit-conventions.md` | Commit format `[REQ-XXX] Action: Description` |
| `status-updates.md` | Worker vs PM responsibilities |
| `assignment-lookup.md` | 4-step assignment sequence |
| `completion-checklist.md` | 5-point verification before done |
| `roadmap-format.md` | Roadmap file structure (path-targeted) |

Rules vs Skills: Rules = "MUST always" (auto-loaded), Skills = "HOW to" (on-demand)

All rules located in: `Haunt/rules/`

---

## Common Commands

### Setup & Verification
```bash
# Full setup
bash scripts/setup-agentic-sdlc.sh

# Update agents only
bash scripts/setup-agentic-sdlc.sh --agents-only

# Verify setup
bash scripts/setup-agentic-sdlc.sh --verify

# Fix issues
bash scripts/setup-agentic-sdlc.sh --verify --fix

# Get help
bash scripts/setup-agentic-sdlc.sh --help
```

### Validation
```bash
# Validate agents
bash scripts/validate-agents.sh

# Validate skills
bash scripts/validate-skills.sh

# Validate references
bash scripts/validate-agent-skills.sh
```

### Agent Usage
```bash
# Start dev session
claude -a dev

# Start planning session
claude -a project-manager

# Start research session
claude -a research
```

---

## Directory Structure

```
~/.claude/agents/              # Global agents (all projects)
~/.claude/rules/               # Global rules (auto-enforced protocols)
./.claude/agents/              # Project agents (override global)
./.claude/rules/               # Project rules (override global)
Haunt/agents/                  # Agent source files
Haunt/rules/                   # Rules source files
Haunt/skills/                  # Haunt methodology skills
├── session-startup/
├── commit-conventions/
├── tdd-workflow/
├── roadmap-workflow/
├── feature-contracts/
├── code-patterns/
├── pattern-defeat/
├── weekly-refactor/
└── roadmap-planning/
Skills/                        # Domain-specific skills (optional)
.haunt/plans/roadmap.md        # Feature roadmap
.haunt/progress/               # Session progress tracking
.haunt/completed/              # Archived completed work
.haunt/tests/                  # Test suites
.haunt/docs/                   # Haunt documentation
```

---

## Troubleshooting Quick Fixes

### Agents not found
```bash
ls ~/.claude/agents/*.md
claude --list-agents
bash scripts/setup-agentic-sdlc.sh --agents-only
```

### Skills not loading
```bash
ls Haunt/skills/
bash scripts/validation/validate-skills.sh
bash scripts/validation/validate-agent-skills.sh
```

### Setup fails
```bash
# Check prerequisites
git --version
python3 --version
node --version
claude --version

# Re-run with verbose
bash scripts/setup-agentic-sdlc.sh --verbose
```

---

## Common Workflows

### Planning a Feature
```bash
claude -a project-manager
> "Create roadmap for dark mode feature"
> "Break down into tasks"
```

### Developing a Feature
```bash
claude -a dev
> "Run session startup checklist"
> "Work on REQ-001 from roadmap"
> "Follow TDD workflow"
```

### Reviewing Code
```bash
claude -a code-reviewer
> "Review changes in src/auth.ts"
> "Check test coverage"
```

### Researching Solutions
```bash
claude -a research
> "Compare PostgreSQL vs MongoDB"
> "Investigate JWT best practices"
```

---

## Customization

### Global Agents (all projects)
```bash
vim ~/.claude/agents/gco-dev.md
```

### Project-Specific Agents (this project only)
```bash
mkdir -p .claude/agents
cp ~/.claude/agents/gco-dev.md .claude/agents/gco-dev.md
vim .claude/agents/gco-dev.md
```

### Create Custom Skill
```bash
# Create new Haunt skill
mkdir -p Haunt/skills/my-skill
vim Haunt/skills/my-skill/SKILL.md

# Add YAML frontmatter + content
bash scripts/validation/validate-skills.sh
```

---

## Documentation

| File | Purpose |
|------|---------|
| README.md | Architecture overview and FAQ |
| SETUP-GUIDE.md | Complete setup instructions |
| QUICK-REFERENCE.md | This cheat sheet |
| docs/SKILLS-REFERENCE.md | All available skills |
| docs/SDK-INTEGRATION.md | SDK integration details |
| docs/TOOL-PERMISSIONS.md | Agent tool access reference |
| docs/WHITE-PAPER.md | Framework design philosophy |
| docs/PATTERN-DETECTION.md | Pattern detection methodology |
| docs/HAUNT-DIRECTORY-SPEC.md | Directory structure specification |

---

## Git Workflow (with commit-conventions skill)

```bash
# Create feature branch
git checkout -b feature/dark-mode

# Make changes
# ...

# Commit (agent will format properly using commit-conventions skill)
claude -a dev
> "Create commit for dark mode toggle component"

# Push
git push -u origin feature/dark-mode
```

---

## Session Startup Checklist (session-startup skill)

```
1. [ ] pwd - Verify correct directory
2. [ ] git status - Check uncommitted changes
3. [ ] npm test - Run tests
4. [ ] Read .haunt/plans/roadmap.md - Check assignment
5. [ ] Start working
```

---

## TDD Workflow (tdd-workflow skill)

```
1. Red: Write failing test
2. Green: Make it pass (minimal code)
3. Refactor: Clean up
4. Repeat
```

---

## Roadmap Format (roadmap-workflow skill)

```markdown
🟡 REQ-001: Add dark mode toggle
   Tasks:
   - [ ] Create toggle component
   - [ ] Add state management
   Files: src/components/DarkModeToggle.tsx, src/store/theme.ts
   Effort: S
   Agent: dev
   Completion: Toggle switches theme, persists to localStorage
   Blocked by: None
```

Status: ⚪ Not Started | 🟡 In Progress | 🟢 Complete | 🔴 Blocked

---

## Environment Variables

```bash
# Custom agent directory
export CLAUDE_AGENTS_DIR=/custom/path/to/agents

# Custom skills directory
export CLAUDE_SKILLS_DIR=/custom/path/to/skills

# Custom config
export CLAUDE_CONFIG=~/.config/claude/custom.json
```

---

## Update After Git Pull

```bash
git pull origin master
bash scripts/setup-agentic-sdlc.sh --agents-only
bash scripts/setup-agentic-sdlc.sh --verify
```

---

## Rollback to v1.0

```bash
mv ~/.claude/agents ~/.claude/agents.v2.backup
bash Ghost_County_Framework/scripts/setup-all.sh --agents
```

---

## Help Resources

```bash
# Setup help
bash scripts/setup-agentic-sdlc.sh --help

# Comprehensive guide
cat SETUP-GUIDE.md

# Troubleshooting
grep -A5 "Troubleshooting" SETUP-GUIDE.md

# Agent customization
cat agents/gco-dev.md
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | Missing dependencies |
| 4 | Verification failed |

---

**Keep this reference handy and start building with agents!**

```bash
claude -a dev  # Let's go!
```
