#!/bin/bash

# SSH Key Generation and Setup Script

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
echo "Checking for required SSH tools..."

if ! command_exists ssh-keygen; then
    echo -e "${RED}Error: ssh-keygen is not installed. Please install OpenSSH.${NC}"
    exit 1
fi

# Check if Ed25519 algorithm is supported
if ! ssh-keygen -t ed25519 -f /tmp/test_key -N "" >/dev/null 2>&1; then
    echo -e "${RED}Error: Ed25519 algorithm not supported by your ssh-keygen.${NC}"
    rm -f /tmp/test_key /tmp/test_key.pub 2>/dev/null
    exit 1
fi

# Clean up test key
rm -f /tmp/test_key /tmp/test_key.pub 2>/dev/null

# Check if ssh-agent is running
if ! ps -p $SSH_AGENT_PID >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: SSH agent does not appear to be running.${NC}"
    echo "Starting ssh-agent..."
    eval "$(ssh-agent -s)"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to start ssh-agent.${NC}"
        exit 1
    fi
    echo -e "${GREEN}SSH agent started successfully.${NC}"
fi

# Collect information for the SSH key
echo -e "\n${GREEN}All prerequisites met. Let's create your SSH key.${NC}"
echo -e "${YELLOW}Please provide the following information:${NC}"

# Get email address
read -p "Email address for the key: " email_address

# Get key name
read -p "Suffix for the SSH key (will be added after id_ed25519__): " key_suffix
key_name="id_ed25519__${key_suffix}"
key_path="$HOME/.ssh/$key_name"

# Check if key already exists
if [ -f "$key_path" ]; then
    read -p "The key $key_path already exists. Overwrite? (y/n): " overwrite
    if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
        echo -e "${YELLOW}Key generation aborted.${NC}"
        exit 0
    fi
fi

# Generate the key
echo -e "\n${YELLOW}Generating SSH key with Ed25519 algorithm...${NC}"
echo -e "${YELLOW}You will be prompted to enter a passphrase for your key.${NC}"
ssh-keygen -t ed25519 -C "$email_address" -f "$key_path"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to generate SSH key.${NC}"
    exit 1
fi

# Add the key to the SSH agent
echo -e "\n${YELLOW}Adding the key to SSH agent...${NC}"
ssh-add "$key_path"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to add the key to SSH agent.${NC}"
    echo -e "${YELLOW}You can manually add it later with: ssh-add $key_path${NC}"
else
    echo -e "${GREEN}Key successfully added to SSH agent.${NC}"
fi

# Display the public key
echo -e "\n${GREEN}Your new SSH public key:${NC}"
cat "$key_path.pub"

echo -e "\n${GREEN}SSH key setup complete!${NC}"
echo -e "Key location: $key_path"
echo -e "Public key: $key_path.pub"
echo -e "\n${YELLOW}You can now add this public key to services like GitHub, GitLab, etc.${NC}"
