# Interactive zsh configuration.
[[ -o interactive ]] || return

ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

source "$ZSH_CONFIG_DIR/options.zsh"
source "$ZSH_CONFIG_DIR/completion.zsh"
source "$ZSH_CONFIG_DIR/keybindings.zsh"
source "$ZSH_CONFIG_DIR/aliases.zsh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/proxy.sh"

command -v fzf >/dev/null && source <(fzf --zsh)

# Prefer classic z when available; it defines the `z` directory-jump command.
z_loaded=0
for z_script in \
  /opt/homebrew/etc/profile.d/z.sh \
  /usr/local/etc/profile.d/z.sh \
  /usr/share/z/z.sh; do
  if [[ -r "$z_script" ]]; then
    source "$z_script"
    z_loaded=1
    break
  fi
done
(( z_loaded )) || { command -v zoxide >/dev/null && eval "$(zoxide init zsh)"; }
unset z_loaded z_script

command -v mise >/dev/null && eval "$(mise activate zsh)"

# Package locations differ between Arch Linux and Homebrew.
for plugin_file in \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -r "$plugin_file" ]] && source "$plugin_file" && break
done

command -v starship >/dev/null && eval "$(starship init zsh)"

# Syntax highlighting must be sourced at the end of .zshrc.
for plugin_file in \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -r "$plugin_file" ]] && source "$plugin_file" && break
done
unset plugin_file
