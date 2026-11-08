set -g fish_greeting
set -gx EDITOR nvim
set -gx NPM_CONFIG_PREFIX "$HOME/.local"

if test (uname -s) = Darwin
    if test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
    else if test -x /usr/local/bin/brew
        /usr/local/bin/brew shellenv | source
    end
end
fish_add_path --global --move --path "$HOME/.local/bin" "$HOME/.local/opt/node/bin" "$HOME/.bun/bin" "$HOME/.cargo/bin"

if status is-interactive
    if test -x "$HOME/miniforge3/bin/conda"
        "$HOME/miniforge3/bin/conda" shell.fish hook | source
    end
    if command -q zoxide
        zoxide init fish | source
    end
    alias g git
    alias cz chezmoi
    alias pn pnpm
    if command -q nvim
        alias vim nvim
    end
    if command -q eza
        alias ll 'eza -l -g --icons=auto'
        alias lla 'eza -la -g --icons=auto'
    end
end

set -l local_config (dirname (status --current-filename))/config-local.fish
if test -f "$local_config"
    source "$local_config"
end
