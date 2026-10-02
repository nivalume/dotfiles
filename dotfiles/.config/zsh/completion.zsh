autoload -Uz compinit

zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zsh_completions_dir="$HOME/.local/share/zsh/plugins/zsh-completions/src"
mkdir -p "${zcompdump:h}"

# Rebuild completion metadata when Zsh or extra completions have changed.
if [[ ! -e "$zcompdump" || "$zcompdump" -ot /usr/share/zsh || ( -d "$zsh_completions_dir" && "$zcompdump" -ot "$zsh_completions_dir" ) ]]; then
  compinit -d "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi
unset zcompdump zsh_completions_dir

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}%d%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completion"
