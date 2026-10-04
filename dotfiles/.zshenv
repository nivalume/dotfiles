# Keep this file small: it is loaded for every zsh, including scripts.
typeset -U path PATH
[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"
