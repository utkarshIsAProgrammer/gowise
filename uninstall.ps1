# ==============================================================================
# Gowise Clean Uninstaller for Windows (PowerShell)
# ==============================================================================

$confirm = Read-Host "Are you sure you want to uninstall Gowise? (y/N)"
if ($confirm -notmatch '^[Yy]$') {
    Write-Host "Uninstallation cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "==> Removing Gowise..." -ForegroundColor Cyan

# 1. Remove Config Junction
$configDir = "$env:LOCALAPPDATA\gowise"
if (Test-Path $configDir) {
    Remove-Item -Path $configDir -Force -Recurse
    Write-Host "✔ Removed $configDir" -ForegroundColor Green
}

# 2. Remove Data and Repo
$repoDir = "$env:LOCALAPPDATA\gowise-repo"
if (Test-Path $repoDir) {
    Remove-Item -Path $repoDir -Force -Recurse
    Write-Host "✔ Removed $repoDir" -ForegroundColor Green
}

$dataDir = "$env:LOCALAPPDATA\gowise-data"
if (Test-Path $dataDir) {
    Remove-Item -Path $dataDir -Force -Recurse
}

# 3. Remove from PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$binDir = "$repoDir\bin"
if ($userPath -like "*$binDir*") {
    $newPath = ($userPath.Split(';') | Where-Object { $_ -ne $binDir }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✔ Removed bin directory from User PATH." -ForegroundColor Green
}

Write-Host "✔ Gowise has been cleanly removed from Windows." -ForegroundColor Green
