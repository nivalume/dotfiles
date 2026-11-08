$ErrorActionPreference = 'Stop'
foreach ($module in @('posh-git', 'Terminal-Icons', 'PSFzf')) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
    }
}

$profilePath = $PROFILE.CurrentUserAllHosts
$profileDir = Split-Path $profilePath -Parent
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath | Out-Null }
$marker = '# dotc managed profile'
if (-not (Select-String -Path $profilePath -SimpleMatch $marker -Quiet)) {
    Add-Content -Path $profilePath -Value @'

# dotc managed profile
. (Join-Path $HOME '.config/powershell/profile.ps1')
'@
}
