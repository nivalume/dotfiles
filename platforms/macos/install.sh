#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../scripts/lib/common.sh"

xcode-select -p >/dev/null 2>&1 || die "Install Apple's build tools first: xcode-select --install; then run the setup again."
if ! command -v brew >/dev/null 2>&1; then
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then eval "$("$candidate" shellenv)"; break; fi
    done
fi
if ! command -v brew >/dev/null 2>&1; then
    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT
    download https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh "$temp_dir/homebrew.sh"
    NONINTERACTIVE=1 bash "$temp_dir/homebrew.sh"
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then eval "$("$candidate" shellenv)"; break; fi
    done
fi
brewfile="$DOTFILES_ROOT/platforms/macos/Brewfile"
brew bundle check --file="$brewfile" >/dev/null 2>&1 && exit 0
if brew help trust >/dev/null 2>&1; then
    brew trust --tap d-kuro/tap heroku/brew
fi
brew bundle install --file="$brewfile" --no-upgrade
