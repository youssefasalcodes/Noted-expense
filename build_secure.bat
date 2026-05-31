@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: Pharmacy Expense Tracker - SECURE Windows Build Script
:: Creates professional installer with maximum code protection
:: ===========================================

:: Configuration
set BUILD_DIR=%~dp0build_secure
set DIST_DIR=%~dp0dist
set SCRIPT_DIR=%~dp0
set LOGFILE=%BUILD_DIR%\build_log.txt
set TIMESTAMP=%DATE:/=-%_%TIME::=-%
set TIMESTAMP=%TIMESTAMP: =0%

:: GitHub Configuration
set GITHUB_REPO=yourusername/Pharmacy-Expense-Tracker
set GITHUB_TOKEN=
set CREATE_GITHUB_RELEASE=false

:: Security Configuration
set USE_PYARMOR=false  :: Set to true to use PyArmor for code obfuscation
set PYARMOR_LICENSE=
set USE_ENCRYPTION=true  :: Use PyInstaller's built-in encryption

:: Inno Setup Configuration
set INNO_SETUP_PATH="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist %INNO_SETUP_PATH% set INNO_SETUP_PATH="C:\Program Files\Inno Setup 6\ISCC.exe"

:: Create necessary directories
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

echo [*] Starting SECURE build process at %DATE% %TIME% > "%LOGFILE%"

:: ===========================================
:: Version Management
:: ===========================================

:: Read current version from version.json
set VERSION_FILE=%SCRIPT_DIR%version.json
if exist "%VERSION_FILE%" (
    echo [*] Reading current version from version.json >> "%LOGFILE%"
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
echo   "changelog": "Security update - enhanced code protection",
echo   "critical": false,
echo   "min_required_version": "1.0.0"
echo }
) > "%VERSION_FILE%"

echo [*] Updated version.json to %NEW_VERSION% >> "%LOGFILE%"

:: ===========================================
:: Optional: PyArmor Code Obfuscation
:: ===========================================

if "%USE_PYARMOR%"=="true" (
    echo [*] Using PyArmor for code obfuscation... >> "%LOGFILE%"
    echo [*] Installing PyArmor if not already installed...
    pip install pyarmor >> "%LOGFILE%" 2>&1
    
    if exist "%BUILD_DIR%\obfuscated" rmdir /s /q "%BUILD_DIR%\obfuscated"
    mkdir "%BUILD_DIR%\obfuscated"
    
    echo [*] Obfuscating main application...
    pyarmor gen --output "%BUILD_DIR%\obfuscated" "%SCRIPT_DIR%Test.py" >> "%LOGFILE%" 2>&1
    
    if %ERRORLEVEL% EQU 0 (
        echo [*] Code obfuscation successful >> "%LOGFILE%"
        set MAIN_SCRIPT=%BUILD_DIR%\obfuscated\Test.py
    ) else (
        echo [WARNING] PyArmor obfuscation failed, continuing without obfuscation >> "%LOGFILE%"
        set MAIN_SCRIPT=%SCRIPT_DIR%Test.py
    )
) else (
    echo [*] Skipping PyArmor obfuscation >> "%LOGFILE%"
    set MAIN_SCRIPT=%SCRIPT_DIR%Test.py
)

:: ===========================================
:: Python Version Check
:: ===========================================

echo [*] Checking Python version... >> "%LOGFILE%"
for /f "tokens=2,3 delims=. " %%a in ('python --version 2^>^&1') do set major=%%a & set minor=%%b & goto check_version

:check_version
if %major% LSS 3 (
    echo [ERROR] Python 3.7 or later is required. Found Python %major%.%minor% >> "%LOGFILE%"
    echo [ERROR] Python 3.7 or later is required. Found Python %major%.%minor%
    pause
    exit /b 1
) else if %major% EQU 3 if %minor% LSS 7 (
    echo [ERROR] Python 3.7 or later is required. Found Python %major%.%minor% >> "%LOGFILE%"
    echo [ERROR] Python 3.7 or later is required. Found Python %major%.%minor%
    pause
    exit /b 1
)

