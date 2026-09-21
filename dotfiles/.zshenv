# Keep this file small: it is loaded before mise can activate.
typeset -U path PATH
path=("$HOME/.local/bin" $path)
for brew_bin in /opt/homebrew/bin /usr/local/bin; do
  [[ -d "$brew_bin" ]] && path=("$brew_bin" $path)
done
unset brew_bin
