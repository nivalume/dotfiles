# PowerShell 7 profile for Windows. Managed by ~/.dotfiles (see install.ps1).
[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# POSIX-style variables so tools that read HOME / XDG_* agree with the Unix setup.
if (-not $env:HOME) { $env:HOME = $HOME }
if (-not $env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME = Join-Path $HOME ".config" }
if (-not $env:XDG_CACHE_HOME) { $env:XDG_CACHE_HOME = Join-Path $HOME ".cache" }
if (-not $env:XDG_DATA_HOME) { $env:XDG_DATA_HOME = Join-Path $HOME ".local/share" }
if (-not $env:PAGER) { $env:PAGER = Join-Path $env:ProgramFiles "Git\usr\bin\less.exe" }
if (-not $env:LESS) { $env:LESS = "-FRX" }
if (-not $env:EDITOR) { $env:EDITOR = "nvim" }
if (-not $env:VISUAL) { $env:VISUAL = $env:EDITOR }

# Machine-local secrets: KEY=VALUE lines in ~/.config/dotfiles/local.env (never committed).
$localEnv = Join-Path $env:XDG_CONFIG_HOME "dotfiles/local.env"
if (Test-Path -LiteralPath $localEnv) {
    foreach ($line in Get-Content -LiteralPath $localEnv) {
        if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$') {
            Set-Item -Path "Env:$($Matches[1])" -Value $Matches[2].Trim('"', "'")
        }
    }
}
Remove-Variable localEnv, line -ErrorAction SilentlyContinue

function global:proxy {
    param([string]$Port = "10808")
    $env:HTTP_PROXY = "http://127.0.0.1:$Port"
    $env:HTTPS_PROXY = $env:HTTP_PROXY
    $env:ALL_PROXY = $env:HTTP_PROXY
    $env:NO_PROXY = "localhost,127.0.0.1,::1,.local"
    $env:http_proxy = $env:HTTP_PROXY
    $env:https_proxy = $env:HTTPS_PROXY
    $env:all_proxy = $env:ALL_PROXY
    $env:no_proxy = $env:NO_PROXY
}

function global:setproxy {
    param([string]$Port = "10808")
    proxy -Port $Port
}

function global:unproxy {
    "HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "NO_PROXY",
    "http_proxy", "https_proxy", "all_proxy", "no_proxy" |
        ForEach-Object { Remove-Item "Env:$_" -ErrorAction SilentlyContinue }
}

# Conda: load the shell hook lazily on first use to keep startup fast.
function global:conda {
    Remove-Item Function:\conda -ErrorAction SilentlyContinue
    $condaExe = Join-Path $env:USERPROFILE "scoop\apps\miniconda3\current\Scripts\conda.exe"
    if (-not (Test-Path -LiteralPath $condaExe)) {
        $condaExe = (Get-Command conda.exe -ErrorAction SilentlyContinue | Select-Object -First 1).Source
    }
    if (-not $condaExe) { Write-Error "conda was not found (scoop install extras/miniconda3)"; return }
    (& $condaExe shell.powershell hook) | Out-String | Invoke-Expression
    conda @args
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Command Set-PSReadLineKeyHandler -ErrorAction SilentlyContinue)) {
    Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        $historyPath = (Get-PSReadLineOption).HistorySavePath
        if (Test-Path -LiteralPath $historyPath) {
            $selection = Get-Content -LiteralPath $historyPath |
                fzf --tac --no-sort --query $line
            if ($selection) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $selection)
            }
        }
    }
}

Set-Alias g git
function global:gs { git status --short --branch @args }
function global:gd { git diff @args }
Remove-Item Alias:gl -Force -ErrorAction SilentlyContinue
function global:gl { git log --oneline --decorate --graph -20 @args }

if (Get-Command eza -ErrorAction SilentlyContinue) {
    function global:l { eza --icons=auto --group-directories-first @args }
    function global:ll { eza -lah --icons=auto --group-directories-first @args }
    function global:lt { eza --tree --icons=auto --group-directories-first @args }
} else {
    function global:l { Get-ChildItem @args }
    function global:ll { Get-ChildItem -Force @args }
    function global:lt { tree /F @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    function global:bt { bat @args }
}

function global:.. { Set-Location .. }
function global:... { Set-Location ../.. }

# Prompt last: starship (Catppuccin Powerline preset).
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
