@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: Simple Inno Setup Installer Creator
:: ===========================================

echo.
echo ============================================
echo Creating Professional Installer
echo ============================================
echo.

:: Configuration
set DIST_DIR=%~dp0dist
set VERSION=1.0.0

:: Read version if exists
if exist "%~dp0version.json" (
    for /f "tokens=2 delims=:," %%a in ('findstr "\"version\"" "%~dp0version.json"') do (
        set VERSION=%%a
        set VERSION=!VERSION:" =!
        set VERSION=!VERSION:"=!
    )
)

echo Current version: %VERSION
echo.

:: Check if executable exists
if not exist "%DIST_DIR%\PharmacyExpenseTracker.exe" (
    echo ERROR: PharmacyExpenseTracker.exe not found in dist folder
    echo Please run build_secure.bat first
    pause
    exit /b 1
)

echo Found: PharmacyExpenseTracker.exe
echo.

:: Find Inno Setup
echo Searching for Inno Setup...
set INNO_PATH=""

:: Check common locations
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set INNO_PATH="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    echo Found at: C:\Program Files (x86)\Inno Setup 6
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set INNO_PATH="C:\Program Files\Inno Setup 6\ISCC.exe"
    echo Found at: C:\Program Files\Inno Setup 6
) else if exist "C:\Program Files (x86)\Inno Setup 5\ISCC.exe" (
    set INNO_PATH="C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
    echo Found at: C:\Program Files (x86)\Inno Setup 5
) else if exist "C:\Program Files\Inno Setup 5\ISCC.exe" (
    set INNO_PATH="C:\Program Files\Inno Setup 5\ISCC.exe"
    echo Found at: C:\Program Files\Inno Setup 5
) else (
    echo Inno Setup not found in standard locations
    echo.
    echo Please manually run Inno Setup from:
    echo Start Menu ^> Inno Setup ^> Compiler
    echo Then open: %~dp0installer_script.iss
    echo.
    pause
    exit /b 1
)

echo.
echo Creating installer...
echo.

:: Update installer script with current version
set TEMP_ISS="%DIST_DIR%\installer_current.iss"
copy "%~dp0installer_script.iss" "%TEMP_ISS%" >nul

:: Replace version numbers
powershell -Command "(Get-Content '%TEMP_ISS%') -replace 'AppVersion=1.0.0', 'AppVersion=%VERSION%' -replace 'AppVerName=Pharmacy Expense Tracker v1.0.0', 'AppVerName=Pharmacy Expense Tracker v%VERSION%' | Set-Content '%TEMP_ISS%'"

:: Run Inno Setup
%INNO_PATH% "%TEMP_ISS%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo SUCCESS! Installer created
    echo ============================================
    echo.
    echo Location: %DIST_DIR%\PharmacyExpenseTracker_Setup.exe
    echo Version: %VERSION
    echo.
    echo Users can now double-click this file to install
    echo the application like professional software.
    echo.
) else (
    echo.
    echo ERROR: Installer creation failed
    echo.
    echo Please check the Inno Setup output above
    echo.
)

pause