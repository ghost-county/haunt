# Migration Script Documentation

## migrate-to-sdlc.sh

**Purpose:** Safely migrate existing Haunt project files from root-level directories to the consolidated `.haunt/` structure.

**Version:** 1.0
**Created:** 2025-12-10
**Related:** REQ-086, SDLC-DIRECTORY-SPEC.md

---

## Overview

The migration script automates the process of moving SDLC working files from scattered root-level directories (`plans/`, `progress/`, `completed/`, `tests/`, `INITIALIZATION.md`) into a single `.haunt/` directory. This improves project organization and separates framework artifacts from project source code.

### What Gets Migrated

| Old Location | New Location | Description |
|--------------|--------------|-------------|
| `plans/roadmap.md` | `.haunt/plans/roadmap.md` | Active requirements roadmap |
| `plans/feature-contract.json` | `.haunt/plans/feature-contract.json` | Feature contracts |
| `plans/*` | `.haunt/plans/*` | All planning documents |
| `progress/*` | `.haunt/progress/*` | Session progress reports |
| `completed/*` | `.haunt/completed/*` | Completed requirements archive |
| `tests/patterns/*` | `.haunt/tests/patterns/*` | Pattern defeat tests |
| `tests/behavior/*` | `.haunt/tests/behavior/*` | Behavior verification tests |
| `tests/e2e/*` | `.haunt/tests/e2e/*` | End-to-end workflow tests |
| `INITIALIZATION.md` | `.haunt/docs/INITIALIZATION.md` | Project initialization record |

### What Stays in Place

- `.claude/` - Project-specific agent configurations
- `Haunt/` - Framework definitions and scripts
- `Skills/` - Reusable skills library (organized by category: SDLC/, code-patterns/, etc.)
- `CLAUDE.md` - Project instructions
- Your actual project source code

---

## Usage

### Basic Migration

```bash
# Preview what will be moved (recommended first step)
bash Haunt/scripts/utils/migrate-to-sdlc.sh --dry-run

# Perform the migration
bash Haunt/scripts/utils/migrate-to-sdlc.sh

# If something goes wrong, rollback
bash Haunt/scripts/utils/migrate-to-sdlc.sh --rollback
```

### Command-Line Options

```
--dry-run       Preview changes without moving files
--rollback      Reverse migration from most recent backup
--no-backup     Skip backup creation (faster but riskier)
-h, --help      Show help message
```

---

## Safety Features

### 1. Automatic Backup
By default, the script creates a timestamped backup before moving any files:

```
.haunt-backup-20251210-130453/
└── rollback-manifest.txt  # Lists all moved files for rollback
```

### 2. Dry-Run Mode
Preview exactly what will happen without making changes:

```bash
bash migrate-to-sdlc.sh --dry-run
```

Output shows:
- Which directories will be created
- Which files will be moved
- Final statistics (files, directories, errors)

### 3. Rollback Support
Undo the migration completely:

```bash
bash migrate-to-sdlc.sh --rollback
```

The script:
1. Finds the most recent backup
2. Restores all files to original locations
3. Preserves the backup for verification

### 4. Prerequisites Check
Before migrating, the script verifies:
- You're in a valid Haunt project (has `CLAUDE.md` or `.claude/`)
- `.haunt/` directory doesn't already exist or is empty
- Source files exist to migrate

### 5. Graceful Error Handling
- Missing source directories/files are skipped with warnings
- Empty directories are removed automatically
- All errors are logged and counted
- Exit code reflects success (0) or failure (non-zero)

---

## Migration Process

### What the Script Does

1. **Prerequisites Check**
   - Validates project structure
   - Checks for existing `.haunt/` directory
   - Verifies source files exist

2. **Create Backup** (unless `--no-backup`)
   - Creates timestamped backup directory
   - Generates rollback manifest

3. **Create .haunt/ Structure**
   - Creates directory tree
   - Generates `.haunt/.gitignore`

