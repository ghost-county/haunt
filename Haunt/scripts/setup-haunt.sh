#!/usr/bin/env bash
#
# setup-haunt.sh - Deploy Haunt dev guardrails to ~/.claude/
#
# Copies rules, skills, and commands from Haunt/ source to global Claude Code config.
#
# Usage: bash Haunt/scripts/setup-haunt.sh [--verify]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HAUNT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

ok() { echo -e "${GREEN}+${NC} $1"; }
fail() { echo -e "${RED}x${NC} $1"; }

# --- Verify mode ---
if [[ "${1:-}" == "--verify" ]]; then
    echo "Verifying Haunt deployment..."
    errors=0

    # Check agents
    agent_count=$(ls "$CLAUDE_DIR/agents"/gco-*.md 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$agent_count" -ge 6 ]]; then
        ok "Agents: $agent_count gco agents deployed"
    else
        fail "Agents: only $agent_count gco agents (expected 6)"
        errors=$((errors + 1))
    fi

    # Check rules
    rule_count=$(ls "$CLAUDE_DIR/rules"/gco-*.md 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$rule_count" -ge 6 ]]; then
        ok "Rules: $rule_count gco rules deployed"
    else
        fail "Rules: only $rule_count gco rules (expected 6)"
        errors=$((errors + 1))
    fi

    # Check skills
    skill_count=$(ls -d "$CLAUDE_DIR/skills"/gco-*/ 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$skill_count" -ge 16 ]]; then
        ok "Skills: $skill_count gco skills deployed"
    else
        fail "Skills: only $skill_count gco skills (expected 16)"
        errors=$((errors + 1))
    fi

    # Check commands
    cmd_count=$(ls "$CLAUDE_DIR/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$cmd_count" -ge 4 ]]; then
        ok "Commands: $cmd_count commands deployed"
    else
        fail "Commands: only $cmd_count commands (expected 4)"
        errors=$((errors + 1))
    fi

    # Validate each skill has SKILL.md
    for skill_dir in "$CLAUDE_DIR/skills"/gco-*/; do
        if [[ ! -f "$skill_dir/SKILL.md" ]]; then
            fail "Missing SKILL.md in $(basename "$skill_dir")"
            errors=$((errors + 1))
        fi
    done

    # Check hooks
    hook_count=$(find "$CLAUDE_DIR/hooks" -name "*.sh" -o -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$hook_count" -ge 6 ]]; then
        ok "Hooks: $hook_count hook scripts deployed"
    else
        fail "Hooks: only $hook_count hooks (expected 6+)"
        errors=$((errors + 1))
    fi

    # Check settings.json has hooks
    if [[ -f "$CLAUDE_DIR/settings.json" ]] && jq -e '.hooks' "$CLAUDE_DIR/settings.json" >/dev/null 2>&1; then
        ok "Settings: hooks configured in settings.json"
    else
        fail "Settings: hooks not found in settings.json"
        errors=$((errors + 1))
    fi

    if [[ "$errors" -eq 0 ]]; then
        echo ""
        ok "All checks passed."
    else
        echo ""
        fail "$errors issues found. Re-run setup: bash Haunt/scripts/setup-haunt.sh"
        exit 1
    fi
    exit 0
fi

# --- Deploy ---
echo "Deploying Haunt dev guardrails..."

# Create directories
mkdir -p "$CLAUDE_DIR/rules" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/agents"

# --- Agent composition helpers ---

# Extract a field value from a YAML or Markdown file.
# Works with both plain YAML files (no --- markers) and Markdown with frontmatter.
# Handles inline format ("field: value") and block list format ("field:\n  - item").
# Usage: yaml_get_field "tools" "$file"
yaml_get_field() {
    local field="$1"
    local file="$2"
    # Detect if file has frontmatter markers
    local has_frontmatter
    has_frontmatter=$(grep -c "^---$" "$file" || true)

    if [[ "$has_frontmatter" -ge 2 ]]; then
        # Markdown with frontmatter: only scan between first and second ---
        local inline
        inline=$(awk -v f="$field" '
            /^---$/ { if (++fm == 2) exit }
            fm == 1 && $0 ~ "^"f":[[:space:]]+[^[:space:]]" {
                sub("^"f":[[:space:]]*", ""); print; exit
            }
        ' "$file")
        if [[ -n "$inline" ]]; then
            echo "$inline"
            return
        fi
        awk -v f="$field" '
            /^---$/ { if (++fm == 2) exit }
            fm == 1 {
                if ($0 ~ "^"f":") { found=1; next }
                if (found && /^  - /) { sub(/^  - /, ""); printf "%s,", $0; next }
                if (found) { exit }
            }
        ' "$file" | sed 's/,$//'
    else
        # Plain YAML: scan the whole file
        local inline
        inline=$(awk -v f="$field" '
            $0 ~ "^"f":[[:space:]]+[^[:space:]]" {
                sub("^"f":[[:space:]]*", ""); print; exit
            }
        ' "$file")
        if [[ -n "$inline" ]]; then
            echo "$inline"
            return
        fi
        awk -v f="$field" '
            $0 ~ "^"f":" { found=1; next }
            found && /^  - / { sub(/^  - /, ""); printf "%s,", $0; next }
            found { exit }
        ' "$file" | sed 's/,$//'
    fi
}

# Alias for backward compat within this script
fm_get_field() { yaml_get_field "$@"; }

# Resolve a base YAML file, following extends chain recursively.
# Prints two lines: "TOOLS:<csv>" and "SKILLS:<csv>"
resolve_base() {
    local base_name="$1"
    local bases_dir="$HAUNT_DIR/agents/bases"
    local base_file="$bases_dir/${base_name}.yaml"

    if [[ ! -f "$base_file" ]]; then
        echo "TOOLS:"
        echo "SKILLS:"
        return
    fi

    local parent_extends
    parent_extends=$(grep -m1 "^extends:" "$base_file" | sed 's/^extends:[[:space:]]*//' || true)

    local parent_tools="" parent_skills=""
    if [[ -n "$parent_extends" ]]; then
        local parent_out
        parent_out=$(resolve_base "$parent_extends")
        parent_tools=$(echo "$parent_out" | grep "^TOOLS:" | sed 's/^TOOLS://')
        parent_skills=$(echo "$parent_out" | grep "^SKILLS:" | sed 's/^SKILLS://')
    fi

    local own_tools own_skills
    own_tools=$(fm_get_field "tools" "$base_file")
    own_skills=$(fm_get_field "skills" "$base_file")

    local merged_tools merged_skills
    merged_tools=$(printf "%s,%s" "$parent_tools" "$own_tools" | tr ',' '\n' | sed 's/^[[:space:]]*//' | grep -v '^$' | awk '!seen[$0]++' | tr '\n' ',' | sed 's/,$//')
    merged_skills=$(printf "%s,%s" "$parent_skills" "$own_skills" | tr ',' '\n' | sed 's/^[[:space:]]*//' | grep -v '^$' | awk '!seen[$0]++' | tr '\n' ',' | sed 's/,$//')

    echo "TOOLS:${merged_tools}"
    echo "SKILLS:${merged_skills}"
}

# Resolve an agent .md file: merge base tools/skills and write resolved version to dest.
# Agents without "extends:" in frontmatter are copied as-is.
resolve_agent() {
    local src="$1"
    local dest="$2"

    # Check for extends in frontmatter (between first and second ---)
    local extends_val
    extends_val=$(awk '/^---$/{if(++fm==2)exit} fm==1 && /^extends:/{sub(/^extends:[[:space:]]*/,""); print; exit}' "$src")

    if [[ -z "$extends_val" ]]; then
        cp "$src" "$dest"
        return
    fi

    # Resolve base chain
    local base_out base_tools base_skills
    base_out=$(resolve_base "$extends_val")
    base_tools=$(echo "$base_out" | grep "^TOOLS:" | sed 's/^TOOLS://')
    base_skills=$(echo "$base_out" | grep "^SKILLS:" | sed 's/^SKILLS://')

    # Extract agent's own tools/skills from frontmatter
    local agent_tools agent_skills
    agent_tools=$(fm_get_field "tools" "$src")
    agent_skills=$(fm_get_field "skills" "$src")

    # Merge base + agent (deduplicated), preserving order: base first, then agent additions
    local merged_tools merged_skills
    merged_tools=$(printf "%s,%s" "$base_tools" "$agent_tools" | tr ',' '\n' | sed 's/^[[:space:]]*//' | grep -v '^$' | awk '!seen[$0]++' | tr '\n' ',' | sed 's/,$//')
    merged_skills=$(printf "%s,%s" "$base_skills" "$agent_skills" | tr ',' '\n' | sed 's/^[[:space:]]*//' | grep -v '^$' | awk '!seen[$0]++' | tr '\n' ',' | sed 's/,$//')

    # Rewrite frontmatter: remove extends line, replace tools/skills with merged values
    awk -v tools="$merged_tools" -v skills="$merged_skills" '
        BEGIN { fm=0 }
        /^---$/ { fm++; print; next }
        fm == 1 {
            if (/^extends:/) next
            if (/^tools:/) { print "tools: " tools; next }
            if (/^skills:/) { print "skills: " skills; next }
        }
        { print }
    ' "$src" > "$dest"
}

# Deploy agents (with base composition resolution)
count=0
for agent in "$HAUNT_DIR/agents"/*.md; do
    resolve_agent "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
    ((count++))
done
ok "Agents deployed ($count files, with base composition)"

# Deploy rules
count=0
for rule in "$HAUNT_DIR/rules"/*.md; do
    cp "$rule" "$CLAUDE_DIR/rules/$(basename "$rule")"
    ((count++))
done
ok "Rules deployed ($count files)"

# Deploy skills (each is a directory with SKILL.md)
count=0
for skill_dir in "$HAUNT_DIR/skills"/gco-*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$CLAUDE_DIR/skills/$skill_name"
    cp -r "$skill_dir"/* "$CLAUDE_DIR/skills/$skill_name/"
    ((count++))
done
ok "Skills deployed ($count skills)"

# Deploy upland-data-engineering skill if present
if [[ -d "$HAUNT_DIR/skills/upland-data-engineering" ]]; then
    mkdir -p "$CLAUDE_DIR/skills/upland-data-engineering"
    cp -r "$HAUNT_DIR/skills/upland-data-engineering"/* "$CLAUDE_DIR/skills/upland-data-engineering/"
    ok "Domain skill deployed (upland-data-engineering)"
fi

# Deploy commands
count=0
for cmd in "$HAUNT_DIR/commands"/*.md; do
    cp "$cmd" "$CLAUDE_DIR/commands/$(basename "$cmd")"
    ((count++))
done
ok "Commands deployed ($count files)"

# Deploy hooks
count=0
mkdir -p "$CLAUDE_DIR/hooks"
# Copy top-level hook scripts
for hook_script in "$HAUNT_DIR/hooks"/*.sh "$HAUNT_DIR/hooks"/*.py; do
    [[ -e "$hook_script" ]] || continue
    cp "$hook_script" "$CLAUDE_DIR/hooks/$(basename "$hook_script")"
    chmod +x "$CLAUDE_DIR/hooks/$(basename "$hook_script")"
    ((count++))
done
# Copy subdirectories (damage-control/, session-start/)
for hook_subdir in "$HAUNT_DIR/hooks"/*/; do
    [[ -d "$hook_subdir" ]] || continue
    subdir_name=$(basename "$hook_subdir")
    mkdir -p "$CLAUDE_DIR/hooks/$subdir_name"
    for f in "$hook_subdir"*.sh "$hook_subdir"*.py "$hook_subdir"*.yaml; do
        [[ -e "$f" ]] || continue
        cp "$f" "$CLAUDE_DIR/hooks/$subdir_name/$(basename "$f")"
        chmod +x "$CLAUDE_DIR/hooks/$subdir_name/$(basename "$f")" 2>/dev/null || true
        ((count++))
    done
done
ok "Hooks deployed ($count files)"

# Generate hooks JSON from manifest and merge into settings.json
generate_hooks_json() {
    local manifest="$HAUNT_DIR/manifest.yaml"

    # Parse manifest hooks section using Python3 (handles matchers with | chars safely)
    python3 - "$manifest" <<'PYEOF'
import sys, json, re

manifest_path = sys.argv[1]
with open(manifest_path) as f:
    content = f.read()

# Extract just the hooks: section (from "^hooks:" until next top-level key or end)
hooks_match = re.search(r'^hooks:\n(.*?)(?=^\w|\Z)', content, re.MULTILINE | re.DOTALL)
if not hooks_match:
    print('{}')
    sys.exit(0)

hooks_yaml = hooks_match.group(1)

# Parse individual hook entries using simple line-by-line state machine
hooks = []
current = {}
for line in hooks_yaml.splitlines():
    stripped = line.strip()
    if stripped.startswith('- name:'):
        if current:
            hooks.append(current)
        current = {'name': stripped[len('- name:'):].strip()}
    elif stripped.startswith('source:'):
        current['source'] = stripped[len('source:'):].strip()
    elif stripped.startswith('trigger:'):
        current['trigger'] = stripped[len('trigger:'):].strip()
    elif stripped.startswith('matcher:'):
        val = stripped[len('matcher:'):].strip().strip('"')
        current['matcher'] = val
    elif stripped.startswith('timeout:'):
        current['timeout'] = int(stripped[len('timeout:'):].strip())
if current:
    hooks.append(current)

# Group by trigger, then by matcher
hooks_by_trigger = {}
for hook in hooks:
    trigger = hook.get('trigger', '')
    matcher = hook.get('matcher', '')
    source = hook.get('source', '')
    timeout = hook.get('timeout', 5)

    # Build command string based on file extension
    # source is relative from Haunt/ dir, e.g. hooks/commit-validator.sh
    # deployed path: $HOME/.claude/hooks/<relative-after-hooks/>
    parts = source.split('/', 1)
    rel = parts[1] if len(parts) > 1 else parts[0]

    if source.endswith('.py'):
        command = '"$HOME/.claude/hooks/{rel}"'.format(rel=rel)
    else:
        command = 'bash "$HOME/.claude/hooks/{rel}"'.format(rel=rel)

    entry = {'type': 'command', 'command': command, 'timeout': timeout}

    if trigger not in hooks_by_trigger:
        hooks_by_trigger[trigger] = {}
    if matcher not in hooks_by_trigger[trigger]:
        hooks_by_trigger[trigger][matcher] = []
    hooks_by_trigger[trigger][matcher].append(entry)

# Build output structure
result = {}
for trigger, matchers in hooks_by_trigger.items():
    result[trigger] = []
    for matcher, hook_list in matchers.items():
        group = {'hooks': hook_list}
        if matcher:
            group['matcher'] = matcher
        result[trigger].append(group)

print(json.dumps(result))
PYEOF
}

HOOKS_JSON=$(generate_hooks_json)
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

if [[ -f "$SETTINGS_FILE" ]]; then
    jq --argjson hooks "$HOOKS_JSON" '.hooks = $hooks' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
    mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
else
    echo "{\"hooks\": $HOOKS_JSON}" | jq . > "$SETTINGS_FILE"
fi
ok "Settings: hooks merged into settings.json"

echo ""
ok "Done. Verify with: bash Haunt/scripts/setup-haunt.sh --verify"
