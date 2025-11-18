#!/bin/bash

# Start a specific project
# Usage: ./start-project.sh <project-name>

set -e

PROJECT_NAME=$1
SAFE_URL=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}❌ Error: Project name required${NC}"
    exit 1
fi

# Check if project exists in docker-compose.yml
if ! grep -q "^  $SAFE_URL:" docker-compose.yml; then
    echo -e "${RED}❌ Error: Project '$PROJECT_NAME' not found${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Starting $PROJECT_NAME...${NC}"

# Start the specific service
docker-compose --profile projects up -d "$SAFE_URL"

echo -e "${GREEN}✅ $PROJECT_NAME started${NC}"
echo ""
echo "Access at: http://$SAFE_URL.localhost"