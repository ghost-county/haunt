#!/bin/bash
#
# unbind.sh - Remove custom workflow rule overrides
#
# Usage: bash Haunt/scripts/unbind.sh <rule-name> [options]
#
# This script removes project-specific or user-global rule overrides,
# causing agents to revert to Haunt default rules.

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SCOPE="project"
DRY_RUN=false
BACKUP=false
FORCE=false

# Show usage
show_help() {
    cat << EOF
Unbind - Remove Custom Rule Overrides

Usage:
  bash Haunt/scripts/unbind.sh <rule-name> [options]

Arguments:
  rule-name       Name of bound rule to remove

Options:
  --scope=project       Remove project binding only (default)
  --scope=user          Remove user-global binding
  --scope=both          Remove from both project and user
  --backup              Create backup before removing
  --dry-run             Preview what would be removed
  --force               Skip confirmation prompt
  --help                Show this help message

Examples:
  # Remove project binding
  bash Haunt/scripts/unbind.sh gco-commit-conventions

  # Preview removal
  bash Haunt/scripts/unbind.sh gco-commit-conventions --dry-run

  # Remove user-global binding
  bash Haunt/scripts/unbind.sh gco-roadmap-format --scope=user

  # Remove from both scopes with backup
  bash Haunt/scripts/unbind.sh gco-session-startup --scope=both --backup

EOF
}

# Parse arguments
RULE_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_help
            exit 0
            ;;
        --scope=*)
            SCOPE="${1#*=}"
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --backup)
            BACKUP=true
            ;;
        --force)
            FORCE=true
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$RULE_NAME" ]]; then
                RULE_NAME="$1"
            else
                echo -e "${RED}Error: Too many arguments${NC}"
                show_help
                exit 1
            fi
            ;;
    esac
    shift
done

# Validate required arguments
if [[ -z "$RULE_NAME" ]]; then
    echo -e "${RED}Error: rule-name is required${NC}"
    show_help
    exit 1
fi

# Validate scope
if [[ "$SCOPE" != "project" && "$SCOPE" != "user" && "$SCOPE" != "both" ]]; then
    echo -e "${RED}Error: scope must be 'project', 'user', or 'both'${NC}"
    exit 1
fi

# Determine binding locations
PROJECT_BINDING=".haunt/bindings/$RULE_NAME.md"
USER_BINDING="$HOME/.haunt/bindings/$RULE_NAME.md"

# Check which bindings exist
PROJECT_EXISTS=false
USER_EXISTS=false

if [[ -f "$PROJECT_BINDING" ]]; then
    PROJECT_EXISTS=true
fi

if [[ -f "$USER_BINDING" ]]; then
    USER_EXISTS=true
fi

# Determine what to remove based on scope
TO_REMOVE=()

if [[ "$SCOPE" = "project" || "$SCOPE" = "both" ]]; then
    if [[ "$PROJECT_EXISTS" = true ]]; then
        TO_REMOVE+=("$PROJECT_BINDING")
    fi
fi

if [[ "$SCOPE" = "user" || "$SCOPE" = "both" ]]; then
    if [[ "$USER_EXISTS" = true ]]; then
        TO_REMOVE+=("$USER_BINDING")
    fi
fi

