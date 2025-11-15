#!/bin/bash

# Enter development mode for a WordPress project
# Usage: ./dev-mode.sh <project-name>

set -e

PROJECT_NAME=$1
SAFE_URL=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
THEME_DIR="/app/wp-content/themes/$PROJECT_NAME"

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
    echo -e "${RED}❌ Error: Project '$PROJECT_NAME' not found in docker-compose.yml${NC}"
    exit 1
fi

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^dockerator_$SAFE_URL$"; then
    echo -e "${YELLOW}⚠️  Container not running. Starting...${NC}"
    docker-compose up -d "$SAFE_URL"
    sleep 2
fi

echo -e "${BLUE}🔧 Setting up development environment for $PROJECT_NAME...${NC}"

# Cleanup function - removes Vite port from all WordPress services
cleanup() {
    echo ""
    echo -e "${BLUE}🧹 Cleaning up...${NC}"
    
    # Remove all Vite port mappings from docker-compose.yml
    sed -i.bak '/- "5173:5173"/d' docker-compose.yml
    rm -f docker-compose.yml.bak
    
    echo -e "${GREEN}✅ Development mode ended${NC}"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Add Vite port to this project
echo -e "${BLUE}📝 Adding Vite port (5173) to $PROJECT_NAME...${NC}"

# First, remove any existing Vite ports
sed -i.bak '/- "5173:5173"/d' docker-compose.yml
rm -f docker-compose.yml.bak

# Add Vite port to the specified service
# Insert after the "labels:" section, before "volumes:"
awk -v service="  $SAFE_URL:" -v port='    ports:\n      - "5173:5173"' '
$0 ~ service {found=1}
found && /^    volumes:/ && !done {
    print port
    done=1
}
{print}
' docker-compose.yml > docker-compose.yml.tmp

mv docker-compose.yml.tmp docker-compose.yml

echo -e "${GREEN}✅ Added port 5173 to $PROJECT_NAME${NC}"

# Restart the container to apply port changes
echo -e "${BLUE}🔄 Restarting container...${NC}"
docker-compose up -d "$SAFE_URL"
sleep 2

echo -e "${GREEN}✅ Container restarted${NC}"
echo ""
echo -e "${BLUE}📂 Entering development environment...${NC}"
echo -e "${YELLOW}Theme directory: $THEME_DIR${NC}"
echo ""
echo "Available commands:"
echo "  npm run dev    - Start Vite dev server (with HMR)"
echo "  npm run build  - Build for production"
echo "  npm install    - Install dependencies"
echo ""
echo -e "${YELLOW}Type 'exit' when done to cleanup${NC}"
echo ""

# Enter the container at the theme directory
docker-compose exec "$SAFE_URL" sh -c "cd $THEME_DIR && exec sh"