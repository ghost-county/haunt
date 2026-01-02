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

# Constants
readonly SECRET_TAG_PREFIX="@secret:op:"
readonly SECRET_TAG_REGEX="^#[[:space:]]*${SECRET_TAG_PREFIX}(.+)$"
readonly VAULT_ITEM_FIELD_REGEX="^([^/]+)/([^/]+)/([^/]+)$"
readonly VAR_NAME_REGEX="^([A-Z_][A-Z0-9_]*)="

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
