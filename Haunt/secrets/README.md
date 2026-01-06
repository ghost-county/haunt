# Haunt Secrets - 1Password Integration

Tag-based secret management for `.env` files using 1Password. Store secrets in 1Password, reference them with comment tags, and load them securely at runtime.

## Overview

**Problem:** Storing secrets in plaintext `.env` files is insecure. Git history, log files, and process listings can expose sensitive credentials.

**Solution:** Tag variables as secrets using comments, fetch them from 1Password at runtime, and automatically redact them from logs/output.

### What This Does

1. **Tag secrets** in `.env` files using `# @secret:op:vault/item/field` comments
2. **Fetch from 1Password** using the `op` CLI at runtime (never stored in plaintext)
3. **Auto-register with redaction** module to prevent logging/output leaks
4. **Export to environment** for use in your application

### Security Features

- Secrets never committed to git (only references)
- Secrets never printed to stdout/stderr
- Automatic redaction in logs using pattern detection
- Fails fast on errors (no partial exposure)
- Compatible with service account tokens for CI/CD

## Quick Start

### 5-Minute Setup

**Prerequisites:**
- 1Password account
- 1Password CLI installed: `brew install 1password-cli`
- Service account token (or interactive session)

**Setup Steps:**

```bash
# 1. Install the package
cd Haunt/secrets
pip install -e .

# 2. Create a service account token in 1Password
# Go to 1Password → Developer Settings → Service Accounts
# Create token with read access to your vault(s)

# 3. Set the token in your environment
export OP_SERVICE_ACCOUNT_TOKEN="ops_xxxxxx..."

# 4. Create tagged .env file
cat > .env <<EOF
# Plain config
APP_NAME=MyApp
LOG_LEVEL=debug

# @secret:op:prod/database/password
DB_PASSWORD=placeholder

# @secret:op:prod/api/key
API_KEY=placeholder
EOF

# 5. Test it works
python -c "from haunt_secrets import get_secrets; print(get_secrets('.env'))"
```

## Tag Format Specification

### Basic Format

```bash
# @secret:op:vault/item/field
VARIABLE_NAME=placeholder_value
```

**Components:**
- `# @secret:op:` - Required prefix (must be exact, including spaces)
- `vault` - 1Password vault name
- `item` - Item name within vault
- `field` - Field name within item (e.g., "password", "token", "api_key")

### Valid Examples

```bash
# Single word paths
# @secret:op:production/database/password
DB_PASSWORD=placeholder

# Paths with spaces (valid in 1Password)
# @secret:op:My Vault/API Keys/Github Token
GITHUB_TOKEN=placeholder

# Multiple secrets
# @secret:op:prod/stripe/secret_key
STRIPE_SECRET_KEY=sk_test_placeholder

# @secret:op:prod/stripe/public_key
STRIPE_PUBLIC_KEY=pk_test_placeholder
```

### Invalid Examples

```bash
# WRONG: Missing @secret prefix
# op:prod/database/password
DB_PASSWORD=placeholder

# WRONG: Wrong prefix (@notsecret)
# @notsecret:op:prod/database/password
DB_PASSWORD=placeholder

# WRONG: Incomplete path (missing field)
# @secret:op:prod/database
DB_PASSWORD=placeholder

# WRONG: Not directly before variable
# @secret:op:prod/database/password
# This is a comment
DB_PASSWORD=placeholder  # Tag must be IMMEDIATELY before variable
```

### Mixed Content (Recommended Pattern)

```bash
# ===========================
# Plain Configuration
# ===========================
APP_NAME=Ghost County
ENV=production
LOG_LEVEL=info

# ===========================
# Secrets (from 1Password)
# ===========================

# @secret:op:prod/database/url
DATABASE_URL=postgresql://placeholder

# @secret:op:prod/api/key
API_KEY=placeholder

# @secret:op:prod/stripe/secret_key
STRIPE_SECRET_KEY=sk_test_placeholder
```

## Bash Usage

### Interactive Sessions

```bash
# Load secrets into current shell
source Haunt/scripts/haunt-secrets.sh .env

# Now all variables are available
echo $APP_NAME      # Works (plaintext variable)
echo $DB_PASSWORD   # Works (fetched from 1Password)
```

### Scripts

```bash
#!/bin/bash

# Load secrets at start of script
source /path/to/Haunt/scripts/haunt-secrets.sh .env

# Use variables normally
psql "$DATABASE_URL" -c "SELECT 1"
curl -H "Authorization: Bearer $API_KEY" https://api.example.com
```

### Error Handling

The bash script exits with specific codes:

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success |
| 1 | `OP_SERVICE_ACCOUNT_TOKEN` not set |
| 2 | 1Password operation failed (secret not found, auth failed) |
| 3 | `.env` file not found |

```bash
#!/bin/bash

if ! source Haunt/scripts/haunt-secrets.sh .env; then
    case $? in
        1) echo "ERROR: Set OP_SERVICE_ACCOUNT_TOKEN" ;;
        2) echo "ERROR: Failed to fetch secrets from 1Password" ;;
        3) echo "ERROR: .env file not found" ;;
    esac
    exit 1
fi

# Proceed with secrets loaded
```

## Python Usage

### API Mode 1: Side-Effect (Export to os.environ)

