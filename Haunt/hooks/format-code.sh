#!/bin/bash
#
# format-code.sh - Auto-format code after Edit/Write/MultiEdit operations
#
# This hook runs linting tools on files modified by Claude Code.
# Tools auto-detect project-level configs (pyproject.toml, .eslintrc, etc.)
# Missing tools are gracefully skipped (via command -v checks).
#
# Part of the Haunt framework: https://github.com/ghost-county/haunt
#

# Skip if disabled
[[ "$HAUNT_LINTERS_DISABLED" == "1" ]] && exit 0

# Process each modified file
for file in $CLAUDE_FILE_PATHS; do
  # Skip if file doesn't exist (was deleted)
  [[ ! -f "$file" ]] && continue

  case "$file" in
    *.sh)
      # ShellCheck for bash scripts (lint only, no auto-fix)
      command -v shellcheck >/dev/null && shellcheck "$file"
      ;;
    *.py)
      # Ruff for Python (lint + format)
      if command -v ruff >/dev/null; then
        ruff check --fix "$file"
        ruff format "$file"
      fi
      ;;
    *.sql)
      # SQLFluff for SQL (Snowflake dialect by default)
      # Note: SQLFluff is slow, uses large_file_skip_byte_limit if configured
      command -v sqlfluff >/dev/null && sqlfluff fix --dialect snowflake "$file"
      ;;
    *.ts|*.tsx|*.js|*.jsx)
      # ESLint + Prettier for TypeScript/JavaScript
      command -v eslint >/dev/null && eslint --fix "$file"
      command -v prettier >/dev/null && prettier --write "$file"
      ;;
    *.md)
      # markdownlint for Markdown
      command -v markdownlint >/dev/null && markdownlint --fix "$file"
      ;;
    *.json)
      # Prettier for JSON
      command -v prettier >/dev/null && prettier --write "$file"
      ;;
    *.yaml|*.yml)
      # Prettier for YAML
      command -v prettier >/dev/null && prettier --write "$file"
      ;;
  esac
done 2>/dev/null

# Always exit 0 - formatting is best-effort, shouldn't block work
exit 0
