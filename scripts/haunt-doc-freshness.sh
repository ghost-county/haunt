#!/bin/bash
set -euo pipefail

# Check freshness of all Haunt skill files
SKILLS_DIR="${1:-$HOME/.claude/skills}"
STALE_DAYS="${2:-90}"
NOW=$(date +%s)
STALE_COUNT=0
MISSING_COUNT=0
FRESH_COUNT=0

echo "=== Haunt Skill Freshness Check ==="
echo "Threshold: $STALE_DAYS days"
echo ""

for skill_dir in "$SKILLS_DIR"/gco-*/; do
    skill="$skill_dir/SKILL.md"
    if [[ ! -f "$skill" ]]; then
        continue
    fi

    SKILL_NAME=$(basename "$skill_dir")
    VERIFIED=$(grep "^last-verified:" "$skill" 2>/dev/null | awk '{print $2}' | tr -d '"' | tr -d "'")

    if [[ -z "$VERIFIED" ]]; then
        echo "  MISSING  $SKILL_NAME — no last-verified date"
        MISSING_COUNT=$((MISSING_COUNT + 1))
        continue
    fi

    # macOS date parsing
    if [[ "$(uname)" == "Darwin" ]]; then
        VERIFIED_EPOCH=$(date -j -f "%Y-%m-%d" "$VERIFIED" +%s 2>/dev/null || echo 0)
    else
        VERIFIED_EPOCH=$(date -d "$VERIFIED" +%s 2>/dev/null || echo 0)
    fi

    if [[ "$VERIFIED_EPOCH" -eq 0 ]]; then
        echo "  INVALID  $SKILL_NAME — could not parse date: $VERIFIED"
        MISSING_COUNT=$((MISSING_COUNT + 1))
        continue
    fi

    AGE_DAYS=$(( (NOW - VERIFIED_EPOCH) / 86400 ))

    if [[ "$AGE_DAYS" -gt "$STALE_DAYS" ]]; then
        echo "  STALE    $SKILL_NAME — $AGE_DAYS days old (verified $VERIFIED)"
        STALE_COUNT=$((STALE_COUNT + 1))
    else
        echo "  FRESH    $SKILL_NAME — $AGE_DAYS days old (verified $VERIFIED)"
        FRESH_COUNT=$((FRESH_COUNT + 1))
    fi
done

echo ""
echo "=== Summary ==="
echo "Fresh:   $FRESH_COUNT"
echo "Stale:   $STALE_COUNT"
echo "Missing: $MISSING_COUNT"

if [[ "$STALE_COUNT" -gt 0 ]] || [[ "$MISSING_COUNT" -gt 0 ]]; then
    echo ""
    echo "Action: Review stale/missing skills and update last-verified dates."
    exit 1
fi

echo "All skills are current."
exit 0
