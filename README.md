# mac-setup

Opinionated and automated macOS development environment setup for backend and full-stack software engineers.

This project provides a reproducible and fast way to bootstrap a macOS machine for professional software development, focusing on productivity, performance, and long-term maintainability.

It installs and configures essential tools commonly used in real-world projects, including:

- **Homebrew** - macOS package manager
- **Node.js** (via NVM) - Multiple managed versions
- **Python** (via pyenv) - Isolated Python environment
- **Java** (via SDKMAN) - Multiple JDK versions
- **Docker Desktop** - Containerization
- **PostgreSQL & Redis** - Databases
- **VS Code, iTerm2, JetBrains Toolbox** - IDEs and tools

The goal is to reduce setup time, avoid manual errors, and ensure a consistent development environment across machines.

---

## 📋 Table of Contents

- [Who is this for](#who-is-this-for)
- [Why this project exists](#why-this-project-exists)
- [Tech stack installed](#tech-stack-installed)
- [Prerequisites](#prerequisites)
- [Quick installation](#quick-installation)
- [Custom configuration](#custom-configuration)
- [Detailed scripts](#detailed-scripts)
- [Make commands](#make-commands)
- [Post-installation verification](#post-installation-verification)
- [Uninstallation](#uninstallation)
- [Troubleshooting](#troubleshooting)

---

## 👨‍💻 Who is this for

This setup is designed for software engineers who work with:

- Backend systems and REST/GraphQL APIs
- Microservices and containerized applications
- Java (Spring Boot, Quarkus)
- Python (FastAPI, Django)
- Node.js (NestJS, Express)
- Docker and CI/CD pipelines

It is especially useful for engineers who frequently switch machines, work on multiple projects, or value automation and developer experience.

---

## 🎯 Why this project exists

Setting up a development environment manually is time-consuming, error-prone, and often undocumented.

This repository codifies years of day-to-day development experience into a single, repeatable setup script, allowing developers to go from a fresh macOS install to a production-ready environment in minutes.

---

## 🛠️ Tech stack installed

### Base system
- macOS (Apple Silicon or Intel)
- Xcode Command Line Tools

### Package and version managers
- **Homebrew** - macOS package manager
- **NVM** - Node Version Manager
- **pyenv** - Python Version Manager
- **SDKMAN** - Software Development Kit Manager (Java)

### Languages and runtimes
- **Node.js** 18 and 20 (via NVM)
- **Python** 3.12+ (via pyenv)
- **Java** 17 and 21 (via SDKMAN with Temurin/Eclipse Adoptium)

### Databases
- **PostgreSQL 16** - Relational database
- **Redis** - Cache and key-value store

### Development tools
- **Docker Desktop** - Containerization
- **Visual Studio Code** - Code editor
- **JetBrains Toolbox** - JetBrains IDEs manager
- **iTerm2** - Advanced terminal
- **Postman** - API testing

### CLI utilities
- git, wget, curl, jq
- tree, gnupg
- ripgrep, fzf

---

## ⚙️ Prerequisites

- **macOS** (Monterey 12+, Ventura 13, or Sonoma 14+)
- **Stable internet connection**
- **Administrator account** (sudo access)
- **~10 GB free disk space**

---

## 🚀 Quick installation

### 1. Clone the repository

```bash
git clone https://github.com/your-username/mac-setup.git
cd mac-setup
```

### 2. (Optional) Configure your preferences

```bash
cp config.env.example config.env
# Edit config.env with your favorite editor
nano config.env
```

Example configuration:
```bash
GIT_NAME="Your Name"
GIT_EMAIL="your.email@example.com"
PY_VERSION="3.12.2"
JAVA_21="21.0.2-tem"
JAVA_17="17.0.10-tem"
```

### 3. Run the setup

```bash
make install
```

### 4. Open a new terminal

After completion, **open a new terminal** to load the shell configurations.

### 5. Verify the installation

```bash
make doctor
```

---

## ⚙️ Custom configuration

### `config.env` file

The `config.env` file allows you to customize versions and configurations without modifying the scripts:

```bash
# Git configuration
GIT_NAME="Your Name"
GIT_EMAIL="your.email@example.com"

# Language versions
PY_VERSION="3.12.2"          # Python version
JAVA_21="21.0.2-tem"         # Java 21 (Temurin)
JAVA_17="17.0.10-tem"        # Java 17 (Temurin)
```

### `Brewfile` file

The `Brewfile` defines all packages, apps, and dependencies installed via Homebrew. You can customize it by adding or removing items:

```ruby
# Add new packages
brew "htop"
brew "neovim"

# Add new apps
cask "slack"
cask "spotify"
```

---

## 📜 Detailed scripts

### `setup.sh` - Main installation script

**Purpose:** Automates the complete development environment installation.

**What it does:**

1. **Validates operating system** - Checks if running on macOS
2. **Loads configuration** - Reads `config.env` file (if it exists)
3. **Installs Xcode Command Line Tools** - Essential build tools
4. **Installs and configures Homebrew** - Package manager
5. **Installs Brewfile packages** - Apps, CLI tools, and dependencies
6. **Configures Git** - Sets global name and email (if configured)
7. **Installs and configures NVM** - Node.js version manager
   - Installs Node.js 18 and 20
   - Sets Node 20 as default
8. **Installs and configures pyenv** - Python version manager
   - Configures build flags for Apple Silicon
   - Installs Python (version specified in `config.env`)
9. **Installs SDKMAN** - Java SDKs manager
   - Installs Java 17 and 21
   - Sets Java 21 as default
10. **Starts services** - PostgreSQL and Redis (via brew services)

**How to run:**

```bash
# Via Make
make install

# Or directly
chmod +x setup.sh
./setup.sh
```

**Expected output:**
```
✅ mac-setup: starting...
✅ Xcode Command Line Tools OK
✅ Homebrew OK
✅ Installing packages via Brewfile...
✅ Configuring Git...
✅ Configuring NVM in .zshrc...
✅ Installing Node 20 and 18...
✅ Installing Python 3.12.2 via pyenv...
✅ Installing SDKMAN...
✅ Installing Java via SDKMAN (17 and 21)...
✅ Setup complete!
⚠️  Open a new terminal to reload .zshrc/.zprofile.
✅ Then run: make doctor
```

---

### `doctor.sh` - Diagnostic script

**Purpose:** Verifies that all tools were installed correctly and are accessible in PATH.

**What it checks:**

- ✅ Xcode Command Line Tools
- ✅ Homebrew
- ✅ Git, jq, Docker, VS Code
- ✅ NVM and Node.js
- ✅ pyenv and Python
- ✅ SDKMAN and Java

**How to run:**

```bash
# Via Make
make doctor

# Or directly
chmod +x doctor.sh
./doctor.sh
```

**Expected output:**
```
== mac-setup doctor ==
✅ xcode-select installed
✅ brew installed
✅ git installed
✅ jq installed
✅ docker installed
✅ code installed
✅ nvm loaded
✅ node v20.11.0
✅ pyenv 2.3.35
✅ python Python 3.12.2
✅ sdkman loaded
✅ java installed
== end ==
```

---

### `uninstall.sh` - Uninstallation script

**Purpose:** Removes configurations added to `.zshrc` and local directories created by the setup.

**⚠️ Important:** This script does **NOT** uninstall:
- Homebrew
- Apps installed via Brewfile (Docker, VS Code, etc.)
- SDKMAN (remains in `~/.sdkman`)

**What it removes:**

- NVM lines from `.zshrc`
- pyenv lines from `.zshrc`
- `~/.nvm` directory

**How to run:**

```bash
# Via Make
make uninstall

# Or directly
chmod +x uninstall.sh
./uninstall.sh
```

**Expected output:**
```
⚠️  This script only removes lines added to .zshrc and local folders (.nvm).
⚠️  It does NOT uninstall Homebrew or apps installed via Brewfile.
✅ Cleaned entries from .zshrc
✅ Removed ~/.nvm
⚠️  Open a new terminal afterwards.
```

---

### `Makefile` - Command shortcuts

**Purpose:** Provides simplified commands to execute the scripts.

**Available commands:**

| Command | Description |
|---------|-----------|
| `make install` | Runs the complete setup |
| `make doctor` | Verifies the installation |
| `make uninstall` | Removes configurations |

**Advantages:**
- Short and memorable commands
- Automatically makes scripts executable
- Familiar pattern for developers

---

### `Brewfile` - Package definition

**Purpose:** Defines all packages, apps, and dependencies installed via Homebrew Bundle.

**Structure:**

```ruby
# Taps (additional repositories)
tap "homebrew/bundle"
tap "homebrew/cask"

# CLI packages (brew)
brew "git"
brew "wget"

# GUI applications (cask)
cask "visual-studio-code"
cask "docker"
```

**How to customize:**

1. Edit the `Brewfile`
2. Add/remove packages
3. Run `brew bundle --file Brewfile` or run the setup again

---

## 🎯 Make commands

```bash
# Complete installation
make install

# Check if everything is working
make doctor

# Remove configurations
make uninstall
```

---

## ✅ Post-installation verification

After installation, verify each tool:

```bash
# Homebrew
brew --version

# Node.js (NVM)
nvm --version
node --version
npm --version

# Python (pyenv)
pyenv --version
python --version
pip --version

# Java (SDKMAN)
sdk version
java -version

# Docker
docker --version
docker compose version

# Git
git --version
git config --global --list

# Databases
psql --version
redis-cli --version

# Check running services
brew services list
```

---

## 🗑️ Uninstallation

### Partial uninstallation (configurations only)

```bash
make uninstall
```

### Complete uninstallation (manual)

To completely remove all tools:

```bash
# Remove Homebrew and all packages
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Remove SDKMAN
rm -rf ~/.sdkman

# Remove pyenv
rm -rf ~/.pyenv

# Remove NVM
rm -rf ~/.nvm

# Manually clean .zshrc and .zprofile
nano ~/.zshrc
nano ~/.zprofile
```

---

## 🔧 Troubleshooting

### Issue: Xcode Command Line Tools won't install

**Solution:**
```bash
# Install via command line
xcode-select --install

# If it persists, download manually from Apple Developer
# https://developer.apple.com/download/more/
```

### Issue: Python pyenv install fails with BUILD FAILED

**Cause:** Missing build dependencies (openssl, readline, zlib)

**Solution:**
```bash
# Check if dependencies are in Brewfile
grep -E "openssl|readline|zlib" Brewfile

# If not, install them:
brew install openssl@3 readline zlib xz

# Run setup again
make install
```

### Issue: NVM doesn't load in terminal

**Solution:**
```bash
# Check if it's in .zshrc
cat ~/.zshrc | grep NVM

# If not, add manually:
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo 'source "$(brew --prefix nvm)/nvm.sh"' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

### Issue: Java not found after installation

**Solution:**
```bash
# Check if SDKMAN is in PATH
source "$HOME/.sdkman/bin/sdkman-init.sh"

# List installed versions
sdk list java

# Set a version as default
sdk default java 21.0.2-tem

# Verify
java -version
```

### Issue: Docker won't start

**Solution:**
```bash
# Open Docker Desktop manually
open -a Docker

# Wait a few seconds
# Check if it's running
docker ps
```

### Issue: PostgreSQL or Redis won't start

**Solution:**
```bash
# Check service status
brew services list

# Start manually
brew services start postgresql@16
brew services start redis

# If it fails, check logs
tail -f /opt/homebrew/var/log/postgresql@16.log
tail -f /opt/homebrew/var/log/redis.log
```

---

## 📝 Important notes

1. **First run may take time** - Downloading JDKs, Node, Python, and apps can take 15-30 minutes
2. **Requires stable connection** - Interruptions may cause incomplete installations
3. **Apple Silicon vs Intel** - Scripts automatically detect architecture
4. **Sudo permissions** - Xcode CLT and Homebrew may request administrator password
5. **New terminal required** - Always open a new terminal after setup to load environment variables

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest improvements
- Add new packages to Brewfile
- Improve documentation

---

## 📄 License

This project is distributed under the MIT license. See the `LICENSE` file for more details.

---

## 📧 Contact

For questions, suggestions, or issues, please open an issue in the repository.

---

**Built with ❤️ for the developer community.**
