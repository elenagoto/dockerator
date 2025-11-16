# Dockerator 🐳

> A beginner-friendly Docker orchestration CLI tool for managing multiple Next.js and WordPress projects with zero configuration.

Inspired by the amazing [devner](https://github.com/MarJC5/devner) but designed to teach Docker fundamentals while providing a production-like development environment.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🎯 What is Dockerator?

Dockerator lets you run multiple web projects (Next.js, WordPress) simultaneously on your local machine using Docker. Each project runs in its own isolated container with automatic routing, shared databases, and hot reload.

**Perfect for:**

- 🎓 Learning Docker and container orchestration
- 💼 Managing multiple client projects
- 🚀 Local development with production-like architecture
- 👥 Team environments (same setup for everyone)

---

## ✨ Features

- 🚀 **Dynamic Service Discovery** - Traefik automatically routes to containers via labels
- 🎯 **Simple CLI** - One command to create projects: `dockerator new nextjs|wp <name>`
- 🗄️ **Shared Services** - MySQL, Adminer, Mailpit shared across all projects
- 🔄 **Hot Reload** - Code changes reflect immediately (Vite for WordPress, Next.js Fast Refresh)
- 🌐 **Clean URLs** - Each project gets `project-name.localhost`
- 🔐 **Auto /etc/hosts** - One command syncs all domains
- 🎨 **WordPress Toolkit Ready** - Built-in Vite support for modern WP themes
- 📧 **Email Testing** - Mailpit catches all emails from all projects

---

## 📋 Prerequisites

Before you begin, ensure you have:

- **macOS** or **Linux** (tested on macOS, should work on Linux)
- **Docker Desktop** installed and running ([Download](https://www.docker.com/products/docker-desktop))
- **Basic terminal knowledge** (how to run commands, edit files)
- **Git** (for cloning the repo)

**Check if Docker is running:**

```bash
docker --version
# Should show: Docker version 20.x.x or higher
```

---

## 🚀 Quick Start

### 1. Clone & Setup

```bash
# Clone the repository
git clone https://github.com/elenagoto/dockerator.git
cd dockerator

# Copy the example compose file (this is your starting point)
cp docker-compose.yml.example docker-compose.yml

# Make the main script executable
chmod +x dockerator

# Create a global command (makes 'dockerator' available anywhere)
sudo ln -s $(pwd)/dockerator /usr/local/bin/dockerator

# Verify installation
dockerator help
```

### 2. Start Core Services

```bash
# Start MySQL, Adminer, Mailpit, and Traefik
dockerator up

# Wait ~30 seconds for MySQL to be ready
# You'll see: ✓ Container dockerator_mysql  Started
```

### 3. Sync /etc/hosts

```bash
# This adds all *.localhost domains to your hosts file
dockerator hosts

# You'll be prompted for your password (needed to edit /etc/hosts)
```

### 4. Access Services

Open these in your browser to verify everything works:

- 🎛️ **Traefik Dashboard**: http://localhost:8080
- 🗄️ **Adminer** (Database UI): http://dockerator-adminer.localhost
  - Server: `mysql`
  - Username: `root`
  - Password: `dockerator`
- 📧 **Mailpit** (Email Inbox): http://dockerator-mailpit.localhost

---

## 📖 Usage Guide

### Creating Projects

#### Next.js Project

```bash
# Create a new Next.js project
dockerator new nextjs my-portfolio

# Sync hosts file (adds my-portfolio.localhost)
dockerator hosts

# Start the project
dockerator up

# Visit: http://my-portfolio.localhost
```

**What gets created:**

- `apps/my-portfolio/` - Your Next.js application
- Dockerfile configured for hot reload
- Automatic routing via Traefik
- Node modules isolated in container

#### WordPress Project

```bash
# Create a new WordPress site
dockerator new wp my-blog

# Sync hosts file
dockerator hosts

# Start the project
dockerator up

# Visit: http://my-blog.localhost
# Complete WordPress installation in browser
```

**What gets created:**

- `apps/my-blog/` - WordPress installation
- `wp-content/themes/my-blog/` - Your custom theme folder
- MySQL database `my_blog` with user `my_blog`
- wp-config.php configured for Dockerator
- Mailpit SMTP integration (catches all emails)

**Database credentials (auto-configured):**

- Database: `my_blog`
- User: `my_blog`
- Password: `my_blog`
- Host: `mysql`

---

### WordPress Development with Vite

If you're using a WordPress theme with Vite (like the WordPress Toolkit):

```bash
# Enter development mode for your WordPress project
dockerator dev-wp my-blog

# This will:
# 1. Expose port 5173 (Vite HMR)
# 2. Drop you into the theme directory
# 3. Let you run npm commands

# Inside the container:
npm install
npm run dev    # Start Vite dev server
# Or
npm run build  # Build for production

# When done, type: exit
# Port 5173 automatically cleaned up
```

**Your theme location:** `apps/my-blog/wp-content/themes/my-blog/`

---

### Managing Projects

```bash
# List all running containers
docker-compose ps

# Start all projects
dockerator up

# Start in background (detached)
dockerator up -d

# Stop all projects
dockerator down

# View logs for all projects
dockerator logs

# View logs for specific project
dockerator logs my-blog

# Follow logs in real-time
dockerator logs -f my-blog

# Remove a project completely
dockerator remove my-blog
# This will:
# - Stop the container
# - Delete the app folder
# - Remove from docker-compose.yml
# - Drop the MySQL database
# - Remind you to update /etc/hosts

# Rebuild a project (after Dockerfile changes)
docker-compose up --build my-blog
```

---

## 🗂️ Project Structure

```
dockerator/
├── dockerator                      # Main CLI script
├── docker-compose.yml              # Active config (git-ignored, auto-generated)
├── docker-compose.yml.example      # Template (tracked in git)
├── README.md                       # This file
├── .gitignore                      # Ignore dynamic files
│
├── scripts/                        # Helper scripts
│   ├── templates/                  # Project templates
│   │   ├── nextjs/
│   │   │   ├── Dockerfile
│   │   │   └── .dockerignore
│   │   └── wordpress/
│   │       ├── Dockerfile
│   │       ├── Caddyfile
│   │       └── wp-config.php.template
│   ├── new-nextjs.sh              # Next.js project creator
│   ├── new-wordpress.sh           # WordPress project creator
│   ├── add-to-compose.sh          # Add Next.js service
│   ├── add-to-compose-wp.sh       # Add WordPress service
│   ├── remove-from-compose.sh     # Remove service from compose
│   ├── remove-project.sh          # Complete project removal
│   ├── dev-mode.sh                # WordPress dev mode with Vite
│   └── sync-hosts.sh              # /etc/hosts synchronization
│
└── apps/                           # Your projects (git-ignored)
    ├── .gitkeep                    # Keeps folder in git
    ├── my-portfolio/               # Next.js project
    └── my-blog/                    # WordPress project
        └── wp-content/
            └── themes/
                └── my-blog/        # Your theme
```

---

## 🏗️ Architecture

### How It Works

```
┌─────────────────────────────────────────┐
│           YOUR BROWSER                   │
└──────────────┬──────────────────────────┘
               │ HTTP Request
               ▼
┌─────────────────────────────────────────┐
│   TRAEFIK (Port 80)                      │
│   Reverse Proxy - Routes by domain      │
└──┬────────┬────────┬─────────┬─────────┘
   │        │        │         │
   ▼        ▼        ▼         ▼
┌──────┐ ┌──────┐ ┌──────┐  ┌────────┐
│Next.js│ │Next.js│ │WordPress│ │WordPress│
│ App 1 │ │ App 2 │ │ Site 1  │ │ Site 2  │
└───┬───┘ └───┬───┘ └────┬───┘ └────┬───┘
    │         │          │          │
    └─────────┴──────────┴──────────┘
                   │
         ┌─────────▼─────────┐
         │  Shared Services   │
         ├───────────────────┤
         │ • MySQL           │
         │ • Adminer         │
         │ • Mailpit         │
         └───────────────────┘
```

### Key Concepts

#### Container-per-Project

Each project runs in its own isolated Docker container:

- ✅ No dependency conflicts between projects
- ✅ Can use different Node/PHP versions per project
- ✅ True isolation (one project crash doesn't affect others)
- ✅ Production-like architecture

#### Shared Services

Common services are shared across all projects:

- **MySQL** - One database server, multiple databases (one per WP site)
- **Adminer** - Web UI to manage all databases
- **Mailpit** - Catches ALL emails from ALL projects in one inbox
- **Traefik** - Smart reverse proxy with automatic service discovery

#### Traefik Auto-Discovery

No manual configuration! Services declare their routes via Docker labels:

```yaml
labels:
  - 'traefik.enable=true'
  - 'traefik.http.routers.my-app.rule=Host(`my-app.localhost`)'
  - 'traefik.http.services.my-app.loadbalancer.server.port=3000'
```

When you create a new project, Dockerator automatically:

1. Adds these labels to docker-compose.yml
2. Traefik discovers the new service
3. Routes traffic to the correct container
4. No Nginx/Apache config files to edit!

---

## 🎓 Learning Resources

### What You'll Learn Using Dockerator

- **Docker Compose orchestration** - How multiple containers work together
- **Container networking** - How containers communicate
- **Reverse proxy patterns** - How Traefik routes traffic
- **Volume mounting strategies** - Hot reload and data persistence
- **Shell scripting** - Automation and developer tools
- **Production-like architecture** - Microservices patterns

### Recommended Reading

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Understanding Docker Networks](https://docs.docker.com/network/)
- [WordPress in Docker Best Practices](https://developer.wordpress.org/advanced-administration/upgrade/migrating/)

---

## 🔧 Troubleshooting

### Port 80 Already in Use

**Problem:** Another service (like devner) is using port 80.

**Solution:**

```bash
# Check what's using port 80
lsof -i :80

# If it's devner:
cd ~/devner && docker-compose down

# If it's Apache/Nginx:
sudo apachectl stop
# or
sudo nginx -s stop
```

### Docker Not Running

**Problem:** Error: "Cannot connect to Docker daemon"

**Solution:**

1. Open Docker Desktop
2. Wait for it to fully start (whale icon steady in menu bar)
3. Try again

### Permission Denied Removing Files

**Problem:** `rm: cannot remove 'node_modules': Permission denied`

**Solution:**

```bash
# Use Docker to remove files (they're owned by container)
docker run --rm -v "$(pwd)":/data alpine rm -rf /data/apps/project-name

# Or use sudo (not recommended)
sudo rm -rf apps/project-name
```

### Project Not Accessible in Browser

**Problem:** Can't access `my-project.localhost`

**Checklist:**

1. ✅ Is the container running? `docker-compose ps`
2. ✅ Is it in /etc/hosts? `cat /etc/hosts | grep my-project`
3. ✅ Run: `dockerator hosts` to sync
4. ✅ Check Traefik dashboard: http://localhost:8080
5. ✅ Try direct port (Next.js): http://localhost:3001

### MySQL Connection Refused

**Problem:** WordPress can't connect to database

**Solution:**

```bash
# Check if MySQL is healthy
docker-compose ps

# Should show: healthy
# If not, wait 30 seconds and check again

# Check logs
dockerator logs mysql

# Restart MySQL
docker-compose restart mysql
```

### Vite Not Working in WordPress

**Problem:** Theme changes not hot-reloading

**Solution:**

```bash
# Make sure you're in dev mode
dockerator dev-wp my-blog

# Check Vite is running
npm run dev

# Verify port 5173 is exposed
docker-compose ps | grep 5173

# Check your theme's vite.config.js has:
# server: { host: '0.0.0.0', port: 5173 }
```

### Changes Not Reflecting

**Problem:** Code changes don't appear in browser

**Solution:**

```bash
# For Next.js - check volume mounts
docker-compose exec my-app ls /app
# Should see your files

# For WordPress - check theme location
docker-compose exec my-blog ls /app/wp-content/themes
# Should see your theme folder

# If files missing, rebuild
dockerator down
dockerator up --build
```

### "Host Already Exists" When Creating Project

**Problem:** Project name conflicts with existing project

**Solution:**

```bash
# List existing projects
docker-compose ps

# Remove old project first
dockerator remove old-project-name

# Or choose a different name
dockerator new wp my-blog-v2
```

---

## 🚨 Common Mistakes (Avoid These!)

### 1. ❌ Forgetting to Run `dockerator hosts`

After creating a new project, you must sync /etc/hosts:

```bash
dockerator new nextjs my-app
dockerator hosts  # ← Don't forget this!
```

### 2. ❌ Editing docker-compose.yml Directly

The file is auto-generated! Edit `docker-compose.yml.example` instead and copy:

```bash
# Wrong:
nano docker-compose.yml  # ❌ Changes will be lost

# Right:
nano docker-compose.yml.example  # ✅ Edit the template
cp docker-compose.yml.example docker-compose.yml
```

### 3. ❌ Not Stopping Devner First

Running both Dockerator and devner causes port conflicts:

```bash
# Always stop devner first
cd ~/devner && docker-compose down
cd ~/dockerator && dockerator up
```

### 4. ❌ Expecting Instant WordPress Builds

First WordPress project takes 2-3 minutes (installs PHP extensions):

```bash
# First WP project: ~3 minutes ⏰
dockerator new wp site-1

# Second WP project: ~1 minute ⚡ (uses cache)
dockerator new wp site-2

# Reopening site-1: instant! ✨
dockerator up
```

---

## 📚 FAQ

### Can I use this in production?

**No.** Dockerator is designed for **local development only**. For production:

- Use proper secrets management
- Implement SSL/TLS
- Use production-grade databases
- Set up proper backups
- Use environment-specific configs

### Can I run multiple projects at once?

**Yes!** That's the whole point. Run as many as your computer can handle:

```bash
dockerator new nextjs project-1
dockerator new nextjs project-2
dockerator new wp blog
dockerator up  # All running simultaneously!
```

### How much disk space do I need?

- **Base installation**: ~2GB (Docker images)
- **Per Next.js project**: ~500MB (node_modules)
- **Per WordPress project**: ~1GB (WordPress + themes)
- **MySQL data**: Grows with content

**Recommendation:** 10GB+ free disk space

### Can I customize the templates?

**Yes!** Edit files in `scripts/templates/`:

- `scripts/templates/nextjs/Dockerfile` - Next.js setup
- `scripts/templates/wordpress/Dockerfile` - WordPress setup
- `scripts/templates/wordpress/wp-config.php.template` - WP config

Changes apply to all NEW projects created after editing.

### Can I use a different database per WP site?

**All WordPress sites share one MySQL server but each gets its own database:**

- Site 1: Database `site_1`
- Site 2: Database `site_2`

This is efficient and industry-standard.

### What if I want PostgreSQL instead of MySQL?

Edit `docker-compose.yml.example` and add a PostgreSQL service. You'll also need to update the WordPress template to use PostgreSQL (requires a plugin).

### Can I use this with existing projects?

**Yes!** Copy your existing project into `apps/project-name/`, create the Dockerfile and Caddyfile (for WP) or Dockerfile (for Next.js), then manually add to docker-compose.yml or use the add scripts.

---

## 🤝 Contributing

Contributions are welcome! This is a learning project, so beginner-friendly improvements are especially appreciated.

### How to Contribute

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly
5. Commit: `git commit -m 'Add amazing feature'`
6. Push: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Ideas for Contributions

- [ ] Add Laravel support
- [ ] Add React (Vite) support
- [ ] Add `dockerator list` command (show all projects)
- [ ] Add `dockerator restart <project>` command
- [ ] Improve error messages
- [ ] Add more WordPress themes templates
- [ ] Add production build configurations
- [ ] Windows support (WSL2)
- [ ] Add PHPMyAdmin as alternative to Adminer

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **[devner](https://github.com/MarJC5/devner)** by [MarJC5](https://github.com/MarJC5) - The inspiration for this project
- **[Traefik](https://traefik.io/)** - Amazing reverse proxy
- **[FrankenPHP](https://frankenphp.dev/)** - Modern PHP application server
- **Everyone who helped test and improve this tool**

---

## 💬 Support

- 🐛 **Bug reports**: [Open an issue](https://github.com/elenagoto/dockerator/issues)
- 💡 **Feature requests**: [Open an issue](https://github.com/elenagoto/dockerator/issues)
- 📖 **Documentation improvements**: [Open a PR](https://github.com/elenagoto/dockerator/pulls)

---

## 🎯 Roadmap

- [x] Next.js support
- [x] WordPress support with FrankenPHP
- [x] Automatic /etc/hosts management
- [x] WordPress dev mode with Vite
- [ ] Laravel support
- [ ] Static site generator support (Hugo, Jekyll)
- [ ] GUI dashboard (web-based)
- [ ] Docker compose generation from UI
- [ ] Backup/restore functionality
- [ ] Import/export project configs

---

**Made with ❤️ for developers learning Docker**

If this project helped you, give it a ⭐️!