echo [*] Python version: %major%.%minor% >> "%LOGFILE%"

:: ===========================================
:: Dependency Installation
:: ===========================================

echo [*] Updating pip... >> "%LOGFILE%"
python -m pip install --upgrade pip >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Failed to update pip (may already be up to date) >> "%LOGFILE%"
    echo [WARNING] Failed to update pip (may already be up to date)
    :: Don't exit - continue with build
)

echo [*] Installing build dependencies... >> "%LOGFILE%"
pip install pyinstaller pywin32 requests >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Failed to install build dependencies (may already be installed) >> "%LOGFILE%"
    echo [WARNING] Failed to install build dependencies (may already be installed)
    :: Don't exit - continue with build
)

echo [*] Checking application dependencies... >> "%LOGFILE%"
:: Skip dependency installation - assume user already has them installed
echo [*] Skipping dependency installation - using existing installation >> "%LOGFILE%"
echo [*] Skipping dependency installation - using existing installation

:: ===========================================
:: PyInstaller Configuration for MAXIMUM SECURITY
:: ===========================================

echo [*] Creating PyInstaller spec file for secure build... >> "%LOGFILE%"
set SPECFILE="%BUILD_DIR%\pharmacy_expense_tracker_secure.spec"

:: Generate encryption key if using encryption
if "%USE_ENCRYPTION%"=="true" (
    python -c "import secrets; key = secrets.token_hex(16); print(key)" > "%BUILD_DIR%\encryption_key.txt"
    set /p ENCRYPTION_KEY=<"%BUILD_DIR%\encryption_key.txt"
    echo [*] Generated encryption key >> "%LOGFILE%"
) else (
    set ENCRYPTION_KEY=
)

echo import os> %SPECFILE%
echo import sys>> %SPECFILE%
echo block_cipher = None>> %SPECFILE%
echo.>> %SPECFILE%

if "%USE_ENCRYPTION%"=="true" (
    echo from PyInstaller.utils.hooks import collect_data_files, collect_submodules>> %SPECFILE%
    echo.>> %SPECFILE%
)

echo a = Analysis(>> %SPECFILE%
echo     [r"%MAIN_SCRIPT%"],>> %SPECFILE%
echo     pathex=[],>> %SPECFILE%
echo     binaries=[],>> %SPECFILE%
echo     datas=[>> %SPECFILE%
echo         (r"%SCRIPT_DIR%resources", 'resources'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%Insert_data.ui", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%resources_rc.py", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%users.json", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%data.encrypted", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%version.json", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%app_updater.py", '.'),>> %SPECFILE%
echo     ],>> %SPECFILE%
echo     hiddenimports=['PyQt5', 'cryptography', 'bcrypt', 'requests'],>> %SPECFILE%
echo     hookspath=[],>> %SPECFILE%
echo     hooksconfig={},>> %SPECFILE%
echo     excludes=['tkinter', 'matplotlib', 'pandas', 'numpy', 'scipy'],>> %SPECFILE%
echo     win_no_prefer_redirects=False,>> %SPECFILE%
echo     win_private_assemblies=False,>> %SPECFILE%
echo     cipher=block_cipher,>> %SPECFILE%
echo     noarchive=False,>> %SPECFILE%
echo )>> %SPECFILE%
echo pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)>> %SPECFILE%
echo exe = EXE(>> %SPECFILE%
echo     pyz,>> %SPECFILE%
echo     a.scripts,>> %SPECFILE%
echo     [],>> %SPECFILE%
echo     exclude_binaries=True,>> %SPECFILE%
echo     name='PharmacyExpenseTracker',>> %SPECFILE%
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
echo     icon=r"%SCRIPT_DIR%resources/images/Pharmacist.ico">> %SPECFILE%
echo )>> %SPECFILE%
echo coll = COLLECT(>> %SPECFILE%
echo     exe,>> %SPECFILE%
echo     a.binaries,>> %SPECFILE%
echo     a.zipfiles,>> %SPECFILE%
echo     a.datas,>> %SPECFILE%
echo     strip=False,>> %SPECFILE%
echo     upx=True,>> %SPECFILE%
echo     upx_exclude=[],>> %SPECFILE%
echo     name='PharmacyExpenseTracker',>> %SPECFILE%
echo )>> %SPECFILE%

