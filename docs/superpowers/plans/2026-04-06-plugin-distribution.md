# Haunt Plugin Distribution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the ghost-county/haunt repo from copy-based deployment to a native Claude Code plugin with auto-updating distribution.

**Architecture:** Flatten `Haunt/` directory to repo root matching the Claude Code plugin format (`.claude-plugin/`, `agents/`, `skills/`, `commands/`, `hooks/`, `rules/`). Add plugin metadata and hooks.json manifest. Repurpose setup script as migration tool.

**Tech Stack:** Claude Code plugin system, bash, git

**Spec:** `docs/superpowers/specs/2026-04-06-plugin-distribution-design.md`

---

### Task 1: Create Plugin Metadata

Create the `.claude-plugin/` directory with plugin.json and marketplace.json.

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Create plugin.json**

```json
{
  "name": "haunt",
  "description": "Dev guardrails and agent coordination toolkit. Quality gates, coding standards, testing enforcement, and the seance spec-driven development workflow.",
  "version": "1.0.0",
  "author": {
    "name": "heckatron"
  },
  "homepage": "https://github.com/ghost-county/haunt",
  "repository": "https://github.com/ghost-county/haunt",
  "license": "MIT",
  "keywords": [
    "guardrails",
    "agent-coordination",
    "quality-gates",
    "testing",
    "seance",
    "code-review"
  ]
}
```

- [ ] **Step 2: Create marketplace.json**