```python
from haunt_secrets import load_secrets
import os

# Load secrets and export to os.environ
load_secrets('.env')

# Access via os.environ
db_password = os.environ['DB_PASSWORD']
api_key = os.environ['API_KEY']
```

**Use when:** You want to integrate with libraries that read from `os.environ` (Django, Flask, etc.)

### API Mode 2: Pure Function (Return Dict)

```python
from haunt_secrets import get_secrets

# Get secrets as dict (no side effects)
secrets = get_secrets('.env')

# Access via dict
db_password = secrets['DB_PASSWORD']
api_key = secrets['API_KEY']
```

**Use when:** You want explicit control over secret handling or avoid modifying global state.

### Error Handling

```python
from haunt_secrets import get_secrets

try:
    secrets = get_secrets('.env')
except RuntimeError as e:
    if 'OP_SERVICE_ACCOUNT_TOKEN' in str(e):
        print("ERROR: Set OP_SERVICE_ACCOUNT_TOKEN environment variable")
    elif 'Failed to fetch secret' in str(e):
        print("ERROR: 1Password operation failed")
    else:
        print(f"ERROR: {e}")
    exit(1)
except FileNotFoundError:
    print("ERROR: .env file not found")
    exit(1)
```

### Automatic Redaction

```python
from haunt_secrets import get_secrets
import logging

# Configure logging with redacting formatter
from haunt_secrets.redaction import SecretRedactingFormatter

handler = logging.StreamHandler()
handler.setFormatter(SecretRedactingFormatter())
logger = logging.getLogger()
logger.addHandler(handler)
logger.setLevel(logging.INFO)

# Load secrets (automatically registered for redaction)
secrets = get_secrets('.env')

# Secret values are automatically redacted in logs
logger.info(f"Using API key: {secrets['API_KEY']}")
# Output: Using API key: ***REDACTED***
```

### Manual Secret Registration

```python
from haunt_secrets.redaction import register_secret, redact

# Manually register additional secrets
register_secret('SESSION_TOKEN', 'abc123xyz789')

# Check if text contains secrets
from haunt_secrets.redaction import contains_secret
text = "Token: abc123xyz789"
print(contains_secret(text))  # True

# Redact secrets from text
print(redact(text))  # "Token: ***REDACTED***"
```

## Security

### What's Protected

1. **Secrets never in plaintext files**
   - Only references (tags) committed to git
   - Actual values fetched at runtime

2. **Secrets never in logs**
   - Automatic pattern detection (API keys, OAuth tokens, UUIDs)
   - Manual registration for custom secrets
   - Redacted in exception messages and tracebacks

3. **Secrets never in stdout/stderr**
   - `op read` uses `capture_output=True`
   - Bash script suppresses all output
   - Python API prevents printing

4. **Fail-fast on errors**
   - Missing token → immediate error
   - Secret not found → immediate error
   - No partial loading (all-or-nothing)

### What's NOT Protected

1. **Process memory** - Secrets are in memory while your app runs (normal for all apps)
2. **Core dumps** - If your process crashes and dumps memory, secrets may be in dump
3. **OS environment** - Other processes with same UID can read `os.environ` (standard Linux behavior)
4. **Malicious code** - If your app is compromised, secrets can be exfiltrated

### Best Practices

1. **Use service account tokens in CI/CD**
   - Create read-only service accounts
   - Scope to specific vaults
   - Rotate regularly

2. **Don't print secrets**
   - Use redaction module for all logging
   - Avoid `print(secret_value)`
   - Avoid f-strings in logs without redaction

3. **Rotate secrets regularly**
   - Update in 1Password
   - No code changes needed (fetched at runtime)

4. **Use vault namespaces**
   - Separate vaults for dev/staging/prod
   - Limit access per environment

5. **Audit access**
   - 1Password logs all secret access
   - Review audit logs regularly

## Migration from Plaintext

See [MIGRATION.md](docs/MIGRATION.md) for step-by-step guide to migrating existing `.env` files.

## Testing

```bash
# Run all tests
cd Haunt/secrets
pytest

# Run with coverage
pytest --cov=haunt_secrets tests/

# Run specific test
pytest tests/test_loader.py -v
```

## Troubleshooting

### "OP_SERVICE_ACCOUNT_TOKEN environment variable must be set"

**Solution:** Set your 1Password service account token:

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_xxxxxx..."
```

Or create one at: 1Password → Developer Settings → Service Accounts

### "1Password CLI (op) not found"

**Solution:** Install the 1Password CLI:

```bash
brew install 1password-cli
```

Or download from: https://developer.1password.com/docs/cli/get-started/

### "Failed to fetch secret from 1Password"

**Possible causes:**
- Secret doesn't exist at specified path
- Service account doesn't have access to vault
- Vault/item/field name is incorrect (case-sensitive)

**Solution:** Verify the path in 1Password:

```bash
# Test manually
op read "op://vault/item/field"
```

### "Malformed secret tag"

**Cause:** Tag doesn't have exactly 3 parts (vault/item/field)

**Solution:** Ensure tag format:

```bash
# CORRECT: 3 parts separated by /
# @secret:op:vault/item/field

# WRONG: Only 2 parts
# @secret:op:vault/item
```

## License

See root repository LICENSE.

## Support

For issues, see the main Haunt repository: [ghost-county](https://github.com/ghost-county/haunt)
