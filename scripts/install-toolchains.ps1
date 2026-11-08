. (Join-Path $PSScriptRoot 'lib/common.ps1')
$versions = Get-ToolVersions
$rustVersion = $versions.RUST_VERSION
$nodeVersion = $versions.NODE_VERSION
$tempDir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempDir | Out-Null
try {
    if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
        $installer = Join-Path $tempDir 'rustup-init.exe'
        Invoke-WebRequest 'https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe' -OutFile $installer -UseBasicParsing
        Invoke-Checked $installer @('-y', '--no-modify-path', '--default-toolchain', 'none')
    }
    Invoke-Checked rustup @('toolchain', 'install', $rustVersion, '--profile', 'minimal', '--component', 'rustfmt', '--component', 'clippy', '--component', 'rust-analyzer', '--component', 'rust-src')
    Invoke-Checked rustup @('default', $rustVersion)

    $nodePlatform = 'win-x64'
    $nodeArchive = "node-v$nodeVersion-$nodePlatform.zip"
    $nodeRoot = Join-Path $env:LOCALAPPDATA 'Programs\nodejs'
    $nodeHome = Join-Path $nodeRoot "node-v$nodeVersion-$nodePlatform"
    $nodeCurrent = Join-Path $nodeRoot 'current'
    New-Item -ItemType Directory -Force -Path $nodeRoot | Out-Null
    $nodeExe = Join-Path $nodeHome 'node.exe'
    if (-not (Test-Path $nodeExe) -or (& $nodeExe --version) -ne "v$nodeVersion") {
        $baseUrl = "https://nodejs.org/dist/v$nodeVersion"
        $archivePath = Join-Path $tempDir $nodeArchive
        Invoke-WebRequest "$baseUrl/$nodeArchive" -OutFile $archivePath -UseBasicParsing
        $checksums = Invoke-RestMethod "$baseUrl/SHASUMS256.txt"
        $line = $checksums -split "`n" | Where-Object { $_ -match "\s+$([regex]::Escape($nodeArchive))\s*$" } | Select-Object -First 1
        if (-not $line) { throw "No checksum for $nodeArchive" }
        $expected = ($line.Trim() -split '\s+')[0]
        if ((Get-FileHash $archivePath -Algorithm SHA256).Hash -ine $expected) { throw "Checksum mismatch for $nodeArchive" }
        Expand-Archive -LiteralPath $archivePath -DestinationPath $tempDir
        if (Test-Path $nodeHome) { Remove-Item -LiteralPath $nodeHome -Recurse -Force }
        Move-Item (Join-Path $tempDir "node-v$nodeVersion-$nodePlatform") $nodeHome
    }
    if (Test-Path $nodeCurrent) {
        if (-not ((Get-Item $nodeCurrent).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "$nodeCurrent is not a managed junction; move it aside first." }
        # Remove the junction itself, never its target.
        [IO.Directory]::Delete($nodeCurrent)
    }
    New-Item -ItemType Junction -Path $nodeCurrent -Target $nodeHome | Out-Null
    $npmPrefix = Join-Path $env:APPDATA 'npm'
    Add-UserPath @($npmPrefix, $nodeCurrent, (Join-Path $env:USERPROFILE '.bun\bin'), (Join-Path $env:USERPROFILE '.cargo\bin'))
    [Environment]::SetEnvironmentVariable('NPM_CONFIG_PREFIX', $npmPrefix, 'User')
    $env:NPM_CONFIG_PREFIX = $npmPrefix
    $nodeNpm = Join-Path $nodeCurrent 'npm.cmd'
    $globalNpm = Join-Path $npmPrefix 'npm.cmd'
    if (-not (Test-Path $globalNpm) -or (& $globalNpm --version) -ne $versions.NPM_VERSION) {
        Invoke-Checked $nodeNpm @('install', '--global', '--no-audit', '--no-fund', "npm@$($versions.NPM_VERSION)")
    }
    if (-not (Get-Command pnpm.cmd -ErrorAction SilentlyContinue) -or (& pnpm.cmd --version) -ne $versions.PNPM_VERSION) {
        Invoke-Checked $globalNpm @('install', '--global', '--no-audit', '--no-fund', "pnpm@$($versions.PNPM_VERSION)")
    }
    $npmModules = Join-Path $npmPrefix 'node_modules'
    if (-not (Test-Path "$npmModules\commitizen") -or -not (Test-Path "$npmModules\cz-git")) {
        Invoke-Checked $globalNpm @('install', '--global', '--no-audit', '--no-fund', 'commitizen', 'cz-git')
    }
    $bun = Join-Path $env:USERPROFILE '.bun\bin\bun.exe'
    if (-not (Test-Path $bun) -or (& $bun --version) -ne $versions.BUN_VERSION) {
        $installer = Invoke-RestMethod https://bun.com/install.ps1
        & ([scriptblock]::Create($installer)) -Version $versions.BUN_VERSION
        if (-not (Test-Path $bun) -or (& $bun --version) -ne $versions.BUN_VERSION) { throw 'Pinned Bun installation failed.' }
    }
} finally { Remove-Item -LiteralPath $tempDir -Recurse -Force }
