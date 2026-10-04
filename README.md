# dotfiles

Cross-platform dotfiles for macOS, Linux (including Omarchy and WSL) and Windows.
No version manager is required: tools come from the system package manager
(Homebrew, pacman, apt or Scoop), and two small scripts link the config files.

| Path | Purpose |
| --- | --- |
| `dotfiles/` | Every config file, laid out like the home directory |
| `links.tsv` | Which file goes where, per OS (`all`, `unix`, `macos`, `linux`, `windows`) |
| `repos.tsv` | Git checkouts for zsh plugins (`install.sh packages`) |
| `packages/` | Scoop, Homebrew, pacman and apt lists, npm globals, VS Code extensions |
| `install.sh` / `install.ps1` | Link manager and package installer |

## Set up a machine

macOS / Linux:

```bash
git clone git@github.com:nivalume/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh all      # packages, zsh plugins, npm globals, then links
./install.sh status
```

Windows (PowerShell 7, with [Scoop](https://scoop.sh) installed):

```powershell
git clone git@github.com:nivalume/dotfiles.git $HOME\.dotfiles
cd $HOME\.dotfiles
.\install.ps1 all
.\install.ps1 status
```

`apply` never overwrites a file that differs. It reports a conflict instead. Use
`adopt` to keep the machine's version (it is copied into the repo), or `-Force` /
`--force` to replace it; the old file is kept as `name.bak-YYYYMMDD`.

On Windows, files are symlinked when Developer Mode (or admin) allows it and
copied otherwise; directories use junctions. With copies, edit the repo file and
run `apply`, or edit the live file and run `adopt`. `status` shows `drift` when
the two differ. Turning on Developer Mode removes the need for this.

## What is configured

- **Shells**: zsh (`.zshrc`, `.config/zsh/`), bash (`.config/shell/bashrc`, added to
  `~/.bashrc` as a marked block so distro defaults stay), and PowerShell 7. All of
  them use [Starship](https://starship.rs) with the Catppuccin Powerline preset,
  `z`/zoxide, fzf, proxy helpers (`proxy` / `unproxy`) and a lazily loaded conda.
  Select a Nerd Font (FiraCode Nerd Font) in the terminal.
- **Environment**: `.config/shell/env.sh` (bash/zsh) and the PowerShell profile set
  `EDITOR`, `PAGER`, XDG directories, `PNPM_HOME` and PATH.
- **Secrets**: put machine-local values such as `ARK_API_KEY` in
  `~/.config/dotfiles/local.env` (copy `dotfiles/.config/shell/local.env.example`).
  It is outside the repository and read by every shell.
- **Neovim**: LazyVim in `.config/nvim`.
- **VS Code**: `.config/Code/User/settings.json` and `keybindings.json` implement
  the LazyVim keymap (Space as leader) on top of the Vim extension, and are linked
  to the right per-OS location. Extensions are listed in
  `packages/vscode-extensions.txt`.
- **Toolchain**: Go, Rust (rustup), Python, Node, pnpm, Bun, uv, Miniconda and
  CLI tools are installed natively. Conda environments live in `~/.conda/`
  (`.condarc`). Codex, Grok, Claude Code, OpenSpec and pm2 are npm globals in
  `packages/npm-globals.txt`.
- **Windows only**: PowerShell profile and `.wslconfig` (mirrored networking,
  DNS tunneling, proxy inheritance; run `wsl --shutdown` after changing it).
- **Linux only**: Hyprland configuration.

## Updating

Edit files under `dotfiles/` (or the live files, then `adopt` on Windows), add new
files to `links.tsv`, and re-run `apply`. Add packages to the matching list in
`packages/` and re-run `packages`.
