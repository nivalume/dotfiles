# Neovim

This is the host Neovim configuration, built on [LazyVim](https://www.lazyvim.org/).
It enables LazyVim language extras for Docker, JSON, Markdown, Python, Rust,
TOML, TypeScript, and YAML. LazyVim installs the relevant LSP servers,
formatters, linters, and Treesitter parsers through Mason on first use.

## Large Rust workspaces

The Rust defaults favor responsive editing: rust-analyzer checks only the
current package with default Cargo features and uses a separate target
directory, so it does not contend with terminal builds for `Cargo.lock`.
Build scripts and procedural macros remain enabled. Run full-workspace and
all-feature checks explicitly in CI or from a terminal.

`~/.config/nvim` is a symlink to this directory during local development, so
changes here take effect on the next Neovim startup without a `chezmoi apply`.

Useful commands:

```bash
nvim                    # start Neovim
nvim +Lazy              # inspect/update plugins
nvim +Mason             # inspect language tooling
nvim +checkhealth       # diagnose the installation
```
