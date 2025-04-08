#!/bin/bash

# Script to display SSH key information for easy copying

# Define SSH key directory
SSH_DIR="$HOME/.ssh"

# Check if .ssh directory exists
if [ ! -d "$SSH_DIR" ]; then
    echo "Error: SSH directory not found at $SSH_DIR"
    exit 1
fi

# Find private keys (files without .pub extension that aren't known_hosts or config)
private_keys=$(find "$SSH_DIR" -type f -not -name "*.pub" -not -name "known_hosts*" -not -name "config" -not -name "authorized_keys" | sort)

# Check if any keys were found
if [ -z "$private_keys" ]; then
    echo "No SSH keys found in $SSH_DIR"
    exit 1
fi

# Create an array of key options
key_options=()
while IFS= read -r key; do
    key_name=$(basename "$key")
    key_options+=("$key_name")
done <<< "$private_keys"

# Display key selection menu
echo "Available SSH keys:"
for i in "${!key_options[@]}"; do
    echo "  $((i+1)). ${key_options[$i]}"
done

# Prompt user to select a key
read -p "Select a key (1-${#key_options[@]}): " selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#key_options[@]}" ]; then
    echo "Invalid selection"
    exit 1
fi

# Get the selected key
selected_key_name="${key_options[$((selection-1))]}"
selected_key="$SSH_DIR/$selected_key_name"

# Check if public key exists, if not try to create it
public_key="${selected_key}.pub"
if [ ! -f "$public_key" ]; then
    echo "Public key not found. Attempting to generate it..."
    ssh-keygen -y -f "$selected_key" > "$public_key"
    if [ $? -ne 0 ]; then
        echo "Failed to generate public key"
        exit 1
    fi
    echo "Public key generated successfully"
fi

# Print key information
echo -e "\n==================== SSH KEY INFORMATION ====================\n"

echo -e "===== PUBLIC KEY ====="
cat "$public_key"
echo -e "\n"

echo -e "===== MD5 FINGERPRINT ====="
ssh-keygen -E md5 -lf "$public_key"
echo -e "\n"

echo -e "===== SHA256 FINGERPRINT ====="
ssh-keygen -E sha256 -lf "$public_key"
echo -e "\n"

echo -e "==============================================================="
echo -e "Information for: $selected_key_name"
echo -e "You can copy and paste the information above as needed."

exit 0
