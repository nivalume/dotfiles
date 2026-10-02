# Omarchy's defaults are available on Omarchy Linux, but this file also works
# on macOS, generic Linux, WSL, and Git Bash.
if [[ "$(uname -s)" == "Linux" ]]; then
  [[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap
fi

[[ $- == *i* ]] || return

if [[ "$(uname -s)" == "Linux" ]]; then
  [[ -n "${OMARCHY_PATH:-}" && -r "$OMARCHY_PATH/default/bash/rc" ]] && source "$OMARCHY_PATH/default/bash/rc"
fi

[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/proxy.sh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/proxy.sh"

for brew_bin in /opt/homebrew/bin /usr/local/bin; do
  [[ -d "$brew_bin" ]] && PATH="$brew_bin:$PATH"
done
unset brew_bin

command -v fzf >/dev/null && eval "$(fzf --bash)"
z_script="$HOME/.local/share/zsh/plugins/z/z.sh"
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
  command -v zoxide >/dev/null && eval "$(zoxide init bash)"
fi
unset z_script
command -v mise >/dev/null && eval "$(mise activate bash)"
command -v conda >/dev/null && eval "$(conda shell.bash hook)"
command -v starship >/dev/null && eval "$(starship init bash)"
