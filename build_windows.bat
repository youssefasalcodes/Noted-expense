@echo off
setlocal enabledelayedexpansion

:: ===========================================
:: Pharmacy Expense Tracker - Windows Build Script
:: ===========================================

:: Configuration
set BUILD_DIR=%~dp0build
set DIST_DIR=%~dp0dist
set SCRIPT_DIR=%~dp0
set LOGFILE=%BUILD_DIR%\build_log.txt
set TIMESTAMP=%DATE:/=-%_%TIME::=-%
set TIMESTAMP=%TIMESTAMP: =0%

:: Create necessary directories
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

echo [*] Starting build process at %DATE% %TIME% > "%LOGFILE%"

:: Check Python version
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

:: Install/update pip
echo [*] Updating pip... >> "%LOGFILE%"
python -m pip install --upgrade pip >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to update pip >> "%LOGFILE%"
    echo [ERROR] Failed to update pip
    pause
    exit /b 1
)

:: Install build dependencies
echo [*] Installing build dependencies... >> "%LOGFILE%"
pip install pyinstaller pywin32 >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install build dependencies >> "%LOGFILE%"
    echo [ERROR] Failed to install build dependencies
    pause
    exit /b 1
)

:: Install application dependencies
echo [*] Installing application dependencies... >> "%LOGFILE%"
pip install -r "%SCRIPT_DIR%requirements_windows.txt" >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install application dependencies >> "%LOGFILE%"
    echo [ERROR] Failed to install application dependencies
    pause
    exit /b 1
)

:: Create PyInstaller spec file
echo [*] Creating PyInstaller spec file... >> "%LOGFILE%"
set SPECFILE="%BUILD_DIR%\pharmacy_expense_tracker.spec"
echo import os> %SPECFILE%
echo block_cipher = None>> %SPECFILE%
echo.>> %SPECFILE%
echo a = Analysis(>> %SPECFILE%
echo     [r"%SCRIPT_DIR%Test.py"],>> %SPECFILE%
echo     pathex=[],>> %SPECFILE%
echo     binaries=[],>> %SPECFILE%
echo     datas=[>> %SPECFILE%
echo         (r"%SCRIPT_DIR%resources", 'resources'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%Insert_data.ui", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%resources_rc.py", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%users.json", '.'),>> %SPECFILE%
echo         (r"%SCRIPT_DIR%data.encrypted", '.')>> %SPECFILE%
echo     ],>> %SPECFILE%
echo     hiddenimports=[],>> %SPECFILE%
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
echo     icon=r"%SCRIPT_DIR%resources/images/Pharmacist.ico" >> %SPECFILE%
echo )>> %SPECFILE%

:: Run PyInstaller
echo [*] Running PyInstaller... >> "%LOGFILE%"
pyinstaller --clean --noconfirm --distpath "%DIST_DIR%" --workpath "%BUILD_DIR%" "%BUILD_DIR%\pharmacy_expense_tracker.spec" >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] PyInstaller build failed. Check %LOGFILE% for details. >> "%LOGFILE%"
    echo [ERROR] PyInstaller build failed. Check %LOGFILE% for details.
    pause
    exit /b 1
)

:: Create final package directory
echo [*] Creating final package... >> "%LOGFILE%"
set PACKAGE_DIR=%DIST_DIR%\PharmacyExpenseTracker
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%"

:: Copy built executable only
copy "%DIST_DIR%\PharmacyExpenseTracker.exe" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1

:: Copy required data files
copy "%SCRIPT_DIR%\users.json" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
copy "%SCRIPT_DIR%\data.encrypted" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1

:: Copy resources folder if needed
xcopy /E /I /Y "%SCRIPT_DIR%\resources" "%PACKAGE_DIR%\resources" >> "%LOGFILE%" 2>&1

:: Copy Insert_data.ui and resources_rc.py if needed
copy "%SCRIPT_DIR%\Insert_data.ui" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1
copy "%SCRIPT_DIR%\resources_rc.py" "%PACKAGE_DIR%\" >> "%LOGFILE%" 2>&1

:: Create run script
echo @echo off > "%PACKAGE_DIR%\run.bat"
echo start "" "%~dp0PharmacyExpenseTracker.exe" >> "%PACKAGE_DIR%\run.bat"

:: Create README
echo Pharmacy Expense Tracker > "%PACKAGE_DIR%\README.txt"
echo ====================== >> "%PACKAGE_DIR%\README.txt"
echo. >> "%PACKAGE_DIR%\README.txt"
echo To start the application, double-click 'run.bat' or 'PharmacyExpenseTracker.exe' >> "%PACKAGE_DIR%\README.txt"
echo. >> "%PACKAGE_DIR%\README.txt"
echo Default login: >> "%PACKAGE_DIR%\README.txt"
echo   Username: admin >> "%PACKAGE_DIR%\README.txt"
echo   Password: admin123 (change this after first login) >> "%PACKAGE_DIR%\README.txt"

:: Create ZIP archive
echo [*] Creating ZIP archive... >> "%LOGFILE%"
powershell -command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%DIST_DIR%\PharmacyExpenseTracker_%TIMESTAMP%.zip' -Force" >> "%LOGFILE%" 2>&1

if %ERRORLEVEL% EQU 0 (
    echo [*] Build completed successfully! >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    echo [*] Build completed successfully!
    echo [*] Executable: %PACKAGE_DIR%\PharmacyExpenseTracker.exe
    echo [*] Package: %DIST_DIR%\PharmacyExpenseTracker_%TIMESTAMP%.zip
) else (
    echo [ERROR] Failed to create ZIP archive >> "%LOGFILE%"
    echo [ERROR] Failed to create ZIP archive
)

