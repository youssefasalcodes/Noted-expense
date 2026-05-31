# Quick Build Reference - Pharmacy Expense Tracker

## Quick Start (5 minutes)

### 1. Basic Secure Build
```batch
build_secure.bat
```

### 2. Build with PyArmor Obfuscation
```batch
pip install pyarmor
# Edit build_secure.bat: set USE_PYARMOR=true
build_secure.bat
```

### 3. Build with Professional Installer
```batch
# Install Inno Setup from https://jrsoftware.org/isdl.php/
build_secure.bat
# Creates: PharmacyExpenseTracker_Setup_vX.X.X.exe
```

### 4. Build with Auto-Release to GitHub
```batch
# Install GitHub CLI from https://cli.github.com/
gh auth login
# Edit build_secure.bat: set CREATE_GITHUB_RELEASE=true
# Edit build_secure.bat: set GITHUB_REPO=yourusername/your-repo
build_secure.bat
```

## Configuration Files

### build_secure.bat (Main Build Script)
```batch
set GITHUB_REPO=yourusername/Pharmacy-Expense-Tracker
set CREATE_GITHUB_RELEASE=false
set USE_PYARMOR=false
set USE_ENCRYPTION=true
```

### app_updater.py (Update System)
```python
GITHUB_REPO = "yourusername/Pharmacy-Expense-Tracker"
GITHUB_TOKEN = ""  # Optional
```

### installer_script.iss (Professional Installer)
```pascal
AppName=Pharmacy Expense Tracker
AppVersion=1.0.0  # Auto-updated by build script
```

### version.json (Version Control)
```json
{
  "version": "1.0.0",
  "release_date": "2025-01-18",
  "changelog": "Update description",
  "critical": false
}
```

## Build Outputs

### Files Created
1. `dist/PharmacyExpenseTracker.exe` - Single-file executable (most secure)
2. `dist/PharmacyExpenseTracker_Setup_vX.X.X.exe` - Professional installer (if Inno Setup available)
3. `dist/PharmacyExpenseTracker_Manual_vX.X.X.zip` - Manual package (fallback)
4. `build_secure/build_log.txt` - Build log

### Distribution to Users
- **Recommended**: Send the `.exe` installer file
- **Alternative**: Send the single `.exe` file
- **Emergency**: Send the ZIP package

## Common Commands

### Check Python Version
```batch
python --version
```

### Install Dependencies
```batch
pip install -r requirements_windows.txt
```

### Install PyArmor (Optional)
```batch
pip install pyarmor
```

### Test Compilation
```batch
python -m py_compile Test.py
python -m py_compile app_updater.py
```

### Manual PyInstaller Build
```batch
pyinstaller --onefile --windowed --icon=resources/images/Pharmacist.ico Test.py
```

### Manual Inno Setup Build
```batch
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer_script.iss
```

## Security Levels

### Level 1: Basic (Default)
- Single-file executable
- PyInstaller compilation
- Hidden data files
- UPX compression

### Level 2: Enhanced
- Level 1 + PyArmor obfuscation
- Advanced code protection
- Restriction modes

### Level 3: Maximum
- Level 2 + Custom encryption
- Hardware binding
- License expiration
- Digital signature

## Troubleshooting

### Build Fails
- Check `build_secure/build_log.txt`
- Ensure Python 3.7+ installed
- Verify all dependencies installed
- Check file permissions

### PyArmor Issues
- `pip install pyarmor`
- Check PyArmor license
- Verify source file exists

### Inno Setup Not Found
- Download: https://jrsoftware.org/isdl.php/
- Or use manual package output

### Update System Issues
- Verify GitHub repository URL
- Check internet connection
- Ensure `app_updater.py` included

## Version Management

### Increment Version
- Automatic in build script
- Or edit `version.json` manually
- Format: MAJOR.MINOR.PATCH

### Release Types
- **Major**: New features, breaking changes (2.0.0)
- **Minor**: New features, backwards compatible (1.1.0)
- **Patch**: Bug fixes (1.0.1)

