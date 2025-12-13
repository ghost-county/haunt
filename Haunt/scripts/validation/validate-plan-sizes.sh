#!/bin/bash
# validate-plan-sizes.sh - Check that plan files don't exceed size limits (Ghost County/Haunt)

PLANS_DIR="${PLANS_DIR:-.haunt/plans}"
MAX_LINES=1000
EXIT_CODE=0
WARNINGS=0

echo "Divining haunting manifest sizes in $PLANS_DIR..."
echo ""

if [[ ! -d "$PLANS_DIR" ]]; then
    echo "Plans directory not found: $PLANS_DIR"
    exit 0
fi

for plan_file in "$PLANS_DIR"/*.md; do
    [[ ! -f "$plan_file" ]] && continue

    line_count=$(wc -l < "$plan_file" | tr -d ' ')
    filename=$(basename "$plan_file")

    if [[ $line_count -gt $MAX_LINES ]]; then
        echo "$filename: $line_count lines [FAIL - exceeds $MAX_LINES]"
        EXIT_CODE=1
    elif [[ $line_count -gt 800 ]]; then
        echo "$filename: $line_count lines [WARNING - approaching limit]"
        ((WARNINGS++))
    else
        echo "$filename: $line_count lines [OK]"
    fi
done

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
    if [[ $WARNINGS -gt 0 ]]; then
        echo "All manifests within bounds, but $WARNINGS haunting(s) approaching threshold."
        echo "Consider exorcising completed hauntings to the crypt."
    else
        echo "All haunting manifests within size limits."
    fi
else
    echo "Some haunting manifests exceed $MAX_LINES lines!"
    echo ""
    echo "To exorcise overgrown manifestations:"
    echo "  1. Archive completed (🟢) hauntings to .haunt/completed/"
    echo "  2. Split large manifests by haunting domain"
    echo "  3. Move detailed analysis to completed/ with ethereal links"
fi

exit $EXIT_CODE
