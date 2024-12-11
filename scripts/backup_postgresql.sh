#!/bin/bash

# Load the configuration file
source "$(dirname "$0")/../config/backup_config.sh"

# Backup directory
BACKUP_DIR="$(dirname "$0")/../backup"

# Ensure the backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory '$BACKUP_DIR' does not exist. Creating it now..."
    mkdir -p "$BACKUP_DIR"
    echo "Backup directory created: $BACKUP_DIR"
fi

# Retention period (number of days to keep backups)
RETENTION_DAYS=5

# Function to create a backup for a single database
backup_database() {
    local db_name="$1"
    local db_user="$2"
    local db_pass="$3"
    local db_host="$4"
    local db_port="$5"

    # Get the current date
    DATE=$(date +"%Y%m%d%H%M%S")

    # Backup file name
    BACKUP_FILE="$BACKUP_DIR/${db_name}-${DATE}.sql.gz"

    # Export PGPASSWORD environment variable to avoid password prompt
    export PGPASSWORD="$db_pass"

    # Create a backup of the database
    echo "Creating backup of database '$db_name' at $db_host:$db_port..."
    pg_dump -U "$db_user" -h "$db_host" -p "$db_port" -d "$db_name" -Fc | gzip > "$BACKUP_FILE"

    # Check if the backup was successful
    if [ $? -eq 0 ]; then
        echo "Backup successful: $BACKUP_FILE"
    else
        echo "Backup failed for database: $db_name"
        return 1
    fi

    # Remove the PGPASSWORD environment variable
    unset PGPASSWORD

    return 0
}

# Function to apply retention policy
apply_retention_policy() {
    local db_name="$1"
    echo "Applying retention policy for database '$db_name' (keeping only the last $RETENTION_DAYS backups)..."

    # Find and delete backups older than the retention period
    find "$BACKUP_DIR" -type f -name "${db_name}-*.sql.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

    echo "Retention policy applied for database '$db_name'."
}

# Main script execution
for db_name in "${!DB_CONFIG[@]}"; do
    IFS=':' read -r db_user db_pass db_host db_port <<< "${DB_CONFIG[$db_name]}"
    backup_database "$db_name" "$db_user" "$db_pass" "$db_host" "$db_port"
    apply_retention_policy "$db_name"
done