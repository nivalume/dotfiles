#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(cd "$(dirname "$0")" && pwd)

if ! command -v chezmoi >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT
    curl -fsSL --retry 3 https://get.chezmoi.io -o "$temp_dir/install-chezmoi.sh"
    sh "$temp_dir/install-chezmoi.sh" -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
    rm -rf "$temp_dir"
    trap - EXIT
fi
exec chezmoi --source "$repo_dir" init --apply
