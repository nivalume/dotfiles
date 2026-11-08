#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

case "$(uname -s)" in
    Darwin) bash "$DOTFILES_ROOT/platforms/macos/install.sh" ;;
    Linux)
        [[ -r /etc/os-release ]] || die "Cannot identify this Linux distribution."
        . /etc/os-release
        case "${ID:-}" in
            debian|ubuntu) bash "$DOTFILES_ROOT/platforms/linux/apt/install.sh" ;;
            arch|omarchy) bash "$DOTFILES_ROOT/platforms/linux/pacman/install.sh" ;;
            *) die "Supported Linux distributions: Debian, Ubuntu, Arch and Omarchy; detected ${ID:-unknown}." ;;
        esac
        ;;
    *) die "Unsupported operating system: $(uname -s)" ;;
esac
bash "$DOTFILES_ROOT/scripts/install-toolchains.sh"
bash "$DOTFILES_ROOT/scripts/install-native-tools.sh"
fish "$DOTFILES_ROOT/scripts/install-fish-plugins.fish"
bash "$DOTFILES_ROOT/scripts/install-ai-clis.sh"
log "Setup completed. Open a new shell, then run scripts/doctor.sh."
