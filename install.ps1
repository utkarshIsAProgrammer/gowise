# ==============================================================================
# Gowise Installer (Windows PowerShell)
# ==============================================================================

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$binPath = "$scriptDir\bin"
$configDir = "$scriptDir\config"

Write-Host "==> Installing Gowise Code Editor on Windows..." -ForegroundColor Cyan

# Link config to %LOCALAPPDATA%\gowise
$userConfig = "$env:LOCALAPPDATA\gowise"
if (-not (Test-Path $userConfig)) {
    New-Item -ItemType Junction -Path $userConfig -Target $configDir | Out-Null
}

# Add bin directory to User PATH if not already present
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$binPath", "User")
    Write-Host "✔ Added $binPath to User PATH." -ForegroundColor Green
}

Write-Host "✔ Gowise installed successfully! You can now run 'gowise' from any terminal." -ForegroundColor Green
