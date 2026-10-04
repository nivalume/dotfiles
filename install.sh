#!/usr/bin/env bash
# Dotfiles manager for macOS and Linux (no mise required).
#   ./install.sh apply      link everything listed in links.tsv
#   ./install.sh status     show the state of every link
#   ./install.sh adopt      move existing real files into the repo, then link them
#   ./install.sh packages   install packages, zsh plugins, npm globals, editor extensions
#   ./install.sh all        packages, then apply
# Add --force to back up conflicting files (name.bak-YYYYMMDD) and replace them.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/dotfiles"
STAMP="$(date +%Y%m%d)"
FORCE=0
CMD="${1:-help}"
[[ "${2:-}" == "--force" || "${1:-}" == "--force" ]] && FORCE=1

case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux) OS=linux ;;
  *) echo "Unsupported OS: $(uname -s). Use install.ps1 on Windows." >&2; exit 1 ;;
esac

expand() { local t="$1"; printf '%s' "${t/#\~/$HOME}"; }

each_link() { # calls "$1 src dst" for every link that applies to this OS
  local os rel target
  while IFS=$'\t' read -r os rel target; do
    [[ -z "${os:-}" || "$os" == \#* ]] && continue
    case "$os" in all | unix | "$OS") ;; *) continue ;; esac
    "$1" "$SRC/$rel" "$(expand "$target")"
  done <"$ROOT/links.tsv"
}

link_state() { # $1 src, $2 dst
  if [[ -L "$2" ]]; then
    [[ "$(readlink "$2")" == "$1" ]] && echo linked || echo conflict
  elif [[ -e "$2" ]]; then
    echo conflict
  else
    echo missing
  fi
}

do_status() { printf '%-9s %s\n' "$(link_state "$1" "$2")" "$2"; }

do_apply() {
  local src="$1" dst="$2" state
  state="$(link_state "$src" "$dst")"
  case "$state" in
    linked) echo "ok        $dst" ;;
    missing)
      mkdir -p "$(dirname "$dst")"
      ln -s "$src" "$dst"
      echo "linked    $dst"
      ;;
    conflict)
      if ((FORCE)); then
        mv "$dst" "$dst.bak-$STAMP"
        ln -s "$src" "$dst"
        echo "replaced  $dst (backup: $dst.bak-$STAMP)"
      else
        echo "CONFLICT  $dst exists and is not this repo's link (use 'adopt' or '--force')" >&2
      fi
      ;;
  esac
}

do_adopt() {
  local src="$1" dst="$2"
  if [[ -f "$dst" && ! -L "$dst" ]]; then
    mkdir -p "$(dirname "$src")"
    cp "$dst" "$src"
    mv "$dst" "$dst.bak-$STAMP"
    ln -s "$src" "$dst"
    echo "adopted   $dst"
  else
    do_apply "$src" "$dst"
  fi
}

# ~/.bashrc stays a real file (distros such as Omarchy ship their own), so add
# one block that sources the shared bashrc instead of replacing it.
ensure_bashrc_block() {
  local rc="$HOME/.bashrc" begin="# >>> dotfiles >>>"
  if ! grep -qF "$begin" "$rc" 2>/dev/null; then
    {
      printf '\n%s\n' "$begin"
      printf '%s\n' '[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/bashrc" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/bashrc"'
      printf '%s\n' "# <<< dotfiles <<<"
    } >>"$rc"
    echo "added     dotfiles block to $rc"
  fi
}

list() { grep -vE '^\s*(#|$)' "$1"; }

install_packages() {
  case "$OS" in
    macos)
      command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh" >&2; exit 1; }
      brew bundle --file="$ROOT/packages/Brewfile"
      ;;
    linux)
      if command -v pacman >/dev/null; then
        list "$ROOT/packages/pacman.txt" | sudo pacman -S --needed --noconfirm -
      elif command -v apt-get >/dev/null; then
        sudo apt-get update
        list "$ROOT/packages/apt.txt" | xargs sudo apt-get install -y
      else
        echo "No supported package manager found; install the tools in packages/ by hand." >&2
      fi
      ;;
  esac

  local path url
  while IFS=$'\t' read -r path url; do
    [[ -z "${path:-}" || "$path" == \#* ]] && continue
    path="$(expand "$path")"
    if [[ -d "$path/.git" ]]; then
      echo "ok        $path"
    else
      mkdir -p "$(dirname "$path")"
      git clone --depth 1 "$url" "$path"
    fi
  done <"$ROOT/repos.tsv"

  if command -v rustup >/dev/null && ! rustup toolchain list 2>/dev/null | grep -q .; then
    rustup default stable
  fi
  if command -v npm >/dev/null; then
    # shellcheck disable=SC2046
    npm install -g $(list "$ROOT/packages/npm-globals.txt")
  else
    echo "npm not found; skipping npm globals." >&2
  fi
  if command -v code >/dev/null; then
    local have ext
    have="$(code --list-extensions)"
    while read -r ext; do
      grep -qix "$ext" <<<"$have" || code --install-extension "$ext"
    done < <(list "$ROOT/packages/vscode-extensions.txt")
  fi
}

case "$CMD" in
  status) each_link do_status ;;
  apply) each_link do_apply; ensure_bashrc_block ;;
  adopt) each_link do_adopt; ensure_bashrc_block ;;
  packages) install_packages ;;
  all) install_packages; each_link do_apply; ensure_bashrc_block ;;
  *) sed -n '2,8p' "$0" ;;
esac