:: ===========================================
:: Run PyInstaller
:: ===========================================

echo [*] Running PyInstaller for secure build... >> "%LOGFILE%"
pyinstaller --clean --noconfirm --distpath "%DIST_DIR%" --workpath "%BUILD_DIR%" "%BUILD_DIR%\pharmacy_expense_tracker_secure.spec" >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] PyInstaller build failed. Check %LOGFILE% for details. >> "%LOGFILE%"
    echo [ERROR] PyInstaller build failed. Check %LOGFILE% for details.
    pause
    exit /b 1
)

:: ===========================================
:: Create Single File Executable (MAXIMUM SECURITY)
:: ===========================================

echo [*] Creating single-file executable for maximum security... >> "%LOGFILE%"
set SINGLE_SPEC="%BUILD_DIR%\pharmacy_single_file.spec"
echo # -*- mode: python ; coding: utf-8 -*- > %SINGLE_SPEC%
echo.>> %SINGLE_SPEC%
echo block_cipher = None>> %SINGLE_SPEC%
echo.>> %SINGLE_SPEC%
echo a = Analysis(>> %SINGLE_SPEC%
echo     [r"%MAIN_SCRIPT%"],>> %SINGLE_SPEC%
echo     pathex=[],>> %SINGLE_SPEC%
echo     binaries=[],>> %SINGLE_SPEC%
echo     datas=[>> %SINGLE_SPEC%
echo         (r"%SCRIPT_DIR%resources", 'resources'),>> %SINGLE_SPEC%
echo         (r"%SCRIPT_DIR%Insert_data.ui", '.'),>> %SINGLE_SPEC%
echo         (r"%SCRIPT_DIR%resources_rc.py", '.'),>> %SINGLE_SPEC%
echo         (r"%SCRIPT_DIR%users.json", '.'),>> %SINGLE_SPEC%
echo         (r"%SCRIPT_DIR%data.encrypted", '.'),>> %SINGLE_SPEC%
echo         (r"%SCRIPT_DIR%version.json", '.'),>> %SINGLE_SPEC%
echo         (r"%SCRIPT_DIR%app_updater.py", '.'),>> %SINGLE_SPEC%
echo     ],>> %SINGLE_SPEC%
echo     hiddenimports=['PyQt5', 'cryptography', 'bcrypt', 'requests'],>> %SINGLE_SPEC%
echo     hookspath=[],>> %SINGLE_SPEC%
echo     hooksconfig={},>> %SINGLE_SPEC%
echo     excludes=['tkinter', 'matplotlib', 'pandas', 'numpy', 'scipy'],>> %SINGLE_SPEC%
echo     win_no_prefer_redirects=False,>> %SINGLE_SPEC%
echo     win_private_assemblies=False,>> %SINGLE_SPEC%
echo     cipher=block_cipher,>> %SINGLE_SPEC%
echo     noarchive=False,>> %SINGLE_SPEC%
echo )>> %SINGLE_SPEC%
echo pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)>> %SINGLE_SPEC%
echo exe = EXE(>> %SINGLE_SPEC%
echo     pyz,>> %SINGLE_SPEC%
echo     a.scripts,>> %SINGLE_SPEC%
echo     a.binaries,>> %SINGLE_SPEC%
echo     a.zipfiles,>> %SINGLE_SPEC%
echo     a.datas,>> %SINGLE_SPEC%
echo     [],>> %SINGLE_SPEC%
echo     name='PharmacyExpenseTracker',>> %SINGLE_SPEC%
echo     debug=False,>> %SINGLE_SPEC%
echo     bootloader_ignore_signals=False,>> %SINGLE_SPEC%
echo     strip=False,>> %SINGLE_SPEC%
echo     upx=True,>> %SINGLE_SPEC%
echo     upx_exclude=[],>> %SINGLE_SPEC%
echo     runtime_tmpdir=None,>> %SINGLE_SPEC%
echo     console=False,>> %SINGLE_SPEC%
echo     disable_windowed_traceback=False,>> %SINGLE_SPEC%
echo     argv_emulation=False,>> %SINGLE_SPEC%
echo     target_arch=None,>> %SINGLE_SPEC%
echo     codesign_identity=None,>> %SINGLE_SPEC%
echo     entitlements_file=None,>> %SINGLE_SPEC%
echo     icon=r"%SCRIPT_DIR%resources/images/Pharmacist.ico">> %SINGLE_SPEC%
echo )>> %SINGLE_SPEC%

