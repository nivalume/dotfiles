#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

[[ ${DOTFILES_INSTALL_GROK:-false} == true || ${DOTFILES_INSTALL_CODEX:-false} == true || ${DOTFILES_INSTALL_CLAUDE:-false} == true ]] || exit 0
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT
if [[ ${DOTFILES_INSTALL_GROK:-false} == true ]] && ! command -v grok >/dev/null 2>&1; then
    download https://x.ai/cli/install.sh "$temp_dir/grok.sh"
    SHELL=/bin/sh GROK_BIN_DIR="$HOME/.local/bin" bash "$temp_dir/grok.sh"
fi
if [[ ${DOTFILES_INSTALL_CODEX:-false} == true ]] && ! command -v codex >/dev/null 2>&1; then
    download https://chatgpt.com/codex/install.sh "$temp_dir/codex.sh"
    sh "$temp_dir/codex.sh"
fi
if [[ ${DOTFILES_INSTALL_CLAUDE:-false} == true ]] && ! command -v claude >/dev/null 2>&1; then
    download https://claude.ai/install.sh "$temp_dir/claude.sh"
    bash "$temp_dir/claude.sh"
fi
