@echo off
setlocal enabledelayedexpansion

echo [*] Looking for NSIS...

:: Auto-detect NSIS location
set NSIS_PATH=
if exist "C:\Program Files (x86)\NSIS\makensis.exe" set NSIS_PATH=C:\Program Files (x86)\NSIS\makensis.exe
if exist "C:\Program Files\NSIS\makensis.exe"       set NSIS_PATH=C:\Program Files\NSIS\makensis.exe

:: Try PATH as fallback
if "!NSIS_PATH!"=="" (
    where makensis >nul 2>&1
    if !ERRORLEVEL! EQU 0 set NSIS_PATH=makensis
)

if "!NSIS_PATH!"=="" (
    echo [ERROR] NSIS not found. Please install it from https://nsis.sourceforge.io/Download
    echo         Then re-run this script.
    pause
    exit /b 1
)
echo [*] Found NSIS at: !NSIS_PATH!

:: Read version from version.json
if not exist version.json (
    echo [ERROR] version.json not found. Run build_windows.bat first.
    pause
    exit /b 1
)

echo [*] Reading version from version.json...
for /f "tokens=2 delims=:," %%a in ('findstr "\"version\"" version.json') do (
    set VER=%%a
    set VER=!VER:" =!
    set VER=!VER:"=!
)

if "!VER!"=="" (
    echo [ERROR] Could not read version from version.json.
    pause
    exit /b 1
)
echo [*] Version: !VER!

:: Patch version into a temp copy of the .nsi file
if not exist installer.nsi (
    echo [ERROR] installer.nsi not found. Make sure it is in the same folder as this script.
    pause
    exit /b 1
)

powershell -Command "(Get-Content installer.nsi) -replace '\"1\.0\.0\"', '\"!VER!\"' | Set-Content installer_build.nsi"

:: Run NSIS
echo [*] Running NSIS compiler...
"!NSIS_PATH!" installer_build.nsi
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] NSIS compilation failed. Check the output above for details.
    del /f /q installer_build.nsi >nul 2>&1
    pause
    exit /b 1
)

del /f /q installer_build.nsi >nul 2>&1

echo.
echo [*] Done! Installer created: dist\NotedExpense_Setup_!VER!.exe
pause