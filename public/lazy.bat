@echo off
REM LazyCLI Windows Batch Wrapper
REM This script provides basic LazyCLI functionality for Windows Command Prompt

setlocal enabledelayedexpansion

REM Check if PowerShell is available
powershell.exe -Command "exit 0" >nul 2>&1
if errorlevel 1 (
    echo ❌ PowerShell is required but not available.
    echo Please install PowerShell or use Git Bash instead.
    exit /b 1
)

REM Set LazyCLI directory
set "LAZYCLI_DIR=%USERPROFILE%\.lazycli"

REM Check if LazyCLI is installed
if not exist "%LAZYCLI_DIR%\lazy.ps1" (
    echo ❌ LazyCLI not found. Please install first:
    echo.
    echo In PowerShell, run:
    echo   iwr -useb https://lazycli.xyz/install.ps1 ^| iex
    echo.
    echo Or download manually:
    echo   https://lazycli.xyz/install.ps1
    exit /b 1
)

REM Execute the PowerShell script with all arguments
powershell.exe -ExecutionPolicy Bypass -File "\"%LAZYCLI_DIR%\lazy.ps1\"" %*