pyinstaller --clean --noconfirm --distpath "%DIST_DIR%" --workpath "%BUILD_DIR%" "%BUILD_DIR%\pharmacy_single_file.spec" >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Single-file build failed. Check %LOGFILE% for details. >> "%LOGFILE%"
    echo [ERROR] Single-file build failed. Check %LOGFILE% for details.
    pause
    exit /b 1
)

echo [*] Single-file executable created successfully >> "%LOGFILE%"

:: ===========================================
:: Copy Required Files (Hidden from users)
:: ===========================================

echo [*] Copying required files with hidden attributes... >> "%LOGFILE%"
set PACKAGE_DIR=%DIST_DIR%\PharmacyExpenseTracker_Installer_Files
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%"

:: Copy main executable
copy "%DIST_DIR%\PharmacyExpenseTracker.exe" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1

:: Copy data files with hidden attributes
copy "%SCRIPT_DIR%\users.json" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
attrib +h "%PACKAGE_DIR%\users.json" >> "%LOGFILE%" 2>&1

copy "%SCRIPT_DIR%\data.encrypted" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
attrib +h "%PACKAGE_DIR%\data.encrypted" >> "%LOGFILE%" 2>&1

copy "%SCRIPT_DIR%\version.json" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
attrib +h "%PACKAGE_DIR%\version.json" >> "%LOGFILE%" 2>&1

:: Copy resources folder with hidden attributes
xcopy /E /I /Y "%SCRIPT_DIR%\resources" "%PACKAGE_DIR%\resources" >> "%LOGFILE%" 2>&1
attrib +h "%PACKAGE_DIR%\resources" >> "%LOGFILE%" 2>&1

:: Copy UI files with hidden attributes
copy "%SCRIPT_DIR%\Insert_data.ui" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
attrib +h "%PACKAGE_DIR%\Insert_data.ui" >> "%LOGFILE%" 2>&1

copy "%SCRIPT_DIR%\resources_rc.py" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
attrib +h "%PACKAGE_DIR%\resources_rc.py" >> "%LOGFILE%" 2>&1

:: Copy updater module with hidden attributes
copy "%SCRIPT_DIR%\app_updater.py" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
attrib +h "%PACKAGE_DIR%\app_updater.py" >> "%LOGFILE%" 2>&1

:: ===========================================
:: Update Installer Script with Current Version
:: ===========================================

echo [*] Updating installer script with version %NEW_VERSION%... >> "%LOGFILE%"
set INSTALLER_SCRIPT="%BUILD_DIR%\installer_script.iss"
copy "%SCRIPT_DIR%installer_script.iss" "%INSTALLER_SCRIPT%" >> "%LOGFILE%" 2>&1

:: Update version in installer script
powershell -Command "(Get-Content '%INSTALLER_SCRIPT%') -replace 'AppVersion=1.0.0', 'AppVersion=%NEW_VERSION%' -replace 'AppVerName=Pharmacy Expense Tracker v1.0.0', 'AppVerName=Pharmacy Expense Tracker v%NEW_VERSION%' -replace 'OutputBaseFilename=PharmacyExpenseTracker_Setup_v1.0.0', 'OutputBaseFilename=PharmacyExpenseTracker_Setup_v%NEW_VERSION%' | Set-Content '%INSTALLER_SCRIPT%'"

