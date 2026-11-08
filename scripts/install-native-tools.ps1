. (Join-Path $PSScriptRoot 'lib/common.ps1')
$uv = Join-Path $env:USERPROFILE '.local\bin\uv.exe'
if (-not (Test-Path $uv)) {
    $env:UV_INSTALL_DIR = Split-Path $uv
    $env:UV_NO_MODIFY_PATH = '1'
    Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
    if (-not (Test-Path $uv)) { throw 'uv installation did not produce uv.exe.' }
}
$miniforgeHome = Join-Path $env:USERPROFILE 'miniforge3'
$conda = Join-Path $miniforgeHome 'Scripts\conda.exe'
if (-not (Test-Path $conda)) {
    $installer = Join-Path ([IO.Path]::GetTempPath()) (([guid]::NewGuid().ToString()) + '.exe')
    try {
        Invoke-WebRequest 'https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe' -OutFile $installer -UseBasicParsing
        $process = Start-Process -FilePath $installer -ArgumentList @('/InstallationType=JustMe', '/RegisterPython=0', '/S', "/D=$miniforgeHome") -Wait -PassThru
        if ($process.ExitCode -ne 0) { throw "Miniforge installer exited with code $($process.ExitCode)" }
    } finally { Remove-Item -LiteralPath $installer -Force -ErrorAction SilentlyContinue }
}
Invoke-Checked $conda @('config', '--set', 'auto_activate_base', 'false')
Add-UserPath @((Split-Path $uv), (Join-Path $miniforgeHome 'condabin'))
