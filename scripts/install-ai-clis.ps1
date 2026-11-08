. (Join-Path $PSScriptRoot 'lib/common.ps1')
if ($env:DOTFILES_INSTALL_GROK -eq 'true' -and -not (Get-Command grok -ErrorAction SilentlyContinue)) {
    $env:GROK_BIN_DIR = Join-Path $env:USERPROFILE '.local\bin'
    Invoke-RestMethod https://x.ai/cli/install.ps1 | Invoke-Expression
    if (-not (Get-Command grok -ErrorAction SilentlyContinue)) { throw 'Grok installation failed.' }
}
if ($env:DOTFILES_INSTALL_CODEX -eq 'true' -and -not (Get-Command codex -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod https://chatgpt.com/codex/install.ps1 | Invoke-Expression
    if (-not (Get-Command codex -ErrorAction SilentlyContinue)) { throw 'Codex installation failed.' }
}
if ($env:DOTFILES_INSTALL_CLAUDE -eq 'true' -and -not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { throw 'Claude Code installation failed.' }
}
