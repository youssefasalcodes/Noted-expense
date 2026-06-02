@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: Noted Expense - Clean Build Script
:: Fixed version that doesn't reference missing files
:: ===========================================

set BUILD_DIR=%~dp0build
set DIST_DIR=%~dp0dist
set SCRIPT_DIR=%~dp0
set LOGFILE=%BUILD_DIR%\build_clean_log.txt

:: Create necessary directories
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

echo [*] Starting clean build process at %DATE% %TIME% > "%LOGFILE%"

:: ===========================================
:: Version Management
:: ===========================================

:: Read current version from version.json
set VERSION_FILE=%SCRIPT_DIR%version.json
if exist "%VERSION_FILE%" (
    for /f "tokens=2 delims=:," %%a in ('findstr "\"version\"" "%VERSION_FILE%"') do (
        set CURRENT_VERSION=%%a
        set CURRENT_VERSION=!CURRENT_VERSION:" =!
        set CURRENT_VERSION=!CURRENT_VERSION:"=!
    )
    echo [*] Current version: !CURRENT_VERSION! >> "%LOGFILE%"
) else (
    echo [*] version.json not found, using default version 1.0.0 >> "%LOGFILE%"
    set CURRENT_VERSION=1.0.0
)

:: Parse version number
for /f "tokens=1,2,3 delims=." %%a in ("%CURRENT_VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

:: Increment patch version
set /a PATCH+=1
set NEW_VERSION=%MAJOR%.%MINOR%.%PATCH%

echo [*] New version: %NEW_VERSION% >> "%LOGFILE%"
echo [*] Bumping version from %CURRENT_VERSION% to %NEW_VERSION%

:: Update version.json
(
echo {
echo   "version": "%NEW_VERSION%",
echo   "release_date": "%DATE%",
echo   "changelog": "Update - see release notes for details",
echo   "critical": false,
echo   "min_required_version": "1.0.0"
echo }
) > "%VERSION_FILE%"

echo [*] Updated version.json to %NEW_VERSION% >> "%LOGFILE%"

:: ===========================================
:: PyInstaller Build
:: ===========================================

echo [*] Creating PyInstaller spec file... >> "%LOGFILE%"
set SPECFILE="%BUILD_DIR%\noted_expense.spec"
echo import os> %SPECFILE%
echo block_cipher = None>> %SPECFILE%
echo.>> %SPECFILE%
echo a = Analysis(>> %SPECFILE%
echo     [r"%SCRIPT_DIR%Test.py"],>> %SPECFILE%
echo     pathex=[],>> %SPECFILE%
echo     binaries=[],>> %SPECFILE%
echo     datas=[>> %SPECFILE%
echo         (r"%SCRIPT_DIR%resources", 'resources'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%users.json", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%data.encrypted", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%version.json", '.'),>> %SPECFILE%
echo     ],>> %SPECFILE%
echo     hiddenimports=['PyQt5.QtCore', 'PyQt5.QtWidgets', 'PyQt5.QtGui', 'PyQt5', 'requests', 'dotenv'],>> %SPECFILE%
echo     hookspath=[],>> %SPECFILE%
echo     hooksconfig={},>> %SPECFILE%
echo     excludes=[],>> %SPECFILE%
echo     win_no_prefer_redirects=False,>> %SPECFILE%
echo     win_private_assemblies=False,>> %SPECFILE%
echo     cipher=block_cipher,>> %SPECFILE%
echo     noarchive=False,>> %SPECFILE%
echo )>> %SPECFILE%
echo pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)>> %SPECFILE%
echo exe = EXE(>> %SPECFILE%
echo     pyz,>> %SPECFILE%
echo     a.scripts,>> %SPECFILE%
echo     a.binaries,>> %SPECFILE%
echo     a.zipfiles,>> %SPECFILE%
echo     a.datas,>> %SPECFILE%
echo     [],>> %SPECFILE%
echo     name='NotedExpense',>> %SPECFILE%
echo     debug=False,>> %SPECFILE%
echo     bootloader_ignore_signals=False,>> %SPECFILE%
echo     strip=False,>> %SPECFILE%
echo     upx=True,>> %SPECFILE%
echo     upx_exclude=[],>> %SPECFILE%
echo     runtime_tmpdir=None,>> %SPECFILE%
echo     console=False,>> %SPECFILE%
echo     disable_windowed_traceback=False,>> %SPECFILE%
echo     argv_emulation=False,>> %SPECFILE%
echo     target_arch=None,>> %SPECFILE%
echo     codesign_identity=None,>> %SPECFILE%
echo     entitlements_file=None,>> %SPECFILE%
echo     icon=r"%SCRIPT_DIR%resources/images/Pharmacist.ico" >> %SPECFILE%
echo )>> %SPECFILE%

echo [*] Running PyInstaller... >> "%LOGFILE%"
pyinstaller --clean --noconfirm --distpath "%DIST_DIR%" --workpath "%BUILD_DIR%" "%BUILD_DIR%\noted_expense.spec" >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] PyInstaller build failed. Check %LOGFILE% for details. >> "%LOGFILE%"
    echo [ERROR] PyInstaller build failed. Check %LOGFILE% for details.
    pause
    exit /b 1
)