# Check if anything to remove
if [[ ${#TO_REMOVE[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No bindings found for: $RULE_NAME (scope: $SCOPE)${NC}"

    # Show what exists
    if [[ "$PROJECT_EXISTS" = true || "$USER_EXISTS" = true ]]; then
        echo -e "\n${BLUE}Bindings that exist:${NC}"
        if [[ "$PROJECT_EXISTS" = true ]]; then
            echo -e "  Project: $PROJECT_BINDING"
        fi
        if [[ "$USER_EXISTS" = true ]]; then
            echo -e "  User: $USER_BINDING"
        fi
        echo -e "\nUse --scope=both to remove all bindings"
    fi

    exit 1
fi

# Show preview
echo -e "${BLUE}Unbind Preview${NC}"
echo -e "  Rule: $RULE_NAME"
echo -e "  Scope: $SCOPE"
echo

for binding in "${TO_REMOVE[@]}"; do
    if [[ "$binding" = "$PROJECT_BINDING" ]]; then
        scope_label="project"
    else
        scope_label="user"
    fi

    echo -e "${YELLOW}Will remove ($scope_label):${NC}"
    echo -e "  Location: $binding"

    # Show file info
    if [[ -f "$binding" ]]; then
        size=$(du -h "$binding" | cut -f1)
        modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$binding" 2>/dev/null || stat -c "%y" "$binding" 2>/dev/null | cut -d'.' -f1)
        echo -e "  Size: $size"
        echo -e "  Modified: $modified"
    fi
    echo
done

# Determine fallback
echo -e "${BLUE}After removal:${NC}"

if [[ "$SCOPE" = "project" && "$USER_EXISTS" = true ]]; then
    echo -e "  Agents will use: ${GREEN}$USER_BINDING${NC} (user binding)"
elif [[ "$SCOPE" = "user" && "$PROJECT_EXISTS" = true ]]; then
    echo -e "  Agents will use: ${GREEN}$PROJECT_BINDING${NC} (project binding)"
else
    # Find Haunt default
    HAUNT_DEFAULT="Haunt/rules/$RULE_NAME.md"
    GLOBAL_DEFAULT="$HOME/.claude/rules/$RULE_NAME.md"

    if [[ -f "$HAUNT_DEFAULT" ]]; then
        echo -e "  Agents will use: ${GREEN}$HAUNT_DEFAULT${NC} (Haunt default)"
    elif [[ -f "$GLOBAL_DEFAULT" ]]; then
        echo -e "  Agents will use: ${GREEN}$GLOBAL_DEFAULT${NC} (global rule)"
    else
        echo -e "  ${YELLOW}No fallback rule found - agents may not have this rule${NC}"
    fi
fi

# Dry run exits here
if [[ "$DRY_RUN" = true ]]; then
    echo -e "\n${BLUE}Dry run complete. No changes made.${NC}"
    exit 0
fi

# Confirmation prompt (unless force)
if [[ "$FORCE" = false ]]; then
    echo
    read -p "Remove binding(s)? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Aborted.${NC}"
        exit 0
    fi
fi

# Create backups if requested
if [[ "$BACKUP" = true ]]; then
    echo -e "\n${BLUE}Creating backups...${NC}"

    for binding in "${TO_REMOVE[@]}"; do
        binding_dir=$(dirname "$binding")
        backup_dir="$binding_dir/.backup"
        mkdir -p "$backup_dir"

        timestamp=$(date +%Y-%m-%d-%H%M%S)
        backup_file="$backup_dir/$(basename "$binding").$timestamp"

        cp "$binding" "$backup_file"
        echo -e "${GREEN}Backup created: $backup_file${NC}"
    done
fi

# Remove bindings
echo -e "\n${BLUE}Removing bindings...${NC}"

for binding in "${TO_REMOVE[@]}"; do
    rm -f "$binding"
    echo -e "${GREEN}Removed: $binding${NC}"

    # Update index
    binding_dir=$(dirname "$binding")
    index_file="$binding_dir/index.txt"

    if [[ -f "$index_file" ]]; then
        # Remove from index
        grep -v "^$RULE_NAME$" "$index_file" > "${index_file}.tmp" || true
        mv "${index_file}.tmp" "$index_file"

        # Remove index if empty
        if [[ ! -s "$index_file" ]]; then
            rm -f "$index_file"
        fi
    fi
done

echo -e "\n${GREEN}✓ Unbind complete${NC}"

# Show what agents will use now
echo -e "\n${BLUE}Agents now use:${NC}"

# Check priority order
if [[ "$SCOPE" = "project" || "$SCOPE" = "both" ]]; then
    if [[ -f "$USER_BINDING" ]]; then
        echo -e "  ${GREEN}$USER_BINDING${NC} (user binding)"
    fi
fi

if [[ ! -f "$USER_BINDING" || "$SCOPE" = "both" ]]; then
    # Check for Haunt default
    HAUNT_DEFAULT="Haunt/rules/$RULE_NAME.md"
    GLOBAL_DEFAULT="$HOME/.claude/rules/$RULE_NAME.md"

    if [[ -f "$HAUNT_DEFAULT" ]]; then
        echo -e "  ${GREEN}$HAUNT_DEFAULT${NC} (Haunt default)"
    elif [[ -f "$GLOBAL_DEFAULT" ]]; then
        echo -e "  ${GREEN}$GLOBAL_DEFAULT${NC} (global rule)"
    fi
fi

# Show restore command if backup created
if [[ "$BACKUP" = true ]]; then
    echo -e "\n${YELLOW}To restore from backup:${NC}"
    for binding in "${TO_REMOVE[@]}"; do
        binding_dir=$(dirname "$binding")
        backup_dir="$binding_dir/.backup"
        echo -e "  /bind $RULE_NAME $backup_dir/$(basename "$binding").TIMESTAMP"
    done
fi
