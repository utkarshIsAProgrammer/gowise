# ==============================================================================
# GOWISE CLI Launcher (Windows PowerShell)
# ==============================================================================

$env:NVIM_APPNAME = "gowise"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configDir = Resolve-Path "$scriptDir\..\config"

$userConfig = "$env:LOCALAPPDATA\gowise"
if (-not (Test-Path $userConfig)) {
    New-Item -ItemType Junction -Path $userConfig -Target $configDir | Out-Null
}

& nvim.exe @args
