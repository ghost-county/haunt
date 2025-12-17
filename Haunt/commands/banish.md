# Banish (Archive Completed Work)

Archive completed requirements from the roadmap, sending them to rest in the `.haunt/completed/roadmap-archive.md`.

## Usage

```
/banish REQ-123           # Archive a specific completed requirement
/banish --all             # Archive all 🟢 Complete requirements
/banish --all-complete    # Archive all 🟢 Complete requirements (alias for --all)
```

## Arguments: $ARGUMENTS

### Validation

Before banishing any requirement:

1. **Verify completion status**: Requirement MUST be marked 🟢 Complete
2. **Check completion criteria**: All criteria in "Completion:" field must be met
3. **Verify all tasks checked**: All `- [x]` items must be checked off
4. **Confirm files updated**: All files in "Files:" section modified/created

If any validation fails, STOP and report which criterion is not met.

### Archival Process

#### For Single Requirement (`/banish REQ-123`)

1. Read `.haunt/plans/roadmap.md`
2. Find the requirement with status 🟢
3. Extract the full requirement block
4. Append to `.haunt/completed/roadmap-archive.md` using this format:

```markdown
## Archived YYYY-MM-DD

### 🟢 REQ-XXX: [Requirement Title]

**Completed by:** [Agent type from "Agent:" field]
**Date:** [Today's date YYYY-MM-DD]
**Effort:** [S or M from requirement]
**Files Changed:** [List from "Files:" section]

**Tasks Completed:**
- [List all tasks from "Tasks:" section]

**Completion Criteria Met:**
- [List all criteria from "Completion:" field]

**Notes:**
[Implementation Notes if present, or "No additional notes"]

---
```

5. Remove the requirement from `.haunt/plans/roadmap.md`
6. Report success with REQ number and archive location

#### For All Complete (`/banish --all` or `/banish --all-complete`)

Both `--all` and `--all-complete` work identically:

1. Read `.haunt/plans/roadmap.md`
2. Find ALL requirements with 🟢 status
3. Validate each one (as above)
4. Archive each using the single-requirement process
5. Report count of archived requirements

### Error Handling

- **Requirement not found**: Report "REQ-XXX not found in roadmap"
- **Not complete**: Report "REQ-XXX is [status icon], not 🟢 Complete. Cannot archive."
- **Validation failed**: Report specific failure (unchecked tasks, unmet criteria, etc.)
- **No complete items**: Report "No completed requirements found to archive"

### Ghost County Flavor

When reporting success, use themed language:
- "Banished REQ-XXX to the archives. The spirit rests."
- "Banished 5 completed requirements. The haunting grows lighter."
- "The roadmap is cleansed. 3 spirits sent to eternal rest."

When reporting errors, maintain the theme:
- "Cannot banish REQ-XXX - it still walks among the living (status: 🟡)"
- "REQ-XXX resists banishment - tasks remain unchecked"
- "No spirits ready for the crossing. All work remains active."
