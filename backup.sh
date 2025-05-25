#!/bin/bash

# MySQL Backup Script
# Creates .sql backups for all user-defined databases using Docker MySQL container

# Load .env variables
if [ -f "./.env" ]; then
    . ./.env
    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        echo "Loading environment variables using fallback method"
        export $(grep -v '^#' .env | xargs)
    fi
else
    echo "Error: .env file not found!"
    exit 1
fi

# Configuration
BACKUP_DIR="../../backups/databases/mysql/"
DB_CONTAINER="mysql_container"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_LOG="$BACKUP_DIR/backup.log"
DAYS_TO_KEEP=7

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Log function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$BACKUP_LOG"
}

log "Starting MySQL backup process"

# List databases, excluding system databases
DATABASES=$(docker exec "$DB_CONTAINER" mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")

if [ -z "$DATABASES" ]; then
    log "No databases found!"
    exit 1
fi

log "Found databases: $DATABASES"

# Backup each database
for DB in $DATABASES; do
    DB=$(echo "$DB" | tr -d ' ')
    BACKUP_FILE="$BACKUP_DIR/${DB}_${TIMESTAMP}.sql"

    log "Backing up $DB to $BACKUP_FILE"
    
    docker exec "$DB_CONTAINER" mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$DB" > "$BACKUP_FILE"

    if [ $? -eq 0 ] && [ -s "$BACKUP_FILE" ]; then
        log "✅ Backup successful for $DB"
    else
        log "❌ Error backing up $DB"
        [ -f "$BACKUP_FILE" ] && cat "$BACKUP_FILE"
    fi
done

# Clean old backups
log "Cleaning backups older than $DAYS_TO_KEEP days"
find "$BACKUP_DIR" -type f -name "*.sql" -mtime +$DAYS_TO_KEEP -exec rm {} \;

log "MySQL backup process completed"
