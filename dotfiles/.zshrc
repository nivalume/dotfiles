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
source "$ZSH_CONFIG_DIR/aliases.zsh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/proxy.sh"

command -v fzf >/dev/null && source <(fzf --zsh)

# Load classic z from the bootstrap checkout, with package-manager fallbacks.
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

command -v mise >/dev/null && eval "$(mise activate zsh)"
command -v conda >/dev/null && eval "$(conda shell.zsh hook)"

# User-local plugins are checked out by mise bootstrap on every platform.
autosuggestions_script="$ZSH_DATA_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "$autosuggestions_script" ]] && source "$autosuggestions_script"

# Spaceship is checked out by mise bootstrap into XDG data storage.
SPACESHIP_CONFIG="$ZSH_CONFIG_DIR/spaceship.zsh"
spaceship_script="$ZSH_DATA_DIR/spaceship-prompt/spaceship.zsh"
if [[ -r "$spaceship_script" ]]; then
  source "$spaceship_script"
elif [[ -r /opt/homebrew/opt/spaceship/spaceship.zsh ]]; then
  source /opt/homebrew/opt/spaceship/spaceship.zsh
elif [[ -r /usr/local/opt/spaceship/spaceship.zsh ]]; then
  source /usr/local/opt/spaceship/spaceship.zsh
fi

unset ZSH_DATA_DIR zsh_completions_dir autosuggestions_script spaceship_script

# Syntax highlighting must be sourced at the end of .zshrc.
syntax_highlighting_script="$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -r "$syntax_highlighting_script" ]] && source "$syntax_highlighting_script"
