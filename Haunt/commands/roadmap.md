# Roadmap Management

Manage roadmap sharding and batch organization for improved token efficiency.

## Usage

```bash
/roadmap shard                    # Split roadmap into batch-specific files
/roadmap shard --active "Batch 1" # Shard and mark specific batch as active
/roadmap unshard                  # Merge all batch files back to monolithic roadmap
/roadmap activate "Batch Name"    # Activate a different batch (move to main roadmap)
/roadmap archive "Batch Name"     # Archive completed batch and activate next
```

## Sharding Overview

**Problem:** Large roadmaps (>500 lines, 10+ requirements) consume excessive tokens when loaded for each assignment lookup.

**Solution:** Split roadmap into batch-specific files in `.haunt/plans/batches/`, keeping only the active batch in main `roadmap.md`.

**Token Savings:** 60-80% reduction for large projects (BMAD achieved 31,667 → 8,333 tokens).

---

## Shard Command (`/roadmap shard`)

Split the monolithic roadmap into batch-specific files.

### Sharding Logic

1. **Read roadmap**: Parse `.haunt/plans/roadmap.md`
2. **Identify batches**: Extract all `## Batch: [Name]` headers
3. **Extract requirements**: Group all requirements under each batch header until next `##` or EOF
4. **Create batch files**: Write to `.haunt/plans/batches/batch-N-[slug].md`
5. **Generate overview**: Create lightweight `roadmap.md` with overview + active batch only
6. **Create directory**: Ensure `.haunt/plans/batches/` exists

### Batch File Format

Each batch file should follow this structure:

```markdown
# Batch: [Batch Name]

> Sharded from roadmap on YYYY-MM-DD
> Contains requirements from original Batch [N]

**Status:** Active / Archived
**Requirements:** X total (Y complete, Z in progress, W not started)
**Estimated Effort:** XX hours remaining

**Goal:** [Batch goal from original roadmap]

---

## Requirements

### 🟡 REQ-001: [Requirement Title]

[Full requirement content with all fields...]

---

### ⚪ REQ-002: [Requirement Title]

[Full requirement content with all fields...]
```

### Overview Roadmap Format

After sharding, main `roadmap.md` should contain:

```markdown
# Haunt Framework Roadmap

> Roadmap is **sharded** for token efficiency. Full batches in `.haunt/plans/batches/`.

---

## Sharding Info

**Status:** Sharded on YYYY-MM-DD
**Active Batch:** [Batch Name]
**Total Batches:** X
**Load Location:** `.haunt/plans/batches/`

---

## Current Focus: [Active Batch Name]

**Goal:** [Active batch goal]

**Active Work:**
- 🟡 REQ-XXX: [Title] (from active batch)

**Recently Completed:**
- 🟢 REQ-XXX: [Title] (from active batch)

---

## Active Batch: [Batch Name]

[Full content of active batch with all requirements]

---

## Other Batches (See .haunt/plans/batches/)

### Batch: Command Improvements
- **File:** `batches/batch-1-command-improvements.md`
- **Progress:** 5/5 Complete (100%)
- **Status:** 🟢 COMPLETE

### Batch: Setup Improvements
- **File:** `batches/batch-2-setup-improvements.md`
- **Progress:** 2/3 Complete (67%)
- **Status:** 🟡 IN PROGRESS

### Batch: BMAD Enhancements - Phase 1
- **File:** `batches/batch-3-bmad-phase-1.md`
- **Progress:** 0/5 Complete (0%)
- **Status:** ⚪ NOT STARTED

Use `/roadmap activate "Batch Name"` to load a different batch.
```

### Implementation Steps

1. **Parse roadmap structure**
   - Identify header (everything before first `## Batch:`)
   - Extract each batch section (from `## Batch:` to next `##` or EOF)
   - Parse batch name from header: `## Batch: [Name]`

2. **Count requirements per batch**
   - Count total REQ-XXX items
   - Count by status (🟢 🟡 ⚪ 🔴)
   - Sum effort for incomplete items (⚪ + 🟡)

