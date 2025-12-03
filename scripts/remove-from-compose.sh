#!/bin/bash

# Remove a service from docker-compose.yml
# Usage: ./remove-from-compose.sh <app-name>

APP_NAME=$1
COMPOSE_FILE="docker-compose.yml"

if [ -z "$APP_NAME" ]; then
    echo "❌ Error: App name required"
    exit 1
fi

# Sanitize name
SAFE_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

# Check if service exists
if ! grep -q "^  $SAFE_NAME:" "$COMPOSE_FILE"; then
    echo "⚠️  Service '$SAFE_NAME' not found in docker-compose.yml"
    exit 0
fi

# Use sed to remove the service block
# Pattern: From "  servicename:" to "    restart: "no" or unless-stopped"
sed -i.bak "/^  $SAFE_NAME:/,/^    restart: \"no\"/d" "$COMPOSE_FILE"
sed -i.bak "/^  $SAFE_NAME:/,/^    restart: unless-stopped/d" "$COMPOSE_FILE"

# Also remove the backup file
rm -f "$COMPOSE_FILE.bak"

echo "✅ Removed $SAFE_NAME from docker-compose.yml"