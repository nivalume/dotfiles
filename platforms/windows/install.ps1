. (Join-Path $PSScriptRoot '../../scripts/lib/common.ps1')

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'WinGet is required. Install or update App Installer from the Microsoft Store.'
}
Invoke-Checked winget @('import', '--import-file', (Join-Path $PSScriptRoot 'winget.json'), '--accept-package-agreements', '--accept-source-agreements', '--no-upgrade')

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
}
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) { throw 'Scoop installation failed.' }
Invoke-Checked scoop @('import', (Join-Path $PSScriptRoot 'scoop.json'))

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$components = @('Microsoft.VisualStudio.Component.VC.Tools.x86.x64', 'Microsoft.VisualStudio.Component.Windows11SDK.26100')
$matching = if (Test-Path $vswhere) { & $vswhere -products '*' -requires @components -property installationPath } else { $null }
if (-not $matching) {
    $buildTools = if (Test-Path $vswhere) { & $vswhere -products Microsoft.VisualStudio.Product.BuildTools -property installationPath } else { $null }
    $config = Join-Path $PSScriptRoot 'build-tools.vsconfig'
    if ($buildTools) {
        $installer = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\setup.exe'
        $arguments = @('modify', '--installPath', "`"$($buildTools | Select-Object -First 1)`"", '--config', "`"$config`"", '--passive', '--norestart', '--wait')
        $result = Start-Process -FilePath $installer -ArgumentList $arguments -Wait -PassThru
        if ($result.ExitCode -ne 0) { throw "Visual Studio Build Tools modification exited with $($result.ExitCode). Restart Windows if requested, then rerun setup." }
    } else {
        $override = "--passive --norestart --wait --config `"$config`""
        Invoke-Checked winget @('install', '--id', 'Microsoft.VisualStudio.BuildTools', '--exact', '--source', 'winget', '--accept-package-agreements', '--accept-source-agreements', '--override', $override)
    }
}
