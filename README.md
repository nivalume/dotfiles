# Mise dotfiles

This repository is a `mise bootstrap` project. It owns the global toolchain,
shared environment defaults, native shell packages, and every dotfile under
`dotfiles/`; chezmoi is no longer part of the setup.

`mise.toml` pins the shared development toolchain: Go, Rust, Python, Node.js,
pnpm, Bun, uv, Neovim, Conda, common CLI tools, and Codex, Grok, and Claude Code.
Project-level `mise.toml` files can still override these global defaults.

## Bootstrap a new machine

### macOS and Linux

The installer needs `curl`, and `mise bootstrap --from` needs `git` to fetch the
repository. Minimal Debian/Ubuntu/WSL images can install both with
`sudo apt-get update && sudo apt-get install -y curl git`. Then run:

```bash
curl -fsSL https://mise.run | sh
"$HOME/.local/bin/mise" bootstrap --from https://github.com/nivalume/dotfiles.git --from-dir "$HOME/.dotfiles" --yes
```

On the checked-out repository, inspect first and then apply:

```bash
mise bootstrap --dry-run
mise bootstrap
mise doctor
```

### Windows (PowerShell 7)

Install PowerShell 7 and Scoop, then open PowerShell 7 and bootstrap:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install mise git
$env:HOME = $env:USERPROFILE
git clone https://github.com/nivalume/dotfiles.git "$HOME\.dotfiles"
Set-Location "$HOME\.dotfiles"
mise trust
mise bootstrap --dry-run
mise bootstrap
mise doctor
```

The PowerShell profile sets `HOME` from `USERPROFILE` when needed, activates
mise, and configures the same prompt, fuzzy history search, directory jumping,
proxy helpers, and short Git commands as the Unix shell profiles. Windows-only
CLI packages are installed through Scoop; Zsh and its plugins remain specific
to macOS/Linux.

Conda is installed at the same pinned version by mise on every platform. The
shell profiles load its activation hook, while the managed `~/.condarc` keeps
named environments and package caches in stable `~/.conda/` paths, selects
conda-forge with strict channel priority, and prevents base from shadowing
mise's Python. Use `conda create -n NAME python=3.14` and `conda activate NAME`
to manage environments. After installing Conda in an already-open PowerShell,
reload the profile with `. $PROFILE`.

On Windows, `.wslconfig` enables mirrored networking, DNS tunneling, and proxy
inheritance for WSL 2. Run `wsl --shutdown` after applying it so WSL reloads
the settings.

The bootstrap symlinks its own `mise.toml` to
`~/.config/mise/config.toml`, so its exact tool versions and `[env]` defaults
apply globally after the first run. `mise bootstrap` installs Zsh through
Homebrew on macOS, apt on Debian/Ubuntu, or pacman on Omarchy/Arch; classic `z`
is checked out alongside Spaceship, zsh-completions, zsh-autosuggestions, and
zsh-syntax-highlighting under `~/.local/share/zsh/`. The Zsh configuration
loads extra completions before `compinit`, then `z`, autosuggestions, Spaceship,
and syntax highlighting. Starship uses its Catppuccin Powerline preset. Select
a Nerd Font in the terminal to render prompt symbols correctly. Run `z foo`
after visiting directories to jump to the most frequently/recently used match.
Run `zsh` to enter the configured shell. On Windows it installs Git, zoxide,
eza, and bat through Scoop.

## Per-machine environment

`mise bootstrap --from` is pinned to `~/.dotfiles`, which is the source root in
`mise.toml`. If you already cloned the repository somewhere else, make
`~/.dotfiles` point to that checkout before applying:

```powershell
New-Item -ItemType Junction -Path "$HOME\.dotfiles" -Target "E:\path\to\dotfiles"
```

```sh
ln -s /path/to/dotfiles ~/.dotfiles
```

The repository tracks `.env.example` and deploys it to
`~/.config/mise/.env.example`. For machine-specific values, copy it to
`~/.config/mise/.env` and add values such as `ARK_API_KEY`. That file is local
to the machine and is loaded by mise when a shell starts; it is optional, so a
fresh bootstrap does not require a secret file.

## Managed files

All deployable files live in `dotfiles/` and are linked by mise. This includes
the shell profiles, Zsh modules, proxy helpers, Starship, Codex flags, ticker,
Neovim, Linux-only Hyprland configuration, and the Windows PowerShell profile.
The shell hooks activate mise; shared `EDITOR`, `PAGER`, XDG defaults, and the
user-local bin path are declared in `[env]` instead of shell-specific exports.
The same environment sets `PNPM_HOME` and adds its `bin/` directory to `PATH`,
so pnpm global tools are available in a new shell without running `pnpm setup`.

`FlowZ` and `hyprswitch` remain external Linux applications because this
repository contains their configuration only, not a reproducible artifact or
package source.

## Updating

Edit `mise.toml` or files in `dotfiles/`, then run:

```bash
mise lock
mise install
mise bootstrap repos apply --yes
mise dot apply
mise dot status
mise doctor
```

Use `mise dot diff` before applying an existing machine. A symlink target that
already contains a real file is intentionally refused; reconcile it first or
use `mise dot apply --force` only after reviewing that file.
