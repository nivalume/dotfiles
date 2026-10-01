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
command -v zoxide >/dev/null && eval "$(zoxide init bash)"
command -v mise >/dev/null && eval "$(mise activate bash)"
command -v conda >/dev/null && eval "$(conda shell.bash hook)"
command -v starship >/dev/null && eval "$(starship init bash)"
