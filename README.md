# Jackson 的 dotfiles

使用 [chezmoi](https://www.chezmoi.io/) 管理开发环境。仓库包含公共配置、各平台的软件清单、Neovim 和终端配置，以及 Rust、Python 和前端工具链的安装脚本。

## 平台与功能

| 功能 | macOS | Debian / Ubuntu | Arch / Omarchy | Windows x64 |
| --- | --- | --- | --- | --- |
| 包管理 | Homebrew | apt + 上游发行包 | pacman + AUR | Scoop + WinGet |
| Shell | Fish + Fisher + Tide | Fish + Fisher + Tide | Fish + Fisher + Tide | PowerShell 7 + Oh My Posh |
| 编辑器 | Neovim + LazyVim | Neovim + LazyVim | Neovim + LazyVim | Neovim + LazyVim |
| Rust | rustup + Apple Command Line Tools | rustup + build-essential | rustup + base-devel | rustup + MSVC Build Tools / Windows SDK |
| Python | Miniforge + uv | Miniforge + uv | Miniforge + uv | Miniforge + uv |
| 前端 | NVM、Node.js、npm、pnpm、Bun | 相同 | 相同 | NVM for Windows、Node.js、npm、pnpm、Bun |
| Git / 终端工具 | Git、gh、ghq、lazygit、delta、zoxide、just、fzf、fd、ripgrep | 相同 | 相同 | 相同 |
| 终端工作区 | tmux、herdr | tmux | tmux | Windows Terminal；WSL 可使用 Linux 配置 |
| Min Browser | — | 官方 `.deb` | AUR `min-browser-bin` | WinGet |
| Codex / Grok / Claude Code | 可选，默认关闭 | 可选，默认关闭 | 可选，默认关闭 | 可选，默认关闭 |

macOS 和 Linux 的安装脚本支持 x86-64、arm64；Windows 的原生安装脚本目前支持 x64。Linux 发行版按 `/etc/os-release` 的 `ID` 匹配 Debian、Ubuntu、Arch 和 Omarchy；apt 清单面向 Debian 13+ 和 Ubuntu 24.04+，Ubuntu 需要启用 universe 软件源。Windows 配置使用标准的 `%USERPROFILE%\AppData\Local` 路径，适合默认用户目录布局。

具体安装项以平台清单为准：

- [macOS Homebrew 清单](platforms/macos/Brewfile)：还包含 Ghostty、1Password、Karabiner-Elements、Zen、Numi、Raycast、Transmit、Sublime Text、Zed、字体及其他命令行工具。
- [Debian / Ubuntu apt 清单](platforms/linux/apt/packages.txt)：较旧仓库缺少 gh、ghq、lazygit、delta、just 或 zoxide 时，从上游发行包补齐；Neovim 使用上游发行包。
- [Arch / Omarchy pacman 清单](platforms/linux/pacman/packages.txt)：Min Browser 从 AUR 安装。
- [Windows Scoop 清单](platforms/windows/scoop.json)和 [WinGet 清单](platforms/windows/winget.json)：还包含 Windows Terminal、PowerToys、WSL、1Password、Sublime Text、Synergy 和 SimplySign Desktop。

## 版本策略

| 工具 | 当前版本 | 安装与升级 |
| --- | --- | --- |
| Rust | 1.99.1 | rustup；包含 rustfmt、clippy、rust-analyzer、rust-src |
| Node.js | 26.13.0 | 官方发行包 |
| npm | 12.2.2 | npm 全局安装 |
| pnpm | 11.28.11 | npm 全局安装 |
| Bun | 1.4.4 | 官方安装程序 |
| nvm-sh | 0.41.0 | macOS/Linux；Fish 使用 nvm.fish，Windows 使用 NVM for Windows |
| Neovim | 不锁定 | 系统包管理器；Debian/Ubuntu 使用上游发行包 |
| uv、Miniforge | 不锁定 | 官方安装程序 |
| Tide / fzf.fish | 6.1.1 / 10.3 | Fisher；兼容 Ubuntu 24.04 的 Fish 3.7 |
| 其他 Fish 插件、LazyVim 插件及系统包 | 不锁定 | Fisher、lazy.nvim 或平台包管理器 |
| Codex、Grok、Claude Code | 不锁定，可选 | 各厂商官方安装程序 |

Rust、Node.js、npm、pnpm、Bun 和 nvm-sh 的版本以 [`config/versions.env`](config/versions.env) 为唯一配置；Tide 与 fzf.fish 在 [`fish_plugins`](modules/fish/fish_plugins) 中固定。修改后运行 `chezmoi apply` 更新。首次安装未锁定工具时获取当时可用的版本，普通 `apply` 会补齐缺失项，不会主动升级所有已安装的软件。不同平台的包仓库和未锁定插件可能提供不同版本；如需完全相同的二进制与插件版本，需要额外锁定这些依赖。

## 安装

### macOS / Linux

需要 Git、curl、Bash 和管理员权限。macOS 的 Rust 构建需要 Apple Command Line Tools：

```sh
xcode-select --install
```

Debian/Ubuntu 的最小系统可先安装 `git curl ca-certificates`；Arch/Omarchy 可用 `pacman` 安装 `git curl`。然后克隆并安装：

```sh
git clone https://github.com/nivalume/dotfiles.git dotc
cd dotc
./install.sh
```

脚本会在缺失时安装 chezmoi，初始化配置并执行 `apply`。首次运行会询问 Git 姓名、邮箱和 GitHub 用户名；Homebrew、apt 或 pacman 可能请求管理员密码。

### Windows

需要 Windows 10/11 x64、WinGet、Git 和 PowerShell。若没有 Git，先运行 `winget install --id Git.Git --exact` 并重新打开终端。

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
git clone https://github.com/nivalume/dotfiles.git dotc
cd dotc
.\install.ps1
```

安装会使用 WinGet 和 Scoop，并在需要时安装 C++ Build Tools 和 Windows SDK；部分安装需要管理员授权或重启。完成后重新打开 **PowerShell 7** 或 Windows Terminal。脚本会在 PowerShell 7 的用户 profile 中添加一行加载 dotc 配置，同时保留 profile 中已有的内容。

### 已有配置的机器

先备份重要的 Git、shell 和编辑器配置。已有 chezmoi 时，可以先初始化并查看差异，再应用：

```sh
chezmoi --source "$PWD" init
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply
```

首次应用时，未带 dotc 标记的旧 Neovim 配置会先复制到备份目录，再部署新配置：macOS/Linux 为 `~/.local/state/dotc/backups/`，Windows 为 `%LOCALAPPDATA%\dotc\backups\`。旧的 Neovim 插件和数据目录不会被清空。其他现有配置请在应用前自行备份；`chezmoi diff` 可以查看将要写入的文件。

## 启动与检查

安装完成后打开新终端：

```sh
fish                 # macOS / Linux
nvim                 # 首次启动会安装 LazyVim 插件
tmux                 # macOS / Linux，前缀 Ctrl+t
bash scripts/doctor.sh
```

Windows 使用 `pwsh`、`nvim` 和 `./scripts/doctor.ps1`。在 Neovim 中执行 `:LazyHealth` 和 `:checkhealth` 检查编辑器环境；`:Lazy` 和 `:Mason` 可查看插件及语言工具。

Fish 中可以运行 `tide configure` 调整提示符，并在终端设置中选择 Nerd Font 以显示图标。

Fish 不会自动成为账户默认 shell。macOS/Linux 安装完成后，可执行：

```sh
fish_path="$(command -v fish)"
grep -Fxq "$fish_path" /etc/shells || echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
chsh -s "$fish_path"
```

重新打开终端后运行 `echo "$SHELL"` 检查。当前窗口可用 `exec fish` 立即切换；切回 Zsh 可运行 `chsh -s "$(command -v zsh)"`。

默认 Node 由 dotfiles 的锁定版本提供。Fish 中可用 `nvm install <版本>` 和 `nvm use <版本>` 为当前会话切换版本，再用 `nvm use system` 恢复默认 Node。Bash/Zsh 要使用 nvm-sh，可先运行 `unset NPM_CONFIG_PREFIX; export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"`。Windows 的 NVM for Windows 是独立实现；需要使用它切换时，应让 NVM 的 Node 路径在当前会话 PATH 中排在 dotc Node 路径之前。

## Neovim 功能

- 基于 LazyVim：默认 **Solarized Osaka**，使用 vivid 和透明背景；另有 VS Code、Catppuccin、Gruvbox、TokyoNight。
- Rust、Python、TypeScript/JavaScript、JSON、Tailwind、Markdown、TOML、YAML、Docker 的 LazyVim extras；HTML/CSS 使用常规支持。
- Python 使用 LazyVim 的环境选择器，`<leader>cv` 可选择项目虚拟环境；额外搜索 Miniforge 和用户 Conda 环境。
- Rust 工作区为编辑响应速度使用默认 features、当前包检查和独立的 rust-analyzer 构建目录。完整覆盖请在终端或 CI 执行 `cargo check --workspace --all-targets --all-features`；独立构建目录会占用额外磁盘空间。
- Rust 分析会排除 `vendor`、`generated`、`build`、`dist` 等常见生成目录；如项目在这些目录中维护源码，可调整 [`rust.lua`](modules/nvim/lua/plugins/rust.lua)。
- `<leader>fg` 搜索文件内容，`<leader>fG` 搜索 Git 文件；`<leader>tw` 切换自动换行。文件浏览器可用 `Ctrl+h` 切换隐藏文件、`Ctrl+g` 同时切换隐藏和忽略文件、`Y` 复制相对路径。终端模式下 `Shift+Esc` 切换窗口缩放，取决于终端能否区分该按键。
- Jupyter 插件未启用。Neovim >= 0.11.2；首次启动及语言工具安装需要网络、Git、C 编译器、`curl`、`ripgrep` 和 `fd`。

## 更新与可选工具

从仓库目录拉取更新并应用：

```sh
git pull --ff-only
chezmoi --source "$PWD" apply
```

修改锁定版本后，同样执行 `chezmoi apply`。未锁定工具按需更新：

| 工具 | 更新命令 |
| --- | --- |
| uv | `uv self update` |
| Conda | `conda update -n base conda` |
| Neovim | macOS：`brew upgrade neovim`；Debian/Ubuntu：`update-neovim`；Arch：`sudo pacman -Syu neovim`；Windows：`scoop update neovim` |
| Fish 插件 | `fisher update` |
| Neovim 插件 | 在 Neovim 中运行 `:Lazy update` |
| Grok / Claude Code | `grok update` / `claude update` |
| Codex CLI | 重新运行其官方安装程序 |

如需安装 AI CLI，运行 `chezmoi edit-config`，在 `[data]` 中将对应项改为 `true`，再运行 `chezmoi apply`：

```toml
[data]
installGrok = true
installCodex = true
installClaudeCode = true
```

可只打开其中需要的项目；已有 CLI 不会在每次应用时自动升级。使用它们需要各自的账户和登录配置。

## 目录与个人配置

```text
chezmoi/       chezmoi 模板、目标路径和安装钩子
common/        Git、lazygit 和公共命令
config/        锁定工具链版本
modules/       nvim、fish、PowerShell、tmux 配置
platforms/     macOS、Linux、Windows 安装清单和平台设置
scripts/       跨平台安装与检查脚本
```

编辑 `modules/` 或 `common/` 中的实际配置；`chezmoi/` 中的同名模板负责将其部署到各平台的正确路径。新增文件时，需要同时添加对应的部署模板。个人 Git 设置可以放在 `~/.gitconfig.private`；Fish、PowerShell 和 tmux 分别支持 `config-local.fish`、`profile.local.ps1` 和 `tmux-private.conf`，这些文件不由仓库管理。

安装失败时，先处理终端中报告的具体错误，再运行 `chezmoi apply` 重试。Homebrew 中已存在但未由 Homebrew 管理的应用可能产生冲突；处理冲突后重试。Arch 用户应先确保系统包数据库和系统保持同步；AUR 构建需要 Git、base-devel 和网络。

仓库验证可运行 `python3 tests/smoke.py -v`（Windows 使用 `python tests/smoke.py -v`）。测试在临时目录渲染各平台配置并检查旧 Neovim 配置备份，不会向当前账户安装软件。
