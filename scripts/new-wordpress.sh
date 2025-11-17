#!/bin/bash

# Create a new WordPress project
# Usage: ./new-wordpress.sh <project-name>

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

# Sanitize names
SAFE_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr '-' '_')  # For database: hello_friend
SAFE_URL=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')   # For URL: hello-friend

echo -e "${BLUE}Creating WordPress project: $APP_NAME${NC}"
echo ""

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
# STEP 2: Download WordPress
# ============================================
if [ -f "$APP_DIR/wp-config.php" ]; then
    echo -e "${YELLOW}⚠️  WordPress already exists${NC}"
else
    echo -e "${BLUE}📥 Downloading WordPress...${NC}"
    curl -sS https://wordpress.org/latest.tar.gz | tar -xz -C "$APP_DIR" --strip-components=1
    echo -e "${GREEN}✅ WordPress downloaded${NC}"
fi
THEMES_DIR="$APP_DIR/wp-content/themes"
THEME_DIR="$THEMES_DIR/$APP_NAME"

# Remove default WordPress themes
if [ -d "$THEMES_DIR" ]; then
    echo -e "${BLUE}🧹 Cleaning default themes...${NC}"
    rm -rf "$THEMES_DIR"/*
    echo -e "${GREEN}✅ Removed default themes${NC}"
fi

# Create project theme directory
if [ ! -d "$THEME_DIR" ]; then
    mkdir -p "$THEME_DIR"
    echo -e "${GREEN}✅ Created theme directory: $APP_NAME${NC}"
else
    echo -e "${YELLOW}⚠️  Theme directory already exists${NC}"
fi
# ============================================
# STEP 3: Copy Dockerfile and Caddyfile
# ============================================
if [ ! -f "$APP_DIR/Dockerfile" ]; then
    cp scripts/templates/wordpress/Dockerfile "$APP_DIR/"
    echo -e "${GREEN}✅ Created Dockerfile${NC}"
else
    echo -e "${YELLOW}⚠️  Dockerfile already exists${NC}"
fi

if [ ! -f "$APP_DIR/Caddyfile" ]; then
    cp scripts/templates/wordpress/Caddyfile "$APP_DIR/"
    echo -e "${GREEN}✅ Created Caddyfile${NC}"
else
    echo -e "${YELLOW}⚠️  Caddyfile already exists${NC}"
fi

# ============================================
# STEP 4: Generate wp-config.php
# ============================================
if [ ! -f "$APP_DIR/wp-config.php" ]; then
    echo -e "${BLUE}🔧 Generating wp-config.php...${NC}"
    
    # Get WordPress salt keys
    SALT_KEYS=$(curl -sS https://api.wordpress.org/secret-key/1.1/salt/)
    
    # Create wp-config from template
    sed -e "s/{{DB_NAME}}/$SAFE_NAME/g" \
        -e "s/{{DB_USER}}/$SAFE_NAME/g" \
        -e "s/{{DB_PASSWORD}}/$SAFE_NAME/g" \
        -e "/{{SALT_KEYS}}/r /dev/stdin" \
        -e "/{{SALT_KEYS}}/d" \
        scripts/templates/wordpress/wp-config.php.template <<< "$SALT_KEYS" > "$APP_DIR/wp-config.php"
    
    echo -e "${GREEN}✅ Created wp-config.php${NC}"
else
    echo -e "${YELLOW}⚠️  wp-config.php already exists${NC}"
fi
# ============================================
# STEP 5: Create MySQL database and user
# ============================================
echo ""
echo -e "${BLUE}🗄️  Setting up database...${NC}"

# Check if MySQL container is running
if ! docker ps --format '{{.Names}}' | grep -q "^dockerator_mysql$"; then
    echo -e "${YELLOW}⚠️  MySQL container not running. Start it with: dockerator up${NC}"
    echo "   Database will be created when you start the containers."
else
    # Check if database already exists
    DB_EXISTS=$(docker exec dockerator_mysql mysql -uroot -pdockerator \
        -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$SAFE_NAME';" \
        -sN 2>/dev/null || echo "")
    
    if [ -n "$DB_EXISTS" ]; then
        echo -e "${YELLOW}⚠️  Database '$SAFE_NAME' already exists${NC}"
    else
        echo -e "${BLUE}   Creating database '$SAFE_NAME'...${NC}"
        
        # Create database
        docker exec dockerator_mysql mysql -uroot -pdockerator \
            -e "CREATE DATABASE IF NOT EXISTS $SAFE_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        
        # Create user and grant privileges
        docker exec dockerator_mysql mysql -uroot -pdockerator \
            -e "CREATE USER IF NOT EXISTS '$SAFE_NAME'@'%' IDENTIFIED BY '$SAFE_NAME';"
        
        docker exec dockerator_mysql mysql -uroot -pdockerator \
            -e "GRANT ALL PRIVILEGES ON $SAFE_NAME.* TO '$SAFE_NAME'@'%';"
        
        docker exec dockerator_mysql mysql -uroot -pdockerator \
            -e "FLUSH PRIVILEGES;"
        
        echo -e "${GREEN}✅ Database created: $SAFE_NAME${NC}"
        echo -e "${GREEN}✅ User created: $SAFE_NAME / $SAFE_NAME${NC}"
    fi
fi
# ============================================
# STEP 6: Add to docker-compose.yml
# ============================================
echo ""
if grep -q "^  $SAFE_URL:" docker-compose.yml; then
    echo -e "${YELLOW}⚠️  Already in docker-compose.yml${NC}"
else
    # Create service block for WordPress
    ./scripts/add-to-compose-wp.sh "$APP_NAME"
fi

# ============================================
# STEP 7: Remind about /etc/hosts
# ============================================
echo ""
echo -e "${BLUE}📋 Final steps:${NC}"

if grep -q "$SAFE_URL.localhost" /etc/hosts 2>/dev/null; then
    echo -e "${GREEN}✅ $SAFE_URL.localhost already in /etc/hosts${NC}"
else
    echo -e "${YELLOW}⚠️  Domain not in /etc/hosts yet${NC}"
    echo "   Run: dockerator hosts"
fi

echo ""
echo -e "${GREEN}🎉 WordPress project '$APP_NAME' ready!${NC}"
echo ""
echo "Database credentials:"
echo "  Database: $SAFE_NAME"
echo "  User: $SAFE_NAME"
echo "  Password: $SAFE_NAME"
echo ""
echo "Next steps:"
echo "  1. Sync hosts: dockerator hosts"
echo "  2. Start containers: dockerator up"
echo "  3. Visit: http://$SAFE_URL.localhost"
echo "  4. Complete WordPress installation"
echo ""
