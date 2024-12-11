#!/bin/bash

# Function to check if a cron job already exists
cron_job_exists() {
  local schedule="$1"
  local command="$2"
  crontab -l 2>/dev/null | grep -Fxq "$schedule $command"
}

# Function to add a new cron job if it doesn't already exist
add_cron_job() {
  local schedule="$1"
  local command="$2"
  
  if cron_job_exists "$schedule" "$command"; then
    echo "Cron job already exists: $schedule $command"
  else
    (crontab -l ; echo "$schedule $command") | crontab -
    echo "Added new cron job: $schedule $command"
  fi
}

# Example usage: Add a daily job to run each script in the scripts/ directory at 2 AM
schedule="0 2 * * *"
for script in scripts/*.sh; do
  if [ -x "$script" ]; then
    add_cron_job "$schedule" "$script"
  else
    echo "Script $script is not executable. Skipping."
  fi
done