```json
{
  "name": "ghost-county-haunt",
  "description": "Dev guardrails and agent coordination toolkit for Claude Code",
  "owner": {
    "name": "heckatron"
  },
  "plugins": [
    {
      "name": "haunt",
      "description": "Dev guardrails and agent coordination toolkit. Quality gates, coding standards, testing enforcement, and the seance spec-driven development workflow.",
      "version": "1.0.0",
      "source": "./",
      "author": {
        "name": "heckatron"
      }
    }
  ]
}
```

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/
git commit -m "WIP Add plugin metadata: plugin.json and marketplace.json"
```

---

### Task 2: Move Agents to Repo Root

Move agent definitions from `Haunt/agents/` to `agents/`. Archive goes to `docs/archive/agents/`.

**Files:**
- Move: `Haunt/agents/gco-*.md` → `agents/gco-*.md`
- Move: `Haunt/agents/bases/` → `agents/bases/`
- Move: `Haunt/agents/templates/` → `agents/templates/`
- Move: `Haunt/agents/archive/` → `docs/archive/agents/`

- [ ] **Step 1: Move agent files**

```bash
mkdir -p agents/bases agents/templates docs/archive/agents
cp Haunt/agents/gco-*.md agents/
cp Haunt/agents/bases/* agents/bases/
cp Haunt/agents/templates/* agents/templates/
cp Haunt/agents/archive/* docs/archive/agents/
```

- [ ] **Step 2: Verify files moved correctly**

```bash
ls agents/gco-*.md  # Should show 6 agent files
ls agents/bases/    # Should show base templates
ls agents/templates/ # Should show slim-agent.md
ls docs/archive/agents/ # Should show archived agents
diff <(ls Haunt/agents/gco-*.md | xargs -I{} basename {}) <(ls agents/gco-*.md | xargs -I{} basename {})
```

Expected: No diff output (all files match).

- [ ] **Step 3: Commit**

```bash
git add agents/ docs/archive/agents/
git commit -m "WIP Move agents to repo root for plugin format"
```

---

### Task 3: Move Rules to Repo Root

**Files:**
- Move: `Haunt/rules/*.md` → `rules/*.md`

- [ ] **Step 1: Move rule files**

```bash
mkdir -p rules
cp Haunt/rules/*.md rules/
```

- [ ] **Step 2: Verify**

```bash
diff <(ls Haunt/rules/*.md | xargs -I{} basename {}) <(ls rules/*.md | xargs -I{} basename {})
```

Expected: No diff.

- [ ] **Step 3: Commit**

```bash
git add rules/
git commit -m "WIP Move rules to repo root for plugin format"
```

---

### Task 4: Move Skills to Repo Root

Move all gco skills. Move upland-data-engineering to Familiar repo. Handle existing `Skills/` directory at root.

**Files:**
- Move: `Haunt/skills/gco-*` → `skills/gco-*`
- Move: `Haunt/skills/README.md` → `skills/README.md`
- Move: `Haunt/skills/upland-data-engineering/` → Familiar repo
- Handle: existing `Skills/` directory at repo root (note the capital S)

- [ ] **Step 1: Remove existing Skills/ directory (capital S)**

The repo has a `Skills/` directory (capital S) at root with personal skills (file-operations, requirements-elicitation, skill-creator, upland-data-engineering, etc.). On macOS case-insensitive filesystem, `Skills/` and `skills/` collide. This directory contains personal/third-party skills that don't belong in the Haunt plugin.

**Action:** The `Skills/upland-data-engineering/` content is a duplicate of `Haunt/skills/upland-data-engineering/`. Move the Haunt version to the Familiar repo, then remove the entire `Skills/` directory.

```bash
# Move upland-data-engineering to Familiar repo's skills directory
cp -r Haunt/skills/upland-data-engineering/ ~/github_repos/familiar/skills/upland-data-engineering/

# Remove the capital-S Skills/ directory entirely
git rm -r Skills/
```

**Note:** `Skills/` also contains `personal/`, `third-party/`, `file-operations/`, `requirements-elicitation/`, `skill-creator/`, `CONTRIBUTING.md`. If any of these are actively used, move them to Familiar or `~/.claude/skills/` before removing. Check with user if unsure.

- [ ] **Step 2: Commit Skills/ removal**

```bash
git commit -m "WIP Remove Skills/ directory — personal skills move to Familiar, Haunt skills move to skills/"
```

- [ ] **Step 3: Move gco skills to lowercase skills/**

```bash
mkdir -p skills
cp -r Haunt/skills/gco-* skills/
cp Haunt/skills/README.md skills/
```

- [ ] **Step 4: Verify upland-data-engineering is in Familiar**

```bash
ls ~/github_repos/familiar/skills/upland-data-engineering/SKILL.md
```

Expected: File exists.

- [ ] **Step 5: Verify**

```bash
ls skills/gco-* -d  # Should show 16 skill directories
ls skills/gco-code-review/SKILL.md  # Spot check
```

- [ ] **Step 6: Commit**

```bash
git add skills/
git commit -m "WIP Move skills to repo root for plugin format"
```

---

### Task 5: Move Commands to Repo Root

**Files:**
- Move: `Haunt/commands/*.md` → `commands/*.md`

- [ ] **Step 1: Move command files**

```bash
mkdir -p commands
cp Haunt/commands/*.md commands/
```

- [ ] **Step 2: Verify**

```bash
diff <(ls Haunt/commands/*.md | xargs -I{} basename {}) <(ls commands/*.md | xargs -I{} basename {})
```

- [ ] **Step 3: Commit**

```bash
git add commands/
git commit -m "WIP Move commands to repo root for plugin format"
```

---

### Task 6: Move Hooks and Create hooks.json

Move hooks and create the hooks.json manifest. Add seance-gate to applicable hooks.

**Files:**
- Move: `Haunt/hooks/*` → `hooks/*`
- Create: `hooks/hooks.json`
- Modify: `hooks/damage-control/*.py` (add seance gate)
- Modify: `hooks/completion-gate.sh` (add seance gate)
- Modify: `hooks/phase-enforcement.sh` (add seance gate)
- Modify: `hooks/file-location-enforcer.sh` (add seance gate)

- [ ] **Step 1: Move hook files**

```bash
mkdir -p hooks
cp -r Haunt/hooks/* hooks/
```

- [ ] **Step 2: Create hooks.json**

Write `hooks/hooks.json`:

```json
{
  "description": "Haunt dev guardrails hooks",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/session-start/initialize-session.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/observability-logger.sh\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/format-code.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"${CLAUDE_PLUGIN_ROOT}/hooks/damage-control/bash-tool-damage-control.py\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"${CLAUDE_PLUGIN_ROOT}/hooks/damage-control/edit-tool-damage-control.py\"",
            "timeout": 5
          },
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/completion-gate.sh\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"${CLAUDE_PLUGIN_ROOT}/hooks/damage-control/write-tool-damage-control.py\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/file-location-enforcer.sh\"",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Agent",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/phase-enforcement.sh\"",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/notify-completion.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/notify-completion.sh\"",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 3: Add seance gate to damage-control hooks**

Add to the top of each damage-control Python script (`hooks/damage-control/bash-tool-damage-control.py`, `edit-tool-damage-control.py`, `write-tool-damage-control.py`):

```python
import os
sentinel = os.path.join(os.getcwd(), '.haunt', 'active-session')
if not os.path.exists(sentinel):
    import sys
    sys.exit(0)
```

- [ ] **Step 4: Add seance gate to shell hooks**

Add to the top of `completion-gate.sh`, `phase-enforcement.sh`, `file-location-enforcer.sh` (after shebang and existing guards):

```bash
# Seance gate: only enforce during active seance
SENTINEL="${PWD}/.haunt/active-session"
[[ -f "$SENTINEL" ]] || exit 0
```

- [ ] **Step 5: Verify hooks.json is valid JSON**

```bash
python3 -m json.tool hooks/hooks.json > /dev/null
```

Expected: No output (valid JSON).

- [ ] **Step 6: Commit**

```bash
git add hooks/
git commit -m "WIP Move hooks to repo root, add hooks.json manifest and seance gates"
```

---

### Task 7: Move Templates, Scripts, and Docs

**Files:**
- Move: `Haunt/templates/*` → `templates/*`
- Move: `Haunt/scripts/*` → `scripts/*`
- Move: `Haunt/docs/*` → `docs/*` (merge with existing)
- Move: `Haunt/tests/` → `tests/`
- Move: miscellaneous Haunt root files

- [ ] **Step 1: Move templates**

```bash
mkdir -p templates
cp Haunt/templates/* templates/
```

- [ ] **Step 2: Move scripts**

```bash
mkdir -p scripts
cp Haunt/scripts/* scripts/
```

- [ ] **Step 3: Move docs (merge with existing)**

```bash
# docs/ already has docs/superpowers/ from our spec work
cp -r Haunt/docs/* docs/
```

- [ ] **Step 4: Move tests**

```bash
mkdir -p tests
cp -r Haunt/tests/* tests/
```

- [ ] **Step 5: Move miscellaneous Haunt files**

```bash
# Files at Haunt/ root that should be preserved
cp Haunt/manifest.yaml ./
cp Haunt/.haunt-version ./
# QUICK-REFERENCE.md, SETUP-GUIDE.md, README.md from Haunt/ go to docs/
cp Haunt/QUICK-REFERENCE.md docs/
cp Haunt/SETUP-GUIDE.md docs/
# Haunt/secrets/ - check if needed, likely stays as-is or moves to secrets/
cp -r Haunt/secrets/ secrets/ 2>/dev/null || true
# Haunt/examples/ - move to docs/examples/
cp -r Haunt/examples/ docs/examples/ 2>/dev/null || true
```

- [ ] **Step 6: Verify key files exist**

```bash
ls templates/institutional-memory.md
ls scripts/setup-haunt.sh
ls docs/SKILL-ARCHITECTURE.md
ls tests/eval/run-evals.sh
```

- [ ] **Step 7: Commit**

```bash
git add templates/ scripts/ docs/ tests/ manifest.yaml .haunt-version secrets/ 2>/dev/null
git commit -m "WIP Move templates, scripts, docs, and tests to repo root"
```

---

### Task 8: Remove Old Haunt/ Directory

After all content is moved and verified, remove the old `Haunt/` directory.

**Files:**
- Delete: `Haunt/` (entire directory)

- [ ] **Step 1: Final verification — diff moved content**

Spot-check that key files match between old and new locations:

```bash
diff Haunt/agents/gco-dev.md agents/gco-dev.md
diff Haunt/rules/gco-communication.md rules/gco-communication.md
diff Haunt/skills/gco-code-review/SKILL.md skills/gco-code-review/SKILL.md
diff Haunt/commands/seance.md commands/seance.md
diff Haunt/hooks/observability-logger.sh hooks/observability-logger.sh
```

Expected: No diff for any of these (content identical before seance-gate additions).

- [ ] **Step 2: Remove Haunt/ directory**

```bash
git rm -r Haunt/
```

- [ ] **Step 3: Remove obsolete root files**

```bash
# INSTALL.md references old setup-haunt.sh curl method
git rm INSTALL.md
# package-lock.json is empty/unused
git rm package-lock.json
```

- [ ] **Step 4: Commit**

```bash
git commit -m "WIP Remove old Haunt/ directory and obsolete root files"
```

---

### Task 9: Create Migration Script

Repurpose setup-haunt.sh as migrate-to-plugin.sh.

**Files:**
- Create: `scripts/migrate-to-plugin.sh`

- [ ] **Step 1: Write migration script**

The script should:
1. Scan `~/.claude/{agents,rules,skills,commands}/` for `gco-*` files/dirs (the Haunt naming convention)
2. In default mode (no flags): list what would be removed (dry-run)
3. With `--execute`: actually remove the files
4. Report results

**Detection strategy:** Use filename pattern matching (`gco-*` prefix) rather than file markers. The `gco-` prefix is Haunt's unique namespace — no other plugin uses it. This is reliable because the old `setup-haunt.sh` only deployed `gco-*` named files.

```bash
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
    for f in "$CLAUDE_DIR/$dir"/gco-* 2>/dev/null; do
        [[ -e "$f" ]] && FOUND+=("$f")
    done
done

# Scan for gco-* skill directories
for d in "$CLAUDE_DIR/skills"/gco-* 2>/dev/null; do
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
```

- [ ] **Step 2: Make executable**

```bash
chmod +x scripts/migrate-to-plugin.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/migrate-to-plugin.sh
git commit -m "WIP Add migration script for setup-haunt.sh → plugin transition"
```

---

### Task 10: Update CLAUDE.md

Update CLAUDE.md to reflect the new repo structure, plugin-based install, and hook tiers.

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update setup section**

Replace the `bash Haunt/scripts/setup-haunt.sh` instructions with plugin install instructions per the spec.

- [ ] **Step 2: Update repository structure**

Replace the tree diagram. Remove all `Haunt/` prefixes. Add `.claude-plugin/` directory.

- [ ] **Step 3: Update hooks section**

Replace the flat hooks table with the three-tier structure (Always Enabled, Seance-Gated, Shipped but Disabled).

- [ ] **Step 4: Update all internal doc links**

Find and replace `Haunt/docs/` → `docs/` in all links.

- [ ] **Step 5: Update observability section**

Replace `Haunt/scripts/` → `scripts/` in all script references.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md
git commit -m "WIP Update CLAUDE.md for plugin-based distribution"
```

---

### Task 11: Update README.md

Add install instructions and update for the plugin distribution model.

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add Quick Install section near the top**

Per the spec's README onboarding section:

```markdown
## Quick Install

1. Add the Haunt marketplace (one-time):
   ```
   /plugin marketplace add ghost-county/haunt
   ```

2. Install the plugin:
   ```
   /plugin install haunt@ghost-county-haunt
   ```

That's it. Updates are automatic.
```

- [ ] **Step 2: Add migration section**

```markdown
### Migrating from setup-haunt.sh

If you previously used `setup-haunt.sh`:

\`\`\`bash
bash scripts/migrate-to-plugin.sh          # Preview cleanup
bash scripts/migrate-to-plugin.sh --execute # Remove old file copies
\`\`\`

Then follow Quick Install above.
```

- [ ] **Step 3: Update any references to Haunt/ paths**

Replace `Haunt/` prefixes with root-relative paths throughout the README.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "WIP Update README with plugin install instructions"
```

---

### Task 12: Update Internal Path References

Scripts, hooks, and docs may reference `Haunt/` paths internally. Find and fix all stale references.

**Files:**
- Modify: Various scripts, hooks, and docs

- [ ] **Step 1: Find all Haunt/ path references**

```bash
grep -r "Haunt/" --include="*.sh" --include="*.md" --include="*.py" --include="*.yaml" --include="*.json" . | grep -v ".git/" | grep -v "docs/archive/" | grep -v "docs/superpowers/"
```

- [ ] **Step 2: Fix each reference**

For each match, update the path to remove the `Haunt/` prefix. Common patterns:
- `Haunt/scripts/` → `scripts/`
- `Haunt/docs/` → `docs/`
- `Haunt/hooks/` → `hooks/`
- `Haunt/agents/` → `agents/`

- [ ] **Step 3: Verify no stale references remain**

Re-run the grep from Step 1. Expected: No matches outside of archive/spec docs.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "WIP Fix internal path references after Haunt/ flattening"
```

---

### Task 13: Add .gitignore Entry

Ensure `.haunt/` runtime directory is gitignored.

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Add .haunt/ to .gitignore**

```
# Haunt runtime directory (session state, logs)
.haunt/
```

- [ ] **Step 2: Commit**

```bash
git add .gitignore
git commit -m "WIP Add .haunt/ runtime directory to .gitignore"
```

---

### Task 14: Verification

End-to-end verification that the plugin structure is correct.

**Files:**
- None (read-only verification)

- [ ] **Step 1: Verify plugin structure matches reference**

```bash
# Must exist
ls .claude-plugin/plugin.json
ls .claude-plugin/marketplace.json
ls hooks/hooks.json

# Valid JSON
python3 -m json.tool .claude-plugin/plugin.json > /dev/null
python3 -m json.tool .claude-plugin/marketplace.json > /dev/null
python3 -m json.tool hooks/hooks.json > /dev/null
```

- [ ] **Step 2: Verify all expected content exists**

```bash
ls agents/gco-*.md | wc -l        # Should be 6
ls rules/gco-*.md | wc -l         # Should be 6
ls skills/gco-* -d | wc -l        # Should be 16
ls commands/*.md | wc -l           # Should be 4
ls hooks/*.sh | wc -l              # Should be 6+
ls hooks/damage-control/*.py | wc -l  # Should be 3
```

- [ ] **Step 3: Verify Haunt/ is gone**

```bash
[[ ! -d Haunt/ ]] && echo "PASS: Haunt/ removed" || echo "FAIL: Haunt/ still exists"
```

- [ ] **Step 4: Verify no broken internal references**

```bash
grep -r "Haunt/" --include="*.sh" --include="*.md" --include="*.py" --include="*.yaml" --include="*.json" . | grep -v ".git/" | grep -v "docs/archive/" | grep -v "docs/superpowers/" | grep -v "CHANGELOG" | wc -l
# Should be 0
```

- [ ] **Step 5: Test plugin install locally**

```bash
# Add as marketplace
# /plugin marketplace add ghost-county/haunt

# Verify it appears
# /plugin list
```

Note: This step requires pushing to GitHub first and running in Claude Code interactively.

- [ ] **Step 6: Final commit — squash WIPs or tag release**

```bash
git tag v1.0.0
git push origin main --tags
```
