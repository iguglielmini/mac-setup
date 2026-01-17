#!/usr/bin/env bash
set -euo pipefail

log() { echo "✅ $1"; }
warn() { echo "⚠️  $1"; }
die() { echo "❌ $1"; exit 1; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "Este script é para macOS."
fi

log "Iniciando setup para macOS (Apple Silicon / Intel)..."

# 1) Xcode CLT
if ! xcode-select -p >/dev/null 2>&1; then
  log "Instalando Xcode Command Line Tools..."
  xcode-select --install || true
  warn "Se abriu uma janela do macOS, conclua a instalação e rode o script novamente."
  exit 0
else
  log "Xcode Command Line Tools OK"
fi

# 2) Homebrew
if ! command -v brew >/dev/null 2>&1; then
  log "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Ajuste path (Apple Silicon)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  log "Homebrew OK"
fi

log "Atualizando brew..."
brew update

# 3) Instala apps/pacotes via Brewfile (se existir)
if [[ -f "./Brewfile" ]]; then
  log "Instalando pacotes via Brewfile..."
  brew bundle --file ./Brewfile
else
  warn "Brewfile não encontrado. Pulando brew bundle."
fi

# 4) Git config (opcional)
if [[ -n "${GIT_NAME:-}" && -n "${GIT_EMAIL:-}" ]]; then
  log "Configurando Git (user.name / user.email)..."
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
else
  warn "GIT_NAME e GIT_EMAIL não informados. Pulando git config."
  warn "Dica: rode assim: GIT_NAME='Seu Nome' GIT_EMAIL='seu@email.com' ./setup.sh"
fi

# 5) Zshrc helpers
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

ensure_line() {
  local line="$1"
  grep -qxF "$line" "$ZSHRC" || echo "$line" >> "$ZSHRC"
}

# 6) NVM
if brew list nvm >/dev/null 2>&1; then
  log "Configurando NVM no .zshrc..."
  mkdir -p "$HOME/.nvm"
  ensure_line 'export NVM_DIR="$HOME/.nvm"'
  ensure_line 'source "$(brew --prefix nvm)/nvm.sh"'
  # carrega nvm na sessão atual
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1090
  source "$(brew --prefix nvm)/nvm.sh"

  log "Instalando Node LTS (20) e Node 18..."
  nvm install 20
  nvm install 18
  nvm use 20
else
  warn "NVM não instalado (verifique Brewfile)."
fi

# 7) pyenv
if brew list pyenv >/dev/null 2>&1; then
  log "Configurando pyenv no .zshrc..."
  ensure_line 'eval "$(pyenv init --path)"'
  ensure_line 'eval "$(pyenv init -)"'

  # carrega pyenv na sessão atual
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"

  PY_VERSION="${PY_VERSION:-3.12.2}"
  log "Instalando Python via pyenv: ${PY_VERSION}"
  pyenv install -s "$PY_VERSION"
  pyenv global "$PY_VERSION"
else
  warn "pyenv não instalado (verifique Brewfile)."
fi

# 8) SDKMAN (Java)
if [[ ! -d "$HOME/.sdkman" ]]; then
  log "Instalando SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
fi

# carrega sdkman na sessão atual
# shellcheck disable=SC1090
source "$HOME/.sdkman/bin/sdkman-init.sh"

JAVA_21="${JAVA_21:-21.0.2-tem}"
JAVA_17="${JAVA_17:-17.0.10-tem}"

log "Instalando Java 21 e 17 via SDKMAN..."
sdk install java "$JAVA_21" || true
sdk install java "$JAVA_17" || true
sdk default java "$JAVA_21" || true

# 9) Final
log "Setup concluído!"
log "Abra um novo terminal para garantir que .zshrc/.zprofile foram recarregados."
log "Sugestão: instale Docker Desktop e faça login no GitHub/GitLab com SSH."
log "Boa codificação! 🚀"