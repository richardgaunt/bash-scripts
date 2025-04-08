#!/bin/bash

# Script to display GPG key information for easy copying

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if gpg is installed
if ! command -v gpg &> /dev/null; then
    echo "Error: GPG is not installed or not in your PATH"
    exit 1
fi

# Get list of secret keys (private keys)
secret_keys=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null)

if [ -z "$secret_keys" ]; then
    echo "No GPG keys found"
    exit 1
fi

# Extract key IDs and user IDs
declare -a key_ids=()
declare -a user_ids=()

while IFS= read -r line; do
    if [[ $line == *"sec"* ]]; then
        # Extract the key ID (after the / character)
        key_id=$(echo "$line" | grep -oP '(?<=/)[A-F0-9]{16}')
        if [ ! -z "$key_id" ]; then
            key_ids+=("$key_id")
        fi
    elif [[ $line == *"uid"* ]]; then
        # Extract the user ID (everything after the first ']')
        user_id=$(echo "$line" | sed 's/.*\]//g' | xargs)
        if [ ! -z "$user_id" ]; then
            user_ids+=("$user_id")
        fi
    fi
done <<< "$(gpg --list-secret-keys --keyid-format=long 2>/dev/null)"

# Check if we found keys
if [ ${#key_ids[@]} -eq 0 ]; then
    echo "No GPG keys could be parsed"
    exit 1
fi

# Display key selection menu
echo -e "${GREEN}Available GPG keys:${NC}"
for i in "${!key_ids[@]}"; do
    echo -e "  ${YELLOW}$((i+1)).${NC} ${user_ids[$i]} (${key_ids[$i]})"
done

# Prompt user to select a key
read -p "Select a key (1-${#key_ids[@]}): " selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#key_ids[@]}" ]; then
    echo "Invalid selection"
    exit 1
fi

# Get the selected key ID
selected_key_id="${key_ids[$((selection-1))]}"
selected_user_id="${user_ids[$((selection-1))]}"

# Print key information
echo -e "\n${GREEN}==================== GPG KEY INFORMATION ====================${NC}\n"

echo -e "${GREEN}===== PUBLIC KEY =====${NC}"
echo -e "${YELLOW}Key ID:${NC} $selected_key_id"
echo -e "${YELLOW}User ID:${NC} $selected_user_id"
echo

echo -e "${YELLOW}ASCII-armored public key:${NC}"
gpg --armor --export "$selected_key_id"

echo -e "\n${GREEN}===============================================================${NC}"
echo -e "You can copy and paste the public key above as needed."

exit 0
