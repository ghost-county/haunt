#!/bin/bash
set -euo pipefail

# haunt-cost-logger.sh
# Logs session token usage and estimated cost to .haunt/logs/cost-log.jsonl
#
# Usage:
#   bash haunt-cost-logger.sh                              # placeholder entry
#   bash haunt-cost-logger.sh --tokens-in 50000 --tokens-out 12000
#   bash haunt-cost-logger.sh --tokens-in 80000 --tokens-out 15000 --model opus

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required. Install with: brew install jq"; exit 1; }

# Defaults
TOKENS_IN=""
TOKENS_OUT=""
MODEL="sonnet"
SOURCE="estimated"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tokens-in)
            TOKENS_IN="$2"
            shift 2
            ;;
        --tokens-out)
            TOKENS_OUT="$2"
            shift 2
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 [--tokens-in N] [--tokens-out N] [--model sonnet|opus]"
            exit 1
            ;;
    esac
done

# Derive source from whether tokens were provided
[[ -n "$TOKENS_IN" || -n "$TOKENS_OUT" ]] && SOURCE="manual"

# Validate model
if [[ "$MODEL" != "sonnet" && "$MODEL" != "opus" ]]; then
    echo "Error: --model must be 'sonnet' or 'opus'"
    exit 1
fi

# Validate token inputs if provided
if [[ -n "$TOKENS_IN" ]] && ! [[ "$TOKENS_IN" =~ ^[0-9]+$ ]]; then
    echo "Error: --tokens-in must be a non-negative integer"
    exit 1
fi
if [[ -n "$TOKENS_OUT" ]] && ! [[ "$TOKENS_OUT" =~ ^[0-9]+$ ]]; then
    echo "Error: --tokens-out must be a non-negative integer"
    exit 1
fi

# Default token counts for placeholder entries
if [[ -z "$TOKENS_IN" ]]; then
    TOKENS_IN=0
fi
if [[ -z "$TOKENS_OUT" ]]; then
    TOKENS_OUT=0
fi

# Pricing per million tokens
SONNET_IN=3;  SONNET_OUT=15
OPUS_IN=15;   OPUS_OUT=75

if [[ "$MODEL" == "opus" ]]; then
    PRICE_IN_PER_MTOK=$OPUS_IN
    PRICE_OUT_PER_MTOK=$OPUS_OUT
elif [[ "$MODEL" == "sonnet" ]]; then
    PRICE_IN_PER_MTOK=$SONNET_IN
    PRICE_OUT_PER_MTOK=$SONNET_OUT
else
    echo "Error: unknown model '$MODEL' — no pricing available"
    exit 1
fi

# Calculate cost using awk for floating point
ESTIMATED_COST=$(awk -v ti="$TOKENS_IN" -v to="$TOKENS_OUT" \
    -v pi="$PRICE_IN_PER_MTOK" -v po="$PRICE_OUT_PER_MTOK" \
    'BEGIN { printf "%.6f", (ti / 1000000 * pi) + (to / 1000000 * po) }')

# Session ID: use env var or generate one
if [[ -n "${CLAUDE_SESSION_ID:-}" ]]; then
    SESSION_ID="$CLAUDE_SESSION_ID"
else
    # Generate a short UUID-like ID without external tools
    SESSION_ID=$(uuidgen 2>/dev/null | tr -d '-' | head -c 12 || printf '%x%x' $RANDOM $RANDOM)
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_DIR=".haunt/logs"
LOG_FILE="$LOG_DIR/cost-log.jsonl"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Build and append JSON entry
ENTRY=$(jq -n \
    --arg timestamp "$TIMESTAMP" \
    --arg session_id "$SESSION_ID" \
    --argjson tokens_in "$TOKENS_IN" \
    --argjson tokens_out "$TOKENS_OUT" \
    --arg model "$MODEL" \
    --argjson estimated_cost_usd "$ESTIMATED_COST" \
    --arg source "$SOURCE" \
    '{
        timestamp: $timestamp,
        session_id: $session_id,
        tokens_in: $tokens_in,
        tokens_out: $tokens_out,
        model: $model,
        estimated_cost_usd: $estimated_cost_usd,
        source: $source
    }')

echo "$ENTRY" >> "$LOG_FILE"

echo "Logged to $LOG_FILE"
echo "  session: $SESSION_ID"
echo "  tokens:  ${TOKENS_IN} in / ${TOKENS_OUT} out"
echo "  model:   $MODEL"
echo "  cost:    \$${ESTIMATED_COST}"
echo "  source:  $SOURCE"
