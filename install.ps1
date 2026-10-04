<#
.SYNOPSIS
  Dotfiles manager for Windows (no mise required).
.DESCRIPTION
  .\install.ps1 apply      link or copy everything listed in links.tsv
  .\install.ps1 status     show the state of every entry
  .\install.ps1 adopt      copy drifted machine files back into the repo
  .\install.ps1 packages   install Scoop packages, npm globals, Rust, VS Code extensions
  .\install.ps1 all        packages, then apply
  Add -Force to back up conflicting files (name.bak-YYYYMMDD) and replace them.
  Files are symlinked when Windows allows it (Developer Mode or admin). Otherwise
  they are copied, and 'status' reports drift so 'adopt' or 'apply' can resync.
  Directories always use junctions, which need no special permission.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('apply', 'status', 'adopt', 'packages', 'all', 'help')]
    [string]$Command = 'help',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
# If the checkout is reached through a junction (for example ~/.dotfiles), use the real path so link targets compare equal.
$rootItem = Get-Item -LiteralPath $Root -Force
if ($rootItem.LinkType -and $rootItem.Target) { $Root = [string]@($rootItem.Target)[0] }
$Src = Join-Path $Root 'dotfiles'
$UserHome = [Environment]::GetFolderPath('UserProfile')
$Stamp = Get-Date -Format 'yyyyMMdd'

