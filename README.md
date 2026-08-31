# Omarchy dotfiles

This repository is initialized as a chezmoi source directory for the Omarchy
user configuration in this environment.

Managed configuration:

- `~/.config/hypr/monitors.lua` — internal display scale `1.25`
- `~/.config/hypr/autostart.lua` — FlowZ and the hyprswitch overview daemon
- `~/.config/hypr/bindings.lua` — `SUPER+TAB` opens the hyprswitch window overview
- `~/.config/codex-flags.conf` — launch the ChatGPT app through the local proxy at `127.0.0.1:1082`
- `~/.config/nvim` — LazyVim-based Neovim configuration (symlinked to this repository for live local updates)
- `~/.ticker.yaml` — grouped US stock, cryptocurrency, and China A-share watchlists for `ticker`
- Zsh — fast completion, history search, fzf, zoxide, mise, and lightweight plugins
- Starship — a compact Git-aware prompt shared by Zsh and PowerShell
- Proxy — enabled by default on `127.0.0.1:1082`, with shell-local on/off helpers
- PowerShell 7 — Windows profile with the same prompt, navigation, and proxy defaults

The Hyprland templates use `{{ .chezmoi.homeDir }}` for user-specific paths.
The `hyprswitch` binary is installed separately at `~/.local/bin/hyprswitch`.

## Apply with chezmoi

On a new macOS or Omarchy Linux machine, install `chezmoi` and clone this
repository as its source state:

```bash
chezmoi init git@github.com:nivalume/dotfiles.git
chezmoi diff
chezmoi apply
```

For this existing local checkout, initialize the local chezmoi configuration
once, then use the same commands without a `--source` flag:

```bash
chezmoi init --source="$(pwd)"
chezmoi diff
chezmoi apply
```

The generated local configuration records the checkout as `sourceDir`. On
macOS, Hyprland files are ignored; on Linux, the PowerShell profile is ignored.
Neovim is deployed as a symlink to the repository's `nvim/` directory, so its
configuration remains live-editable on both platforms.

## Cross-platform shell

Linux and macOS use Zsh. Native Windows uses PowerShell 7; WSL uses the Linux
Zsh configuration. Install `starship`, `fzf`, `zoxide`, `mise`, and the two Zsh
plugins with the platform package manager. The configuration gracefully skips
tools that are not installed yet.

Proxy environment variables are enabled in each interactive shell and point to
`127.0.0.1:1082`. Use `proxy_on`, `proxy_off`, and `proxy_status` to control the
proxy for the current shell session.

Useful commands:

```bash
chezmoi diff
chezmoi apply
chezmoi add ~/.config/hypr/<file>
```

Install and launch the market dashboard with:

```bash
omarchy pkg aur add ticker
ticker
```

Inside `ticker`, use `Tab` and `Shift+Tab` to switch between market groups.
