#!/usr/bin/env bash
# migrate-to-plugin.sh - Clean up old setup-haunt.sh deployment
# Usage:
#   bash scripts/migrate-to-plugin.sh            # Preview (dry-run)
#   bash scripts/migrate-to-plugin.sh --execute   # Actually remove files

set -euo pipefail

EXECUTE=false
[[ "${1:-}" == "--execute" ]] && EXECUTE=true

CLAUDE_DIR="$HOME/.claude"
FOUND=()

# Scan for gco-* files in agents, rules, commands
for dir in agents rules commands; do
    for f in "$CLAUDE_DIR/$dir"/gco-*; do
        [[ -e "$f" ]] && FOUND+=("$f")
    done
done

# Scan for gco-* skill directories
for d in "$CLAUDE_DIR/skills"/gco-*; do
    [[ -d "$d" ]] && FOUND+=("$d")
done

if [[ ${#FOUND[@]} -eq 0 ]]; then
    echo "Nothing to migrate. No setup-haunt.sh deployments found."
    exit 0
fi

echo "Found ${#FOUND[@]} haunt-deployed items:"
printf '  %s\n' "${FOUND[@]}"

if [[ "$EXECUTE" == "false" ]]; then
    echo ""
    echo "Dry run. To remove these, run:"
    echo "  bash scripts/migrate-to-plugin.sh --execute"
    exit 0
fi

echo ""
echo "Removing..."
for item in "${FOUND[@]}"; do
    if [[ -d "$item" ]]; then
        rm -rf "$item"
    else
        rm -f "$item"
    fi
    echo "  Removed: $item"
done

echo ""
echo "Migration complete. Next steps:"
echo "  1. /plugin marketplace add ghost-county/haunt"
echo "  2. /plugin install haunt@ghost-county-haunt"
