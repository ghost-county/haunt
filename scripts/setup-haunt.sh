#!/usr/bin/env bash
#
# setup-haunt.sh - Deploy Haunt dev guardrails to ~/.claude/
#
# Copies rules, skills, commands, agents, and hooks from source to Claude Code config.
#
# Usage:
#   Local:  bash scripts/setup-haunt.sh [OPTIONS]
#   Remote: curl -fsSL https://raw.githubusercontent.com/ghost-county/haunt/main/scripts/setup-haunt.sh | bash -s -- [OPTIONS]
#
# Options:
#   --verify        Verify existing deployment
#   --scope=global  Deploy to ~/.claude/ (default)
#   --scope=project Deploy to .claude/ in current directory
#   --quiet         Suppress non-error output
#   --dry-run       Preview what would be installed

set -euo pipefail

# --- Parse flags ---
SCOPE="global"
QUIET=false
DRY_RUN=false
VERIFY=false

for arg in "$@"; do
    case "$arg" in
        --verify)        VERIFY=true ;;
        --scope=global)  SCOPE="global" ;;
        --scope=project) SCOPE="project" ;;
        --cleanup|--clean) ;; # accepted for backward compat, cleanup is automatic
        --quiet)         QUIET=true ;;
        --dry-run)       DRY_RUN=true ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

# --- Resolve source directory ---
# When piped from curl, BASH_SOURCE[0] won't resolve to a real file.
# In that case, download the repo tarball to a temp dir and re-run from there.
REMOTE_REPO="https://github.com/ghost-county/haunt"
TEMP_DIR=""

resolve_source() {
    # Check if we're running from a local clone
    local script_path="${BASH_SOURCE[0]:-}"
    if [[ -n "$script_path" && -f "$script_path" ]]; then
        SCRIPT_DIR="$(cd "$(dirname "$script_path")" && pwd)"
        HAUNT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
        return 0
    fi

    # Remote mode: download tarball
    TEMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM

    $QUIET || echo "Downloading Haunt..."
    if ! curl -fsSL "$REMOTE_REPO/archive/refs/heads/main.tar.gz" | tar -xz -C "$TEMP_DIR" 2>/dev/null; then
        echo "Error: Failed to download Haunt from $REMOTE_REPO" >&2
        exit 1
    fi

    HAUNT_DIR="$TEMP_DIR/haunt-main/Haunt"
    if [[ ! -d "$HAUNT_DIR" ]]; then
        echo "Error: Haunt directory not found in downloaded archive" >&2
        exit 1
    fi
}

# --- Set target directory ---
if [[ "$SCOPE" == "project" ]]; then
    CLAUDE_DIR=".claude"
else
    CLAUDE_DIR="$HOME/.claude"
fi

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

ok()   { $QUIET || echo -e "${GREEN}+${NC} $1"; }
fail() { echo -e "${RED}x${NC} $1"; }
info() { $QUIET || echo -e "${YELLOW}*${NC} $1"; }

# --- Verify mode (no source needed, skip download) ---
if $VERIFY; then
    echo "Verifying Haunt deployment in $CLAUDE_DIR..."
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
        fail "$errors issues found. Re-run setup."
        exit 1
    fi
    exit 0
fi

# --- Resolve source (downloads tarball in remote mode) ---
resolve_source

# --- Dry-run mode ---
if $DRY_RUN; then
    echo "Dry run — would deploy to $CLAUDE_DIR:"
    echo ""
    info "Agents:"
    for f in "$HAUNT_DIR/agents"/*.md; do [[ -e "$f" ]] && echo "    $(basename "$f")"; done
    info "Rules:"
    for f in "$HAUNT_DIR/rules"/*.md; do [[ -e "$f" ]] && echo "    $(basename "$f")"; done
    info "Skills:"
    for d in "$HAUNT_DIR/skills"/gco-*/; do [[ -d "$d" ]] && echo "    $(basename "$d")/"; done
    info "Commands:"
    for f in "$HAUNT_DIR/commands"/*.md; do [[ -e "$f" ]] && echo "    $(basename "$f")"; done
    info "Hooks:"
    find "$HAUNT_DIR/hooks" \( -name "*.sh" -o -name "*.py" -o -name "*.yaml" \) 2>/dev/null | while read -r f; do
        echo "    ${f#"$HAUNT_DIR"/hooks/}"
    done
    echo ""
    info "Target: $CLAUDE_DIR"
    info "Scope: $SCOPE"
    exit 0
fi

# --- Deploy ---
$QUIET || echo "Deploying Haunt dev guardrails to $CLAUDE_DIR..."

# Create directories
mkdir -p "$CLAUDE_DIR/rules" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/agents"

# --- Agent composition helpers ---

# Extract a field value from a YAML or Markdown file.
# Works with both plain YAML files (no --- markers) and Markdown with frontmatter.
# Handles inline format ("field: value") and block list format ("field:\n  - item").
yaml_get_field() {
    local field="$1"
    local file="$2"
    local has_frontmatter
    has_frontmatter=$(grep -c "^---$" "$file" || true)

    if [[ "$has_frontmatter" -ge 2 ]]; then
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
    own_tools=$(yaml_get_field "tools" "$base_file")
    own_skills=$(yaml_get_field "skills" "$base_file")

    local merged_tools merged_skills
    merged_tools=$(printf "%s,%s" "$parent_tools" "$own_tools" | tr ',' '\n' | sed 's/^[[:space:]]*//' | grep -v '^$' | awk '!seen[$0]++' | tr '\n' ',' | sed 's/,$//')
    merged_skills=$(printf "%s,%s" "$parent_skills" "$own_skills" | tr ',' '\n' | sed 's/^[[:space:]]*//' | grep -v '^$' | awk '!seen[$0]++' | tr '\n' ',' | sed 's/,$//')

    echo "TOOLS:${merged_tools}"
    echo "SKILLS:${merged_skills}"
}

