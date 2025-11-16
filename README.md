# Dockerator 🐳

A Docker orchestration CLI tool for managing multiple Next.js and WordPress projects with dynamic service discovery.

## Features

- 🚀 **Dynamic Service Discovery** - Traefik automatically routes to containers via labels
- 🎯 **Simple CLI** - `dockerator new nextjs|wp <name>` to create projects
- 🗄️ **Shared Services** - MySQL, Adminer, Mailpit shared across all projects
- 🔄 **Hot Reload** - Code changes reflect immediately
- 🌐 **Clean URLs** - `project-name.localhost` for each project

## Quick Start

### 1. Clone & Setup

```bash
git clone <your-repo-url> dockerator
cd dockerator

# Copy example compose file
cp docker-compose.yml.example docker-compose.yml

# Create symlink (make command available globally)
sudo ln -s $(pwd)/dockerator /usr/local/bin/dockerator
```

### 2. Add to /etc/hosts

```bash
sudo nano /etc/hosts

# Add these lines:
127.0.0.1 dockerator-adminer.localhost
127.0.0.1 dockerator-mailpit.localhost
```

### 3. Start Services

```bash
dockerator up
```

### 4. Access Services

- **Traefik Dashboard**: http://localhost:8080
- **Adminer** (DB): http://dockerator-adminer.localhost (user: root, pass: dockerator)
- **Mailpit** (Email): http://dockerator-mailpit.localhost

## Usage

### Create Projects

```bash
# Create Next.js app
dockerator new nextjs my-app

# Create WordPress site (coming soon)
dockerator new wp my-site
```

### Manage Projects

```bash
# Start all containers
dockerator up

# Stop all containers
dockerator down

# View logs
dockerator logs <project-name>

# Remove project
dockerator remove <project-name>
```

### Database Access

**Root Access (for all databases):**

- Server: `mysql`
- Username: `root`
- Password: `dockerator`

**Project Databases:**
Each WordPress site gets:

- Database: `project_name` (underscores)
- User: `project_name`
- Password: `project_name`

Access via Adminer at http://dockerator-adminer.localhost

## Project Structure

```
dockerator/
├── dockerator              # Main CLI script
├── docker-compose.yml      # Generated (git-ignored)
├── docker-compose.yml.example  # Template
├── scripts/
│   ├── new-nextjs.sh      # Next.js project creator
│   ├── new-wordpress.sh   # WordPress project creator (WIP)
│   ├── add-to-compose.sh  # Adds service to compose
│   ├── remove-from-compose.sh
│   └── remove-project.sh
└── apps/
    ├── .gitkeep
    ├── project-1/         # Your projects (git-ignored)
    └── project-2/
```

## Architecture

### Container-per-Project

Each project runs in its own isolated container:

- ✅ No dependency conflicts
- ✅ Different Node/PHP versions possible
- ✅ True isolation

### Shared Services

Common services shared across projects:

- **MySQL** - One instance, multiple databases
- **Adminer** - Access all databases
- **Mailpit** - Catch all emails from all projects
- **Traefik** - Automatic routing

### Traefik Auto-Discovery

Services declare routing via Docker labels:

```yaml
labels:
  - 'traefik.enable=true'
  - 'traefik.http.routers.my-app.rule=Host(`my-app.localhost`)'
```

No manual proxy configuration needed!

## Development

### Adding New Project Types

Create a new script in `scripts/new-<type>.sh` following the pattern of `new-nextjs.sh`.

### Modifying Templates

Edit `docker-compose.yml.example` for the base template.

## Troubleshooting

### Port Conflicts

```bash
# Check what's using port 80
lsof -i :80

# Stop other Docker projects
cd ~/devner && docker-compose down
```

### Permission Issues

```bash
# Remove Docker-created files
docker run --rm -v "$(pwd)":/data alpine rm -rf /data/apps/project-name
```

### Reset Everything

```bash
dockerator down
rm docker-compose.yml
cp docker-compose.yml.example docker-compose.yml
dockerator up
```

## Comparison with Devner

| Feature      | Dockerator        | Devner            |
| ------------ | ----------------- | ----------------- |
| Architecture | Container per app | Single FrankenPHP |
| Isolation    | High              | Low               |
| Routing      | Traefik (labels)  | Caddy (config)    |
| Best For     | Learning Docker   | Fast WP dev       |

## Learning Resources

This project teaches:

- Docker Compose orchestration
- Container networking
- Reverse proxy patterns (Traefik)
- Volume mounting strategies
- Shell scripting automation

## License

MIT

## Author

Built as a learning project to understand Docker orchestration deeply.
