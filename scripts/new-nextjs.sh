#!/bin/bash

# Create a new Next.js project
# Usage: ./new-nextjs.sh <project-name>

set -e

APP_NAME=$1
APP_DIR="apps/$APP_NAME"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$APP_NAME" ]; then
    echo "❌ Error: Project name required"
    exit 1
fi

echo -e "${BLUE}Creating Next.js project: $APP_NAME${NC}"
echo ""

# ============================================
# STEP 0: Check if app exists in docker-compose
# ============================================
SAFE_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
if grep -q "^  $SAFE_NAME:" docker-compose.yml; then
    echo -e "${YELLOW}⚠️  Project already in docker-compose.yml${NC}"
    IN_COMPOSE=true
else
    IN_COMPOSE=false
fi

# ============================================
# STEP 1: Create folder
# ============================================
if [ -d "$APP_DIR" ]; then
    echo -e "${YELLOW}⚠️  Folder $APP_DIR already exists${NC}"
else
    mkdir -p "$APP_DIR"
    echo -e "${GREEN}✅ Created $APP_DIR${NC}"
fi

# ============================================
# STEP 2: Create package.json
# ============================================
if [ -f "$APP_DIR/package.json" ]; then
    echo -e "${YELLOW}⚠️  package.json already exists${NC}"
else
    cat > "$APP_DIR/package.json" << EOF
{
  "name": "$APP_NAME",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "^15.0.4",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  }
}
EOF
    echo -e "${GREEN}✅ Created package.json${NC}"
fi

# ============================================
# STEP 3: Create Dockerfile
# ============================================

if [ -f "$APP_DIR/Dockerfile" ]; then
    echo -e "${YELLOW}⚠️  Dockerfile already exists${NC}"
else
    cat > "$APP_DIR/Dockerfile" << EOF
# Use Node.js 20 on Alpine Linux (lightweight)
FROM node:20-alpine

# Set working directory inside container
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose port 3000 (Next.js default)
EXPOSE 3000

# Start the development server
CMD ["npm", "run", "dev"]

EOF
    echo -e "${GREEN}✅ Created Dockerfile${NC}"
fi

# ============================================
# STEP 4: Create .dockerignore
# ============================================

if [ -f "$APP_DIR/.dockerignore" ]; then
    echo -e "${YELLOW}⚠️  .dockerignore already exists${NC}"
else
    cat > "$APP_DIR/.dockerignore" << EOF
node_modules
.next
.git
.DS_Store
npm-debug.log
.env*.local
README.md
EOF
    echo -e "${GREEN}✅ Created .dockerignore${NC}"
fi

# ============================================
# STEP 5: Create minimal Next.js app structure
# ============================================
if [ -d "$APP_DIR/src/app" ]; then
    echo -e "${YELLOW}⚠️  Next.js structure already exists${NC}"
else
    mkdir -p "$APP_DIR/src/app"
    cat > "$APP_DIR/src/app/page.js" << EOF
export default function Home() {
  return (
    <main style={{ padding: '2rem', fontFamily: 'system-ui' }}>
      <h1>🎯 $APP_NAME</h1>
      <p>Running in Dockerator!</p>
      <p>Access via: <a href="http://$SAFE_NAME.localhost">$SAFE_NAME.localhost</a></p>
    </main>
  )
}
EOF
    echo -e "${GREEN}✅ Created Next.js structure${NC}"
fi

# ============================================
# STEP 6: Add to docker-compose.yml
# ============================================
if [ "$IN_COMPOSE" = false ]; then
    ./scripts/add-to-compose.sh "$APP_NAME"
fi

# ============================================
# STEP 7: Check /etc/hosts
# ============================================
echo ""
echo -e "${BLUE}📋 Final steps:${NC}"

if grep -q "$SAFE_NAME.localhost" /etc/hosts 2>/dev/null; then
    echo -e "${GREEN}✅ $SAFE_NAME.localhost already in /etc/hosts${NC}"
else
    echo -e "${YELLOW}⚠️  Add to /etc/hosts:${NC}"
    echo "   127.0.0.1 $SAFE_NAME.localhost"
    echo ""
    echo "   Run: sudo nano /etc/hosts"
fi

echo ""
echo -e "${GREEN}🎉 Project '$APP_NAME' ready!${NC}"
echo ""
echo "Next steps:"
echo "  1. Start containers: ./dockerator up"
echo "  2. View logs: ./dockerator logs $SAFE_NAME"
echo "  3. Access app: http://$SAFE_NAME.localhost"