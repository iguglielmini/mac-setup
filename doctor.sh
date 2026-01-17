#!/usr/bin/env bash
set -euo pipefail

ok()   { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }
fail() { echo "❌ $*"; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || fail "macOS required."

check_cmd() {
  local c="$1"
  if command -v "$c" >/dev/null 2>&1; then ok "$c instalado"; else warn "$c não encontrado"; fi
}

echo "== mac-setup doctor =="

check_cmd xcode-select
check_cmd brew
check_cmd git
check_cmd jq
check_cmd docker
check_cmd code

# Node / NVM
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.nvm/nvm.sh"
  ok "nvm carregado"
  node -v >/dev/null 2>&1 && ok "node $(node -v)" || warn "node não acessível"
else
  warn "nvm não instalado/configurado"
fi

# Python / pyenv
if command -v pyenv >/dev/null 2>&1; then
  ok "pyenv $(pyenv --version)"
  python3 --version >/dev/null 2>&1 && ok "python $(python3 --version)" || warn "python3 não acessível"
else
  warn "pyenv não instalado"
fi

# Java / SDKMAN
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  ok "sdkman carregado"
  java -version >/dev/null 2>&1 && ok "java instalado" || warn "java não acessível"
else
  warn "sdkman não instalado"
fi

echo "== fim =="
