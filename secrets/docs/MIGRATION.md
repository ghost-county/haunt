# Migration Guide: Plaintext .env → Tagged Secrets

Step-by-step guide for migrating existing plaintext `.env` files to use 1Password secret tags.

## Before You Start

**Prerequisites:**
- 1Password account with CLI access
- Secrets already stored in 1Password (or ready to create them)
- Plaintext `.env` file you want to secure

**Time Estimate:** 15-30 minutes for typical project

**Risk Level:** LOW (original `.env` remains unchanged until you commit)

## Step 1: Audit Current Secrets

Identify which variables in your `.env` are actually secrets.

### What Qualifies as a Secret?

**YES - Tag as secret:**
- Database passwords/URLs with credentials
- API keys and tokens
- OAuth client secrets
- Encryption keys
- Private keys (SSH, SSL, etc.)
- Session secrets
- Webhook secrets
- Service account credentials

**NO - Keep as plaintext:**
- Public configuration (app name, port numbers)
- Feature flags
- Log levels
- Public API URLs (without credentials)
- Environment names (dev/staging/prod)

### Example Audit

```bash
# Original .env file
APP_NAME=MyApp                           # PLAINTEXT - public config
PORT=3000                                # PLAINTEXT - public config
LOG_LEVEL=debug                          # PLAINTEXT - public config
DATABASE_URL=postgresql://user:pass@...  # SECRET - contains password
API_KEY=sk_live_abc123...               # SECRET - credentials
STRIPE_PUBLIC_KEY=pk_live_xyz789...     # PLAINTEXT - public key
STRIPE_SECRET_KEY=sk_live_def456...     # SECRET - private key
FRONTEND_URL=https://app.example.com    # PLAINTEXT - public URL
SESSION_SECRET=random_string_here       # SECRET - security-critical
```

## Step 2: 1Password Setup

### Create Service Account (Recommended for CI/CD)

1. Go to 1Password: **Developer Settings → Service Accounts**
2. Click "Create Service Account"
3. Name it descriptively: `MyApp Production Secrets`
4. Grant read access to vault(s) containing your secrets
5. Save the token (starts with `ops_...`)

**Security Notes:**
- Service accounts are read-only by default (secure)
- Can be scoped to specific vaults (least privilege)
- Can be rotated without changing code
- Safe to use in CI/CD environments

### Create Vault Structure (Optional but Recommended)

Organize secrets in 1Password using consistent naming:

```
Vault: MyApp Production
├── Database
│   ├── password
│   └── url (full connection string)
├── API Keys
│   ├── stripe_secret
│   ├── github_token
│   └── sendgrid_key
└── Session
    └── secret
```

**Best Practice:** Use lowercase with underscores for field names (matches `.env` convention).

### Store Secrets in 1Password

For each secret you identified:

1. Open 1Password desktop/web app
2. Navigate to appropriate vault
3. Create or edit item
4. Add field with secret value
5. Note the path: `vault/item/field`

**Example:**

| Secret Variable | 1Password Path |
|-----------------|----------------|
| `DATABASE_URL` | `prod/database/url` |
| `API_KEY` | `prod/api-keys/stripe_secret` |
| `SESSION_SECRET` | `prod/session/secret` |

## Step 3: Add Tags to .env File

### Backup First

```bash
# Create backup of original .env
cp .env .env.backup
```

### Add Secret Tags

For each secret, add a comment tag **immediately before** the variable:

```bash
# Before (plaintext)
DATABASE_URL=postgresql://user:pass@localhost/db

# After (tagged)
# @secret:op:prod/database/url
DATABASE_URL=placeholder
```

**Complete Example:**

```bash
# ===========================
# Plain Configuration
# ===========================
APP_NAME=MyApp
PORT=3000
LOG_LEVEL=debug
FRONTEND_URL=https://app.example.com

# ===========================
# Secrets (from 1Password)
# ===========================

# @secret:op:prod/database/url
DATABASE_URL=postgresql://placeholder

# @secret:op:prod/api-keys/stripe_secret
STRIPE_SECRET_KEY=sk_live_placeholder

# @secret:op:prod/session/secret
SESSION_SECRET=placeholder
```

### Tag Format Checklist

For each secret tag, verify:

- [ ] Starts with `# @secret:op:`
- [ ] Has exactly 3 path components: `vault/item/field`
- [ ] Tag is **immediately before** variable (no blank lines)
- [ ] Variable assignment follows standard format: `VAR_NAME=value`
- [ ] Placeholder value is safe to commit (no real secrets)

## Step 4: Test Locally

### Install Package

```bash
cd Haunt/secrets
pip install -e .
```

### Set Service Account Token

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_xxxxxx..."
```

### Test Bash Usage

```bash
# Test sourcing the script
source Haunt/scripts/haunt-secrets.sh .env

# Verify secrets loaded
echo "DB_PASSWORD length: ${#DB_PASSWORD}"  # Should show length, not value
echo "API_KEY length: ${#API_KEY}"