### Critical Updates
- Set `"critical": true` in version.json
- Users forced to update
- Use for security fixes only

## Distribution Checklist

### Before Release
- [ ] Test build on clean system
- [ ] Verify all functionality works
- [ ] Test update system
- [ ] Check file size acceptable
- [ ] Update changelog
- [ ] Verify version number

### Release Process
- [ ] Run build script
- [ ] Test installer
- [ ] Create GitHub release (if using)
- [ ] Update documentation
- [ ] Notify users
- [ ] Monitor feedback

### After Release
- [ ] Monitor installation success
- [ ] Track update adoption
- [ ] Gather user feedback
- [ ] Address issues quickly

## File Structure

### Source Files
```
Pharmacy app/
├── Test.py (main application)
├── app_updater.py (update system)
├── version.json (version control)
├── build_secure.bat (secure build script)
├── installer_script.iss (installer config)
├── pyarmor_config.py (obfuscation config)
└── requirements_windows.txt (dependencies)
```

### Build Output
```
dist/
├── PharmacyExpenseTracker.exe (single file)
├── PharmacyExpenseTracker_Setup_v1.0.0.exe (installer)
└── PharmacyExpenseTracker_Manual_v1.0.0.zip (manual package)
```

### Installed Files
```
C:\Program Files\PharmacyExpenseTracker\
├── PharmacyExpenseTracker.exe
├── users.json (hidden)
├── data.encrypted (hidden)
├── version.json (hidden)
├── resources/ (hidden)
└── app_updater.py (hidden)
```

## Performance Tips

### Build Speed
- Use SSD for build directory
- Exclude unused modules
- Disable UPX during development
- Use incremental builds

### File Size
- Exclude unused dependencies
- Use UPX compression
- Optimize resource files
- Consider delta updates

## Advanced Options

### Custom Encryption
```python
import secrets
key = secrets.token_hex(16)
```

### Silent Installation
```batch
PharmacyExpenseTracker_Setup.exe /VERYSILENT /SUPPRESSMSGBOXES
```

### Hardware Binding
```python
'bind_disk': True,  # In pyarmor_config.py
'bind_mac': True,
```

### License Expiration
```python
'expired_days': 30,  # In pyarmor_config.py
```

## Quick Reference Commands

### Development
```batch
# Test compilation
python -m py_compile Test.py

# Run application
python Test.py

# Quick build (not secure)
pyinstaller --onefile Test.py
```

### Production
```batch
# Secure build
build_secure.bat

# With obfuscation
# set USE_PYARMOR=true in build_secure.bat
build_secure.bat

# With auto-release
# set CREATE_GITHUB_RELEASE=true in build_secure.bat
build_secure.bat
```

### Maintenance
```batch
# Clean build directories
rmdir /s build_secure
rmdir / dist

# Update dependencies
pip install --upgrade -r requirements_windows.txt

# Check for updates
pip list --outdated
```

## Support Documentation

### Main Documentation
- `SECURE_BUILD_GUIDE.md` - Comprehensive build guide
- `USER_INSTALLATION_GUIDE.md` - End user installation guide
- `UPDATE_SETUP_GUIDE.md` - Update system setup
- `UPDATE_QUICKSTART.md` - Quick update system start

### Configuration Files
- `build_secure.bat` - Build script with comments
- `installer_script.iss` - Inno Setup script
- `app_updater.py` - Update system code
- `pyarmor_config.py` - PyArmor configuration

## Emergency Procedures

### Build Failure
1. Check `build_secure/build_log.txt`
2. Verify dependencies installed
3. Try clean build (delete build directories)
4. Test individual components

### Distribution Error
1. Use fallback manual package
2. Verify file integrity
3. Test on different system
4. Contact support if needed

### Update System Failure
1. Users can download manually from GitHub
2. Provide direct download link
3. Disable auto-updates temporarily
4. Fix and republish update

---

**For detailed information, see the comprehensive guides.**