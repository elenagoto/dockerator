#!/bin/bash

# Enter development mode for a Next.js project
# Usage: ./dev-mode-frontend.sh <project-name>

set -e

PROJECT_NAME=$1
SAFE_URL=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}❌ Error: Project name required${NC}"
    exit 1
fi

# Check if project exists
if ! grep -q "^  $SAFE_URL:" docker-compose.yml; then
    echo -e "${RED}❌ Error: Project '$PROJECT_NAME' not found${NC}"
    exit 1
fi

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^dockerator_$SAFE_URL$"; then
    echo -e "${YELLOW}⚠️  Container not running. Starting...${NC}"
    docker-compose up -d "$SAFE_URL"
    sleep 2
fi

echo -e "${BLUE}🚀 Entering development environment for $PROJECT_NAME...${NC}"
echo ""
echo ""
echo "📦 Installing new packages:"
echo "  1. pkill -f 'next dev'        - Stop dev server"
echo "  2. npm install <package>      - Install package"
echo "  3. npm run dev                - Restart dev server"
echo ""
echo "🔧 Other commands:"
echo "  npm run build         - Build for production"
echo "  npm run lint          - Lint code"
echo ""
echo -e "${YELLOW}Type 'exit' when done${NC}"
echo ""

# Enter the container at /app
docker-compose exec "$SAFE_URL" sh