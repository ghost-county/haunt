#!/usr/bin/env bash
# Example: Using haunt-secrets.sh to load secrets from .env

# SETUP:
# 1. Create a .env file with secret tags:
#
# # @secret:op:ghost-county/api-keys/github-token
# GITHUB_TOKEN=placeholder
#
# # @secret:op:ghost-county/database/postgres-password
# DATABASE_PASSWORD=placeholder
#
# # Regular plaintext variable (no tag)
# DATABASE_URL=postgres://localhost/dev

# 2. Ensure OP_SERVICE_ACCOUNT_TOKEN is set:
export OP_SERVICE_ACCOUNT_TOKEN="${OP_SERVICE_ACCOUNT_TOKEN:-ops_your_token_here}"

# 3. Source the script and load secrets:
source "$(dirname "$0")/haunt-secrets.sh"
load_secrets .env

# 4. Use the secrets:
echo "GitHub Token: ${GITHUB_TOKEN:0:10}..." # Show first 10 chars only
echo "Database URL: $DATABASE_URL"
echo "Database Password: ${DATABASE_PASSWORD:0:5}..." # Show first 5 chars only

# SECURITY NOTES:
# - The script NEVER logs secret values, only variable names
# - Secrets are only exported to environment variables
# - Use cleanup trap if you need to clear secrets on exit

# Optional: Add cleanup trap to unset secrets on script exit
cleanup() {
    unset GITHUB_TOKEN DATABASE_PASSWORD
    echo "Secrets cleared" >&2
}
trap cleanup EXIT
