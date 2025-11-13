#!/bin/bash

# Remove a project completely
# Usage: ./remove-project.sh <project-name>

set -e

PROJECT_NAME=$1
APP_DIR="apps/$PROJECT_NAME"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}❌ Error: Project name required${NC}"
    exit 1
fi

SAFE_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

echo -e "${RED}🗑️  Removing project: $PROJECT_NAME${NC}"
echo ""

# Safety confirmation
read -p "Are you sure you want to remove '$PROJECT_NAME'? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

# ============================================
# STEP 1: Check and stop container
# ============================================
# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^dockerator_$SAFE_NAME$"; then
    echo -e "${YELLOW}⚠️  Container is running, stopping...${NC}"
    docker-compose stop "$SAFE_NAME"
    echo -e "${GREEN}✅ Container stopped${NC}"
else
    echo -e "${BLUE}ℹ️  Container not running${NC}"
fi

# Remove container if it exists (even if stopped)
if docker ps -a --format '{{.Names}}' | grep -q "^dockerator_$SAFE_NAME$"; then
    echo -e "${YELLOW}⚠️  Removing container...${NC}"
    docker-compose rm -f "$SAFE_NAME"
    echo -e "${GREEN}✅ Container removed${NC}"
fi

# ============================================
# STEP 2: Remove from docker-compose.yml
# ============================================
if grep -q "^  $SAFE_NAME:" docker-compose.yml; then
    ./scripts/remove-from-compose.sh "$PROJECT_NAME"
else
    echo -e "${BLUE}ℹ️  Not in docker-compose.yml${NC}"
fi

# ============================================
# STEP 3: Remove app folder
# ============================================
if [ -d "$APP_DIR" ]; then
    echo -e "${YELLOW}⚠️  Removing $APP_DIR...${NC}"
    rm -rf "$APP_DIR"
    echo -e "${GREEN}✅ Folder removed${NC}"
else
    echo -e "${BLUE}ℹ️  Folder doesn't exist${NC}"
fi

# ============================================
# STEP 4: Remind about /etc/hosts
# ============================================
echo ""
echo -e "${BLUE}📋 Final cleanup:${NC}"

if grep -q "$SAFE_NAME.localhost" /etc/hosts 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Remove from /etc/hosts:${NC}"
    echo "   127.0.0.1 $SAFE_NAME.localhost"
    echo ""
    echo "   Run: sudo nano /etc/hosts"
else
    echo -e "${GREEN}✅ Not in /etc/hosts${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Project '$PROJECT_NAME' removed!${NC}"