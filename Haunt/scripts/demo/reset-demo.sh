#!/bin/bash
# Reset Demo State
#
# Purpose: Clean up after Haunt demo presentation
# Usage: bash reset-demo.sh

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Resetting Haunt demo state...${NC}"
echo ""

# Note: This script is a placeholder for future demo state management
# Currently, the demo script is read-only (simulated commands, no actual changes)

echo -e "${GREEN}✓ Demo script is read-only, no cleanup needed${NC}"
echo ""
echo "If you ran actual commands during demo (not recommended):"
echo "  1. Check git status for uncommitted changes"
echo "  2. Review .haunt/plans/roadmap.md for demo artifacts"
echo "  3. Clean up any test data or sample projects"
echo ""
echo -e "${YELLOW}Demo state reset complete.${NC}"
