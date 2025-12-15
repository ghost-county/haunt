---
name: file-operations
description: Correct file operations patterns for Read, Write, Edit, Glob, and Grep tools. Invoke when file operations fail, on "can't read file", "file not found", "path error", "Error writing file", or at session startup for agents handling files.
---

# File Operations

Patterns for reliable file operations that avoid common agent errors.

## Critical Rules

### 1. ALWAYS Read Before Write/Edit

```
# WRONG - Will fail
Write(file_path="/path/to/existing/file.md")
Edit(file_path="/path/to/file.md", old_string="...", new_string="...")

# RIGHT - Read first, then modify
Read(file_path="/path/to/existing/file.md")  # Must do this first
Write(file_path="/path/to/existing/file.md", content="...")
# OR
Read(file_path="/path/to/file.md")  # Must do this first
Edit(file_path="/path/to/file.md", old_string="...", new_string="...")
```

**Why:** The tools enforce this to prevent accidental overwrites and ensure you understand the file's current state.

### 2. Use Absolute Paths

```
# WRONG
Read(file_path="src/config.js")
Read(file_path="./Skills/session-startup/SKILL.md")

# RIGHT
Read(file_path="/Users/name/project/src/config.js")
Read(file_path="/Users/name/project/Haunt/skills/gco-session-startup/SKILL.md")
```

### 3. Verify Paths Before Operations

When unsure if a path exists or is correct:

```
# Find the actual path first
Glob(pattern="**/requirements-elicitation/**")
# OR
Glob(pattern="Skills/**/SKILL.md")

# Then read the correct path from results
Read(file_path="/actual/path/from/glob/results")
```

### 4. Know the Directory Structure

Common path mistakes in this repository:

| Wrong Path | Correct Path |
|------------|--------------|
| `Skills/session-startup/` | `Haunt/skills/gco-session-startup/` |
| `Skills/code-patterns/` | `Haunt/skills/gco-code-patterns/` |
| `Skills/commit-conventions/` | `Haunt/skills/gco-commit-conventions/` |
| `agents/dev.md` | `Haunt/agents/gco-dev.md` or `.claude/agents/gco-dev.md` |

**Skills directory structure:**
```
Haunt/skills/                 # Ghost County methodology skills
├── gco-session-startup/
├── gco-code-patterns/
├── gco-commit-conventions/
├── gco-roadmap-workflow/
└── ...

Skills/                       # Domain-specific skills
├── requirements-elicitation/  # Requirements analysis skill
├── file-operations/           # This skill
├── skill-creator/             # Skill authoring guidance
└── third-party/               # External/domain-specific skills
    ├── pitch-deck-builder/
    ├── resume-builder/
    └── ...
```

## Tool Selection Guide

| Task | Tool | Notes |
|------|------|-------|
| Read single file | `Read` | Requires absolute path |
| Find files by pattern | `Glob` | Use `**` for recursive |
| Search file contents | `Grep` | Returns matching files or content |
| Create new file | `Write` | Parent dir must exist |
| Modify existing file | `Edit` | Must Read first; old_string must be unique |
| Overwrite entire file | `Write` | Must Read first if file exists |

## Common Errors and Fixes

### Error: "File has not been read yet"

**Cause:** Attempting Write or Edit on a file you haven't Read in this session.

**Fix:**
```
# Always read first
Read(file_path="/path/to/file.md")
# Now you can write or edit
Write(file_path="/path/to/file.md", content="...")
```

### Error: "File does not exist" on Read

**Cause:** Wrong path or file genuinely doesn't exist.

**Fix:**
```
# Use Glob to find the actual path
Glob(pattern="**/filename.md")
# Or search for content you know is in the file
Grep(pattern="unique content", output_mode="files_with_matches")
```

### Error: "old_string not found" on Edit

**Cause:** The exact string doesn't exist in the file (whitespace, encoding, or content mismatch).

**Fix:**
```
# Re-read the file to see current content
Read(file_path="/path/to/file.md")
# Copy the EXACT text including whitespace for old_string
# Line numbers in Read output help locate the text
```

### Error: "old_string is not unique" on Edit

**Cause:** The string appears multiple times in the file.

**Fix:**
```
# Include more context to make it unique
Edit(
  file_path="/path/to/file.md",
  old_string="## Section Header\n\nThe text to change",  # More context
  new_string="## Section Header\n\nThe new text"
)
# OR use replace_all=true if you want to change all occurrences
Edit(
  file_path="/path/to/file.md",
  old_string="old",
  new_string="new",
  replace_all=true
)
```

## Operation Patterns

### Pattern: Find and Read

When you don't know the exact path:

```
1. Glob(pattern="**/config*.json")
   → Returns list of matching paths
2. Read(file_path="/project/src/config.json")  # Use actual path from results
```

### Pattern: Safe File Edit

```
1. Read(file_path="/path/to/file.md")           # Required first step
2. Edit(file_path="/path/to/file.md",
        old_string="exact text from file",
        new_string="replacement text")
3. Read(file_path="/path/to/file.md")           # Optional: verify change
```

### Pattern: Create New File

```
1. Glob(pattern="/path/to/dir/*")               # Verify directory exists
2. Write(file_path="/path/to/dir/newfile.md",
         content="file contents")
```

### Pattern: Search Then Modify

```
1. Grep(pattern="function oldName", output_mode="files_with_matches")
   → Returns: /project/src/utils.js
2. Read(file_path="/project/src/utils.js")
3. Edit(file_path="/project/src/utils.js",
        old_string="function oldName",
        new_string="function newName",
        replace_all=true)
```

## Quick Diagnostics

When file operations fail, check in order:

1. **Is path absolute?** Must start with `/`
2. **Did you Read first?** Required before Write/Edit on existing files
3. **Does the file/directory exist?** Use Glob to verify
4. **Is the path correct?** Check Haunt/skills/ vs Skills/third-party/ etc.
5. **For Edit: Is old_string exact?** Copy from Read output, preserve whitespace
6. **For Edit: Is old_string unique?** Include more context or use replace_all

## Session Startup Checklist

At the start of any session involving file operations:

- [ ] Note the working directory (from environment info)
- [ ] Understand the project structure (use Glob if unfamiliar)
- [ ] Use absolute paths for all operations
- [ ] Read files before attempting to modify them
