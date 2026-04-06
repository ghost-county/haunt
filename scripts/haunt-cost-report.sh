#!/bin/bash
set -euo pipefail

# haunt-cost-report.sh
# Reads .haunt/logs/cost-log.jsonl and produces a cost summary report.
#
# Usage:
#   bash haunt-cost-report.sh
#   bash haunt-cost-report.sh /path/to/cost-log.jsonl

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required. Install with: brew install jq"; exit 1; }

LOG_FILE="${1:-.haunt/logs/cost-log.jsonl}"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "No cost data logged yet."
    echo "Run: bash Haunt/scripts/haunt-cost-logger.sh --tokens-in N --tokens-out N"
    exit 0
fi

# Compute all stats in a single jq pass
STATS=$(jq -s '
    if length == 0 then halt_error(1) else . end |
    sort_by(.timestamp) |
    . as $entries |
    ($entries | map(.estimated_cost_usd) | add) as $total |
    ($entries | length) as $n |
    ($entries | map(.estimated_cost_usd) | sort) as $sorted |
    (
        if ($n % 2) == 1
        then $sorted[($n / 2 | floor)]
        else ($sorted[($n / 2) - 1] + $sorted[$n / 2]) / 2
        end
    ) as $median |
    ($total / $n) as $avg |
    {
        n: $n,
        total: $total,
        median: $median,
        avg: $avg,
        entries: [
            $entries[] |
            {
                date: (.timestamp | split("T")[0]),
                session_id: .session_id,
                cost: .estimated_cost_usd,
                model: .model,
                tokens_in: .tokens_in,
                tokens_out: .tokens_out
            }
        ]
    }
' "$LOG_FILE" 2>/dev/null) || { echo "No cost data logged yet."; exit 0; }

# Extract scalars in one pass
read -r SESSION_COUNT TOTAL MEDIAN AVG < <(echo "$STATS" | jq -r '[.n, .total, .median, .avg] | @tsv')

echo "=== Haunt Cost Report ==="
echo ""

printf "Sessions logged: %s\n" "$SESSION_COUNT"
printf "Total estimated cost: \$%s\n" "$(printf '%.2f' "$TOTAL")"
echo ""
echo "Per-session breakdown:"

echo "$STATS" | jq -r '.entries[] |
    "  \(.date) \(.session_id)  $\(.cost | . * 100 | round / 100) (\(.model), \(.tokens_in / 1000 | floor)K in / \(.tokens_out / 1000 | floor)K out)"'

echo ""
echo "Statistics:"
printf "  Median session cost: \$%s\n" "$(printf '%.2f' "$MEDIAN")"
printf "  Average session cost: \$%s\n" "$(printf '%.2f' "$AVG")"

# Outlier detection: entries with cost > 2x median (skip if median is 0)
OUTLIERS=$(echo "$STATS" | jq -r --argjson median "$MEDIAN" '
    if $median <= 0 then empty else
    .entries[] |
    select(.cost > ($median * 2)) |
    "\(.date) \(.session_id)  $\(.cost | . * 100 | round / 100 | tostring) (\(.cost / $median | . * 10 | round / 10)x median)"
    end
')

if [[ -n "$OUTLIERS" ]]; then
    echo ""
    echo "WARNING Outliers (>2x median):"
    while IFS= read -r line; do
        echo "  $line"
    done <<< "$OUTLIERS"
fi

echo ""
echo "=== Done ==="
