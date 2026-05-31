@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: Simple Professional Installer Creator
:: Creates a single .exe installer file
:: ===========================================

:: Configuration
set BUILD_DIR=build_installer
set DIST_DIR=dist
set SCRIPT_DIR=%~dp0
set INNO_SETUP_PATH="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist %INNO_SETUP_PATH% set INNO_SETUP_PATH="C:\Program Files\Inno Setup 6\ISCC.exe"

:: Create directories
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

echo [*] Creating Professional Installer...
echo.

:: Check if Inno Setup is installed
if not exist %INNO_SETUP_PATH% (
    echo [ERROR] Inno Setup not found!
    echo.
    echo Please install Inno Setup from: https://jrsoftware.org/isdl.php
    echo.
    pause
    exit /b 1
)

echo [*] Inno Setup found at %INNO_SETUP_PATH%
echo.

:: Check if the executable exists
if not exist "%DIST_DIR%\PharmacyExpenseTracker.exe" (
    echo [ERROR] PharmacyExpenseTracker.exe not found in dist folder!
    echo.
    echo Please run build_secure.bat first to create the executable.
    echo.
    pause
    exit /b 1
)

echo [*] Found PharmacyExpenseTracker.exe
echo.

:: Copy supporting files if they exist
echo [*] Copying supporting files...
if exist "%SCRIPT_DIR%users.json" copy "%SCRIPT_DIR%users.json" "%DIST_DIR%\" >nul
if exist "%SCRIPT_DIR%data.encrypted" copy "%SCRIPT_DIR%data.encrypted" "%DIST_DIR%\" >nul
if exist "%SCRIPT_DIR%version.json" copy "%SCRIPT_DIR%version.json" "%DIST_DIR%\" >nul
if exist "%SCRIPT_DIR%app_updater.py" copy "%SCRIPT_DIR%app_updater.py" "%DIST_DIR%\" >nul

echo [*] All files ready for installer
echo.

:: Update installer script with current version
set INSTALLER_SCRIPT="%BUILD_DIR%\installer_script.iss"
copy "%SCRIPT_DIR%installer_script.iss" "%INSTALLER_SCRIPT%" >nul

:: Read version from version.json
if exist "%SCRIPT_DIR%version.json" (
    for /f "tokens=2 delims=:," %%a in ('findstr "\"version\"" "%SCRIPT_DIR%version.json"') do (
        set VERSION=%%a
        set VERSION=!VERSION:" =!
        set VERSION=!VERSION:"=!
    )
) else (
    set VERSION=1.0.0
)

echo [*] Version: %VERSION%
echo.

:: Update version in installer script
powershell -Command "(Get-Content '%INSTALLER_SCRIPT%') -replace 'AppVersion=1.0.0', 'AppVersion=%VERSION%' -replace 'AppVerName=Pharmacy Expense Tracker v1.0.0', 'AppVerName=Pharmacy Expense Tracker v%VERSION%' | Set-Content '%INSTALLER_SCRIPT%'"

echo [*] Creating installer with Inno Setup...
echo.

:: Run Inno Setup
%INNO_SETUP_PATH% "%INSTALLER_SCRIPT%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [*] ===========================================
    echo [*] INSTALLER CREATED SUCCESSFULLY!
    echo [*] ===========================================
    echo.
    echo [*] Installer location: %DIST_DIR%\PharmacyExpenseTracker_Setup.exe
    echo [*] Version: %VERSION%
    echo.
    echo [*] You can now distribute this single .exe file to users.
    echo [*] Users just need to double-click it to install.
    echo.
    echo [*] Installation features:
    echo [*] - Professional setup wizard
    echo [*] - Creates desktop shortcut
    echo [*] - Adds to Start Menu
    echo [*] - Includes uninstaller
    echo [*] - Installs to Program Files
    echo.
) else (
    echo.
    echo [ERROR] Installer creation failed!
    echo.
    echo Please check the Inno Setup output above for details.
    echo.
)

pause