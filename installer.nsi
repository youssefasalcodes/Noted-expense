; ============================================
; Noted Expense - NSIS Installer Script
; ============================================

Unicode True

; --- Metadata ---
!define APP_NAME        "Noted Expense"
!define APP_VERSION     "1.0.0"
!define APP_PUBLISHER   "Youssef Asal"
!define APP_EXE         "NotedExpense.exe"
!define INSTALL_DIR     "$PROGRAMFILES64\NotedExpense"
!define REG_KEY         "Software\Microsoft\Windows\CurrentVersion\Uninstall\NotedExpense"

; --- Modern UI ---
!include "MUI2.nsh"
!include "LogicLib.nsh"

; --- General Settings ---
Name            "${APP_NAME} ${APP_VERSION}"
OutFile         "dist\NotedExpense_Setup_${APP_VERSION}.exe"
InstallDir      "${INSTALL_DIR}"
InstallDirRegKey HKLM "${REG_KEY}" "InstallLocation"
RequestExecutionLevel admin
SetCompressor   /SOLID lzma

; --- MUI Settings ---
!define MUI_ABORTWARNING

!define MUI_WELCOMEPAGE_TITLE   "Welcome to ${APP_NAME} Setup"
!define MUI_WELCOMEPAGE_TEXT    "This wizard will guide you through the installation of ${APP_NAME} ${APP_VERSION}.$\r$\n$\r$\nClick Next to continue."

!define MUI_FINISHPAGE_RUN          "$INSTDIR\${APP_EXE}"
!define MUI_FINISHPAGE_RUN_TEXT     "Launch ${APP_NAME} now"
!define MUI_FINISHPAGE_LINK         "Visit GitHub Page"
!define MUI_FINISHPAGE_LINK_LOCATION "https://github.com/youssefasalcodes/Noted-Expense"

; --- Pages ---
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; --- Language ---
!insertmacro MUI_LANGUAGE "English"

; ============================================
; Installer Sections
; ============================================

Section "Main Application" SecMain

    SectionIn RO   ; required, can't be unchecked

    SetOutPath "$INSTDIR"

    File "dist\NotedExpense\NotedExpense.exe"
    File "dist\NotedExpense\users.json"
    File "dist\NotedExpense\data.encrypted"
    File "dist\NotedExpense\version.json"
    File "dist\NotedExpense\README.txt"

    SetOutPath "$INSTDIR\resources"
    File /r "dist\NotedExpense\resources\*.*"

    SetOutPath "$INSTDIR"

    ; --- Create Start Menu Shortcut ---
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\Uninstall.exe"

    ; --- Write Registry (for Add/Remove Programs) ---
    WriteRegStr   HKLM "${REG_KEY}" "DisplayName"     "${APP_NAME}"
    WriteRegStr   HKLM "${REG_KEY}" "DisplayVersion"  "${APP_VERSION}"
    WriteRegStr   HKLM "${REG_KEY}" "Publisher"       "${APP_PUBLISHER}"
    WriteRegStr   HKLM "${REG_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr   HKLM "${REG_KEY}" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr   HKLM "${REG_KEY}" "DisplayIcon"     "$INSTDIR\${APP_EXE}"
    WriteRegDWORD HKLM "${REG_KEY}" "NoModify"        1
    WriteRegDWORD HKLM "${REG_KEY}" "NoRepair"        1

    WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

Section "Desktop Shortcut" SecDesktop

    CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"

SectionEnd

; --- Section Descriptions ---
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMain}    "Core application files. Required."
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} "Add a shortcut to your Desktop."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; ============================================
; Uninstaller
; ============================================

Section "Uninstall"

    Delete "$INSTDIR\${APP_EXE}"
    Delete "$INSTDIR\users.json"
    Delete "$INSTDIR\data.encrypted"
    Delete "$INSTDIR\version.json"
    Delete "$INSTDIR\README.txt"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir  /r "$INSTDIR\resources"
    RMDir  "$INSTDIR"

    Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk"
    RMDir  "$SMPROGRAMS\${APP_NAME}"
    Delete "$DESKTOP\${APP_NAME}.lnk"

    DeleteRegKey HKLM "${REG_KEY}"

SectionEnd