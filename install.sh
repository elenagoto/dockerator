#!/bin/bash
# Run this after cloning: ./install.sh

echo "🔧 Setting up Dockerator..."

# Make all scripts executable
chmod +x dockerator
chmod +x scripts/*.sh

# Copy example compose file
if [ ! -f docker-compose.yml ]; then
    cp docker-compose.yml.example docker-compose.yml
    echo "✅ Created docker-compose.yml"
fi

# Create symlink
if [ ! -L /usr/local/bin/dockerator ]; then
    sudo ln -s $(pwd)/dockerator /usr/local/bin/dockerator
    echo "✅ Created global command"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. dockerator up"
echo "  2. dockerator hosts"