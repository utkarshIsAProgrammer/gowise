# ==============================================================================
# Minimal Universal Zero-Setup Installer for Windows (PowerShell)
# Handles all permissions, PATH registration, dependency auto-provisioning,
# and Start Menu application integration
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$Clean,
    [switch]$Force
)

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

# 1. Dependency Checks & Auto-Provisioning
Write-Host "==> Checking and provisioning dependencies..." -ForegroundColor Cyan

# Check Git
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-Host "▲ Git was not found. Attempting automatic installation via winget..." -ForegroundColor Yellow
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetCmd) {
        try {
            winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        } catch {
            Write-Host "✖ Could not automatically install Git." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✖ Git is required. Please install Git from https://git-scm.com and rerun." -ForegroundColor Red
        exit 1
    }
}
Write-Host "✔ Git is available." -ForegroundColor Green

# Check Neovim (v0.10+ required)
$nvimCmd = Get-Command nvim -ErrorAction SilentlyContinue
if (-not $nvimCmd) {
    Write-Host "▲ Neovim was not found. Attempting automatic installation..." -ForegroundColor Yellow
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetCmd) {
        try {
            Write-Host "  Installing Neovim via winget..." -ForegroundColor Cyan
            winget install --id Neovim.Neovim -e --accept-source-agreements --accept-package-agreements
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        } catch {
            Write-Host "▲ Winget install failed, falling back to portable download..." -ForegroundColor Yellow
        }
    }
    
    # Standalone portable fallback if still missing
    $nvimCmd = Get-Command nvim -ErrorAction SilentlyContinue
    if (-not $nvimCmd) {
        $nvimZipDir = "$env:LOCALAPPDATA\minimal-nvim"
        Write-Host "  Downloading portable Neovim runtime to $nvimZipDir..." -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $nvimZipDir -Force | Out-Null
        $zipFile = "$env:TEMP\nvim-win64.zip"
        Invoke-WebRequest -Uri "https://github.com/neovim/neovim/releases/latest/download/nvim-win64.zip" -OutFile $zipFile
        Expand-Archive -Path $zipFile -DestinationPath $nvimZipDir -Force
        Remove-Item $zipFile -Force
        
        $portableBin = "$nvimZipDir\nvim-win64\bin"
        if (Test-Path "$portableBin\nvim.exe") {
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$portableBin", "User")
            $env:Path += ";$portableBin"
        }
    }
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $nvimVer = & nvim --version | Select-Object -First 1
    Write-Host "✔ Neovim engine is active ($nvimVer)." -ForegroundColor Green
} else {
    Write-Host "✖ Neovim could not be installed. Please install Neovim from https://neovim.io" -ForegroundColor Red
    exit 1
}

# 2. Setup Paths
$installDir = "$env:LOCALAPPDATA\minimal-repo"
$configDir  = "$env:LOCALAPPDATA\minimal"
$dataDir    = "$env:LOCALAPPDATA\minimal-data"
$binDir     = "$installDir\bin"

if ($Clean) {
    Write-Host "==> Clean install requested: Purging old runtime files..." -ForegroundColor Yellow
    if (Test-Path $configDir)  { Remove-Item -Path $configDir -Force -Recurse -ErrorAction SilentlyContinue }
    if (Test-Path $installDir) { Remove-Item -Path $installDir -Force -Recurse -ErrorAction SilentlyContinue }
    if (Test-Path $dataDir)    { Remove-Item -Path $dataDir -Force -Recurse -ErrorAction SilentlyContinue }
}

# 3. Clone or Copy Repository
Write-Host "==> Syncing Minimal files..." -ForegroundColor Cyan
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (Test-Path "$scriptDir\config\init.lua") {
    Write-Host "  Installing from local workspace: $scriptDir" -ForegroundColor Gray
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
    Copy-Item -Path "$scriptDir\*" -Destination $installDir -Recurse -Force
} else {
    $repoUrl = "https://github.com/utkarshIsAProgrammer/minimal.git"
    $fallbackUrl = "https://github.com/utkarshIsAProgrammer/gowise.git"
    if (Test-Path "$installDir\.git") {
        Write-Host "  Updating existing installation..." -ForegroundColor Gray
        git -C $installDir pull --quiet
    } else {
        Write-Host "  Cloning repository from GitHub..." -ForegroundColor Gray
        try {
            git clone --depth 1 $repoUrl $installDir --quiet
        } catch {
            git clone --depth 1 $fallbackUrl $installDir --quiet
        }
    }
}
Write-Host "✔ Files synced to $installDir." -ForegroundColor Green

# 4. Link Isolated Configuration (Directory Junction)
Write-Host "==> Configuring isolated environment..." -ForegroundColor Cyan
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
Write-Host "==> Registering 'minimal' command..." -ForegroundColor Cyan
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
    $env:Path += ";$binDir"
    Write-Host "✔ Added $binDir to User PATH." -ForegroundColor Green
} else {
    Write-Host "✔ 'minimal' is already in your PATH." -ForegroundColor Green
}

# 6. Windows Start Menu Shortcut Integration
Write-Host "==> Registering Windows Start Menu shortcut..." -ForegroundColor Cyan
try {
    $wshShell = New-Object -ComObject WScript.Shell
    $programsFolder = [Environment]::GetFolderPath("Programs")
    $shortcutPath = "$programsFolder\Minimal.lnk"
    $shortcut = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$binDir\minimal.cmd"
    $shortcut.WorkingDirectory = [Environment]::GetFolderPath("UserProfile")
    $shortcut.Description = "Minimal - The Fluent, Modeless Terminal Code Editor"
    $shortcut.Save()
    Write-Host "✔ Created Start Menu shortcut: Minimal" -ForegroundColor Green
} catch {
    Write-Host "▲ Could not create Start Menu shortcut (optional)." -ForegroundColor Gray
}

# 7. Preheat Lazy plugins
Write-Host "==> Pre-compiling plugin cache..." -ForegroundColor Cyan
$lazyDir = "$dataDir\lazy\lazy.nvim"
if (-not (Test-Path $lazyDir)) {
    git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git $lazyDir --quiet
}
$env:NVIM_APPNAME = "minimal"
& nvim --headless "+Lazy! sync" +qa 2>$null
Write-Host "✔ Preheat complete. Startup optimized." -ForegroundColor Green

# 8. Friendly Finish Summary
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✔ Minimal installed successfully and ready to use!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host "  To launch the editor, run:" -ForegroundColor White
Write-Host "    minimal .                    # Open current folder / project" -ForegroundColor Cyan
Write-Host "    minimal src\main.go          # Open or create a file" -ForegroundColor Cyan
Write-Host "    minimal --doctor             # Check system health" -ForegroundColor Cyan
Write-Host "    minimal --benchmark          # Measure cold startup latency" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Or search for 'Minimal' in the Windows Start Menu!" -ForegroundColor Yellow
Write-Host ""
