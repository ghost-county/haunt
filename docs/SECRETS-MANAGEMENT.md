# Secrets Management with Haunt

> **Security-First Configuration Management**
> Manage secrets with 1Password integration while keeping your .env files versionable.

---

## Table of Contents

1. [Two Approaches](#two-approaches)
2. [Quick Start](#quick-start)
3. [Prerequisites](#prerequisites)
4. [Pattern 1: Native op run](#pattern-1-native-op-run)
5. [Pattern 2: Haunt Secrets Wrapper](#pattern-2-haunt-secrets-wrapper)
6. [Tag Format Specification](#tag-format-specification)
7. [Usage Guide](#usage-guide)
   - [Shell (Bash)](#shell-bash)
   - [Python](#python)
8. [Security Model](#security-model)
9. [Troubleshooting](#troubleshooting)
10. [Migration Guide](#migration-guide)

---

## Two Approaches

Haunt supports **two patterns** for 1Password secret management. Choose based on your use case:

| Aspect | Pattern 1: Native `op run` | Pattern 2: Haunt Wrapper |
|--------|---------------------------|--------------------------|
| **Syntax** | `VAR=op://vault/item/field` | `# @secret:op:vault/item/field`<br>`VAR=placeholder` |
| **Execution** | `op run --env-file=.env -- cmd` | `source haunt-secrets.sh && load_secrets .env` |
| **Complexity** | Zero custom code | Custom wrapper (~900 lines) |
| **Best For** | npm scripts, quick commands | Shell scripts, Python apps |

### When to Use Each

| Use Case | Recommended Pattern |
|----------|---------------------|
| npm/yarn scripts (`npm run dev`) | **Pattern 1** - `op run` |
| One-off CLI commands | **Pattern 1** - `op run` |
| Shell scripts sourcing .env | **Pattern 2** - Haunt wrapper |
| Python applications | **Pattern 2** - Haunt wrapper |
| CI validation (check secrets exist) | **Pattern 2** - `--validate` mode |
| Need programmatic secret access | **Pattern 2** - Python API |

### Can I Use Both?

**Yes!** Both patterns can coexist in the same project:

```bash
# .env file works with BOTH patterns
# @secret:op:my-vault/api-keys/github-token
GITHUB_TOKEN=op://my-vault/api-keys/github-token

# Pattern 1: Use with op run
op run --env-file=.env -- npm test

# Pattern 2: Use with haunt-secrets
source .haunt/scripts/haunt-secrets.sh
load_secrets .env
```

**Note:** When using both, the `.env` value (`op://...`) is the native format. The comment tag (`# @secret:op:...`) is parsed by the Haunt wrapper.

---

## Quick Start

**Goal:** Get a secret from 1Password into your environment in 60 seconds.

### 1. Install 1Password CLI

```bash
# macOS (Homebrew)
brew install 1password-cli

# Verify installation
op --version
```

### 2. Set Service Account Token

```bash
# Export your 1Password service account token
export OP_SERVICE_ACCOUNT_TOKEN="ops_your_token_here"

# Verify authentication
op vault list
```

### 3. Tag a Secret in .env

Create a `.env` file with secret tag:

```bash
# @secret:op:my-vault/api-keys/github-token
GITHUB_TOKEN=placeholder

# Plaintext variables work too
APP_ENV=development
```

### 4. Load Secrets

> **Note:** After running `setup-haunt.sh`, the secrets wrapper scripts are automatically deployed to `.haunt/scripts/` in your project.

**Shell:**
```bash
# From deployed location (after setup)
source .haunt/scripts/haunt-secrets.sh
load_secrets .env

# Or from source (during development)
source Haunt/scripts/haunt-secrets.sh
load_secrets .env

echo $GITHUB_TOKEN  # Actual secret from 1Password
```

**Python:**
```python
# Add .haunt/scripts to path (after setup)
import sys
sys.path.insert(0, '.haunt/scripts')

from haunt_secrets import load_secrets

load_secrets(".env")
print(os.environ["GITHUB_TOKEN"])  # Actual secret
```

**Done!** Your secret is loaded from 1Password and available in your environment.

---

## Prerequisites

### 1Password Account Setup

**What you need:**
1. **1Password account** (Business, Teams, or Personal plan)
2. **Service account** with access to vaults containing secrets
3. **Service account token** (starts with `ops_`)

**How to get a service account token:**
1. Log into 1Password at https://my.1password.com
2. Navigate to **Settings** → **Developer** → **Service Accounts**
3. Click **Create Service Account**
4. Grant access to vaults containing secrets
5. Copy the service account token (you'll only see this once!)
6. Store token securely (DO NOT commit to version control)

### 1Password CLI Installation

**macOS:**
```bash
brew install 1password-cli
```

**Linux:**
```bash
# Debian/Ubuntu
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
  sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] \
  https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
  sudo tee /etc/apt/sources.list.d/1password.list

sudo apt update && sudo apt install 1password-cli
```

**Windows:**
```powershell
# Using winget
winget install AgileBits.1Password.CLI

# Or download from https://1password.com/downloads/command-line/
```

**Verify installation:**
```bash
op --version
# Should output: 2.x.x or higher
```

### Environment Setup

**Set service account token:**

```bash
# Temporary (current session only)
export OP_SERVICE_ACCOUNT_TOKEN="ops_your_token_here"

# Permanent (add to ~/.bashrc, ~/.zshrc, or equivalent)
echo 'export OP_SERVICE_ACCOUNT_TOKEN="ops_your_token_here"' >> ~/.bashrc
source ~/.bashrc
```

**Verify authentication:**
```bash
# List vaults to confirm token works
op vault list

# Should output vault names/IDs
```

---

## Pattern 1: Native op run

The simplest approach uses 1Password's built-in `op run` command. **Zero custom code required.**

### .env Format

Put `op://` references directly as values:

```bash
# .env (safe to commit - no actual secrets)
GITHUB_TOKEN=op://my-vault/api-keys/github-token
STRIPE_SECRET_KEY=op://my-vault/api-keys/stripe-key
DATABASE_URL=op://my-vault/database/connection-string

# Plaintext values work alongside secrets
APP_ENV=development
LOG_LEVEL=info
```

### Usage

Wrap any command with `op run`:

```bash
# Run a command with secrets injected
op run --env-file=.env -- npm test

# Run development server
op run --env-file=.env -- npm run dev

# Run any script
op run --env-file=.env -- python script.py
```

### Package.json Integration

```json
{
  "scripts": {
    "dev": "op run --env-file=.env -- next dev",
    "dev:local": "next dev",
    "build": "op run --env-file=.env -- next build",
    "test": "op run --env-file=.env -- vitest run",
    "test:local": "vitest run"
  }
}
```

**Pattern:**
- Primary scripts use `op run` for production-like behavior
- `:local` variants skip secrets (for quick iteration)

### Item Naming Convention

Use consistent naming for 1Password items:

```
{Project} - {Service} - {Type}
```

**Examples:**
- `Familiar - Jira - API Token`
- `Familiar - Notion - OAuth`
- `Familiar - Google - OAuth`

**Field names within items:**
- `credential` - For single-value secrets (API tokens, keys)
- `client_id` / `client_secret` - For OAuth
- `password` / `username` - For credentials

### When to Use Pattern 1

✅ **Ideal for:**
- npm/yarn scripts
- One-off CLI commands
- Simple projects without Python
- When you want zero custom code

❌ **Not ideal for:**
- Shell scripts that source .env
- Python applications needing programmatic access
- CI validation (checking secrets exist without loading)

---

## Pattern 2: Haunt Secrets Wrapper

The Haunt wrapper provides additional features: Python API, validation mode, and shell script compatibility.

### .env Format

Use comment tags above variables:

```bash
# .env (safe to commit - no actual secrets)

# @secret:op:my-vault/api-keys/github-token
GITHUB_TOKEN=placeholder

# @secret:op:my-vault/api-keys/stripe-key
STRIPE_SECRET_KEY=placeholder

# Plaintext values (no tags needed)
APP_ENV=development
LOG_LEVEL=info
```

### Usage

**Shell:**
```bash
source .haunt/scripts/haunt-secrets.sh
load_secrets .env
echo $GITHUB_TOKEN  # Actual secret from 1Password
```

**Python:**
```python
from haunt_secrets import load_secrets
load_secrets(".env")
import os
print(os.environ["GITHUB_TOKEN"])  # Actual secret
```

**Validation Mode:**
```bash
# Check all secrets are resolvable WITHOUT loading them
bash .haunt/scripts/haunt-secrets.sh --validate .env
```

### When to Use Pattern 2

✅ **Ideal for:**
- Shell scripts sourcing .env
- Python applications
- CI validation pipelines
- Programmatic secret access
- Debug/diagnostics (`--debug` flag)

❌ **Not ideal for:**
- Simple npm scripts (Pattern 1 is simpler)
- When you want zero custom dependencies

---

## Tag Format Specification

### Syntax

```
# @secret:op:vault/item/field
VAR_NAME=placeholder
```

### Components

| Component | Description | Valid Characters | Example |
|-----------|-------------|------------------|---------|
| `@secret:op:` | Required prefix | Fixed string | `@secret:op:` |
| `vault` | Vault name | `a-z A-Z 0-9 _ -` | `ghost-county` |
| `item` | Item name | `a-z A-Z 0-9 _ -` | `api-keys` |
| `field` | Field name | `a-z A-Z 0-9 _ -` | `github-token` |
| `VAR_NAME` | Environment variable | `A-Z 0-9 _` (must start with letter/underscore) | `GITHUB_TOKEN` |

### Valid Examples

**Basic secret:**
```bash
# @secret:op:my-vault/credentials/api-key
API_KEY=placeholder
```

**Hyphenated names:**
```bash
# @secret:op:ghost-county/api-keys/github-token
GITHUB_TOKEN=placeholder
```

**Underscored names:**
```bash
# @secret:op:production_secrets/database_creds/postgres_password
DATABASE_PASSWORD=placeholder
```

**Multiple secrets:**
```bash
# @secret:op:my-vault/api-keys/github-token
GITHUB_TOKEN=placeholder

# @secret:op:my-vault/api-keys/stripe-key
STRIPE_SECRET_KEY=placeholder

# Plaintext variables work alongside secrets
APP_ENV=development
LOG_LEVEL=info
```

### Invalid Examples

**Missing tag prefix:**
```bash
# WRONG: Missing @secret:op: prefix
# my-vault/item/field
GITHUB_TOKEN=placeholder
```

**Using colons instead of slashes:**
```bash
# WRONG: Use / not :
# @secret:op:my-vault:item:field
GITHUB_TOKEN=placeholder
```

**Tag not followed by variable:**
```bash
# WRONG: Tag must be immediately before variable
# @secret:op:my-vault/item/field

GITHUB_TOKEN=placeholder  # Blank line breaks association
```

**Wrong component count:**
```bash
# WRONG: Must have exactly 3 components (vault/item/field)
# @secret:op:my-vault/item
GITHUB_TOKEN=placeholder
```

**Variable doesn't follow naming rules:**
```bash
# WRONG: Variable must start with letter or underscore
# @secret:op:my-vault/item/field
123_TOKEN=placeholder  # Can't start with number
```

### Parsing Rules

1. **Tag MUST be on its own line** starting with `# @secret:op:`
2. **Tag MUST be immediately followed** by variable assignment (no blank lines)
3. **Variable assignment format:** `VAR_NAME=value` (value is placeholder)
4. **Whitespace:** Leading/trailing spaces allowed, collapsed during parsing
5. **Comments:** Inline comments after tag are ignored: `# @secret:op:vault/item/field # This is ignored`

---

## Usage Guide

### Shell (Bash)

The shell wrapper (`haunt-secrets.sh`) provides functions for loading secrets in bash scripts.

#### Normal Mode: Load Secrets

**Source and load:**
```bash
# Source the script to make functions available
source Haunt/scripts/haunt-secrets.sh

# Load secrets from .env file
load_secrets .env

# Secrets are now available as environment variables
echo $GITHUB_TOKEN
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

**Direct execution:**
```bash
# Run as standalone script (loads and exports in current shell)
bash Haunt/scripts/haunt-secrets.sh .env

# NOTE: Exports only work if you source the script
source Haunt/scripts/haunt-secrets.sh .env
```

#### Validation Mode: Check Resolvability

Verify all secrets are accessible WITHOUT loading them:

```bash
# Validate secrets exist and are accessible
bash Haunt/scripts/haunt-secrets.sh --validate .env

# Output:
# ✓ Validated 3 secret(s): GITHUB_TOKEN, STRIPE_SECRET_KEY, DATABASE_PASSWORD
```

**Debug mode:**
```bash
# Show detailed diagnostics during validation
bash Haunt/scripts/haunt-secrets.sh --validate --debug .env

# Output:
# DEBUG: Checking GITHUB_TOKEN → op://my-vault/api-keys/github-token
# DEBUG: ✓ GITHUB_TOKEN is resolvable
# DEBUG: Checking STRIPE_SECRET_KEY → op://my-vault/api-keys/stripe-key
# DEBUG: ✓ STRIPE_SECRET_KEY is resolvable
# ✓ Validated 2 secret(s): GITHUB_TOKEN, STRIPE_SECRET_KEY
```

#### Individual Secret Fetching

```bash
# Source the script
source Haunt/scripts/haunt-secrets.sh

# Fetch a single secret
secret=$(fetch_secret "my-vault" "api-keys" "github-token")
echo $secret  # Actual secret value

# Use in command
curl -H "Authorization: token $(fetch_secret my-vault api-keys github-token)" \
  https://api.github.com/user
```

#### Error Handling

```bash
# Check exit code
if load_secrets .env; then
    echo "Secrets loaded successfully"
else
    echo "Failed to load secrets" >&2
    exit 1
fi

# Handle specific errors
if ! fetch_secret "vault" "item" "field" > /dev/null 2>&1; then
    exit_code=$?
    case $exit_code in
        1) echo "ERROR: Missing OP_SERVICE_ACCOUNT_TOKEN" >&2 ;;
        2) echo "ERROR: op CLI not installed" >&2 ;;
        3) echo "ERROR: Authentication failed" >&2 ;;
        4) echo "ERROR: Network error" >&2 ;;
        5) echo "ERROR: Secret not found" >&2 ;;
        *) echo "ERROR: Unknown error" >&2 ;;
    esac
fi
```

### Python

The Python module (`haunt_secrets.py`) provides functions for loading secrets in Python applications.

#### Normal Mode: Modify os.environ

**Load secrets into environment:**
```python
from haunt_secrets import load_secrets
import os

# Load secrets from .env file
load_secrets(".env")

# Secrets are now available in os.environ
github_token = os.environ["GITHUB_TOKEN"]
stripe_key = os.environ["STRIPE_SECRET_KEY"]

# Use in application
import requests
response = requests.get(
    "https://api.github.com/user",
    headers={"Authorization": f"token {github_token}"}
)
```

#### Get Secrets as Dict (Without Modifying Environment)

```python
from haunt_secrets import get_secrets

# Get all secrets as dictionary (doesn't modify os.environ)
secrets = get_secrets(".env")

github_token = secrets["GITHUB_TOKEN"]
stripe_key = secrets["STRIPE_SECRET_KEY"]

# Useful for passing to functions without polluting global environment
def configure_app(config):
    app.config["GITHUB_TOKEN"] = config["GITHUB_TOKEN"]
    app.config["STRIPE_KEY"] = config["STRIPE_SECRET_KEY"]

configure_app(secrets)
```

#### Validation Mode: Check Resolvability

```python
from haunt_secrets import validate_secrets

# Validate all secrets are accessible
result = validate_secrets(".env", debug=True)

if result.success:
    print(f"✓ All {len(result.validated)} secrets are valid")
    print(f"Validated: {', '.join(result.validated)}")
else:
    print(f"✗ Validation failed for {len(result.missing)} secret(s)")
    for var_name, op_ref, error_msg in result.missing:
        print(f"  - {var_name} ({op_ref}): {error_msg}")
```

#### Individual Secret Fetching

```python
from haunt_secrets import fetch_secret

# Fetch a single secret
github_token = fetch_secret("my-vault", "api-keys", "github-token")

# Use in application
import requests
response = requests.get(
    "https://api.github.com/user",
    headers={"Authorization": f"token {github_token}"}
)
```

#### Error Handling

```python
from haunt_secrets import (
    load_secrets,
    MissingTokenError,
    OpNotInstalledError,
    AuthenticationError,
    SecretNotFoundError,
    SecretTagError
)

try:
    load_secrets(".env")
except FileNotFoundError:
    print("ERROR: .env file not found")
except SecretTagError as e:
    print(f"ERROR: Malformed secret tag: {e}")
except MissingTokenError:
    print("ERROR: OP_SERVICE_ACCOUNT_TOKEN not set")
except OpNotInstalledError:
    print("ERROR: 1Password CLI not installed")
except AuthenticationError:
    print("ERROR: 1Password authentication failed")
except SecretNotFoundError as e:
    print(f"ERROR: Secret not found: {e}")
```

#### Logging Configuration

```python
import logging
from haunt_secrets import load_secrets

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)

# Module logs variable names (NOT secret values)
load_secrets(".env")

# Output:
# 2026-01-02 10:00:00 - haunt_secrets - INFO - Loading secret for GITHUB_TOKEN
# 2026-01-02 10:00:01 - haunt_secrets - INFO - Loaded 3 secrets and 2 plaintext variables
```

---

## Security Model

### What's Protected

The haunt-secrets wrapper provides **comprehensive anti-leak protection**:

#### 1. Logging Redaction

**What's logged:** Variable names, metadata (vault/item/field names), counts
**What's NEVER logged:** Secret values

**Shell example:**
```bash
bash Haunt/scripts/haunt-secrets.sh .env
# Output: Loaded: GITHUB_TOKEN, STRIPE_SECRET_KEY
# Note: Only variable NAMES, never values
```

**Python example:**
```python
load_secrets(".env")
# Log: INFO - Loading secret for GITHUB_TOKEN
# Log: INFO - Loaded 3 secrets and 2 plaintext variables
# Note: Only names/counts, never values
```

#### 2. Error Message Sanitization

Errors show **metadata only**, never secret values:

**Example errors:**
```
ERROR: Failed to fetch secret for GITHUB_TOKEN
ERROR: Vault: my-vault, Item: api-keys, Field: github-token
ERROR: Secret not found in 1Password
```

**What's safe to log:**
- Variable names (GITHUB_TOKEN)
- Vault names (my-vault)
- Item names (api-keys)
- Field names (github-token)

**What's NEVER logged:**
- Secret values
- Authentication tokens (except as errors)

#### 3. Validation Without Exposure

Validation mode checks resolvability **without exposing values**:

```bash
bash Haunt/scripts/haunt-secrets.sh --validate --debug .env

# Output shows metadata only:
# DEBUG: Checking GITHUB_TOKEN → op://my-vault/api-keys/github-token
# DEBUG: ✓ GITHUB_TOKEN is resolvable
```

Secrets are fetched to verify existence, then **immediately discarded**.

#### 4. Stdout/Stderr Separation (Shell)

**Shell implementation detail:**
- `stdout`: Secret values (controllable by caller via `$(...)`)
- `stderr`: Metadata and errors (safe to log)

**Example:**
```bash
# Capture secret value in variable (stdout)
secret=$(fetch_secret "vault" "item" "field")

# Errors go to stderr (safe to display/log)
fetch_secret "vault" "wrong-item" "field" 2>&1 | grep ERROR
# Output: ERROR: Secret not found in 1Password
```

### What's NOT Protected

The wrapper **cannot protect against**:

#### 1. Post-Load Exposure

Once secrets are loaded into environment, they're accessible to:
- Your application code
- Any process you spawn (`subprocess.run`, `os.system`)
- Debuggers and memory dumps
- Stack traces (if you pass secrets to logged functions)

**Your responsibility:**
```python
# WRONG: Secret in log message
logger.info(f"Using token: {os.environ['GITHUB_TOKEN']}")

# RIGHT: Only log metadata
logger.info("Using GitHub token from environment")
```

#### 2. Third-Party Code

The wrapper doesn't control third-party libraries:

**Example vulnerability:**
```python
import some_library

# If some_library logs all environment variables, secrets are exposed
some_library.debug_environment()  # May log GITHUB_TOKEN value!
```

**Mitigation:** Only load secrets just before use, unset after use if possible.

#### 3. Process Environment Inspection

Secrets in `os.environ` are visible to:
- `/proc/<pid>/environ` (Linux)
- Process explorers (Activity Monitor, Task Manager)
- Parent/child processes

**Mitigation:** Use `get_secrets()` (Python) to avoid polluting `os.environ`.

#### 4. .env File in Version Control

The wrapper manages **secret retrieval**, not `.env` file storage.

**NEVER commit `.env` files with real secrets**, even if placeholders:

```bash
# .gitignore
.env
.env.*
!.env.example  # Only commit example files
```

### Threat Model Summary

| Threat | Protected? | How |
|--------|------------|-----|
| Secrets in logs | ✅ Yes | Only variable names logged |
| Secrets in error messages | ✅ Yes | Metadata only in exceptions |
| Secrets in stdout (accidental echo) | ✅ Yes (Shell) | Stdout/stderr separation |
| Secrets in .env committed to git | ❌ No | Use `.gitignore` |
| Secrets in application logs | ❌ No | Your code's responsibility |
| Secrets in third-party logs | ❌ No | Audit dependencies |
| Secrets in process environment | ⚠️ Partial | Use `get_secrets()` to avoid `os.environ` |
| Secrets in memory dumps | ❌ No | Operating system security concern |

### Best Practices

1. **Use tagged .env files in version control:**
   ```bash
   # Commit this (safe)
   # @secret:op:my-vault/api-keys/github-token
   GITHUB_TOKEN=placeholder
   ```

2. **Never commit real secrets:**
   ```bash
   # Add to .gitignore
   .env
   .env.local
   .env.production
   ```

3. **Limit secret exposure window:**
   ```python
   # Load secrets just before use
   secrets = get_secrets(".env")
   api_call(secrets["GITHUB_TOKEN"])

   # Clear if no longer needed
   del secrets
   ```

4. **Audit third-party dependencies:**
   ```bash
   # Check if library logs environment
   grep -r "os.environ" venv/lib/python*/site-packages/some_library/
   ```

5. **Use service account tokens, not personal tokens:**
   - Service accounts have limited permissions
   - Can be rotated without affecting personal account
   - Audit trail separate from personal usage

---

## Troubleshooting

### "op not found"

**Symptom:**
```
ERROR: 1Password CLI (op) is not installed
```

**Cause:** 1Password CLI not installed or not in PATH

**Solution:**

1. **Install op CLI:**
   ```bash
   # macOS
   brew install 1password-cli

   # Linux (Debian/Ubuntu)
   # See Prerequisites section for full installation
   ```

2. **Verify installation:**
   ```bash
   which op
   # Should output: /usr/local/bin/op or similar

   op --version
   # Should output: 2.x.x
   ```

3. **Add to PATH if needed:**
   ```bash
   export PATH="/usr/local/bin:$PATH"
   echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
   ```

---

### "Authentication failed"

**Symptom:**
```
ERROR: Authentication failed with 1Password
ERROR: Check OP_SERVICE_ACCOUNT_TOKEN is valid
```

**Cause:** Service account token not set, invalid, or expired

**Solution:**

1. **Check token is set:**
   ```bash
   echo $OP_SERVICE_ACCOUNT_TOKEN
   # Should output: ops_... (not empty)
   ```

2. **Set token if missing:**
   ```bash
   export OP_SERVICE_ACCOUNT_TOKEN="ops_your_token_here"
   ```

3. **Verify token works:**
   ```bash
   op vault list
   # Should output vault names (not authentication error)
   ```

4. **Get new token if invalid:**
   - Log into 1Password at https://my.1password.com
   - Navigate to Settings → Developer → Service Accounts
   - Revoke old token, create new one
   - Update `OP_SERVICE_ACCOUNT_TOKEN`

---

### "Item not found"

**Symptom:**
```
ERROR: Secret not found in 1Password
ERROR: Vault: my-vault, Item: api-keys, Field: github-token
```

**Cause:** Vault, item, or field doesn't exist in 1Password

**Solution:**

1. **Verify vault exists:**
   ```bash
   op vault list
   # Check vault name matches tag exactly (case-sensitive)
   ```

2. **Verify item exists:**
   ```bash
   op item list --vault my-vault
   # Check item name matches tag exactly
   ```

3. **Verify field exists:**
   ```bash
   op item get api-keys --vault my-vault --format json | jq '.fields'
   # Check field name matches tag exactly
   ```

4. **Check service account permissions:**
   - Service account must have **read access** to vault
   - Check permissions at https://my.1password.com → Settings → Service Accounts

5. **Common mistakes:**
   - **Case sensitivity:** `my-vault` ≠ `My-Vault`
   - **Spaces:** `api keys` (with space) ≠ `api-keys` (hyphenated)
   - **Field label vs ID:** Use field **label** from 1Password UI

---

### "Malformed secret tag"

**Symptom:**
```
ERROR: Malformed secret tag on line 5: '# @secret:op:vault:item:field'
ERROR: Use '/' to separate vault/item/field, not ':'
```

**Cause:** Secret tag doesn't match expected format

**Solution:**

1. **Check tag format:**
   ```bash
   # WRONG: Using colons
   # @secret:op:vault:item:field

   # RIGHT: Using slashes
   # @secret:op:vault/item/field
   ```

2. **Verify component count:**
   ```bash
   # WRONG: Missing field
   # @secret:op:vault/item

   # RIGHT: Exactly 3 components
   # @secret:op:vault/item/field
   ```

3. **Check for blank lines:**
   ```bash
   # WRONG: Blank line between tag and variable
   # @secret:op:vault/item/field

   GITHUB_TOKEN=placeholder

   # RIGHT: Tag immediately before variable
   # @secret:op:vault/item/field
   GITHUB_TOKEN=placeholder
   ```

---

### "Tag not followed by variable"

**Symptom:**
```
ERROR: Secret tag on line 3 not followed by variable definition
```

**Cause:** Secret tag exists but next line is not a variable assignment

**Solution:**

1. **Check next line is variable:**
   ```bash
   # WRONG: Comment after tag
   # @secret:op:vault/item/field
   # This is a comment
   GITHUB_TOKEN=placeholder

   # RIGHT: Variable immediately after tag
   # @secret:op:vault/item/field
   GITHUB_TOKEN=placeholder
   ```

2. **Verify variable format:**
   ```bash
   # WRONG: Missing equals sign
   # @secret:op:vault/item/field
   GITHUB_TOKEN

   # RIGHT: Must have =value
   # @secret:op:vault/item/field
   GITHUB_TOKEN=placeholder
   ```

---

### "Network error"

**Symptom:**
```
ERROR: Network error connecting to 1Password
ERROR: Check internet connection and try again
```

**Cause:** Network timeout or connection failure

**Solution:**

1. **Check internet connection:**
   ```bash
   ping -c 3 1password.com
   # Should receive responses
   ```

2. **Check firewall/proxy:**
   - Ensure `op` CLI can reach 1Password servers
   - Check corporate firewall rules
   - Configure proxy if needed:
     ```bash
     export HTTPS_PROXY="http://proxy.company.com:8080"
     ```

3. **Retry with backoff:**
   ```bash
   # Retry a few times (network may be temporarily down)
   for i in {1..3}; do
       if load_secrets .env; then
           break
       fi
       echo "Retry $i failed, waiting 5 seconds..."
       sleep 5
   done
   ```

---

## Migration Guide

### Migrating from Plaintext .env to Tagged Format

**Goal:** Convert existing `.env` files to use 1Password secret references without disrupting workflows.

### Step 1: Audit Current Secrets

Identify which variables are secrets (should be in 1Password) vs plaintext (safe to commit):

```bash
# Current .env (plaintext secrets - UNSAFE)
GITHUB_TOKEN=ghp_abc123xyz789  # SECRET - should be in 1Password
STRIPE_SECRET_KEY=sk_test_xyz  # SECRET - should be in 1Password
APP_ENV=development            # PLAINTEXT - safe to commit
LOG_LEVEL=info                 # PLAINTEXT - safe to commit
DATABASE_URL=postgresql://localhost/mydb  # SECRET - has credentials
```

**Rule of thumb:**
- **Secrets:** API keys, passwords, tokens, database URLs with credentials
- **Plaintext:** Environment names, log levels, feature flags, public URLs

### Step 2: Store Secrets in 1Password

For each secret variable:

1. **Create item in 1Password:**
   - Open 1Password app
   - Select vault (e.g., `my-vault`)
   - Click "New Item" → Choose "Password" or "API Credential"
   - Set item name (e.g., `api-keys`)
   - Add field with label matching your needs (e.g., `github-token`)
   - Paste secret value

2. **Note the reference path:**
   - Vault: `my-vault`
   - Item: `api-keys`
   - Field: `github-token`

3. **Repeat for all secrets**

**Example 1Password structure:**
```
Vault: my-vault
  ├── Item: api-keys
  │   ├── Field: github-token → ghp_abc123xyz789
  │   ├── Field: stripe-key → sk_test_xyz
  ├── Item: database-credentials
  │   ├── Field: postgres-url → postgresql://user:pass@localhost/mydb
```

### Step 3: Create Tagged .env File

Replace secret values with placeholders and add tags:

```bash
# .env (tagged format - SAFE to commit)

# @secret:op:my-vault/api-keys/github-token
GITHUB_TOKEN=placeholder

# @secret:op:my-vault/api-keys/stripe-key
STRIPE_SECRET_KEY=placeholder

# @secret:op:my-vault/database-credentials/postgres-url
DATABASE_URL=placeholder

# Plaintext variables (no tags needed)
APP_ENV=development
LOG_LEVEL=info
```

**Key changes:**
- Secrets: Replaced real values with `placeholder`
- Secrets: Added `# @secret:op:...` tag immediately before variable
- Plaintext: Left as-is (no tags)

### Step 4: Validate Migration

**Before deploying, validate all secrets are resolvable:**

```bash
# Validate secrets without loading them
bash Haunt/scripts/haunt-secrets.sh --validate --debug .env

# Output should show all secrets as resolvable:
# DEBUG: Checking GITHUB_TOKEN → op://my-vault/api-keys/github-token
# DEBUG: ✓ GITHUB_TOKEN is resolvable
# DEBUG: Checking STRIPE_SECRET_KEY → op://my-vault/api-keys/stripe-key
# DEBUG: ✓ STRIPE_SECRET_KEY is resolvable
# ✓ Validated 2 secret(s): GITHUB_TOKEN, STRIPE_SECRET_KEY
```

**If validation fails:**
- Check vault/item/field names match exactly (case-sensitive)
- Verify service account has access to vault
- Ensure 1Password items and fields exist

### Step 5: Update Application Code

**No code changes needed if you use environment variables:**

```python
# Code remains unchanged
github_token = os.environ["GITHUB_TOKEN"]  # Still works
```

**Just change how you load .env:**

**Before (plaintext .env):**
```python
from dotenv import load_dotenv
load_dotenv()  # Loads plaintext .env
```

**After (tagged .env):**
```python
from haunt_secrets import load_secrets
load_secrets(".env")  # Fetches secrets from 1Password
```

### Step 6: Update CI/CD

**Before (secrets in CI environment variables):**
```yaml
# .github/workflows/test.yml
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # From GitHub Secrets
  STRIPE_SECRET_KEY: ${{ secrets.STRIPE_KEY }}
```

**After (1Password service account):**
```yaml
# .github/workflows/test.yml
env:
  OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}

steps:
  - name: Install 1Password CLI
    run: |
      brew install 1password-cli  # or appropriate for runner OS

  - name: Load secrets
    run: |
      source Haunt/scripts/haunt-secrets.sh
      load_secrets .env

  - name: Run tests
    run: pytest
```

**Key changes:**
- Only `OP_SERVICE_ACCOUNT_TOKEN` needs to be in CI secrets
- All other secrets fetched from 1Password at runtime
- Reduces secret sprawl across multiple CI systems

### Step 7: Commit Tagged .env

**Now safe to commit:**

```bash
git add .env
git commit -m "feat: migrate secrets to 1Password references"
git push
```

**What's committed:**
- `.env` with tags and placeholders (SAFE)
- No real secret values (SAFE)

**What's NOT committed:**
- Real secret values (stay in 1Password)
- Service account token (in CI secrets or local environment)

### Step 8: Team Onboarding

**New team members need:**

1. **1Password access:**
   - Add to team/organization
   - Grant vault access

2. **Service account token:**
   ```bash
   export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
   echo 'export OP_SERVICE_ACCOUNT_TOKEN="ops_..."' >> ~/.bashrc
   ```

3. **Clone repo and load secrets:**
   ```bash
   git clone repo
   cd repo
   source Haunt/scripts/haunt-secrets.sh
   load_secrets .env

   # Ready to develop!
   ```

**That's it!** No more sharing secrets via Slack/email.

---

## Example: Complete End-to-End Workflow

### Scenario: New API Integration

You're adding a new third-party API (SendGrid) to your application.

**1. Get API key from SendGrid:**
```
Login to SendGrid dashboard → API Keys → Create API Key
Copy key: SG.abc123xyz789...
```

**2. Store in 1Password:**
```
1Password app:
  - Vault: my-vault
  - New Item: "sendgrid-credentials"
  - New Field (label: api-key, value: SG.abc123xyz789...)
  - Save
```

**3. Add tag to .env:**
```bash
# .env

# @secret:op:my-vault/sendgrid-credentials/api-key
SENDGRID_API_KEY=placeholder

# Existing secrets and plaintext vars...
```

**4. Validate:**
```bash
bash Haunt/scripts/haunt-secrets.sh --validate --debug .env

# Output:
# DEBUG: Checking SENDGRID_API_KEY → op://my-vault/sendgrid-credentials/api-key
# DEBUG: ✓ SENDGRID_API_KEY is resolvable
```

**5. Use in code:**
```python
from haunt_secrets import load_secrets
load_secrets(".env")

import os
from sendgrid import SendGridAPIClient

sg = SendGridAPIClient(os.environ["SENDGRID_API_KEY"])
# Ready to send emails!
```

**6. Commit .env:**
```bash
git add .env
git commit -m "feat: add SendGrid integration"
git push
```

**Done!** API key is:
- ✅ Secure (in 1Password)
- ✅ Versionable (.env with placeholder is safe)
- ✅ Shareable (team gets access via 1Password)
- ✅ Auditable (1Password tracks access)

---

## Additional Resources

- **1Password CLI Documentation:** https://developer.1password.com/docs/cli
- **1Password Service Accounts:** https://developer.1password.com/docs/service-accounts
- **Haunt Framework:** `Haunt/README.md`
- **Implementation Details:**
  - Shell: `Haunt/scripts/haunt-secrets.sh`
  - Python: `Haunt/scripts/haunt_secrets.py`
  - Tests: `Haunt/tests/test-haunt-secrets.sh`, `Haunt/tests/test_haunt_secrets.py`

---

## Support

**Issues or questions?**
- Check [Troubleshooting](#troubleshooting) section first
- Review 1Password CLI logs: `op --help`
- Verify `.env` file format matches [Tag Format Specification](#tag-format-specification)
- File issue at: [Your project's issue tracker]

**Security concerns?**
- Review [Security Model](#security-model)
- Report security issues privately (not via public issues)
