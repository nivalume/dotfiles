#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../../scripts/lib/common.sh"

missing=()
while IFS= read -r package; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    pacman -Q "$package" >/dev/null 2>&1 || missing+=("$package")
done < "$DOTFILES_ROOT/platforms/linux/pacman/packages.txt"
((${#missing[@]} == 0)) || sudo pacman -S --needed --noconfirm "${missing[@]}"
pacman -Q min-browser-bin >/dev/null 2>&1 && exit 0

if command -v paru >/dev/null 2>&1; then
    paru -S --needed --noconfirm min-browser-bin
elif command -v yay >/dev/null 2>&1; then
    yay -S --needed --noconfirm min-browser-bin
else
    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT
    git clone https://aur.archlinux.org/min-browser-bin.git "$temp_dir/min-browser-bin"
    (cd "$temp_dir/min-browser-bin" && makepkg -si --noconfirm)
fi
