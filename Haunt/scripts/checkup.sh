#!/bin/bash
# Haunt Framework Health Check
# Verifies that Ghost County spirits are properly installed and responsive
# Usage: bash Haunt/scripts/checkup.sh [--quick|--verbose]

set -e

# Terminal colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
MAGENTA='\033[1;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse mode
MODE="${1:-normal}"
VERBOSE=false
QUICK=false

case "$MODE" in
    --quick)
        QUICK=true
        ;;
    --verbose)
        VERBOSE=true
        ;;
esac

# Tracking results
CHECKS_PASSED=0
CHECKS_WARNED=0
CHECKS_FAILED=0
ISSUES=()

# Check function that tracks results
check() {
    local status=$1
    local message=$2

    case "$status" in
        "pass")
            echo -e "${GREEN}✅${NC} $message"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
            ;;
        "warn")
            echo -e "${YELLOW}⚠️${NC} $message"
            CHECKS_WARNED=$((CHECKS_WARNED + 1))
            ;;
        "fail")
            echo -e "${RED}❌${NC} $message"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
            ;;
    esac
}

# Add issue for troubleshooting section
add_issue() {
    local title=$1
    local fix=$2
    ISSUES+=("$title|$fix")
}

# Header
if [ "$QUICK" = true ]; then
    echo -e "${MAGENTA}🏚️  QUICK CHECKUP  🏚️${NC}"
else
    echo -e "${MAGENTA}🏚️  HAUNT CHECKUP COMPLETE  🏚️${NC}"
fi
echo ""

# 1. Rules Adherence Check
if [ "$QUICK" = false ] || [ "$QUICK" = true ]; then
    RULES_DIR="$HOME/.claude/rules"
    EXPECTED_RULES=8

    if [ -d "$RULES_DIR" ]; then
        FOUND_RULES=$(ls "$RULES_DIR"/gco-*.md 2>/dev/null | wc -l | tr -d ' ')

        if [ "$VERBOSE" = true ]; then
            echo -e "${CYAN}Rules found:${NC}"
            ls "$RULES_DIR"/gco-*.md 2>/dev/null | sed 's/^/  /' || true
            echo ""
        fi

        if [ "$FOUND_RULES" -eq "$EXPECTED_RULES" ]; then
            check "pass" "Rules: $FOUND_RULES/$EXPECTED_RULES loaded"
        elif [ "$FOUND_RULES" -gt 0 ]; then
            MISSING=$((EXPECTED_RULES - FOUND_RULES))
            check "warn" "Rules: $FOUND_RULES/$EXPECTED_RULES loaded (missing $MISSING)"
            add_issue "Rules partially deployed" "Re-run: bash Haunt/scripts/setup-haunt.sh"
        else
            check "fail" "Rules: No rules found"
            add_issue "Rules not deployed" "Run: bash Haunt/scripts/setup-haunt.sh"
        fi
    else
        check "fail" "Rules: Directory not found"
        add_issue "Rules directory missing" "Run: bash Haunt/scripts/setup-haunt.sh"
    fi
fi

# 2. Skills Availability Check
if [ "$QUICK" = false ]; then
    SKILLS_DIR="$HOME/.claude/skills"

    if [ -d "$SKILLS_DIR" ]; then
        FOUND_SKILLS=$(ls -d "$SKILLS_DIR"/gco-*/ 2>/dev/null | wc -l | tr -d ' ')
        VALID_SKILLS=0

        for skill_dir in "$SKILLS_DIR"/gco-*/; do
            if [ -f "$skill_dir/SKILL.md" ]; then
                VALID_SKILLS=$((VALID_SKILLS + 1))
            fi
        done

        if [ "$VERBOSE" = true ]; then
            echo -e "${CYAN}Skills found:${NC}"
            ls -d "$SKILLS_DIR"/gco-*/ 2>/dev/null | sed 's/^/  /' || true
            echo ""
        fi

        if [ "$VALID_SKILLS" -ge 10 ]; then
            check "pass" "Skills: $VALID_SKILLS/$FOUND_SKILLS available"
        elif [ "$VALID_SKILLS" -gt 0 ]; then
            check "warn" "Skills: $VALID_SKILLS/$FOUND_SKILLS available (some may be missing)"
            add_issue "Skills partially deployed" "Re-run: bash Haunt/scripts/setup-haunt.sh"
        else
            check "fail" "Skills: No valid skills found"
            add_issue "Skills not deployed" "Run: bash Haunt/scripts/setup-haunt.sh"
        fi
    else
        check "fail" "Skills: Directory not found"
        add_issue "Skills directory missing" "Run: bash Haunt/scripts/setup-haunt.sh"
    fi
fi

