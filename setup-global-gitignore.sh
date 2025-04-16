#!/bin/bash

# Script to set up and configure global Git settings including gitignore, username, email, and signing keys

# Define colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Default location for global gitignore
DEFAULT_GITIGNORE_PATH="$HOME/.gitignore_global"

# Function to return default gitignore content
get_default_gitignore_content() {
    cat << 'EOL'
# IDE - PhpStorm, IntelliJ, etc
.idea/
*.iml
*.iws
.idea_modules/

# VS Code
.vscode/
*.code-workspace

# Vim
*.swp
*.swo
*~

# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# Linux
.directory
.Trash-*

# Temporary files
*.log
*.tmp
*.temp

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Composer
vendor/
composer.phar

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg

# Java
*.class
*.jar
*.war
*.ear
*.logs
.gradle

# Ruby
*.gem
*.rbc
/.config
/coverage/
/InstalledFiles
/pkg/
/spec/reports/
/spec/examples.txt
.rvmrc


## Database and content rules
.data
*.sql
*.tar.gz
*.sql.gz
EOL
}

# Function to create a gitignore file at a specified path
create_gitignore_file() {
    local target_path="$1"

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$target_path")"

    # Write the default content to the file
    get_default_gitignore_content > "$target_path"

    echo -e "${GREEN}Created global gitignore file at: ${target_path}${NC}"
}

# Function to check and setup global gitignore
setup_global_gitignore() {
    echo -e "\n${BLUE}=== Setting up global gitignore ===${NC}"

    # Check if global gitignore is already configured
    echo "Checking for existing global gitignore configuration..."
    CURRENT_GITIGNORE=$(git config --global core.excludesfile)

    if [ -z "$CURRENT_GITIGNORE" ]; then
        echo -e "${YELLOW}No global gitignore configured.${NC}"

        # Check if the default file exists anyway
        if [ -f "$DEFAULT_GITIGNORE_PATH" ]; then
            echo -e "${YELLOW}Found existing ${DEFAULT_GITIGNORE_PATH} file, but it's not configured in git.${NC}"
        else
            echo -e "Creating default global gitignore at ${DEFAULT_GITIGNORE_PATH}"
            create_gitignore_file "$DEFAULT_GITIGNORE_PATH"
        fi

        # Configure git to use the global gitignore
        echo "Configuring git to use global gitignore..."
        git config --global core.excludesfile "$DEFAULT_GITIGNORE_PATH"
        echo -e "${GREEN}Successfully configured git to use global gitignore at: ${DEFAULT_GITIGNORE_PATH}${NC}"

    else
        echo -e "${GREEN}Global gitignore already configured at: ${CURRENT_GITIGNORE}${NC}"

        # Check if the configured file exists
        if [ ! -f "$CURRENT_GITIGNORE" ]; then
            echo -e "${RED}Warning: Configured gitignore file does not exist!${NC}"
            read -p "Would you like to create the default gitignore at this location? (y/n): " CREATE_NEW

            if [[ $CREATE_NEW == "y" || $CREATE_NEW == "Y" ]]; then
                create_gitignore_file "$CURRENT_GITIGNORE"
            else
                echo "No changes made to gitignore."
            fi
        else
            echo -e "${GREEN}Configured gitignore file exists.${NC}"
            echo "Current gitignore patterns:"
            echo "----------------------"
            cat "$CURRENT_GITIGNORE"
            echo "----------------------"
        fi
    fi
}

# Function to check and setup git user name
setup_git_username() {
    echo -e "\n${BLUE}=== Setting up Git username ===${NC}"

    # Check if username is configured
    CURRENT_USERNAME=$(git config --global user.name)

    if [ -z "$CURRENT_USERNAME" ]; then
        echo -e "${YELLOW}No Git username configured.${NC}"
        read -p "Enter your Git username: " NEW_USERNAME

        if [ -n "$NEW_USERNAME" ]; then
            git config --global user.name "$NEW_USERNAME"
            echo -e "${GREEN}Successfully configured Git username: ${NEW_USERNAME}${NC}"
        else
            echo -e "${RED}Username not provided. Skipping username configuration.${NC}"
        fi
    else
        echo -e "${GREEN}Git username already configured: ${CURRENT_USERNAME}${NC}"
        read -p "Would you like to change your Git username? (y/n): " CHANGE_USERNAME

        if [[ $CHANGE_USERNAME == "y" || $CHANGE_USERNAME == "Y" ]]; then
            read -p "Enter your new Git username: " NEW_USERNAME

            if [ -n "$NEW_USERNAME" ]; then
                git config --global user.name "$NEW_USERNAME"
                echo -e "${GREEN}Successfully updated Git username to: ${NEW_USERNAME}${NC}"
            else
                echo -e "${RED}Username not provided. Keeping current username.${NC}"
            fi
        fi
    fi
}

