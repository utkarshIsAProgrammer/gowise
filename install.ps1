# ==============================================================================
# Gowise Universal Installer for Windows (PowerShell)
# Handles all permissions, PATH registration, and dependency checks
# ==============================================================================

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Write-Banner {
    Write-Host ""
    Write-Host "   ██████╗  ██████╗ ██╗    ██╗██╗███████╗███████╗" -ForegroundColor Cyan
    Write-Host "  ██╔════╝ ██╔═══██╗██║    ██║██║██╔════╝██╔════╝" -ForegroundColor Cyan
    Write-Host "  ██║  ███╗██║   ██║██║ █╗ ██║██║███████╗█████╗  " -ForegroundColor Cyan
    Write-Host "  ██║   ██║██║   ██║██║███╗██║██║╚════██║██╔══╝  " -ForegroundColor Cyan
    Write-Host "  ╚██████╔╝╚██████╔╝╚███╔███╔╝██║███████║███████╗" -ForegroundColor Cyan
    Write-Host "   ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝╚══════╝╚══════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  The Fluent, Modeless Terminal Code Editor for Windows" -ForegroundColor White
    Write-Host ""
}

Write-Banner

# 1. Check Dependencies
Write-Host "==> Checking dependencies..." -ForegroundColor Cyan

# Check Git
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-Host "✖ Git is required to download and maintain Gowise." -ForegroundColor Red
    Write-Host "  Please install Git using winget:" -ForegroundColor Yellow
    Write-Host "    winget install --id Git.Git -e --source winget" -ForegroundColor White
    exit 1
}
Write-Host "✔ Git is available." -ForegroundColor Green

# Check Neovim
$nvimCmd = Get-Command nvim -ErrorAction SilentlyContinue
if (-not $nvimCmd) {
    Write-Host "▲ Neovim (v0.10+) was not found on your system." -ForegroundColor Yellow
    Write-Host "  You can easily install Neovim using winget:" -ForegroundColor Cyan
    Write-Host "    winget install --id Neovim.Neovim -e" -ForegroundColor White
    Write-Host "  Continuing installation... Install Neovim before launching 'gowise'." -ForegroundColor Yellow
} else {
    $nvimVer = & nvim --version | Select-Object -First 1
    Write-Host "✔ Neovim is available ($nvimVer)." -ForegroundColor Green
}

# 2. Setup Paths
$installDir = "$env:LOCALAPPDATA\gowise-repo"
$configDir  = "$env:LOCALAPPDATA\gowise"
$binDir     = "$installDir\bin"

# 3. Clone or Update
Write-Host "==> Syncing Gowise files..." -ForegroundColor Cyan
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (Test-Path "$scriptDir\config\init.lua") {
    Write-Host "  Installing from local folder..." -ForegroundColor Gray
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
    Copy-Item -Path "$scriptDir\*" -Destination $installDir -Recurse -Force
} else {
    $repoUrl = "https://github.com/utkarshIsAProgrammer/gowise.git"
    if (Test-Path "$installDir\.git") {
        Write-Host "  Updating existing installation..." -ForegroundColor Gray
        git -C $installDir pull --quiet
    } else {
        Write-Host "  Cloning repository..." -ForegroundColor Gray
        git clone --depth 1 $repoUrl $installDir --quiet
    }
}
Write-Host "✔ Files synced to $installDir." -ForegroundColor Green

# 4. Link Config
Write-Host "==> Setting up isolated config..." -ForegroundColor Cyan
if (Test-Path $configDir) {
    $isJunction = (Get-Item $configDir).Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)
    if (-not $isJunction) {
        $backupDir = "$configDir.backup." + (Get-Date -Format "yyyyMMddHHmmss")
        Write-Host "  Backing up existing config to $backupDir" -ForegroundColor Yellow
        Rename-Item -Path $configDir -NewName $backupDir
    } else {
        Remove-Item $configDir -Force
    }
}
New-Item -ItemType Junction -Path $configDir -Target "$installDir\config" | Out-Null
Write-Host "✔ Linked $configDir -> $installDir\config" -ForegroundColor Green

# 5. Add to User PATH
Write-Host "==> Registering 'gowise' command..." -ForegroundColor Cyan
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
    $env:Path += ";$binDir"
    Write-Host "✔ Added $binDir to User PATH." -ForegroundColor Green
} else {
    Write-Host "✔ 'gowise' is already in your PATH." -ForegroundColor Green
}

# 6. Preheat if nvim exists
if ($nvimCmd) {
    Write-Host "==> Preheating plugins for instant startup..." -ForegroundColor Cyan
    $env:NVIM_APPNAME = "gowise"
    Start-Process -FilePath "nvim" -ArgumentList "--headless", "+Lazy! sync", "+qa" -NoNewWindow -Wait -ErrorAction SilentlyContinue
    Write-Host "✔ Startup latency pre-warmed." -ForegroundColor Green
}

# 7. Success Banner
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✔ Gowise installed successfully on Windows!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host "  To launch the editor, open a new terminal and type:" -ForegroundColor White
Write-Host "    gowise .                    # Open current workspace" -ForegroundColor Cyan
Write-Host "    gowise path\to\file.ts       # Open or create file" -ForegroundColor Cyan
Write-Host "    gowise --doctor             # Check system health" -ForegroundColor Cyan
Write-Host ""
