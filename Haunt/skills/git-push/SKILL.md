---
name: git-push
description: Commit all changes and push to remote. Use when user says "git push", "commit and push", or invokes /git-push.
---

# Git Commit and Push

Commit staged and unstaged changes, then push to remote.

## Workflow

**Step 1: Gather Context (parallel)**

Run these commands simultaneously:
- `git status` - See all changes
- `git diff --stat` - See what changed
- `git log --oneline -5` - Recent commit style

**Step 2: Stage Changes**

```bash
git add -A
```

**Step 3: Commit**

Draft a concise commit message based on the changes. Follow the repository's commit style from Step 1.

```bash
git commit -m "$(cat <<'EOF'
[Commit message here]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Step 4: Push**

```bash
git push
```

If no upstream is set:
```bash
git push -u origin HEAD
```

## Rules

- NEVER force push to main/master
- NEVER skip hooks unless user explicitly requests
- NEVER commit .env files or secrets
- If nothing to commit, say so and stop
- If push fails due to diverged branches, ask user before proceeding

## Output

Report:
1. What was committed (brief summary)
2. Commit hash
3. Push status (success/failure)
