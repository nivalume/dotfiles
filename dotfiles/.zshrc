# Interactive zsh configuration.
[[ -o interactive ]] || return

ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
ZSH_DATA_DIR="$HOME/.local/share/zsh"

# Add extra completion definitions before compinit builds its cache.
zsh_completions_dir="$ZSH_DATA_DIR/plugins/zsh-completions/src"
[[ -d "$zsh_completions_dir" ]] && fpath=("$zsh_completions_dir" $fpath)

source "$ZSH_CONFIG_DIR/options.zsh"
source "$ZSH_CONFIG_DIR/completion.zsh"
source "$ZSH_CONFIG_DIR/keybindings.zsh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/proxy.sh"

command -v fzf >/dev/null && source <(fzf --zsh)

# Classic z from install.sh, with package-manager fallbacks.
z_script="$ZSH_DATA_DIR/plugins/z/z.sh"
if [[ ! -r "$z_script" ]]; then
  for z_script in \
    /opt/homebrew/etc/profile.d/z.sh \
    /usr/local/etc/profile.d/z.sh \
    /usr/share/z/z.sh; do
    [[ -r "$z_script" ]] && break
  done
fi
if [[ -r "$z_script" ]]; then
  source "$z_script"
else
  command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
fi
unset z_script

# mise provides the toolchain on macOS and Linux (Windows uses Scoop).
command -v mise >/dev/null && eval "$(mise activate zsh)"

# Load conda's shell hook lazily on first use to keep startup fast.
if command -v conda >/dev/null 2>&1; then
  __conda_bin="$(command -v conda)"
  conda() {
    unfunction conda
    eval "$("$__conda_bin" shell.zsh hook)"
    conda "$@"
  }
fi

autosuggestions_script="$ZSH_DATA_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "$autosuggestions_script" ]] && source "$autosuggestions_script"

# Same prompt as bash and PowerShell (Catppuccin Powerline preset).
command -v starship >/dev/null && eval "$(starship init zsh)"

unset ZSH_DATA_DIR zsh_completions_dir autosuggestions_script

# Syntax highlighting must be sourced at the end of .zshrc.
syntax_highlighting_script="$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -r "$syntax_highlighting_script" ]] && source "$syntax_highlighting_script"
