#!/bin/bash
# File Location Enforcement Hook
# Blocks: Ghost County artifacts created outside .haunt/
#
# This hook ensures that GCO-specific artifacts (roadmaps, requirements,
# progress notes, etc.) are always placed in the .haunt/ directory structure.

set -euo pipefail

# Global disable check
if [[ "${HAUNT_HOOKS_DISABLED:-0}" == "1" ]]; then
    exit 0
fi

# Seance gate: only enforce during active seance
SENTINEL="${PWD}/.haunt/active-session"
[[ -f "$SENTINEL" ]] || exit 0

# Read hook input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Skip if no file path (shouldn't happen, but be defensive)
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Get filename and convert to lowercase for pattern matching
FILE_NAME=$(basename "$FILE_PATH")
FILE_LOWER=$(echo "$FILE_NAME" | tr '[:upper:]' '[:lower:]')

# Ghost County artifact patterns
# These files MUST be in .haunt/ directory
GCO_PATTERNS=(
    "roadmap"
    "requirement"
    "req-"
    "completed"
    "progress"
    "pattern-test"
    "defeat-test"
    "feature-contract"
    "seance-"
    "batch-"
)

# Check if file matches any GCO pattern
IS_GCO_ARTIFACT=false
MATCHED_PATTERN=""
for pattern in "${GCO_PATTERNS[@]}"; do
    if [[ "$FILE_LOWER" == *"$pattern"* ]]; then
        IS_GCO_ARTIFACT=true
        MATCHED_PATTERN="$pattern"
        break
    fi
done

# If it's a GCO artifact, it must be in .haunt/
if [[ "$IS_GCO_ARTIFACT" == true ]] && [[ "$FILE_PATH" != *".haunt/"* ]]; then
    echo "Location violation: Ghost County artifacts must go in .haunt/" >&2
    echo "" >&2
    echo "File: $FILE_NAME" >&2
    echo "Matched pattern: '$MATCHED_PATTERN'" >&2
    echo "Current path: $FILE_PATH" >&2
    echo "" >&2
    echo "Correct locations:" >&2
    echo "  - Roadmaps/plans:     .haunt/plans/" >&2
    echo "  - Completed work:     .haunt/completed/" >&2
    echo "  - Progress notes:     .haunt/progress/" >&2
    echo "  - Pattern tests:      .haunt/tests/patterns/" >&2
    echo "  - Feature contracts:  .haunt/plans/" >&2
    echo "" >&2
    echo "See: gco-file-conventions rule for full directory structure" >&2
    exit 2  # Blocking error
fi

exit 0
