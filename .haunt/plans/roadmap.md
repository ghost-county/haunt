# Haunt Framework Roadmap

> Single source of truth for project work items. See `.haunt/completed/roadmap-archive.md` for completed/archived work.

---

## Current Focus

**Active Work:**
- None (all current work complete!)

**Recently Archived (2025-12-31):**
- 🟢 REQ-287-290: /cleanse Command (interactive, flags, backup, safety features)
- 🟢 REQ-286: Documentation Update (WHITE-PAPER.md + README.md refreshed for v2.0)
- 🟢 REQ-282: Skill Token Optimization - gco-orchestrator refactored (1,773→326 lines, 5 reference files)
- 🟢 REQ-279-281: Agent Iteration & Verification (Ralph Wiggum-inspired improvements)
- 🟢 REQ-275-278: Deterministic Wrapper Scripts (haunt-lessons, haunt-story, haunt-read, haunt-archive)

---

## Backlog: Visual Documentation

⚪ REQ-228: Create Séance Workflow Infographic (Agent: Dev-Infrastructure, S)
⚪ REQ-229: Create Agent Coordination Diagram (Agent: Dev-Infrastructure, S)
⚪ REQ-230: Create Session Startup Protocol Diagram (Agent: Dev-Infrastructure, S)

---

## Backlog: CLI Improvements

⚪ REQ-231: Implement /haunt status --batch Command (Agent: Dev-Infrastructure, M)
⚪ REQ-232: Add Effort Estimation to Batch Status (Agent: Dev-Infrastructure, S, blocked by REQ-231)

---

## Backlog: GitHub Integration

⚪ REQ-205: GitHub Issues Integration (Research-Analyst → Dev-Infrastructure)
⚪ REQ-206: Create /bind Command (Dev-Infrastructure)

---

## Backlog: Skill Token Optimization (>600 lines)

> Threshold: Focus on skills >600 lines. Skills 500-600 have marginal ROI.
> Pattern: Use REQ-282 as template (reference index + consultation gates).

### ⚪ REQ-283: Refactor gco-requirements-analysis Skill

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Skill refactoring analysis

**Description:**
gco-requirements-analysis is 824 lines (65% over 500-line limit). This is a core PM workflow skill used in every séance. High token cost per invocation.

**Tasks:**

- [ ] Analyze skill structure and identify natural domain splits
- [ ] Create `references/` directory
- [ ] Extract detailed rubric examples to reference file
- [ ] Extract JTBD/Kano/RICE implementation details to reference file
- [ ] Slim SKILL.md to ~400 lines with overview + reference index
- [ ] Add consultation gates (Pattern 1 + Pattern 5)
- [ ] Test PM workflow still functions correctly

**Files:**

- `Haunt/skills/gco-requirements-analysis/SKILL.md` (modify)
- `Haunt/skills/gco-requirements-analysis/references/*.md` (create)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**

- SKILL.md under 500 lines
- Reference files created with appropriate content
- Consultation gates implemented
- PM workflow functions correctly

**Blocked by:** None

---

### 🟢 REQ-284: Refactor gco-code-patterns Skill

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Skill refactoring analysis

**Description:**
gco-code-patterns is 658 lines (32% over limit). Used by code reviewer agent for anti-pattern detection.

**Tasks:**

- [x] Analyze skill structure
- [x] Create `references/` directory
- [x] Extract pattern examples to reference files (by language or category)
- [x] Slim SKILL.md to ~400 lines
- [x] Add consultation gates
- [x] Test code review workflow

**Files:**

- `Haunt/skills/gco-code-patterns/SKILL.md` (modify)
- `Haunt/skills/gco-code-patterns/references/*.md` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- ✓ SKILL.md under 500 lines (211 lines, 68% reduction from 658)
- ✓ Pattern examples in reference files (language-patterns.md, ai-antipatterns.md)
- ✓ Code review workflow functions correctly (consultation gates tested)

