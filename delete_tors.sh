#!/bin/bash

# Lockfile path
LOCKFILE="/tmp/$(basename "$0").lock"
# Define the maximum execution time in seconds (1 hour)
MAX_RUNTIME=$((60 * 60))
# Track the script's start time
START_TIME=$(date +%s)

# Cleanup function to remove the lock file on exit
cleanup() {
    rm -f "$LOCKFILE"
}
trap cleanup EXIT SIGINT SIGTERM

# Ensure only one instance is running
if [ -f "$LOCKFILE" ]; then
    echo "Another instance of the script is already running. Exiting."
    exit 1
else
    echo $$ > "$LOCKFILE"
fi

# Source .bashrc to load your environment variables
source ~/.bashrc

# Define the maximum disk usage threshold in GiB
MAX_DISK_USAGE_GB=800  # Set your desired maximum disk usage in GiB

# Function to get the current disk usage in GiB using `hddusage`
get_disk_usage_gb() {
    raw_output=$(sh /usr/bin/bash_script 5)
    current_usage_gb=$(echo "$raw_output" | awk '{gsub("GiB", ""); print $2}' | grep -Eo '^[0-9]+' | head -n 1)
    echo "$current_usage_gb"
}

# Loop to continuously check disk space and delete torrents if necessary
while true; do
    # Get the current disk usage
    current_usage_gb=$(get_disk_usage_gb)
    current_usage_gb=$(echo "$current_usage_gb" | grep -Eo '^[0-9]+')

    # Verify if current_usage_gb is a valid number (integer)
    if ! [[ "$current_usage_gb" =~ ^[0-9]+$ ]]; then
        echo "Error: Current disk usage is not a valid integer: $current_usage_gb"
        exit 1
    fi

    echo "Current disk usage: ${current_usage_gb}GiB"

    # Check if disk usage is above the threshold
    if (( current_usage_gb > MAX_DISK_USAGE_GB )); then
        echo "Disk usage (${current_usage_gb}GiB) is above the limit (${MAX_DISK_USAGE_GB}GiB). Deleting torrent with the lowest upload..."

        # Find and delete the torrent with the lowest upload and label "delete"
        /home19/nitrobass24/bin/rtcontrol custom_1="delete" xfer=0 -s uploaded -qo name --select 1 --cull --yes

        # Update the disk usage after deletion
        current_usage_gb=$(get_disk_usage_gb)
        current_usage_gb=$(echo "$current_usage_gb" | grep -Eo '^[0-9]+')
        echo "Updated disk usage: ${current_usage_gb}GiB"
    else
        echo "Disk usage is below the limit. No further deletions required."
        break  # Exit the loop if disk usage is below the threshold
    fi
done