# Function to check and setup git email
setup_git_email() {
    echo -e "\n${BLUE}=== Setting up Git email ===${NC}"

    # Check if email is configured
    CURRENT_EMAIL=$(git config --global user.email)

    if [ -z "$CURRENT_EMAIL" ]; then
        echo -e "${YELLOW}No Git email configured.${NC}"
        read -p "Enter your Git email: " NEW_EMAIL

        if [ -n "$NEW_EMAIL" ]; then
            git config --global user.email "$NEW_EMAIL"
            echo -e "${GREEN}Successfully configured Git email: ${NEW_EMAIL}${NC}"
        else
            echo -e "${RED}Email not provided. Skipping email configuration.${NC}"
        fi
    else
        echo -e "${GREEN}Git email already configured: ${CURRENT_EMAIL}${NC}"
        read -p "Would you like to change your Git email? (y/n): " CHANGE_EMAIL

        if [[ $CHANGE_EMAIL == "y" || $CHANGE_EMAIL == "Y" ]]; then
            read -p "Enter your new Git email: " NEW_EMAIL

            if [ -n "$NEW_EMAIL" ]; then
                git config --global user.email "$NEW_EMAIL"
                echo -e "${GREEN}Successfully updated Git email to: ${NEW_EMAIL}${NC}"
            else
                echo -e "${RED}Email not provided. Keeping current email.${NC}"
            fi
        fi
    fi
}

