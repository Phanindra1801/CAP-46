
#!/bin/bash

# CAP-46 Nginx Configuration Backup

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ACTIVE_CONFIG="$PROJECT_ROOT/nginx/active/default.conf"
BACKUP_DIR="$PROJECT_ROOT/nginx/backups"

# Verify active configuration
if [ ! -f "$ACTIVE_CONFIG" ]; then
    echo "ERROR: Active Nginx configuration not found."
    exit 1
fi

# Create backup directory if missing
mkdir -p "$BACKUP_DIR"

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

BACKUP_FILE="$BACKUP_DIR/default-$TIMESTAMP.conf"

echo "======================================"
echo " CAP-46 NGINX CONFIGURATION BACKUP"
echo "======================================"

# Copy active configuration
cp "$ACTIVE_CONFIG" "$BACKUP_FILE"

echo "Backup created successfully:"
echo "$BACKUP_FILE"

# Verify backup
if cmp -s "$ACTIVE_CONFIG" "$BACKUP_FILE"; then
    echo "Backup verification successful."
else
    echo "ERROR: Backup verification failed."
    exit 1
fi

echo "======================================"
