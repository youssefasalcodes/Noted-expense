# Pharmacy Expense Tracker - Windows Setup

This package contains all the necessary files to run the Pharmacy Expense Tracker application on Windows.

## Prerequisites
- Windows 7 or later
- Python 3.8 or later (64-bit recommended)
- Internet connection (for first-time setup to download dependencies)

## Quick Start

1. **Extract the ZIP file** to your preferred location
2. **Run the setup script**:
   - Double-click `setup.bat` (Windows)
   - Or open Command Prompt in the extracted folder and run:
     ```
     pip install -r requirements_windows.txt
     ```
3. **Launch the application**:
   - Double-click `run.bat` (Windows)
   - Or run from Command Prompt:
     ```
     python Test.py
     ```

## Default Login
- **Username**: admin
- **Password**: admin123 (change this after first login)

## Directory Structure
```
PharmacyExpenseTracker/
├── Test.py              # Main application
├── Insert_data.ui       # UI definition
├── resources.qrc        # Resource definitions
├── resources_rc.py      # Compiled resources
├── users.json           # User database (created on first run if not exists)
├── data.encrypted       # Encrypted application data
├── requirements_windows.txt  # Python dependencies
├── resources/           # Resource files
│   └── images/          # Application images
└── README_WINDOWS.md    # This file
```

## First Run
1. The application will create necessary files on first run
2. Log in with the default credentials
3. Change the admin password immediately
4. Start adding your pharmacy expense data

## Troubleshooting

### Common Issues
- **Missing Dependencies**: Run `pip install -r requirements_windows.txt`
- **Permission Errors**: Run Command Prompt as Administrator
- **Blank Screen**: Ensure all files are extracted and in the correct locations

### Logs
- Check `app_error.log` for error messages
- Application logs are saved in the same directory

## Support
For assistance, please contact your system administrator or refer to the application documentation.

---

Happy tracking!
