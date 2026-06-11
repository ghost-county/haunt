---
name: gco-haunt-orchestration
description: >-
  Project-local standards discovery, indexing, and context-aware injection via /haunt subcommands (init, discover, inject, status).
  Use to initialize Haunt in a repo, extract tribal coding knowledge into standards files, and load only relevant standards per task.
last-verified: 2026-05-12
version: "1.0"
---

# Haunt Orchestration

The lead agent's guide for running `/haunt` — Haunt's project initialization and standards layer. The command file (`commands/haunt.md`) is a thin router; this skill is the procedure.

## Vocabulary

| Term | Definition | Use When |
|------|-----------|----------|
| Standard | One concise documented pattern (≤30 lines) at `.haunt/standards/{category}/{name}.md` | Capturing a project-specific convention |
| Focus area | A category of patterns in the repo (api, database, react, testing, naming) | Choosing what to interview about |
| Tribal knowledge | Conventions a new dev wouldn't know without being told | Identifying what's worth documenting |
| Index | `.haunt/standards/index.yml` mapping each standard to a one-line description | Matching standards to current work |
| Standards injection | Loading relevant standards into context for the current task | After /haunt init, on most non-trivial tasks |
| Auto-suggest mode | `/haunt inject` (no args): match conversation against index, present 2-5 candidates | When work-type is obvious from context |
| Explicit mode | `/haunt inject api/response-format`: load named folder or file | When you know which standards apply |
| Scenario | Whether to load standards inline (conversation) or as `@path` references (plan/spec) | Detecting via plan-mode + keywords |
| Discovery interview | The Step 3-5 loop: present pattern → ask why → draft → confirm → write | Building a new standard with the user |
| Idempotent init | Re-running `/haunt init` safely without clobbering existing standards | Always — never destructive by default |
| Index drift | Files in `.haunt/standards/` without index entries (or vice versa) | Detected by `/haunt status`; fixed by re-index |
| Concise standard | Rule-led, code-exampled, bulleted, ≤30 lines | Every standard file — verbosity costs tokens at injection |
| Vocabulary routing | First-sentence keywords in skill description that route to expert knowledge | Designing standard descriptions for the index |

## Anti-Patterns

| Anti-Pattern | Detection Signal | Resolution |
|-------------|-----------------|------------|
| Batching discovery questions | Asking 3+ "why" questions in a single `AskUserQuestion` | One pattern at a time: present → ask 1-2 why → draft → confirm → write, then next |
| Verbose standards | Standard file >30 lines or paragraph-heavy | Lead with the rule; code example; bullets only. See `references/example-standard.md` |
| Over-injection | Surfacing all 20 standards as candidates | Match against work signals (file types, keywords); cap at 2-5 candidates |
| Silent index drift | Adding/removing standards without updating index.yml | `/haunt status` reports drift; `/haunt init` Step 6 rebuilds |
| Hardcoded scenario default | Assuming "conversation" without checking | Detect plan mode + spec/plan/shape keywords; `AskUserQuestion` if uncertain |
| Skipping the why | Drafting a standard without asking why the pattern exists | Always 1-2 why-questions before drafting; the rationale belongs in the file |
| Clobbering on re-init | `/haunt init` overwriting `.haunt/standards/` without asking | Step 1 checks for existing `index.yml`; offer continue/fresh/cancel |
| Generic focus areas | Presenting "frontend / backend / testing" with no repo evidence | Inspect actual folders, file types, framework signatures; tailor candidates |
| Standards as documentation | Treating standards as long-form docs | Standards are **injected** into LLM context — token budget matters more than completeness |

## Workflow: `/haunt` (smart router)

1. Check `.haunt/` exists in current working directory.
2. IF `.haunt/standards/index.yml` exists AND has at least one entry → run `/haunt status`.
3. ELSE → run `/haunt init`.

## Workflow: `/haunt init`

The interactive setup. Ported from Agent OS `discover-standards.md`; outputs to `.haunt/standards/` (not `agent-os/standards/`).

### Step 1: Idempotency check

Check if `.haunt/standards/index.yml` exists.

IF it exists with entries:
```
Existing standards setup found:
  - {N} standards across {M} categories
  - Last indexed: {mtime}

Options:
  1. Continue (add more standards to existing setup)
  2. Start fresh (move existing to .haunt/standards.bak.{timestamp}/, then restart)
  3. Cancel
```
Use `AskUserQuestion`. Never destructive without explicit "start fresh".

IF no index: proceed to Step 2.

### Step 2: Scaffold directories

Ensure `.haunt/standards/` and `.haunt/specs/` exist. Idempotent — session-start hook also handles this.

### Step 3: Determine focus areas

