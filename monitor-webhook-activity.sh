#!/bin/bash

# This script monitors Jenkins logs for webhook activity
# It helps troubleshoot webhook integration issues

# Configuration - replace these values with your own
JENKINS_HOME="/var/lib/jenkins"  # Default Jenkins home directory
LOG_FILE="$JENKINS_HOME/logs/jenkins.log"
WEBHOOK_KEYWORD="github-webhook"

# Check if we have access to Jenkins logs
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Cannot access Jenkins log file at $LOG_FILE"
    echo "You may need to run this script with sudo or adjust the JENKINS_HOME path."
    exit 1
fi

# Function to display colored output
color_echo() {
    local color=$1
    local message=$2
    
    case $color in
        "red")    echo -e "\e[31m$message\e[0m" ;;
        "green")  echo -e "\e[32m$message\e[0m" ;;
        "yellow") echo -e "\e[33m$message\e[0m" ;;
        "blue")   echo -e "\e[34m$message\e[0m" ;;
        *)        echo "$message" ;;
    esac
}

# Display header
clear
color_echo "blue" "===================================================="
color_echo "blue" "  Jenkins GitHub Webhook Activity Monitor"
color_echo "blue" "===================================================="
echo ""
color_echo "yellow" "Monitoring $LOG_FILE for webhook activity..."
color_echo "yellow" "Press Ctrl+C to stop monitoring."
echo ""

# Monitor the log file for webhook activity
tail -f "$LOG_FILE" | grep --line-buffered -i "$WEBHOOK_KEYWORD" | while read -r line; do
    # Highlight successful webhook events in green
    if echo "$line" | grep -q -i "success\|received\|processed"; then
        color_echo "green" "$line"
    # Highlight errors in red
    elif echo "$line" | grep -q -i "error\|fail\|exception"; then
        color_echo "red" "$line"
    # Other webhook-related lines in default color
    else
        echo "$line"
    fi
done