:: ===========================================
:: Final Package Creation
:: ===========================================

echo [*] Creating final package... >> "%LOGFILE%"
set PACKAGE_DIR=%DIST_DIR%\NotedExpense
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%"

:: Copy built executable
copy "%DIST_DIR%\NotedExpense.exe" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1

:: Copy required data files
copy "%SCRIPT_DIR%\users.json" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
copy "%SCRIPT_DIR%\data.encrypted" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
copy "%SCRIPT_DIR%\version.json" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
copy "%SCRIPT_DIR%\app_updater.py" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1

:: Copy resources folder
xcopy /E /I /Y "%SCRIPT_DIR%\resources" "%PACKAGE_DIR%\resources" >> "%LOGFILE%" 2>&1

:: Create README
echo Noted Expense > "%PACKAGE_DIR%\README.txt"
echo Version: %NEW_VERSION% >> "%PACKAGE_DIR%\README.txt"
echo. >> "%PACKAGE_DIR%\README.txt"
echo To start the application, double-click NotedExpense.exe >> "%PACKAGE_DIR%\README.txt"
echo. >> "%PACKAGE_DIR%\README.txt"
echo Default login: >> "%PACKAGE_DIR%\README.txt"
echo   Username: admin >> "%PACKAGE_DIR%\README.txt"
echo   Password: admin123 >> "%PACKAGE_DIR%\README.txt"
echo. >> "%PACKAGE_DIR%\README.txt"
echo For automatic updates, the app uses the .env file or environment variable: >> "%PACKAGE_DIR%\README.txt"
echo NOTED_EXPENSE_GITHUB_TOKEN for GitHub access. >> "%PACKAGE_DIR%\README.txt"

:: Create ZIP archive
echo [*] Creating ZIP archive... >> "%LOGFILE%"
powershell -command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%DIST_DIR%\NotedExpense_%NEW_VERSION%.zip' -Force" >> "%LOGFILE%" 2>&1

:: ===========================================
:: Inno Setup Installer
:: ===========================================

echo [*] Creating Inno Setup installer... >> "%LOGFILE%"
set INNO_SETUP_PATH="C:\Program Files\Inno Setup 7\ISCC.exe"
if exist %INNO_SETUP_PATH% (
    echo [*] Found Inno Setup at %INNO_SETUP_PATH% >> "%LOGFILE%"
    
    :: Update final installer script with version
    powershell -Command "(Get-Content '%SCRIPT_DIR%installer_final.iss') -replace 'AppVersion=1.0.0', 'AppVersion=%NEW_VERSION%' | Set-Content '%SCRIPT_DIR%installer_final.iss'" >> "%LOGFILE%" 2>&1
    powershell -Command "(Get-Content '%SCRIPT_DIR%installer_final.iss') -replace 'AppVerName=Noted Expense v1.0.0', 'AppVerName=Noted Expense v%NEW_VERSION%' | Set-Content '%SCRIPT_DIR%installer_final.iss'" >> "%LOGFILE%" 2>&1
    
    :: Build installer
    echo [*] Building Inno Setup installer... >> "%LOGFILE%"
    %INNO_SETUP_PATH% "%SCRIPT_DIR%installer_final.iss" >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo [WARNING] Inno Setup installer build failed, but application build succeeded. >> "%LOGFILE%"
        echo [WARNING] Inno Setup installer build failed, but application build succeeded.
    ) else (
        echo [*] Inno Setup installer created successfully >> "%LOGFILE%"
    )
) else (
    echo [WARNING] Inno Setup not found at %INNO_SETUP_PATH%. Skipping installer creation. >> "%LOGFILE%"
    echo [WARNING] Inno Setup not found. Skipping installer creation.
)

:: ===========================================
:: Completion
:: ===========================================

if %ERRORLEVEL% EQU 0 (
    echo [==========================================] >> "%LOGFILE%"
    echo [*] Build completed successfully! >> "%LOGFILE%"
    echo [==========================================] >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    echo [*] Version: %NEW_VERSION% >> "%LOGFILE%"
    echo [*] Executable: %DIST_DIR%\NotedExpense.exe >> "%LOGFILE%"
    echo [*] Package: %DIST_DIR%\NotedExpense_%NEW_VERSION%.zip >> "%LOGFILE%"
    echo [*] Installer: %DIST_DIR%\NotedExpense_Setup.exe (if Inno Setup is installed) >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    
    echo [==========================================]
    echo [Build completed successfully!]
    echo [==========================================]
    echo [*] Version: %NEW_VERSION%
    echo [*] Executable: %DIST_DIR%\NotedExpense.exe
    echo [*] Package: %DIST_DIR%\NotedExpense_%NEW_VERSION%.zip
    echo [*] Installer: %DIST_DIR%\NotedExpense_Setup.exe (if Inno Setup is installed)
    echo.
) else (
    echo [==========================================] >> "%LOGFILE%"
    echo [ERROR] Build completed with errors >> "%LOGFILE%"
    echo [==========================================] >> "%LOGFILE%"
    echo [ERROR] Build completed with errors
)

pause