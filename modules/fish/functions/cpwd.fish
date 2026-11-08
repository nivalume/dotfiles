function cpwd --description 'Copy the current directory to the clipboard'
    set -l path (string replace -r '^'"$HOME" '~' -- "$PWD")
    if command -q pbcopy
        printf %s "$path" | pbcopy
    else if command -q wl-copy
        printf %s "$path" | wl-copy
    else if command -q xclip
        printf %s "$path" | xclip -selection clipboard
    else
        echo 'cpwd requires pbcopy, wl-copy or xclip' >&2
        return 1
    end
end
