#!/bin/bash
# validate-agents.sh - Validate agent definitions (Ghost County/Haunt Framework)
# Checks:
# 1. Line count (<= 100 lines)
# 2. YAML frontmatter exists with required fields (name, description)

AGENTS_DIR="${AGENTS_DIR:-Haunt/agents}"
MAX_LINES=100
EXIT_CODE=0

echo "Divining agent spirit signatures in $AGENTS_DIR..."
echo ""

for agent_file in "$AGENTS_DIR"/*.md; do
    [ ! -f "$agent_file" ] && echo "No agent files found in $AGENTS_DIR" && exit 1

    filename=$(basename "$agent_file")

    # Check line count
    line_count=$(grep -cve '^\s*$' "$agent_file")

    if [ "$line_count" -le "$MAX_LINES" ]; then
        echo "$filename: $line_count lines [PASS]"
    else
        echo "$filename: $line_count lines [FAIL - exceeds $MAX_LINES]"
        EXIT_CODE=1
    fi

    # Check for YAML frontmatter
    has_frontmatter=$(head -n 1 "$agent_file" | grep -c '^---$')

    if [ "$has_frontmatter" -eq 0 ]; then
        echo "$filename: Missing YAML frontmatter [FAIL]"
        EXIT_CODE=1
    else
        # Check for required fields
        has_name=$(grep -c '^name:' "$agent_file")
        has_description=$(grep -c '^description:' "$agent_file")

        if [ "$has_name" -eq 0 ]; then
            echo "$filename: Missing 'name' field in frontmatter [FAIL]"
            EXIT_CODE=1
        fi

        if [ "$has_description" -eq 0 ]; then
            echo "$filename: Missing 'description' field in frontmatter [FAIL]"
            EXIT_CODE=1
        fi

        if [ "$has_name" -gt 0 ] && [ "$has_description" -gt 0 ]; then
            echo "$filename: YAML frontmatter valid [PASS]"
        fi
    fi

    echo ""
done

[ $EXIT_CODE -eq 0 ] && echo "All agent spirits bound successfully." || echo "Some agent spirits failed binding ritual."

exit $EXIT_CODE