3. **Create batch files**
   - Create `.haunt/plans/batches/` directory if missing
   - Generate filename: `batch-N-[slug].md` where slug is lowercase-hyphenated batch name
   - Write batch content with metadata header
   - Store batch count and batch names in memory

4. **Generate overview roadmap**
   - Keep original header and metadata
   - Add "Sharding Info" section
   - Include full active batch content
   - Summarize other batches with links

5. **Determine active batch**
   - If `--active "Batch Name"` flag provided, use that batch
   - Otherwise, use first batch with 🟡 In Progress items
   - If no in-progress items, use first batch with ⚪ Not Started items
   - If all complete, use last batch

6. **Write files**
   - Write each batch file to `.haunt/plans/batches/batch-N-[slug].md`
   - Overwrite main `.haunt/plans/roadmap.md` with overview

### Success Output

```
The spirits shard the roadmap across the ethereal realm...

📊 Sharding Summary:
   Batches detected: 6
   Requirements total: 42
   Active batch: "BMAD Enhancements - Phase 3"

📂 Batch Files Created:
   ✅ batches/batch-1-command-improvements.md (5 requirements, 🟢 COMPLETE)
   ✅ batches/batch-2-setup-improvements.md (3 requirements, 🟡 IN PROGRESS)
   ✅ batches/batch-3-bmad-phase-1.md (5 requirements, 🟢 COMPLETE)
   ✅ batches/batch-4-bmad-phase-2.md (7 requirements, 🟡 IN PROGRESS)
   ✅ batches/batch-5-bmad-phase-3.md (3 requirements, ⚪ NOT STARTED)
   ✅ batches/batch-6-future-work.md (19 requirements, ⚪ NOT STARTED)

📋 Overview Roadmap:
   ✅ roadmap.md updated (300 lines → reduced from 850 lines)
   🎯 Active batch loaded: "BMAD Enhancements - Phase 3"

💾 Token Savings:
   Before: ~2,550 tokens (850 lines)
   After: ~900 tokens (300 lines)
   Reduction: 65% (~1,650 tokens saved per request)

The roadmap is sharded. Access inactive batches via .haunt/plans/batches/
```

### Error Handling

- **No batches found**: "No batch headers (## Batch:) found in roadmap. Cannot shard."
- **Already sharded**: "Roadmap is already sharded (sharding info detected). Use `/roadmap unshard` first."
- **Missing roadmap**: "Roadmap file not found at .haunt/plans/roadmap.md"
- **Empty batch**: "Batch '[Name]' contains no requirements. Skipping."
- **Invalid active batch**: "Batch '[Name]' not found. Available batches: [list]"

---

## Unshard Command (`/roadmap unshard`)

Merge all batch files back into a single monolithic roadmap.

### Unsharding Logic

1. **Read overview roadmap**: Parse current `.haunt/plans/roadmap.md`
2. **Verify sharding**: Check for "Sharding Info" section or "Other Batches" section
3. **Find batch files**: List all `.haunt/plans/batches/batch-*.md` files
4. **Read each batch**: Load content from each batch file
5. **Merge content**: Reconstruct monolithic roadmap with all batches
6. **Write roadmap**: Overwrite `.haunt/plans/roadmap.md` with full content
7. **Keep batch files**: Do NOT delete batch files (backup/reference)

### Merged Roadmap Format

```markdown
# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` for completed work.

---

## Current Focus: [Active Batch Name]

**Goal:** [Goal from active batch]

**Active Work:**
- 🟡 REQ-XXX: [Title]

**Recently Completed:**
- 🟢 REQ-XXX: [Title]

---

## Batch: Command Improvements

[Full batch content...]

---

## Batch: Setup Improvements

[Full batch content...]

---

[... all other batches in original order ...]
```

### Implementation Steps

1. **Detect sharded state**
   - Read `.haunt/plans/roadmap.md`
   - Check for "Sharding Info" section or "Other Batches" heading
   - If not sharded, error and exit

2. **Read batch files**
   - List files in `.haunt/plans/batches/` matching `batch-*.md`
   - Sort by batch number (batch-1, batch-2, etc.)
   - Read each file content

3. **Extract batch content**
   - Skip metadata header (lines before first `##`)
   - Extract "## Requirements" section and all following content
   - Reconstruct as `## Batch: [Name]` section

