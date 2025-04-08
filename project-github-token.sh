#!/bin/bash

# Check if an argument was provided
if [ $# -eq 0 ]; then
    echo "Error: No environment file path provided."
    echo "Usage: $0 /path/to/env/file"
    exit 1
fi

if [ -f "$ENV_FILE" ]; then
  echo "Invalid env file provided";
  exit 1;
fi

# Define .env.local file path from first argument
ENV_FILE="$1"

# Source the GitHub functions script
source utils/github.sh

# Ensure GitHub CLI is installed and user is logged in
ensure_github_cli_installed
ensure_github_logged_in

if grep -q "^[A-Za-z0-9_]*=" "$ENV_FILE" || [[ "$ENV_FILE" == *".env"* && -z $(cat "$ENV_FILE") ]]; then
    echo "Found existing environment file at $ENV_FILE"
else
    echo "Error: File exists but doesn't appear to be an environment file."
    echo "Environment files should contain KEY=VALUE pairs."
    exit 1
fi

# Get a GitHub token with a specific note (for public scope)
TOKEN=$(get_github_token "$1")

# Generate timestamp for the modification
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Handle the environment file

# Check if GITHUB_TOKEN already exists in the file
if grep -q "^GITHUB_TOKEN=" "$ENV_FILE"; then
    # Update existing token
    sed -i "s/^GITHUB_TOKEN=.*$/GITHUB_TOKEN=$TOKEN # Updated at $TIMESTAMP/" "$ENV_FILE"
    echo "Updated GITHUB_TOKEN in $ENV_FILE"
else
    # Append token to existing file
    # Make sure there's a newline at the end of the file
    if [ -s "$ENV_FILE" ] && [ "$(tail -c 1 "$ENV_FILE" | wc -l)" -eq 0 ]; then
        echo "" >> "$ENV_FILE" # Add a newline for clarity
    fi
    echo "GITHUB_TOKEN=$TOKEN # Added at $TIMESTAMP" >> "$ENV_FILE"
    echo "Added GITHUB_TOKEN to $ENV_FILE"
fi

echo "Process completed successfully."