# 3. MCP Server Connectivity Check
if [ "$QUICK" = false ]; then
    # macOS path
    MCP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

    # Linux path (alternative)
    if [ ! -f "$MCP_CONFIG" ]; then
        MCP_CONFIG="$HOME/.config/Claude/claude_desktop_config.json"
    fi

    if [ -f "$MCP_CONFIG" ]; then
        CONTEXT7=$(grep "context7" "$MCP_CONFIG" 2>/dev/null | wc -l | tr -d ' ')
        MEMORY=$(grep -E "agent_memory|memory" "$MCP_CONFIG" 2>/dev/null | wc -l | tr -d ' ')
        PLAYWRIGHT=$(grep -E "playwright|browser" "$MCP_CONFIG" 2>/dev/null | wc -l | tr -d ' ')

        CONNECTED=0
        SERVERS=""

        if [ "$CONTEXT7" -gt 0 ]; then
            CONNECTED=$((CONNECTED + 1))
            SERVERS="$SERVERS context7"
        fi

        if [ "$MEMORY" -gt 0 ]; then
            CONNECTED=$((CONNECTED + 1))
            SERVERS="$SERVERS agent_memory"
        fi

        if [ "$PLAYWRIGHT" -gt 0 ]; then
            CONNECTED=$((CONNECTED + 1))
            SERVERS="$SERVERS playwright"
        fi

        if [ "$VERBOSE" = true ]; then
            echo -e "${CYAN}MCP Configuration:${NC}"
            echo "  Config file: $MCP_CONFIG"
            echo "  Servers configured:$SERVERS"
            if [ "$CONNECTED" -lt 3 ]; then
                echo "  Missing servers: $([ "$CONTEXT7" -eq 0 ] && echo -n "context7 ")$([ "$MEMORY" -eq 0 ] && echo -n "agent_memory ")$([ "$PLAYWRIGHT" -eq 0 ] && echo -n "playwright")"
            fi
            echo ""
        fi

        if [ "$CONNECTED" -ge 2 ]; then
            check "pass" "MCP:$SERVERS connected ($CONNECTED/3)"
        elif [ "$CONNECTED" -eq 1 ]; then
            check "warn" "MCP:$SERVERS connected ($CONNECTED/3 - some servers missing)"
            add_issue "MCP servers partially configured" "Install missing MCP servers (optional). See: Haunt/docs/BROWSER-MCP-SETUP.md"
        else
            check "warn" "MCP: No servers configured (optional feature)"
            add_issue "MCP servers not configured" "MCP servers are optional but recommended. See: Haunt/docs/BROWSER-MCP-SETUP.md"
        fi
    else
        check "warn" "MCP: Configuration file not found"
        add_issue "MCP configuration missing" "Claude Code may need configuration. See: Haunt/docs/BROWSER-MCP-SETUP.md"
    fi
fi

# 4. Agent Deployment Verification
if [ "$QUICK" = false ] || [ "$QUICK" = true ]; then
    AGENTS_DIR="$HOME/.claude/agents"

    if [ -d "$AGENTS_DIR" ]; then
        FOUND_AGENTS=$(ls "$AGENTS_DIR"/gco-*.md 2>/dev/null | wc -l | tr -d ' ')
        VALID_AGENTS=0

        for agent_file in "$AGENTS_DIR"/gco-*.md; do
            if [ -f "$agent_file" ] && head -n 5 "$agent_file" 2>/dev/null | grep -q "^---$"; then
                VALID_AGENTS=$((VALID_AGENTS + 1))
            fi
        done

        if [ "$VERBOSE" = true ]; then
            echo -e "${CYAN}Agents found:${NC}"
            ls "$AGENTS_DIR"/gco-*.md 2>/dev/null | sed 's/^/  /' || true
            echo ""
        fi

        if [ "$VALID_AGENTS" -ge 5 ]; then
            check "pass" "Agents: $VALID_AGENTS/$FOUND_AGENTS deployed"
        elif [ "$VALID_AGENTS" -gt 0 ]; then
            check "warn" "Agents: $VALID_AGENTS/$FOUND_AGENTS deployed (expected at least 5 core agents)"
            add_issue "Agents partially deployed" "Re-run: bash Haunt/scripts/setup-haunt.sh"
        else
            check "fail" "Agents: No valid agents found"
            add_issue "Agents not deployed" "Run: bash Haunt/scripts/setup-haunt.sh"
        fi
    else
        check "fail" "Agents: Directory not found"
        add_issue "Agents directory missing" "Run: bash Haunt/scripts/setup-haunt.sh"
    fi
fi