# Verify plaintext variables
echo $APP_NAME  # Should show actual value
echo $PORT
```

**Expected Output:**
- Plaintext variables print actual values
- Secret lengths show they were loaded (but values not printed)
- No errors about missing secrets

### Test Python Usage

```python
from haunt_secrets import get_secrets

# Test loading
secrets = get_secrets('.env')

# Verify all variables present
assert 'APP_NAME' in secrets          # Plaintext
assert 'DATABASE_URL' in secrets      # Secret
assert 'API_KEY' in secrets           # Secret

# Verify plaintext values correct
assert secrets['APP_NAME'] == 'MyApp'
assert secrets['PORT'] == '3000'

# Verify secrets fetched (not placeholders)
assert secrets['DATABASE_URL'] != 'placeholder'
assert 'postgresql://' in secrets['DATABASE_URL']

print("✓ All tests passed")
```

### Troubleshooting Tests

**Error: "OP_SERVICE_ACCOUNT_TOKEN environment variable must be set"**

```bash
# Check if set
echo $OP_SERVICE_ACCOUNT_TOKEN

# If empty, set it
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
```

**Error: "Failed to fetch secret from 1Password"**

```bash
# Test manually
op read "op://prod/database/url"

# If fails, check:
# 1. Is secret path correct? (case-sensitive)
# 2. Does service account have vault access?
# 3. Does item/field exist in 1Password?
```

**Error: "Malformed secret tag"**

```bash
# Check tag format:
# CORRECT: # @secret:op:vault/item/field
# WRONG:   # @secret:op:vault/item (missing field)
```

## Step 5: Update Application

### Option A: No Code Changes (Environment Variables)

If your app already reads from `os.environ`, no changes needed:

```python
# Your existing code (no changes)
import os

DATABASE_URL = os.environ['DATABASE_URL']
API_KEY = os.environ['API_KEY']
```

**Setup:** Just source the script before running app:

```bash
source Haunt/scripts/haunt-secrets.sh .env
python app.py
```

### Option B: Explicit Loading (Python)

For applications that don't use `os.environ`:

```python
# Add at application startup
from haunt_secrets import load_secrets

# Load secrets (exports to os.environ)
load_secrets('.env')

# Now read normally
import os
DATABASE_URL = os.environ['DATABASE_URL']
```

### Option C: Configuration Class (Python)

For structured configuration:

```python
from haunt_secrets import get_secrets
from dataclasses import dataclass

@dataclass
class Config:
    app_name: str
    port: int
    database_url: str
    api_key: str

    @classmethod
    def from_env(cls, env_file: str = '.env'):
        secrets = get_secrets(env_file)
        return cls(
            app_name=secrets['APP_NAME'],
            port=int(secrets['PORT']),
            database_url=secrets['DATABASE_URL'],
            api_key=secrets['API_KEY']
        )

# Usage
config = Config.from_env()
```

## Step 6: Update CI/CD

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install 1Password CLI
        run: |
          curl -sSO https://downloads.1password.com/linux/debian/amd64/stable/1password-cli-amd64-latest.deb
          sudo dpkg -i 1password-cli-amd64-latest.deb

      - name: Load secrets
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
        run: |
          source Haunt/scripts/haunt-secrets.sh .env

      - name: Run tests
        run: pytest
```

**Setup:**
1. Go to GitHub repo: **Settings → Secrets → Actions**
2. Add secret: `OP_SERVICE_ACCOUNT_TOKEN` with your service account token
3. Commit workflow file

### GitLab CI

```yaml
# .gitlab-ci.yml
test:
  image: python:3.11
  before_script:
    - apt-get update && apt-get install -y curl
    - curl -sSO https://downloads.1password.com/linux/debian/amd64/stable/1password-cli-amd64-latest.deb
    - dpkg -i 1password-cli-amd64-latest.deb
    - source Haunt/scripts/haunt-secrets.sh .env
  script:
    - pytest
  variables:
    OP_SERVICE_ACCOUNT_TOKEN: $OP_SERVICE_ACCOUNT_TOKEN
```

**Setup:**
1. Go to GitLab project: **Settings → CI/CD → Variables**
2. Add variable: `OP_SERVICE_ACCOUNT_TOKEN` (protected, masked)
3. Commit `.gitlab-ci.yml`

### Docker

```dockerfile
# Dockerfile
FROM python:3.11-slim

# Install 1Password CLI
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sSO https://downloads.1password.com/linux/debian/amd64/stable/1password-cli-amd64-latest.deb && \
    dpkg -i 1password-cli-amd64-latest.deb && \
    rm 1password-cli-amd64-latest.deb

COPY . /app
WORKDIR /app

# Install dependencies
RUN pip install -r requirements.txt

# Load secrets and run app
CMD source Haunt/scripts/haunt-secrets.sh .env && python app.py
```

**Usage:**

