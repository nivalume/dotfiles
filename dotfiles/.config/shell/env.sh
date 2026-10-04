# Shared environment for bash and zsh. Sourced from .zshenv and the bashrc.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"
export PNPM_HOME="${PNPM_HOME:-$XDG_DATA_HOME/pnpm}"

# Prepend only existing directories, once. Later entries take priority.
__path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in *":$1:"*) return 0 ;; esac
  PATH="$1:$PATH"
}
for __d in /usr/local/bin /opt/homebrew/bin "$HOME/.cargo/bin" "$PNPM_HOME" "$HOME/.local/bin"; do
  __path_prepend "$__d"
done
unset __d
unset -f __path_prepend
export PATH

# Machine-local secrets (not in the repository).
if [ -r "$XDG_CONFIG_HOME/dotfiles/local.env" ]; then
  set -a
  . "$XDG_CONFIG_HOME/dotfiles/local.env"
  set +a
fi