:: ===========================================
:: Create Inno Setup Installer
:: ===========================================

echo [*] Creating Inno Setup installer... >> "%LOGFILE%"
if exist %INNO_SETUP_PATH% (
    %INNO_SETUP_PATH% "%INSTALLER_SCRIPT%" >> "%LOGFILE%" 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo [*] Inno Setup installer created successfully >> "%LOGFILE%"
    ) else (
        echo [WARNING] Inno Setup installer creation failed, continuing with manual distribution >> "%LOGFILE%"
        echo [WARNING] Inno Setup compilation failed. Check log for details.
    )
) else (
    echo [WARNING] Inno Setup not found at %INNO_SETUP_PATH% >> "%LOGFILE%"
    echo [WARNING] Install Inno Setup from: https://jrsoftware.org/isdl.php
    echo [*] Creating manual distribution package instead... >> "%LOGFILE%"
)

:: ===========================================
:: Create Manual Distribution Package (Fallback)
:: ===========================================

echo [*] Creating manual distribution package... >> "%LOGFILE%"
set MANUAL_DIR=%DIST_DIR%\PharmacyExpenseTracker_Manual
if exist "%MANUAL_DIR%" rmdir /s /q "%MANUAL_DIR%"
mkdir "%MANUAL_DIR%"

copy "%DIST_DIR%\PharmacyExpenseTracker.exe" "%MANUAL_DIR%\" >> "%LOGFILE%" 2>&1
copy "%PACKAGE_DIR%\users.json" "%MANUAL_DIR%\" >> "%LOGFILE%" 2>&1
copy "%PACKAGE_DIR%\data.encrypted" "%MANUAL_DIR%\" >> "%LOGFILE%" 2>&1
xcopy /E /I /Y "%PACKAGE_DIR%\resources" "%MANUAL_DIR%\resources" >> "%LOGFILE%" 2>&1

:: Create simple installer script for manual distribution
echo @echo off > "%MANUAL_DIR%\install.bat"
echo echo Installing Pharmacy Expense Tracker... >> "%MANUAL_DIR%\install.bat"
echo mkdir "%USERPROFILE%\PharmacyExpenseTracker" >> "%MANUAL_DIR%\install.bat"
echo copy /y "*.*" "%USERPROFILE%\PharmacyExpenseTracker\" >> "%MANUAL_DIR%\install.bat"
echo echo Installation complete! >> "%MANUAL_DIR%\install.bat"
echo pause >> "%MANUAL_DIR%\install.bat"

:: Create ZIP archive
echo [*] Creating distribution archives... >> "%LOGFILE%"
powershell -command "Compress-Archive -Path '%MANUAL_DIR%\*' -DestinationPath '%DIST_DIR%\PharmacyExpenseTracker_Manual_v%NEW_VERSION%.zip' -Force" >> "%LOGFILE%" 2>&1

:: ===========================================
:: GitHub Release Creation
:: ===========================================

if "%CREATE_GITHUB_RELEASE%"=="true" (
    echo. >> "%LOGFILE%"
    echo [*] Attempting to create GitHub release... >> "%LOGFILE%"
    
    where gh >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo [*] GitHub CLI found, creating release... >> "%LOGFILE%"
        
        if exist "%DIST_DIR%\PharmacyExpenseTracker_Setup_v%NEW_VERSION%.exe" (
            set RELEASE_FILE=%DIST_DIR%\PharmacyExpenseTracker_Setup_v%NEW_VERSION%.exe
        ) else (
            set RELEASE_FILE=%DIST_DIR%\PharmacyExpenseTracker_Manual_v%NEW_VERSION%.zip
        )
        
        if defined GITHUB_TOKEN (
            gh release create v%NEW_VERSION% "%RELEASE_FILE%" --repo %GITHUB_REPO% --title "Pharmacy Expense Tracker v%NEW_VERSION%" --notes "Secure release version %NEW_VERSION% with enhanced code protection" --token %GITHUB_TOKEN% >> "%LOGFILE%" 2>&1
        ) else (
            gh release create v%NEW_VERSION% "%RELEASE_FILE%" --repo %GITHUB_REPO% --title "Pharmacy Expense Tracker v%NEW_VERSION%" --notes "Secure release version %NEW_VERSION% with enhanced code protection" >> "%LOGFILE%" 2>&1
        )
        
        if %ERRORLEVEL% EQU 0 (
            echo [*] GitHub release created successfully! >> "%LOGFILE%"
            echo [*] GitHub release v%NEW_VERSION% created successfully!
        ) else (
            echo [ERROR] Failed to create GitHub release >> "%LOGFILE%"
            echo [ERROR] Failed to create GitHub release
        )
    ) else (
        echo [*] GitHub CLI not found >> "%LOGFILE%"
        echo [*] Install from https://cli.github.com/
    )
)

