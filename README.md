# Dockerator 🐳

> A beginner-friendly Docker orchestration CLI tool for managing multiple Next.js and WordPress projects with zero configuration.

Inspired by [devner](https://github.com/MarJC5/devner).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🚀 **One-command project creation** - `dockerator new nextjs|wp <name>`
- 🗄️ **Shared services** - MySQL, Adminer, Mailpit across all projects
- 🔄 **Hot reload** - Changes reflect immediately
- 🌐 **Clean URLs** - `project-name.localhost` for each project
- 🔐 **Auto /etc/hosts sync** - No manual editing needed

## Prerequisites

- **Docker Desktop** installed and running
- **macOS** or **Linux**
- Basic terminal knowledge

```bash
# Verify Docker is running
docker --version
```

## Quick Start

```bash
# 1. Clone and setup
git clone https://github.com/elenagoto/dockerator.git
cd dockerator
bash install.sh
cp docker-compose.yml.example docker-compose.yml

# 2. Make globally available
sudo ln -s $(pwd)/dockerator /usr/local/bin/dockerator

# 3. Start services
dockerator up

# 4. Sync hosts file
dockerator hosts
```

## Access Services

- **Traefik Dashboard**: http://localhost:8080
- **Adminer** (Database): http://dockerator-adminer.localhost
  - Server: `mysql` | User: `root` | Pass: `dockerator`
- **Mailpit** (Email Testing): http://dockerator-mailpit.localhost

## Usage

### Create Projects

```bash
# Next.js project
dockerator new nextjs my-app
dockerator hosts
dockerator up

# WordPress project
dockerator new wp my-site
dockerator hosts
dockerator up
```

### WordPress Development with Vite

```bash
# Enter dev mode (exposes port 5173 for Vite HMR)
dockerator dev-wp my-site

# Inside container:
npm install
npm run dev
# When done: exit
```

Your theme: `apps/my-site/wp-content/themes/my-site/`

### Manage Projects

```bash
dockerator up              # Start all
dockerator down            # Stop all
dockerator logs <name>     # View logs
dockerator remove <name>   # Remove project
dockerator hosts           # Sync /etc/hosts
```

## Project Structure

```
dockerator/
├── dockerator                   # Main CLI
├── docker-compose.yml          # Active config (git-ignored)
├── docker-compose.yml.example  # Template
├── scripts/
│   ├── templates/              # Project templates
│   ├── new-nextjs.sh
│   ├── new-wordpress.sh
│   └── sync-hosts.sh
└── apps/                       # Your projects (git-ignored)
```

## WordPress Database Info

Each WordPress site gets:

- Database: `project_name` (underscores)
- User: `project_name`
- Password: `project_name`
- Host: `mysql`

Access all databases via Adminer: http://dockerator-adminer.localhost

## Troubleshooting

### Port 80 in use

```bash
# Check what's using it
lsof -i :80

# Stop other Docker projects
docker-compose down
```

### Can't access project.localhost

```bash
# 1. Is container running?
docker-compose ps

# 2. Is it in /etc/hosts?
dockerator hosts

# 3. Check Traefik dashboard
open http://localhost:8080
```

### WordPress can't connect to database

```bash
# Wait for MySQL to be healthy (~30 seconds)
docker-compose ps

# Check MySQL logs
dockerator logs mysql
```

### Permission denied removing files

```bash
# Docker creates files as root, use Docker to remove
docker run --rm -v "$(pwd)":/data alpine rm -rf /data/apps/project-name
```

### First WordPress build is slow

First WP project: ~2-3 minutes (installs PHP extensions)  
Second WP project: ~1 minute (uses cache)  
Reopening existing: instant

## Common Mistakes

- ❌ Forgetting `dockerator hosts` after creating projects
- ❌ Editing `docker-compose.yml` directly (edit `.example` instead)
- ❌ Not waiting for MySQL to be ready before accessing WordPress

## Contributing

Contributions welcome! Fork, create a feature branch, and open a PR.

Ideas:

- Laravel support
- `dockerator list` command
- GUI dashboard
- Backup/restore functionality

## License

MIT - see LICENSE file

## Support

- Bug reports: [Open an issue](https://github.com/elenagoto/dockerator/issues)
- Feature requests: [Open an issue](https://github.com/elenagoto/dockerator/issues)

---

**Made with ❤️ for developers learning Docker**
