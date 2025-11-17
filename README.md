# Dockerator 🐳

> A Docker orchestration CLI tool for managing multiple Next.js and WordPress projects with automatic routing and zero configuration.

Inspired by [devner](https://github.com/MarJC5/devner).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

- 🚀 **One-command project creation** - `dockerator new nextjs|wp <name>`
- 🗄️ **Shared services** - MySQL, Adminer, Mailpit across all projects
- 🔄 **Hot reload** - Changes reflect immediately (Vite + Next.js)
- 🌐 **Clean URLs** - `project-name.localhost` for each project
- 🔐 **Auto /etc/hosts sync** - No manual editing
- 📋 **Project management** - List, open, and manage all projects
- ⚡ **Shell autocomplete** - Tab completion for commands and projects
- 🎨 **VS Code integration** - Open projects directly from CLI

---

## 📋 Prerequisites

- **Docker Desktop** installed and running ([Download](https://www.docker.com/products/docker-desktop))
- **macOS** or **Linux**
- Basic terminal knowledge

```bash
# Verify Docker is running
docker --version
```

---

## 🚀 Quick Start

```bash
# 1. Clone and install
git clone https://github.com/elenagoto/dockerator.git
cd dockerator
bash install.sh

# 2. Start services
dockerator up

# 3. Sync hosts file
dockerator hosts
```

---

## 🌐 Access Services

- 🎛️ **Traefik Dashboard**: http://localhost:8080
- 🗄️ **Adminer** (Database): http://dockerator-adminer.localhost
  - Server: `mysql` | User: `root` | Pass: `dockerator`
- 📧 **Mailpit** (Email Testing): http://dockerator-mailpit.localhost

---

## 📖 Usage

### Creating Projects

#### Next.js Project

```bash
dockerator new nextjs my-app
dockerator hosts
dockerator up
# Visit: http://my-app.localhost
```

#### WordPress Project

```bash
dockerator new wp my-site
dockerator hosts
dockerator up
# Visit: http://my-site.localhost
```

---

### 🎨 WordPress Development with Vite

```bash
# Enter dev mode (exposes port 5173 for Vite HMR)
dockerator dev-wp my-site

# Inside container:
📦 Installing new packages:
  1. pkill -f 'next dev'    - Stop dev server
  2. npm install <package>  - Install package
  3. npm run dev            - Restart dev server

🔧 Other commands:
  npm run build  - Build for production
  npm run lint   - Lint code

# When done: exit
```

**Your theme location:** `apps/my-site/wp-content/themes/my-site/`

---

### 💻 Next.js Development

```bash
# Enter dev mode
dockerator dev-nextjs my-app

# Inside container:
📦 Installing new packages:
  1. pkill -f 'next dev'    - Stop dev server
  2. npm install <package>  - Install package
  3. npm run dev            - Restart dev server

🔧 Other commands:
  npm run build  - Build for production
  npm run lint   - Lint code

# When done: exit
```

---

### 🛠️ Managing Projects

```bash
dockerator list            # List all projects with status
dockerator open <name>     # Open project in VS Code
dockerator up              # Start all containers
dockerator down            # Stop all containers
dockerator logs <name>     # View logs
dockerator remove <name>   # Remove project completely
dockerator hosts           # Sync /etc/hosts
```

---

## 📂 Project Structure

```
dockerator/
├── dockerator                      # Main CLI script
├── install.sh                      # Installation script
├── docker-compose.yml              # Active config (git-ignored)
├── docker-compose.yml.example      # Template
├── dockerator-completion.bash      # Bash autocomplete
├── dockerator-completion.zsh       # Zsh autocomplete
├── scripts/
│   ├── templates/                  # Project templates
│   │   ├── nextjs/
│   │   └── wordpress/
│   ├── new-nextjs.sh
│   ├── new-wordpress.sh
│   ├── list-projects.sh
│   ├── open-project.sh
│   ├── dev-mode.sh
│   ├── dev-mode-nextjs.sh
│   └── sync-hosts.sh
└── apps/                           # Your projects (git-ignored)
```

---

## 🗄️ WordPress Database Info

Each WordPress site automatically gets:

- **Database**: `project_name` (underscores)
- **User**: `project_name`
- **Password**: `project_name`
- **Host**: `mysql`

Access all databases via Adminer: http://dockerator-adminer.localhost

---

## 🔧 Troubleshooting

### Port 80 Already in Use

```bash
# Check what's using port 80
lsof -i :80

# Stop other Docker projects
docker-compose down
```

### Can't Access project.localhost

```bash
# 1. Is container running?
docker-compose ps

# 2. Sync hosts file
dockerator hosts

# 3. Check Traefik dashboard
open http://localhost:8080
```

### WordPress Can't Connect to Database

```bash
# Wait ~30 seconds for MySQL to be healthy
docker-compose ps

# Check MySQL logs
dockerator logs mysql
```

### Permission Denied Removing Files

```bash
# Docker creates files as root, use Docker to remove them
docker run --rm -v "$(pwd)":/data alpine rm -rf /data/apps/project-name
```

### First WordPress Build is Slow

- **First WP project**: ~2-3 minutes (installs PHP extensions + Node.js)
- **Second WP project**: ~1 minute (uses Docker cache)
- **Reopening existing**: Instant! ⚡

---

## ⚠️ Common Mistakes

### ❌ Forgetting to sync hosts

```bash
dockerator new nextjs my-app
dockerator hosts  # ← Don't forget this!
```

### ❌ Editing docker-compose.yml directly

```bash
# Wrong:
nano docker-compose.yml  # ❌ Changes will be lost

# Right:
nano docker-compose.yml.example  # ✅ Edit the template
cp docker-compose.yml.example docker-compose.yml
```

### ❌ Not waiting for MySQL

Wait ~30 seconds after `dockerator up` before accessing WordPress sites.

---

## 🤝 Contributing

Contributions welcome! Fork, create a feature branch, and open a PR.

### Ideas for Contributions

- [ ] Laravel support
- [ ] `dockerator restart <project>` command
- [ ] GUI dashboard (web-based)
- [ ] Backup/restore functionality
- [ ] Windows support (WSL2)
- [ ] PostgreSQL support

---

## 📄 License

MIT - see [LICENSE](LICENSE) file

---

## 💬 Support

- 🐛 **Bug reports**: [Open an issue](https://github.com/elenagoto/dockerator/issues)
- 💡 **Feature requests**: [Open an issue](https://github.com/elenagoto/dockerator/issues)

---

## 🙏 Acknowledgments

- **[devner](https://github.com/MarJC5/devner)** by [MarJC5](https://github.com/MarJC5) - The inspiration
- **[Traefik](https://traefik.io/)** - Dynamic reverse proxy
- **[FrankenPHP](https://frankenphp.dev/)** - Modern PHP application server

---

**Made with ❤️ for efficient local development**

If this project helped you, give it a ⭐️!
