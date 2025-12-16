#!/bin/bash
#
# bind-list.sh - Show active rule overrides
#
# Usage: bash Haunt/scripts/bind-list.sh [options]
#
# Display all active custom rule bindings and their priority order.

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SCOPE="both"
VERBOSE=false
SPECIFIC_RULE=""

# Show usage
show_help() {
    cat << EOF
Bind-List - Show Active Rule Overrides

Usage:
  bash Haunt/scripts/bind-list.sh [options]

Options:
  --scope=project       Show project bindings only
  --scope=user          Show user-global bindings only
  --scope=both          Show all bindings (default)
  --verbose             Include detailed information
  --rule=<name>         Show details for specific rule
  --help                Show this help message

Examples:
  # List all bindings
  bash Haunt/scripts/bind-list.sh

  # Show project bindings only
  bash Haunt/scripts/bind-list.sh --scope=project

  # Detailed view
  bash Haunt/scripts/bind-list.sh --verbose

  # Check specific rule
  bash Haunt/scripts/bind-list.sh --rule=gco-commit-conventions

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_help
            exit 0
            ;;
        --scope=*)
            SCOPE="${1#*=}"
            ;;
        --verbose)
            VERBOSE=true
            ;;
        --rule=*)
            SPECIFIC_RULE="${1#*=}"
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
        *)
            echo -e "${RED}Error: Unexpected argument $1${NC}"
            show_help
            exit 1
            ;;
    esac
    shift
done

# Validate scope
if [[ "$SCOPE" != "project" && "$SCOPE" != "user" && "$SCOPE" != "both" ]]; then
    echo -e "${RED}Error: scope must be 'project', 'user', or 'both'${NC}"
    exit 1
fi

# Binding directories
PROJECT_BINDINGS=".haunt/bindings"
USER_BINDINGS="$HOME/.haunt/bindings"

# Collect bindings
PROJECT_FILES=()
USER_FILES=()

if [[ "$SCOPE" = "project" || "$SCOPE" = "both" ]]; then
    if [[ -d "$PROJECT_BINDINGS" ]]; then
        while IFS= read -r -d '' file; do
            PROJECT_FILES+=("$file")
        done < <(find "$PROJECT_BINDINGS" -maxdepth 1 -name "*.md" -type f -print0 2>/dev/null || true)
    fi
fi

if [[ "$SCOPE" = "user" || "$SCOPE" = "both" ]]; then
    if [[ -d "$USER_BINDINGS" ]]; then
        while IFS= read -r -d '' file; do
            USER_FILES+=("$file")
        done < <(find "$USER_BINDINGS" -maxdepth 1 -name "*.md" -type f -print0 2>/dev/null || true)
    fi
fi

# Handle specific rule query
if [[ -n "$SPECIFIC_RULE" ]]; then
    PROJECT_BINDING="$PROJECT_BINDINGS/$SPECIFIC_RULE.md"
    USER_BINDING="$USER_BINDINGS/$SPECIFIC_RULE.md"

    ACTIVE_BINDING=""
    ACTIVE_SCOPE=""
    PRIORITY=""

    # Determine active binding (project > user)
    if [[ -f "$PROJECT_BINDING" ]]; then
        ACTIVE_BINDING="$PROJECT_BINDING"
        ACTIVE_SCOPE="project"
        PRIORITY="1 (highest)"
    elif [[ -f "$USER_BINDING" ]]; then
        ACTIVE_BINDING="$USER_BINDING"
        ACTIVE_SCOPE="user"
        PRIORITY="2"
    fi

    if [[ -z "$ACTIVE_BINDING" ]]; then
        echo -e "${YELLOW}No binding found for: $SPECIFIC_RULE${NC}"
        echo
        echo -e "Rule may use Haunt default:"
        echo -e "  Haunt/rules/$SPECIFIC_RULE.md"
        echo -e "  ~/.claude/rules/$SPECIFIC_RULE.md"
        exit 1
    fi

    # Show specific rule details
    echo -e "${GREEN}Rule: $SPECIFIC_RULE${NC}"
    echo
    echo -e "${BLUE}Active Binding:${NC}"
    echo -e "  Location: ${GREEN}$ACTIVE_BINDING${NC} ($ACTIVE_SCOPE scope)"
    echo -e "  Priority: $PRIORITY"

    # File details
    if [[ -f "$ACTIVE_BINDING" ]]; then
        size=$(du -h "$ACTIVE_BINDING" | cut -f1)
        created=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$ACTIVE_BINDING" 2>/dev/null || stat -c "%y" "$ACTIVE_BINDING" 2>/dev/null | cut -d'.' -f1)
        modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$ACTIVE_BINDING" 2>/dev/null || stat -c "%y" "$ACTIVE_BINDING" 2>/dev/null | cut -d'.' -f1)

        echo -e "  Size: $size"
        echo -e "  Created: $created"
        echo -e "  Modified: $modified"
    fi

    # Show what it overrides
    echo
    echo -e "${BLUE}Overrides:${NC}"

    # Check for lower-priority bindings
    if [[ "$ACTIVE_SCOPE" = "project" && -f "$USER_BINDING" ]]; then
        echo -e "  $USER_BINDING (priority 2, user)"
    fi

    # Check for Haunt default
    HAUNT_DEFAULT="Haunt/rules/$SPECIFIC_RULE.md"
    GLOBAL_DEFAULT="$HOME/.claude/rules/$SPECIFIC_RULE.md"

    if [[ -f "$GLOBAL_DEFAULT" ]]; then
        echo -e "  $GLOBAL_DEFAULT (priority 4, global)"
    fi

    if [[ -f "$HAUNT_DEFAULT" ]]; then
        echo -e "  $HAUNT_DEFAULT (priority 5, Haunt default)"
    fi

    # Show what agents load
    echo
    echo -e "${BLUE}Agents Load From:${NC}"
    echo -e "  ${GREEN}$ACTIVE_BINDING${NC} ← ACTIVE"

    echo
    echo -e "To remove: ${YELLOW}/unbind $SPECIFIC_RULE${NC}"

    exit 0