resolve_agent() {
    local src="$1"
    local dest="$2"

    local extends_val
    extends_val=$(awk '/^---$/{if(++fm==2)exit} fm==1 && /^extends:/{sub(/^extends:[[:space:]]*/,""); print; exit}' "$src")

    if [[ -z "$extends_val" ]]; then
        cp "$src" "$dest"
        return
    fi

    local base_out base_tools base_skills
    base_out=$(resolve_base "$extends_val")
    base_tools=$(echo "$base_out" | grep "^TOOLS:" | sed 's/^TOOLS://')
    base_skills=$(echo "$base_out" | grep "^SKILLS:" | sed 's/^SKILLS://')

    local agent_tools agent_skills
    agent_tools=$(yaml_get_field "tools" "$src")
    agent_skills=$(yaml_get_field "skills" "$src")

    local merged_tools merged_skills
    merged_tools=$(printf "%s,%s" "$base_tools" "$agent_tools" | tr ',' '\n' | sed 's/^[[:space:]]*//' | grep -v '^$' | awk '!seen[$0]++' | tr '\n' ',' | sed 's/,$//')
    merged_skills=$(printf "%s,%s" "$base_skills" "$agent_skills" | tr ',' '\n' | sed 's/^[[:space:]]*//' | grep -v '^$' | awk '!seen[$0]++' | tr '\n' ',' | sed 's/,$//')

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

# Deploy agents
count=0
for agent in "$HAUNT_DIR/agents"/*.md; do
    [[ -e "$agent" ]] || continue
    resolve_agent "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
    ((count++))
done
ok "Agents deployed ($count files, with base composition)"

# Deploy rules
count=0
for rule in "$HAUNT_DIR/rules"/*.md; do
    [[ -e "$rule" ]] || continue
    cp "$rule" "$CLAUDE_DIR/rules/$(basename "$rule")"
    ((count++))
done
ok "Rules deployed ($count files)"

# Deploy skills (each is a directory with SKILL.md)
count=0
for skill_dir in "$HAUNT_DIR/skills"/gco-*/; do
    [[ -d "$skill_dir" ]] || continue
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
    [[ -e "$cmd" ]] || continue
    cp "$cmd" "$CLAUDE_DIR/commands/$(basename "$cmd")"
    ((count++))
done
ok "Commands deployed ($count files)"

# Deploy hooks
count=0
mkdir -p "$CLAUDE_DIR/hooks"
for hook_script in "$HAUNT_DIR/hooks"/*.sh "$HAUNT_DIR/hooks"/*.py; do
    [[ -e "$hook_script" ]] || continue
    cp "$hook_script" "$CLAUDE_DIR/hooks/$(basename "$hook_script")"
    chmod +x "$CLAUDE_DIR/hooks/$(basename "$hook_script")"
    ((count++))
done
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

    python3 - "$manifest" <<'PYEOF'
import sys, json, re

manifest_path = sys.argv[1]
with open(manifest_path) as f:
    content = f.read()

hooks_match = re.search(r'^hooks:\n(.*?)(?=^\w|\Z)', content, re.MULTILINE | re.DOTALL)
if not hooks_match:
    print('{}')
    sys.exit(0)

hooks_yaml = hooks_match.group(1)

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

hooks_by_trigger = {}
for hook in hooks:
    trigger = hook.get('trigger', '')
    matcher = hook.get('matcher', '')
    source = hook.get('source', '')
    timeout = hook.get('timeout', 5)

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
ok "Haunt deployed to $CLAUDE_DIR ($SCOPE scope)"
if [[ -n "$TEMP_DIR" ]]; then
    $QUIET || echo "  Verify with: bash -c \"\$(curl -fsSL $REMOTE_REPO/raw/main/scripts/setup-haunt.sh)\" -- --verify"
else
    $QUIET || echo "  Verify with: bash scripts/setup-haunt.sh --verify"
fi
