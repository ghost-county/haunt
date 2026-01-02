#!/usr/bin/env bash
# haunt-secrets.sh - 1Password secrets management wrapper
#
# Parses .env files for secret tags and retrieves secrets from 1Password.
# Tag format: # @secret:op:vault/item/field
#
# Security Note: This parser NEVER outputs or logs secret values, only
# metadata (vault/item/field names). Actual secret retrieval happens in
# separate functions with proper output redaction.

set -euo pipefail

# Constants - Tag Parsing
readonly SECRET_TAG_PREFIX="@secret:op:"
readonly SECRET_TAG_REGEX="^#[[:space:]]*${SECRET_TAG_PREFIX}(.+)$"
readonly VAULT_ITEM_FIELD_REGEX="^([^/]+)/([^/]+)/([^/]+)$"
readonly VAR_NAME_REGEX="^([A-Z_][A-Z0-9_]*)="

# Constants - fetch_secret Exit Codes
readonly EXIT_SUCCESS=0
readonly EXIT_MISSING_TOKEN=1
readonly EXIT_OP_NOT_INSTALLED=2
readonly EXIT_AUTH_FAILURE=3
readonly EXIT_NETWORK_ERROR=4
readonly EXIT_ITEM_NOT_FOUND=5
readonly EXIT_OTHER_ERROR=6

