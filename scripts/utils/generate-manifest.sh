#!/bin/bash
# Regenerate manifest.yaml active sections from the filesystem.
#
# Active sections (agents, rules, skills, commands, hooks) are rebuilt from
# what actually exists in the repo. The deprecated section is preserved
# verbatim — it is manually maintained (see manifest header).
#
# Usage: bash scripts/utils/generate-manifest.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

MANIFEST="manifest.yaml"
TMP=$(mktemp)
TODAY=$(date +%Y-%m-%d)

# Preserve the manually maintained deprecated section
DEPRECATED=""
if [[ -f "$MANIFEST" ]]; then
    DEPRECATED=$(awk '/^deprecated:/,0' "$MANIFEST")
fi

{
cat <<HEADER
# Haunt Object Manifest
# Single source of truth for all Haunt framework assets (agents, rules, skills, commands)
#
# PURPOSE:
#   - Define all active Haunt objects with their source paths and deployment scope
#   - Track deprecated objects for automatic cleanup
#   - Enable verification that deployed objects match source of truth
#
# SCHEMA:
#   Active Sections (agents, rules, skills, commands):
#     - name: Base filename without extension (e.g., "gco-dev" not "gco-dev.md")
#     - scope: Where to deploy (global | project | both)
#       - global: Deploy to ~/.claude/ only
#       - project: Deploy to .claude/ only (project-specific customization)
#       - both: Deploy to both locations
#     - source: Relative path from repo root to source file/directory
#
#   Deprecated Section:
#     - type: Type of object (agent | rule | skill | command)
#     - name: Object name (as it appears in ~/.claude/ or .claude/)
#     - removed: ISO date when deprecated (YYYY-MM-DD)
#     - reason: Brief explanation of why deprecated
#
# MAINTENANCE:
#   - Active sections: Auto-generated via \`bash scripts/utils/generate-manifest.sh\`
#   - Deprecated section: MANUALLY maintained (never auto-generated)
#   - Update workflow:
#     1. Add/remove files in agents/, rules/, skills/, commands/
#     2. Run generator to update active sections
#     3. Manually add deprecated entries when removing objects

version: "2.0"
updated: "$TODAY"
generated_by: "scripts/utils/generate-manifest.sh"

# ==============================================================================
# AGENTS - Character sheets for agent personas
# ==============================================================================

agents:
HEADER

for f in agents/*.md; do
    name="${f##*/}"; name="${name%.md}"
    printf '  - name: %s\n    scope: global\n    source: %s\n\n' "$name" "$f"
done

cat <<'SECTION'
# ==============================================================================
# RULES - Invariant enforcement protocols
# ==============================================================================

rules:
SECTION

for f in rules/*.md; do
    name="${f##*/}"; name="${name%.md}"
    printf '  - name: %s\n    scope: global\n    source: %s\n\n' "$name" "$f"
done

cat <<'SECTION'
# ==============================================================================
# SKILLS - On-demand SDLC methodology guidance
# ==============================================================================

skills:
SECTION

for d in skills/*/; do
    [[ -f "${d}SKILL.md" ]] || continue
    name="${d#skills/}"; name="${name%/}"
    version=$(awk -F'"' '/^version:/{print $2; exit}' "${d}SKILL.md")
    version="${version:-1.0}"
    printf '  - name: %s\n    scope: global\n    source: %s\n    version: "%s"\n\n' "$name" "$d" "$version"
done

cat <<'SECTION'
# ==============================================================================
# COMMANDS - Workflow automation commands
# ==============================================================================

commands:
SECTION

for f in commands/*.md; do
    name="${f##*/}"; name="${name%.md}"
    printf '  - name: %s\n    scope: global\n    source: %s\n\n' "$name" "$f"
done

cat <<'SECTION'
# ==============================================================================
# HOOKS - Deterministic enforcement and observability
# ==============================================================================

hooks:
SECTION

# Derive hook entries from hooks/hooks.json (the wiring source of truth).
# Empty matchers use a "~" placeholder BECAUSE tab is IFS whitespace and
# consecutive tabs collapse in read, shifting fields.
jq -r '
    .hooks | to_entries[] | .key as $event | .value[] |
    (.matcher // "~") as $m | .hooks[] |
    [$event, $m, .command, (.timeout // 0)] | @tsv
' hooks/hooks.json | while IFS=$'\t' read -r event matcher command timeout; do
    [[ "$matcher" == "~" ]] && matcher=""
    # Extract repo-relative path from the command string
    source=$(grep -oE 'hooks/[A-Za-z0-9._/-]+' <<< "$command" | head -1)
    name="${source##*/}"; name="${name%.*}"
    printf '  - name: %s\n    source: %s\n    trigger: %s\n    matcher: "%s"\n    timeout: %s\n\n' \
        "$name" "$source" "$event" "$matcher" "$timeout"
done

printf '%s\n' "$DEPRECATED"
} > "$TMP"

mv "$TMP" "$MANIFEST"
echo "Regenerated $MANIFEST"
echo "  agents:   $(ls agents/*.md | wc -l | tr -d ' ')"
echo "  rules:    $(ls rules/*.md | wc -l | tr -d ' ')"
echo "  skills:   $(ls skills/*/SKILL.md | wc -l | tr -d ' ')"
echo "  commands: $(ls commands/*.md | wc -l | tr -d ' ')"
