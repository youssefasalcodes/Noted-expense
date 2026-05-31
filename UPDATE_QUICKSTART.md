# Quick Start Guide - Remote Update System

## Initial Setup (5 minutes)

### 1. Create GitHub Repository
- Go to GitHub.com and create a new repository
- Name it something like "Pharmacy-Expense-Tracker"
- Make it private if desired
- Copy the repository name: `yourusername/Pharmacy-Expense-Tracker`

### 2. Update Configuration Files

#### Edit `app_updater.py` (line ~12):
```python
GITHUB_REPO = "yourusername/Pharmacy-Expense-Tracker"  # Change this
```

#### Edit `build_windows.bat` (lines ~5-7):
```batch
set GITHUB_REPO=yourusername/Pharmacy-Expense-Tracker  # Change this
set GITHUB_TOKEN=  # Optional: Add GitHub token for private repos
set CREATE_GITHUB_RELEASE=false  # Set to true after installing GitHub CLI
```

### 3. Install Dependencies
```batch
pip install requests
```

Or update all dependencies:
```batch
pip install -r requirements_windows.txt
```

## Creating Your First Update

### Option A: Automatic (Recommended for future updates)
1. Install GitHub CLI: https://cli.github.com/
2. Authenticate: `gh auth login`
3. Set `CREATE_GITHUB_RELEASE=true` in `build_windows.bat`
4. Run: `build_windows.bat`

### Option B: Manual (Quick start)
1. Run: `build_windows.bat`
2. Go to GitHub → Your repository → Releases
3. Click "Create a new release"
4. Tag: `v1.0.1` (must match version.json)
5. Upload ZIP from `dist/` folder
6. Add release notes and publish

## How Users Update

### Automatic
- App checks on startup
- Users get notified of updates
- Critical updates prompt immediately

### Manual
- Users click "فحص التحديثات" button
- Review and install updates

## Testing Without GitHub

To test locally without GitHub:
1. Comment out GitHub API calls in `app_updater.py`
2. Use local file for version checking
3. Manually simulate updates

## Common Issues

**"Updater module not available"**
- Ensure `app_updater.py` is in the same directory as `Test.py`
- Check that requests library is installed

**"Could not fetch release information"**
- Check internet connection
- Verify GitHub repository URL is correct
- Ensure repository is public or token is provided

**"Update failed"**
- Check write permissions in app directory
- Ensure antivirus is not blocking the update
- Verify sufficient disk space

## Security Tips

1. **Keep repository private** - Prevents unauthorized access
2. **Use GitHub token** - For private repos and rate limits
3. **Verify updates** - Only update from official GitHub releases
4. **Test updates** - Test on a machine before deploying to all users

## Next Steps

1. ✅ Complete initial setup
2. ✅ Test the update system
3. ✅ Deploy to a few users
4. ✅ Monitor update success rate
5. ✅ Scale to all users

## Support

- Detailed guide: `UPDATE_SETUP_GUIDE.md`
- Check logs: `build/build_log.txt`
- App errors: `app_error.log`