```bash
docker build -t myapp .
docker run -e OP_SERVICE_ACCOUNT_TOKEN="ops_..." myapp
```

## Step 7: Commit Changes

### Review Changes

```bash
# Check what's being committed
git diff .env

# Verify:
# ✓ Secret values replaced with placeholders
# ✓ Tags added for all secrets
# ✓ Plaintext config unchanged
```

### Commit Tagged .env

```bash
# Add tagged .env (safe to commit - no secrets)
git add .env

# Commit with clear message
git commit -m "Security: Migrate secrets to 1Password tags

- Add @secret:op: tags for sensitive variables
- Replace secret values with placeholders
- Plaintext config remains unchanged
"
```

### Document for Team

Create or update project documentation:

```markdown
# Running the Project

## Prerequisites

- 1Password CLI installed
- Service account token for production vault

## Setup

1. Get the service account token (ask team lead)
2. Export the token:
   ```bash
   export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
   ```

3. Load secrets and run:
   ```bash
   source Haunt/scripts/haunt-secrets.sh .env
   python app.py
   ```

## First-Time Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Install 1Password CLI (if needed)
brew install 1password-cli

# Verify setup
op --version
```
```

## Step 8: Cleanup

### Remove Backup (After Verification)

```bash
# Verify everything works with new setup
source Haunt/scripts/haunt-secrets.sh .env
python app.py  # Should start normally

# If all good, remove backup
rm .env.backup
```

### Rotate Secrets (Recommended)

Since secrets were in plaintext before:

1. Assume they may have been exposed (git history, logs, etc.)
2. Generate new secrets in 1Password
3. Update applications to use new secrets
4. Revoke old secrets

**Example (Stripe):**
1. Generate new Stripe secret key in Stripe dashboard
2. Update 1Password item with new key
3. Restart app (fetches new key automatically)
4. Revoke old key in Stripe

## Verification Checklist

Before considering migration complete:

- [ ] All secrets tagged in `.env`
- [ ] All secrets stored in 1Password
- [ ] Service account created and scoped appropriately
- [ ] Local testing passes (bash and Python)
- [ ] Application runs with new setup
- [ ] CI/CD updated and passing
- [ ] Team documentation updated
- [ ] Original `.env.backup` removed (after verification)
- [ ] Secrets rotated (if previously exposed)
- [ ] `.env` committed (with placeholders only)

## Before vs After Comparison

### Before (Plaintext)

```bash
# .env (committed to git - INSECURE)
DATABASE_URL=postgresql://admin:SuperSecretPassword123@db.example.com/prod
API_KEY=sk_live_51234567890abcdefg
SESSION_SECRET=random_32_char_string_here
```

**Problems:**
- Secrets in git history forever
- Visible in CI logs if printed
- Shared via insecure channels (Slack, email)
- Hard to rotate (requires code changes)

### After (Tagged)

```bash
# .env (committed to git - SECURE)
# @secret:op:prod/database/url
DATABASE_URL=placeholder

# @secret:op:prod/api-keys/stripe
API_KEY=placeholder

# @secret:op:prod/session/secret
SESSION_SECRET=placeholder
```

**Benefits:**
- Only references in git (secrets in 1Password)
- Automatic redaction in logs
- Centralized secret management
- Easy rotation (no code changes)
- Audit trail in 1Password

## Troubleshooting

### "I forgot to backup .env and lost my secrets"

**Solution:** Check git history:

```bash
# View .env from previous commit
git show HEAD~1:.env

# Restore old version temporarily
git show HEAD~1:.env > .env.old

# Copy secrets to 1Password
# Then delete .env.old
```

### "Team member doesn't have 1Password access"

**Solutions:**

1. **Add to existing service account** (preferred for CI/CD)
2. **Create separate service account** with same vault access
3. **Use interactive login** (if they have 1Password account):
   ```bash
   eval $(op signin)  # Interactive login
   source Haunt/scripts/haunt-secrets.sh .env
   ```

### "Secrets work locally but fail in CI"

**Checklist:**
- [ ] `OP_SERVICE_ACCOUNT_TOKEN` set in CI secrets
- [ ] 1Password CLI installed in CI environment
- [ ] Service account has access to vault
- [ ] `.env` file exists in CI workspace (committed to git)

### "Want to use different vaults for dev/staging/prod"

**Solution:** Use environment-specific `.env` files:

```bash
# .env.development
# @secret:op:dev/database/url
DATABASE_URL=placeholder

# .env.production
# @secret:op:prod/database/url
DATABASE_URL=placeholder
```

**Usage:**

```bash
# Development
source Haunt/scripts/haunt-secrets.sh .env.development

# Production
source Haunt/scripts/haunt-secrets.sh .env.production
```

## Next Steps

- Review [README.md](../README.md) for detailed API documentation
- Set up automatic secret rotation schedule
- Add secrets to password manager's monitoring/breach detection
- Train team on new workflow
