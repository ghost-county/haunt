---
name: haunt-report
description: Report a bug or feature request for the Haunt framework to the maintainers
---

# Report Issue to Haunt Maintainers

Report bugs, request features, or ask questions about the Haunt framework.

## What This Does

This command helps you create a detailed issue report on the main Haunt GitHub repository by:

1. **Collecting diagnostic information** (Haunt version, OS, recent errors)
2. **Guiding you through issue creation** (type, title, description)
3. **Automatically creating the issue** (via GitHub CLI) or opening your browser with a pre-filled template

## What Gets Collected

**Diagnostic data included:**
- Haunt version
- Operating system and architecture
- Claude Code version
- Recent error logs (last 10 lines from `.haunt/integration.log` if present)

**Privacy:** No sensitive data (tokens, API keys, credentials, or project code) is collected.

## Requirements

**Recommended (automated):**
- GitHub CLI (`gh`) installed and authenticated

**Fallback (manual):**
- Web browser (opens GitHub with pre-filled issue)

## Installation of GitHub CLI (Optional)

**macOS:**
```bash
brew install gh
gh auth login
```

**Linux:**
```bash
# See https://github.com/cli/cli#installation
sudo apt install gh  # Debian/Ubuntu
gh auth login
```

**Windows:**
```bash
# See https://github.com/cli/cli#installation
winget install GitHub.cli
gh auth login
```

**Note:** You only need to authenticate once with `gh auth login`.

## Usage

```bash
claude /haunt-report
```

**Or directly:**
```bash
bash Haunt/scripts/haunt-report.sh
```

## Interactive Prompts

The command will ask you:

1. **Issue type:**
   - 🐛 Bug Report
   - ✨ Feature Request
   - 📚 Documentation Issue
   - ❓ Question

2. **Title:** Short summary of the issue

3. **Description:** Detailed explanation (type 'END' on new line to finish, or press Ctrl+D)

## Examples

**Bug Report:**
```
Issue type: 1 (Bug Report)
Title: Session startup fails on macOS Sonoma
Description: When running session-startup protocol, git status 
command fails with "permission denied" error. This started after 
upgrading to macOS 14.2.
END
```

**Feature Request:**
```
Issue type: 2 (Feature Request)
Title: Add support for GitLab issue integration
Description: Similar to GitHub integration, would be great to 
support GitLab issues with @haunt marker detection.
END
```

**Documentation:**
```
Issue type: 3 (Documentation)
Title: SETUP-GUIDE.md missing step for Windows users
Description: The setup guide doesn't mention that Windows users 
need to run the script in Git Bash, not PowerShell.
END
```

## How It Works

**With GitHub CLI (automated):**
1. Collects diagnostics
2. Prompts for issue details
3. Creates issue on `github.com/ghost-county/haunt`
4. Returns issue URL for tracking

**Without GitHub CLI (browser fallback):**
1. Collects diagnostics
2. Prompts for issue details
3. Opens browser with pre-filled GitHub issue template
4. You review and click "Submit new issue"

## After Submission

- You'll receive the issue URL
- Maintainers will be notified
- You can track the issue on GitHub
- You may receive follow-up questions in issue comments

## Troubleshooting

**"GitHub CLI not found"**
- Install `gh` CLI (see Installation above), or
- Use browser fallback (script handles this automatically)

**"Not authenticated with GitHub"**
- Run: `gh auth login`
- Follow prompts to authenticate

**"Could not open browser"**
- Script will print the GitHub URL
- Copy and paste into your browser manually

**"Failed to encode issue body"**
- Python 3 may not be available
- Script will show the issue text
- Manually create issue at: `https://github.com/ghost-county/haunt/issues/new`

## Privacy & Security

**What's sent:**
- Haunt version number
- OS name and version
- Recent error messages from logs
- Your issue description

**What's NOT sent:**
- GitHub tokens or API keys
- Project code or file contents
- Environment variables
- User credentials
- Personal data

**Data visibility:**
- Issues are public on GitHub
- Don't include sensitive information in your description
- Logs are sanitized to remove tokens/secrets

## See Also

- [GitHub Issues](https://github.com/ghost-county/haunt/issues) - View existing issues
- [Contributing Guidelines](https://github.com/ghost-county/haunt/blob/main/CONTRIBUTING.md)
- `/haunt` command - Check Haunt installation health
- `/checkup` command - Verify framework setup

## Thank You!

Your feedback helps make Haunt better for everyone. Every bug report, feature request, and documentation improvement is appreciated. 👻
