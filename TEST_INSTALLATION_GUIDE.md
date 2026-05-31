# Testing Installation Guide - Step by Step

## Quick Test Setup (10 minutes)

### Step 1: Install Inno Setup (Optional but Recommended)

#### Download Inno Setup
1. Go to: https://jrsoftware.org/isdl.php
2. Download "Inno Setup 6" (latest version)
3. Run the installer
4. Accept default settings
5. Complete installation

**Note**: If you skip this, the build will still work but will create a manual package instead of a professional installer.

### Step 2: Configure GitHub Repository (Skip if not using GitHub)

If you want to test with GitHub updates:
1. Edit `app_updater.py` (line ~12):
   ```python
   GITHUB_REPO = "yourusername/Pharmacy-Expense-Tracker"
   ```

2. Edit `build_secure.bat` (line ~5):
   ```batch
   set GITHUB_REPO=yourusername/Pharmacy-Expense-Tracker
   ```

**For now, you can skip this and test the local build first.**

### Step 3: Run the Secure Build

1. Open Command Prompt in your project directory:
   ```batch
   cd "c:/Users/youssef asal/Desktop/Projects/Pharmacy app"
   ```

2. Run the secure build script:
   ```batch
   build_secure.bat
   ```

3. Wait for the build to complete (2-5 minutes)

4. Check the output:
   - You should see: "SECURE BUILD COMPLETED SUCCESSFULLY!"
   - Check `build_secure/build_log.txt` if there are errors

### Step 4: Locate the Build Output

After successful build, check these locations:

#### Primary Output (Always Created)
```
dist/PharmacyExpenseTracker.exe
```
- This is the single-file executable
- All code is hidden inside
- Can be distributed directly

#### Professional Installer (If Inno Setup installed)
```
dist/PharmacyExpenseTracker_Setup_v1.0.0.exe
```
- Professional Windows installer
- Recommended for distribution
- Best user experience

#### Manual Package (Fallback)
```
dist/PharmacyExpenseTracker_Manual_v1.0.0.zip
```
- ZIP package with all files
- For systems without Inno Setup
- Manual installation required

### Step 5: Test the Professional Installer (Recommended)

#### If Inno Setup was installed:

1. **Run the installer:**
   - Navigate to `dist/` folder
   - Double-click `PharmacyExpenseTracker_Setup_v1.0.0.exe`

2. **Follow the installation wizard:**
   - Select language (Arabic or English)
   - Accept license terms
   - Choose installation location (default is fine)
   - Create desktop shortcut (recommended)
   - Click "Install"

3. **Launch the application:**
   - Check "Launch Pharmacy Expense Tracker" and click "Finish"
   - Or double-click the desktop shortcut

4. **Verify installation:**
   - Application should start normally
   - Login with default credentials (admin/admin123)
   - Test basic functionality

5. **Check that code is hidden:**
   - Navigate to installation folder (usually `C:\Program Files\PharmacyExpenseTracker`)
   - You should see: `PharmacyExpenseTracker.exe` and some hidden files
   - **IMPORTANT**: No `.py` files should be visible
   - Data files should be hidden (marked with hidden attribute)

### Step 6: Test the Single-File Executable (Alternative)

#### If you want to test the single-file version:

1. **Navigate to `dist/` folder**

2. **Double-click `PharmacyExpenseTracker.exe`**
   - Application should start immediately
   - No installation required
   - All functionality should work

3. **Verify it's a single file:**
   - Check file properties
   - It should be a single executable
   - No other files should be required to run it

### Step 7: Test Security Features

#### Verify Code Protection:

1. **Check for Python files:**
   ```batch
   dir *.py
   ```
   - Should find NO `.py` files in the installation directory

2. **Check for source code:**
   - Try to open the `.exe` file in a text editor
   - You should see binary/garbled data, not readable code
   - No source code should be visible

3. **Check hidden files:**
   - In File Explorer, go to View → Options → View
   - Enable "Show hidden files, folders, and drives"
   - You should see some hidden files (users.json, data.encrypted, etc.)
   - These should be marked as hidden/system files

#### Test Update System:

1. **Click "فحص التحديثات" (Check for Updates) button**
2. If GitHub is configured, it should check for updates
3. If not configured, it should show an error message (expected)

