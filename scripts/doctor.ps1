. (Join-Path $PSScriptRoot 'lib/common.ps1')
$versions = Get-ToolVersions
$failed = $false
foreach ($name in @('git', 'nvim', 'gh', 'ghq', 'lazygit', 'delta', 'zoxide', 'just', 'fzf', 'rg', 'fd', 'uv', 'conda', 'rustup')) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if ($command) { Write-Host ("{0,-16} {1}" -f $name, $command.Source) }
    else { Write-Warning "$name is missing"; $failed = $true }
}
foreach ($pair in @(@('node', 'NODE_VERSION'), @('npm.cmd', 'NPM_VERSION'), @('pnpm.cmd', 'PNPM_VERSION'), @('bun', 'BUN_VERSION'))) {
    $command = Get-Command $pair[0] -ErrorAction SilentlyContinue
    if (-not $command) { Write-Warning "$($pair[0]) is missing"; $failed = $true; continue }
    $actual = (& $command.Source --version | Select-Object -First 1).TrimStart('v')
    Write-Host ("{0,-16} {1} (expected {2})" -f $pair[0], $actual, $versions[$pair[1]])
    if ($actual -ne $versions[$pair[1]]) { $failed = $true }
}
if (Get-Command rustup -ErrorAction SilentlyContinue) {
    & rustup run $versions.RUST_VERSION rustc --version
    if ($LASTEXITCODE -ne 0) { $failed = $true }
}
if ($failed) { exit 1 }
