. (Join-Path $PSScriptRoot 'lib/common.ps1')
if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') { throw 'Native Windows setup currently supports x64. Use the Linux setup in WSL for other architectures.' }
& (Join-Path $script:DotfilesRoot 'platforms/windows/install.ps1')
& (Join-Path $PSScriptRoot 'install-toolchains.ps1')
& (Join-Path $PSScriptRoot 'install-native-tools.ps1')
$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
if ($pwsh) { $pwshPath = $pwsh.Source } else { $pwshPath = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe' }
if (-not (Test-Path $pwshPath)) { throw 'PowerShell 7 was not found after installation.' }
Invoke-Checked $pwshPath @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $script:DotfilesRoot 'platforms/windows/configure-shell.ps1'))
& (Join-Path $PSScriptRoot 'install-ai-clis.ps1')
Write-Host '[dotfiles] Setup completed. Open PowerShell 7, then run ./scripts/doctor.ps1.'
