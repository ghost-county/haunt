#!/bin/bash
#
# bind.sh - Create custom workflow rule overrides
#
# Usage: bash Haunt/scripts/bind.sh <rule-name> <override-file> [options]
#
# This script creates project-specific or user-global rule overrides
# that supersede Haunt's default workflow rules.

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
VALIDATE_ONLY=false
FORCE=false

# Show usage
show_help() {
    cat << EOF
Bind - Create Custom Workflow Rule Overrides

Usage:
  bash Haunt/scripts/bind.sh <rule-name> <override-file> [options]

Arguments:
  rule-name       Name of rule to override (e.g., gco-commit-conventions)
  override-file   Path to custom rule markdown file

Options:
  --scope=project       Apply to current project only (default)
  --scope=user          Apply globally to all user projects
  --validate            Validate rule format without applying
  --dry-run             Preview binding without creating it
  --force               Skip validation and confirmation prompts
  --help                Show this help message

Examples:
  # Bind custom commit conventions for project
  bash Haunt/scripts/bind.sh gco-commit-conventions ./custom-commits.md

  # Preview binding
  bash Haunt/scripts/bind.sh gco-commit-conventions ./custom-commits.md --dry-run

  # Validate format only
  bash Haunt/scripts/bind.sh gco-commit-conventions ./custom-commits.md --validate

  # Apply globally
  bash Haunt/scripts/bind.sh gco-roadmap-format ./custom-roadmap.md --scope=user

EOF
}

# Parse arguments
RULE_NAME=""
OVERRIDE_FILE=""

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
        --validate)
            VALIDATE_ONLY=true
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
            elif [[ -z "$OVERRIDE_FILE" ]]; then
                OVERRIDE_FILE="$1"
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

if [[ -z "$OVERRIDE_FILE" ]]; then
    echo -e "${RED}Error: override-file is required${NC}"
    show_help
    exit 1
fi

# Validate scope
if [[ "$SCOPE" != "project" && "$SCOPE" != "user" ]]; then
    echo -e "${RED}Error: scope must be 'project' or 'user'${NC}"
    exit 1
fi

# Check override file exists
if [[ ! -f "$OVERRIDE_FILE" ]]; then
    echo -e "${RED}Error: Override file not found: $OVERRIDE_FILE${NC}"
    exit 1
fi

# Check override file is readable
if [[ ! -r "$OVERRIDE_FILE" ]]; then
    echo -e "${RED}Error: Cannot read override file: $OVERRIDE_FILE${NC}"
    exit 1
fi

# Validate markdown format
validate_markdown() {
    local file="$1"

    # Check file extension
    if [[ ! "$file" =~ \.md$ ]]; then
        echo -e "${YELLOW}Warning: File should have .md extension${NC}"
        return 1
    fi

    # Check file is not empty
    if [[ ! -s "$file" ]]; then
        echo -e "${RED}Error: File is empty${NC}"
        return 1
    fi

    # Check has markdown heading
    if ! grep -q '^#' "$file"; then
        echo -e "${YELLOW}Warning: File should have at least one markdown heading${NC}"
        return 1
    fi

    return 0
}

# Check rule naming convention
check_naming() {
    local name="$1"

    if [[ ! "$name" =~ ^gco- ]]; then
        echo -e "${YELLOW}Warning: Rule name should start with 'gco-' prefix${NC}"
        echo -e "  Got: $name"
        echo -e "  Recommend: gco-$name"
        return 1
    fi

    return 0
}

# Validate override file
echo -e "${BLUE}Validating override file...${NC}"

VALIDATION_PASSED=true

if ! validate_markdown "$OVERRIDE_FILE"; then
    VALIDATION_PASSED=false
fi

if ! check_naming "$RULE_NAME"; then
    VALIDATION_PASSED=false
fi

if [[ "$VALIDATION_PASSED" = false && "$FORCE" = false ]]; then
    echo -e "${RED}Validation failed. Use --force to skip validation.${NC}"
    exit 1
fi

if [[ "$VALIDATE_ONLY" = true ]]; then
    echo -e "${GREEN}Validation complete.${NC}"
    exit 0
