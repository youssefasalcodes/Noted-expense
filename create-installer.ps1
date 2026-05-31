# Professional Installer Creator for Pharmacy Expense Tracker
# This script creates a single .exe installer using Inno Setup

$ErrorActionPreference = "Stop"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$DistDir = Join-Path $ScriptPath "dist"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Professional Installer Creator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Read version
$Version = "1.0.0"
$VersionFile = Join-Path $ScriptPath "version.json"
if (Test-Path $VersionFile) {
    $VersionJson = Get-Content $VersionFile | ConvertFrom-Json
    $Version = $VersionJson.version
}

Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host ""

# Check for main executable
$ExeFile = Join-Path $DistDir "PharmacyExpenseTracker.exe"
if (-not (Test-Path $ExeFile)) {
    Write-Host "ERROR: PharmacyExpenseTracker.exe not found in dist folder!" -ForegroundColor Red
    Write-Host "Please run build_secure.bat first to create the executable." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Found: PharmacyExpenseTracker.exe" -ForegroundColor Green
Write-Host ""

# Find Inno Setup
Write-Host "Searching for Inno Setup..." -ForegroundColor Yellow
$InnoPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe",
    "C:\Program Files (x86)\Inno Setup 5\ISCC.exe",
    "C:\Program Files\Inno Setup 5\ISCC.exe"
)

$InnoPath = $null
foreach ($Path in $InnoPaths) {
    if (Test-Path $Path) {
        $InnoPath = $Path
        Write-Host "Found Inno Setup at: $Path" -ForegroundColor Green
        break
    }
}

if (-not $InnoPath) {
    Write-Host "Inno Setup not found in standard locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "MANUAL INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Open Inno Setup from your Start Menu"
    Write-Host "2. Click 'File' > 'Open' and select: $ScriptPath\installer_script.iss"
    Write-Host "3. Click 'Build' > 'Compile'"
    Write-Host "4. The installer will be created in the dist folder"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Update installer script
Write-Host "Updating installer script..." -ForegroundColor Yellow
$IssFile = Join-Path $ScriptPath "installer_script.iss"
$TempIssFile = Join-Path $DistDir "installer_current.iss"
Copy-Item $IssFile $TempIssFile -Force

# Replace version
$IssContent = Get-Content $TempIssFile -Raw
$IssContent = $IssContent -replace 'AppVersion=1.0.0', "AppVersion=$Version"
$IssContent = $IssContent -replace 'AppVerName=Pharmacy Expense Tracker v1.0.0', "AppVerName=Pharmacy Expense Tracker v$Version"
$IssContent = $IssContent -replace 'OutputBaseFilename=PharmacyExpenseTracker_Setup', "OutputBaseFilename=PharmacyExpenseTracker_Setup_v$Version"
Set-Content $TempIssFile $IssContent

Write-Host "Installer script updated" -ForegroundColor Green
Write-Host ""

# Run Inno Setup
Write-Host "Creating installer..." -ForegroundColor Yellow
$Process = Start-Process -FilePath $InnoPath -ArgumentList $TempIssFile -Wait -PassThru

if ($Process.ExitCode -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "INSTALLER CREATED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Location: $DistDir\PharmacyExpenseTracker_Setup_v$Version.exe" -ForegroundColor Cyan
    Write-Host "Version: $Version" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This is a single .exe file that users can double-click" -ForegroundColor Yellow
    Write-Host "to install the application like professional software." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installation features:" -ForegroundColor Cyan
    Write-Host "- Professional setup wizard" -ForegroundColor White
    Write-Host "- Creates desktop shortcut" -ForegroundColor White
    Write-Host "- Creates Start Menu shortcut" -ForegroundColor White
    Write-Host "- Installs to Program Files" -ForegroundColor White
    Write-Host "- Includes uninstaller" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ERROR: Installer creation failed!" -ForegroundColor Red
    Write-Host "Exit code: $($Process.ExitCode)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please check the Inno Setup output above for details." -ForegroundColor Yellow
    Write-Host ""
}

Read-Host "Press Enter to exit"