# Secure Build Guide - Maximum Code Protection

## Overview
This guide explains how to create secure builds of the Pharmacy Expense Tracker that completely hide the source code from end users while providing a professional installation experience.

## Security Features

### 1. **Single-File Executable**
- All Python code compiled into a single `.exe` file
- No visible Python source files
- Users cannot access the original code

### 2. **Code Obfuscation (Optional)**
- PyArmor protection for reverse engineering prevention
- Advanced obfuscation modes available
- Restriction modes to prevent debugging

### 3. **Professional Installer**
- Inno Setup creates professional Windows installer
- Single `.exe` installer for easy distribution
- Automatic shortcuts creation
- Clean uninstall support

### 4. **File Protection**
- All data files hidden with system attributes
- Configuration files hidden from casual users
- Resources embedded in application

## Prerequisites

### Required Tools
1. **Python 3.7+** - Download from https://python.org/
2. **PyInstaller** - Included in requirements
3. **Inno Setup 6+** - Download from https://jrsoftware.org/isdl.php (for professional installer)

### Optional Tools
1. **PyArmor** - For advanced code obfuscation: `pip install pyarmor`
2. **GitHub CLI** - For automatic releases: https://cli.github.com/
3. **Digital Certificate** - For code signing (optional)

## Installation Instructions

### Step 1: Install Dependencies
```batch
pip install -r requirements_windows.txt
```

### Step 2: Install Inno Setup (Optional but Recommended)
1. Download from: https://jrsoftware.org/isdl.php
2. Run the installer
3. Default installation location is fine
4. The build script will auto-detect it

### Step 3: Configure Build Settings
Edit `build_secure.bat` and update these variables:

```batch
:: GitHub Configuration
set GITHUB_REPO=yourusername/Pharmacy-Expense-Tracker
set GITHUB_TOKEN=your_token_here  (optional)
set CREATE_GITHUB_RELEASE=false  (set to true after testing)

:: Security Configuration  
set USE_PYARMOR=false  (set to true for obfuscation)
set PYARMOR_LICENSE=    (PyArmor license if you have one)
set USE_ENCRYPTION=true (PyInstaller built-in encryption)
```

### Step 4: Configure Updater
Edit `app_updater.py`:
```python
GITHUB_REPO = "yourusername/Pharmacy-Expense-Tracker"
GITHUB_TOKEN = ""  (optional)
```

### Step 5: Configure Installer Script
Edit `installer_script.iss`:
```pascal
AppName=Pharmacy Expense Tracker
AppVersion=1.0.0  (will be auto-updated by build script)
AppPublisher=Your Company Name
```

## Building Secure Executables

### Basic Build (No Obfuscation)
```batch
build_secure.bat
```

### Advanced Build (With PyArmor Obfuscation)
1. Install PyArmor: `pip install pyarmor`
2. Enable in `build_secure.bat`: `set USE_PYARMOR=true`
3. Run: `build_secure.bat`

### With Automatic GitHub Release
1. Install GitHub CLI: https://cli.github.com/
2. Authenticate: `gh auth login`
3. Enable in `build_secure.bat`: `set CREATE_GITHUB_RELEASE=true`
4. Run: `build_secure.bat`

## Build Output

The build process creates:

### 1. **Single-File Executable** (Most Secure)
- Location: `dist/PharmacyExpenseTracker.exe`
- Contains entire application in one file
- Maximum code protection
- No visible source code

### 2. **Professional Installer** (If Inno Setup Available)
- Location: `dist/PharmacyExpenseTracker_Setup_v1.0.0.exe`
- Professional Windows installer
- Creates shortcuts, registry entries
- Easy uninstall support
- Recommended for distribution

### 3. **Manual Package** (Fallback)
- Location: `dist/PharmacyExpenseTracker_Manual_v1.0.0.zip`
- ZIP file with executable and hidden files
- For systems without Inno Setup

## Security Levels

### Level 1: Basic Protection (Default)
- Single-file executable
- PyInstaller compilation
- Hidden data files
- UPX compression

### Level 2: Enhanced Protection
- Level 1 features
- PyArmor obfuscation
- Advanced code protection
- Restriction modes

### Level 3: Maximum Protection
- Level 2 features
- Custom encryption keys
- Hardware binding
- License expiration
- Digital signature

## Code Obfuscation Options

### PyArmor Configuration
Edit `pyarmor_config.py` to customize:

```python
PYARMOR_CONFIG = {
    'obf_mode': 1,           # 0 = normal, 1 = advanced
    'restrict_mode': 1,      # 0 = no restriction, 1 = restrict
    'expired_days': 0,       # 0 = permanent, N = expire after N days
    'bind_disk': False,      # Bind to hard disk
    'bind_mac': False,       # Bind to MAC address
}
```

