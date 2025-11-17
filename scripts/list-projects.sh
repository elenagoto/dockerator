#!/bin/bash

# List all Dockerator projects
# Usage: ./list-projects.sh

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}📋 Dockerator Projects${NC}"
echo ""

# Get running containers
RUNNING=$(docker-compose ps --services --filter "status=running" 2>/dev/null | grep -v "traefik\|mysql\|adminer\|mailpit" || true)

# Get all services from docker-compose.yml (excluding core services and network/volume definitions)
ALL_SERVICES=$(grep -E "^  [a-z0-9-]+:" docker-compose.yml | \
               grep -v "traefik:\|mysql:\|adminer:\|mailpit:" | \
               sed 's/://g' | sed 's/^  //' || true)

if [ -z "$ALL_SERVICES" ]; then
    echo -e "${YELLOW}No projects found${NC}"
    echo ""
    echo "Create one with:"
    echo "  dockerator new nextjs <name>"
    echo "  dockerator new wp <name>"
    exit 0
fi

# Header
echo -e "${BLUE}PROJECT              TYPE           STATUS          URL${NC}"
echo "────────────────────────────────────────────────────────────────────────"

# Display projects
for project in $ALL_SERVICES; do
    # Skip if not a real project directory
    if [ ! -d "apps/$project" ]; then
        continue
    fi
    
    # Determine type
    if [ -f "apps/$project/wp-config.php" ]; then
        TYPE="${CYAN}WordPress${NC}"
        TYPE_DISPLAY="WordPress"
    elif [ -f "apps/$project/package.json" ]; then
        TYPE="${GREEN}Next.js${NC}"
        TYPE_DISPLAY="Next.js  "
    else
        TYPE="Unknown"
        TYPE_DISPLAY="Unknown  "
    fi
    
    # Check status
    if echo "$RUNNING" | grep -q "^$project$"; then
        STATUS="${GREEN}●${NC} Running"
    else
        STATUS="○ Stopped"
    fi
    
    # URL
    URL="http://$project.localhost"
    
    # Use echo -e for color support, with manual spacing
    printf "%-20s " "$project"
    echo -en "$TYPE"
    printf "%-5s" ""  # Spacing after type
    echo -en "$STATUS"
    printf "%-5s" ""  # Spacing after status
    echo "$URL"
done

echo ""
echo "Commands:"
echo "  dockerator up              - Start all projects"
echo "  dockerator down            - Stop all projects"
echo "  dockerator logs <project>  - View project logs"
echo "  dockerator open <project>  - Open in VS Code"
echo ""