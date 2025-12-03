#!/bin/bash

# Create a new Vite + React + TypeScript project
# Usage: ./new-vite-react.sh <project-name>

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

echo -e "${BLUE}Creating Vite + React + TypeScript project: $APP_NAME${NC}"
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
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.4",
    "typescript": "^5.6.3",
    "vite": "^5.4.11"
  }
}
EOF
    echo -e "${GREEN}✅ Created package.json${NC}"
fi

# ============================================
# STEP 3: Copy Dockerfile from template
# ============================================
if [ -f "$APP_DIR/Dockerfile" ]; then
    echo -e "${YELLOW}⚠️  Dockerfile already exists${NC}"
else
    cp scripts/templates/vite/Dockerfile "$APP_DIR/Dockerfile"
    echo -e "${GREEN}✅ Created Dockerfile${NC}"
fi

# ============================================
# STEP 4: Copy .dockerignore from template
# ============================================
if [ -f "$APP_DIR/.dockerignore" ]; then
    echo -e "${YELLOW}⚠️  .dockerignore already exists${NC}"
else
    cp scripts/templates/vite/.dockerignore "$APP_DIR/.dockerignore"
    echo -e "${GREEN}✅ Created .dockerignore${NC}"
fi

# ============================================
# STEP 5: Create vite.config.ts
# ============================================
if [ -f "$APP_DIR/vite.config.ts" ]; then
    echo -e "${YELLOW}⚠️  vite.config.ts already exists${NC}"
else
    cat > "$APP_DIR/vite.config.ts" << EOF
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // Needed for Docker
    port: 5173,
    watch: {
      usePolling: true // Needed for hot reload in Docker
    }
  }
})
EOF
    echo -e "${GREEN}✅ Created vite.config.ts${NC}"
fi

# ============================================
# STEP 6: Create tsconfig.json
# ============================================
if [ -f "$APP_DIR/tsconfig.json" ]; then
    echo -e "${YELLOW}⚠️  tsconfig.json already exists${NC}"
else
    cat > "$APP_DIR/tsconfig.json" << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"]
}
EOF
    echo -e "${GREEN}✅ Created tsconfig.json${NC}"
fi

# ============================================
# STEP 7: Create index.html
# ============================================
if [ -f "$APP_DIR/index.html" ]; then
    echo -e "${YELLOW}⚠️  index.html already exists${NC}"
else
    cat > "$APP_DIR/index.html" << EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>$APP_NAME</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF
    echo -e "${GREEN}✅ Created index.html${NC}"
fi

# ============================================
# STEP 8: Create React app structure
# ============================================
if [ -d "$APP_DIR/src" ]; then
    echo -e "${YELLOW}⚠️  src/ directory already exists${NC}"
else
    mkdir -p "$APP_DIR/src"
    
    # Create main.tsx
    cat > "$APP_DIR/src/main.tsx" << EOF
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF
    
    # Create App.tsx
    cat > "$APP_DIR/src/App.tsx" << EOF
import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="app">
      <h1>🎯 $APP_NAME</h1>
      <p>Running in Dockerator with Vite + React + TypeScript!</p>
      <p>Access via: <a href="http://$SAFE_NAME.localhost">$SAFE_NAME.localhost</a></p>
      
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
      </div>
    </div>
  )
}

export default App
EOF
    
    # Create App.css
    cat > "$APP_DIR/src/App.css" << EOF
.app {
  max-width: 1280px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}

.card {
  padding: 2em;
}

button {
  border-radius: 8px;
  border: 1px solid transparent;
  padding: 0.6em 1.2em;
  font-size: 1em;
  font-weight: 500;
  font-family: inherit;
  background-color: #1a1a1a;
  cursor: pointer;
  transition: border-color 0.25s;
}

button:hover {
  border-color: #646cff;
}
EOF
    
    # Create index.css
    cat > "$APP_DIR/src/index.css" << EOF
:root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;

  color: rgba(255, 255, 255, 0.87);
  background-color: #242424;

  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

a {
  font-weight: 500;
  color: #646cff;
  text-decoration: inherit;
}

a:hover {
  color: #535bf2;
}

body {
  margin: 0;
  display: flex;
  place-items: center;
  min-width: 320px;
  min-height: 100vh;
}

h1 {
  font-size: 3.2em;
  line-height: 1.1;
}

#root {
  width: 100%;
}
EOF
    
    # Create vite-env.d.ts
    cat > "$APP_DIR/src/vite-env.d.ts" << EOF
/// <reference types="vite/client" />
EOF
    
    echo -e "${GREEN}✅ Created React app structure${NC}"
fi

# ============================================
# STEP 9: Add to docker-compose.yml
# ============================================
if [ "$IN_COMPOSE" = false ]; then
    ./scripts/add-to-compose-vite.sh "$APP_NAME"
fi

# ============================================
# STEP 10: Check /etc/hosts
# ============================================
echo ""
echo -e "${BLUE}📋 Final steps:${NC}"

if grep -q "$SAFE_NAME.localhost" /etc/hosts 2>/dev/null; then
    echo -e "${GREEN}✅ $SAFE_NAME.localhost already in /etc/hosts${NC}"
else
    echo -e "${YELLOW}⚠️  Domain not in /etc/hosts yet${NC}"
    echo "   Run: dockerator hosts"
fi

echo ""
echo -e "${GREEN}🎉 Project '$APP_NAME' ready!${NC}"
echo ""
echo "Next steps:"
echo "  1. Sync hosts: dockerator hosts"
echo "  2. Start container: dockerator start $SAFE_NAME"
echo "  3. Access app: http://$SAFE_NAME.localhost"
echo "  4. View logs: dockerator logs $SAFE_NAME"