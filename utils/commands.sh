#!/bin/bash

# Function to check if a required command is available
check_command_availability() {
    local command_name="$1"
    if ! command -v "$command_name" &> /dev/null; then
        echo "$command_name is not installed. Please install it first."
        exit 1
    fi
}

# Function to check if the script is running as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Please use sudo."
        exit 1
    fi
}
