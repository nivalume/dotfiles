# Omarchy dotfiles

This repository is initialized as a chezmoi source directory for the Omarchy
user configuration in this environment.

Managed configuration:

- `~/.config/hypr/monitors.lua` — internal display scale `1.25`
- `~/.config/hypr/autostart.lua` — FlowZ and the hyprswitch overview daemon
- `~/.config/hypr/bindings.lua` — `SUPER+TAB` opens the hyprswitch window overview
- `~/.config/codex-flags.conf` — launch the ChatGPT app through the local proxy at `127.0.0.1:1082`
- `~/.ticker.yaml` — grouped US stock, cryptocurrency, and China A-share watchlists for `ticker`
- Zsh — fast completion, history search, fzf, zoxide, mise, and lightweight plugins
- Starship — a compact Git-aware prompt shared by Zsh and PowerShell
- Proxy — enabled by default on `127.0.0.1:1082`, with shell-local on/off helpers
- PowerShell 7 — Windows profile with the same prompt, navigation, and proxy defaults

The Hyprland templates use `{{ .chezmoi.homeDir }}` for user-specific paths.
The `hyprswitch` binary is installed separately at `~/.local/bin/hyprswitch`.

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
