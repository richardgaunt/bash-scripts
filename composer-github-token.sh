#!/bin/bash

source utils/commands.sh
source utils/github.sh

check_command_availability "composer"
ensure_github_cli_installed
ensure_github_logged_in

echo "Creating a new GitHub token with read-only access to public repositories..."

# Create a new GitHub token with read-only access to public repos
# The token will expire in 30 days (you can adjust this as needed)
iso_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
TOKEN="$(get_github_token "Composer auth token $iso_timestamp")"

echo "Successfully retrieved GitHub token."

# Configure Composer to use the token
echo "Configuring Composer with the GitHub token..."
composer config --global github-oauth.github.com "$TOKEN"

echo "Success! Composer is now configured with your GitHub token."
echo "This will allow for higher rate limits when downloading packages from GitHub."
