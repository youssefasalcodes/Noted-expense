# Pharmacy App Remote Update System - Setup Guide

## Overview
This update system allows you to remotely update all users' applications through GitHub releases. Users can check for updates manually, and the app can automatically notify them of new versions.

## Components

### 1. Version Management (`version.json`)
- Tracks current application version
- Contains changelog and critical update flags
- Automatically updated during build process

### 2. Updater Module (`app_updater.py`)
- Checks GitHub API for latest releases
- Downloads and installs updates
- Handles critical vs. optional updates
- Includes Arabic UI for update dialogs

### 3. Enhanced Build Script (`build_windows.bat`)
- Automatically increments version numbers
- Creates GitHub releases (optional)
- Includes all necessary files in distribution

## Setup Instructions

### Step 1: Create GitHub Repository
1. Create a new GitHub repository for your application
2. Make it private if you want to control access
3. Note the repository name in format: `username/repository-name`

### Step 2: Configure Build Script
Edit `build_windows.bat` and update these variables:

```batch
set GITHUB_REPO=yourusername/Pharmacy-Expense-Tracker
set GITHUB_TOKEN=your_github_token  (optional)
set CREATE_GITHUB_RELEASE=true  (set to true to enable auto-releases)
```

### Step 3: Configure Updater Module
Edit `app_updater.py` and update these constants:

```python
GITHUB_REPO = "yourusername/Pharmacy-Expense-Tracker"  # Your GitHub repo
GITHUB_TOKEN = ""  # Optional: Add for private repos or rate limit increases
```

### Step 4: Install GitHub CLI (Optional)
For automatic GitHub release creation:
1. Download from: https://cli.github.com/
2. Install and authenticate: `gh auth login`
3. Grant repository permissions

### Step 5: Build and Release
1. Run the build script: `build_windows.bat`
2. The script will:
   - Increment version number automatically
   - Build the application
   - Create ZIP package
   - Optionally create GitHub release

### Step 6: Manual Release (if auto-release disabled)
If you prefer manual control:
1. Build the application
2. Go to GitHub repository → Releases
3. Click "Create a new release"
4. Tag version: `v1.0.0` (match version.json)
5. Upload the ZIP file from `dist/` folder
6. Add release notes

## Usage for End Users

### Automatic Updates
- App checks for updates on startup
- Critical updates prompt user immediately
- Optional updates show notification

### Manual Updates
- Click "فحص التحديثات" (Check for Updates) button
- Review available updates and release notes
- Click "تثبيت التحديث" (Install Update) to apply

## Version Control

### Version Format
- Uses semantic versioning: `MAJOR.MINOR.PATCH`
- Example: `1.0.0`, `1.0.1`, `1.1.0`, `2.0.0`

### Critical Updates
Mark an update as critical by:
1. Edit `version.json` before building
2. Set `"critical": true`
3. Users will be forced to update

### Release Notes
Add meaningful changelog in `version.json`:
```json
{
  "version": "1.1.0",
  "release_date": "2025-01-18",
  "changelog": "Added new features and bug fixes",
  "critical": false,
  "min_required_version": "1.0.0"
}
```

## Security Considerations

### Source Code Protection
- PyInstaller compiles Python to executable
- Source code is not exposed to end users
- Users only receive the `.exe` and required data files

### GitHub Repository
- Use private repository for additional security
- Add GitHub token for authentication
- Control who has access to releases

### Update Verification
- Updates are downloaded from official GitHub releases
- Version verification prevents unauthorized updates
- Backup/restore mechanism for failed updates

## Troubleshooting

### Build Issues
- Ensure all dependencies are installed
- Check `build/build_log.txt` for errors
- Verify Python 3.7+ is installed

### Update Issues
- Check internet connectivity
- Verify GitHub repository URL is correct
- Ensure GitHub token has proper permissions

### GitHub CLI Issues
- Install latest version from https://cli.github.com/
- Authenticate with `gh auth login`
- Verify repository permissions

## Advanced Configuration

### Custom Update Server
To use a custom server instead of GitHub:
1. Modify `UpdateChecker.get_latest_release()` in `app_updater.py`
2. Point to your custom API endpoint
3. Implement version checking logic

### Forced Updates
To force all users to update to a minimum version:
1. Set `min_required_version` in `version.json`
2. Modify updater to check this field
3. Block app startup if below minimum version

### Delta Updates
For smaller update sizes:
1. Implement differential updates
2. Download only changed files
3. Requires more complex file management

## File Structure After Build

```
dist/PharmacyExpenseTracker/
├── PharmacyExpenseTracker.exe  (Main application)
├── version.json                 (Version information)
├── app_updater.py              (Update module)
├── users.json                  (User data)
├── data.encrypted              (Encrypted data)
├── resources/                  (Resources folder)
├── Insert_data.ui              (UI file)
├── resources_rc.py            (Resources module)
├── run.bat                    (Run script)
└── README.txt                 (Documentation)
```

## Support

For issues or questions:
1. Check build logs in `build/build_log.txt`
2. Review app logs in `app_error.log`
3. Verify GitHub repository settings
4. Ensure all dependencies are current