#!/usr/bin/env bash

DOTFILES_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
export DOTFILES_ROOT
export PATH="$HOME/.local/bin:$HOME/.local/opt/node/bin:$HOME/.bun/bin:$HOME/.cargo/bin:$HOME/miniforge3/condabin:/opt/homebrew/bin:/usr/local/bin:$PATH"

log() { printf '[dotfiles] %s\n' "$*"; }
die() { printf '[dotfiles] %s\n' "$*" >&2; exit 1; }
download() { curl --fail --location --silent --show-error --retry 3 "$1" -o "$2"; }

load_versions() {
    # shellcheck source=../../config/versions.env
    . "$DOTFILES_ROOT/config/versions.env"
    local key
    for key in RUST_VERSION NODE_VERSION NPM_VERSION PNPM_VERSION BUN_VERSION NVM_UNIX_VERSION; do
        [[ ${!key:-} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Invalid $key in config/versions.env"
    done
}
