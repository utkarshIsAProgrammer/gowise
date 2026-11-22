# ==============================================================================
# MINIMAL CLI Launcher (Windows PowerShell)
# ==============================================================================

$env:NVIM_APPNAME = "minimal"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configDir = Resolve-Path "$scriptDir\..\config"

$userConfig = "$env:LOCALAPPDATA\minimal"
if (-not (Test-Path $userConfig)) {
    New-Item -ItemType Junction -Path $userConfig -Target $configDir | Out-Null
}

& nvim.exe @args
