$ErrorActionPreference = 'Stop'
$script:DotfilesRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$env:Path = "$env:APPDATA\npm;$env:LOCALAPPDATA\Programs\nodejs\current;$env:USERPROFILE\.bun\bin;$env:USERPROFILE\.local\bin;$env:USERPROFILE\.cargo\bin;$env:USERPROFILE\miniforge3\condabin;$env:USERPROFILE\scoop\shims;$env:Path"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    $global:LASTEXITCODE = 0
    & $Command @Arguments
    if (-not $?) { throw "$Command failed." }
    if ($LASTEXITCODE -ne 0) { throw "$Command failed with exit code $LASTEXITCODE" }
}

function Get-ToolVersions {
    $versions = @{}
    Get-Content (Join-Path $script:DotfilesRoot 'config/versions.env') | ForEach-Object {
        if ($_ -match '^([A-Z_]+)=([0-9]+\.[0-9]+\.[0-9]+)$') { $versions[$matches[1]] = $matches[2] }
    }
    foreach ($key in @('RUST_VERSION', 'NODE_VERSION', 'NPM_VERSION', 'PNPM_VERSION', 'BUN_VERSION')) {
        if (-not $versions.ContainsKey($key)) { throw "Missing or invalid $key in config/versions.env" }
    }
    return $versions
}

function Add-UserPath {
    param([string[]]$Paths)
    $old = @([Environment]::GetEnvironmentVariable('Path', 'User') -split ';' | Where-Object { $_ })
    $items = @($Paths)
    foreach ($entry in $old) {
        if (-not ($items | Where-Object { $_.TrimEnd('\') -ieq $entry.TrimEnd('\') })) { $items += $entry }
    }
    [Environment]::SetEnvironmentVariable('Path', ($items -join ';'), 'User')
    $env:Path = ($Paths -join ';') + ';' + $env:Path
}
