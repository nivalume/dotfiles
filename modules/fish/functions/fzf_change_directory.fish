function fzf_change_directory --description 'Find a project or nearby directory'
    set -l selected (begin
        printf '%s\n' "$HOME/.config"
        if command -q ghq
            ghq list --full-path
        end
        find . -mindepth 1 -maxdepth 2 -type d -not -path '*/.git*' 2>/dev/null
    end | sort -u | fzf --layout reverse --prompt 'directory> ')
    if test -n "$selected"
        builtin cd "$selected"
        commandline -f repaint
    end
end
