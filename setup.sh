#!/usr/bin/env bash
set -euo pipefail

# =========================
# Helpers
# =========================
GREEN="\033[0;32m"; YELLOW="\033[0;33m"; RED="\033[0;31m"; NC="\033[0m"

log()  { echo -e "${GREEN}✅ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $*${NC}"; }
err()  { echo -e "${RED}❌ $*${NC}"; }

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    err "Este script é para macOS."
    exit 1
  fi
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

append_if_missing() {
  local line="$1"
  local file="$2"
  touch "$file"
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

# =========================
# Load dotenv (config.env)
# =========================
# Formato suportado:
# KEY=value
# KEY="value with spaces"
# Linhas comentadas com # são ignoradas
load_dotenv() {
  local dotenv_path="${1:-./config.env}"
  if [[ -f "$dotenv_path" ]]; then
    log "Carregando config: $dotenv_path"
    set -a
    # shellcheck disable=SC1090
    source "$dotenv_path"
    set +a
  else
    warn "config.env não encontrado (opcional). Você pode criar via: cp config.env.example config.env"
  fi
}

# =========================
# Start
# =========================
require_macos
load_dotenv "./config.env"

# =========================
# Config via env vars (defaults)
# =========================
PY_VERSION="${PY_VERSION:-3.12.2}"
JAVA_21="${JAVA_21:-21.0.2-tem}"
JAVA_17="${JAVA_17:-17.0.10-tem}"
BREWFILE="${BREWFILE:-./Brewfile}"

ZPROFILE="$HOME/.zprofile"
ZSHRC="$HOME/.zshrc"

log "mac-setup: iniciando..."

# 1) Xcode CLT
if ! xcode-select -p >/dev/null 2>&1; then
  log "Instalando Xcode Command Line Tools..."
  xcode-select --install || true
  warn "Conclua o popup de instalação e rode novamente: make install"
  exit 0
else
  log "Xcode Command Line Tools OK"
fi

# 2) Homebrew
if ! has_cmd brew; then
  log "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon path
  if [[ -x /opt/homebrew/bin/brew ]]; then
    append_if_missing 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$ZPROFILE"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  log "Homebrew OK"
fi

log "Atualizando Homebrew..."
brew update

# 3) Brewfile bundle
if [[ -f "$BREWFILE" ]]; then
  log "Instalando pacotes via Brewfile..."
  brew bundle --file "$BREWFILE"
else
  warn "Brewfile não encontrado em: $BREWFILE"
fi

# 4) Git config (via dotenv)
if [[ -n "${GIT_NAME:-}" && -n "${GIT_EMAIL:-}" ]]; then
  log "Configurando Git..."
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
else
  warn "Git não configurado. Defina GIT_NAME e GIT_EMAIL em config.env"
fi

# 5) Zsh integrations (NVM + pyenv)
touch "$ZSHRC"

# -------------------------
# NVM (Node)
# -------------------------
if brew list nvm >/dev/null 2>&1; then
  log "Configurando NVM no .zshrc..."
  mkdir -p "$HOME/.nvm"
  append_if_missing 'export NVM_DIR="$HOME/.nvm"' "$ZSHRC"
  append_if_missing 'source "$(brew --prefix nvm)/nvm.sh"' "$ZSHRC"

  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1090
  source "$(brew --prefix nvm)/nvm.sh"

  log "Instalando Node 20 e 18..."
  nvm install 20
  nvm install 18
  nvm alias default 20
  nvm use 20
else
  warn "NVM não instalado (verifique o Brewfile)."
fi

# -------------------------
# pyenv (Python) - FIXED for macOS Apple Silicon
# -------------------------
# IMPORTANTE: Brewfile deve conter:
# openssl@3, readline, zlib, xz, pyenv
if brew list pyenv >/dev/null 2>&1; then
  log "Configurando pyenv no .zshrc..."
  append_if_missing 'eval "$(pyenv init --path)"' "$ZSHRC"
  append_if_missing 'eval "$(pyenv init -)"' "$ZSHRC"

  # carrega pyenv na sessão atual
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"

  # flags de build (evitam BUILD FAILED no pyenv install)
  if brew list openssl@3 >/dev/null 2>&1; then
    export LDFLAGS="-L$(brew --prefix openssl@3)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix zlib)/lib"
    export CPPFLAGS="-I$(brew --prefix openssl@3)/include -I$(brew --prefix readline)/include -I$(brew --prefix zlib)/include"
    export PKG_CONFIG_PATH="$(brew --prefix openssl@3)/lib/pkgconfig"
  else
    warn "openssl@3 não encontrado. Garanta que está no Brewfile."
  fi

  log "Instalando Python ${PY_VERSION} via pyenv..."
  pyenv install -s "$PY_VERSION"
  pyenv global "$PY_VERSION"
else
  warn "pyenv não instalado (verifique o Brewfile)."
fi

# 6) SDKMAN + Java
if [[ ! -d "$HOME/.sdkman" ]]; then
  log "Instalando SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
fi

# shellcheck disable=SC1090
source "$HOME/.sdkman/bin/sdkman-init.sh"

log "Instalando Java via SDKMAN (17 e 21)..."
sdk install java "$JAVA_21" || true
sdk install java "$JAVA_17" || true
sdk default java "$JAVA_21" || true

# 7) Opcional: iniciar serviços
if brew list postgresql@16 >/dev/null 2>&1; then
  log "Iniciando PostgreSQL 16 (brew services)..."
  brew services start postgresql@16 >/dev/null 2>&1 || true
fi

if brew list redis >/dev/null 2>&1; then
  log "Iniciando Redis (brew services)..."
  brew services start redis >/dev/null 2>&1 || true
fi

log "Setup concluído!"
warn "Abra um novo terminal para recarregar .zshrc/.zprofile."
log "Depois rode: make doctor"
