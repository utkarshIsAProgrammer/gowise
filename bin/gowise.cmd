@echo off
rem ==============================================================================
rem GOWISE CLI Launcher (Windows Command Prompt)
rem ==============================================================================

set "NVIM_APPNAME=gowise"
set "SCRIPT_DIR=%~dp0"
set "CONFIG_DIR=%SCRIPT_DIR%..\config"

rem Link Windows LocalAppData config if not present
if not exist "%LOCALAPPDATA%\gowise" (
    mklink /J "%LOCALAPPDATA%\gowise" "%CONFIG_DIR%" >nul 2>&1
)

nvim.exe %*
