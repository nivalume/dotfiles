# PowerShell 7 profile for Windows. Managed by mise.
# Native Windows exposes USERPROFILE; the shared mise config uses HOME for its
# XDG and Rust paths, so provide the POSIX-compatible alias before activation.
if (-not $env:HOME) {
    $env:HOME = $HOME
}

if (-not $env:XDG_CONFIG_HOME) {
    $env:XDG_CONFIG_HOME = Join-Path $HOME ".config"
}
if (-not $env:XDG_CACHE_HOME) {
    $env:XDG_CACHE_HOME = Join-Path $HOME ".cache"
}
if (-not $env:XDG_DATA_HOME) {
    $env:XDG_DATA_HOME = Join-Path $HOME ".local/share"
}
# Keep mise's tool store on its native Windows path even though applications
# use XDG_DATA_HOME for their own data. Use the same location that bootstrap
# installs into, even if this shell inherited an older MISE_DATA_DIR value.
$env:MISE_DATA_DIR = Join-Path $env:LOCALAPPDATA "mise"
if (-not $env:PAGER) {
    $env:PAGER = "more"
}
if (-not $env:LESS) {
    $env:LESS = "-FRX"
}
if (-not $env:EDITOR) {
    $env:EDITOR = "nvim"
}
if (-not $env:VISUAL) {
    $env:VISUAL = $env:EDITOR
}


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

# Activate mise before starting tools that it manages so their shell hooks load.
if (Get-Command mise -ErrorAction SilentlyContinue) {
    (& mise activate pwsh) | Out-String | Invoke-Expression

    # Resolve Conda through mise directly. Calling the prefix's conda.exe avoids
    # relying on mise's PATH refresh in an already-open shell.
    $condaRoot = & mise where "conda:conda" 2>$null
    if ($condaRoot) {
        $condaRoot = ($condaRoot | Select-Object -First 1).Trim()
        $condaExecutable = Join-Path $condaRoot "Scripts/conda.exe"
        if (Test-Path -LiteralPath $condaExecutable) {
            (& $condaExecutable shell.powershell hook) | Out-String | Invoke-Expression
        }
        Remove-Variable condaRoot, condaExecutable -ErrorAction SilentlyContinue
    }
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
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
