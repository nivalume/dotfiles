set -l manifest "$DOTFILES_ROOT/modules/fish/fish_plugins"
set -l desired (string match -rv '^\s*(#|$)' < "$manifest")
set -l sync_plugins 0

if not functions -q fisher
    set -l temp_dir (mktemp -d)
    curl -fsSL --retry 3 https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish -o "$temp_dir/fisher.fish"; or begin
        rm -rf "$temp_dir"
        exit 1
    end
    source "$temp_dir/fisher.fish"; or begin
        rm -rf "$temp_dir"
        exit 1
    end
    rm -rf "$temp_dir"
    set sync_plugins 1
end

set -l installed (fisher list)
if test (count $installed) -ne (count $desired)
    set sync_plugins 1
end
for plugin in $desired
    if not contains -- "$plugin" $installed
        set sync_plugins 1
    end
end
if not functions -q fzf_configure_bindings; or not functions -q tide; or not functions -q nvm
    set sync_plugins 1
end
if test $sync_plugins -eq 1
    fisher update; or exit 1
end
set installed (fisher list)
for plugin in $desired
    if not contains -- "$plugin" $installed
        echo "Fish plugin installation failed: $plugin" >&2
        exit 1
    end
end
for name in fisher tide nvm fzf_configure_bindings
    if not functions -q $name
        echo "Fish plugin function is missing: $name" >&2
        exit 1
    end
end
