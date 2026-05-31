# Pharmacy Expense Tracker - Installation Guide

## Welcome!
Thank you for choosing Pharmacy Expense Tracker. This guide will help you install the application on your Windows computer.

## System Requirements

### Minimum Requirements
- **Operating System**: Windows 7, 8, 10, or 11
- **Memory**: 2 GB RAM minimum
- **Storage**: 100 MB free disk space
- **Display**: 1024x768 resolution or higher

### Recommended Requirements
- **Operating System**: Windows 10 or 11
- **Memory**: 4 GB RAM or more
- **Storage**: 500 MB free disk space
- **Display**: 1920x1080 resolution or higher
- **Internet Connection**: For automatic updates

## Installation Methods

### Method 1: Professional Installer (Recommended)

#### Step 1: Download the Installer
- You will receive a file named: `PharmacyExpenseTracker_Setup_vX.X.X.exe`
- Save it to your Downloads folder or desktop

#### Step 2: Run the Installer
1. Double-click the installer file
2. If Windows shows a security warning, click "More info" then "Run anyway"
3. Click "Yes" if prompted for administrator permissions
4. Select your language (Arabic or English)
5. Click "I Agree" to accept the license terms

#### Step 3: Choose Installation Location
- Default location: `C:\Program Files\PharmacyExpenseTracker`
- Click "Browse" to choose a different location if needed
- Click "Next" to continue

#### Step 4: Create Shortcuts
- Check "Create desktop icon" for quick access
- Click "Next" to continue

#### Step 5: Install
- Click "Install" to begin installation
- Wait for the installation to complete (usually 1-2 minutes)
- Click "Finish" when done

#### Step 6: Launch the Application
- Check "Launch Pharmacy Expense Tracker" and click "Finish"
- The application will start automatically
- You can also access it from your desktop or Start menu

### Method 2: Single File Installation

#### Step 1: Download the Application
- You will receive a file named: `PharmacyExpenseTracker.exe`
- Save it to any location on your computer

#### Step 2: Create Application Folder (Optional)
- Create a new folder named "PharmacyExpenseTracker"
- Move the `PharmacyExpenseTracker.exe` file into this folder

#### Step 3: Run the Application
- Double-click `PharmacyExpenseTracker.exe`
- The application will start immediately
- No installation required

### Method 3: Manual Package Installation

#### Step 1: Download and Extract
- Download the ZIP file: `PharmacyExpenseTracker_Manual_vX.X.X.zip`
- Right-click and select "Extract All"
- Choose a location for extraction

#### Step 2: Run the Installer
- Open the extracted folder
- Double-click `install.bat`
- Follow the on-screen instructions

#### Step 3: Launch the Application
- After installation, you can launch from your Start menu
- Or navigate to the installation folder and run the executable

## First-Time Setup

### Default Login Credentials
```
Username: admin
Password: admin123
```

**IMPORTANT**: Change the default password after first login!

### Change Password
1. Login with default credentials
2. Go to "إدارة المستخدمين" (User Management)
3. Click "تغيير كلمة المرور" (Change Password)
4. Enter your new password
5. Confirm and save

### Create Additional Users (Optional)
1. Go to "إدارة المستخدمين" (User Management)
2. Click "إضافة مستخدم" (Add User)
3. Enter username and password
4. Select user role (Admin or Regular)
5. Click to save

## Updating the Application

### Automatic Updates
The application checks for updates automatically when you start it. If an update is available:
- Critical updates: You'll be prompted to update immediately
- Optional updates: You'll be notified and can choose to update later

### Manual Updates
1. Click "فحص التحديثات" (Check for Updates) button
2. Review available updates
3. Click "تثبيت التحديث" (Install Update) to apply

### Update Notifications
- The application notifies you when updates are available
- You can choose when to install optional updates
- Critical updates should be installed immediately

## Troubleshooting

### Installation Issues

**Windows Defender Warning**
- Click "More info" then "Run anyway"
- The application is safe and digitally signed
- Add exception to Windows Defender if needed

**Administrator Access Required**
- Right-click the installer
- Select "Run as administrator"
- Enter administrator credentials if prompted

**Insufficient Permissions**
- Ensure you have write access to installation directory
- Try installing to a different location
- Contact your IT administrator

### Runtime Issues

**Application Won't Start**
- Check Windows Event Viewer for errors
- Disable antivirus temporarily to test
- Run as administrator
- Check .NET Framework is installed