# parse_secret_tags - Parse .env file and extract secret tags
#
# Extracts 1Password secret references from .env files in the format:
#   # @secret:op:vault/item/field
#   VAR_NAME=placeholder
#
# Arguments:
#   $1 - Path to .env file
#
# Returns:
#   Zero or more lines in format: "VAR_NAME vault item field"
#   Empty output if no secret tags found (not an error)
#
# Exit codes:
#   0 - Success (including zero tags found)
#   1 - Error (file not found, malformed tag, tag not followed by variable)
#
# Example:
#   # @secret:op:ghost-county/api-keys/github-token
#   GITHUB_TOKEN=placeholder
#
# Outputs: "GITHUB_TOKEN ghost-county api-keys github-token"
parse_secret_tags() {
    local env_file="$1"

    # Validate input file exists
    if [[ ! -f "$env_file" ]]; then
        echo "ERROR: File not found: $env_file" >&2
        return 1
    fi

    # State tracking across lines
    local line_num=0
    local prev_tag=""
    local vault=""
    local item=""
    local field=""

    # Process file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_num=$((line_num + 1))

        # Detect secret tag line: # @secret:op:vault/item/field
        if [[ "$line" =~ $SECRET_TAG_REGEX ]]; then
            local tag_content="${BASH_REMATCH[1]}"

            # Parse vault/item/field components
            if [[ "$tag_content" =~ $VAULT_ITEM_FIELD_REGEX ]]; then
                vault="${BASH_REMATCH[1]}"
                item="${BASH_REMATCH[2]}"
                field="${BASH_REMATCH[3]}"

                # Validate all components are non-empty (shouldn't happen with regex, but be safe)
                if [[ -z "$vault" || -z "$item" || -z "$field" ]]; then
                    echo "ERROR: Malformed secret tag at line $line_num: missing vault, item, or field" >&2
                    return 1
                fi

                # Store tag for next line processing
                prev_tag="$tag_content"
            else
                echo "ERROR: Malformed secret tag at line $line_num: expected format 'vault/item/field'" >&2
                return 1
            fi

        # Detect variable definition following a tag: VAR_NAME=value
        elif [[ -n "$prev_tag" && "$line" =~ $VAR_NAME_REGEX ]]; then
            local var_name="${BASH_REMATCH[1]}"

            # Output parsed data (space-separated for easy parsing)
            echo "$var_name $vault $item $field"

            # Reset state for next tag
            prev_tag=""

        # Detect non-comment, non-empty line after tag (error: tag must be followed by variable)
        elif [[ -n "$prev_tag" && -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            echo "ERROR: Secret tag at line $((line_num - 1)) not followed by variable definition" >&2
            return 1
        fi

    done < "$env_file"

    # Check if file ended with unclosed tag (tag at end without variable)
    if [[ -n "$prev_tag" ]]; then
        echo "ERROR: Secret tag at end of file not followed by variable definition" >&2
        return 1
    fi

    return 0
}

# fetch_secret - Fetch secret value from 1Password using op CLI
#
# Retrieves a secret from 1Password using the op CLI tool.
# Requires OP_SERVICE_ACCOUNT_TOKEN environment variable for authentication.
#
# Arguments:
#   $1 - Vault name
#   $2 - Item name
#   $3 - Field name
#
# Returns:
#   Secret value on stdout (only if successful)
#   Error message on stderr
#
# Exit codes:
#   EXIT_SUCCESS (0) - Success (secret retrieved)
#   EXIT_MISSING_TOKEN (1) - Missing OP_SERVICE_ACCOUNT_TOKEN
#   EXIT_OP_NOT_INSTALLED (2) - op CLI not installed
#   EXIT_AUTH_FAILURE (3) - Authentication failure
#   EXIT_NETWORK_ERROR (4) - Network timeout or connection error
#   EXIT_ITEM_NOT_FOUND (5) - Item not found
#   EXIT_OTHER_ERROR (6) - Other error
#
# Security:
#   - NEVER logs or echoes the actual secret value to stderr
#   - Only outputs secret value to stdout on success
#   - Error messages do not contain secret data
#
# Example:
#   export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
#   secret=$(fetch_secret "ghost-county" "api-keys" "github-token")
fetch_secret() {
    local vault="$1"
    local item="$2"
    local field="$3"

    # Validate required environment variable
    if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
        echo "ERROR: OP_SERVICE_ACCOUNT_TOKEN environment variable is not set" >&2
        echo "ERROR: 1Password service account token required for authentication" >&2
        return $EXIT_MISSING_TOKEN
    fi

    # Check if op CLI is installed
    if ! command -v op &> /dev/null; then
        echo "ERROR: 1Password CLI (op) is not installed" >&2
        echo "ERROR: Install from: https://developer.1password.com/docs/cli/get-started/" >&2
        return $EXIT_OP_NOT_INSTALLED
    fi

    # Construct op:// reference
    local op_ref="op://${vault}/${item}/${field}"

    # Fetch secret from 1Password
    # Note: We capture both stdout and stderr to detect error types
    local temp_output=$(mktemp)
    local temp_error=$(mktemp)

    if op read "$op_ref" > "$temp_output" 2> "$temp_error"; then
        # Success: Output secret value (only place secret appears)
        cat "$temp_output"
        rm -f "$temp_output" "$temp_error"
        return $EXIT_SUCCESS
    else
        # Failure: Analyze error message to determine error type
        local error_msg=$(cat "$temp_error")
        rm -f "$temp_output" "$temp_error"

        # Detect error type from op CLI error message
        if [[ "$error_msg" =~ [Aa]uth|[Uu]nauthorized|[Ii]nvalid.*token ]]; then
            echo "ERROR: Authentication failed with 1Password" >&2
            echo "ERROR: Check OP_SERVICE_ACCOUNT_TOKEN is valid" >&2
            return $EXIT_AUTH_FAILURE
        elif [[ "$error_msg" =~ [Nn]etwork|[Tt]imeout|[Cc]onnection ]]; then
            echo "ERROR: Network error connecting to 1Password" >&2
            echo "ERROR: Check internet connection and try again" >&2
            return $EXIT_NETWORK_ERROR
        elif [[ "$error_msg" =~ [Nn]ot.*found|[Dd]oesn\'t.*exist ]]; then
            echo "ERROR: Secret not found in 1Password" >&2
            echo "ERROR: Vault: $vault, Item: $item, Field: $field" >&2
            return $EXIT_ITEM_NOT_FOUND
        else
            # Generic error
            echo "ERROR: Failed to fetch secret from 1Password" >&2
            echo "ERROR: $error_msg" >&2
            return $EXIT_OTHER_ERROR
        fi
    fi
}
