@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: Create Professional Installer using PowerShell
:: Creates a self-extracting installer without Inno Setup
:: ===========================================

echo [*] Creating Professional Installer (PowerShell Method)
echo.

:: Configuration
set DIST_DIR=%~dp0dist
set INSTALLER_DIR=%~dp0installer_files
set VERSION=1.0.0

:: Create directories
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"
if not exist "%INSTALLER_DIR%" mkdir "%INSTALLER_DIR%"

:: Read version from version.json if exists
if exist "%~dp0version.json" (
    for /f "tokens=2 delims=:," %%a in ('findstr "\"version\"" "%~dp0version.json"') do (
        set VERSION=%%a
        set VERSION=!VERSION:" =!
        set VERSION=!VERSION:"=!
    )
)

echo [*] Version: %VERSION%
echo.

:: Check if main executable exists
if not exist "%DIST_DIR%\PharmacyExpenseTracker.exe" (
    echo [ERROR] PharmacyExpenseTracker.exe not found!
    echo Please run build_secure.bat first to create the executable.
    pause
    exit /b 1
)

echo [*] Found PharmacyExpenseTracker.exe
echo.

:: Copy files to installer directory
echo [*] Copying files to installer directory...
copy "%DIST_DIR%\PharmacyExpenseTracker.exe" "%INSTALLER_DIR%\" >nul
if exist "%~dp0users.json" copy "%~dp0users.json" "%INSTALLER_DIR%\" >nul
if exist "%~dp0data.encrypted" copy "%~dp0data.encrypted" "%INSTALLER_DIR%\" >nul
if exist "%~dp0version.json" copy "%~dp0version.json" "%INSTALLER_DIR%\" >nul
if exist "%~dp0app_updater.py" copy "%~dp0app_updater.py" "%INSTALLER_DIR%\" >nul

echo [*] Files copied successfully
echo.

:: Create PowerShell installer script
echo [*] Creating installer script...

(
echo # Pharmacy Expense Tracker - Professional Installer
echo $ErrorActionPreference = "Stop"
echo.
echo $ProgressPreference = "SilentlyContinue"
echo.
echo Write-Host "========================================" -ForegroundColor Cyan
echo Write-Host "Pharmacy Expense Tracker - Installer" -ForegroundColor Cyan
echo Write-Host "========================================" -ForegroundColor Cyan
echo Write-Host ""
echo.
echo # Read current script location
echo $ScriptPath = $PSScriptRoot
echo $InstallerFiles = Join-Path $ScriptPath "installer_files"
echo $TargetDir = Join-Path $env:ProgramFiles "PharmacyExpenseTracker"
echo.
echo Write-Host "Installing to: $TargetDir" -ForegroundColor Yellow
echo Write-Host ""
echo.
echo # Create target directory
echo if ^(Test-Path $TargetDir^) {
echo     Write-Host "Application already installed. Removing old version..." -ForegroundColor Yellow
echo     Remove-Item -Path $TargetDir -Recurse -Force
echo }
echo.
echo New-Item -Path $TargetDir -ItemType Directory -Force ^| Out-Null
echo.
echo # Copy files
echo Write-Host "Copying application files..." -ForegroundColor Green
echo Copy-Item -Path "$InstallerFiles\*" -Destination $TargetDir -Recurse -Force
echo.
echo # Create desktop shortcut
echo $WshShell = New-Object -ComObject WScript.Shell
echo $DesktopPath = [Environment]::GetFolderPath^("Desktop"^)
echo $Shortcut = $WshShell.CreateShortcut^("$DesktopPath\Pharmacy Expense Tracker.lnk"^)
echo $Shortcut.TargetPath = Join-Path $TargetDir "PharmacyExpenseTracker.exe"
echo $Shortcut.WorkingDirectory = $TargetDir
echo $Shortcut.Description = "Pharmacy Expense Tracker"
echo $Shortcut.Save^(^)
echo.
echo # Create Start Menu shortcut
echo $StartMenuPath = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
echo $StartMenuShortcut = $WshShell.CreateShortcut^("$StartMenuPath\Pharmacy Expense Tracker.lnk"^)
echo $StartMenuShortcut.TargetPath = Join-Path $TargetDir "PharmacyExpenseTracker.exe"
echo $StartMenuShortcut.WorkingDirectory = $TargetDir
echo $StartMenuShortcut.Save^(^)
echo.
echo Write-Host "Installation completed successfully!" -ForegroundColor Green
echo Write-Host ""
echo Write-Host "Shortcuts created:" -ForegroundColor Cyan
echo Write-Host "  - Desktop: Pharmacy Expense Tracker" -ForegroundColor White
echo Write-Host "  - Start Menu: Pharmacy Expense Tracker" -ForegroundColor White
echo Write-Host ""
echo Write-Host "To uninstall, delete the folder: $TargetDir" -ForegroundColor Yellow
echo Write-Host ""
echo.
echo # Ask if user wants to launch
echo $Launch = Read-Host "Launch application now? (Y/N)"
echo if ($Launch -eq "Y" -or $Launch -eq "y"^) {
echo     Start-Process -FilePath (Join-Path $TargetDir "PharmacyExpenseTracker.exe"^)
echo }
echo.
echo Write-Host "Thank you for installing Pharmacy Expense Tracker!" -ForegroundColor Cyan
) > "%INSTALLER_DIR%\install.ps1"

echo [*] Installer script created
echo.

:: Create self-extracting archive
echo [*] Creating ZIP archive...
powershell -Command "Compress-Archive -Path '%INSTALLER_DIR%\*' -DestinationPath '%DIST_DIR%\PharmacyExpenseTracker_Installer_%VERSION%.zip' -Force"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [*] ===========================================
    echo [*] INSTALLER CREATED SUCCESSFULLY!
    echo [*] ===========================================
    echo.
    echo [*] Created file: %DIST_DIR%\PharmacyExpenseTracker_Installer_%VERSION%.zip
    echo [*] Version: %VERSION%
    echo.
    echo [*] To install:
    echo [*] 1. Extract the ZIP file
    echo [*] 2. Run install.ps1
    echo [*] 3. Follow the prompts
    echo.
) else (
    echo [ERROR] Failed to create ZIP archive
)

pause