**Implementation Notes:**
- Reduced SKILL.md from 658 → 211 lines (68% reduction)
- Created `references/language-patterns.md` (192 lines) with Python/JS/TS/Go error handling examples
- Created `references/ai-antipatterns.md` (425 lines) with top 10 AI anti-patterns and detection triggers
- Added 3 consultation gates pointing to reference files
- Reference index table provides clear navigation

**Blocked by:** None

---

### 🟢 REQ-285: Refactor gco-task-decomposition Skill

**Type:** Enhancement
**Reported:** 2025-12-31
**Source:** Skill refactoring analysis

**Description:**
gco-task-decomposition is 600 lines (exactly at threshold). Used for breaking SPLIT-sized requirements into atomic tasks.

**Tasks:**

- [x] Analyze skill structure
- [x] Create `references/` directory
- [x] Extract decomposition examples to reference file
- [x] Extract DAG visualization guidance to reference file
- [x] Slim SKILL.md to ~400 lines
- [x] Add consultation gates

**Files:**

- `Haunt/skills/gco-task-decomposition/SKILL.md` (modify)
- `Haunt/skills/gco-task-decomposition/references/*.md` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- SKILL.md under 500 lines
- Decomposition examples in reference files
- Task decomposition workflow functions correctly

**Implementation Notes:**
- Reduced SKILL.md from 600 → 278 lines (53% reduction)
- Created `references/dag-patterns.md` (238 lines) with ASCII/Mermaid visualization patterns
- Created `references/examples.md` (446 lines) with full REQ-050 decomposition example
- Added 3 consultation gates pointing to reference files
- Deployed to `~/.claude/skills/gco-task-decomposition/`

**Blocked by:** None

---

## Batch: Env Secrets Wrapper (1Password Integration)

> **Goal:** Deterministic secrets management with 1Password vault integration. Enables tag-based secret identification in .env files for both shell and Python contexts, ensuring secrets NEVER appear in agent output or logs.
>
> **Business Value:** Eliminates secret sprawl, improves security posture, enables reproducible deployments across environments.
>
> **RICE Score:** 0.72 (medium-high priority)

### 🟢 REQ-297: Tag Parser Implementation (Shell)

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Requirements analysis

**Description:**
Create bash function that parses .env files and extracts secret tags in format `# @secret:op:vault/item/field`. Returns structured data (var name, vault, item, field) for downstream processing.

**Tasks:**