fi

# Determine binding directory
if [[ "$SCOPE" = "project" ]]; then
    BINDING_DIR=".haunt/bindings"
else
    BINDING_DIR="$HOME/.haunt/bindings"
fi

BINDING_FILE="$BINDING_DIR/$RULE_NAME.md"
BINDING_INDEX="$BINDING_DIR/index.txt"
BACKUP_DIR="$BINDING_DIR/.backup"

# Create binding directory if needed
if [[ ! -d "$BINDING_DIR" ]]; then
    if [[ "$DRY_RUN" = false ]]; then
        echo -e "${BLUE}Creating binding directory: $BINDING_DIR${NC}"
        mkdir -p "$BINDING_DIR"
    else
        echo -e "${BLUE}Would create binding directory: $BINDING_DIR${NC}"
    fi
fi

# Check if binding already exists
if [[ -f "$BINDING_FILE" ]]; then
    echo -e "${YELLOW}Warning: Binding already exists: $BINDING_FILE${NC}"

    if [[ "$FORCE" = false && "$DRY_RUN" = false ]]; then
        read -p "Overwrite existing binding? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Aborted.${NC}"
            exit 0
        fi

        # Create backup
        if [[ ! -d "$BACKUP_DIR" ]]; then
            mkdir -p "$BACKUP_DIR"
        fi

        TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
        BACKUP_FILE="$BACKUP_DIR/$RULE_NAME.md.$TIMESTAMP"

        echo -e "${BLUE}Creating backup: $BACKUP_FILE${NC}"
        cp "$BINDING_FILE" "$BACKUP_FILE"
    fi
fi

# Show preview
echo -e "\n${GREEN}Binding Preview${NC}"
echo -e "  Rule: $RULE_NAME"
echo -e "  Override file: $OVERRIDE_FILE"
echo -e "  Scope: $SCOPE"
echo -e "  Target: $BINDING_FILE"

if [[ -f "$BINDING_FILE" ]]; then
    echo -e "  Action: ${YELLOW}Overwrite existing binding${NC}"
else
    echo -e "  Action: ${GREEN}Create new binding${NC}"
fi

echo -e "\n${BLUE}Priority after binding:${NC}"
echo -e "  Agents will use: $BINDING_FILE"

# Dry run exits here
if [[ "$DRY_RUN" = true ]]; then
    echo -e "\n${BLUE}Dry run complete. No changes made.${NC}"
    exit 0
fi

# Confirmation prompt (unless force)
if [[ "$FORCE" = false ]]; then
    echo
    read -p "Create binding? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Aborted.${NC}"
        exit 0
    fi
fi

# Create binding
echo -e "\n${BLUE}Creating binding...${NC}"

# Copy override file to binding location
cp "$OVERRIDE_FILE" "$BINDING_FILE"
echo -e "${GREEN}Created: $BINDING_FILE${NC}"

# Update index
if [[ ! -f "$BINDING_INDEX" ]]; then
    touch "$BINDING_INDEX"
fi

# Add to index if not already present
if ! grep -q "^$RULE_NAME$" "$BINDING_INDEX" 2>/dev/null; then
    echo "$RULE_NAME" >> "$BINDING_INDEX"
    echo -e "${GREEN}Updated index: $BINDING_INDEX${NC}"
fi

# Add metadata comment to binding file
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
cat > "${BINDING_FILE}.tmp" << EOF
<!--
Bound: $TIMESTAMP
Scope: $SCOPE
Source: $OVERRIDE_FILE
-->

EOF

cat "$BINDING_FILE" >> "${BINDING_FILE}.tmp"
mv "${BINDING_FILE}.tmp" "$BINDING_FILE"

echo -e "\n${GREEN}✓ Binding created successfully${NC}"
echo -e "\nAgents will now use: ${BLUE}$BINDING_FILE${NC}"
echo -e "\nTo remove: ${YELLOW}/unbind $RULE_NAME${NC}"
echo -e "To verify: ${YELLOW}/bind-list${NC}"