function Expand-Target([string]$Path) {
    $Path = $Path.Replace('{APPDATA}', $env:APPDATA).Replace('{LOCALAPPDATA}', $env:LOCALAPPDATA)
    if ($Path.StartsWith('~')) { $Path = $UserHome + $Path.Substring(1) }
    return [IO.Path]::GetFullPath($Path.Replace('/', '\'))
}

function Get-Links {
    Get-Content -LiteralPath (Join-Path $Root 'links.tsv') | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object {
        $parts = $_ -split "`t"
        if ($parts[0] -eq 'all' -or $parts[0] -eq 'windows') {
            [pscustomobject]@{
                Source = [IO.Path]::GetFullPath((Join-Path $Src $parts[1].Replace('/', '\')))
                Target = Expand-Target $parts[2]
            }
        }
    }
}

$script:CanSymlink = $null
function Test-CanSymlink {
    if ($null -ne $script:CanSymlink) { return $script:CanSymlink }
    $dir = Join-Path $env:TEMP ('dotlink-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $dir | Out-Null
    try {
        Set-Content -LiteralPath (Join-Path $dir 'a') -Value 'x'
        New-Item -ItemType SymbolicLink -Path (Join-Path $dir 'b') -Target (Join-Path $dir 'a') -ErrorAction Stop | Out-Null
        $script:CanSymlink = $true
    } catch {
        $script:CanSymlink = $false
    } finally {
        Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
    }
    return $script:CanSymlink
}

function Get-LinkTarget($Item) {
    $t = @($Item.Target)[0]
    if (-not $t) { return $null }
    return ([string]$t).TrimStart('\', '?')
}

function Get-State($Link) {
    $item = Get-Item -LiteralPath $Link.Target -Force -ErrorAction SilentlyContinue
    if (-not $item) { return 'missing' }
    $isLink = $item.LinkType -eq 'SymbolicLink' -or $item.LinkType -eq 'Junction'
    if (Test-Path -LiteralPath $Link.Source -PathType Container) {
        if ($isLink -and (Get-LinkTarget $item) -ieq $Link.Source) { return 'linked' }
        return 'conflict'
    }
    if ($item.LinkType -eq 'SymbolicLink') {
        if ((Get-LinkTarget $item) -ieq $Link.Source) { return 'linked' }
        return 'conflict'
    }
    if ($item.PSIsContainer) { return 'conflict' }
    if ((Get-FileHash -LiteralPath $Link.Target).Hash -eq (Get-FileHash -LiteralPath $Link.Source).Hash) { return 'copy' }
    return 'drift'
}

function Install-Item($Link) {
    $parent = Split-Path -Parent $Link.Target
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    if (Test-Path -LiteralPath $Link.Source -PathType Container) {
        New-Item -ItemType Junction -Path $Link.Target -Target $Link.Source | Out-Null
    } elseif (Test-CanSymlink) {
        New-Item -ItemType SymbolicLink -Path $Link.Target -Target $Link.Source | Out-Null
    } else {
        Copy-Item -LiteralPath $Link.Source -Destination $Link.Target
    }
}

function Remove-Entry([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -eq 'Junction' -or ($item.PSIsContainer -and $item.LinkType -eq 'SymbolicLink')) {
        $item.Delete()
    } else {
        Remove-Item -LiteralPath $Path -Force -Recurse
    }
}

function Invoke-Status {
    foreach ($l in Get-Links) { '{0,-9} {1}' -f (Get-State $l), $l.Target }
    if (-not (Test-CanSymlink)) {
        Write-Host "`nSymlinks are unavailable, so files are copies. Turn on Developer Mode for real symlinks." -ForegroundColor Yellow
    }
}

function Invoke-Apply {
    foreach ($l in Get-Links) {
        $state = Get-State $l
        switch ($state) {
            'linked' { '{0,-9} {1}' -f 'ok', $l.Target }
            'missing' { Install-Item $l; '{0,-9} {1}' -f 'created', $l.Target }
            'copy' {
                if (Test-CanSymlink) { Remove-Entry $l.Target; Install-Item $l; '{0,-9} {1}' -f 'relinked', $l.Target }
                else { '{0,-9} {1}' -f 'ok', $l.Target }
            }
            default {
                if ($Force) {
                    $bak = "$($l.Target).bak-$Stamp"
                    Move-Item -LiteralPath $l.Target -Destination $bak -Force
                    Install-Item $l
                    '{0,-9} {1} (backup: {2})' -f 'replaced', $l.Target, $bak
                } else {
                    Write-Warning "$state $($l.Target): differs from the repo. Use 'adopt' to keep the machine copy, or -Force to overwrite it (a backup is kept)."
                }
            }
        }
    }
    if (-not (Test-CanSymlink)) {
        Write-Host "`nSymlinks are unavailable, so files were copied. After editing a live file run '.\install.ps1 adopt'." -ForegroundColor Yellow
    }
}

function Invoke-Adopt {
    foreach ($l in Get-Links) {
        if ((Get-State $l) -eq 'drift') {
            Copy-Item -LiteralPath $l.Target -Destination $l.Source -Force
            '{0,-9} {1}' -f 'adopted', $l.Target
        }
    }
}

function Get-List([string]$File) {
    Get-Content -LiteralPath (Join-Path $Root "packages\$File") | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
}

function Invoke-Packages {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        throw "Scoop is missing. Install it first: https://scoop.sh"
    }
    $buckets = @(scoop bucket list | ForEach-Object { $_.Name })
    $have = @(scoop list | ForEach-Object { $_.Name })
    foreach ($line in Get-List 'scoop.txt') {
        if ($line -like 'bucket *') {
            $b = $line.Substring(7).Trim()
            if ($buckets -notcontains $b) { scoop bucket add $b }
            continue
        }
        $name = $line.Split('/')[-1]
        if ($have -contains $name) { '{0,-9} {1}' -f 'ok', $line } else { scoop install $line }
    }

    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ((Get-Command rustup -ErrorAction SilentlyContinue) -and -not ((rustup toolchain list 2>$null) -match '\w')) {
        rustup default stable
    }
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        npm install -g @(Get-List 'npm-globals.txt')
    } else {
        Write-Warning 'npm not found; skipping npm globals.'
    }
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $installed = @(code --list-extensions)
        foreach ($ext in Get-List 'vscode-extensions.txt') {
            if ($installed -notcontains $ext) { code --install-extension $ext }
        }
    }
}

switch ($Command) {
    'status' { Invoke-Status }
    'apply' { Invoke-Apply }
    'adopt' { Invoke-Adopt }
    'packages' { Invoke-Packages }
    'all' { Invoke-Packages; Invoke-Apply }
    default { Get-Help $PSCommandPath }
}