fi

# Count total bindings
TOTAL_COUNT=$((${#PROJECT_FILES[@]} + ${#USER_FILES[@]}))

# Show header
echo -e "${GREEN}Active Rule Bindings${NC}"

if [[ "$VERBOSE" = true ]]; then
    echo -e "${BLUE}(Detailed)${NC}"
fi

echo

# Show empty state
if [[ $TOTAL_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}No custom bindings found.${NC}"
    echo
    echo -e "All agents use Haunt default rules."
    echo
    echo -e "To create a binding: ${BLUE}/bind <rule-name> <override-file>${NC}"
    exit 0
fi

# Show project bindings
if [[ ${#PROJECT_FILES[@]} -gt 0 ]]; then
    echo -e "${BLUE}Project Bindings ($PROJECT_BINDINGS):${NC}"

    for file in "${PROJECT_FILES[@]}"; do
        basename=$(basename "$file")
        rule_name="${basename%.md}"

        if [[ "$VERBOSE" = true ]]; then
            size=$(du -h "$file" | cut -f1)
            created=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d'.' -f1)

            echo -e "  ${GREEN}$basename${NC}"
            echo -e "    Priority: 1 (highest - overrides all)"
            echo -e "    Size: $size"
            echo -e "    Created: $created"

            # Check what it overrides
            HAUNT_DEFAULT="Haunt/rules/$rule_name.md"
            if [[ -f "$HAUNT_DEFAULT" ]]; then
                echo -e "    Overrides: $HAUNT_DEFAULT"
            fi

            echo
        else
            echo -e "  $basename"
        fi
    done

    if [[ "$VERBOSE" = false ]]; then
        echo
    fi
fi

# Show user bindings
if [[ ${#USER_FILES[@]} -gt 0 ]]; then
    echo -e "${BLUE}User Bindings ($USER_BINDINGS):${NC}"

    for file in "${USER_FILES[@]}"; do
        basename=$(basename "$file")
        rule_name="${basename%.md}"

        if [[ "$VERBOSE" = true ]]; then
            size=$(du -h "$file" | cut -f1)
            created=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d'.' -f1)

            echo -e "  ${GREEN}$basename${NC}"
            echo -e "    Priority: 2 (overrides global and Haunt defaults)"
            echo -e "    Size: $size"
            echo -e "    Created: $created"

            # Check what it overrides
            HAUNT_DEFAULT="Haunt/rules/$rule_name.md"
            if [[ -f "$HAUNT_DEFAULT" ]]; then
                echo -e "    Overrides: $HAUNT_DEFAULT"
            fi

            # Check if shadowed by project binding
            PROJECT_BINDING="$PROJECT_BINDINGS/$rule_name.md"
            if [[ -f "$PROJECT_BINDING" ]]; then
                echo -e "    ${YELLOW}Note: Shadowed by higher-priority project binding${NC}"
            fi

            echo
        else
            echo -e "  $basename"
        fi
    done

    if [[ "$VERBOSE" = false ]]; then
        echo
    fi
fi

# Show total
echo -e "${GREEN}Total: $TOTAL_COUNT binding(s)${NC}"

# Show priority explanation
if [[ "$VERBOSE" = true ]]; then
    echo
    echo -e "${BLUE}Priority Order (highest to lowest):${NC}"
    echo -e "  1. Project bindings (.haunt/bindings/)"
    echo -e "  2. User bindings (~/.haunt/bindings/)"
    echo -e "  3. Project rules (.claude/rules/)"
    echo -e "  4. Global rules (~/.claude/rules/)"
    echo -e "  5. Haunt defaults (Haunt/rules/)"
else
    if [[ ${#PROJECT_FILES[@]} -gt 0 && ${#USER_FILES[@]} -gt 0 ]]; then
        echo
        echo -e "${BLUE}Priority:${NC} Project bindings override user bindings."
    fi

    echo
    echo -e "To see details: ${YELLOW}/bind-list --verbose${NC}"
fi
