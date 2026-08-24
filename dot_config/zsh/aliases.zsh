if command -v eza >/dev/null; then
  alias l='eza --icons=auto --group-directories-first'
  alias ll='eza -lah --icons=auto --group-directories-first'
  alias lt='eza --tree --icons=auto --group-directories-first'
else
  alias l='ls -lah'
  alias ll='ls -lah'
fi

command -v bat >/dev/null && alias bt='bat'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph -20'
