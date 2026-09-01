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
- Zsh — fast completion, history search, fzf, classic `z` (with zoxide fallback), mise, and lightweight plugins
- Starship — a compact Git-aware prompt shared by Zsh and PowerShell
- Proxy — disabled by default; use `proxy` and `unproxy` for the current shell
- CLI tools on macOS/Linux — `node`, `npm`, `npx`, `pnpm`, `bun`, `codex`, `grok`, and `claude`
- PowerShell 7 — Windows profile with the same prompt, navigation, and proxy helpers

The Hyprland templates use `{{ .chezmoi.homeDir }}` for user-specific paths.
The `hyprswitch` binary is installed separately at `~/.local/bin/hyprswitch`.
The `run_onchange_install-cli-tools.sh.tmpl` script installs the shell tools
when `chezmoi apply` first runs (or when the script changes). On macOS it
uses Homebrew; on Linux it supports pacman, apt, dnf, and apk.

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
Zsh configuration. `chezmoi apply` installs Node.js/npm (including `npx`),
pnpm, Bun, the official Codex, Grok, and Claude Code CLIs, and classic `z` where
the platform package manager provides it. Install `starship`, `fzf`, `zoxide`,
`mise`, and the two Zsh plugins with the platform package manager. The
configuration gracefully skips tools that are not installed yet.

Proxy environment variables are off in each new shell. Run `proxy` to point
them at `127.0.0.1:1082`, and `unproxy` to remove them from the current shell
session.

The npm-installed CLI mappings are `@openai/codex` → `codex`,
`@xai-official/grok` → `grok`, and `@anthropic-ai/claude-code` → `claude`;
`pnpm` and `bun` are installed from their official npm packages.

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