# 5. Directory Structure Validation
if [ "$QUICK" = false ]; then
    HAUNT_DIR=".haunt"

    if [ -d "$HAUNT_DIR" ]; then
        MISSING_DIRS=""

        [ ! -d "$HAUNT_DIR/plans" ] && MISSING_DIRS="$MISSING_DIRS plans"
        [ ! -d "$HAUNT_DIR/completed" ] && MISSING_DIRS="$MISSING_DIRS completed"
        [ ! -d "$HAUNT_DIR/progress" ] && MISSING_DIRS="$MISSING_DIRS progress"
        [ ! -d "$HAUNT_DIR/tests" ] && MISSING_DIRS="$MISSING_DIRS tests"
        [ ! -d "$HAUNT_DIR/docs" ] && MISSING_DIRS="$MISSING_DIRS docs"

        if [ "$VERBOSE" = true ]; then
            echo -e "${CYAN}Directory structure:${NC}"
            ls -d "$HAUNT_DIR"/*/ 2>/dev/null | sed 's/^/  /' || true
            echo ""
        fi

        if [ -z "$MISSING_DIRS" ]; then
            if [ -f "$HAUNT_DIR/plans/roadmap.md" ]; then
                check "pass" "Directories: .haunt/ structure valid"
            else
                check "warn" "Directories: Structure exists, roadmap.md missing"
                add_issue ".haunt/plans/roadmap.md missing" "Initialize with: /seance"
            fi
        else
            check "warn" "Directories: Missing subdirectories:$MISSING_DIRS"
            add_issue ".haunt/ subdirectories missing" "Run: bash Haunt/scripts/setup-haunt.sh --project-only"
        fi
    else
        check "warn" "Directories: .haunt/ not found (run in project root)"
        add_issue ".haunt/ directory not found" "Run this command from project root, or initialize with: /seance"
    fi
fi

# 6. Commands Availability Check
if [ "$QUICK" = false ]; then
    COMMANDS_DIR="$HOME/.claude/commands"

    if [ -d "$COMMANDS_DIR" ]; then
        # Count all commands (gco-* and legacy non-prefixed)
        FOUND_COMMANDS=$(ls "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
        GCO_COMMANDS=$(ls "$COMMANDS_DIR"/gco-*.md 2>/dev/null | wc -l | tr -d ' ')

        if [ "$VERBOSE" = true ]; then
            echo -e "${CYAN}Commands found:${NC}"
            ls "$COMMANDS_DIR"/*.md 2>/dev/null | sed 's/^/  /' || true
            echo ""
        fi

        if [ "$FOUND_COMMANDS" -ge 13 ]; then
            check "pass" "Commands: $FOUND_COMMANDS slash commands available ($GCO_COMMANDS gco-prefixed)"
        elif [ "$FOUND_COMMANDS" -gt 0 ]; then
            check "warn" "Commands: $FOUND_COMMANDS slash commands found (expected at least 13)"
            add_issue "Commands partially deployed" "Re-run: bash Haunt/scripts/setup-haunt.sh"
        else
            check "fail" "Commands: No commands found"
            add_issue "Commands not deployed" "Run: bash Haunt/scripts/setup-haunt.sh"
        fi
    else
        check "fail" "Commands: Directory not found"
        add_issue "Commands directory missing" "Run: bash Haunt/scripts/setup-haunt.sh"
    fi
fi

# Summary
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$CHECKS_FAILED" -gt 0 ]; then
    echo -e "${RED}💀 The spirits are silent. Haunt is not installed.${NC}"
    EXIT_CODE=2
elif [ "$CHECKS_WARNED" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  The spirits are present but weakened.${NC}"
    echo -e "${YELLOW}   Some components need attention.${NC}"
    EXIT_CODE=1
else
    echo -e "${GREEN}🌙 The spirits are strong and responsive.${NC}"
    echo -e "${GREEN}   Haunt is properly installed and operational.${NC}"
    EXIT_CODE=0
fi

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Issues and troubleshooting
if [ ${#ISSUES[@]} -gt 0 ]; then
    echo -e "${YELLOW}Issues detected:${NC}"
    count=1
    for issue in "${ISSUES[@]}"; do
        title="${issue%%|*}"
        fix="${issue#*|}"
        echo -e "${YELLOW}$count. $title${NC}"
        echo -e "   → $fix"
        echo ""
        count=$((count + 1))
    done

    echo "Troubleshooting:"
    echo "  bash Haunt/scripts/setup-haunt.sh --verify"
    echo "  cat Haunt/SETUP-GUIDE.md"
    echo ""
elif [ "$QUICK" = true ]; then
    echo "The core spirits are present."
    echo ""
else
    echo "Next steps:"
    echo "  /seance          # Start a new haunting"
    echo "  /haunt           # View current status"
    echo "  /summon dev      # Call forth a specific spirit"
    echo ""
fi

exit $EXIT_CODE
