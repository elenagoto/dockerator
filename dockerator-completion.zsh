#compdef dockerator

_dockerator() {
    local -a commands projects
    
    commands=(
        'new:Create new project'
        'open:Open project in VS Code'
        'list:List all projects'
        'up:Start all containers'
        'down:Stop all containers'
        'logs:View project logs'
        'remove:Remove project'
        'dev-wp:WordPress dev mode'
        'dev-nextjs:Next.js dev mode'
        'hosts:Sync /etc/hosts'
        'help:Show help'
    )
    
    # Get dockerator directory
    if [ -f "$HOME/.dockerator-path" ]; then
        DOCKERATOR_DIR=$(cat "$HOME/.dockerator-path")
    else
        DOCKERATOR_DIR="$HOME/projects/dockerator"
    fi
    
    # Get projects
    if [ -f "$DOCKERATOR_DIR/docker-compose.yml" ]; then
        projects=(${(f)"$(grep -E "^  [a-z0-9-]+:" "$DOCKERATOR_DIR/docker-compose.yml" | \
                         sed 's/://g' | sed 's/^  //' | \
                         grep -v "traefik\|mysql\|adminer\|mailpit")"})
    fi
    
    case "$words[2]" in
        new)
            _arguments '2:type:(nextjs wp)'
            ;;
        open|logs|remove|dev-wp|dev-nextjs)
            _arguments "2:project:(${projects})"
            ;;
        *)
            _describe 'command' commands
            ;;
    esac
}

_dockerator