### Hardware Binding (Optional)
To prevent copying between machines:
```python
'bind_disk': True,  # Binds to hard disk serial
'bind_mac': True,   # Binds to network adapter
```

### License Expiration (Optional)
To create time-limited versions:
```python
'expired_days': 30,  # Expires after 30 days
```

## Digital Signature (Optional)

### Why Sign Your Executable?
- Windows SmartScreen warnings
- User trust
- Antivirus whitelist
- Professional appearance

### How to Sign
1. Purchase code signing certificate
2. Configure in Inno Setup script:
```pascal
SignTool=mycert
```
3. Or sign manually after build:
```batch
signtool sign /f certificate.pfx /p password dist\PharmacyExpenseTracker.exe
```

## Distribution Methods

### Method 1: Professional Installer (Recommended)
- Use `PharmacyExpenseTracker_Setup_vX.X.X.exe`
- Double-click to install
- Professional appearance
- Automatic updates support

### Method 2: Single File
- Use `PharmacyExpenseTracker.exe`
- Copy to any location
- No installation required
- Manual updates only

### Method 3: Manual Package
- Extract `PharmacyExpenseTracker_Manual_vX.X.X.zip`
- Run `install.bat`
- Simple installation
- Manual updates

## Troubleshooting

### Build Fails
- Check `build_secure/build_log.txt` for errors
- Ensure all dependencies are installed
- Verify Python 3.7+ is installed
- Check file permissions

### PyArmor Errors
- Ensure PyArmor is installed: `pip install pyarmor`
- Check PyArmor license if using commercial features
- Verify source file exists

### Inno Setup Not Found
- Download from: https://jrsoftware.org/isdl.php
- Build script will fall back to manual package
- Or set `INNO_SETUP_PATH` manually

### Executable Won't Run
- Check Windows Defender/antivirus
- Try running as administrator
- Verify all dependencies are included
- Check Event Viewer for errors

### Update System Not Working
- Verify GitHub repository URL is correct
- Check internet connection
- Ensure `app_updater.py` is included
- Verify version.json format

## Security Best Practices

### 1. Keep Source Code Private
- Use private GitHub repository
- Never distribute source files
- Use the secure build process

### 2. Version Control
- Always use semantic versioning
- Update changelog in version.json
- Mark critical updates appropriately

### 3. Test Before Release
- Test installer on clean system
- Verify update system works
- Check all functionality
- Test on different Windows versions

### 4. Monitor Distribution
- Track installation success rate
- Monitor update adoption
- Gather user feedback
- Watch for security issues

## Advanced Configuration

### Custom Encryption Keys
Generate custom encryption keys:
```python
import secrets
key = secrets.token_hex(16)
print(key)  # Use this in build script
```

### Custom Install Locations
Modify installer script:
```pascal
DefaultDirName={autopf}\PharmacyExpenseTracker
```

### Silent Installation
Support silent installs:
```pascal
[Setup]
CreateAppDir=yes
Uninstallable=yes
```

Users can install silently:
```batch
PharmacyExpenseTracker_Setup.exe /VERYSILENT /SUPPRESSMSGBOXES
```

## Performance Optimization

### Build Speed
- Use SSD for build directory
- Exclude unnecessary modules
- Disable UPX during development
- Use incremental builds

### Runtime Performance
- Exclude unused Python modules
- Use UPX compression
- Optimize resource loading
- Profile and optimize hot paths

## Compliance and Licensing

### Open Source Compliance
- Ensure all dependencies have compatible licenses
- Include license attributions
- Follow PyQt5 licensing requirements
- Document third-party components

### Commercial Distribution
- Consider commercial PyArmor license
- Get code signing certificate
- Ensure compliance with local laws
- Provide proper support channels

## Support and Maintenance

### Build Logs
- All logs saved to `build_secure/build_log.txt`
- Check logs for troubleshooting
- Archive logs for each release

### Version Management
- Version numbers auto-incremented
- version.json tracks all versions
- Keep changelog updated

### Update System
- Configure GitHub repository
- Set up release process
- Test update mechanism
- Monitor update success rate

## Next Steps

1. ✅ Complete initial secure build
2. ✅ Test installer on clean system
3. ✅ Configure automatic updates
4. ✅ Set up GitHub releases
5. ✅ Deploy to production
6. ✅ Monitor and maintain

## Additional Resources

- PyInstaller Documentation: https://pyinstaller.org/
- PyArmor Documentation: https://pyarmor.readthedocs.io/
- Inno Setup Documentation: https://jrsoftware.org/ishelp/
- Windows Security Guidelines: https://docs.microsoft.com/windows/security/