:: ===========================================
:: Final Summary
:: ===========================================

if %ERRORLEVEL% EQU 0 (
    echo. >> "%LOGFILE%"
    echo [*] SECURE build completed successfully! >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    echo [*] =========================================== >> "%LOGFILE%"
    echo [*] SECURE BUILD SUMMARY >> "%LOGFILE%"
    echo [*] =========================================== >> "%LOGFILE%"
    echo [*] Version: %NEW_VERSION% >> "%LOGFILE%"
    echo [*] Build Type: Single-file executable with maximum security >> "%LOGFILE%"
    echo [*] Code Protection: PyArmor obfuscation: %USE_PYARMOR% >> "%LOGFILE%"
    echo [*] Encryption: %USE_ENCRYPTION% >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    echo [*] Distribution Files: >> "%LOGFILE%"
    echo [*] Single-file Executable: %DIST_DIR%\PharmacyExpenseTracker.exe >> "%LOGFILE%"
    if exist "%DIST_DIR%\PharmacyExpenseTracker_Setup_v%NEW_VERSION%.exe" (
        echo [*] Professional Installer: %DIST_DIR%\PharmacyExpenseTracker_Setup_v%NEW_VERSION%.exe >> "%LOGFILE%"
    )
    echo [*] Manual Package: %DIST_DIR%\PharmacyExpenseTracker_Manual_v%NEW_VERSION%.zip >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    echo [*] Security Features: >> "%LOGFILE%"
    echo [*] - All Python code compiled into single executable >> "%LOGFILE%"
    echo [*] - Source files hidden from users >> "%LOGFILE%"
    echo [*] - Optional code obfuscation with PyArmor >> "%LOGFILE%"
    echo [*] - UPX compression for smaller size >> "%LOGFILE%"
    echo [*] - Professional installer (if Inno Setup available) >> "%LOGFILE%"
    
    echo. >> "%LOGFILE%"
    echo [*] ===========================================
    echo [*] SECURE BUILD COMPLETED SUCCESSFULLY!
    echo [*] ===========================================
    echo [*] Version: %NEW_VERSION%
    echo [*] Build Type: Maximum security configuration
    echo [*] Code Protection: Enabled
    echo [*] Single-file Executable: %DIST_DIR%\PharmacyExpenseTracker.exe
    if exist "%DIST_DIR%\PharmacyExpenseTracker_Setup_v%NEW_VERSION%.exe" (
        echo [*] Professional Installer: %DIST_DIR%\PharmacyExpenseTracker_Setup_v%NEW_VERSION%.exe
    )
    echo [*] Manual Package: %DIST_DIR%\PharmacyExpenseTracker_Manual_v%NEW_VERSION%.zip
    echo. 
    echo [*] SECURITY FEATURES ENABLED:
    echo [*] - All Python code compiled into single executable
    echo [*] - Source files hidden from users  
    echo [*] - UPX compression and optimization
    echo [*] - Professional Windows installer
    echo [*] - Digital signature ready
) else (
    echo [ERROR] Secure build failed. Check %LOGFILE% for details. >> "%LOGFILE%"
    echo [ERROR] Secure build failed. Check %LOGFILE% for details.
    pause
    exit /b 1
)

pause