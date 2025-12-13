# Commit Conventions

Every commit in this repository MUST follow a standardized format for consistency and traceability.

## Commit Message Format

Every commit MUST follow this structure:

```
[REQ-XXX] Action: Brief description

What was done:
- Specific change 1
- Specific change 2
- Specific change 3 (if needed)

🤖 Generated with Claude Code
```

## Required Elements

### 1. Header: `[REQ-XXX] Action: Brief description`

- **REQ-XXX**: Requirement ID from roadmap (REQUIRED)
  - Must reference an existing requirement in `.haunt/plans/roadmap.md`
  - Format: REQ-001, REQ-042, REQ-107, etc.

- **Action**: One of the approved action verbs
  - `Add`: Creating new functionality or files
  - `Update`: Enhancing existing features or files
  - `Fix`: Correcting bugs or broken behavior
  - `Remove`: Deleting code, files, or features
  - `Refactor`: Restructuring code without changing behavior
  - `Test`: Adding or updating tests
  - `Docs`: Documentation-only changes

- **Brief description**: One-line summary (50 characters max)
  - Lowercase after colon
  - No period at end
  - Describes WHAT changed, not WHY (the requirement has the WHY)

### 2. Body: `What was done:` Section

- Bulleted list of specific changes
- Use past tense ("Created", "Updated", "Fixed")
- Be specific about files/systems touched
- Focus on WHAT changed, not WHY it changed
- Typically 2-4 bullets
- Each bullet should be a complete thought

### 3. Footer: `🤖 Generated with Claude Code`

- MUST be included on every commit
- Identifies commits created by AI agents
- No variation allowed

## Examples

### Good Commits

```
[REQ-105] Add: Session startup protocol rule

What was done:
- Created .haunt/rules/gco-session-startup.md
- Extracted protocol from session-startup skill
- Added assignment lookup hierarchy

🤖 Generated with Claude Code
```

```
[REQ-042] Fix: Database connection timeout

What was done:
- Increased connection pool timeout to 30s
- Added retry logic for transient failures
- Updated error messages for clarity

🤖 Generated with Claude Code
```

```
[REQ-089] Update: Authentication middleware for better session handling

What was done:
- Modified auth middleware to check session state before redirect
- Added session validation helper function
- Updated tests to cover new session scenarios

🤖 Generated with Claude Code
```

```
[REQ-101] Refactor: Payment service for maintainability

What was done:
- Extracted payment validation to separate module
- Simplified payment processing pipeline
- Added JSDoc comments to all public methods

🤖 Generated with Claude Code
```

```
[REQ-067] Test: Pattern detector CLI functionality

What was done:
- Added unit tests for pattern collector
- Added integration tests for pattern analyzer
- Verified test coverage exceeds 80%

🤖 Generated with Claude Code
```

### Bad Commits (Don't Do This)

```
fixed stuff
```
**Problems:**
- No REQ reference
- No structure
- Vague description

```
WIP
```
**Problems:**
- Never commit work-in-progress without details
- No REQ reference
- No explanation

```
[REQ-001] Updated files
```
**Problems:**
- Too vague ("Updated files" tells us nothing)
- No "What was done" section
- No footer

```
Added new feature for authentication
```
**Problems:**
- No REQ reference
- Wrong action format (should be "[REQ-XXX] Add:")
- No structure

```
[REQ-042] Add: user authentication endpoints.
```
**Problems:**
- Period at end of brief description
- No "What was done" section
- No footer

## Non-Negotiable Rules

1. **MUST reference REQ-XXX** from roadmap
   - Every commit ties to a tracked requirement
   - Enables traceability and project tracking

2. **MUST use approved Action verb**
   - Standardizes commit history
   - Makes scanning git log easier

3. **MUST include "What was done" section**
   - Provides implementation details
   - Helps future developers understand changes

4. **MUST include footer**
   - Identifies AI-generated commits
   - Maintains transparency

5. **NEVER commit without testing**
   - Run tests before committing
   - Verify changes don't break existing functionality

6. **NEVER commit secrets or credentials**
   - No .env files with real credentials
   - No API keys, passwords, or tokens
   - Use .gitignore properly

## Branch Naming Conventions

When creating branches, follow this format:

`<type>/REQ-XXX[-optional-descriptor]`

### Types
- `feature/` - New functionality or enhancement
- `bugfix/` - Fixing broken behavior
- `hotfix/` - Urgent production fixes

### Examples
- `feature/REQ-042`
- `bugfix/REQ-089-auth-redirect`
- `hotfix/REQ-101-security-patch`

### Rules
- Always include REQ-XXX from roadmap
- Optional descriptor for clarity (kebab-case)
- No spaces, use hyphens
- Lowercase preferred
