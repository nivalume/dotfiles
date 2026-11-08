$env:NPM_CONFIG_PREFIX = Join-Path $env:APPDATA 'npm'
$env:Path = "$env:NPM_CONFIG_PREFIX;$env:LOCALAPPDATA\Programs\nodejs\current;$env:USERPROFILE\.bun\bin;$env:USERPROFILE\.local\bin;$env:USERPROFILE\.cargo\bin;$env:USERPROFILE\miniforge3\condabin;$env:Path"
$env:EDITOR = 'nvim'

foreach ($module in @('PSReadLine', 'posh-git', 'Terminal-Icons', 'PSFzf')) {
    if (Get-Module -ListAvailable -Name $module) { Import-Module $module }
}
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config (Join-Path $PSScriptRoot 'theme.omp.json') | Invoke-Expression
}
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Emacs -BellStyle None -PredictionSource History
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
}
if (Get-Module PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}
if (Get-Command nvim -ErrorAction SilentlyContinue) { Set-Alias vim nvim }
Set-Alias g git
if (Get-Command zoxide -ErrorAction SilentlyContinue) { zoxide init powershell | Out-String | Invoke-Expression }
$condaHook = Join-Path $env:USERPROFILE 'miniforge3\shell\condabin\conda-hook.ps1'
if (Test-Path $condaHook) { . $condaHook }
$localProfile = Join-Path $PSScriptRoot 'profile.local.ps1'
if (Test-Path $localProfile) { . $localProfile }
