---
name: test-skill
description: Format file listings as markdown tables with specific columns. Invoke when user requests file inventory or directory listings in structured format.
---

# Test Skill: File Listing Formatter

## Purpose

This skill provides guidance for formatting file listings as structured markdown tables. This is a proof-of-concept skill to validate the dynamic skill invocation pattern.

## When to Invoke

- User requests file inventory
- User asks for directory contents in structured format
- Task requires listing files with metadata

## Table Format

When presenting file listings, use this exact format:

| Filename | Size | Type | Last Modified |
|----------|------|------|---------------|
| [name]   | [size] | [extension or "directory"] | [date] |

## Column Specifications

1. **Filename**: Basename only (no full path)
2. **Size**: Human-readable (e.g., "2.4 KB", "1.2 MB", "N/A" for directories)
3. **Type**: File extension (e.g., ".md", ".py") or "directory"
4. **Last Modified**: ISO date format (YYYY-MM-DD)

## Example Output

```markdown
| Filename | Size | Type | Last Modified |
|----------|------|------|---------------|
| README.md | 2.4 KB | .md | 2025-12-09 |
| scripts | N/A | directory | 2025-12-08 |
| main.py | 1.1 KB | .py | 2025-12-07 |
```

## Implementation Notes

- Sort by filename alphabetically
- Directories first, then files
- Use `ls -lh` or equivalent to get file sizes
- Use `stat` command for precise modification times

## Success Criteria

An agent successfully using this skill will:
1. Recognize when file listing task requires structured format
2. Read this skill file mid-session (not have it pre-loaded)
3. Apply the exact table format specified above
4. Include all 4 columns in correct order
