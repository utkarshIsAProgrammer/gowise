# ==============================================================================
# Gowise Clean Uninstaller for Windows (PowerShell)
# Safely removes junctions, binaries, data, and Start Menu shortcuts
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$Force
)

if (-not $Force) {
    $confirm = Read-Host "Are you sure you want to completely uninstall Gowise? (y/N)"
    if ($confirm -notmatch '^[Yy]$') {
        Write-Host "Uninstallation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "==> Removing Gowise from Windows..." -ForegroundColor Cyan

# 1. Remove Config Junction
$configDir = "$env:LOCALAPPDATA\gowise"
if (Test-Path $configDir) {
    Remove-Item -Path $configDir -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "✔ Removed $configDir" -ForegroundColor Green
}

# 2. Remove Data and Repo
$repoDir = "$env:LOCALAPPDATA\gowise-repo"
if (Test-Path $repoDir) {
    Remove-Item -Path $repoDir -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "✔ Removed $repoDir" -ForegroundColor Green
}

$dataDir = "$env:LOCALAPPDATA\gowise-data"
if (Test-Path $dataDir) {
    Remove-Item -Path $dataDir -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "✔ Cleaned plugin data" -ForegroundColor Green
}

# 3. Remove Start Menu Shortcut
$programsFolder = [Environment]::GetFolderPath("Programs")
$shortcutPath = "$programsFolder\Gowise.lnk"
if (Test-Path $shortcutPath) {
    Remove-Item -Path $shortcutPath -Force -ErrorAction SilentlyContinue
    Write-Host "✔ Removed Start Menu shortcut" -ForegroundColor Green
}

# 4. Remove from PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$binDir = "$repoDir\bin"
if ($userPath -like "*$binDir*") {
    $newPath = ($userPath.Split(';') | Where-Object { $_ -ne $binDir -and $_ -ne "" }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✔ Removed bin directory from User PATH." -ForegroundColor Green
}

Write-Host ""
Write-Host "✔ Gowise has been cleanly and completely uninstalled from Windows." -ForegroundColor Green