**Missing Files Error**
- Reinstall the application
- Ensure all files were extracted from ZIP
- Check antivirus didn't quarantine files

**Data Not Saving**
- Ensure you have write permissions to app directory
- Check available disk space
- Disable antivirus temporarily

### Network Issues

**Updates Not Working**
- Check internet connection
- Verify firewall allows the application
- Check GitHub repository is accessible
- Try manual update download

## Uninstallation

### Using Professional Installer
1. Go to Control Panel → Programs and Features
2. Find "Pharmacy Expense Tracker"
3. Right-click and select "Uninstall"
4. Follow the uninstall wizard

### Manual Removal
1. Close the application
2. Delete the application folder
3. Remove desktop shortcuts
4. Clean registry entries (advanced users)

## Data Backup

### Automatic Data Location
- Application data is stored in the installation directory
- Files: `users.json`, `data.encrypted`
- Keep backups of these files

### Manual Backup
1. Close the application
2. Navigate to installation directory
3. Copy `users.json` and `data.encrypted`
4. Save to a safe location (USB drive, cloud storage)

### Restore Backup
1. Close the application
2. Replace the current files with your backups
3. Restart the application

## Security Tips

### Password Security
- Use strong passwords (min 8 characters)
- Include numbers and special characters
- Change passwords regularly
- Don't share passwords

### Data Protection
- Keep your data files backed up
- Store backups in secure locations
- Don't share encrypted data files
- Use encrypted storage for sensitive data

### Application Security
- Keep the application updated
- Only download from official sources
- Report security issues immediately
- Don't modify application files

## Frequently Asked Questions

### Q: Is my data secure?
A: Yes, all data is encrypted and stored locally. No data is sent to external servers.

### Q: Can I install on multiple computers?
A: Yes, you can install on as many computers as needed (subject to your license terms).

### Q: Do I need internet connection?
A: Internet is only required for automatic updates. The application works offline for daily use.

### Q: How do I transfer my data to a new computer?
A: Backup your `users.json` and `data.encrypted` files, then restore them on the new computer.

### Q: What if I forget my password?
A: Contact your system administrator. If you are the admin, you may need to reinstall the application.

### Q: Can I customize the application?
A: Some customizations are possible through settings. Contact support for advanced customizations.

### Q: Is there a mobile version?
A: Currently, this is a Windows-only application. Mobile versions may be developed in the future.

### Q: How do I report bugs or request features?
A: Contact your system administrator or use the support channels provided by your organization.

## Support

### Getting Help
- Contact your system administrator
- Check the application documentation
- Review error logs if available
- Consult with other users

### Error Reporting
- Note the error message
- Record steps to reproduce
- Check application logs
- Provide screenshots if helpful

## System Requirements Detail

### Windows Versions Supported
- Windows 7 (with Service Pack 1)
- Windows 8.1
- Windows 10 (version 1607 or later)
- Windows 11

### Required Components
- .NET Framework 4.6.1 or later (usually pre-installed)
- DirectX 9.0c or later (usually pre-installed)
- Visual C++ Redistributable (usually pre-installed)

### Optional Components
- Internet connection (for updates)
- Administrative privileges (for installation)

## Privacy and Data Collection

### Data Storage
- All data is stored locally on your computer
- No personal data is collected or transmitted
- Encrypted data files ensure privacy

### Telemetry
- No telemetry or analytics are collected
- Application usage is not tracked
- No data is sent to third parties

## Legal and Compliance

### License Terms
- This software is provided under license terms specified by your organization
- Commercial use may require specific licensing
- Redistribution may be restricted

### Compliance
- Application complies with relevant data protection regulations
- Encryption meets industry standards
- Regular security updates provided

## Additional Resources

### Documentation
- User Manual: Available within the application
- Technical Guide: Provided to administrators
- Update Notes: Included with each update

### Training
- Basic training available for new users
- Advanced training for administrators
- Video tutorials may be available

### Updates and Announcements
- Check for updates regularly
- Subscribe to update notifications
- Review release notes for new features

## Contact Information

### Technical Support
- Email: support@yourcompany.com
- Phone: (Your support number)
- Website: https://yourwebsite.com/support

### Business Hours
- Monday-Friday: 9:00 AM - 5:00 PM
- Emergency support: Available as per your service agreement

---

**Thank you for using Pharmacy Expense Tracker!**

For the most up-to-date information, please visit our website or contact support directly.