Inspect the repo: top-level folders, dominant file types, framework markers (`package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, etc.).

Present 3-5 candidate areas via `AskUserQuestion`, tailored to the repo (e.g., for a Next.js + Postgres app: "API Routes" / "Database" / "React Components" / "Authentication"). Always cite actual folder paths from this repo, not generic categories.

### Step 4: Analyze and present findings

Read 5-10 representative files. Look for patterns that are **unusual / opinionated / tribal / consistent** (not standard framework boilerplate). Present 3-6 candidates via `AskUserQuestion`; user picks which to document.

### Step 5: For each selected pattern — ask, draft, confirm, write

**ONE PATTERN AT A TIME.** Do not batch.

1. Ask 1-2 "why" questions via `AskUserQuestion` (e.g., "What problem does this solve vs. the framework default?", "Common mistake to avoid?").
2. Draft the standard per `references/example-standard.md` format.
3. Confirm: `yes / edit: {changes} / skip`.
4. Write to `.haunt/standards/{category}/{name}.md`. Create category folder if needed.
5. Move to next pattern.

### Step 6: Update the index

After all patterns in the area are written, scan `.haunt/standards/` and rebuild `.haunt/standards/index.yml`:

```yaml
api:
  response-format:
    description: API response envelope structure and error codes
  error-handling:
    description: Error codes, exception handling, error response format
```

Alphabetize folders, then files. One-line descriptions. For new files without entries, propose a description via `AskUserQuestion`.

### Step 7: Offer next area

```
Discovered {N} standards in {area}. Continue with another area, or done?
```

Loop to Step 3 or exit.

### Step 8: Completion summary

Report what was captured, where, and next steps (`/haunt inject` to use these).

## Workflow: `/haunt discover [area]`

Skip Steps 1-2 of init. Go directly to Step 3 (if no area argument) or Step 4 (if area provided). Adds to existing standards. Always update index at Step 6.

## Workflow: `/haunt inject` (auto-suggest mode)

### Step 1: Read the index

Read `.haunt/standards/index.yml`. IF missing or empty:
```
No standards found at .haunt/standards/index.yml. Run /haunt init first.
```
Stop.

### Step 2: Detect scenario

Determine output format by checking:
- IF plan mode is active → **plan/spec** scenario.
- IF conversation mentions "spec", "plan", "shape" prominently → **plan/spec** scenario.
- ELSE → **conversation** scenario (but confirm via `AskUserQuestion` if work context is ambiguous).

### Step 3: Analyze work signals

Examine current conversation:
- What file types are being edited?
- What keywords appear (api, database, auth, test, component, etc.)?
- What is the user trying to accomplish?

### Step 4: Match and surface candidates

Match index descriptions against signals. Present 2-5 candidates via `AskUserQuestion`:

```
Based on your task, these standards may apply:

1. api/response-format — API response envelope structure
2. api/error-handling — Error codes, exception handling
3. global/naming — File and variable naming conventions

Inject? (all / just 1 and 2 / add: database/migrations / none)
```

Cap at 5 — surfacing 20 is not selection, it's noise.

### Step 5: Load by scenario

**Conversation scenario:** read each selected standard file and announce its content inline:
```
--- Standard: api/response-format ---
{full file content}
--- End Standard ---

Key points:
- {bulleted summary}
```

**Plan/spec scenario:** output reference paths only (don't expand content):
```
Add to your plan:
@.haunt/standards/api/response-format.md
@.haunt/standards/api/error-handling.md

Coverage:
- API response envelope structure
- Error codes, exception handling
```

## Workflow: `/haunt inject {args}` (explicit mode)

Skip Steps 2-4. Parse arg(s):
- `api` → all `.md` files in `.haunt/standards/api/`
- `api/response-format` → single file `.haunt/standards/api/response-format.md`
- Multiple args → multiple injections

Validate paths. On miss:
```
Standard not found: api/nonexistent

Available in api/:
- response-format
- error-handling

Did you mean one of these?
```

Detect scenario (Step 2 above), then load (Step 5 above).

## Workflow: `/haunt status`

1. Read `.haunt/standards/index.yml`. Count entries by folder.
2. Scan `.haunt/standards/` filesystem. Compare to index.
3. Report:
   ```
   Haunt standards inventory:
     api: 3 standards
     database: 2 standards
     react: 4 standards
     Total: 9 indexed standards across 3 categories

   Index health: ✓ no drift
   Last discovery: 2026-05-10 (2 days ago)

   Run /haunt discover {area} to add more.
   Run /haunt inject to surface relevant standards.
   ```
4. IF drift detected (files without entries, or entries without files):
   ```
   ⚠ Index drift:
     - Missing entry: api/pagination.md
     - Stale entry: testing/old-pattern.md (file deleted)

   Run /haunt init to rebuild the index.
   ```

## Standard File Format

Standards are **injected into LLM context** — token budget matters. Target ≤30 lines per file.

```markdown
# Standard Title

Lead with the rule.

\`\`\`code
example
\`\`\`

- Bullet
- Bullet
- Bullet (with why if non-obvious)
```

Bad pattern: paragraphs, exhaustive edge cases, framework re-documentation.

See `references/example-standard.md` for a calibrated good-vs-bad example.

## Index Format

`.haunt/standards/index.yml`:
```yaml
api:
  response-format:
    description: API response envelope structure, status codes, pagination
  error-handling:
    description: Error codes, exception handling, error response format
database:
  migrations:
    description: Migration file structure, naming conventions, rollback patterns
```

- Alphabetize folders, then files within
- File names without `.md` extension
- Descriptions are one-liners used for matching, not docs

## Questions This Skill Answers

- How do I initialize Haunt in a new repo?
- How do I capture this project's coding conventions for the agent?
- What standards apply to my current task?
- How do I document a project-specific pattern so agents follow it?
- What's the difference between `gco-python-standards` (global) and project-local standards?
- How do I add a standard for an API pattern unique to this codebase?
- Where do project-local standards live?
- How do I inject standards into a plan vs a conversation?
- How do I check what standards exist in this project?
- How do I rebuild the standards index after manual edits?
- What's the right length for a standard file?
- How do I extract tribal knowledge from a codebase I just inherited?
- Can I run /haunt init more than once safely?
- What goes in `.haunt/standards/index.yml`?
