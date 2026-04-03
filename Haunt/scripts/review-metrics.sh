#!/bin/bash
set -euo pipefail

# Review metrics from .haunt/logs/review-verdicts.jsonl
LOGFILE="${1:-.haunt/logs/review-verdicts.jsonl}"

if [[ ! -f "$LOGFILE" ]]; then
    echo "No review verdicts found at $LOGFILE"
    echo "Review verdicts are logged when gco-code-reviewer completes reviews."
    exit 0
fi

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required. Install with: brew install jq"; exit 1; }

TOTAL=$(wc -l < "$LOGFILE" | tr -d ' ')

# Single jq pass for all counts
read -r APPROVED CHANGES BLOCKED NO_EVIDENCE < <(
    jq -s '
        {
            approved: [.[] | select(.verdict=="APPROVED")] | length,
            changes: [.[] | select(.verdict=="CHANGES_REQUESTED")] | length,
            blocked: [.[] | select(.verdict=="BLOCKED")] | length,
            no_evidence: [.[] | select(.evidence_quality=="none")] | length
        } | "\(.approved) \(.changes) \(.blocked) \(.no_evidence)"
    ' "$LOGFILE" 2>/dev/null || echo "0 0 0 0"
)

echo "=== Review Metrics ==="
echo "Total reviews:      $TOTAL"
echo "Approved:           $APPROVED"
echo "Changes requested:  $CHANGES"
echo "Blocked:            $BLOCKED"
echo ""

if [[ "$TOTAL" -gt 0 ]]; then
    APPROVAL_RATE=$((APPROVED * 100 / TOTAL))
    echo "Approval rate:      ${APPROVAL_RATE}%"
    echo ""

    # Rubber-stamp detection (check 100% first since >85 would catch it)
    if [[ "$APPROVAL_RATE" -eq 100 ]] && [[ "$TOTAL" -gt 3 ]]; then
        echo "ALERT: 100% approval rate over $TOTAL reviews."
        echo "Zero rejections indicates decorative reviews, not functional quality gates."
    elif [[ "$APPROVAL_RATE" -gt 85 ]]; then
        echo "WARNING: Approval rate exceeds 85% ($APPROVAL_RATE%)"
        echo "This may indicate rubber-stamp reviews (MAST FM-3.1)."
        echo "Consider: Are reviews citing specific evidence? Are findings meaningful?"
    else
        echo "Approval rate is within healthy range (5-85%)."
    fi

    # Evidence quality check
    if [[ "$NO_EVIDENCE" -gt 0 ]]; then
        echo ""
        echo "WARNING: $NO_EVIDENCE reviews had no evidence cited."
        echo "Every verdict should include specific file:line references."
    fi
fi

echo ""
echo "=== Done ==="