4. **Build merged roadmap**
   - Start with original header (from overview roadmap)
   - Add Current Focus section (from overview)
   - Append each batch in order
   - Remove "Sharding Info" section
   - Remove "Other Batches" summary section

5. **Write monolithic roadmap**
   - Overwrite `.haunt/plans/roadmap.md`
   - Keep batch files for reference (don't delete)

### Success Output

```
The spirits reunite the sharded realm...

📂 Batch Files Found:
   ✅ batch-1-command-improvements.md (5 requirements)
   ✅ batch-2-setup-improvements.md (3 requirements)
   ✅ batch-3-bmad-phase-1.md (5 requirements)
   ✅ batch-4-bmad-phase-2.md (7 requirements)
   ✅ batch-5-bmad-phase-3.md (3 requirements)
   ✅ batch-6-future-work.md (19 requirements)

📋 Merged Roadmap:
   ✅ roadmap.md rebuilt (850 lines, 6 batches)
   📦 All requirements restored

🗂️  Batch files preserved in .haunt/plans/batches/ (for reference)

The roadmap is whole again. All batches visible in roadmap.md
```

### Error Handling

- **Not sharded**: "Roadmap is not sharded (no sharding info detected). Nothing to unshard."
- **Missing batch files**: "Batch files directory not found at .haunt/plans/batches/"
- **Empty batches dir**: "No batch files found in .haunt/plans/batches/"
- **Parse error**: "Failed to parse batch file: [filename]. Skipping."

---

## Activate Command (`/roadmap activate "Batch Name"`)

Switch the active batch in a sharded roadmap.

### Activation Logic

1. **Verify sharded state**: Roadmap must be sharded
2. **Find batch file**: Locate `batches/batch-N-[slug].md` matching batch name
3. **Read batch content**: Load full batch content from file
4. **Update overview roadmap**: Replace "Active Batch" section with new batch
5. **Update "Sharding Info"**: Change "Active Batch:" field to new batch name
6. **Report change**: Display old batch → new batch transition

### Implementation Steps

1. **Validate sharding**
   - Read `.haunt/plans/roadmap.md`
   - Verify "Sharding Info" section exists
   - If not sharded, error and exit

2. **Find matching batch**
   - Extract batch name from command args
   - Search "Other Batches" section for matching name
   - Find corresponding file path
   - If not found, list available batches and error

3. **Read new batch**
   - Read content from `batches/batch-N-[slug].md`
   - Extract requirements section
   - Parse batch goal/metadata

4. **Update overview roadmap**
   - Replace "Active Batch:" field in "Sharding Info"
   - Replace entire "## Active Batch:" section with new batch content
   - Update "Current Focus:" section with new batch goal
   - Rewrite overview list to reflect status change

5. **Write updated roadmap**
   - Overwrite `.haunt/plans/roadmap.md`
   - Keep all batch files unchanged

### Success Output

```
The spirits shift focus to a new haunting...

🔄 Activating Batch:
   Previous: "BMAD Enhancements - Phase 2"
   New: "BMAD Enhancements - Phase 3"

📂 Loading Batch File:
   ✅ batches/batch-5-bmad-phase-3.md (3 requirements)

📋 Roadmap Updated:
   ✅ Active batch replaced in roadmap.md
   🎯 Current Focus: "BMAD Enhancements - Phase 3"
   ⚪ 3 requirements now visible in main roadmap

The realm refocuses. New batch activated.
```

### Error Handling

- **Not sharded**: "Roadmap is not sharded. Cannot activate batch. Use `/roadmap shard` first."
- **Batch not found**: "Batch '[Name]' not found. Available batches: [list]"
- **Missing batch file**: "Batch file not found: batches/batch-N-[slug].md"
- **Parse error**: "Failed to read batch file: [filename]"
- **Already active**: "Batch '[Name]' is already active. No change needed."

---

## Archive Command (`/roadmap archive "Batch Name"`)

Archive a completed batch and automatically activate the next batch.

### Archival Logic

1. **Verify batch completion**: All requirements in batch must be 🟢 Complete
2. **Move batch file**: Move from `.haunt/plans/batches/` to `.haunt/completed/batches/`
3. **Add archive metadata**: Timestamp archival date in batch file
4. **Update overview roadmap**: Remove batch from "Other Batches" summary
5. **Activate next batch**: Load next unarchived batch as active (if available)
6. **Create archived batches directory**: Ensure `.haunt/completed/batches/` exists

### Implementation Steps

1. **Validate completion**
   - Read batch file from `.haunt/plans/batches/batch-N-[slug].md`
   - Parse all requirements in batch
   - Count status icons (🟢 🟡 ⚪ 🔴)
   - If ANY requirement is not 🟢, error and list incomplete items
   - Completion check is STRICT - all tasks must be checked, all criteria met

2. **Prepare archive**
   - Create `.haunt/completed/batches/` directory if missing
   - Add archival timestamp to batch file metadata
   - Add "Archived: YYYY-MM-DD" field to batch header
   - Update "Status:" field from "Active" or "In Progress" to "Archived"

3. **Archive batch file**
   - Move `batches/batch-N-[slug].md` to `completed/batches/batch-N-[slug]-archived.md`
   - Keep original batch number for ordering reference
   - Add "-archived" suffix to filename for clarity

4. **Update overview roadmap**
   - Remove archived batch from "## Other Batches" section
   - Update "Total Batches:" count in "Sharding Info"
   - Add entry to "Recently Completed:" section if applicable

5. **Determine next batch**
   - List remaining batches in `.haunt/plans/batches/`
   - Find first batch with ⚪ Not Started or 🟡 In Progress items
   - If all remaining batches are 🟢 Complete, offer to archive them too
   - If no batches remain, mark roadmap as "All batches complete"

6. **Activate next batch**
   - If next batch exists, run activate logic (see "Activate Command")
   - Load next batch content into main roadmap
   - Update "Active Batch:" field in "Sharding Info"
   - Report batch transition (archived → activated)

### Archived Batch File Format

Batch files in `.haunt/completed/batches/` should have archival metadata:

```markdown
# Batch: [Batch Name]

> Sharded from roadmap on YYYY-MM-DD
> **Archived:** YYYY-MM-DD
> Contains requirements from original Batch [N]

**Status:** Archived
**Requirements:** X total (all 🟢 Complete)
**Estimated Effort:** 0 hours remaining (XX hours total)
**Completion Date:** YYYY-MM-DD

**Goal:** [Batch goal from original roadmap]

---

## Requirements

### 🟢 REQ-001: [Requirement Title]

**Completed:** YYYY-MM-DD

[Full requirement content with all tasks checked...]

---

### 🟢 REQ-002: [Requirement Title]

**Completed:** YYYY-MM-DD

[Full requirement content with all tasks checked...]
```

### Success Output

```
The spirits lay the completed work to rest...

✅ Batch Verification:
   Batch: "Command Improvements"
   Requirements: 5/5 Complete (100%)
   All tasks checked: ✓
   All criteria met: ✓

📦 Archiving Batch:
   Source: batches/batch-1-command-improvements.md
   Destination: completed/batches/batch-1-command-improvements-archived.md
   ✅ Batch archived with completion timestamp

🔄 Activating Next Batch:
   Previous: "Command Improvements" (archived)
   Next: "Setup Improvements"

📂 Loading Batch File:
   ✅ batches/batch-2-setup-improvements.md (3 requirements)

📋 Roadmap Updated:
   ✅ Archived batch removed from overview
   🎯 Active batch: "Setup Improvements"
   ⚪ 3 requirements now visible in main roadmap

The batch is archived. The realm moves forward.
```

### Auto-Archive Detection (Optional Enhancement)

When PM runs `/roadmap shard` or `/roadmap activate`, the command can detect completed batches and suggest archiving:

```
⚠️  Batch "Command Improvements" is 100% complete. Archive it?

Options:
  1. Archive now (recommended)
  2. Keep active (defer archival)
  3. Archive all complete batches

Enter choice [1-3]:
```

This reduces manual archival overhead and keeps roadmap clean automatically.

### Batch Lifecycle Workflow

```
1. Create batch (via roadmap planning)
2. Shard roadmap (creates batch file)
3. Activate batch (becomes active, visible in roadmap.md)
4. Work on requirements (status: ⚪ → 🟡 → 🟢)
5. Complete batch (all requirements 🟢)
6. Archive batch (move to completed/, activate next)
7. Repeat for next batch
```

### Error Handling

- **Incomplete batch**: "Batch '[Name]' has incomplete requirements. Cannot archive. Incomplete items: REQ-XXX (🟡), REQ-YYY (⚪)"
- **Batch not found**: "Batch '[Name]' not found in .haunt/plans/batches/. Available batches: [list]"
- **Not sharded**: "Roadmap is not sharded. Cannot archive batches. Use `/roadmap shard` first."
- **Already archived**: "Batch '[Name]' is already archived in .haunt/completed/batches/"
- **No next batch**: "Batch '[Name]' archived successfully. No more batches remaining. All work complete!"
- **Permission error**: "Cannot create .haunt/completed/batches/ directory. Check permissions."

### Manual Archival (PM Workflow)

PM can manually archive batches as part of completion workflow:

1. **Verify completion**: Check all requirements in batch are 🟢
2. **Run archive command**: `/roadmap archive "Batch Name"`
3. **Review output**: Confirm archival and next batch activation
4. **Update CLAUDE.md**: Remove archived batch from Active Work if needed
5. **Communicate to team**: Notify team of batch completion and new focus

### Integration with Existing Workflow

- **REQ-220 (Sharding)**: Archive command assumes roadmap is sharded
- **REQ-221 (Session Startup)**: Archived batches are NOT loaded during assignment lookup
- **PM Agent**: PM can trigger archival as part of batch completion workflow
- **Backward Compatibility**: If roadmap is not sharded, command errors gracefully

---

## Ghost County Theming

**Opening phrases:**
- "The spirits prepare to shard the roadmap..."
- "Merging the ethereal fragments..."
- "Shifting focus across the batches..."
- "The spirits lay the completed work to rest..."

**Success messages:**
- "The roadmap is sharded. Token efficiency achieved."
- "The realm is whole once more. All batches reunited."
- "The active batch shifts. New hauntings come into view."
- "The batch is archived. The realm moves forward."

**Error messages:**
- "The roadmap resists sharding - no batches detected."
- "The fragments cannot be found. Batches missing from the ethereal realm."
- "The requested batch eludes us. Check the available hauntings."
- "The batch clings to unfinished work. Complete all requirements before archiving."

---

## When to Use Sharding

**Shard when:**
- Roadmap exceeds 500 lines
- 10+ requirements across multiple batches
- Token usage becomes noticeable (>2,000 tokens per request)
- Multiple agents working on different batches simultaneously

**Keep monolithic when:**
- Roadmap under 300 lines
- Fewer than 8 requirements
- Single batch in progress
- Early project phase with high churn

**Activate different batch when:**
- Completing current batch and moving to next phase
- Switching team focus between batches
- Reviewing historical batches for context
- Debugging requirements in inactive batches

**Archive batch when:**
- All requirements in batch are 🟢 Complete
- All tasks checked off (no `- [ ]` remaining)
- Batch goal achieved and verified
- Moving to next phase of work
- Need to reduce roadmap clutter

---

## Implementation Notes

This command integrates with existing Haunt workflow:

- **Session startup** (REQ-221): Assignment lookup loads only active batch when sharded
- **Batch archival** (REQ-222): Archive command moves completed batches to `.haunt/completed/batches/` and activates next batch
- **PM coordination**: PM can shard/unshard/archive at project milestones
- **Backward compatibility**: Unshard restores monolithic format for tools expecting it
- **Archive lifecycle**: Completed batches preserve full history in `.haunt/completed/batches/` for reference

Sharding is **optional** and **reversible**. The roadmap remains functional in both sharded and monolithic forms. Archival is a lifecycle management tool - archived batches remain accessible for historical reference but are excluded from active context loading.
