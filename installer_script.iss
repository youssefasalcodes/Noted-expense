; Pharmacy Expense Tracker - Professional Windows Installer
; Single .exe installer for easy distribution

[Setup]
AppName=Pharmacy Expense Tracker
AppVersion=1.0.0
AppVerName=Pharmacy Expense Tracker v1.0.0
AppPublisher=Pharmacy Expense Tracker
DefaultDirName={autopf}\PharmacyExpenseTracker
DefaultGroupName=Pharmacy Expense Tracker
AllowNoIcons=yes
OutputDir=dist
OutputBaseFilename=PharmacyExpenseTracker_Setup
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=admin
WizardStyle=modern
DisableDirPage=no
DisableProgramGroupPage=no
UninstallDisplayIcon={app}\PharmacyExpenseTracker.exe
CreateAppDir=yes
; Remove license file reference
; LicenseFile=LICENSE.txt

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
; Main executable - single file with everything bundled
Source: "dist\PharmacyExpenseTracker.exe"; DestDir: "{app}"; Flags: ignoreversion

; Include supporting files if they exist
Source: "users.json"; DestDir: "{app}"; Flags: ignoreversion; Attribs: hidden
Source: "data.encrypted"; DestDir: "{app}"; Flags: ignoreversion; Attribs: hidden  
Source: "version.json"; DestDir: "{app}"; Flags: ignoreversion; Attribs: hidden
Source: "app_updater.py"; DestDir: "{app}"; Flags: ignoreversion; Attribs: hidden

[Icons]
Name: "{group}\Pharmacy Expense Tracker"; Filename: "{app}\PharmacyExpenseTracker.exe"
Name: "{group}\Uninstall Pharmacy Expense Tracker"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Pharmacy Expense Tracker"; Filename: "{app}\PharmacyExpenseTracker.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\PharmacyExpenseTracker.exe"; Description: "Launch Pharmacy Expense Tracker"; Flags: nowait postinstall skipifsilent