### Step 8: Test Uninstallation

#### Uninstall the application:

1. **Go to Control Panel → Programs and Features**
2. **Find "Pharmacy Expense Tracker"**
3. **Right-click and select "Uninstall"**
4. **Follow the uninstall wizard**
5. **Verify removal:**
   - Application folder should be deleted
   - Desktop shortcut should be removed
   - Start menu entry should be removed

### Step 9: Test Without Inno Setup (If you didn't install it)

If you skipped Inno Setup installation:

1. **Extract the manual package:**
   - Navigate to `dist/` folder
   - Right-click `PharmacyExpenseTracker_Manual_v1.0.0.zip`
   - Select "Extract All"
   - Choose a location (e.g., Desktop)

2. **Run the manual installer:**
   - Open the extracted folder
   - Double-click `install.bat`
   - Follow the prompts

3. **Test the application:**
   - It should work the same as the professional installer
   - Just less polished installation experience

## Troubleshooting

### Build Fails

**Error: "Python 3.7 or later is required"**
- Install Python 3.7 or later from python.org
- Update your PATH environment variable

**Error: "Failed to install dependencies"**
- Run manually: `pip install -r requirements_windows.txt`
- Check your internet connection

**Error: "PyInstaller build failed"**
- Check `build_secure/build_log.txt` for details
- Ensure no other programs are locking files
- Try running as administrator

### Installation Fails

**Error: "Inno Setup not found"**
- This is normal if you didn't install Inno Setup
- Use the manual package instead
- Or install Inno Setup and rebuild

**Error: "Access denied"**
- Run installer as administrator
- Check permissions on installation directory

**Error: "Application won't start"**
- Check Windows Defender/antivirus
- Try running as administrator
- Check Event Viewer for errors

### Security Verification Fails

**I can still see Python files**
- Make sure you ran `build_secure.bat`, not the old `build_windows.bat`
- Check that you're looking at the installation directory, not source directory
- Verify build completed successfully

**I can see configuration files**
- Some files are intentionally present but hidden
- They should be marked as hidden/system
- Users won't typically see them

## Quick Verification Checklist

After installation, verify:

- [ ] Application starts successfully
- [ ] Login works with admin/admin123
- [ ] No `.py` files visible in installation directory
- [ ] Main executable is a single file
- [ ] Data files are hidden from normal view
- [ ] Desktop shortcut created (if selected)
- [ ] Application appears in Programs and Features
- [ ] Uninstall works correctly
- [ ] Re-installation works after uninstall

## Performance Testing

1. **Launch time**: Should be similar to original version
2. **Memory usage**: Should be comparable or slightly higher
3. **Functionality**: All features should work normally
4. **Data saving**: Encrypted data should save correctly
5. **Updates**: Update button should be accessible

## Next Steps After Testing

### If Everything Works:
1. ✅ Configure your GitHub repository
2. ✅ Create your first GitHub release
3. ✅ Test the remote update system
4. ✅ Deploy to a few test users
5. ✅ Gather feedback
6. ✅ Deploy to all users

### If You Find Issues:
1. Check `build_secure/build_log.txt` for build errors
2. Test with Inno Setup installed for better results
3. Try the single-file executable as alternative
4. Review the comprehensive documentation
5. Adjust configuration as needed

## Professional vs. Quick Test

### Quick Test (5 minutes)
1. Run: `build_secure.bat`
2. Test: `dist/PharmacyExpenseTracker.exe`
3. Verify: No Python files visible

### Professional Test (15 minutes)
1. Install Inno Setup
2. Run: `build_secure.bat`
3. Test: Professional installer
4. Verify: Complete installation experience

### Comprehensive Test (30 minutes)
1. Professional test steps
2. Test all functionality
3. Test update system
4. Test uninstall/reinstall
5. Verify all security features

## Need Help?

If you encounter any issues:

1. Check the build log: `build_secure/build_log.txt`
2. Review documentation files in the project
3. Verify all prerequisites are installed
4. Try the simpler single-file test first
5. Check that you're using the new `build_secure.bat`

---

**You should now have a fully functional, secure installer that hides all your source code!**