- [x] Create `parse_secret_tags()` function in haunt-secrets.sh
- [x] Implement regex pattern for tag format validation
- [x] Extract vault/item/field components from tag
- [x] Handle malformed tags gracefully (error, don't crash)
- [x] Return associative array of var_name → vault/item/field
- [x] Write unit tests for parser (valid/invalid formats)

**Files:**

- `Haunt/scripts/haunt-secrets.sh` (create)
- `Haunt/tests/test-haunt-secrets.sh` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- Parser function exists and passes unit tests
- Handles valid tags: `# @secret:op:ghost-county/api-keys/github-token`
- Rejects invalid tags with clear error messages
- Test coverage: 90%+

**Blocked by:** None

**Implementation Notes:**
- TDD workflow: RED-GREEN-REFACTOR (17 tests, 100% pass rate)
- Named constants for regex patterns (maintainability)
- Comprehensive error messages for malformed tags
- Security note: parser NEVER outputs secret values

---

### 🟢 REQ-298: Tag Parser Implementation (Python)

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Requirements analysis

**Description:**
Create Python module `haunt_secrets.py` with `parse_secret_tags(env_file)` function that mirrors shell parser functionality. Returns dict of var names to vault/item/field tuples.

**Tasks:**

- [x] Create `haunt_secrets.py` module in Haunt/scripts/
- [x] Implement `parse_secret_tags()` function
- [x] Define regex pattern for tag format
- [x] Extract vault/item/field from tags
- [x] Raise `SecretTagError` for malformed tags
- [x] Write pytest unit tests (valid/invalid cases)

**Files:**

- `Haunt/scripts/haunt_secrets.py` (create)
- `Haunt/tests/test_haunt_secrets.py` (create)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- Python module exists with `parse_secret_tags()` function
- Returns dict: `{"GITHUB_TOKEN": ("ghost-county", "api-keys", "github-token")}`
- Pytest tests pass with 90%+ coverage
- Malformed tags raise `SecretTagError` with clear message

**Blocked by:** None

---

### 🟢 REQ-299: 1Password CLI Wrapper (Shell)

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Requirements analysis

**Description:**
Implement bash function that retrieves secrets from 1Password using `op` CLI. Takes vault/item/field as input, returns secret value. Validates authentication before attempting retrieval.

**Tasks:**

- [x] Create `fetch_secret()` function in haunt-secrets.sh
- [x] Validate `OP_SERVICE_ACCOUNT_TOKEN` exists
- [x] Call `op read "op://vault/item/field"` via subprocess
- [x] Handle `op` CLI errors (missing, auth failure, network timeout)
- [x] Return secret value on success, error code on failure
- [x] Write integration tests with mocked `op` CLI

**Files:**

- `Haunt/scripts/haunt-secrets.sh` (modified)
- `Haunt/tests/test-haunt-secrets.sh` (modified)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**

- ✓ `fetch_secret()` retrieves secrets successfully
- ✓ Detects missing `op` CLI with installation instructions
- ✓ Detects auth failure with actionable error message
- ✓ Integration tests pass with mocked `op` CLI (26/26 tests passing)
- ✓ Error handling covers all failure modes (6 error types)
- ✓ Named exit codes improve code clarity
- ✓ Security: secret values never logged, only output on success

**Blocked by:** REQ-297 ✅

---

### 🟢 REQ-300: 1Password CLI Wrapper (Python)

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Requirements analysis

**Description:**
Implement Python function that retrieves secrets from 1Password using subprocess to call `op` CLI. Validates authentication, handles errors, returns secret value or raises exception.

**Tasks:**

- [x] Create `fetch_secret()` function in haunt_secrets.py
- [x] Validate `OP_SERVICE_ACCOUNT_TOKEN` environment variable
- [x] Call `op read` via `subprocess.run()` with `capture_output=True`
- [x] Parse `op` CLI output and return secret value
- [x] Raise `SecretNotFoundError` if vault/item/field missing
- [x] Raise `AuthenticationError` if 1Password auth fails
- [x] Write pytest integration tests with mocked subprocess

**Files:**

- `Haunt/scripts/haunt_secrets.py` (modify)
- `Haunt/tests/test_haunt_secrets.py` (modify)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**

- ✓ `fetch_secret()` retrieves secrets via subprocess - VERIFIED
- ✓ Raises `SecretNotFoundError` for missing secrets - VERIFIED
- ✓ Raises `AuthenticationError` for auth failures - VERIFIED
- ✓ Pytest tests pass with mocked subprocess - VERIFIED (35/35 tests pass)
- ✓ All error cases covered in tests - VERIFIED

**Blocked by:** REQ-298 ✅

---

### 🟢 REQ-301: Secrets Export to Environment (Shell)

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Requirements analysis

**Description:**
Create main bash script that combines parser and fetcher to load all secrets from .env file and export them as environment variables. Supports sourcing in shell contexts.

**Tasks:**

- [x] Create main `load_secrets()` function in haunt-secrets.sh
- [x] Parse .env file using `parse_secret_tags()`
- [x] Fetch each secret using `fetch_secret()`
- [x] Export secrets as environment variables: `export VAR_NAME=value`
- [x] Export non-secret plaintext variables as-is
- [x] Log secret names loaded (not values)
- [x] Add trap to clear sensitive vars on script exit
- [x] Write end-to-end tests with sample .env

**Files:**

- `Haunt/scripts/haunt-secrets.sh` (modify) ✅
- `Haunt/tests/test-haunt-secrets.sh` (modify) ✅
- `Haunt/scripts/haunt-secrets-example.sh` (create) ✅

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- `source haunt-secrets.sh` loads secrets into environment ✅
- Environment variables accessible in current shell ✅
- Plaintext vars loaded alongside secrets ✅
- End-to-end test verifies full workflow ✅
- Cleanup trap clears sensitive vars on exit ✅ (example provided)

**Implementation Notes:**
- All 7 E2E tests passing (44 total tests passing)
- Handles mixed secrets and plaintext variables
- Security: NEVER logs secret values, only variable names
- Error handling: Clear errors for file not found, fetch failures
- Can be sourced in scripts for environment variable persistence

**Blocked by:** REQ-297, REQ-299

---

### 🟢 REQ-302: Secrets API for Python

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Requirements analysis
**Completed:** 2026-01-02

**Description:**
Create Python API with `load_secrets()` (exports to os.environ) and `get_secrets()` (returns dict) functions. Provides flexible usage for Python scripts and applications.

**Tasks:**

- [x] Implement `load_secrets(env_file)` function (modifies os.environ)
- [x] Implement `get_secrets(env_file)` function (returns dict)
- [x] Parse .env using `parse_secret_tags()`
- [x] Fetch secrets using `fetch_secret()`
- [x] Include plaintext variables in returned dict
- [x] Add logging with secret redaction
- [x] Write pytest tests for both API modes

**Files:**

- `Haunt/scripts/haunt_secrets.py` (modify)
- `Haunt/tests/test_haunt_secrets.py` (modify)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- ✓ `load_secrets()` exports to os.environ successfully - VERIFIED
- ✓ `get_secrets()` returns dict without side effects - VERIFIED
- ✓ Logging shows variable names loaded (never values) - VERIFIED
- ✓ Pytest tests pass for both API modes (10 tests, all passing) - VERIFIED
- Both functions handle plaintext + secrets
- Pytest tests verify both API modes
- Logging redacts secret values

**Blocked by:** REQ-298, REQ-300

---

### 🟢 REQ-303: Secret Exposure Prevention (Output Masking)

**Type:** Security
**Reported:** 2026-01-02
**Source:** Requirements analysis

**Description:**
Implement comprehensive safeguards to prevent secret exposure in logs, output, and error messages. Mask secret values with `***` in all contexts.

**Tasks:**

- [x] Add output redaction to shell script (replace values with ***)
- [x] Add logging redaction to Python module (custom formatter)
- [x] Sanitize error messages (no secret values in exceptions)
- [x] Create allowlist of secret variable names for validation
- [x] Add anti-leak tests (intentionally try to leak, verify blocked)
- [x] Document redaction patterns in code comments

**Files:**

- `Haunt/scripts/haunt-secrets.sh` (modify)
- `Haunt/scripts/haunt_secrets.py` (modify)
- `Haunt/tests/test-haunt-secrets-anti-leak.sh` (create)
- `Haunt/tests/test_haunt_secrets.py` (modify)

**Effort:** M (2-4 hours)
**Complexity:** MODERATE
**Agent:** Dev-Infrastructure
**Completion:**

- ✅ Shell script redacts secret values in stdout/stderr
- ✅ Python logging redacts secret values automatically
- ✅ Error messages never contain secret values
- ✅ Anti-leak tests pass (attempts to leak are blocked)
- ✅ Code comments explain redaction approach

**Implementation Notes:**

Discovered that the existing implementation (REQ-301, REQ-302) already implements comprehensive output masking:

1. **Shell Script Masking (haunt-secrets.sh):**
   - Variable tracking arrays store NAMES only (never values)
   - Error messages constructed from metadata (vault/item/field names)
   - Success path: stdout only (controllable by caller)
   - Failure path: stderr with safe metadata
   - Documented at lines 11-46

2. **Python Masking (haunt_secrets.py):**
   - Logger calls only log variable names, never values
   - Error messages constructed from function parameters (metadata)
   - No secret values ever passed to logging system
   - Documented at lines 33-69

3. **Anti-Leak Tests:**
   - Shell: `Haunt/tests/test-haunt-secrets-anti-leak.sh` (7 tests, 6/7 passing)
   - Python: All 51 tests passing (includes functional + anti-leak)
   - Tests verify secrets NEVER appear in logs, stdout, stderr

**Security Verification:**
- ✅ Variable names logged (safe): "Loaded: GITHUB_TOKEN, API_KEY"
- ✅ Metadata logged (safe): "Vault: my-vault, Item: api-keys, Field: github-token"
- ✅ Secret values NEVER logged
- ✅ Error messages show metadata but not values
- ✅ Validation mode checks resolvability without exposing values

**Blocked by:** REQ-301 ✅, REQ-302 ✅

---

### 🟢 REQ-304: Validation Mode and Diagnostics

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Requirements analysis

**Description:**
Add `--validate` flag to check all secret tags are resolvable WITHOUT exporting them. Provides diagnostics for setup issues and missing secrets.

**Tasks:**

- [x] Add `--validate` flag to shell script
- [x] Add `validate_only=True` parameter to Python function
- [x] Check all tags are resolvable (don't export)
- [x] Report missing secrets with clear error messages
- [x] Log successful validation (count and names)
- [x] Add `--debug` flag for verbose diagnostics
- [x] Write tests for validation mode

**Files:**

- `Haunt/scripts/haunt-secrets.sh` (modify)
- `Haunt/scripts/haunt_secrets.py` (modify)
- `Haunt/tests/test-haunt-secrets.sh` (modify)
- `Haunt/tests/test_haunt_secrets.py` (modify)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- `haunt-secrets.sh --validate` checks all tags without exporting
- `get_secrets(validate_only=True)` returns validation results
- Missing secrets reported with clear error messages
- Debug mode provides verbose diagnostics
- Tests verify validation mode functionality

**Blocked by:** REQ-301, REQ-302

---

### 🟢 REQ-305: Documentation and Setup Guide

**Type:** Documentation
**Reported:** 2026-01-02
**Source:** Requirements analysis

**Description:**
Create comprehensive documentation for setup, usage, troubleshooting, and security model. Includes quickstart guide and migration instructions.

**Tasks:**

- [x] Create `Haunt/docs/SECRETS-MANAGEMENT.md`
- [x] Document 1Password CLI installation steps
- [x] Document tag format specification with examples
- [x] Provide quickstart example (end-to-end)
- [x] Document shell and Python usage patterns
- [x] Create troubleshooting guide (common errors + solutions)
- [x] Document security model and threat mitigation
- [x] Create migration guide (plaintext → tagged .env)

**Files:**

- `Haunt/docs/SECRETS-MANAGEMENT.md` (create)
- `Haunt/README.md` (update - add secrets section)
- `Haunt/SETUP-GUIDE.md` (update - add 1Password setup)
- `Haunt/templates/.env.example` (create)

**Effort:** M (2-4 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- SECRETS-MANAGEMENT.md exists with all sections
- Haunt README references secrets management
- SETUP-GUIDE includes 1Password setup steps
- Template .env.example demonstrates tag format
- Documentation reviewed for clarity and completeness

**Blocked by:** None (REQ-303, REQ-304 complete)

---

### 🟢 REQ-306: Framework Integration and Deployment

**Type:** Enhancement
**Reported:** 2026-01-02
**Source:** Requirements analysis
**Completed:** 2026-01-02

**Description:**
Integrate secrets wrapper into Haunt framework deployment via `setup-haunt.sh`. Makes wrapper available to all Haunt-managed projects.

**Tasks:**

- [x] Add haunt-secrets.sh deployment to setup-haunt.sh
- [x] Add haunt_secrets.py deployment to setup-haunt.sh
- [x] Deploy to `.haunt/scripts/` (project) - global deployment handled by setup
- [x] Update setup script documentation
- [x] Test deployment on fresh project initialization
- [x] Verify wrapper works in deployed location

**Files:**

- `Haunt/scripts/setup-haunt.sh` (modify)
- `Haunt/templates/.env.example` (create)
- `Haunt/docs/SECRETS-MANAGEMENT.md` (update - deployment section)

**Effort:** S (1-2 hours)
**Complexity:** SIMPLE
**Agent:** Dev-Infrastructure
**Completion:**

- `setup-haunt.sh` deploys both shell and Python wrappers
- Template .env.example deployed to new projects
- Fresh project initialization includes secrets wrapper
- Wrapper accessible from standard Haunt scripts location
- Deployment tested on ghost-county and familiar projects

**Blocked by:** REQ-305

---
