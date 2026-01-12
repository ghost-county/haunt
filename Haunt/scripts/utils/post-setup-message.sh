#!/usr/bin/env bash
#
# post-setup-message.sh - Enhanced post-setup guidance message
#
# This file contains the comprehensive "Next Steps" message that should
# be displayed after successful setup completion.
#
# Usage: Source this file or call show_next_steps function

# Ensure color codes are available
if [[ -z "${BOLD}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m' # No Color
fi

# Default paths (can be overridden)
GLOBAL_AGENTS_DIR="${GLOBAL_AGENTS_DIR:-${HOME}/.claude/agents}"
PROJECT_SKILLS_DIR="${PROJECT_SKILLS_DIR:-Haunt/skills}"

show_next_steps() {
    cat << EOF

${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${BOLD}${GREEN}  SETUP COMPLETE! Your Haunt environment is ready.${NC}
${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BOLD}${CYAN}QUICK START - Your First Command:${NC}

    ${BOLD}claude -a dev${NC}

    This starts a development session with the dev agent.
    Try saying: "${CYAN}What skills do you have available?${NC}"
    Or: "${CYAN}Run session startup checklist${NC}"

${BOLD}${CYAN}WHAT WAS INSTALLED:${NC}

    ${BOLD}Global Agents:${NC} ${GLOBAL_AGENTS_DIR}
    ✓ gco-dev.md              - Polyglot developer (backend/frontend/infrastructure)
    ✓ gco-project-manager.md  - Roadmap coordinator and task dispatcher
    ✓ gco-research.md         - Technical investigator and validator
    ✓ gco-code-reviewer.md    - Quality enforcer for merge requests
    ✓ gco-release-manager.md  - Deployment orchestrator

    ${BOLD}Skills Library:${NC} ${PROJECT_SKILLS_DIR}
    ✓ session-startup     - Session initialization checklist
    ✓ commit-conventions  - Git commit and branch naming standards
    ✓ tdd-workflow        - Test-driven development workflow
    ✓ roadmap-workflow    - Feature planning and batch management
    ✓ feature-contracts   - Immutable acceptance criteria patterns
    ${CYAN}... and 10+ more Haunt skills available${NC}

${BOLD}${CYAN}NEXT STEPS:${NC}

    ${BOLD}1. Verify Installation${NC}
       ls ~/.claude/agents/                    ${CYAN}# List installed agents${NC}
       claude --list-agents                    ${CYAN}# Check Claude recognizes them${NC}

    ${BOLD}2. Review Agent Definitions${NC}
       cat ~/.claude/agents/gco-dev.md             ${CYAN}# Most commonly used${NC}
       cat ~/.claude/agents/gco-project-manager.md ${CYAN}# For roadmap planning${NC}

    ${BOLD}3. Browse Available Skills${NC}
       ls -1 Haunt/skills/                   ${CYAN}# List all skills${NC}
       cat Haunt/skills/gco-session-startup/SKILL.md   ${CYAN}# Core workflow${NC}
       cat Haunt/skills/gco-tdd-workflow/SKILL.md      ${CYAN}# TDD guidance${NC}

    ${BOLD}4. Start Your First Session${NC}
       claude -a dev                           ${CYAN}# Development agent${NC}
       claude -a project-manager               ${CYAN}# Planning agent${NC}

    ${BOLD}5. Create Your First Roadmap${NC}
       mkdir -p plans                          ${CYAN}# Create plans directory${NC}
       claude -a project-manager               ${CYAN}# Start PM session${NC}
       ${CYAN}# In session: "Create roadmap for [your project]"${NC}

${BOLD}${CYAN}COMMON WORKFLOWS:${NC}

    ${BOLD}Planning Session (with Project Manager):${NC}
       claude -a project-manager
       > "Create a roadmap for adding dark mode to my app"
       > "Break down REQ-001 into smaller tasks"
       > "Archive completed requirements from last sprint"

    ${BOLD}Development Session (with Dev):${NC}
       claude -a dev
       > "Run session startup checklist"
       > "Work on REQ-001 from roadmap"
       > "Follow TDD workflow for authentication feature"

    ${BOLD}Code Review Session (with Code Reviewer):${NC}
       claude -a code-reviewer
       > "Review the changes in src/auth.ts"
       > "Check if tests cover all edge cases"

    ${BOLD}Research Session (with Research):${NC}
       claude -a research
       > "Investigate best practices for JWT token rotation"
       > "Compare PostgreSQL vs MongoDB for our use case"

${BOLD}${CYAN}DOCUMENTATION:${NC}

    ${BOLD}README.md${NC}                  - Architecture overview and FAQ
    ${BOLD}SETUP-GUIDE.md${NC}             - Comprehensive setup instructions
    ${BOLD}docs/SKILLS-REFERENCE.md${NC}   - Complete catalog of all available skills
    ${BOLD}docs/WHITE-PAPER.md${NC}        - Framework design philosophy
    ${BOLD}docs/SDK-INTEGRATION.md${NC}    - SDK integration details

${BOLD}${CYAN}TROUBLESHOOTING:${NC}

    ${BOLD}If agents not found:${NC}
       bash scripts/setup-haunt.sh --verify --fix

    ${BOLD}If skills not loading:${NC}
       bash scripts/validation/validate-skills.sh
       bash scripts/validation/validate-agent-skills.sh

    ${BOLD}For detailed help:${NC}
       bash scripts/setup-haunt.sh --help
       cat SETUP-GUIDE.md

${BOLD}${CYAN}CUSTOMIZATION:${NC}

    ${BOLD}Global agents (all projects):${NC}
       vim ~/.claude/agents/gco-dev.md             ${CYAN}# Edit global behavior${NC}

    ${BOLD}Project-specific agents (this project only):${NC}
       mkdir -p .claude/agents
       cp ~/.claude/agents/gco-dev.md .claude/agents/gco-dev.md
       vim .claude/agents/gco-dev.md               ${CYAN}# Project-specific overrides${NC}

    ${BOLD}Create custom skills:${NC}
       mkdir -p Haunt/skills/my-skill
       vim Haunt/skills/my-skill/SKILL.md    ${CYAN}# Add YAML frontmatter + content${NC}
       bash scripts/validation/validate-skills.sh  ${CYAN}# Validate format${NC}

${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BOLD}Ready to start?${NC} Run this command:

    ${BOLD}${CYAN}claude -a dev${NC}

${BOLD}Happy agentic development!${NC}

EOF
}

# If executed directly (not sourced), show the message
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_next_steps
fi
