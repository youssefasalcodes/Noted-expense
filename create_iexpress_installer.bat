@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: Create Professional Installer using IExpress (Built-in to Windows)
:: Creates a single .exe installer file
:: ===========================================

echo [*] Creating Professional Installer using IExpress
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

:: Create installation batch script
echo [*] Creating installation script...

(
echo @echo off
echo setlocal enabledelayedexpansion
echo.
echo echo ========================================
echo echo Pharmacy Expense Tracker - Installation
echo echo ========================================
echo echo.
echo echo Installing to Program Files...
echo echo.
echo set TARGET_DIR=C:\Program Files\PharmacyExpenseTracker
echo.
echo if exist "!TARGET_DIR!" (
echo     echo Removing existing installation...
echo     rmdir /s /q "!TARGET_DIR!"
echo )
echo.
echo mkdir "!TARGET_DIR!"
echo.
echo echo Copying files...
echo copy "%~dp0PharmacyExpenseTracker.exe" "!TARGET_DIR!\" ^>nul
echo copy "%~dp0users.json" "!TARGET_DIR!\" ^>nul 2^>^&1
echo copy "%~dp0data.encrypted" "!TARGET_DIR!\" ^>nul 2^>^&1
echo copy "%~dp0version.json" "!TARGET_DIR!\" ^>nul 2^>^&1
echo copy "%~dp0app_updater.py" "!TARGET_DIR!\" ^>nul 2^>^&1
echo.
echo echo Creating shortcuts...
echo set DESKTOP=%USERPROFILE%\Desktop
echo set STARTMENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs
echo.
echo powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut^('!DESKTOP!\Pharmacy Expense Tracker.lnk'^); $Shortcut.TargetPath = '!TARGET_DIR!\PharmacyExpenseTracker.exe'; $Shortcut.WorkingDirectory = '!TARGET_DIR!'; $Shortcut.Save^(^)"
echo.
echo powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut^('!STARTMENU!\Pharmacy Expense Tracker.lnk'^); $Shortcut.TargetPath = '!TARGET_DIR!\PharmacyExpenseTracker.exe'; $Shortcut.WorkingDirectory = '!TARGET_DIR!'; $Shortcut.Save^(^)"
echo.
echo echo ========================================
echo echo Installation completed successfully!
echo echo ========================================
echo echo.
echo echo Shortcuts created:
echo echo   - Desktop
echo echo   - Start Menu
echo echo.
echo echo To uninstall, delete: !TARGET_DIR!
echo echo.
echo set /p LAUNCH="Launch application now? (Y/N): "
echo if /i "!LAUNCH!"=="Y" (
echo     start "" "!TARGET_DIR!\PharmacyExpenseTracker.exe"
echo )
echo.
echo echo Thank you for installing Pharmacy Expense Tracker!
echo pause
) > "%INSTALLER_DIR%\install.bat"

echo [*] Installation script created
echo.

:: Create IExpress configuration file
echo [*] Creating IExpress configuration...

(
echo [Version]
echo Class=IEXPRESS
echo SEDVersion=3
echo [Options]
echo PackagePurpose=InstallApp
echo ShowInstallProgramWindow=1
echo HideExtractAnimation=1
echo UseLongFileName=1
echo InsideCompressed=0
echo CAB_FixedSize=0
echo CAB_ResvCodeSigning=0
echo RebootMode=N
echo DisplayLicense=0
echo FinishMessage=0
echo TargetName=PharmacyExpenseTracker_Setup_%VERSION%
echo FriendlyName=Pharmacy Expense Tracker
echo [Strings]
echo AppInstall=install.bat
echo [Files]
echo Source=%INSTALLER_DIR%\install.bat
echo Source=%INSTALLER_DIR%\PharmacyExpenseTracker.exe
echo Source=%INSTALLER_DIR%\users.json
echo Source=%INSTALLER_DIR%\data.encrypted
echo Source=%INSTALLER_DIR%\version.json
echo Source=%INSTALLER_DIR%\app_updater.py
) > "%DIST_DIR%\iexpress_config.sed"

echo [*] Configuration created
echo.

:: Run IExpress
echo [*] Creating installer with IExpress...
echo.

iexpress /N /Q "%DIST_DIR%\iexpress_config.sed"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [*] ===========================================
    echo [*] INSTALLER CREATED SUCCESSFULLY!
    echo [*] ===========================================
    echo.
    echo [*] Created file: %DIST_DIR%\PharmacyExpenseTracker_Setup_%VERSION%.exe
    echo [*] Version: %VERSION%
    echo.
    echo [*] Installation features:
    echo [*] - Single .exe installer file
    echo [*] - Professional setup experience
    echo [*] - Creates desktop shortcut
    echo [*] - Creates Start Menu shortcut
    echo [*] - Installs to Program Files
    echo [*] - Simple uninstall (delete folder)
    echo.
    echo [*] Distribution ready!
    echo.
) else (
    echo [ERROR] IExpress installer creation failed!
    echo.
    echo Please check if IExpress is available on your system.
    echo IExpress should be available on Windows 7 and later.
    echo.
)

pause