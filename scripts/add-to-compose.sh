#!/bin/bash

# Add a new service to docker-compose.yml with safety checks
# Usage: ./add-to-compose.sh <app-name>

APP_NAME=$1
COMPOSE_FILE="docker-compose.yml"

if [ -z "$APP_NAME" ]; then
    echo "❌ Error: App name required"
    exit 1
fi

# Sanitize name
SAFE_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

# CHECK 1: Does service already exist in docker-compose.yml?
if grep -q "^  $SAFE_NAME:" "$COMPOSE_FILE"; then
    echo "⚠️  Service '$SAFE_NAME' already exists in docker-compose.yml"
    echo "   Skipping docker-compose.yml update"
    exit 0
fi

# The service block to add
SERVICE_BLOCK="
  $SAFE_NAME:
    build:
      context: ./apps/$APP_NAME
      dockerfile: Dockerfile
    container_name: dockerator_$SAFE_NAME
    labels:
      - \"traefik.enable=true\"
      - \"traefik.http.routers.$SAFE_NAME.rule=Host(\`$SAFE_NAME.localhost\`)\"
      - \"traefik.http.services.$SAFE_NAME.loadbalancer.server.port=3000\"
    volumes:
      - ./apps/$APP_NAME:/app
      - /app/node_modules
      - /app/.next
    environment:
      - NODE_ENV=development
    networks:
      - dockerator
    restart: unless-stopped
"

# Append to docker-compose.yml
echo "$SERVICE_BLOCK" >> "$COMPOSE_FILE"

echo "✅ Added $SAFE_NAME to docker-compose.yml"