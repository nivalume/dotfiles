# Mise dotfiles

This repository is a `mise bootstrap` project. It owns the global toolchain,
shared environment defaults, native shell packages, and every dotfile under
`dotfiles/`; chezmoi is no longer part of the setup.

`mise.toml` pins the development tools currently used on this Mac: Go, Rust,
Python, Node.js, pnpm, Bun, uv, Neovim, common CLI tools, and Codex, Grok, and
Claude Code. Project-level `mise.toml` files can still override these global
defaults.

## Bootstrap a new machine

Install mise once, then let this repository take over:

```bash
curl https://mise.run | sh
mise bootstrap --from git@github.com:nivalume/dotfiles.git
```

On the checked-out repository, inspect first and then apply:

```bash
mise bootstrap --dry-run
mise bootstrap
mise doctor
```

The bootstrap symlinks its own `mise.toml` to
`~/.config/mise/config.toml`, so its exact tool versions and `[env]` defaults
apply globally after the first run. `mise bootstrap` also installs the native
shell pieces: Zsh, classic `z`, zsh-autosuggestions, and
zsh-syntax-highlighting (Homebrew on macOS; pacman on Omarchy/Arch).

## Managed files

All deployable files live in `dotfiles/` and are linked by mise. This includes
the shell profiles, Zsh modules, proxy helpers, Starship, Codex flags, ticker,
Neovim, Linux-only Hyprland configuration, and the Windows PowerShell profile.
The shell hooks activate mise; shared `EDITOR`, `PAGER`, XDG defaults, and the
user-local bin path are declared in `[env]` instead of shell-specific exports.

`FlowZ` and `hyprswitch` remain external Linux applications because this
repository contains their configuration only, not a reproducible artifact or
package source. The old automatic Miniforge activation is deliberately not
carried over: it would replace mise's pinned Python on `PATH`; declare a conda
environment in the project that needs it instead.

## Updating

Edit `mise.toml` or files in `dotfiles/`, then run:

```bash
mise lock
mise bootstrap
mise dot status
```

Use `mise dot diff` before applying an existing machine. A symlink target that
already contains a real file is intentionally refused; reconcile it first or
use `mise dot apply --force` only after reviewing that file.