4. **Migrate Files**
   - Moves `plans/` → `.haunt/plans/`
   - Moves `progress/` → `.haunt/progress/`
   - Moves `completed/` → `.haunt/completed/`
   - Moves `tests/patterns/` → `.haunt/tests/patterns/`
   - Moves `tests/behavior/` → `.haunt/tests/behavior/`
   - Moves `tests/e2e/` → `.haunt/tests/e2e/`
   - Moves `INITIALIZATION.md` → `.haunt/docs/INITIALIZATION.md`

5. **Update .gitignore**
   - Adds `.haunt/` entries to project root `.gitignore`
   - Preserves existing ignore rules

6. **Clean Up**
   - Removes empty source directories

---

## Example Migration Session

```bash
# Step 1: Preview the migration
$ bash Haunt/scripts/utils/migrate-to-sdlc.sh --dry-run

[INFO] Dry-run mode enabled.
[SUCCESS] Prerequisites check passed.
[DRY-RUN] Would create directory: .haunt/plans
[DRY-RUN] Would move: plans/roadmap.md → .haunt/plans/roadmap.md
...
Files moved:    27
Directories:    9
Errors:         0

# Step 2: Perform the migration
$ bash Haunt/scripts/utils/migrate-to-sdlc.sh

[SUCCESS] Backup directory created: .haunt-backup-20251210-130453
[INFO] Created directory: .haunt
[SUCCESS] Moved 9 file(s) from plans to .haunt/plans
...
[SUCCESS] Migration completed successfully!

Next steps:
  1. Verify migration: ls -la .haunt/
  2. Test your workflows with new paths
  3. Commit changes: git add .haunt/ .gitignore
  4. Remove backup once verified: rm -rf .haunt-backup-*

# Step 3: Verify the migration
$ ls -la .haunt/
drwxr-xr-x  9 user  staff  288 Dec 10 13:04 .
drwxr-xr-x 16 user  staff  512 Dec 10 13:04 ..
-rw-r--r--  1 user  staff  288 Dec 10 13:04 .gitignore
drwxr-xr-x  6 user  staff  192 Dec 10 13:04 completed
drwxr-xr-x  3 user  staff   96 Dec 10 13:04 docs
drwxr-xr-x 11 user  staff  352 Dec 10 13:04 plans
drwxr-xr-x 12 user  staff  384 Dec 10 13:04 progress
drwxr-xr-x  2 user  staff   64 Dec 10 13:04 scripts
drwxr-xr-x  5 user  staff  160 Dec 10 13:04 tests

$ cat .haunt/plans/roadmap.md
# Success! File migrated correctly

# Step 4: Commit the changes
$ git add .haunt/ .gitignore
$ git commit -m "Migrate SDLC files to .haunt/ structure"

# Step 5: Remove backup
$ rm -rf .haunt-backup-20251210-130453
```

---

## Rollback Example

```bash
# Oh no! Something went wrong after migration
$ bash Haunt/scripts/utils/migrate-to-sdlc.sh --rollback

[INFO] Rollback mode enabled.
[INFO] Found backup: .haunt-backup-20251210-130453
[SUCCESS] Restored: .haunt/plans/roadmap.md → plans/roadmap.md
[SUCCESS] Restored: .haunt/progress/... → progress/...
...
[SUCCESS] Restored 27 file(s) from backup.
[INFO] Rollback complete. Backup preserved at: .haunt-backup-*

# Verify everything is back
$ ls plans/
roadmap.md  feature-contract.json  ...

# Files are restored!
```

---

## Troubleshooting

### Error: "Directory .haunt/ is not empty"

**Problem:** The `.haunt/` directory already exists and has files.

**Solution:**
```bash
# Option 1: Remove existing .haunt/ if it's safe
rm -rf .haunt/

# Option 2: Rename existing .haunt/ to preserve it
mv .haunt/ .haunt.backup/

# Then run migration again
bash Haunt/scripts/utils/migrate-to-sdlc.sh
```

### Error: "Not in a valid Haunt project"

**Problem:** Script can't find `CLAUDE.md` or `.claude/` directory.