# Function to check for GPG/SSH keys and setup commit signing
setup_commit_signing() {
    echo -e "\n${BLUE}=== Setting up Git commit signing ===${NC}"

    # Check if signing is already configured
    CURRENT_SIGNING_KEY=$(git config --global user.signingkey)
    CURRENT_SIGN_COMMITS=$(git config --global commit.gpgsign)

    echo -e "Git offers multiple options for signing commits:"
    echo -e "1. GPG keys - Widely supported, requires GPG setup"
    echo -e "2. SSH keys - Convenient if you already use SSH keys for GitHub/GitLab"
    echo -e "3. Skip commit signing for now"
    read -p "Which signing method would you like to use? (1/2/3): " SIGNING_METHOD

    case $SIGNING_METHOD in
        1)
            # GPG key signing setup
            echo -e "\n${BLUE}Setting up GPG key signing${NC}"

            # Check if gpg is installed
            if ! command -v gpg &> /dev/null; then
                echo -e "${RED}GPG is not installed. Please install it to use GPG signing.${NC}"
                return
            fi

            # List existing GPG keys
            echo -e "\nYour existing GPG keys:"
            gpg --list-secret-keys --keyid-format=long

            if [ -n "$CURRENT_SIGNING_KEY" ]; then
                echo -e "${GREEN}Current signing key: ${CURRENT_SIGNING_KEY}${NC}"
                read -p "Would you like to change your signing key? (y/n): " CHANGE_KEY

                if [[ $CHANGE_KEY != "y" && $CHANGE_KEY != "Y" ]]; then
                    echo -e "Keeping current signing key."
                    USE_EXISTING_KEY="n"
                else
                    USE_EXISTING_KEY="y"
                fi
            else
                USE_EXISTING_KEY="y"
            fi

            if [[ $USE_EXISTING_KEY == "y" ]]; then
                read -p "Enter your GPG key ID (the long format ID shown after 'sec'): " GPG_KEY_ID

                if [ -n "$GPG_KEY_ID" ]; then
                    git config --global user.signingkey "$GPG_KEY_ID"
                    git config --global commit.gpgsign true
                    echo -e "${GREEN}Successfully configured GPG signing with key: ${GPG_KEY_ID}${NC}"

                    # Provide instructions for adding the key to GitHub/GitLab
                    echo -e "\n${YELLOW}Don't forget to add your GPG public key to your GitHub/GitLab account:${NC}"
                    echo -e "Run: ${GREEN}gpg --armor --export $GPG_KEY_ID${NC}"
                    echo -e "Then copy the output and add it to your GitHub/GitLab settings."
                else
                    echo -e "${RED}No key ID provided. Skipping GPG signing setup.${NC}"
                fi
            fi
            ;;

        2)
            # SSH key signing setup
            echo -e "\n${BLUE}Setting up SSH key signing${NC}"

            # Check if ssh-keygen is available
            if ! command -v ssh-keygen &> /dev/null; then
                echo -e "${RED}OpenSSH is not installed. Please install it to use SSH signing.${NC}"
                return
            fi

            # List existing SSH keys
            echo -e "\nYour existing SSH keys:"
            ls -la ~/.ssh/ 2>/dev/null | grep -E '.*id_.*' || echo "No SSH keys found in ~/.ssh/"

            read -p "Enter the path to your SSH key (e.g., ~/.ssh/id_ed25519): " SSH_KEY_PATH

            if [ -n "$SSH_KEY_PATH" ] && [ -f "$SSH_KEY_PATH" ]; then
                git config --global user.signingkey "$SSH_KEY_PATH"
                git config --global gpg.format ssh
                git config --global commit.gpgsign true
                echo -e "${GREEN}Successfully configured SSH signing with key: ${SSH_KEY_PATH}${NC}"

                # Provide instructions for adding the key to GitHub/GitLab
                echo -e "\n${YELLOW}Don't forget to add your SSH public key to your GitHub/GitLab account:${NC}"
                echo -e "Run: ${GREEN}cat ${SSH_KEY_PATH}.pub${NC}"
                echo -e "Then copy the output and add it to your GitHub/GitLab settings."
            else
                echo -e "${RED}Invalid SSH key path. Skipping SSH signing setup.${NC}"
            fi
            ;;

        3)
            # Skip signing setup
            echo -e "${YELLOW}Skipping commit signing configuration.${NC}"
            if [ "$CURRENT_SIGN_COMMITS" = "true" ]; then
                read -p "Would you like to disable commit signing? (y/n): " DISABLE_SIGNING

                if [[ $DISABLE_SIGNING == "y" || $DISABLE_SIGNING == "Y" ]]; then
                    git config --global --unset commit.gpgsign
                    echo -e "${GREEN}Commit signing has been disabled.${NC}"
                fi
            fi
            ;;

        *)
            echo -e "${RED}Invalid option. Skipping commit signing configuration.${NC}"
            ;;
    esac
}

# Main script execution
echo -e "${BLUE}=== Git Global Setup Script ===${NC}"

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed or not in PATH.${NC}"
    echo "Please install Git and try again."
    exit 1
fi

# Setup username, email, signing keys, and gitignore
setup_git_username
setup_git_email
setup_commit_signing
setup_global_gitignore

# Show summary
echo -e "\n${BLUE}=== Git Configuration Summary ===${NC}"
echo -e "Username: ${GREEN}$(git config --global user.name)${NC}"
echo -e "Email: ${GREEN}$(git config --global user.email)${NC}"

SIGNING_KEY=$(git config --global user.signingkey)
if [ -n "$SIGNING_KEY" ]; then
    SIGNING_FORMAT=$(git config --global gpg.format)
    SIGNING_FORMAT=${SIGNING_FORMAT:-gpg}  # Default to gpg if not set
    echo -e "Signing key: ${GREEN}${SIGNING_KEY} (${SIGNING_FORMAT})${NC}"
    echo -e "Commit signing: ${GREEN}$(git config --global commit.gpgsign || echo "disabled")${NC}"
else
    echo -e "Commit signing: ${YELLOW}Not configured${NC}"
fi

echo -e "Global gitignore: ${GREEN}$(git config --global core.excludesfile)${NC}"

echo -e "\n${GREEN}Git global setup complete!${NC}"
