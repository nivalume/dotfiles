function fish_user_key_bindings
    # fzf
    bind \cf fzf_change_directory

    # prevent iterm2 from closing when typing Ctrl-D (EOF)
    bind \cd delete-char

    # fzf.fish is optional until the plugin installer has completed.
    if functions -q fzf_configure_bindings
        fzf_configure_bindings --directory=\co
    end
end