**Solution:**
```bash
# Make sure you're in the project root
cd /path/to/your/project

# Verify you have SDLC markers
ls -la CLAUDE.md .claude/

# Then run migration
bash Haunt/scripts/utils/migrate-to-sdlc.sh
```

### Warning: "No source directories/files found"

**Problem:** No SDLC files exist to migrate.

**Solution:** This is normal for new projects. The migration script is only needed for existing projects with scattered SDLC files.

### Issue: Rollback fails with "No backup found"

**Problem:** Backup was deleted or migration was run with `--no-backup`.

**Solution:**
```bash
# Check for any backups
ls -la .haunt-backup-*

# If no backups exist, manually restore from git history
git checkout HEAD~1 -- plans/ progress/ completed/ tests/ INITIALIZATION.md
```

---

## Post-Migration Workflow

### Update Your Scripts

If you have custom scripts that reference old paths, update them:

```bash
# Old
cat plans/roadmap.md

# New
cat .haunt/plans/roadmap.md
```

### Update Agent Character Sheets

If agents reference specific file paths, update their context:

```markdown
# Before
Read `plans/roadmap.md` for current work items.

# After
Read `.haunt/plans/roadmap.md` for current work items.
```

### Update Documentation

Update any project documentation that references old paths:

```markdown
# Before
Progress reports are in `progress/session-*.md`

# After
Progress reports are in `.haunt/progress/session-*.md`
```

---

## Git Integration

### Recommended .gitignore

The migration script automatically adds these entries to your `.gitignore`:

```gitignore
# Haunt working files (ephemeral)
.haunt/plans/
.haunt/progress/
.haunt/completed/
.haunt/docs/

# Preserve SDLC tests and scripts (optionally shareable)
!.haunt/tests/
!.haunt/scripts/
!.haunt/README.md
```

### Committing the Migration

```bash
# After successful migration
git add .haunt/ .gitignore

# Remove old directories from git (already moved by script)
git add -u

# Commit the migration
git commit -m "Migrate SDLC files to .haunt/ directory structure

- Consolidate plans/, progress/, completed/, tests/ into .haunt/
- Update .gitignore to preserve tests and scripts
- Improve project organization and separation of concerns

See: Haunt/SDLC-DIRECTORY-SPEC.md"
```

---

## Performance Notes

### Typical Migration Times

- **Small project** (< 50 files): ~1 second
- **Medium project** (50-200 files): ~2-3 seconds
- **Large project** (200+ files): ~5-10 seconds

### Disk Space Requirements

Backup requires approximately 2x the size of migrated files:
- Original files: X MB
- Backup copy: X MB
- Total: 2X MB

After verifying migration, remove backup to reclaim space:
```bash
rm -rf .haunt-backup-*
```

---

## Advanced Usage

### Skip Backup (Faster but Riskier)

```bash
# Skip backup creation for faster migration
bash migrate-to-sdlc.sh --no-backup

# WARNING: No rollback possible without backup!
```

### Multiple Migrations

If you run migration multiple times, the script:
1. Creates a new timestamped backup each time
2. Only the most recent backup is used for rollback
3. Old backups remain until manually deleted

### Custom Migration

For partial migrations, manually move specific directories:

```bash
# Only migrate plans
mkdir -p .haunt/plans
mv plans/* .haunt/plans/

# Only migrate tests
mkdir -p .haunt/tests/patterns
mv tests/patterns/* .haunt/tests/patterns/
```

---

## Related Documentation

- **SDLC-DIRECTORY-SPEC.md** - Complete `.haunt/` directory specification
- **setup-haunt.sh** - Initial project setup (includes `.haunt/` creation)
- **verify-precommit-setup.sh** - Validates `.haunt/` structure exists

---

## Support

For issues or questions:

1. Check troubleshooting section above
2. Review dry-run output for clues
3. Check backup manifest: `cat .haunt-backup-*/rollback-manifest.txt`
4. Restore from backup if needed: `--rollback`

---

## Changelog

### Version 1.0 (2025-12-10)
- Initial release
- Supports dry-run, rollback, no-backup modes
- Automatic backup creation
- Graceful error handling
- Empty directory cleanup
- .gitignore auto-update
