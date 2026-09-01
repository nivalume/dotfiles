# PowerShell 7 profile for Windows. Managed by chezmoi.
function global:proxy {
    $env:HTTP_PROXY = "http://127.0.0.1:1082"
    $env:HTTPS_PROXY = $env:HTTP_PROXY
    $env:ALL_PROXY = "socks5h://127.0.0.1:1082"
    $env:NO_PROXY = "localhost,127.0.0.1,::1,.local"
    $env:http_proxy = $env:HTTP_PROXY
    $env:https_proxy = $env:HTTPS_PROXY
    $env:all_proxy = $env:ALL_PROXY
    $env:no_proxy = $env:NO_PROXY
}

function global:unproxy {
    "HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "NO_PROXY",
    "http_proxy", "https_proxy", "all_proxy", "no_proxy" |
        ForEach-Object { Remove-Item "Env:$_" -ErrorAction SilentlyContinue }
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
if (Get-Command mise -ErrorAction SilentlyContinue) {
    (&mise activate pwsh) | Out-String | Invoke-Expression
}

Set-Alias g git
function global:gs { git status --short --branch @args }
function global:gd { git diff @args }
