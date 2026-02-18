# Ship (Create PR and Merge)

Create a PR for the current feature branch and enable auto-merge.

## Usage

```bash
/ship                 # Ship current feature branch
/ship --draft         # Create draft PR
```

## Arguments: $ARGUMENTS

### Step 1: Verify Prerequisites

Before proceeding, verify:

1. **On feature branch**: Must NOT be on `main` or `master`
2. **Tests passing**: Run project tests (npm test, pytest, etc.)
3. **Changes committed**: No uncommitted changes
4. **Branch pushed**: Branch must be pushed to remote

**If any check fails, STOP and report the issue.**

### Step 2: Gather Context

```bash
# Get current branch
current_branch=$(git branch --show-current)

# Verify not on main
if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    echo "ERROR: Cannot ship from $current_branch. Switch to a feature branch first."
    exit 1
fi

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo "Uncommitted changes detected. Commit or stash before shipping."
    git status --short
    exit 1
fi

# Get commit log for PR body
commits=$(git log main..HEAD --oneline)
diff_stat=$(git diff main..HEAD --stat)
```

### Step 3: Generate PR

Build the PR title and body from git history:

- **Title**: Use branch name or first commit message, kept under 70 chars
- **Body**: Include commit list, diff stats, and test plan

```bash
# Parse --draft flag
is_draft=false
[[ "$ARGUMENTS" == *"--draft"* ]] && is_draft=true

# Create PR
if [[ "$is_draft" == "true" ]]; then
    gh pr create --title "$pr_title" --body "$pr_body" --draft
else
    gh pr create --title "$pr_title" --body "$pr_body" --base main
fi
```

### Step 4: Enable Auto-Merge

```bash
# Enable auto-merge if repository supports it
if gh pr merge --auto --squash --delete-branch 2>/dev/null; then
    echo "Auto-merge enabled (will merge when checks pass)"
else
    echo "Auto-merge not available (manual merge required)"
fi
```

### Step 5: Report

Show the PR URL and status.

## PR Body Format

```markdown
## Summary
- [bullet points from commit messages]

## Changes
[git diff --stat output]

## Test Plan
- [ ] Tests pass locally
- [ ] Manual verification complete

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

## Error Handling

| Error Condition | Action |
|----------------|--------|
| On main/master | Exit with instructions to switch branch |
| Tests failing | Exit with instruction to fix tests |
| Uncommitted changes | Exit with commit/stash options |
| gh CLI not authenticated | Exit with `gh auth login` instruction |
| Merge conflict | Exit (manual resolution needed) |
