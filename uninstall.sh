#!/usr/bin/env bash
set -euo pipefail

warn() { echo "⚠️  $*"; }
ok()   { echo "✅ $*"; }

ZSHRC="$HOME/.zshrc"

warn "Este script remove apenas linhas adicionadas no .zshrc e pastas locais (.nvm)."
warn "Ele NÃO desinstala Homebrew nem apps instalados via Brewfile."

if [[ -f "$ZSHRC" ]]; then
  # remove linhas exatas
  sed -i '' '/export NVM_DIR="\$HOME\/\.nvm"/d' "$ZSHRC" || true
  sed -i '' '/source "\$(brew --prefix nvm)\/nvm\.sh"/d' "$ZSHRC" || true
  sed -i '' '/eval "\$(pyenv init --path)"/d' "$ZSHRC" || true
  sed -i '' '/eval "\$(pyenv init -)"/d' "$ZSHRC" || true
  ok "Limpou entradas no .zshrc"
else
  warn ".zshrc não encontrado"
fi

if [[ -d "$HOME/.nvm" ]]; then
  rm -rf "$HOME/.nvm"
  ok "Removeu ~/.nvm"
fi

warn "Abra um novo terminal depois."
