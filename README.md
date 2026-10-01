# Mise dotfiles

This repository is a `mise bootstrap` project. It owns the global toolchain,
shared environment defaults, native shell packages, and every dotfile under
`dotfiles/`; chezmoi is no longer part of the setup.

`mise.toml` pins the shared development toolchain: Go, Rust, Python, Node.js,
pnpm, Bun, uv, Neovim, Conda, common CLI tools, and Codex, Grok, and Claude Code.
Project-level `mise.toml` files can still override these global defaults.

## Bootstrap a new machine

### macOS and Linux

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

### Windows (PowerShell 7)

Install PowerShell 7 and Scoop, then open PowerShell 7 and bootstrap:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install mise git
$env:HOME = $env:USERPROFILE
git clone https://github.com/nivalume/dotfiles.git "$HOME\dotfiles"
Set-Location "$HOME\dotfiles"
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
apply globally after the first run. `mise bootstrap` also installs native
shell pieces: Zsh, classic `z`, zsh-autosuggestions, and
zsh-syntax-highlighting (Homebrew on macOS; pacman on Omarchy/Arch). On Windows
it installs Git, zoxide, eza, and bat through Scoop.

## Per-machine environment

The repository tracks .env.example. Copy it to .env in the repository root
and add per-machine values such as ARK_API_KEY. Git ignores root .env.
The checkout must be available as `~/.dotfiles`; if it lives elsewhere,
create a directory symlink or junction at that path:

```powershell
New-Item -ItemType Junction -Path "$HOME\.dotfiles" -Target "E:\path\to\dotfiles"
```

```sh
ln -s /path/to/dotfiles ~/.dotfiles
```

`mise dot apply` copies root .env to `~/.config/mise/.env`, which the Zsh, Bash, and PowerShell
mise activation hooks load into each shell. The home-relative source paths
let you run `mise dot apply` from any directory. After editing root .env,
run apply and open a new shell or reload the profile.

## Managed files

All deployable files live in `dotfiles/` and are linked by mise. This includes
the shell profiles, Zsh modules, proxy helpers, Starship, Codex flags, ticker,
Neovim, Linux-only Hyprland configuration, and the Windows PowerShell profile.
The shell hooks activate mise; shared `EDITOR`, `PAGER`, XDG defaults, and the
user-local bin path are declared in `[env]` instead of shell-specific exports.

`FlowZ` and `hyprswitch` remain external Linux applications because this
repository contains their configuration only, not a reproducible artifact or
package source.

## Updating

Edit `mise.toml` or files in `dotfiles/`, then run:

```bash
mise lock
mise install
mise dot apply
mise dot status
mise doctor
```

Use `mise dot diff` before applying an existing machine. A symlink target that
already contains a real file is intentionally refused; reconcile it first or
use `mise dot apply --force` only after reviewing that file.
