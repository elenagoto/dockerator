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

echo "🔧 Setting up autocomplete..."

# Save dockerator path for completion
echo "$(pwd)" > ~/.dockerator-path

# Detect shell
if [ -n "$ZSH_VERSION" ]; then
    # Zsh
    mkdir -p ~/.zsh/completion
    cp dockerator-completion.zsh ~/.zsh/completion/_dockerator
    echo "✅ Zsh completion installed (restart terminal to activate)"
elif [ -n "$BASH_VERSION" ]; then
    # Bash
    sudo cp dockerator-completion.bash /etc/bash_completion.d/dockerator 2>/dev/null || \
        cp dockerator-completion.bash ~/.bash_completion.d/dockerator
    echo "✅ Bash completion installed (restart terminal to activate)"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal window"
echo "  2. dockerator up"
echo "  3. dockerator hosts"
echo "  4. dockerator new nextjs <project-name>  OR  dockerator new wp <project-name>"
echo ""