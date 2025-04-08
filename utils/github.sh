#!/bin/bash

# Check if gh CLI is installed
# Ensure that GitHub CLI is installed and available
ensure_github_cli_installed() {
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI (gh) is not installed or not in PATH."
        echo "Please install it from https://cli.github.com/ and try again."
        exit 1
    fi
}

ensure_github_logged_in() {
  # Check if user is authenticated with gh
  if ! gh auth status &> /dev/null; then
      echo "You are not authenticated with GitHub CLI. Please run 'gh auth login' first."
      exit 1
  fi
}

# Function to retrieve or create a GitHub token
get_github_token() {
    # Default values
    local default_note="${1:-'Composer Auth Token'}"
    local default_scope="read:packages"
    local github_host="github.com"
    local token_note=""
    local token_scope=""

    # Try to retrieve existing token
    local token

    # Ask for token note with default
    read -rp "Enter token note [$default_note]: " token_note
    token_note=${token_note:-$default_note}

    # Ask for token scope with default
    read -rp "Enter token scope [$default_scope]: " token_scope
    token_scope=${token_scope:-$default_scope}

    # Create a new token with provided or default values
    token=$(gh api --method POST /user/tokens \
        -f note="$token_note" \
        -f scopes="$token_scope" \
        --jq .token)

    if [ -z "$token" ]; then
        echo "Failed to create GitHub token. Please check your GitHub CLI authentication."
        exit 1
    fi


    echo "Successfully retrieved GitHub token."
    echo "$token"
}
