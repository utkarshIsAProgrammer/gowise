@echo off
rem ==============================================================================
rem MINIMAL CLI Launcher (Windows Command Prompt)
rem ==============================================================================

set "NVIM_APPNAME=minimal"
set "SCRIPT_DIR=%~dp0"
set "CONFIG_DIR=%SCRIPT_DIR%..\config"

rem Link Windows LocalAppData config if not present
if not exist "%LOCALAPPDATA%\minimal" (
    mklink /J "%LOCALAPPDATA%\minimal" "%CONFIG_DIR%" >nul 2>&1
)

nvim.exe %*
