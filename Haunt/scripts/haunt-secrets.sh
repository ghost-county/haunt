#!/bin/bash

# haunt-secrets.sh - Load secrets from 1Password and export as environment variables
#
# Usage:
#   source Haunt/scripts/haunt-secrets.sh [.env file path]
#
# This script reads a .env file, detects secret tags (# @secret:op:vault/item/field),
# fetches secrets from 1Password using `op read`, and exports them as environment variables.
#
# Exit codes:
#   0 - Success
#   1 - Missing OP_SERVICE_ACCOUNT_TOKEN
#   2 - 1Password operation failed
#   3 - .env file not found
#
# Security:
#   - Never prints secret values
#   - Validates OP_SERVICE_ACCOUNT_TOKEN exists
#   - Uses `op read` (secure, no logs)
#   - Fails fast on any error

set -e

# Default .env file location
ENV_FILE="${1:-.env}"

# Validate OP_SERVICE_ACCOUNT_TOKEN exists
if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
    echo "ERROR: OP_SERVICE_ACCOUNT_TOKEN environment variable is not set" >&2
    echo "Please set your 1Password service account token before running this script" >&2
    return 1 2>/dev/null || exit 1
fi

# Validate .env file exists
if [[ ! -f "$ENV_FILE" ]]; then
    echo "ERROR: Environment file not found: $ENV_FILE" >&2
    return 3 2>/dev/null || exit 3
fi

# Track if we're being sourced (proper usage) or executed (improper)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "WARNING: This script should be sourced, not executed" >&2
    echo "Usage: source $0 [.env file]" >&2
fi

# Track previous line for secret detection
prev_line=""
secret_ref=""

# Process .env file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    # Detect secret tag: # @secret:op:vault/item/field
    if [[ "$line" =~ ^[[:space:]]*#[[:space:]]*@secret:op:(.+)$ ]]; then
        secret_ref="${BASH_REMATCH[1]}"
        continue
    fi

    # Skip empty lines and pure comments
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        secret_ref=""  # Reset secret ref on non-secret comments
        continue
    fi

    # Handle environment variables (key=value)
    if [[ "$line" =~ ^([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
        var_name="${BASH_REMATCH[1]}"
        var_value="${BASH_REMATCH[2]}"

        # Check if previous line was a secret tag
        if [[ -n "$secret_ref" ]]; then
            # Fetch secret from 1Password
            if ! secret_value=$(op read "op://${secret_ref}" 2>/dev/null); then
                echo "ERROR: Failed to read secret from 1Password: op://${secret_ref}" >&2
                return 2 2>/dev/null || exit 2
            fi
            # Export secret using eval for compatibility
            eval export "${var_name}=\"\${secret_value}\""
            secret_ref=""  # Reset after processing
        else
            # Regular variable - remove quotes if present
            var_value="${var_value%\"}"
            var_value="${var_value#\"}"
            var_value="${var_value%\'}"
            var_value="${var_value#\'}"

            # Export regular variable using eval for compatibility
            eval export "${var_name}=\"\${var_value}\""
        fi
    fi
done < "$ENV_FILE"

# Success - no output (security: don't print secrets)
return 0 2>/dev/null || exit 0
