$ErrorActionPreference = 'Stop'
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'WinGet is required; install or update App Installer first.' }
    winget install --id twpayne.chezmoi --exact --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "chezmoi installation failed with exit code $LASTEXITCODE" }
    $env:Path = "$env:LOCALAPPDATA\Microsoft\WinGet\Links;" + [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) { throw 'chezmoi is not on PATH. Open a new PowerShell window and rerun this script.' }
& chezmoi --source $PSScriptRoot init --apply
if ($LASTEXITCODE -ne 0) { throw "chezmoi apply failed with exit code $LASTEXITCODE" }
