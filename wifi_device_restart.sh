#!/bin/bash

source $(HOME)/scripts/utils/commands.sh

# Path for the log file
LOG_FILE="/var/log/wifi_restart.log"

# Function to log messages to both console and log file
log() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1"
    echo "[$timestamp] $1" >> "$LOG_FILE"
}



# Function to check device status and return boolean result
check_device_status() {
    log "Checking ath12k device status..."
    local device_working=true

    # Check if device appears in lspci
    if lspci -v | grep -q "WCN785x"; then
        log "Device is physically present in PCI bus"
    else
        log "WARNING: Device not found in PCI bus!"
        device_working=false
    fi

    # Check if module is loaded
    if lsmod | grep -q 'ath12k'; then
        log "Module ath12k is loaded"
    else
        log "WARNING: Module ath12k is not loaded!"
        device_working=false
    fi

    # Check network interfaces (specifically wlp8s0)
    if ip link show wlp8s0 &>/dev/null; then
        log "Network interface wlp8s0 exists"

        # Check if interface is UP
        if ip link show wlp8s0 | grep -q "UP"; then
            log "Network interface wlp8s0 is UP"
        else
            log "WARNING: Network interface wlp8s0 is DOWN"
            device_working=false
        fi
    else
        log "WARNING: Network interface wlp8s0 not found!"
        device_working=false
    fi

    # Check for critical errors in dmesg
    if dmesg | grep 'ath12k' | grep -q -E 'failed|error|unable'; then
        log "WARNING: Critical errors found in dmesg for ath12k"
        device_working=false
    fi

    # Log detailed information for debugging
    log "Recent kernel messages for ath12k:"
    dmesg | grep 'ath12k' | tail -10 >> "$LOG_FILE"

    log "Network interfaces status:"
    ip link show wlp8s0 >> "$LOG_FILE" 2>&1

    # Return result (0 for working, 1 for not working in bash terms)
    if $device_working; then
        log "Device appears to be working correctly"
        return 0
    else
        log "Device appears to be NOT working correctly"
        return 1
    fi
}

# Main function to restart the WiFi device
restart_wifi() {
    log "Starting WiFi restart procedure..."

    # Save list of dependent modules
    DEPENDENT_MODULES=$(lsmod | grep -w "ath12k" | awk '{print $4}' | tr ',' ' ')
    log "Dependent modules: $DEPENDENT_MODULES"

    # Unload the module and dependencies
    log "Unloading ath12k module..."
    modprobe -r ath12k
    if [ $? -ne 0 ]; then
        log "Failed to unload ath12k module. Trying with force..."
        rmmod -f ath12k
        if [ $? -ne 0 ]; then
            log "ERROR: Could not unload ath12k module even with force!"
        fi
    fi

    # Small delay
    log "Waiting 2 seconds..."
    sleep 2

    # Reload the module
    log "Reloading ath12k module..."
    modprobe ath12k
    if [ $? -ne 0 ]; then
        log "ERROR: Failed to reload ath12k module!"
    else
        log "ath12k module reloaded successfully"
    fi

    # Wait for device to initialize
    log "Waiting 5 seconds for device initialization..."
    sleep 5

    # Check result
    check_device_status

    # Try to bring up wireless interfaces
    log "Attempting to bring up wireless interfaces..."
    for iface in $(ip link | grep -i wlan | cut -d: -f2 | tr -d ' '); do
        log "Bringing up interface $iface"
        ip link set $iface up
    done

    log "WiFi restart procedure completed"
}

# Main execution
check_root
log "=== WiFi Restart Script Started ==="
check_device_status
device_status=$?

if [ $device_status -eq 0 ]; then
    log "WiFi device is working correctly. No restart needed."
else
    log "WiFi device is not working correctly. Attempting restart..."
#    restart_wifi

    # Check if restart fixed the issue
    log "Checking device status after restart..."
    check_device_status
    if [ $? -eq 0 ]; then
        log "WiFi device is now working correctly after restart!"
    else
        log "WARNING: WiFi device is still not working correctly after restart!"
    fi
fi

exit 0
